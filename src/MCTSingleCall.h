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

#define MCT_SINGLECALL_ACTIVITY_LOG_LOCATIONS @"com.mobicage.api.activity.logLocations"
#define MCT_SINGLECALL_MESSAGING_GET_CONVERSATION @"com.mobicage.api.messaging.getConversation"
#define MCT_SINGLECALL_MESSAGING_GET_CONVERSATION_AVATAR @"com.mobicage.api.messaging.getConversationAvatar"
#define MCT_SINGLECALL_SERVICES_START_ACTION @"com.mobicage.api.services.startAction"
#define MCT_SINGLECALL_SYSTEM_IDENTITY_QRCODE @"com.mobicage.api.system.getIdentityQRCode"
#define MCT_SINGLECALL_FRIENDS_GET_CATEGORY @"com.mobicage.api.friends.getCategory"
#define MCT_SINGLECALL_FRIENDS_GET_FRIEND @"com.mobicage.api.friends.getFriend"
#define MCT_SINGLECALL_FRIENDS_GET_USER_INFO @"com.mobicage.api.friends.getUserInfo"


@interface MCTAbstractSingleCall : NSObject

@property (nonatomic, copy) NSString *function;
@property (nonatomic, strong) NSDictionary *arguments;

+ (MCTAbstractSingleCall *)singleCallWithFunction:(NSString *)func arguments:(NSDictionary *)args;
+ (NSArray *)specialSingleCalls;

- (id)initWithFunction:(NSString *)func arguments:(NSDictionary *)args;
- (BOOL)isEqualToFunctionWithArguments:(NSDictionary *)args;

@end


@interface MCTStartServiceActionSingleCall : MCTAbstractSingleCall
@end


@interface MCTGetIdentityQRCodeSingleCall : MCTAbstractSingleCall
@end


@interface MCTGetConversationSingleCall : MCTAbstractSingleCall
@end


@interface MCTGetConversationAvatarSingleCall : MCTAbstractSingleCall
@end


@interface MCTGetCategorySingleCall : MCTAbstractSingleCall
@end


@interface MCTGetFriendSingleCall : MCTAbstractSingleCall
@end


@interface MCTGetUserInfoSingleCall : MCTAbstractSingleCall
@end


@interface MCTLogLocationsSingleCall : MCTAbstractSingleCall
@end