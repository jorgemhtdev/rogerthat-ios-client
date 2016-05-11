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

#import <CFNetwork/CFSocketStream.h>

#import "3rdParty/xmppframework/Categories/NSXMLElement+XMPP.h"
#import "3rdParty/xmppframework/Core/XMPPJID.h"
#import "3rdParty/xmppframework/Core/XMPPIQ.h"
#import "3rdParty/xmppframework/Core/XMPPMessage.h"
#import "3rdParty/xmppframework/Extensions/XEP-0199/XMPPPing.h"

#import "MCTComponentFramework.h"
#import "MCTConfigProvider.h"
#import "MCTLogForwarding.h"
#import "MCTSecurity.h"
#import "MCTXMPPConnection.h"
#import "MCTXMPPStream.h"

#define KICK_HTTP_COMMAND @"kickHTTP"
#define MCT_XMPP_PING_TIMEOUT 5

@interface MCTXMPPConnection ()

@property(nonatomic, strong) dispatch_queue_t xmppQueue;
@property(nonatomic, strong) XMPPRoster *xmppRoster;
@property(nonatomic, strong) XMPPRosterMemoryStorage *xmppRosterStorage;
@property(nonatomic, strong) XMPPReconnect *xmppReconnect;

// Live on COMM thread
@property(nonatomic, strong) MCTCredentials *credentials;
@property(nonatomic, strong) NSObject<MCTXMPPConnectionDelegate> *delegate;

@property(atomic, assign) BOOL analysing;

- (void)setupStream;
- (void)tearDownStream;
- (void)goOnline;
- (void)goOffline;

- (void)analyse;
- (void)setAnalysing:(BOOL)analysing;

@end


@implementation MCTXMPPConnection


- (MCTXMPPConnection *)initWithCredentials:(MCTCredentials *)credentials
{
    T_BACKLOG();
    XMPPHERE();
    if (self = [super init]) {
        self.kickOnNextAnalyse = NO;
        self.reconnectOnNextDisconnect = NO;
        self.credentials = credentials;
        self.xmppQueue = dispatch_queue_create("XMPP", NULL);
        self.analysing = NO;
        [self setupStream];
    }
    return self;
}

- (void)dealloc
{
    T_BACKLOG();

    [self tearDownStream];
    [self disconnect];
}

- (BOOL)getAnalysingAndSetKickOnNextAnalyseIfAnalising:(BOOL)kickOnNextAnalyse
{
    T_BACKLOG();
    __block BOOL isAnalysing;
    dispatch_sync(self.xmppQueue, ^{
        if ((isAnalysing = _analysing)) {
            self.kickOnNextAnalyse = kickOnNextAnalyse;
        }
    });
    return isAnalysing;
}

#pragma mark -

- (void)setupStream
{
    T_DONTCARE();
    XMPPHERE();
    self.xmppStream = [[MCTXMPPStream alloc] init];
    self.xmppStream.enableBackgroundingOnSocket = YES;

    self.xmppRosterStorage = [[XMPPRosterMemoryStorage alloc] init];
    self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStorage];
    self.xmppRoster.autoFetchRoster = YES;

    self.xmppReconnect = [[XMPPReconnect alloc] initWithDispatchQueue:self.xmppQueue];

    [self.xmppStream    addDelegate:self delegateQueue:self.xmppQueue];
    [self.xmppRoster    addDelegate:self delegateQueue:self.xmppQueue];
    [self.xmppReconnect addDelegate:self delegateQueue:self.xmppQueue];

    [self.xmppReconnect activate:self.xmppStream];
    [self.xmppRoster    activate:self.xmppStream];
}

- (void)tearDownStream
{
    T_DONTCARE();
    XMPPHERE();
    [self.xmppStream    removeDelegate:self];
    [self.xmppReconnect removeDelegate:self];
    [self.xmppRoster    removeDelegate:self];

    [self.xmppRoster    deactivate];
    [self.xmppReconnect deactivate];

    [self.xmppStream disconnect];

    MCT_RELEASE(self.xmppStream);
    MCT_RELEASE(self.xmppReconnect);
    MCT_RELEASE(self.xmppRoster);
    MCT_RELEASE(self.xmppRosterStorage);
}

- (void)goOnline
{
    T_DONTCARE();
    XMPPHERE();
    self.analysing = NO;
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmppStream sendElement:presence];
    [self.delegate xmppConnected];
}

- (void)goOffline
{
    T_DONTCARE();
    XMPPHERE();
    self.analysing = NO;
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.xmppStream sendElement:presence];
}

#pragma -

- (void)connectWithDelegate:(NSObject<MCTXMPPConnectionDelegate> *)delegate
{
    T_BACKLOG();
    XMPPHERE();
    self.delegate = delegate;
    [self connect];
}

