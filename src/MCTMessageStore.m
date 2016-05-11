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
#import "MCTIntent.h"
#import "MCTMemberStatusSummaryEncoding.h"
#import "MCTMessage.h"
#import "MCTMessageEnums.h"
#import "MCTMessageStore.h"
#import "MCTMessageThread.h"
#import "MCTTransferObjects.h"

@interface MCTMessageStore ()

- (void)initPreparedStatements;
- (void)destroyPreparedStatements;

- (int)sortIdForMessageWithParentKey:(NSString *)key;
- (int)highestSortId;
- (MCTlong)calculateRecipientStatusForMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message;
- (void)insertMessage:(MCTMessage *)message withSenderIsMe:(BOOL)senderIsMe;
- (void)insertButtons:(NSArray *)buttons forMessage:(NSString *)messageKey;
- (void)insertMemberStatuses:(NSArray *)members forMessage:(NSString *)messageKey;
- (void)insertAttachments:(NSArray *)attachments forMessage:(NSString *)messageKey;
- (void)updateMemberSummaryForMessage:(NSString *)key;
- (void)operationUpdateMessageMemberStatus:(MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *)request;
- (void)operationUpdateMessageMemberStatusWithMessage:(NSString *)messageKey
                                    receivedTimestamp:(MCTlong)receivedTimestamp
                                       ackedTimestamp:(MCTlong)ackedTimestamp
                                             buttonId:(NSString *)buttonId
                                          customReply:(NSString *)customReply
                                               status:(MCTlong)status
                                               member:(NSString *)member
                                                flags:(MCTlong)flags;
- (void)updateMessageFlagsWithKey:(NSString *)key andFlag:(MCTMessageFlag)flag;

- (void)operationSetMessageIsDirty:(BOOL)isDirty withKey:(NSString *)msgKey;
- (void)operationClearNeedsMyAnswerOfMessageWithKey:(NSString *)msgKey;

- (void)operationAckMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message
               withButtonId:(NSString *)btnId
             andCustomReply:(NSString *)customReply;
- (void)broadCastMessageAcked:(MCT_com_mobicage_to_messaging_MessageTO *)message
                 withButtonId:(NSString *)buttonId;
- (void)operationUpdateForm:(MCTMessage *)message;

- (MCTMessage *)messageInfoWithStatement:(sqlite3_stmt *)stmt parentKey:(NSString *)pkey index:(int)index;

- (BOOL)mustShowThreadInList:(NSString *)threadKey;

@end


@implementation MCTMessageStore

static sqlite3_stmt *stmtGetDirtyThreadsCount_;
static sqlite3_stmt *stmtGetMessageBreadCrumbs_;
static sqlite3_stmt *stmtGetMessageByKey_;
static sqlite3_stmt *stmtGetMessageByPKeyAndIndex_;
static sqlite3_stmt *stmtGetVisibleMessageByPKeyAndIndex_;
static sqlite3_stmt *stmtGetMessageCount_;
static sqlite3_stmt *stmtGetVisibleMessageCount_;
static sqlite3_stmt *stmtGetMessageButtons_;
static sqlite3_stmt *stmtGetMessageMemberStatuses_;
static sqlite3_stmt *stmtGetReplies_;
static sqlite3_stmt *stmtGetThreadByKey_;
static sqlite3_stmt *stmtGetThreadsByMember_;
static sqlite3_stmt *stmtGetThreads_;
static sqlite3_stmt *stmtIsMessageDirty_;
static sqlite3_stmt *stmtGetUnprocessedMessagesCountForSender_;

static sqlite3_stmt *stmtGetAlertFlags_;
static sqlite3_stmt *stmtGetHighestSortId_;
static sqlite3_stmt *stmtGetMessageFlags_;
static sqlite3_stmt *stmtGetMessageMembers_;
static sqlite3_stmt *stmtGetMessageAttachments_;
static sqlite3_stmt *stmtGetMessageNeedsAnswer_;
static sqlite3_stmt *stmtGetMessagesInThreadNeedsAnswer_;
static sqlite3_stmt *stmtGetMessageSender_;
static sqlite3_stmt *stmtGetParentSortid_;
static sqlite3_stmt *stmtInsertButton_;
static sqlite3_stmt *stmtInsertMemberStatus_;
static sqlite3_stmt *stmtInsertAttachment_;
static sqlite3_stmt *stmtInsertMessage_;
static sqlite3_stmt *stmtSetMemberSummary_;
static sqlite3_stmt *stmtSetMessageDirty_;
static sqlite3_stmt *stmtSetMessageProcessed_;
static sqlite3_stmt *stmtUpdateButtonMessageKey_;
static sqlite3_stmt *stmtUpdateAttachmentsMessageKey_;
static sqlite3_stmt *stmtUpdateFlags_;
static sqlite3_stmt *stmtUpdateForm_;
static sqlite3_stmt *stmtUpdateMemberStatus_;
static sqlite3_stmt *stmtUpdateMemberMessageKey_;
static sqlite3_stmt *stmtUpdateMessageKeyAndTimestamp_;
static sqlite3_stmt *stmtUpdateMessageLastThreadMessage_;
static sqlite3_stmt *stmtUpdateMyMemberStatus_;
static sqlite3_stmt *stmtUpdateSortIdForThread_;

static sqlite3_stmt *stmtGetChildMessageKeys_;
static sqlite3_stmt *stmtGetFullServiceThread_;
static sqlite3_stmt *stmtGetThreadMembers_;
static sqlite3_stmt *stmtMarkThreadAsRead_;
static sqlite3_stmt *stmtUpdateThreadExistence_;
static sqlite3_stmt *stmtGetMessageExistence_;

static sqlite3_stmt *stmtThreadAvatarGet_;
static sqlite3_stmt *stmtThreadAvatarInsert_;
static sqlite3_stmt *stmtThreadAvatarCount_;

static sqlite3_stmt *stmtMessageThreadShowInListUpdate_;
static sqlite3_stmt *stmtMessageThreadShowInListGet_;

static sqlite3_stmt *stmtCountRequestedConversation_;
static sqlite3_stmt *stmtDeleteRequestedConversation_;
static sqlite3_stmt *stmtInsertRequestedConversation_;

static sqlite3_stmt *stmtMessageFlowRunSave_;
static sqlite3_stmt *stmtMessageFlowRunGet_;
static sqlite3_stmt *stmtMessageFlowRunDelete_;

static sqlite3_stmt *stmtMessageRecalculateShowInList_;

- (MCTMessageStore *)init
{
    T_BIZZ();
    if (self = [super init]) {
        [self initPreparedStatements];
    }
    return self;
}

- (void)dealloc
{
    HERE();
    T_BIZZ();
    [self destroyPreparedStatements];
    
}

- (void)initPreparedStatements
{
    T_BIZZ();
    [self dbLockedOperationWithBlock:^{

        [self prepareStatement:&stmtGetDirtyThreadsCount_
                  withQueryKey:@"sql_message_get_thread_dirty_count"];

        [self prepareStatement:&stmtGetMessageBreadCrumbs_
                  withQueryKey:@"sql_message_get_bread_crumbs"];

        [self prepareStatement:&stmtGetMessageByKey_
                  withQueryKey:@"sql_message_get_message_by_key"];

        [self prepareStatement:&stmtGetMessageByPKeyAndIndex_
                  withQueryKey:@"sql_message_get_message_by_pkey_and_index"];

        [self prepareStatement:&stmtGetVisibleMessageByPKeyAndIndex_
                  withQueryKey:@"sql_message_get_visible_message_by_pkey_and_index"];

        [self prepareStatement:&stmtGetMessageCount_
                  withQueryKey:@"sql_message_get_count"];

        [self prepareStatement:&stmtGetVisibleMessageCount_
                  withQueryKey:@"sql_message_get_visible_count"];

        [self prepareStatement:&stmtGetMessageButtons_
                  withQueryKey:@"sql_message_get_message_buttons"];

        [self prepareStatement:&stmtGetMessageMemberStatuses_
                  withQueryKey:@"sql_message_get_message_members_statusses"];

        [self prepareStatement:&stmtGetReplies_
                  withQueryKey:@"sql_message_get_replies"];

        [self prepareStatement:&stmtGetThreadByKey_
                  withQueryKey:@"sql_message_get_thread_by_key"];

        [self prepareStatement:&stmtGetThreadsByMember_
                  withQueryKey:@"sql_message_get_threads_by_member"];

        [self prepareStatement:&stmtGetThreads_
                  withQueryKey:@"sql_message_get_threads"];

        [self prepareStatement:&stmtIsMessageDirty_
                  withQueryKey:@"sql_message_is_dirty"];

        [self prepareStatement:&stmtGetUnprocessedMessagesCountForSender_
                  withQueryKey:@"sql_message_get_unprocessed_message_count_for_sender"];

        [self prepareStatement:&stmtGetAlertFlags_
                  withQueryKey:@"sql_message_get_alert_flags_of_open_messages"];

        [self prepareStatement:&stmtGetHighestSortId_
                  withQueryKey:@"sql_message_get_highest_sortid"];

        [self prepareStatement:&stmtGetMessageFlags_
                  withQueryKey:@"sql_message_get_flags"];

        [self prepareStatement:&stmtGetMessageMembers_
                  withQueryKey:@"sql_message_get_message_members"];

        [self prepareStatement:&stmtGetMessageAttachments_
                  withQueryKey:@"sql_message_get_attachments"];

        [self prepareStatement:&stmtGetMessageSender_
                  withQueryKey:@"sql_message_get_message_sender"];

        [self prepareStatement:&stmtGetMessageNeedsAnswer_
                  withQueryKey:@"sql_message_get_needs_answer"];

        [self prepareStatement:&stmtGetMessagesInThreadNeedsAnswer_
                  withQueryKey:@"sql_message_cursor_need_my_answer_message_from_thread"];

        [self prepareStatement:&stmtGetParentSortid_
                  withQueryKey:@"sql_message_get_parent_sortid"];

        [self prepareStatement:&stmtInsertButton_
                  withQueryKey:@"sql_message_insert_button"];

        [self prepareStatement:&stmtInsertMemberStatus_
                  withQueryKey:@"sql_message_insert_member_status"];

        [self prepareStatement:&stmtInsertAttachment_
                  withQueryKey:@"sql_message_insert_attachment"];

        [self prepareStatement:&stmtInsertMessage_
                  withQueryKey:@"sql_message_insert"];

        [self prepareStatement:&stmtSetMemberSummary_
                  withQueryKey:@"sql_message_set_member_summary"];

        [self prepareStatement:&stmtSetMessageDirty_
                  withQueryKey:@"sql_message_set_message_dirty_ios"];

        [self prepareStatement:&stmtSetMessageProcessed_
                  withQueryKey:@"sql_message_set_message_processed"];

        [self prepareStatement:&stmtUpdateButtonMessageKey_
                  withQueryKey:@"sql_message_replace_tmp_key_button"];

        [self prepareStatement:&stmtUpdateAttachmentsMessageKey_
                  withQueryKey:@"sql_message_replace_tmp_key_attachment"];

        [self prepareStatement:&stmtUpdateFlags_
                  withQueryKey:@"sql_message_update_flags"];

        [self prepareStatement:&stmtUpdateForm_
                  withQueryKey:@"sql_message_update_form"];

        [self prepareStatement:&stmtUpdateMemberMessageKey_
                  withQueryKey:@"sql_message_replace_tmp_key_member"];

        [self prepareStatement:&stmtUpdateMemberStatus_
                  withQueryKey:@"sql_message_update_member_status"];

        [self prepareStatement:&stmtUpdateMessageKeyAndTimestamp_
                  withQueryKey:@"sql_message_replace_tmp_key_message"];

        [self prepareStatement:&stmtUpdateMessageLastThreadMessage_
                  withQueryKey:@"sql_message_replace_tmp_key_last_thread_message"];

        [self prepareStatement:&stmtUpdateMyMemberStatus_
                  withQueryKey:@"sql_message_update_my_member_status"];

        [self prepareStatement:&stmtUpdateSortIdForThread_
                  withQueryKey:@"sql_message_update_sortid_for_thread"];


        [self prepareStatement:&stmtGetChildMessageKeys_
                  withQueryKey:@"sql_message_select_children"];

        [self prepareStatement:&stmtGetFullServiceThread_
                  withQueryKey:@"sql_message_cursor_full_service_thread"];

        [self prepareStatement:&stmtGetThreadMembers_
                  withQueryKey:@"sql_message_get_least_member_statusses"];

        [self prepareStatement:&stmtMarkThreadAsRead_
                  withQueryKey:@"sql_message_set_thread_as_read"];

        [self prepareStatement:&stmtUpdateThreadExistence_
                  withQueryKey:@"sql_message_update_thread_existence"];

        [self prepareStatement:&stmtGetMessageExistence_
                  withQueryKey:@"sql_message_get_existence"];

        [self prepareStatement:&stmtThreadAvatarGet_
                  withQueryKey:@"sql_thread_avatar_get"];

        [self prepareStatement:&stmtThreadAvatarInsert_
                  withQueryKey:@"sql_thread_avatar_insert"];

        [self prepareStatement:&stmtThreadAvatarCount_
                  withQueryKey:@"sql_thread_avatar_count"];

        [self prepareStatement:&stmtMessageThreadShowInListGet_
                  withQueryKey:@"sql_message_get_thread_show_in_list"];

        [self prepareStatement:&stmtMessageThreadShowInListUpdate_
                  withQueryKey:@"sql_message_update_thread_show_in_list"];


        [self prepareStatement:&stmtCountRequestedConversation_
                  withQueryKey:@"sql_message_requested_conversation_count"];

        [self prepareStatement:&stmtDeleteRequestedConversation_
                  withQueryKey:@"sql_message_requested_conversation_delete"];

        [self prepareStatement:&stmtInsertRequestedConversation_
                  withQueryKey:@"sql_message_requested_conversation_insert"];


        [self prepareStatement:&stmtMessageFlowRunSave_
                  withQueryKey:@"sql_mf_run_save"];

        [self prepareStatement:&stmtMessageFlowRunGet_
                  withQueryKey:@"sql_mf_run_get"];

        [self prepareStatement:&stmtMessageFlowRunDelete_
                  withQueryKey:@"sql_mf_run_delete"];


        [self prepareStatement:&stmtMessageRecalculateShowInList_
                 withQueryKey:@"sql_message_recalculate_show_in_list"];

    }];
}

