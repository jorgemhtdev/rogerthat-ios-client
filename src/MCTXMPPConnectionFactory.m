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

#import "MCTXMPPConnectionFactory.h"

#define XMPP_MAX_CONNECT 30
#define XMPP_MAX_TRY_PREFERRED_PORT 3


@interface MCTXMPPConnectionFactory ()

@property (nonatomic, strong) NSMutableArray *srvRecords;
@property (nonatomic, strong) NSMutableArray *allSockets;
@property (nonatomic, strong) NSMutableArray *remainingSockets;
@property (nonatomic) int preferredPort;
@property (nonatomic, strong) XMPPSRVRecord *goodSrvRecord;
@property(nonatomic, assign) dispatch_queue_t xmppQueue;


- (void)finish;

- (void)waitingForPreferredPortTimedOut;
- (void)endWaitForPreferredPortTimer;
- (void)startWaitForPreferredPortTimer:(NSTimeInterval)timeout;

@end


@implementation MCTXMPPConnectionFactory


- (id)initWithDelegate:(id <MCTXMPPConnectionFactoryDelegate>)delegate andSrvRecords:(NSArray *)srvRecords xmppQueue:(dispatch_queue_t)xmppQueue
{
    if (self = [super init]) {
        self.delegate = delegate;
        self.srvRecords = [NSMutableArray arrayWithArray:srvRecords];
        self.preferredPort = [srvRecords count] ? ((XMPPSRVRecord *) [srvRecords objectAtIndex:0]).port : 0;
        self.xmppQueue = xmppQueue;
    }
    return self;
}

- (void)findGoodConnection
{
    self.allSockets = [NSMutableArray array];
    self.remainingSockets = [NSMutableArray array];
    self.goodSrvRecord = nil;

    for (XMPPSRVRecord *srvRecord in self.srvRecords) {
        const char *sq = [[NSString stringWithFormat:@"Queue for %@", [srvRecord hostName]] UTF8String];
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                             delegateQueue:self.xmppQueue
                                                               socketQueue:dispatch_queue_create(sq, NULL)];
        [self.allSockets addObject:socket];

        NSError *connectError = nil;
        if([socket connectToHost:srvRecord.target
                          onPort:srvRecord.port
                     withTimeout:XMPP_MAX_CONNECT
                           error:&connectError]) {
            [self.remainingSockets addObject:socket];
        } else {
            XMPPLOG(@"Ignoring socket due to connection error: %@", connectError);
        }
    }

    if ([self.remainingSockets count] == 0) {
        XMPPLOG(@"Error: could not connect to any of the XMPP DNS SRV records");
        [self finish];
    }
}

- (void)finish
{
    XMPPHERE();
    if (self.waitForPreferredPortTimer) {
        [self endWaitForPreferredPortTimer];
    }

    XMPPLOG(@"Closing attempted sockets");
    for (GCDAsyncSocket *sock in self.allSockets) {
        [sock setDelegate:nil];
        [sock disconnect];
    }
    XMPPLOG(@"All attempted sockets are closed now");
    MCT_RELEASE(self.allSockets);
    MCT_RELEASE(self.remainingSockets);

    if (self.goodSrvRecord == nil) {
        XMPPLOG(@"Did not find a good host address");
        [self.delegate connectionFactoryDidNotFindGoodSrvResult:self];
    } else {
        XMPPLOG(@"Using xmpp host %@", [self.goodSrvRecord hostName]);

        [self.delegate connectionFactory:self didFindGoodSrvResult:self.goodSrvRecord];
    }

    MCT_RELEASE(self.goodSrvRecord);
}

#pragma mark -
#pragma mark Timers

- (void)waitingForPreferredPortTimedOut
{
    XMPPHERE();
    XMPPLOG(@"Give up looking for responsive XMPP host with preferred port");
    [self finish];
}

