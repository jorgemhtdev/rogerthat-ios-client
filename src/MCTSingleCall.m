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

#import "MCTComponentFramework.h"
#import "MCTSingleCall.h"


@implementation MCTAbstractSingleCall


+ (MCTAbstractSingleCall *)singleCallWithFunction:(NSString *)func arguments:(NSDictionary *)args
{
    if ([MCT_SINGLECALL_SERVICES_START_ACTION isEqualToString:func])
        return [[MCTStartServiceActionSingleCall alloc] initWithFunction:func arguments:args];
    if ([MCT_SINGLECALL_SYSTEM_IDENTITY_QRCODE isEqualToString:func])
                return [[MCTGetIdentityQRCodeSingleCall alloc] initWithFunction:func arguments:args];

    if ([MCT_SINGLECALL_MESSAGING_GET_CONVERSATION isEqualToString:func])
                        return [[MCTGetConversationSingleCall alloc] initWithFunction:func arguments:args];

    if ([MCT_SINGLECALL_MESSAGING_GET_CONVERSATION_AVATAR isEqualToString:func])
                                return [[MCTGetConversationAvatarSingleCall alloc] initWithFunction:func arguments:args];

    if ([MCT_SINGLECALL_FRIENDS_GET_CATEGORY isEqualToString:func])
                                        return [[MCTGetCategorySingleCall alloc] initWithFunction:func arguments:args];

    if ([MCT_SINGLECALL_FRIENDS_GET_FRIEND isEqualToString:func])
                                                return [[MCTGetFriendSingleCall alloc] initWithFunction:func arguments:args];

    if ([MCT_SINGLECALL_FRIENDS_GET_USER_INFO isEqualToString:func])
                                                        return [[MCTGetUserInfoSingleCall alloc] initWithFunction:func arguments:args];

    if ([MCT_SINGLECALL_ACTIVITY_LOG_LOCATIONS isEqualToString:func])
        return [[MCTLogLocationsSingleCall alloc] initWithFunction:func arguments:args];

    return nil;
}

+ (NSArray *)specialSingleCalls
{
    return @[MCT_SINGLECALL_SERVICES_START_ACTION,
             MCT_SINGLECALL_SYSTEM_IDENTITY_QRCODE,
             MCT_SINGLECALL_MESSAGING_GET_CONVERSATION,
             MCT_SINGLECALL_MESSAGING_GET_CONVERSATION_AVATAR,
             MCT_SINGLECALL_FRIENDS_GET_CATEGORY,
             MCT_SINGLECALL_FRIENDS_GET_FRIEND,
             MCT_SINGLECALL_FRIENDS_GET_USER_INFO,
             MCT_SINGLECALL_ACTIVITY_LOG_LOCATIONS];
}

- (id)initWithFunction:(NSString *)func arguments:(NSDictionary *)args
{
    if (self = [super init]) {
        self.function = func;
        self.arguments = args;
    }
    return self;
}

- (BOOL)isEqualToFunctionWithArguments:(NSDictionary *)otherArgs
{
    ERROR(@"Abstract function");
    return NO;
}

@end


@implementation MCTStartServiceActionSingleCall

- (BOOL)isEqualToFunctionWithArguments:(NSDictionary *)otherArgs
{
    NSDictionary *otherRequest = [otherArgs objectForKey:@"request"];
    if (otherRequest == nil)
        return NO;

    NSString *thisEmail = [self.arguments objectForKey:@"email"];
    if (thisEmail == nil) {
        ERROR(@"email should be set in StartServiceAction call");
        return NO;
    }

    NSString *otherEmail = [otherRequest objectForKey:@"email"];
    if (![thisEmail isEqualToString:otherEmail])
        return NO;

    NSString *thisAction = [self.arguments objectForKey:@"action"];
    NSString *otherAction = [otherRequest objectForKey:@"action"];

    if (thisAction == nil || thisAction == MCTNull) {
        return (otherAction == nil || otherAction == MCTNull);
    }

    return [thisAction isEqualToString:otherAction];
}

@end


@implementation MCTGetIdentityQRCodeSingleCall

