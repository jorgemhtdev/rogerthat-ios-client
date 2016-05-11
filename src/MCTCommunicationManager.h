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

#import "3rdParty/xmppframework/Core/XMPPJID.h"

#import "MCTBacklog.h"
#import "MCTCallReceiver.h"
#import "MCTCredentials.h"
#import "MCTIntentFramework.h"
#import "MCTOperation.h"
#import "MCTRPCProtocol.h"
#import "MCTXMPPConnection.h"

typedef enum {
    MCTCommunicationResultSuccess,
    MCTCommunicationResultError,
    MCTCommunicationResultConnecting,
    MCTCommunicationResultDisconnected,
} MCTCommunicationResult;


@interface MCTCommunicationLoop : NSObject

@property (nonatomic, copy) NSString *requestStr;
@property (nonatomic, copy) NSString *responseStr;
@property (nonatomic) int count;
@property (nonatomic) BOOL force;

+ (MCTCommunicationLoop *)loopWithCount:(int)count;

@end


#pragma mark -

@interface MCTCommunicationManager : NSObject <IMCTIntentReceiver, MCTXMPPConnectionDelegate, NSURLSessionDownloadDelegate> 

@property (nonatomic, strong) MCTBacklog *backlog;
@property (nonatomic, strong) MCTRPCProtocol *protocol;
@property (nonatomic, strong) MCTCallReceiver *callReceiver;
@property (nonatomic, strong) MCTCredentials *credentials;
@property (nonatomic) BOOL stopped;
@property (nonatomic) BOOL force;
@property (nonatomic, strong) MCTXMPPConnection *xmppConnection;
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSURLSession *logForwardingURLSession;

+ (NSString *)URLSessionIdentifier;
- (NSURLSession *)initializeURLSession;

+ (NSString *)logForwardingURLSessionIdentifier;
- (NSURLSession *)initializeLogForwardingURLSession;

- (void)kick;
- (void)terminate;

- (void)log:(NSString *)message toXmppAccount:(NSString *)target;

@end