- (void)destroyPreparedStatements
{
    T_BIZZ();
    [self dbLockedOperationWithBlock:^{
        [self finalizeStatement:stmtGetDirtyThreadsCount_
                   withQueryKey:@"sql_message_get_thread_dirty_count"];

        [self finalizeStatement:stmtGetMessageBreadCrumbs_
                   withQueryKey:@"sql_message_get_bread_crumbs"];

        [self finalizeStatement:stmtGetMessageByKey_
                   withQueryKey:@"sql_message_get_message_by_key"];

        [self finalizeStatement:stmtGetMessageByPKeyAndIndex_
                   withQueryKey:@"sql_message_get_message_by_pkey_and_index"];

        [self finalizeStatement:stmtGetVisibleMessageByPKeyAndIndex_
                   withQueryKey:@"sql_message_get_visible_message_by_pkey_and_index"];

        [self finalizeStatement:stmtGetMessageCount_
                   withQueryKey:@"sql_message_get_count"];

        [self finalizeStatement:stmtGetVisibleMessageCount_
                   withQueryKey:@"sql_message_get_visible_count"];

        [self finalizeStatement:stmtGetMessageButtons_
                   withQueryKey:@"sql_message_get_message_buttons"];

        [self finalizeStatement:stmtGetMessageMemberStatuses_
                   withQueryKey:@"sql_message_get_message_members_statusses"];

        [self finalizeStatement:stmtGetReplies_
                   withQueryKey:@"sql_message_get_replies"];

        [self finalizeStatement:stmtGetThreadByKey_
                   withQueryKey:@"sql_message_get_thread_by_key"];

        [self finalizeStatement:stmtGetThreadsByMember_
                   withQueryKey:@"sql_message_get_threads_by_member"];

        [self finalizeStatement:stmtGetThreads_
                   withQueryKey:@"sql_message_get_threads"];

        [self finalizeStatement:stmtIsMessageDirty_
                   withQueryKey:@"sql_message_is_dirty"];

        [self finalizeStatement:stmtGetUnprocessedMessagesCountForSender_
                   withQueryKey:@"sql_message_get_unprocessed_message_count_for_sender"];

        [self finalizeStatement:stmtGetAlertFlags_
                   withQueryKey:@"sql_message_get_alert_flags_of_open_messages"];

        [self finalizeStatement:stmtGetHighestSortId_
                   withQueryKey:@"sql_message_get_highest_sortid"];

        [self finalizeStatement:stmtGetMessageFlags_
                   withQueryKey:@"sql_message_get_flags"];

        [self finalizeStatement:stmtGetMessageMembers_
                   withQueryKey:@"sql_message_get_message_members"];

        [self finalizeStatement:stmtGetMessageAttachments_
                   withQueryKey:@"sql_message_get_attachments"];

        [self finalizeStatement:stmtGetMessageSender_
                   withQueryKey:@"sql_message_get_message_sender"];

        [self finalizeStatement:stmtGetMessageNeedsAnswer_
                   withQueryKey:@"sql_message_get_needs_answer"];

        [self finalizeStatement:stmtGetMessagesInThreadNeedsAnswer_
                   withQueryKey:@"sql_message_cursor_need_my_answer_message_from_thread"];

        [self finalizeStatement:stmtGetParentSortid_
                   withQueryKey:@"sql_message_get_parent_sortid"];

        [self finalizeStatement:stmtInsertButton_
                   withQueryKey:@"sql_message_insert_button"];

        [self finalizeStatement:stmtInsertMemberStatus_
                   withQueryKey:@"sql_message_insert_member_status"];

        [self finalizeStatement:stmtInsertAttachment_
                   withQueryKey:@"sql_message_insert_attachment"];

        [self finalizeStatement:stmtInsertMessage_
                   withQueryKey:@"sql_message_insert"];

        [self finalizeStatement:stmtSetMemberSummary_
                   withQueryKey:@"sql_message_set_member_summary"];

        [self finalizeStatement:stmtSetMessageDirty_
                   withQueryKey:@"sql_message_set_message_dirty_ios"];

        [self finalizeStatement:stmtSetMessageProcessed_
                   withQueryKey:@"sql_message_set_message_processed"];

        [self finalizeStatement:stmtUpdateButtonMessageKey_
                   withQueryKey:@"sql_message_replace_tmp_key_button"];

        [self finalizeStatement:stmtUpdateAttachmentsMessageKey_
                   withQueryKey:@"sql_message_replace_tmp_key_attachment"];

        [self finalizeStatement:stmtUpdateFlags_
                   withQueryKey:@"sql_message_update_flags"];

        [self finalizeStatement:stmtUpdateForm_
                   withQueryKey:@"sql_message_update_form"];

        [self finalizeStatement:stmtUpdateMemberMessageKey_
                   withQueryKey:@"sql_message_replace_tmp_key_member"];

        [self finalizeStatement:stmtUpdateMemberStatus_
                   withQueryKey:@"sql_message_update_member_status"];

        [self finalizeStatement:stmtUpdateMessageKeyAndTimestamp_
                   withQueryKey:@"sql_message_replace_tmp_key_message"];

        [self finalizeStatement:stmtUpdateMessageLastThreadMessage_
                   withQueryKey:@"sql_message_replace_tmp_key_last_thread_message"];

        [self finalizeStatement:stmtUpdateMyMemberStatus_
                   withQueryKey:@"sql_message_update_my_member_status"];

        [self finalizeStatement:stmtUpdateSortIdForThread_
                   withQueryKey:@"sql_message_update_sortid_for_thread"];


        [self finalizeStatement:stmtGetChildMessageKeys_
                   withQueryKey:@"sql_message_select_children"];

        [self finalizeStatement:stmtGetFullServiceThread_
                   withQueryKey:@"sql_message_cursor_full_service_thread"];

        [self finalizeStatement:stmtGetThreadMembers_
                   withQueryKey:@"sql_message_get_least_member_statusses"];

        [self finalizeStatement:stmtMarkThreadAsRead_
                   withQueryKey:@"sql_message_set_thread_as_read"];

        [self finalizeStatement:stmtUpdateThreadExistence_
                   withQueryKey:@"sql_message_update_thread_existence"];

        [self finalizeStatement:stmtGetMessageExistence_
                   withQueryKey:@"sql_message_get_existence"];


        [self finalizeStatement:stmtThreadAvatarGet_
                   withQueryKey:@"sql_thread_avatar_get"];

        [self finalizeStatement:stmtThreadAvatarInsert_
                   withQueryKey:@"sql_thread_avatar_insert"];

        [self finalizeStatement:stmtThreadAvatarCount_
                   withQueryKey:@"sql_thread_avatar_count"];


        [self finalizeStatement:stmtMessageThreadShowInListGet_
                   withQueryKey:@"sql_message_get_thread_show_in_list"];

        [self finalizeStatement:stmtMessageThreadShowInListUpdate_
                   withQueryKey:@"sql_message_update_thread_show_in_list"];


        [self finalizeStatement:stmtCountRequestedConversation_
                   withQueryKey:@"sql_message_requested_conversation_count"];

        [self finalizeStatement:stmtDeleteRequestedConversation_
                   withQueryKey:@"sql_message_requested_conversation_delete"];

        [self finalizeStatement:stmtInsertRequestedConversation_
                   withQueryKey:@"sql_message_requested_conversation_insert"];
        
        
        [self finalizeStatement:stmtMessageFlowRunSave_
                   withQueryKey:@"sql_mf_run_save"];
        
        [self finalizeStatement:stmtMessageFlowRunGet_
                   withQueryKey:@"sql_mf_run_get"];
        
        [self finalizeStatement:stmtMessageFlowRunDelete_
                   withQueryKey:@"sql_mf_run_delete"];


        [self finalizeStatement:stmtMessageRecalculateShowInList_
                  withQueryKey:@"sql_message_recalculate_show_in_list"];

    }];
}

- (NSString *)myEmail
{
    T_DONTCARE();
    return [[MCTComponentFramework systemPlugin] myIdentity].email;
}

- (int)sortIdForMessageWithParentKey:(NSString *)key
{
    T_DONTCARE();
    __block int sortId;
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtGetParentSortid_, 1, [key UTF8String], -1, NULL);
            if ((e = sqlite3_step(stmtGetParentSortid_)) != SQLITE_ROW) {
                LOG(@"Failed to get sortId for parent message with key %@", key);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            sortId = sqlite3_column_int(stmtGetParentSortid_, 0);
        }
        @finally {
            sqlite3_reset(stmtGetParentSortid_);
        }
    }];
    return sortId;
}

- (int)highestSortId
{
    T_DONTCARE();
    __block int sortId;
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            if ((e = sqlite3_step(stmtGetHighestSortId_)) != SQLITE_ROW) {
                LOG(@"Failed to get highest message sortId");
                MCT_THROW_SQL_EXCEPTION(e);
            }

            sortId = sqlite3_column_int(stmtGetHighestSortId_, 0);
        }
        @finally {
            sqlite3_reset(stmtGetHighestSortId_);
        }
    }];
    return sortId;
}

- (MCTlong)calculateRecipientStatusForMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message
{
    T_DONTCARE();
    int numNonSenderMembers = 0;
    int numNonSenderMembersReceived = 0;
    int numNonSenderMembersQuickReplied = 0;
    int numNonSenderMembersDismissed = 0;

    for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in message.members) {
        if (![member.member isEqualToString:message.sender]) {
            numNonSenderMembers++;

            if (IS_FLAG_SET(member.status, MCTMessageStatusReceived)) {
                numNonSenderMembersReceived++;

                if (IS_FLAG_SET(member.status, MCTMessageStatusAcked)) {
                    if (member.button_id == nil) {
                        numNonSenderMembersDismissed++;
                    } else {
                        numNonSenderMembersQuickReplied++;
                    }
                }
            }
        }
    }
    return [MCTMemberStatusSummaryEncoding encodeMessageMemberSummaryWithRecipients:numNonSenderMembers
                                                                        andReceived:numNonSenderMembersReceived
                                                                    andQuickReplied:numNonSenderMembersQuickReplied
                                                                       andDismissed:numNonSenderMembersDismissed];
}