- (void)connect
{
    T_DONTCARE();
    XMPPHERE();
    if ([self.xmppStream isConnected]) {
        XMPPLOG(@"xmpp stream is already connected. not reconnecting...");
        return;
    }
    if (![self.xmppStream isDisconnected]) {
        XMPPLOG(@"xmpp stream is neither connected or disconnected. not reconnecting...");
        return;
    }
    if (![MCTUtils connectedToInternet]) {
        XMPPLOG(@"We're not connected to the internet. Not connecting...");
        return;
    }

    NSString *myJid = [NSString stringWithFormat:@"%@/i_%lld", self.credentials.username, [MCTUtils currentTimeMillis]];
    [self.xmppStream setMyJID:[XMPPJID jidWithString:myJid]];

    NSError *error = nil;
    if ([self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        XMPPLOG(@"Connecting XMPP ...");
    } else {
        XMPPERROR(@"Error connecting XMPP: %@", error);
    }
}

- (void)disconnect
{
    T_DONTCARE();
    XMPPHERE();
    [self goOffline];
    [self.xmppStream disconnect];
}

#pragma mark - XMPPPing

- (void)keepAlive
{
    T_DONTCARE();
    XMPPLOG(@"Posting analyse operation on XMPP thread");
    dispatch_async(self.xmppQueue, ^{
        [[[MCTComponentFramework commManager] xmppConnection] analyse];
    });
}

- (void)analyse
{
    XMPPHERE();
    XMPPLOG(@"Analysing XMPP connection");
    self.analysing = YES;

    if (![MCTUtils connectedToInternet]) {
        XMPPLOG(@"We're not connected to the internet. Disconnecting ...");
        [self disconnect];
        return;
    }

    if ([self.xmppStream isConnected]) {
        XMPPPing *ping = [[XMPPPing alloc] initWithDispatchQueue:self.xmppQueue];
        [ping activate:self.xmppStream];
        [ping addDelegate:self delegateQueue:self.xmppQueue];
        NSString *pingID = [ping sendPingToServerWithTimeout:MCT_XMPP_PING_TIMEOUT]; // 5 seconds
        XMPPLOG(@"Sending XMPP ping with pingID %@", pingID);
    } else {
        XMPPLOG(@"Trying XMPP Connection");
        [self connect];
    }
}

- (void)xmppPing:(XMPPPing *)sender didReceivePong:(XMPPIQ *)pong withRTT:(NSTimeInterval)rtt
{
    T_DONTCARE();
    XMPPLOG(@"did receive pong on ping %@ with rtt %ld", [pong elementID], rtt);
    XMPPLOG(@"**************************************************************************");
    [sender deactivate];

    self.analysing = NO;

    if (self.kickOnNextAnalyse) {
        [[MCTComponentFramework commManager] kick];
        self.kickOnNextAnalyse = NO;
    }
}

- (void)xmppPing:(XMPPPing *)sender didNotReceivePong:(NSString *)pingID dueToTimeout:(NSTimeInterval)timeout
{
    T_DONTCARE();
    XMPPLOG(@"PingID %@ - did not receive pong - timeout %ld", pingID, timeout);
    [sender deactivate];
    self.kickOnNextAnalyse = NO;

    if ([self.xmppStream isConnected]) {
        self.reconnectOnNextDisconnect = YES;
        [self disconnect];
    } else if ([self.xmppStream isDisconnected]) {
        [self connect];
    } else {
        XMPPLOG(@"XMPP is already connecting");
    }
}

#pragma mark - XMPPStreamDelegate

/**
 * This method is called immediately prior to the stream being secured via TLS/SSL.
 * Note that this delegate may be called even if you do not explicitly invoke the startTLS method.
 * Servers have the option of requiring connections to be secured during the opening process.
 * If this is the case, the XMPPStream will automatically attempt to properly secure the connection.
 *
 * The possible keys and values for the security settings are well documented.
 * Some possible keys are:
 * - kCFStreamSSLLevel
 * - kCFStreamSSLAllowsExpiredCertificates
 * - kCFStreamSSLAllowsExpiredRoots
 * - kCFStreamSSLAllowsAnyRoot
 * - kCFStreamSSLValidatesCertificateChain
 * - kCFStreamSSLPeerName
 * - kCFStreamSSLCertificates
 *
 * Please refer to Apple's documentation for associated values, as well as other possible keys.
 *
 * The dictionary of settings is what will be passed to the startTLS method of ther underlying AsyncSocket.
 * The AsyncSocket header file also contains a discussion of the security consequences of various options.
 * It is recommended reading if you are planning on implementing this method.
 *
 * The dictionary of settings that are initially passed will be an empty dictionary.
 * If you choose not to implement this method, or simply do not edit the dictionary,
 * then the default settings will be used.
 * That is, the kCFStreamSSLPeerName will be set to the configured host name,
 * and the default security validation checks will be performed.
 *
 * This means that authentication will fail if the name on the X509 certificate of
 * the server does not match the value of the hostname for the xmpp stream.
 * It will also fail if the certificate is self-signed, or if it is expired, etc.
 *
 * These settings are most likely the right fit for most production environments,
 * but may need to be tweaked for development or testing,
 * where the development server may be using a self-signed certificate.
 **/
- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    HERE();
    if ([MCTSecurity hasTrustedCertificate]) {
        // We will do the cert validation ourself
        [settings setObject:(id)kCFBooleanFalse forKey:(id)kCFStreamSSLValidatesCertificateChain];
    }
}

