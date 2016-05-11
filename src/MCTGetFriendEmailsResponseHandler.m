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

#import "MCTActivityEnums.h"
#import "MCTActivityPlugin.h"
#import "MCTGetFriendEmailsResponseHandler.h"
#import "MCTGetFriendResponseHandler.h"
#import "MCTComponentFramework.h"
#import "MCTTransferObjects.h"
#import "MCTFriendsPlugin.h"
#import "MCTFriendStore.h"
#import "MCT_CS_API.h"


#define PICKLE_CLASS_VERSION 1

#define PICKLE_FORCE_KEY @"force"
#define PICKLE_RECALCULATE_MESSAGES_SHOW_IN_LIST_KEY @"recalculate_messages_show_in_list"

@implementation MCTGetFriendEmailsResponseHandler


- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for GetFriendEmails request: %@", error);
}

- (void)handleResult:(MCT_com_mobicage_to_friends_GetFriendEmailsResponseTO *)result
{
    T_BIZZ();
    LOG(@"Result received for GetFriendEmails request");

    [[MCTComponentFramework friendsPlugin] updateFriendSet:result.emails
                                               withVersion:result.friend_set_version
                                                     force:self.force
                             recalculateMessagesShowInList:self.recalculateMessagesShowInList];
}

- (MCTGetFriendEmailsResponseHandler *)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    if (self = [super initWithCoder:coder]) {
        self.force = [coder decodeBoolForKey:PICKLE_FORCE_KEY];
        self.recalculateMessagesShowInList = [coder decodeBoolForKey:PICKLE_RECALCULATE_MESSAGES_SHOW_IN_LIST_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
    [coder encodeBool:self.force forKey:PICKLE_FORCE_KEY];
    [coder encodeBool:self.recalculateMessagesShowInList forKey:PICKLE_RECALCULATE_MESSAGES_SHOW_IN_LIST_KEY];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end