- (void)insertMessage:(MCTMessage *)message withSenderIsMe:(BOOL)senderIsMe
{
    T_DONTCARE();
    // This runs inside a txn, so let's not start a new txn (nested txn doesn't work)
    [self dbLockedOperationWithBlock:^{

        @try {
            int e;
            long sortId;
            NSInteger tzDiff = [[NSTimeZone localTimeZone] secondsFromGMT];

            BOOL messageLocked = IS_FLAG_SET(message.flags, MCTMessageFlagLocked);
            MCTlong myStatus = [message memberWithEmail:[self myEmail]].status;

            BOOL needsMyAnswer = !senderIsMe && !messageLocked && !IS_FLAG_SET(myStatus, MCTMessageStatusAcked);
            BOOL dirty = !senderIsMe && !IS_FLAG_SET(myStatus, MCTMessageStatusRead) && !IS_FLAG_SET(myStatus, MCTMessageStatusAcked);

            BOOL threadForceVisible = message.parent_key == nil ? [MCTUtils isEmptyOrWhitespaceString:message.context]
                : [self mustShowThreadInList:message.parent_key];

            sqlite3_bind_text(stmtInsertMessage_, 1, [message.key UTF8String], -1, NULL);
            if (message.parent_key == nil) {
                sqlite3_bind_null(stmtInsertMessage_, 2);
                sortId = -1;
            } else {
                sqlite3_bind_text(stmtInsertMessage_, 2, [message.parent_key UTF8String], -1, NULL);
                sortId = [self sortIdForMessageWithParentKey:message.parent_key];
            }
            sqlite3_bind_text(stmtInsertMessage_, 3, [message.sender UTF8String], -1, NULL);
            sqlite3_bind_text(stmtInsertMessage_, 4, [message.message UTF8String], -1, NULL);
            sqlite3_bind_int64(stmtInsertMessage_, 5, message.timeout);
            sqlite3_bind_int64(stmtInsertMessage_, 6, message.timestamp);
            sqlite3_bind_int64(stmtInsertMessage_, 7, message.flags);
            sqlite3_bind_int(stmtInsertMessage_, 8, needsMyAnswer ? 1 : 0);
            sqlite3_bind_int64(stmtInsertMessage_, 10, sortId);
            sqlite3_bind_int(stmtInsertMessage_, 11, dirty ? 1 : 0);

            if (message.branding == nil)
                sqlite3_bind_null(stmtInsertMessage_, 9);
            else
                sqlite3_bind_text(stmtInsertMessage_, 9, [message.branding UTF8String], -1, NULL);

            NSMutableArray *members = [NSMutableArray array];
            for (MCT_com_mobicage_to_messaging_MemberStatusTO *memberStatus in message.members) {
                BOOL isMe = [[self myEmail] isEqualToString:memberStatus.member];
                if (![message.sender isEqualToString:memberStatus.member]) {
                    if (isMe) {
                        [members addObject:NSLocalizedString(@"__me_as_recipient", nil)];
                    } else {
                        [members addObject:[[MCTComponentFramework friendsPlugin] friendDisplayNameByEmail:memberStatus.member]];
                    }
                }
                if (isMe)
                    memberStatus.status |= MCTMessageStatusReceived;
            }
            sqlite3_bind_text(stmtInsertMessage_, 12, [[members componentsJoinedByString:@", "] UTF8String], -1, NULL);

            sqlite3_bind_int64(stmtInsertMessage_, 13, [self calculateRecipientStatusForMessage:message]);
            sqlite3_bind_int64(stmtInsertMessage_, 14, message.alert_flags);
            sqlite3_bind_int64(stmtInsertMessage_, 15, (message.timestamp + tzDiff) / 86400); // day
            if (message.form) {
                sqlite3_bind_text(stmtInsertMessage_, 16, [[message formJSONRepresentation] UTF8String], -1, NULL);
            } else {
                sqlite3_bind_null(stmtInsertMessage_, 16);
            }

            sqlite3_bind_int64(stmtInsertMessage_, 17, message.dismiss_button_ui_flags);
            sqlite3_bind_text(stmtInsertMessage_, 18, [message.key UTF8String], -1, NULL);
            sqlite3_bind_int(stmtInsertMessage_, 19, threadForceVisible ? 1 : 0);

            if (message.broadcast_type == nil)
                sqlite3_bind_null(stmtInsertMessage_, 20);
            else
                sqlite3_bind_text(stmtInsertMessage_, 20, [message.broadcast_type UTF8String], -1, NULL);

            if (message.thread_avatar_hash == nil) {
                sqlite3_bind_null(stmtInsertMessage_, 21);
            } else {
                sqlite3_bind_text(stmtInsertMessage_, 21, [message.thread_avatar_hash UTF8String], -1, NULL);

                if (![self threadAvatarExistsWithHash:message.thread_avatar_hash]) {
                    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                        [[MCTComponentFramework messagesPlugin] requestAvatarWithHash:message.thread_avatar_hash
                                                                            threadKey:message.threadKey];
                    }];
                }
            }

            if (message.thread_background_color == nil)
                sqlite3_bind_null(stmtInsertMessage_, 22);
            else
                sqlite3_bind_text(stmtInsertMessage_, 22, [message.thread_background_color UTF8String], -1, NULL);

            if (message.thread_text_color == nil)
                sqlite3_bind_null(stmtInsertMessage_, 23);
            else
                sqlite3_bind_text(stmtInsertMessage_, 23, [message.thread_text_color UTF8String], -1, NULL);

            sqlite3_bind_int64(stmtInsertMessage_, 24, message.priority);
            sqlite3_bind_int64(stmtInsertMessage_, 25, message.default_priority);
            sqlite3_bind_int64(stmtInsertMessage_, 26, message.default_sticky ? 1 : 0);

            if ((e = sqlite3_step(stmtInsertMessage_)) != SQLITE_DONE) {
                LOG(@"Failed to insert message %@", message);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            long nextSortId = [self highestSortId] + 1;
            @try {
                sqlite3_bind_int64(stmtUpdateSortIdForThread_, 1, nextSortId);
                sqlite3_bind_int64(stmtUpdateSortIdForThread_, 2, sortId);
                sqlite3_bind_int64(stmtUpdateSortIdForThread_, 3, sortId);

                if ((e = sqlite3_step(stmtUpdateSortIdForThread_)) != SQLITE_DONE) {
                    LOG(@"Failed to update sort id for thread with sortId %d", sortId);
                    MCT_THROW_SQL_EXCEPTION(e);
                }
            }
            @finally {
                sqlite3_reset(stmtUpdateSortIdForThread_);
            }
        }
        @finally {
            sqlite3_reset(stmtInsertMessage_);
        }
    }];
}

- (void)insertButtons:(NSArray *)buttons forMessage:(NSString *)messageKey
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        int e;

        int i = 0;
        for (MCT_com_mobicage_to_messaging_ButtonTO *button in buttons) {

            @try {
                sqlite3_bind_text(stmtInsertButton_, 1, [messageKey UTF8String], -1, NULL);
                sqlite3_bind_text(stmtInsertButton_, 2, [button.idX UTF8String], -1, NULL);
                sqlite3_bind_text(stmtInsertButton_, 3, [button.caption UTF8String], -1, NULL);
                if (button.action == nil)
                    sqlite3_bind_null(stmtInsertButton_, 4);
                else
                    sqlite3_bind_text(stmtInsertButton_, 4, [button.action UTF8String], -1, NULL);
                sqlite3_bind_int(stmtInsertButton_, 5, i++);
                sqlite3_bind_int64(stmtInsertButton_, 6, button.ui_flags);

                if ((e = sqlite3_step(stmtInsertButton_)) != SQLITE_DONE) {
                    LOG(@"Failed to insert button %@", button);
                    MCT_THROW_SQL_EXCEPTION(e);
                }
            }
            @finally {
                sqlite3_reset(stmtInsertButton_);
            }
        }
    }];
}

- (void)insertMemberStatuses:(NSArray *)members forMessage:(NSString *)messageKey
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        int e;

        for (MCT_com_mobicage_to_messaging_MemberStatusTO *memberStatus in members) {

            @try {
                sqlite3_bind_text(stmtInsertMemberStatus_, 1, [messageKey UTF8String], -1, NULL);
                sqlite3_bind_text(stmtInsertMemberStatus_, 2, [memberStatus.member UTF8String], -1, NULL);

                if ([memberStatus.member isEqualToString:[self myEmail]]) {
                    sqlite3_bind_int64(stmtInsertMemberStatus_, 3, [MCTUtils currentServerTime]);
                    sqlite3_bind_int64(stmtInsertMemberStatus_, 6, memberStatus.status | MCTMessageStatusReceived);
                } else {
                    sqlite3_bind_int64(stmtInsertMemberStatus_, 3, memberStatus.received_timestamp);
                    sqlite3_bind_int64(stmtInsertMemberStatus_, 6, memberStatus.status);
                }
                sqlite3_bind_int64(stmtInsertMemberStatus_, 4, memberStatus.acked_timestamp);
                if (memberStatus.button_id == nil)
                    sqlite3_bind_null(stmtInsertMemberStatus_, 5);
                else
                    sqlite3_bind_text(stmtInsertMemberStatus_, 5, [memberStatus.button_id UTF8String], -1, NULL);

                if ((e = sqlite3_step(stmtInsertMemberStatus_)) != SQLITE_DONE) {
                    LOG(@"Failed to insert memberStatus %@", memberStatus);
                    MCT_THROW_SQL_EXCEPTION(e);
                }
            }
            @finally {
                sqlite3_reset(stmtInsertMemberStatus_);
            }
        }
    }];
}

- (void)insertAttachments:(NSArray *)attachments forMessage:(NSString *)messageKey
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        int e;

        for (MCT_com_mobicage_to_messaging_AttachmentTO *attachment in attachments) {
            @try {
                sqlite3_bind_text(stmtInsertAttachment_, 1, [messageKey UTF8String], -1, NULL);
                sqlite3_bind_text(stmtInsertAttachment_, 2, [attachment.content_type UTF8String], -1, NULL);
                sqlite3_bind_text(stmtInsertAttachment_, 3, [attachment.download_url UTF8String], -1, NULL);
                sqlite3_bind_int64(stmtInsertAttachment_, 4, attachment.size);
                sqlite3_bind_text(stmtInsertAttachment_, 5, [attachment.name UTF8String], -1, NULL);

                if ((e = sqlite3_step(stmtInsertAttachment_)) != SQLITE_DONE) {
                    LOG(@"Failed to insert attachment %@", [attachment dictRepresentation]);
                    MCT_THROW_SQL_EXCEPTION(e);
                }
            }
            @finally {
                sqlite3_reset(stmtInsertAttachment_);
            }
        }
    }];
}

- (BOOL)saveMessage:(MCTMessage *)message withSentByMeFromOtherDevice:(BOOL)sentFromOtherDevice
{
    T_DONTCARE();
    __block BOOL senderIsMe;

    [self dbLockedTransactionWithBlock:^{
        NSString *myEmail = [self myEmail];
        senderIsMe = [message.sender isEqualToString:myEmail];

        [self insertMessage:message withSenderIsMe:senderIsMe];
        [self insertButtons:message.buttons forMessage:message.key];
        [self insertMemberStatuses:message.members forMessage:message.key];
        [self insertAttachments:message.attachments forMessage:message.key];
    }];

    MCTIntent *intent;
    MCTIntent *highPrioIntent = nil;

    if (senderIsMe) {
        intent = [MCTIntent intentWithAction:kINTENT_MESSAGE_SENT];
        intent.forceStash = sentFromOtherDevice;
    } else {
        intent = [MCTIntent intentWithAction:kINTENT_MESSAGE_RECEIVED];
        highPrioIntent = [MCTIntent intentWithAction:kINTENT_MESSAGE_RECEIVED_HIGH_PRIO];
        if (message.alert_flags == MCTAlertFlagSilent)
            [intent setBool:YES forKey:@"is_silent"];
        if (IS_FLAG_SET(message.flags, MCTMessageFlagLocked)) {
            [intent setBool:YES forKey:@"dirty_changed"];
            [highPrioIntent setBool:YES forKey:@"dirty_changed"];
        }
        if (message.parent_key) {
            [intent setString:message.parent_key forKey:@"parent_message_key"];
            [highPrioIntent setString:message.parent_key forKey:@"parent_message_key"];
        }
    }

    if (highPrioIntent) {
        [highPrioIntent setString:message.key forKey:@"message_key"];
        [highPrioIntent setString:message.parent_key forKey:@"parent_key"];
        [highPrioIntent setString:message.context forKey:@"context"];
        [[MCTComponentFramework intentFramework] broadcastIntent:highPrioIntent];
    }

    [intent setString:message.key forKey:@"message_key"];
    [intent setString:message.parent_key forKey:@"parent_key"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];

    return senderIsMe;
}

