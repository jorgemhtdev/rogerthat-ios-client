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

#import "MCTMessage.h"
#import "MCTMessageBreadCrumbs.h"
#import "MCTMessageEnums.h"
#import "MCTMessageFlowRun.h"
#import "MCTMessageThread.h"
#import "MCTStore.h"
#import "MCTTransferObjects.h"


@interface MCTMessageStore : MCTStore

- (NSString *)myEmail;

// returns YES if the sender is the phone owner
- (BOOL)saveMessage:(MCTMessage *)message withSentByMeFromOtherDevice:(BOOL)sentFromOtherDevice;
- (void)insertAttachments:(NSArray *)attachments forMessage:(NSString *)messageKey;

// returns NO if there was nothing updated (message not found)
- (BOOL)updateMessageMemberStatus:(MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *)member;
- (BOOL)updateMessageWithKey:(NSString *)messageKey
                   parentKey:(NSString *)parentMessageKey
                       flags:(NSNumber *)flags
                   existence:(NSNumber *)existence
                     message:(NSString *)message
            threadAvatarHash:(NSString *)threadAvatarHash
       threadBackgroundColor:(NSString *)threadBackgroundColor
             threadTextColor:(NSString *)threadTextColor;

- (void)messageFailed:(NSString *)key;

- (void)replaceTmpKey:(NSString *)tmpKey withKey:(NSString *)key andTimestamp:(MCTlong)timestamp;

- (NSString *)messageSenderWithMessageKey:(NSString *)key;
- (NSSet *)membersWithMessageKey:(NSString *)key;
- (NSArray *)attachmentsWithMessageKey:(NSString *)key;
- (int)messageFlagsWithKey:(NSString *)msgKey;
- (NSArray *)alertFlagsOfOpenMessagesSince:(MCTlong)timestamp;

- (BOOL)isMessageDirty:(NSString *)msgKey;
- (void)setMessageIsDirty:(BOOL)isDirty withKey:(NSString *)msgKey;
- (void)setThreadReadWithKey:(NSString *)threadKey andDirtyMessages:(NSArray *)dirtyMessageKeys;

- (BOOL)messageNeedsMyAnswer:(NSString *)key;
- (NSArray *)messagesInThreadThatNeedsMyAnswer:(NSString *)threadKey;
- (void)ackMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message
      withButtonId:(NSString *)btnId
    andCustomReply:(NSString *)customReply
       andIsInBulk:(BOOL)inBulk;
- (void)operationAckChat:(MCT_com_mobicage_to_messaging_MessageTO *)message;

// returns NO if there was nothing updated (message not found)
- (BOOL)lockMessageWithKey:(NSString *)key andMembers:(NSArray *)members andFlags:(MCTlong)flags;
- (BOOL)lockMessageWithKey:(NSString *)key andMembers:(NSArray *)members andDirtyBehavior:(MCTDirtyBehavior)dirtyBehavior andFlags:(MCTlong)flags;

- (void)deleteConversationWithKey:(NSString *)key;
- (void)restoreConversationWithKey:(NSString *)key;

- (void)submitFormWithMessage:(MCTMessage *)message andButtonId:(NSString *)buttonId;
- (void)updateFormWithMessage:(MCTMessage *)message
                     buttonId:(NSString *)buttonId
            receivedTimestamp:(MCTlong)receivedTimestamp
               ackedTimestamp:(MCTlong)ackedTimestamp;

- (int)countMessages;
- (int)countVisibleMessages;
- (int)countUnprocessedMessagesForSender:(NSString *)sender;
- (NSArray *)messageThreads;
- (NSArray* )messageThreadsByMember:(NSString *)email;
- (MCTMessageThread *)messageThreadByKey:(NSString *)msgKey;

- (NSData *)threadAvatarWithHash:(NSString *)threadAvatarHash;
- (void)insertThreadAvatar:(NSData *)avatar withHash:(NSString *)avatarHash;

- (NSArray *)repliesWithParentKey:(NSString *)parentKey;
- (MCTMessage *)messageInfoByParentKey:(NSString *)pkey andIndex:(int)index;
- (MCTMessage *)visibleMessageInfoByParentKey:(NSString *)pkey andIndex:(int)index;
- (MCTMessage *)messageInfoByKey:(NSString *)key;
- (MCTMessage *)messageDetailsByKey:(NSString *)key;
- (NSArray *)buttonsWithMessageKey:(NSString *)key;
- (NSArray *)memberStatusesWithMessageKey:(NSString *)key;
- (MCTMessageBreadCrumbs *)messageBreadCrumbsWithKey:(NSString *)msgKey;

- (NSMutableArray *)childMessageKeysInThread:(NSString *)parentKey;
- (NSArray *)messagesInThread:(NSString *)parentKey;
- (NSArray *)membersStatusesInThread:(NSString *)parentKey;

- (int)countDirtyThreads;

- (MCTMessageExistence)existenceOfMessageWithKey:(NSString *)key;

- (void)addRequestedConversationWithKey:(NSString *)key;
- (BOOL)isConversationAlreadyRequestedWithKey:(NSString *)key;
- (void)deleteRequestedConversationWithKey:(NSString *)key;

- (void)saveMessageFlowRun:(MCTMessageFlowRun *)messageFlowRun;
- (MCTMessageFlowRun *)messageFlowRunWithParentKey:(NSString *)parentMessageKey;
- (void)deleteMessageFlowRunWithParentKey:(NSString *)parentMessageKey;

- (void)updateMessageThread:(NSString *)threadKey withVisibility:(BOOL)visible;
- (void)recalculateShowInList;

@end