- (void)endWaitForPreferredPortTimer
{
    XMPPHERE();
    if (self.waitForPreferredPortTimer) {
        dispatch_source_cancel(self.waitForPreferredPortTimer);
        self.waitForPreferredPortTimer = NULL;
    }
}

- (void)startWaitForPreferredPortTimer:(NSTimeInterval)timeout
{
    if (timeout >= 0.0)
    {
        self.waitForPreferredPortTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.xmppQueue);

        dispatch_source_set_event_handler(self.waitForPreferredPortTimer, ^{
            [self waitingForPreferredPortTimedOut];
        });

        dispatch_source_t theTimer = self.waitForPreferredPortTimer;
        dispatch_source_set_cancel_handler(self.waitForPreferredPortTimer, ^{
            LOG(@"dispatch_release(waitForPreferredPortTimer_)");
        });

        dispatch_time_t tt = dispatch_time(DISPATCH_TIME_NOW, (timeout * NSEC_PER_SEC));
        dispatch_source_set_timer(self.waitForPreferredPortTimer, tt, DISPATCH_TIME_FOREVER, 0);

        dispatch_resume(self.waitForPreferredPortTimer);
    }
}

- (BOOL)stillWaitingForConnectionWithPreferredPort
{
    for (GCDAsyncSocket *sock in self.remainingSockets) {
        XMPPSRVRecord *record = [self.srvRecords objectAtIndex:[self.allSockets indexOfObject:sock]];
        if (record.port == self.preferredPort) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -
#pragma mark GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    if (self.allSockets == nil || ![self.allSockets containsObject:sock]) {
        return; // this operation was queued before the socket disconnected. Ignoring ...
    }

    // Get corresponding SRV record
    XMPPSRVRecord *srvRecord = [self.srvRecords objectAtIndex:[self.allSockets indexOfObject:sock]];
    XMPPLOG(@"Successful connection to %@", srvRecord);
    [self.remainingSockets removeObject:sock];

    if (self.goodSrvRecord) {
        // We already found a host. Pick this one only if the one we found already was not using the preferred XMPP port,
        // and the new one does have the preferred XMPP port
        if (self.goodSrvRecord.port != self.preferredPort && srvRecord.port == self.preferredPort) {
            self.goodSrvRecord = srvRecord;
            XMPPLOG(@"Found better host: %@", [srvRecord hostName]);
            [self finish];
            return;
        } else {
            XMPPLOG(@"Old host was better: %@", [srvRecord hostName]);
        }
    } else {
        XMPPLOG(@"Selecting host: %@", [srvRecord hostName]);
        self.goodSrvRecord = srvRecord;
        if (self.preferredPort == srvRecord.port) {
            [self finish];
            return;
        } else {
            // We got a connection to a non-preferred port.
            if (!self.waitForPreferredPortTimer) {
                if ([self stillWaitingForConnectionWithPreferredPort]) {
                    // Wait at most |XMPP_MAX_TRY_PREFERRED_PORT| seconds on a connection to the preferred port.
                    [self startWaitForPreferredPortTimer:XMPP_MAX_TRY_PREFERRED_PORT];
                } else {
                    XMPPLOG(@"No more XMPP hosts with preferred port to wait for");
                    [self finish];
                    return;
                }
            }
        }
    }

    if ([self.remainingSockets count] == 0) {
        XMPPLOG(@"No more XMPP hosts to check");
        [self finish];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    // Get corresponding SRV record
    XMPPSRVRecord *srvRecord = [self.srvRecords objectAtIndex:[self.allSockets indexOfObject:sock]];
    XMPPLOG(@"Failed connection to %@ with error: %@", srvRecord, err);
    [self.remainingSockets removeObject:sock];

    if ([self.remainingSockets count] == 0) {
        XMPPLOG(@"No more XMPP hosts to check");
        [self finish];
    }
}

@end


#pragma mark -

@implementation XMPPSRVRecord (MCTXMPPConnectionFactory)

- (NSString *)hostName
{
    return [NSString stringWithFormat:@"%@:%d", target, port];
}

@end