- (void)messageFailed:(NSString *)key
{
    T_DONTCARE();
    [self dbLockedTransactionWithBlock:^{
        @try {
            int e;

            sqlite3_bind_int(stmtSetMemberSummary_, 1, kMemberStatusSummaryError);
            sqlite3_bind_text(stmtSetMemberSummary_, 2, [key UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtSetMemberSummary_)) != SQLITE_DONE) {
                LOG(@"Failed to update member summary of message %@ to %d", key, kMemberStatusSummaryError);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtSetMemberSummary_);
        }
    }];

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_MESSAGE_MODIFIED];
    [intent setString:key forKey:@"message_key"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (void)updateMemberSummaryForMessage:(NSString *)key
{
    MCTMessage *msg = [self messageDetailsByKey:key];
    MCTlong summary = [self calculateRecipientStatusForMessage:msg];
    [self dbLockedOperationWithBlock:^{
       @try {
           int e;

           sqlite3_bind_int64(stmtSetMemberSummary_, 1, summary);
           sqlite3_bind_text(stmtSetMemberSummary_, 2, [key UTF8String], -1, NULL);

           if ((e = sqlite3_step(stmtSetMemberSummary_)) != SQLITE_DONE) {
               LOG(@"Failed to update member summary of message %@ to %d", key, summary);
               MCT_THROW_SQL_EXCEPTION(e);
           }
       }
       @finally {
           sqlite3_reset(stmtSetMemberSummary_);
       }
    }];
}

- (void)operationUpdateMessageMemberStatus:(MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *)request
{
    T_DONTCARE();
    [self operationUpdateMessageMemberStatusWithMessage:request.message
                                      receivedTimestamp:request.received_timestamp
                                         ackedTimestamp:request.acked_timestamp
                                               buttonId:request.button_id
                                            customReply:request.custom_reply
                                                 status:request.status
                                                 member:request.member
                                                  flags:request.flags];
}

- (void)operationUpdateMessageMemberStatusWithMessage:(NSString *)messageKey
                                    receivedTimestamp:(MCTlong)receivedTimestamp
                                       ackedTimestamp:(MCTlong)ackedTimestamp
                                             buttonId:(NSString *)buttonId
                                          customReply:(NSString *)customReply
                                               status:(MCTlong)status
                                               member:(NSString *)member
                                                flags:(MCTlong)flags
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_int64(stmtUpdateMemberStatus_, 1, receivedTimestamp);
            sqlite3_bind_int64(stmtUpdateMemberStatus_, 2, receivedTimestamp);
            sqlite3_bind_int64(stmtUpdateMemberStatus_, 3, receivedTimestamp);
            sqlite3_bind_int64(stmtUpdateMemberStatus_, 4, receivedTimestamp);
            sqlite3_bind_int64(stmtUpdateMemberStatus_, 5, ackedTimestamp);
            if (buttonId == nil)
                sqlite3_bind_null(stmtUpdateMemberStatus_, 6);
            else
                sqlite3_bind_text(stmtUpdateMemberStatus_, 6, [buttonId UTF8String], -1, NULL);

            if (customReply == nil)
                sqlite3_bind_null(stmtUpdateMemberStatus_, 7);
            else
                sqlite3_bind_text(stmtUpdateMemberStatus_, 7, [customReply UTF8String], -1, NULL);

            sqlite3_bind_int64(stmtUpdateMemberStatus_, 8, status);
            sqlite3_bind_text(stmtUpdateMemberStatus_, 9, [messageKey UTF8String], -1, NULL);
            sqlite3_bind_text(stmtUpdateMemberStatus_, 10, [member UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateMemberStatus_)) != SQLITE_DONE) {
                LOG(@"Failed to update member_status for message %@ and member %@", messageKey, member);
                MCT_THROW_SQL_EXCEPTION(e);
            }
            if (flags != -1 && IS_FLAG_SET(flags, MCTMessageFlagDynamicChat) && IS_FLAG_SET(flags, MCTMessageFlagAllowChatButtons)) {
                if (sqlite3_changes(self.dbMgr.writeableDB) == 0) {
                    MCT_com_mobicage_to_messaging_MemberStatusTO *ms = [[MCT_com_mobicage_to_messaging_MemberStatusTO alloc] init];
                    ms.acked_timestamp = ackedTimestamp;
                    ms.button_id = buttonId;
                    ms.custom_reply = customReply;
                    ms.member = member;
                    ms.received_timestamp = receivedTimestamp;
                    ms.status = status;
                    [self insertMemberStatuses:@[ms] forMessage:messageKey];
                }
            }

        }
        @finally {
            sqlite3_reset(stmtUpdateMemberStatus_);
        }
    }];
}

- (BOOL)updateMessageMemberStatus:(MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *)request
{
    T_DONTCARE();
    __block int rowsChanged;
    __block BOOL dirtyChanged = NO;
    __block BOOL needsMyAnswerChanged = NO;
    __block BOOL memberIsMe = NO;

    [self dbLockedTransactionWithBlock:^{
        [self operationUpdateMessageMemberStatus:request];

        if ((rowsChanged = sqlite3_changes([MCTComponentFramework writeableDB])) > 0) {
            memberIsMe = [request.member isEqualToString:self.myEmail];

            if (memberIsMe) {
                if (IS_FLAG_SET(request.status, MCTMessageStatusRead)) {
                    // I read the message on another client
                    [self operationSetMessageIsDirty:NO withKey:request.message];
                    dirtyChanged = YES;
                }
                if (IS_FLAG_SET(request.status, MCTMessageStatusAcked)) {
                    // I dismissed or quick replied on the message on another client
                    [self operationClearNeedsMyAnswerOfMessageWithKey:request.message];
                    needsMyAnswerChanged = YES;
                }
            } else {
                NSString *messageSender = [self messageSenderWithMessageKey:request.message];
                BOOL iAmSender = [self.myEmail isEqualToString:messageSender];
                BOOL memberIsSender = [request.member isEqualToString:messageSender];

                if (request.button_id != nil && (iAmSender || memberIsSender)) {
                    // Someone quick replied on my message, or sender quick replied to his own message
                    [self operationSetMessageIsDirty:YES withKey:request.message];
                    dirtyChanged = YES;
                }
            }
        }

        [self updateMemberSummaryForMessage:request.message];
    }];

    if (rowsChanged > 0) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_MESSAGE_MODIFIED];
        intent.forceStash = YES;
        [intent setString:request.message forKey:@"message_key"];
        [intent setBool:YES forKey:@"message_processed"];
        if (needsMyAnswerChanged)
            [intent setBool:YES forKey:@"needsMyAnswer_changed"];
        if (dirtyChanged)
            [intent setBool:YES forKey:@"dirty_changed"];
        if (memberIsMe)
            [intent setString:request.button_id forKey:@"my_button_id"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];

        return YES;
    }

    return NO;
}

- (BOOL)updateMessageWithKey:(NSString *)messageKey
                   parentKey:(NSString *)parentMessageKey
                       flags:(NSNumber *)flags
                   existence:(NSNumber *)existence
                     message:(NSString *)message
            threadAvatarHash:(NSString *)threadAvatarHash
       threadBackgroundColor:(NSString *)threadBackgroundColor
             threadTextColor:(NSString *)threadTextColor
{
    T_DONTCARE();
    BOOL updateWholeThread = (messageKey == nil);

    if (updateWholeThread && message != nil ) {
        @throw([NSException exceptionWithName:@"UpdateNotAllowedException"
                                       reason:@"Updating the message of every thread message is not allowed!"
                                     userInfo:nil]);
    }

    __block int rowsChanged;
    __block BOOL existenceChanged = NO;

    [self dbLockedTransactionWithBlock:^{

        NSString *qryFormat = @"UPDATE message SET %@ WHERE %@";

        NSMutableString *whereClause = [NSMutableString stringWithString:@"key = ?"];
        if (updateWholeThread) {
            [whereClause appendString:@" OR parent_key = ?"];
        }

        NSMutableArray *a = [NSMutableArray array];
        if (flags != nil) {
            [a addObject:@"flags = ?"];
        }
        if (existence != nil) {
            existenceChanged = YES;
            [a addObject:@"existence = ?"];
        }
        if (message != nil) {
            [a addObject:@"message = ?"];
        }
        if (threadAvatarHash != nil) {
            [a addObject:@"thread_avatar_hash = ?"];
        }
        if (threadBackgroundColor != nil) {
            [a addObject:@"thread_background_color = ?"];
        }
        if (threadTextColor != nil) {
            [a addObject:@"thread_text_color = ?"];
        }

        NSString *qry = [NSString stringWithFormat:qryFormat, [a componentsJoinedByString:@", "], whereClause];

        sqlite3_stmt *stmt;
        int e = sqlite3_prepare(self.dbMgr.writeableDB, [qry UTF8String], -1, &stmt, NULL);
        if (e != SQLITE_OK) {
            LOG(@"Failed to prepare query:\n %@", qry);
            MCT_THROW_SQL_EXCEPTION(e);
        }

        @try {
            int i = 1;
            if (flags != nil) {
                sqlite3_bind_int64(stmt, i++, [flags longLongValue]);
            }
            if (existence != nil) {
                sqlite3_bind_int64(stmt, i++, [existence longLongValue]);
            }
            if (message != nil) {
                sqlite3_bind_text(stmt, i++, [message UTF8String], -1, NULL);
            }
            if (threadAvatarHash != nil) {
                if ([threadAvatarHash length] == 0) {
                    sqlite3_bind_null(stmt, i++);
                } else {
                    sqlite3_bind_text(stmt, i++, [threadAvatarHash UTF8String], -1, NULL);

                    if (![self threadAvatarExistsWithHash:threadAvatarHash]) {
                        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                            [[MCTComponentFramework messagesPlugin] requestAvatarWithHash:threadAvatarHash
                                                                                threadKey:parentMessageKey];
                        }];
                    }
                }
            }
            if (threadBackgroundColor != nil) {
                if ([threadBackgroundColor length] == 0) {
                    sqlite3_bind_null(stmt, i++);
                } else {
                    sqlite3_bind_text(stmt, i++, [threadBackgroundColor UTF8String], -1, NULL);
                }
            }
            if (threadTextColor != nil) {
                if ([threadTextColor length] == 0) {
                    sqlite3_bind_null(stmt, i++);
                } else {
                    sqlite3_bind_text(stmt, i++, [threadTextColor UTF8String], -1, NULL);
                }
            }

            if (updateWholeThread) {
                sqlite3_bind_text(stmt, i++, [parentMessageKey UTF8String], -1, NULL);
                sqlite3_bind_text(stmt, i++, [parentMessageKey UTF8String], -1, NULL);
            } else {
                sqlite3_bind_text(stmt, i++, [messageKey UTF8String], -1, NULL);
            }

            if ((e = sqlite3_step(stmt)) != SQLITE_DONE) {
                LOG(@"Failed to update message %@", updateWholeThread ? parentMessageKey : messageKey);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_finalize(stmt);
        }

        rowsChanged = sqlite3_changes(self.dbMgr.writeableDB);

        if (messageKey != nil && existence != nil && [existence longLongValue] == MCTMessageExistenceDeleted) {
            MCTlong sortId = [self sortIdForMessageWithParentKey:messageKey];
            @try {
                sqlite3_bind_int64(stmtUpdateSortIdForThread_, 1, sortId);
                sqlite3_bind_int64(stmtUpdateSortIdForThread_, 2, sortId);
                sqlite3_bind_int64(stmtUpdateSortIdForThread_, 3, sortId);

                if ((e = sqlite3_step(stmtUpdateSortIdForThread_)) != SQLITE_DONE) {
                    LOG(@"Failed to update sort id for thread with sortId %d", sortId);
                    MCT_THROW_SQL_EXCEPTION(e);
                }
            }
            @finally {
                sqlite3_reset(stmtUpdateSortIdForThread_);
            }
        }
    }];

    if (rowsChanged > 0) {
        MCTIntent *intent;
        if (updateWholeThread) {
            intent = [MCTIntent intentWithAction:kINTENT_THREAD_MODIFIED];
            [intent setString:parentMessageKey forKey:@"thread_key"];
        } else {
            intent = [MCTIntent intentWithAction:kINTENT_MESSAGE_MODIFIED];
            [intent setString:messageKey forKey:@"message_key"];
        }
        if (existenceChanged) {
            [intent setBool:YES forKey:@"existence_changed"];
            [intent setLong:[existence longLongValue] forKey:@"existence"];
        }

        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
        return YES;
    }

    return NO;
}

