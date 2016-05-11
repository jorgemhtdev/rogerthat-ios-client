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

#import "3rdParty/xmppframework/Core/XMPPStream.h"
#import "3rdParty/xmppframework/Extensions/Reconnect/XMPPReconnect.h"
#import "3rdParty/xmppframework/Extensions/Roster/XMPPRoster.h"
#import "3rdParty/xmppframework/Extensions/Roster/MemoryStorage/XMPPRosterMemoryStorage.h"

#import "MCTCredentials.h"


@protocol MCTXMPPConnectionDelegate

@required
- (void)xmppConnected;
- (void)xmppDisconnectedWithWasAnalysing:(BOOL)wasAnalysing;

@optional
- (void)didReceiveIQ:(XMPPIQ *)iq;
- (void)didReceiveMessage:(XMPPMessage *)message;
- (void)didReceivePresence:(XMPPPresence *)presence;

@end


@interface MCTXMPPConnection : NSObject <XMPPStreamDelegate, XMPPRosterDelegate, XMPPReconnectDelegate>

@property(nonatomic, strong) XMPPStream *xmppStream;
@property(atomic, assign) BOOL kickOnNextAnalyse;
@property(atomic, assign) BOOL reconnectOnNextDisconnect;

- (MCTXMPPConnection *)initWithCredentials:(MCTCredentials *)credentials;

- (void)connect;
- (void)connectWithDelegate:(NSObject<MCTXMPPConnectionDelegate> *)delegate;

- (void)disconnect;

- (void)keepAlive;

 // Synchronously executed by xmppQueue
- (BOOL)getAnalysingAndSetKickOnNextAnalyseIfAnalising:(BOOL)kickOnNextAnalyse;

@end