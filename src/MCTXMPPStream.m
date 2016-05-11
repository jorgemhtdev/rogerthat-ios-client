/*
 * Copyright 2016 Mobicage NV
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @@license_version:1.1@@
 */

#import "MCTXMPPStream.h"
#import "MCTXMPPSRVResolver.h"
#import "MCTSecurity.h"
#import "XMPPJID.h"

/**
 * Seeing a return statements within an inner block
 * can sometimes be mistaken for a return point of the enclosing method.
 * This makes inline blocks a bit easier to read.
 **/
#define return_from_block  return

// Define the timeouts (in seconds) for SRV
#define TIMEOUT_SRV_RESOLUTION 30.0


@interface XMPPStream ()

- (void)tryNextSrvResult;
- (BOOL)isP2P;
- (BOOL)connectToHost:(NSString *)host onPort:(UInt16)port withTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr;
- (void)startConnectTimeout:(NSTimeInterval)timeout;

@end


@interface MCTXMPPStream ()

@property BOOL foundGoodConnection;
@property (nonatomic, strong) MCTXMPPConnectionFactory *connectionFactory;

- (void)tryNextSrvResult;

@end


@implementation MCTXMPPStream

- (void)tryNextSrvResult
{
    XMPPHERE(); // DNS SRV resolving finished
    if (self.foundGoodConnection) {
        [super tryNextSrvResult];
    } else {
        MCT_RELEASE(self.connectionFactory);
        self.connectionFactory = [[MCTXMPPConnectionFactory alloc] initWithDelegate:self
                                                                       andSrvRecords:srvResults
                                                                           xmppQueue:xmppQueue];
        [self.connectionFactory findGoodConnection];
    }
}

- (BOOL)connectWithTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr
{
    self.foundGoodConnection = NO;

    __block BOOL result = NO;
    __block NSError *err = nil;

    dispatch_block_t block = ^{ @autoreleasepool {

        if (state != STATE_XMPP_DISCONNECTED)
        {
            NSString *errMsg = @"Attempting to connect while already connected or connecting.";
            NSDictionary *info = @{NSLocalizedDescriptionKey : errMsg};

            err = [NSError errorWithDomain:XMPPStreamErrorDomain code:XMPPStreamInvalidState userInfo:info];

            result = NO;
            return_from_block;
        }

        if ([self isP2P])
        {
            NSString *errMsg = @"P2P streams must use either connectTo:withAddress: or connectP2PWithSocket:.";
            NSDictionary *info = @{NSLocalizedDescriptionKey : errMsg};

            err = [NSError errorWithDomain:XMPPStreamErrorDomain code:XMPPStreamInvalidType userInfo:info];

            result = NO;
            return_from_block;
        }

        if (myJID_setByClient == nil)
        {
            // Note: If you wish to use anonymous authentication, you should still set myJID prior to calling connect.
            // You can simply set it to something like "anonymous@<domain>", where "<domain>" is the proper domain.
            // After the authentication process, you can query the myJID property to see what your assigned JID is.
            //
            // Setting myJID allows the framework to follow the xmpp protocol properly,
            // and it allows the framework to connect to servers without a DNS entry.
            //
            // For example, one may setup a private xmpp server for internal testing on their local network.
            // The xmpp domain of the server may be something like "testing.mycompany.com",
            // but since the server is internal, an IP (192.168.1.22) is used as the hostname to connect.
            //
            // Proper connection requires a TCP connection to the IP (192.168.1.22),
            // but the xmpp handshake requires the xmpp domain (testing.mycompany.com).

            NSString *errMsg = @"You must set myJID before calling connect.";
            NSDictionary *info = @{NSLocalizedDescriptionKey : errMsg};

            err = [NSError errorWithDomain:XMPPStreamErrorDomain code:XMPPStreamInvalidProperty userInfo:info];

            result = NO;
            return_from_block;
        }

        // Notify delegates
        [multicastDelegate xmppStreamWillConnect:self];

        if ([hostName length] == 0)
        {
            // Resolve the hostName via myJID SRV resolution

            state = STATE_XMPP_RESOLVING_SRV;

            srvResolver = [[MCTXMPPSRVResolver alloc] initWithdDelegate:self delegateQueue:xmppQueue resolverQueue:NULL];

            srvResults = nil;
            srvResultsIndex = 0;

            NSString *srvName = [MCTXMPPSRVResolver srvNameFromXMPPDomain:[myJID_setByClient domain]];

            [srvResolver startWithSRVName:srvName timeout:TIMEOUT_SRV_RESOLUTION];

            result = YES;
        }
        else
        {
            // Open TCP connection to the configured hostName.
            
            state = STATE_XMPP_CONNECTING;
            
            NSError *connectErr = nil;
            result = [self connectToHost:hostName onPort:hostPort withTimeout:XMPPStreamTimeoutNone error:&connectErr];
            
            if (!result)
            {
                err = connectErr;
                state = STATE_XMPP_DISCONNECTED;
            }
        }
        
        if(result)
        {
            [self startConnectTimeout:timeout];
        }
    }};
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    if (errPtr)
        *errPtr = err;
    
    return result;
}

#pragma mark - MCTXMPPConnectionFactoryDelegate

- (void)connectionFactory:(MCTXMPPConnectionFactory *)factory didFindGoodSrvResult:(XMPPSRVRecord *)record
{
    if (factory != self.connectionFactory)
        return;

    XMPPHERE();
    self.foundGoodConnection = YES;
    srvResults = [NSArray arrayWithObject:record];
    srvResultsIndex = 0;

    MCT_RELEASE(self.connectionFactory);

    [self tryNextSrvResult];
}

- (void)connectionFactoryDidNotFindGoodSrvResult:(MCTXMPPConnectionFactory *)factory
{
    if (factory != self.connectionFactory)
        return;

    XMPPHERE();
    MCT_RELEASE(self.connectionFactory);
    self.foundGoodConnection = NO;
    srvResultsIndex = [srvResults count]; // making sure tryNextSrvResult is not called if there are srvResults
    if (srvResultsIndex == 0) {
        [super tryNextSrvResult]; // will fall back to <domain>:5222
    } else {
        [self socketDidDisconnect:nil withError:[NSError errorWithDomain:@"CouldNotConnectToAnyOfTheXmppTargets"
                                                                    code:1
                                                                userInfo:nil]];
    }
}

#pragma mark - SSL

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    HERE();
    if ([MCTSecurity hasTrustedCertificate]) {
        [sock performBlock:^{
            NSError *error = [MCTSecurity validateStream:objc_unretainedObject([sock readStream])];
            if (error) {
                [sock performSelector:@selector(closeWithError:) withObject:error];
            }
        }];
    }

    [super socketDidSecure:sock];
}

@end