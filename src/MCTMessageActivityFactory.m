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

#import "MCTActivity.h"
#import "MCTActivityEnums.h"
#import "MCTComponentFramework.h"
#import "MCTFriendStore.h"
#import "MCTMessage.h"
#import "MCTMessageActivityFactory.h"
#import "MCTMessageStore.h"
#import "MCTUtils.h"

#define MCT_ACTIVITY_MESSAGE_CUTOFF 100

#define MCT_ACTIVITY_ME_PASSIVE NSLocalizedString(@"myself", nil)
#define MCT_ACTIVITY_OTHERS NSLocalizedString(@"others", nil)


@implementation MCTMessageActivityFactory

- (void)newMessageWithKey:(NSString *)key
{
    T_DONTCARE();
    MCTMessage *msg = [[[MCTComponentFramework messagesPlugin] store] messageDetailsByKey:key];
    [self newMessage:msg];
}

- (void)newMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message
{
    T_DONTCARE();
    if (IS_FLAG_SET(message.flags, MCTMessageFlagDynamicChat)) {
        return;
    }

    MCTActivity *activity = [MCTActivity activity];
    activity.reference = message.key;
    activity.friendReference = message.sender;

    [activity.parameters setValue:[message.message stringByTruncatingTailWithLength:MCT_ACTIVITY_MESSAGE_CUTOFF]
                           forKey:MCT_ACTIVITY_MESSAGE_CONTENT];

    [activity.parameters setValue:[[MCTComponentFramework friendsPlugin] friendDisplayNameByEmail:message.sender]
                           forKey:MCT_ACTIVITY_MESSAGE_FROM];

    BOOL iAmTheSender = [[MCTComponentFramework friendsPlugin] isMyEmail:message.sender];

    if (message.parent_key == nil) {
        activity.type = iAmTheSender ? MCTActivityMessageSent:  MCTActivityMessageReceived;
    } else {
        activity.type = iAmTheSender ? MCTActivityMessageReplySent : MCTActivityMessageReplyReceived;

        MCTMessage *parentMsg = [[[MCTComponentFramework messagesPlugin] store] messageInfoByParentKey:message.parent_key andIndex:0];

        [activity.parameters setValue:[parentMsg.message stringByTruncatingTailWithLength:MCT_ACTIVITY_MESSAGE_CUTOFF]
                               forKey:MCT_ACTIVITY_MESSAGE_PARENT_CONTENT];
    }

    NSMutableArray *memberEmails = [NSMutableArray arrayWithCapacity:[message.members count]];
    for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in message.members)
        if (![message.sender isEqualToString:member.member])
            [memberEmails addObject:member.member];

    NSMutableArray *to = [NSMutableArray arrayWithCapacity:fmin(2, [memberEmails count])];
    if (iAmTheSender)
        [to addObject:[[MCTComponentFramework friendsPlugin] friendDisplayNameByEmail:[memberEmails objectAtIndex:0]]];
    else
        [to addObject:MCT_ACTIVITY_ME_PASSIVE];

    if ([memberEmails count] > 1)
        [to addObject:MCT_ACTIVITY_OTHERS];

    [activity.parameters setValue:[to componentsJoinedByString:@", "]
                           forKey:MCT_ACTIVITY_MESSAGE_TO];

    [[[MCTComponentFramework activityPlugin] store] saveActivity:activity];
}

- (void)lockedMessageWithKey:(NSString *)key
{
    T_DONTCARE();
    MCTMessage *message = [[[MCTComponentFramework messagesPlugin] store] messageDetailsByKey:key];

    MCTActivity *activity = [MCTActivity activity];
    activity.reference = message.key;
    activity.friendReference = message.sender;

    [activity.parameters setValue:[message.message stringByTruncatingTailWithLength:MCT_ACTIVITY_MESSAGE_CUTOFF]
                           forKey:MCT_ACTIVITY_MESSAGE_CONTENT];

    BOOL iAmTheSender = [[MCTComponentFramework friendsPlugin] isMyEmail:message.sender];

    if (iAmTheSender) {
        activity.type = MCTActivityMessageLockedByMe;
        [activity.parameters setValue:MCT_ACTIVITY_ME_PASSIVE forKey:MCT_ACTIVITY_MESSAGE_FROM];
    } else {
        activity.type = MCTActivityMessageLockedByOther;
        [activity.parameters setValue:[[MCTComponentFramework friendsPlugin] friendDisplayNameByEmail:message.sender]
                               forKey:MCT_ACTIVITY_MESSAGE_FROM];
    }

    // If sender has made a choice, put it in the activity log
    MCT_com_mobicage_to_messaging_MemberStatusTO *sender = [message memberWithEmail:message.sender];
    if (sender && sender.button_id) {
        [activity.parameters setValue:[[message buttonWithId:sender.button_id] caption]
                               forKey:MCT_ACTIVITY_MESSAGE_QRBUTTON];
    }

    [[[MCTComponentFramework activityPlugin] store] saveActivity:activity];
}

