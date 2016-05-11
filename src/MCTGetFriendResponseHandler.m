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


#import "MCTGetFriendResponseHandler.h"
#import "MCTComponentFramework.h"
#import "MCTTransferObjects.h"
#import "MCTFriendsPlugin.h"
#import "MCTFriendStore.h"

#import "NSData+Base64.h"


#define PICKLE_CLASS_VERSION 1

#define PICKLE_FORCE_KEY @"force"
#define PICKLE_IS_LAST_KEY @"is_last"
#define PICKLE_GENERATION_KEY @"generation"
#define PICKLE_RECALCULATE_MESSAGES_SHOW_IN_LIST_KEY @"recalculate_messages_show_in_list"


@implementation MCTGetFriendResponseHandler


- (void)handleError:(NSString *)error
{
    T_BIZZ();
    @try {
        LOG(@"Error response for GetFriend request: %@", error);
    }
    @finally {
        [self doFinalizeWithFriend:nil];
    }
}

- (void)handleResult:(MCT_com_mobicage_to_friends_GetFriendResponseTO *)result
{
    T_BIZZ();
    @try {
        LOG(@"Result received for GetFriend request");

        if (result.friend && (self.force || [[[MCTComponentFramework friendsPlugin] store] shouldUpdateFriend:result.friend].updated)) {
            NSData *avatar = [NSData dataFromBase64String:result.avatar];
            [[[MCTComponentFramework friendsPlugin] store] storeFriend:result.friend
                                                            withAvatar:avatar
                                                              andForce:self.force];

            [[MCTComponentFramework brandingMgr] queueFriend:[MCTFriend friendWithFriendTO:result.friend]];
        }
    }
    @finally {
        [self doFinalizeWithFriend:result.friend];
    }
}

- (void)doFinalizeWithFriend:(MCT_com_mobicage_to_friends_FriendTO *)friend
{
    T_DONTCARE();
    @try {
        if (self.isLast) {
            [[[MCTComponentFramework friendsPlugin] store] scrub];
        }
    }
    @finally {
        @try {
            if (self.isLast && self.recalculateMessagesShowInList) {
                [[[MCTComponentFramework messagesPlugin] store] recalculateShowInList];
            }
        }
        @finally {
            if (self.force) {
                if (self.isLast) {
                    [[MCTComponentFramework intentFramework] broadcastIntent:[MCTIntent intentWithAction:kINTENT_FRIENDS_RETRIEVED]];

                    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                        [[MCTComponentFramework activityPlugin] logActivityWithText:NSLocalizedString(@"Updated friends list from server", nil)
                                                                        andLogLevel:MCTActivityLogInfo];
                    }];
                }
            } else if (friend) {
                MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_FRIEND_ADDED];
                [intent setString:friend.email forKey:@"email"];
                [intent setLong:friend.type forKey:@"friend_type"];
                [intent setLong:friend.existence forKey:@"existence"];
                [[MCTComponentFramework intentFramework] broadcastIntent:intent];

                [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                    MCTActivity *activity = [MCTActivity activity];
                    activity.reference = activity.friendReference = friend.email;
                    activity.parameters = [NSDictionary dictionaryWithObject:friend.name
                                                                      forKey:MCT_ACTIVITY_FRIEND_NAME];
                    activity.type = MCTActivityFriendAdded;
                    [[[MCTComponentFramework activityPlugin] store] saveActivity:activity];
                }];
            }
        }
    }
}

- (MCTGetFriendResponseHandler *)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    if (self = [super initWithCoder:coder]) {
        self.force = [coder decodeBoolForKey:PICKLE_FORCE_KEY];
        self.isLast = [coder decodeBoolForKey:PICKLE_IS_LAST_KEY];
        self.recalculateMessagesShowInList = [coder decodeBoolForKey:PICKLE_RECALCULATE_MESSAGES_SHOW_IN_LIST_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
    [coder encodeBool:self.force forKey:PICKLE_FORCE_KEY];
    [coder encodeBool:self.isLast forKey:PICKLE_IS_LAST_KEY];
    [coder encodeBool:self.recalculateMessagesShowInList forKey:PICKLE_RECALCULATE_MESSAGES_SHOW_IN_LIST_KEY];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end