- (void)replaceTmpKey:(NSString *)tmpKey withKey:(NSString *)key andTimestamp:(MCTlong)timestamp
{
    T_DONTCARE();
    [self dbLockedTransactionWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtUpdateMessageKeyAndTimestamp_, 1, [key UTF8String], -1, NULL);
            sqlite3_bind_int64(stmtUpdateMessageKeyAndTimestamp_, 2, timestamp);
            sqlite3_bind_text(stmtUpdateMessageKeyAndTimestamp_, 3, [tmpKey UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateMessageKeyAndTimestamp_)) != SQLITE_DONE) {
                LOG(@"Failed to replace message tmpKey '%@' with key '%@'", tmpKey, key);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateMessageKeyAndTimestamp_);
        }

        @try {
            int e;

            sqlite3_bind_text(stmtUpdateMessageLastThreadMessage_, 1, [key UTF8String], -1, NULL);
            sqlite3_bind_text(stmtUpdateMessageLastThreadMessage_, 2, [tmpKey UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateMessageLastThreadMessage_)) != SQLITE_DONE) {
                LOG(@"Failed to update message last thread message '%@' with '%@'", tmpKey, key);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateMessageLastThreadMessage_);
        }

        @try {
            int e;

            sqlite3_bind_text(stmtUpdateMemberMessageKey_, 1, [key UTF8String], -1, NULL);
            sqlite3_bind_text(stmtUpdateMemberMessageKey_, 2, [tmpKey UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateMemberMessageKey_)) != SQLITE_DONE) {
                LOG(@"Failed to replace member_status message tmpKey '%@' with key '%@'", tmpKey, key);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateMemberMessageKey_);
        }

        @try {
            int e;

            sqlite3_bind_text(stmtUpdateButtonMessageKey_, 1, [key UTF8String], -1, NULL);
            sqlite3_bind_text(stmtUpdateButtonMessageKey_, 2, [tmpKey UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateButtonMessageKey_)) != SQLITE_DONE) {
                LOG(@"Failed to replace button message tmpKey '%@' with key '%@'", tmpKey, key);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateButtonMessageKey_);
        }

        @try {
            int e;

            sqlite3_bind_text(stmtUpdateAttachmentsMessageKey_, 1, [key UTF8String], -1, NULL);
            sqlite3_bind_text(stmtUpdateAttachmentsMessageKey_, 2, [tmpKey UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateAttachmentsMessageKey_)) != SQLITE_DONE) {
                LOG(@"Failed to replace attachment message tmpKey '%@' with key '%@'", tmpKey, key);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateAttachmentsMessageKey_);
        }
    }];

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_MESSAGE_REPLACED];
    [intent setString:key forKey:@"key"];
    [intent setString:tmpKey forKey:@"tmp_key"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (NSString *)messageSenderWithMessageKey:(NSString *)key
{
    T_DONTCARE();
    __block NSString *sender;

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtGetMessageSender_, 1, [key UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtGetMessageSender_)) != SQLITE_ROW) {
                LOG(@"Failed to get sender of message %@", key);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            sender = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageSender_, 0)];
        }
        @finally {
            sqlite3_reset(stmtGetMessageSender_);
        }
    }];

    return sender;
}

- (NSSet *)membersWithMessageKey:(NSString *)key
{
    T_DONTCARE();
    NSMutableSet *result = [NSMutableSet set];

    [self dbLockedOperationWithBlock:^{
        [result addObject:[self messageSenderWithMessageKey:key]];

        @try {
            int e;

            sqlite3_bind_text(stmtGetMessageMembers_, 1, [key UTF8String], -1, NULL);

            while ((e = sqlite3_step(stmtGetMessageMembers_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get members of message %@", key);
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                [result addObject:[NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageMembers_, 0)]];
            }
        }
        @finally {
            sqlite3_reset(stmtGetMessageMembers_);
        }
    }];

    return result;
}

- (NSArray *)attachmentsWithMessageKey:(NSString *)key
{
    T_DONTCARE();
    NSMutableArray *result = [NSMutableArray array];

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtGetMessageAttachments_, 1, [key UTF8String], -1, NULL);

            while ((e = sqlite3_step(stmtGetMessageAttachments_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get attachments of message %@", key);
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                MCT_com_mobicage_to_messaging_AttachmentTO *attachment =
                    [MCT_com_mobicage_to_messaging_AttachmentTO transferObject];
                attachment.content_type = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageAttachments_, 0)];
                attachment.download_url = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageAttachments_, 1)];
                attachment.size = sqlite3_column_int(stmtGetMessageAttachments_, 2);
                attachment.name = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageAttachments_, 3)];
                [result addObject:attachment];
            }
        }
        @finally {
            sqlite3_reset(stmtGetMessageAttachments_);
        }
    }];

    return result;
}

- (int)messageFlagsWithKey:(NSString *)msgKey
{
    T_DONTCARE();
    __block int flags;

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtGetMessageFlags_, 1, [msgKey UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtGetMessageFlags_)) != SQLITE_ROW) {
                LOG(@"Failed to get message flags of message '%@'", msgKey);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            flags = sqlite3_column_int(stmtGetMessageFlags_, 0);
        }
        @finally {
            sqlite3_reset(stmtGetMessageFlags_);
        }
    }];

    return flags;
}

- (NSArray *)alertFlagsOfOpenMessagesSince:(MCTlong)timestamp;
{
    T_DONTCARE();
    NSMutableArray *alertFlags = [NSMutableArray array];

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_int64(stmtGetAlertFlags_, 1, timestamp);

            while ((e = sqlite3_step(stmtGetAlertFlags_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get alert flags of open messages");
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                int flag = sqlite3_column_int(stmtGetAlertFlags_, 0);
                [alertFlags addObject:[NSNumber numberWithInt:flag]];
            }
        }
        @finally {
            sqlite3_reset(stmtGetAlertFlags_);
        }
    }];

    return alertFlags;
}

- (void)updateMessageFlagsWithKey:(NSString *)key andFlag:(MCTMessageFlag)flag
{
    T_DONTCARE();

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_int(stmtUpdateFlags_, 1, flag);
            sqlite3_bind_text(stmtUpdateFlags_, 2, [key UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateFlags_)) != SQLITE_DONE) {
                LOG(@"Failed to lock message with key %@", key);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateFlags_);
        }
    }];
}

- (void)setMessageIsDirty:(BOOL)isDirty withKey:(NSString *)msgKey
{
    T_DONTCARE();
    [self dbLockedTransactionWithBlock:^{
        [self operationSetMessageIsDirty:isDirty withKey:msgKey];
    }];

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_MESSAGE_MODIFIED];
    [intent setString:msgKey forKey:@"message_key"];
    [intent setBool:YES forKey:@"dirty_changed"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (void)operationSetMessageIsDirty:(BOOL)isDirty withKey:(NSString *)msgKey
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_int(stmtSetMessageDirty_, 1, isDirty ? 1 : 0);
            sqlite3_bind_text(stmtSetMessageDirty_, 2, [msgKey UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtSetMessageDirty_)) != SQLITE_DONE) {
                LOG(@"Failed to set 'dirty=%d' on message '%@'", isDirty ? 1 : 0, msgKey);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtSetMessageDirty_);
        }
    }];
}

- (void)operationClearNeedsMyAnswerOfMessageWithKey:(NSString *)msgKey
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtSetMessageProcessed_, 1, [msgKey UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtSetMessageProcessed_)) != SQLITE_DONE) {
                LOG(@"Failed to set 'needs_my_answer=0' on message '%@'", msgKey);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtSetMessageProcessed_);
        }
    }];
}

- (void)setThreadReadWithKey:(NSString *)threadKey andDirtyMessages:(NSArray *)dirtyMessageKeys
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtMarkThreadAsRead_, 1, [threadKey UTF8String], -1, NULL);
            sqlite3_bind_text(stmtMarkThreadAsRead_, 2, [threadKey UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtMarkThreadAsRead_)) != SQLITE_DONE) {
                LOG(@"Failed to mark thread '%@' as read", threadKey);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtMarkThreadAsRead_);
        }
    }];

    NSEnumerator *reverseObjectEnumerator = [dirtyMessageKeys reverseObjectEnumerator];
    for (NSString *key in reverseObjectEnumerator) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_MESSAGE_MODIFIED];
        [intent setString:key forKey:@"message_key"];
        [intent setBool:YES forKey:@"dirty_changed"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    }
}

- (void)operationAckMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message
               withButtonId:(NSString *)btnId
             andCustomReply:(NSString *)customReply
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            [self operationClearNeedsMyAnswerOfMessageWithKey:message.key];
            [self operationSetMessageIsDirty:NO withKey:message.key];

            int e;

            MCTlong acked_timestamp = [MCTUtils serverTimeFromClientTime:[MCTUtils currentTimeMillis]];
            sqlite3_bind_int64(stmtUpdateMyMemberStatus_, 1, acked_timestamp);
            if (btnId == nil) {
                sqlite3_bind_null(stmtUpdateMyMemberStatus_, 2);
            } else {
                sqlite3_bind_text(stmtUpdateMyMemberStatus_, 2, [btnId UTF8String], -1, NULL);
            }
            if (customReply == nil) {
                sqlite3_bind_null(stmtUpdateMyMemberStatus_, 3);
            } else {
                sqlite3_bind_text(stmtUpdateMyMemberStatus_, 3, [customReply UTF8String], -1, NULL);
            }
            sqlite3_bind_int(stmtUpdateMyMemberStatus_, 4, MCTMessageStatusAcked);
            sqlite3_bind_text(stmtUpdateMyMemberStatus_, 5, [message.key UTF8String], -1, NULL);
            sqlite3_bind_text(stmtUpdateMyMemberStatus_, 6, [[self myEmail] UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateMyMemberStatus_)) != SQLITE_DONE) {
                LOG(@"Failed to update my member status with message '%@' and button '%@' and custom reply '%@'",
                    message.key, btnId, customReply);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            if (IS_FLAG_SET(message.flags, MCTMessageFlagDynamicChat) && IS_FLAG_SET(message.flags, MCTMessageFlagAllowChatButtons)) {
                if (sqlite3_changes(self.dbMgr.writeableDB) == 0) {
                    MCT_com_mobicage_to_messaging_MemberStatusTO *myMember = [[MCT_com_mobicage_to_messaging_MemberStatusTO alloc] init];
                    myMember.acked_timestamp = acked_timestamp;
                    myMember.button_id = btnId;
                    myMember.custom_reply = customReply;
                    myMember.member = [self myEmail];
                    myMember.received_timestamp = 0;
                    myMember.status = MCTMessageStatusAcked;
                    [self insertMemberStatuses:@[myMember] forMessage:message.key];
                }
            }


            int flags = [self messageFlagsWithKey:message.key];
            if ((flags & MCTMessageFlagAutoLock) == MCTMessageFlagAutoLock) {
                [self updateMessageFlagsWithKey:message.key andFlag:MCTMessageFlagLocked];
            }

            [self updateMemberSummaryForMessage:message.key];
        }
        @finally {
            sqlite3_reset(stmtUpdateMyMemberStatus_);
        }
    }];
}

- (void)operationAckChat:(MCT_com_mobicage_to_messaging_MessageTO *)message
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        [self operationClearNeedsMyAnswerOfMessageWithKey:message.key];
        [self operationSetMessageIsDirty:NO withKey:message.key];
    }];
}