- (BOOL)isEqualToFunctionWithArguments:(NSDictionary *)otherArgs
{
    NSDictionary *otherRequest = [otherArgs objectForKey:@"request"];
    if (otherRequest == nil)
        return NO;

    NSString *thisEmail = [self.arguments objectForKey:@"email"];
    if (thisEmail == nil) {
        ERROR(@"email should be set in GetIdentityQRCode call %@", self.arguments);
        return NO;
    }

    NSString *otherEmail = [otherRequest objectForKey:@"email"];
    if (otherEmail == nil) {
        ERROR(@"email should be set in GetIdentityQRCode call %@", otherArgs);
        return NO;
    }

    // Both calls should continue only if one call is for my identity AND the other call is for someone else

    if ([[MCTComponentFramework friendsPlugin] isMyEmail:thisEmail]
            || [[MCTComponentFramework friendsPlugin] isMyEmail:otherEmail])
        return [thisEmail isEqualToString:otherEmail];

    return YES;
}

@end


@implementation MCTGetConversationSingleCall

- (BOOL)isEqualToFunctionWithArguments:(NSDictionary *)otherArgs
{
    NSDictionary *otherRequest = [otherArgs objectForKey:@"request"];
    if (otherRequest == nil)
        return NO;

    NSString *thisThread = [self.arguments objectForKey:@"parent_message_key"];
    if (thisThread == nil) {
        ERROR(@"parent_message_key should be set in getConversation call");
        return NO;
    }

    NSString *otherThread = [otherRequest objectForKey:@"parent_message_key"];
    return [thisThread isEqualToString:otherThread];
}

@end


@implementation MCTGetConversationAvatarSingleCall

- (BOOL)isEqualToFunctionWithArguments:(NSDictionary *)otherArgs
{
    NSDictionary *otherRequest = [otherArgs objectForKey:@"request"];
    if (otherRequest == nil)
        return NO;

    NSString *thisThread = [self.arguments objectForKey:@"thread_key"];
    if (thisThread == nil) {
        ERROR(@"thread_key should be set in getConversationAvatar call");
        return NO;
    }

    NSString *otherThread = [otherRequest objectForKey:@"thread_key"];
    return [thisThread isEqualToString:otherThread];
}

@end


@implementation MCTGetCategorySingleCall

- (BOOL)isEqualToFunctionWithArguments:(NSDictionary *)otherArgs
{
    NSDictionary *otherRequest = [otherArgs objectForKey:@"request"];
    if (otherRequest == nil)
        return NO;

    NSString *thisCategoryId = [self.arguments objectForKey:@"category_id"];
    if (thisCategoryId == nil) {
        ERROR(@"category_id should be set in getCategory call");
        return NO;
    }

    NSString *otherCategoryId = [otherRequest objectForKey:@"category_id"];
    return [thisCategoryId isEqualToString:otherCategoryId];
}

@end


@implementation MCTGetFriendSingleCall

- (BOOL)isEqualToFunctionWithArguments:(NSDictionary *)otherArgs
{
    NSDictionary *otherRequest = [otherArgs objectForKey:@"request"];
    if (otherRequest == nil)
        return NO;

    NSString *thisFriendEmail = [self.arguments objectForKey:@"email"];
    if (thisFriendEmail == nil) {
        ERROR(@"email should be set in getFriend call");
        return NO;
    }

    NSString *otherFriendEmail = [otherRequest objectForKey:@"email"];
    return [thisFriendEmail isEqualToString:otherFriendEmail];
}

@end


@implementation MCTGetUserInfoSingleCall

- (BOOL)isEqualToFunctionWithArguments:(NSDictionary *)otherArgs
{
    NSDictionary *otherRequest = [otherArgs objectForKey:@"request"];
    if (otherRequest == nil)
        return NO;

    NSString *thisCode = [self.arguments objectForKey:@"code"];
    if (thisCode == nil) {
        ERROR(@"code should be set in getUserInfo call");
        return NO;
    }

    NSString *otherCode = [otherRequest objectForKey:@"code"];
    return [thisCode isEqualToString:otherCode];
}

@end


@implementation MCTLogLocationsSingleCall

- (BOOL)isEqualToFunctionWithArguments:(NSDictionary *)otherArgs
{
    NSDictionary *otherRequest = [otherArgs objectForKey:@"request"];
    if (otherRequest == nil)
        return NO;

    NSArray *recipients = [self.arguments objectForKey:@"recipients"];
    if (recipients == nil) {
        ERROR(@"recipients should be set in logLocations call: %@", self.arguments);
        return NO;
    }

    // Return YES if the target is not a TRACKING target (>1000)
    for (NSDictionary *r in recipients) {
        return [r longForKey:@"target"] < 1000;
    }
    return YES;
}

@end