/**
 * This method is called after the XML stream has been fully opened.
 * More precisely, this method is called after an opening <xml/> and <stream:stream/> tag have been sent and received,
 * and after the stream features have been received, and any required features have been fullfilled.
 * At this point it's safe to begin communication with the server.
 **/
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    XMPPHERE();
    if (MCT_USE_SECURE_XMPP_CONNECTION && ![self.xmppStream isSecure]) {
        NSError *error = nil;
        if (![sender secureConnection:&error]) {
            XMPPERROR(@"Cannot secure: %@", error);
        }
    } else {
        NSError *error = nil;
        if (![self.xmppStream authenticateWithPassword:self.credentials.password error:&error]) {
            XMPPERROR(@"Cannot authenticate: %@", error);
        }
    }
}

/**
 * This method is called after authentication has successfully finished.
 * If authentication fails for some reason, the xmppStream:didNotAuthenticate: method will be called instead.
 **/
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    XMPPHERE();

    [self goOnline];
}

/**
 * This method is called if authentication fails.
 **/
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    XMPPHERE();
    XMPPLOG(@"XMPP could not authenticate - error %@", error);
    [self.delegate xmppDisconnectedWithWasAnalysing:self.analysing];
}

/**
 * These methods are called after their respective XML elements are received on the stream.
 *
 * In the case of an IQ, the delegate method should return YES if it has or will respond to the given IQ.
 * If the IQ is of type 'get' or 'set', and no delegates respond to the IQ,
 * then xmpp stream will automatically send an error response.
 **/
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    HERE();
    NSString *from = [iq fromStr];
    if (![from isEqualToString:MCT_XMPP_KICK_COMPONENT]) {
        XMPPLOG(@"Ignoring XMPP IQ from '%@'. Only accepting messages from '%@'.", from, MCT_XMPP_KICK_COMPONENT);
        return NO;
    }

    if ([self.delegate respondsToSelector:@selector(didReceiveIQ:)]) {
        NSObject<MCTXMPPConnectionDelegate> *bDelegate = self.delegate;
        [[MCTComponentFramework commQueue] addOperationWithBlock:^{
            [bDelegate didReceiveIQ:iq];
        }];

        return YES;
    }

    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSString *from = [message fromStr];
    if (![from isEqualToString:MCT_XMPP_KICK_COMPONENT]) {
        if (![[MCTLogForwarder logForwarder] forwarding])
            XMPPLOG(@"Ignoring XMPP message from '%@'. Only accepting messages from '%@'.", from, MCT_XMPP_KICK_COMPONENT);
        return;
    }

    HERE();
    XMPPLOG(@"xmppStream didReceiveMessage:\n%@", message);

    NSString *body = [[message elementForName:@"body"] stringValue];
    if (body == nil)
        return;

    if ([body isEqualToString:KICK_HTTP_COMMAND]) {
        XMPPLOG(@"**************************************************************************");
        XMPPLOG(@"XMPP command: kickHTTP");

        [[MCTComponentFramework commManager] kick];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    // HERE();
    // Do nothing
}

/**
 * There are two types of errors: TCP errors and XMPP errors.
 * If a TCP error is encountered (failure to connect, broken connection, etc) a standard NSError object is passed.
 * If an XMPP error is encountered (<stream:error> for example) an NSXMLElement object is passed.
 *
 * Note that standard errors (<iq type='error'/> for example) are delivered normally,
 * via the other didReceive...: methods.
 **/
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    XMPPHERE();
    XMPPLOG(@"XMPP error: %@", error);

    if ([error isKindOfClass:[XMPPMessage class]] && [((XMPPMessage *)error) elementForName:@"conflict"] != nil) {
        XMPPLOG(@"Creating new connection");
        self.reconnectOnNextDisconnect = NO;
        [self disconnect];
        [self tearDownStream];
        [self setupStream];
        [self connect];
    }
}

/**
 * This method is called after the stream is closed.
 **/
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error;
{
    XMPPHERE();
    if (error) {
        ERROR(@"xmppStreamDidDisconnect with error %@", error);
    }
    if (self.reconnectOnNextDisconnect) {
        self.reconnectOnNextDisconnect = NO;
        [self connect];
    } else {
        [self.delegate xmppDisconnectedWithWasAnalysing:self.analysing];
    }
}

#pragma mark - XMPPReconnectDelegate

- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags
{
    XMPPHERE();
    XMPPLOG(@"Disconnection - network reachability flags are %x", connectionFlags);
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)reachabilityFlags
{
    XMPPHERE();
    XMPPLOG(@"XMPP shouldAttemptAutoReconnect - network reachability flags are %x", reachabilityFlags);
    return (reachabilityFlags != 0);
}

@end