- (void)broadCastMessageAcked:(MCT_com_mobicage_to_messaging_MessageTO *)message
                 withButtonId:(NSString *)buttonId
{
    T_DONTCARE();

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_MESSAGE_MODIFIED];
    [intent setString:message.key forKey:@"message_key"];
    [intent setBool:YES forKey:@"message_processed"];
    [intent setBool:YES forKey:@"needsMyAnswer_changed"];
    [intent setBool:YES forKey:@"dirty_changed"];
    [intent setString:buttonId forKey:@"my_button_id"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (void)ackMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message
      withButtonId:(NSString *)btnId
    andCustomReply:(NSString *)customReply
       andIsInBulk:(BOOL)inBulk
{
    T_DONTCARE();

    [self dbLockedTransactionWithBlock:^{
        [self operationAckMessage:message withButtonId:btnId andCustomReply:customReply];
    }];

    if (!inBulk) {
        [self broadCastMessageAcked:message withButtonId:btnId];
    }
}

- (BOOL)messageNeedsMyAnswer:(NSString *)key
{
    T_DONTCARE();
    __block BOOL needsMyAnswer;
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtGetMessageNeedsAnswer_, 1, [key UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtGetMessageNeedsAnswer_)) != SQLITE_ROW) {
                LOG(@"Failed to get needs_my_answer of message '%@'", key);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            needsMyAnswer = sqlite3_column_int(stmtGetMessageNeedsAnswer_, 0) == 1 ? YES : NO;
        }
        @finally {
            sqlite3_reset(stmtGetMessageNeedsAnswer_);
        }
    }];
    return needsMyAnswer;
}

- (NSArray *)messagesInThreadThatNeedsMyAnswer:(NSString *)threadKey
{
    T_DONTCARE();
    NSMutableArray *messages = [NSMutableArray array];

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtGetMessagesInThreadNeedsAnswer_, 1, [threadKey UTF8String], -1, NULL);
            sqlite3_bind_text(stmtGetMessagesInThreadNeedsAnswer_, 2, [threadKey UTF8String], -1, NULL);

            while ((e = sqlite3_step(stmtGetMessagesInThreadNeedsAnswer_)) != SQLITE_DONE) {
                if (e == SQLITE_ERROR) {
                    LOG(@"Failed to get messages that needs my answer");
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                MCTMessage *message = [MCTMessage message];
                message.key = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessagesInThreadNeedsAnswer_, 0)];
                message.parent_key = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessagesInThreadNeedsAnswer_, 1)];
                [messages addObject:message];
            }

        }
        @finally {
            sqlite3_reset(stmtGetMessagesInThreadNeedsAnswer_);
        }
    }];

    return messages;
}

- (BOOL)lockMessageWithKey:(NSString *)key andMembers:(NSArray *)members andFlags:(MCTlong)flags
{
    T_DONTCARE();
    return [self lockMessageWithKey:key andMembers:members andDirtyBehavior:MCTDirtyBehaviorNormal andFlags:flags];
}

- (BOOL)lockMessageWithKey:(NSString *)key andMembers:(NSArray *)members andDirtyBehavior:(MCTDirtyBehavior)dirtyBehavior1 andFlags:(MCTlong)flags
{
    T_DONTCARE();
    __block int rowsChanged;
    __block BOOL neededMyAnswer = NO;
    __block MCTDirtyBehavior dirtyBehavior = dirtyBehavior1;
    [self dbLockedTransactionWithBlock:^{
        [self updateMessageFlagsWithKey:key andFlag:MCTMessageFlagLocked];

        if ((rowsChanged = sqlite3_changes([MCTComponentFramework writeableDB])) > 0) {
            neededMyAnswer = [self messageNeedsMyAnswer:key];
            if (dirtyBehavior == MCTDirtyBehaviorNormal && neededMyAnswer)
                dirtyBehavior = MCTDirtyBehaviorMakeDirty;

            if (neededMyAnswer)
                [self operationClearNeedsMyAnswerOfMessageWithKey:key];

            if (dirtyBehavior == MCTDirtyBehaviorMakeDirty)
                [self operationSetMessageIsDirty:YES withKey:key];
            else if (dirtyBehavior == MCTDirtyBehaviorClearDirty)
                [self operationSetMessageIsDirty:NO withKey:key];

            if (members && [members count] != 0) {
                for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in members) {
                    MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *request =
                            [MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO transferObject];
                    request.acked_timestamp = member.acked_timestamp;
                    request.button_id = member.button_id;
                    request.custom_reply = member.custom_reply;
                    request.member = member.member;
                    request.message = key;
                    request.received_timestamp = member.received_timestamp;
                    request.status = member.status;
                    request.flags = flags;
                    [self operationUpdateMessageMemberStatus:request];
                }
            }
        }
    }];

    if (rowsChanged > 0) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_MESSAGE_MODIFIED];
        [intent setString:key forKey:@"message_key"];
        [intent setBool:YES forKey:@"message_locked"];
        if (neededMyAnswer)
            [intent setBool:YES forKey:@"needsMyAnswer_changed"];
        if (dirtyBehavior != MCTDirtyBehaviorNormal)
            [intent setBool:YES forKey:@"dirty_changed"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];

        return YES;
    }

    return NO;
}

- (void)updateMessageExistence:(MCTMessageExistence)existence withParentMessageKey:(NSString *)key
{
    T_DONTCARE();
    if (existence == MCTMessageExistenceNotFound) {
        ERROR(@"MCTMessageExistenceNotFound is an illegal db value for message.existence");
        return;
    }

    [self dbLockedOperationWithBlock:^{
        int e;
        @try {
            int i = 1;
            sqlite3_bind_int64(stmtUpdateThreadExistence_, i++, existence);
            sqlite3_bind_text(stmtUpdateThreadExistence_, i++, [key UTF8String], -1, NULL);
            sqlite3_bind_text(stmtUpdateThreadExistence_, i++, [key UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateThreadExistence_)) != SQLITE_DONE) {
                LOG(@"Failed to delete conversation %@", key);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateThreadExistence_);
        }
    }];
}

- (void)deleteConversationWithKey:(NSString *)key
{
    T_DONTCARE();
    [self updateMessageExistence:MCTMessageExistenceDeleted withParentMessageKey:key];

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_THREAD_DELETED];
    [intent setString:key forKey:@"key"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (void)restoreConversationWithKey:(NSString *)key
{
    T_DONTCARE();
    [self updateMessageExistence:MCTMessageExistenceActive withParentMessageKey:key];

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_THREAD_RESTORED];
    [intent setString:key forKey:@"key"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (void)operationUpdateForm:(MCTMessage *)message
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            if (message.form) {
                sqlite3_bind_text(stmtUpdateForm_, 1, [[message formJSONRepresentation] UTF8String], -1, NULL);
            } else {
                sqlite3_bind_null(stmtUpdateForm_, 1);
            }

            sqlite3_bind_text(stmtUpdateForm_, 2, [message.key UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateForm_)) != SQLITE_DONE) {
                LOG(@"Failed to update form of message \n%@", message);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateForm_);
        }
    }];
}

- (void)submitFormWithMessage:(MCTMessage *)message andButtonId:(NSString *)buttonId
{
    T_DONTCARE();
    [self dbLockedTransactionWithBlock:^{
        [self operationUpdateForm:message];
        [self operationAckMessage:message withButtonId:buttonId andCustomReply:nil];
    }];

    [self broadCastMessageAcked:message withButtonId:buttonId];
}

- (void)updateFormWithMessage:(MCTMessage *)message
                     buttonId:(NSString *)buttonId
            receivedTimestamp:(MCTlong)receivedTimestamp
               ackedTimestamp:(MCTlong)ackedTimestamp
{
    T_DONTCARE();
    [self dbLockedTransactionWithBlock:^{
        [self operationUpdateForm:message];
        [self operationUpdateMessageMemberStatusWithMessage:message.key
                                          receivedTimestamp:receivedTimestamp
                                             ackedTimestamp:ackedTimestamp
                                                   buttonId:buttonId
                                                customReply:nil
                                                     status:(MCTMessageStatusAcked | MCTMessageStatusReceived)
                                                     member:[self myEmail]
                                                      flags:-1];
        [self operationClearNeedsMyAnswerOfMessageWithKey:message.key];
        [self operationSetMessageIsDirty:NO withKey:message.key];
        [self updateMemberSummaryForMessage:message.key];
    }];

    [self broadCastMessageAcked:message withButtonId:buttonId];
}


#pragma mark -

- (int)countMessages
{
    T_DONTCARE();
    __block int count;

    [self dbLockedOperationWithBlock:^{
        @try {
            int e = sqlite3_step(stmtGetMessageCount_);
            if (e != SQLITE_ROW) {
                MCT_THROW_SQL_EXCEPTION(e);
            }
            count = sqlite3_column_int(stmtGetMessageCount_, 0);
        }
        @finally {
            sqlite3_reset(stmtGetMessageCount_);
        }
    }];

    return count;
}

- (int)countVisibleMessages
{
    T_DONTCARE();
    __block int count;

    [self dbLockedOperationWithBlock:^{
        @try {
            int e = sqlite3_step(stmtGetVisibleMessageCount_);
            if (e != SQLITE_ROW) {
                MCT_THROW_SQL_EXCEPTION(e);
            }
            count = sqlite3_column_int(stmtGetVisibleMessageCount_, 0);
        }
        @finally {
            sqlite3_reset(stmtGetVisibleMessageCount_);
        }
    }];

    return count;
}

- (int)countUnprocessedMessagesForSender:(NSString *)sender
{
    T_DONTCARE();
    __block int count;

    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtGetUnprocessedMessagesCountForSender_, 1, [sender UTF8String], -1, NULL);
            int e = sqlite3_step(stmtGetUnprocessedMessagesCountForSender_);
            if (e != SQLITE_ROW) {
                MCT_THROW_SQL_EXCEPTION(e);
            }
            count = sqlite3_column_int(stmtGetUnprocessedMessagesCountForSender_, 0);
        }
        @finally {
            sqlite3_reset(stmtGetUnprocessedMessagesCountForSender_);
        }
    }];

    return count;
}

- (MCTMessageThread *)messageThreadWithStatement:(sqlite3_stmt *)stmt
{
    T_DONTCARE();
    NSString *pkey = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, 0)];
    NSString *key = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, 1)];
    MCTlong replyCount = sqlite3_column_int(stmt, 2);
    NSString *recipients = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, 3)];
    BOOL threadForceVisible = sqlite3_column_int(stmt, 4) == 1;
    MCTlong flags = sqlite3_column_int64(stmt, 5);
    MCTlong priority = sqlite3_column_int64(stmt, 6);
    // MCTlong default_priority = sqlite3_column_int64(stmt, 7);
    // BOOL default_sticky = sqlite3_column_int64(stmt, 8) == 1 ? YES : NO;
    MCTlong unreadCount = sqlite3_column_int64(stmt, 9);
    return [MCTMessageThread threadWithKey:OR(pkey, key)
                             andReplyCount:replyCount
                             andRecipients:recipients
                         andVisibleMessage:key
                       andThreadShowInList:threadForceVisible
                                  andFlags:flags
                               andPriority:priority
                            andUnreadCount:unreadCount];
}

- (NSArray* )messageThreads
{
    T_DONTCARE();

    NSMutableArray *threads = [NSMutableArray array];

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            while ((e = sqlite3_step(stmtGetThreads_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    MCT_THROW_SQL_EXCEPTION(e);
                }
                [threads addObject:[self messageThreadWithStatement:stmtGetThreads_]];
            }
        }
        @finally {
            sqlite3_reset(stmtGetThreads_);
        }
    }];

    return threads;
}

- (NSArray* )messageThreadsByMember:(NSString *)email
{
    T_DONTCARE();

    NSMutableArray *threads = [NSMutableArray array];

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtGetThreadsByMember_, 1, [email UTF8String], -1, NULL);
            sqlite3_bind_text(stmtGetThreadsByMember_, 2, [email UTF8String], -1, NULL);
            sqlite3_bind_text(stmtGetThreadsByMember_, 3, [email UTF8String], -1, NULL);

            while ((e = sqlite3_step(stmtGetThreadsByMember_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    MCT_THROW_SQL_EXCEPTION(e);
                }
                [threads addObject:[self messageThreadWithStatement:stmtGetThreadsByMember_]];
            }
        }
        @finally {
            sqlite3_reset(stmtGetThreadsByMember_);
        }
    }];

    return threads;
}

