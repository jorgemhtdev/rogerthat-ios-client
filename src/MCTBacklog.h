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

#import "MCTUtils.h"
#import "MCTJSONUtils.h"
#import "MCTRPCCall.h"
#import "MCTRPCResponse.h"
#import "MCTAbstractResponseHandler.h"
#import "MCTBacklogStreamer.h"
#import "MCTStore.h"

#import "sqlite3.h"

#define MCT_BACKLOG_MESSAGE_TYPE_CALL 0
#define MCT_BACKLOG_MESSAGE_TYPE_RESPONSE 1

@interface MCTBacklog : MCTStore

- (BOOL)hasItemsToSend;

- (void)insertOutgoingRpcCall:(MCTRPCCall *)call
            withRequestString:(NSString *)requestString
          withResponseHandler:(MCTAbstractResponseHandler *)responseHandler;

- (void)insertIncomingRpcCall:(MCTRPCCall *)call;

- (BOOL)itemHasBody:(NSString *)callid;

- (void)updateBody:(MCTRPCResponse *)response;

- (NSString *)bodyForCallid:(NSString *)callid;

- (void)freezeRetentionForItem:(NSString *)callid;

- (void)updateLastResendTimestamp:(MCTlong)timestamp forCallid:(NSString *)callid;

- (void)deleteItem:(NSString *)callid;

- (void)deleteAllItems;

- (MCTAbstractResponseHandler *)responseHandlerForCallid:(NSString *)callid;

- (void)doRetentionCleanup;

- (MCTBacklogStreamer *)backlogStreamerWithFilterOnWifiOnly:(BOOL)filterOnWifiOnly;

@end