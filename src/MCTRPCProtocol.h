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

#import "MCTBacklog.h"
#import "MCTCredentials.h"
#import "MCTCallReceiver.h"
#import "MCTAbstractResponseHandler.h"

#define MCT_PROTOCOL_VERSION 1
#define MCT_MAX_PACKET_SIZE 153600 // 150KB

@interface MCTRPCProtocol : NSObject

@property(nonatomic, retain, setter=setCredentials:) MCTCredentials *credentials;
@property(nonatomic, strong) MCTCredentials *headerCredentials;
@property(nonatomic, weak) MCTBacklog *backlog;
@property(nonatomic, weak) MCTCallReceiver *callReceiver;
@property(nonatomic, strong) NSMutableArray *acksToSend;
@property(nonatomic, strong) NSMutableArray *responsesToSend;
@property(nonatomic, copy) NSString *defaultUrl;
@property(nonatomic, copy) NSString *alternativeUrl;

- (void)resetDestinationUrl;

- (BOOL)processIncomingMessagesStr:(NSString *)messagesStr;

- (void)onCallProcessed:(NSString *)callid;

- (void)onResponseProcessed:(NSString *)callid;

- (void)callToServerWithFunction:(NSString *)function andArguments:(NSDictionary *)arguments andResponseHandler:(MCTAbstractResponseHandler *)responseHandler;

@end