- (MCTMessageThread *)messageThreadByKey:(NSString *)msgKey
{
    T_DONTCARE();
    __block MCTMessageThread *thread;

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtGetThreadByKey_, 1, [msgKey UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtGetThreadByKey_)) != SQLITE_ROW) {
                LOG(@"Failed to get reply_count of message %@", msgKey);
                MCT_THROW_SQL_EXCEPTION(e);
            }
            int count = sqlite3_column_int(stmtGetThreadByKey_, 0);
            NSString *recipients = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetThreadByKey_, 1)];
            NSString *lastThreadMessage = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetThreadByKey_, 2)];
            BOOL threadForceVisible = sqlite3_column_int(stmtGetThreadByKey_, 3) == 1;
            long flags = sqlite3_column_int64(stmtGetThreadByKey_, 4);
            long priority = sqlite3_column_int64(stmtGetThreadByKey_, 5);
            long unreadCount = sqlite3_column_int64(stmtGetThreadByKey_, 6);
            thread = [MCTMessageThread threadWithKey:msgKey
                                       andReplyCount:count
                                       andRecipients:recipients
                                   andVisibleMessage:lastThreadMessage
                                 andThreadShowInList:threadForceVisible
                                            andFlags:flags
                                         andPriority:priority
                      andUnreadCount:unreadCount];
        }
        @finally {
            sqlite3_reset(stmtGetThreadByKey_);
        }
    }];

    return thread;
}


#pragma mark - Thread avatars

- (void)insertThreadAvatar:(NSData *)avatar withHash:(NSString *)avatarHash
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtThreadAvatarInsert_, 1, [avatarHash UTF8String], -1, NULL);
            sqlite3_bind_blob(stmtThreadAvatarInsert_, 2, [avatar bytes], (int)[avatar length], NULL);

            if ((e = sqlite3_step(stmtThreadAvatarInsert_)) != SQLITE_DONE) {
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtThreadAvatarInsert_);
        }
    }];

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_THREAD_AVATAR_RETREIVED];
    [intent setString:avatarHash forKey:@"thread_avatar_hash"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (BOOL)threadAvatarExistsWithHash:(NSString *)threadAvatarHash
{
    T_DONTCARE();
    __block BOOL exists = NO;
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtThreadAvatarCount_, 1, [threadAvatarHash UTF8String], -1, NULL);

            int e = sqlite3_step(stmtThreadAvatarCount_);

            if (e != SQLITE_ROW) {
                LOG(@"Failed to count thread_avatar %@", threadAvatarHash);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            exists = sqlite3_column_int(stmtThreadAvatarCount_, 0) > 0;
        }
        @finally {
            sqlite3_reset(stmtThreadAvatarCount_);
        }
    }];
    return exists;
}

- (NSData *)threadAvatarWithHash:(NSString *)threadAvatarHash
{
    T_DONTCARE();
    __block NSData *data = nil;
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtThreadAvatarGet_, 1, [threadAvatarHash UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtThreadAvatarGet_)) == SQLITE_DONE) {
                return;
            } else if (e != SQLITE_ROW) {
                MCT_THROW_SQL_EXCEPTION(e);
            }

            int length = sqlite3_column_bytes(stmtThreadAvatarGet_, 0);
            if (length != 0) {
                const void *bytes = sqlite3_column_blob(stmtThreadAvatarGet_, 0);
                data = [NSData dataWithBytes:bytes length:length];
            }
        }
        @finally {
            sqlite3_reset(stmtThreadAvatarGet_);
        }
    }];
    return data;
}

- (MCTMessage *)messageInfoWithStatement:(sqlite3_stmt *)stmt parentKey:(NSString *)pkey index:(int)index
{
    T_DONTCARE();
    __block MCTMessage *msg = nil;

    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmt, 1, [pkey UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [pkey UTF8String], -1, NULL);
            sqlite3_bind_int(stmt, 3, index);

            int e = sqlite3_step(stmt);
            if (e == SQLITE_DONE) {
                LOG(@"No Message with parentKey %@ and index %d", pkey, index);
            } else if (e == SQLITE_ROW) {
                msg = [MCTMessage message];
                msg.key = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, 0)];
                msg.parent_key = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, 1)];
                msg.sender = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, 2)];
                msg.message = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, 3)];
                if (msg.message == nil)
                    msg.message = @"";
                msg.timestamp = sqlite3_column_int(stmt, 4);
                msg.dirty = sqlite3_column_int(stmt, 5) == 0 ? NO : YES;
                msg.recipients = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, 6)];
                msg.flags = sqlite3_column_int(stmt, 7);
                msg.needsMyAnswer = sqlite3_column_int(stmt, 8) == 1 ? YES : NO;
                msg.replyCount = sqlite3_column_int(stmt, 9);
                msg.recipientsStatus = sqlite3_column_int64(stmt, 10);
                msg.alert_flags = sqlite3_column_int64(stmt, 11);
                [msg loadFormWithJSON:[NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, 12)]];
                msg.dismiss_button_ui_flags = sqlite3_column_int64(stmt, 13);
                msg.thread_avatar_hash = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, 14)];
                msg.thread_background_color = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, 15)];
                msg.thread_text_color = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, 16)];
                msg.priority = sqlite3_column_int64(stmt, 17);
                msg.default_priority = sqlite3_column_int64(stmt, 18);
                msg.default_sticky = sqlite3_column_int64(stmt, 19) == 1 ? YES : NO;
            } else {
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmt);
        }
    }];

    return msg;
}


#pragma mark -

- (MCTMessage *)messageInfoByParentKey:(NSString *)pkey andIndex:(int)index
{
    T_DONTCARE();
    MCTMessage *msg = [self messageInfoWithStatement:stmtGetMessageByPKeyAndIndex_ parentKey:pkey index:index];
    return msg;
}

- (MCTMessage *)visibleMessageInfoByParentKey:(NSString *)pkey andIndex:(int)index
{
    T_DONTCARE();
    MCTMessage *msg = [self messageInfoWithStatement:stmtGetVisibleMessageByPKeyAndIndex_ parentKey:pkey index:index];
    return msg;
}

- (NSArray *)buttonsWithMessageKey:(NSString *)key
{
    T_DONTCARE();
    NSMutableArray *buttons = [NSMutableArray array];

    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtGetMessageButtons_, 1, [key UTF8String], -1, NULL);

            int e;

            while ((e = sqlite3_step(stmtGetMessageButtons_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                MCT_com_mobicage_to_messaging_ButtonTO *btn = [MCT_com_mobicage_to_messaging_ButtonTO transferObject];
                btn.idX = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageButtons_, 0)];
                btn.caption = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageButtons_, 1)];
                btn.action = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageButtons_, 2)];
                btn.ui_flags = sqlite3_column_int64(stmtGetMessageButtons_, 3);

                [buttons addObject:btn];
            }
        }
        @finally {
            sqlite3_reset(stmtGetMessageButtons_);
        }

    }];

    return buttons;
}

- (NSArray *)memberStatusesWithMessageKey:(NSString *)key
{
    T_DONTCARE();
    NSMutableArray *members = [NSMutableArray array];

    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtGetMessageMemberStatuses_, 1, [key UTF8String], -1, NULL);

            int e;

            while ((e = sqlite3_step(stmtGetMessageMemberStatuses_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                MCT_com_mobicage_to_messaging_MemberStatusTO *member =
                    [MCT_com_mobicage_to_messaging_MemberStatusTO transferObject];

                member.member = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageMemberStatuses_, 0)];
                member.received_timestamp = sqlite3_column_int(stmtGetMessageMemberStatuses_, 1);
                member.acked_timestamp = sqlite3_column_int(stmtGetMessageMemberStatuses_, 2);
                member.button_id = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageMemberStatuses_, 3)];
                member.custom_reply = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageMemberStatuses_, 4)];
                member.status = sqlite3_column_int(stmtGetMessageMemberStatuses_, 5);

                [members addObject:member];
            }
        }
        @finally {
            sqlite3_reset(stmtGetMessageMemberStatuses_);
        }

    }];

    return members;
}

- (MCTMessage *)messageInfoByKey:(NSString *)key
{
    T_DONTCARE();
    __block MCTMessage *msg = nil;

    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtGetMessageByKey_, 1, [key UTF8String], -1, NULL);

            int e = sqlite3_step(stmtGetMessageByKey_);

            if (e == SQLITE_DONE) {
                LOG(@"Message %@ not found in the database", key);
            } else if (e != SQLITE_ROW) {
                LOG(@"Failed to get message with key %@", key);
                MCT_THROW_SQL_EXCEPTION(e);
            } else {
                msg = [MCTMessage message];

                msg.key = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageByKey_, 0)];
                msg.parent_key = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageByKey_, 1)];
                msg.sender = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageByKey_, 2)];
                msg.message = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageByKey_, 3)];
                if (msg.message == nil)
                    msg.message = @"";
                msg.timestamp = sqlite3_column_int(stmtGetMessageByKey_, 4);
                msg.flags = sqlite3_column_int(stmtGetMessageByKey_, 5);
                msg.branding = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageByKey_, 6)];
                msg.alert_flags = sqlite3_column_int64(stmtGetMessageByKey_, 7);
                msg.needsMyAnswer = sqlite3_column_int(stmtGetMessageByKey_, 8) == 1 ? YES : NO;
                msg.replyCount = sqlite3_column_int(stmtGetMessageByKey_, 9);
                msg.dirty = sqlite3_column_int(stmtGetMessageByKey_, 10) == 1 ? YES : NO;
                msg.recipientsStatus = sqlite3_column_int64(stmtGetMessageByKey_, 11);
                msg.recipients = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageByKey_, 12)];
                [msg loadFormWithJSON:[NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageByKey_, 13)]];
                msg.threadDirty = (BOOL) sqlite3_column_int(stmtGetMessageByKey_, 14);
                msg.threadNeedsMyAnswer = (BOOL) sqlite3_column_int(stmtGetMessageByKey_, 15);
                msg.dismiss_button_ui_flags = sqlite3_column_int64(stmtGetMessageByKey_, 16);
                msg.lastThreadMessage = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageByKey_, 17)];
                msg.threadShowInList = (BOOL) sqlite3_column_int(stmtGetMessageByKey_, 18);
                msg.broadcast_type = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageByKey_, 19)];
                msg.thread_avatar_hash = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageByKey_, 20)];
                msg.thread_background_color = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageByKey_, 21)];
                msg.thread_text_color = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageByKey_, 22)];
                msg.priority = sqlite3_column_int64(stmtGetMessageByKey_, 23);
                msg.default_priority = sqlite3_column_int64(stmtGetMessageByKey_, 24);
                msg.default_sticky = sqlite3_column_int64(stmtGetMessageByKey_, 25) == 1 ? YES : NO;
            }
        }
        @finally {
            sqlite3_reset(stmtGetMessageByKey_);
        }
    }];

    return msg;
}

- (MCTMessage *)messageDetailsByKey:(NSString *)key
{
    T_DONTCARE();
    __block MCTMessage *msg;

    [self dbLockedOperationWithBlock:^{
        msg = [self messageInfoByKey:key];
        if (msg) {
            msg.buttons = [self buttonsWithMessageKey:msg.key];
            msg.members = [self memberStatusesWithMessageKey:msg.key];
            msg.attachments = [self attachmentsWithMessageKey:msg.key];
        }
    }];

    return msg;
}

- (NSArray *)repliesWithParentKey:(NSString *)parentKey
{
    T_DONTCARE();
    NSMutableArray *keys = [NSMutableArray array];
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtGetReplies_, 1, [parentKey UTF8String], -1, NULL);

            while ((e = sqlite3_step(stmtGetReplies_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get replies of message %@", parentKey);
                    MCT_THROW_SQL_EXCEPTION(e);
                }
                [keys addObject:[NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetReplies_, 0)]];
            }
        }
        @finally {
            sqlite3_reset(stmtGetReplies_);
        }
    }];

    return keys;
}

- (int)countDirtyThreads
{
    T_DONTCARE();
    __block int count;
    [self dbLockedOperationWithBlock:^{
        @try {
            int e = sqlite3_step(stmtGetDirtyThreadsCount_);

            if (e != SQLITE_ROW) {
                LOG(@"Failed to get dirty thread count");
                MCT_THROW_SQL_EXCEPTION(e);
            }

            count = sqlite3_column_int(stmtGetDirtyThreadsCount_, 0);
        }
        @finally {
            sqlite3_reset(stmtGetDirtyThreadsCount_);
        }
    }];
    return count;
}

- (BOOL)isMessageDirty:(NSString *)msgKey
{
    T_DONTCARE();
    __block BOOL isDirty;
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtIsMessageDirty_, 1, [msgKey UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtIsMessageDirty_)) != SQLITE_ROW) {
                MCT_THROW_SQL_EXCEPTION(e);
            }

            isDirty = sqlite3_column_int(stmtIsMessageDirty_, 0) == 1 ? YES : NO;
        }
        @finally {
            sqlite3_reset(stmtIsMessageDirty_);
        }
    }];
    return isDirty;
}