- (void)quickReplyUndoneDuringLockMessage:(MCTMessage *)message
                withNewMemberStatusUpdate:(MCT_com_mobicage_to_messaging_MemberStatusTO *)newMember
{
    T_DONTCARE();
    MCTActivity *activity = [MCTActivity activity];
    activity.type = MCTActivityQuickReplyUndone;
    activity.reference = message.key;
    activity.friendReference = newMember.member;

    [activity.parameters setValue:[[message buttonWithId:newMember.button_id] caption]
                           forKey:MCT_ACTIVITY_MESSAGE_QRBUTTON];

    [activity.parameters setValue:[[MCTComponentFramework friendsPlugin] friendDisplayNameByEmail:newMember.member]
                           forKey:MCT_ACTIVITY_MESSAGE_FROM];

    [[[MCTComponentFramework activityPlugin] store] saveActivity:activity];
}

- (void)statusUpdateWithMessage:(NSString *)msgKey andMember:(NSString *)memberEmail andButton:(NSString *)btnId
{
    T_DONTCARE();
    MCTActivity *activity = [MCTActivity activity];
    activity.reference = msgKey;
    activity.friendReference = memberEmail;

    MCTMessage *message = [[[MCTComponentFramework messagesPlugin] store] messageDetailsByKey:msgKey];
    BOOL iAmTheSender = [[MCTComponentFramework friendsPlugin] isMyEmail:message.sender];
    BOOL updatedByMe = [[MCTComponentFramework friendsPlugin] isMyEmail:memberEmail];

    if (btnId == nil) {
        activity.type = updatedByMe ? MCTActivityMessageDismissedByMe : MCTActivityMessageDismissedByOther;
    } else if (updatedByMe) {
        activity.type = iAmTheSender ? MCTActivityQuickReplySentForMe : MCTActivityQuickReplySentForOther;
    } else {
        activity.type = iAmTheSender ? MCTActivityQuickReplyReceivedForMe : MCTActivityQuickReplyReceivedForOther;
    }

    NSString *updater = updatedByMe ? MCT_ACTIVITY_ME_PASSIVE : [[MCTComponentFramework friendsPlugin] friendDisplayNameByEmail:memberEmail];
    [activity.parameters setValue:updater forKey:MCT_ACTIVITY_MESSAGE_FROM];

    NSString *to;
    if (iAmTheSender) {
        to = MCT_ACTIVITY_ME_PASSIVE;
    } else {
        to = [[MCTComponentFramework friendsPlugin] friendDisplayNameByEmail:message.sender];
    }

    BOOL otherMembers = NO;
    for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in message.members) {
        if (![message.sender isEqualToString:member.member]) {
            otherMembers = YES;
            break;
        }
    }

    if (otherMembers) {
        to = [NSString stringWithFormat:@"%@, %@", to, MCT_ACTIVITY_OTHERS];
    }

    [activity.parameters setValue:[message.message stringByTruncatingTailWithLength:MCT_ACTIVITY_MESSAGE_CUTOFF]
                           forKey:MCT_ACTIVITY_MESSAGE_CONTENT];
    if (btnId != nil) {
        [activity.parameters setValue:to forKey:MCT_ACTIVITY_MESSAGE_TO];
        [activity.parameters setValue:[[message buttonWithId:btnId] caption] forKey:MCT_ACTIVITY_MESSAGE_QRBUTTON];
    }

    [[[MCTComponentFramework activityPlugin] store] saveActivity:activity];
}

@end