- (MCTMessageBreadCrumbs *)messageBreadCrumbsWithKey:(NSString *)msgKey
{
    T_DONTCARE();
    NSMutableArray *previous = [NSMutableArray array];
    NSMutableArray *next = [NSMutableArray array];

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;
            BOOL before = YES;

            sqlite3_bind_text(stmtGetMessageBreadCrumbs_, 1, [msgKey UTF8String], -1, NULL);

            while ((e = sqlite3_step(stmtGetMessageBreadCrumbs_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get bread crumbs of message %@", msgKey);
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                NSString *mbKey = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageBreadCrumbs_, 0)];

                if ([msgKey isEqualToString:mbKey]) {
                    before = NO;
                } else {
                    MCTMessageBreadCrumb *mb = [[MCTMessageBreadCrumb alloc] init];
                    mb.key = mbKey;

                    mb.parentKey = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageBreadCrumbs_, 1)];
                    mb.sender = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageBreadCrumbs_, 2)];
                    mb.message = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMessageBreadCrumbs_, 3)];
                    if (mb.message == nil)
                        mb.message = @"";
                    mb.timestamp = sqlite3_column_int64(stmtGetMessageBreadCrumbs_, 4);

                    [(before ? previous : next) addObject:mb];
                }
            }
        }
        @finally {
            sqlite3_reset(stmtGetMessageBreadCrumbs_);
        }
    }];

    MCTMessageBreadCrumbs *breadCrumbs = [[MCTMessageBreadCrumbs alloc] init];
    breadCrumbs.previous = previous;
    breadCrumbs.next = next;
    return breadCrumbs;
}

- (NSMutableArray *)childMessageKeysInThread:(NSString *)parentKey
{
    T_DONTCARE();
    NSMutableArray *keys = [NSMutableArray array];

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtGetChildMessageKeys_, 1, [parentKey UTF8String], -1, NULL);

            while ((e = sqlite3_step(stmtGetChildMessageKeys_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get messageKeys of thread %@", parentKey);
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                NSString *key = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetChildMessageKeys_, 0)];
                [keys addObject:key];
            }
        }
        @finally {
            sqlite3_reset(stmtGetChildMessageKeys_);
        }
    }];

    return keys;
}

- (NSArray *)messagesInThread:(NSString *)parentKey
{
    T_DONTCARE();
    NSMutableArray *messages = [NSMutableArray array];

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtGetFullServiceThread_, 1, [parentKey UTF8String], -1, NULL);
            sqlite3_bind_text(stmtGetFullServiceThread_, 2, [parentKey UTF8String], -1, NULL);

            while ((e = sqlite3_step(stmtGetFullServiceThread_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get messages of thread %@", parentKey);
                    MCT_THROW_SQL_EXCEPTION(e);
                }
                MCTMessage *msg = [MCTMessage message];
                msg.key = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFullServiceThread_, 0)];
                msg.parent_key = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFullServiceThread_, 1)];
                msg.sender = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFullServiceThread_, 2)];
                msg.message = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFullServiceThread_, 3)];
                if (msg.message == nil)
                    msg.message = @"";
                msg.timestamp = sqlite3_column_int64(stmtGetFullServiceThread_, 4);
                msg.dirty = (BOOL) sqlite3_column_int(stmtGetFullServiceThread_, 5);
                msg.recipients = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFullServiceThread_, 6)];
                msg.flags = sqlite3_column_int(stmtGetFullServiceThread_, 7);
                msg.needsMyAnswer = (BOOL) sqlite3_column_int(stmtGetFullServiceThread_, 8);
                msg.recipientsStatus = sqlite3_column_int64(stmtGetFullServiceThread_, 9);
                msg.alert_flags = sqlite3_column_int(stmtGetFullServiceThread_, 10);
                // 11: _id, 12: sortid, 13: mergeid
                msg.threadDirty = (BOOL) sqlite3_column_int(stmtGetFullServiceThread_, 14);
                msg.lastThreadMessage = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFullServiceThread_, 15)];
                msg.replyCount = sqlite3_column_int(stmtGetFullServiceThread_, 16);
                [msg loadFormWithJSON:[NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFullServiceThread_, 17)]];
                msg.dismiss_button_ui_flags = sqlite3_column_int64(stmtGetFullServiceThread_, 18);
                msg.threadNeedsMyAnswer = (BOOL) sqlite3_column_int(stmtGetFullServiceThread_, 19);
                msg.priority = sqlite3_column_int64(stmtGetFullServiceThread_, 20);
                msg.default_priority = sqlite3_column_int64(stmtGetFullServiceThread_, 21);
                msg.default_sticky = sqlite3_column_int64(stmtGetFullServiceThread_, 22) == 1 ? YES : NO;

                msg.buttons = [self buttonsWithMessageKey:msg.key];
                msg.members = [self memberStatusesWithMessageKey:msg.key];
                msg.attachments = [self attachmentsWithMessageKey:msg.key];

                [messages addObject:msg];
            }
        }
        @finally {
            sqlite3_reset(stmtGetFullServiceThread_);
        }
    }];

    return messages;
}

- (NSArray *)membersStatusesInThread:(NSString *)parentKey
{
    T_DONTCARE();
    NSMutableDictionary *msDict = [NSMutableDictionary dictionary];

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtGetThreadMembers_, 1, [parentKey UTF8String], -1, NULL);
            sqlite3_bind_text(stmtGetThreadMembers_, 2, [parentKey UTF8String], -1, NULL);

            while ((e = sqlite3_step(stmtGetThreadMembers_)) != SQLITE_DONE) {
                NSString *sender = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetThreadMembers_, 0)];
                NSString *member = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetThreadMembers_, 1)];
                int status = sqlite3_column_int(stmtGetThreadMembers_, 2);
                int flags = sqlite3_column_int(stmtGetThreadMembers_, 3);
                if ([sender isEqualToString:member] || IS_FLAG_SET(flags, MCTMessageFlagLocked))
                    status = MCTMessageStatusAcked;

                MCT_com_mobicage_to_messaging_MemberStatusTO *ms = [msDict objectForKey:member];
                if (ms == nil) {
                    ms = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObject];
                    ms.member = member;
                    ms.status = status;
                    [msDict setObject:ms forKey:member];
                } else {
                    if (status < ms.status)
                        ms.status = status;
                }
            }
        }
        @finally {
            sqlite3_reset(stmtGetThreadMembers_);
        }
    }];

    return [msDict allValues];
}

- (MCTMessageExistence)existenceOfMessageWithKey:(NSString *)key
{
    T_DONTCARE();
    __block MCTMessageExistence existence;

    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtGetMessageExistence_, 1, [key UTF8String], -1, NULL);

            int e = sqlite3_step(stmtGetMessageExistence_);

            if (e == SQLITE_ROW) {
                existence = sqlite3_column_int(stmtGetMessageExistence_, 0);
            } else if (e == SQLITE_DONE) {
                existence = MCTMessageExistenceNotFound;
            } else {
                LOG(@"Failed to get existence of message %@", key);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtGetMessageExistence_);
        }
    }];

    return existence;
}

- (void)addRequestedConversationWithKey:(NSString *)key
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtInsertRequestedConversation_, 1, [key UTF8String], -1, NULL);

            int e = sqlite3_step(stmtInsertRequestedConversation_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to add requested conversation %@", key);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtInsertRequestedConversation_);
        }
    }];
}

- (BOOL)isConversationAlreadyRequestedWithKey:(NSString *)key
{
    T_DONTCARE();
    __block int count;

    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtCountRequestedConversation_, 1, [key UTF8String], -1, NULL);

            int e = sqlite3_step(stmtCountRequestedConversation_);
            if (e != SQLITE_ROW) {
                LOG(@"Failed to check existence of maybe requested conversation %@", key);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            count = sqlite3_column_int(stmtCountRequestedConversation_, 0);
        }
        @finally {
            sqlite3_reset(stmtCountRequestedConversation_);
        }
    }];

    return count > 0;
}

- (void)deleteRequestedConversationWithKey:(NSString *)key
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtDeleteRequestedConversation_, 1, [key UTF8String], -1, NULL);

            int e = sqlite3_step(stmtDeleteRequestedConversation_);
            if (e != SQLITE_DONE) {
                LOG(@"Failed to delete requested conversation %@", key);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtDeleteRequestedConversation_);
        }
    }];
}

- (void)updateMessageThread:(NSString *)threadKey withVisibility:(BOOL)visible
{
    T_UI();
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_int(stmtMessageThreadShowInListUpdate_, 1, visible ? 1 : 0);
            sqlite3_bind_text(stmtMessageThreadShowInListUpdate_, 2, [threadKey UTF8String], -1, NULL);
            sqlite3_bind_text(stmtMessageThreadShowInListUpdate_, 3, [threadKey UTF8String], -1, NULL);

            int e = sqlite3_step(stmtMessageThreadShowInListUpdate_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to update thread_show_in_list for thread %@", threadKey);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtMessageThreadShowInListUpdate_);
        }
    }];

    if (visible) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_THREAD_RESTORED];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    }
}

- (BOOL)mustShowThreadInList:(NSString *)threadKey
{
    T_DONTCARE();
    __block BOOL showInList;

    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtMessageThreadShowInListGet_, 1, [threadKey UTF8String], -1, NULL);

            int e = sqlite3_step(stmtMessageThreadShowInListGet_);

            if (e == SQLITE_ROW) {
                showInList = sqlite3_column_int(stmtMessageThreadShowInListGet_, 0) == 1;
            } else if (e == SQLITE_DONE) {
                LOG(@"Thread %@ not found", threadKey);
                showInList = NO;
            } else {
                LOG(@"Failed to get update_thread_show_in_list for thread %@", threadKey);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtMessageThreadShowInListGet_);
        }
    }];

    return showInList;
}

#pragma mark -
#pragma mark MessageFlows

- (void)saveMessageFlowRun:(MCTMessageFlowRun *)mfr
{
    T_DONTCARE();
    [self dbLockedTransactionWithBlock:^{
        @try {
            sqlite3_bind_text(stmtMessageFlowRunSave_, 1, [mfr.parentKey UTF8String], -1, NULL);
            sqlite3_bind_text(stmtMessageFlowRunSave_, 2, [mfr.state UTF8String], -1, NULL);
            sqlite3_bind_text(stmtMessageFlowRunSave_, 3, [mfr.staticFlowHash UTF8String], -1, NULL);

            int e = sqlite3_step(stmtMessageFlowRunSave_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to insert message_flow_run with parent_message_key %@, staticFlowHash %@ and state %@",
                    mfr.parentKey, mfr.staticFlowHash, mfr.state);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtMessageFlowRunSave_);
        }
    }];
}

- (MCTMessageFlowRun *)messageFlowRunWithParentKey:(NSString *)parentMessageKey
{
    T_DONTCARE();
    __block MCTMessageFlowRun *mfr = nil;

    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtMessageFlowRunGet_, 1, [parentMessageKey UTF8String], -1, NULL);

            int e = sqlite3_step(stmtMessageFlowRunGet_);

            if (e == SQLITE_DONE) {
                LOG(@"No message flow run found with parent_message_key %@", parentMessageKey);
            } else if (e != SQLITE_ROW) {
                LOG(@"Failed to get message_flow_run by parent_message_key %@", parentMessageKey);
                MCT_THROW_SQL_EXCEPTION(e);
            } else {
                mfr = [MCTMessageFlowRun messageFlowRun];
                mfr.parentKey = parentMessageKey;
                mfr.state = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtMessageFlowRunGet_, 0)];
                mfr.staticFlowHash = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtMessageFlowRunGet_, 1)];
            }
        }
        @finally {
            sqlite3_reset(stmtMessageFlowRunGet_);
        }
    }];

    return mfr;
}

- (void)deleteMessageFlowRunWithParentKey:(NSString *)parentMessageKey
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtMessageFlowRunDelete_, 1, [parentMessageKey UTF8String], -1, NULL);

            int e = sqlite3_step(stmtMessageFlowRunDelete_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to delete message_flow_run by parent_message_key %@", parentMessageKey);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtMessageFlowRunDelete_);
        }
    }];
}

- (void)recalculateShowInList
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            if ((e = sqlite3_step(stmtMessageRecalculateShowInList_)) != SQLITE_DONE) {
                LOG(@"Failed to recalculate show in list of messages");
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtMessageRecalculateShowInList_);
        }
    }];
}

@end