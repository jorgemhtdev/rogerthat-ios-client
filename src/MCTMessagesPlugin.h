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

#import "MCTAlertMgr.h"
#import "MCTBrandingMgr.h"
#import "MCTCallReceiver.h"
#import "MCTMessage.h"
#import "MCTMessageActivityFactory.h"
#import "MCTMessageStore.h"
#import "MCTPlugin.h"
#import "MCTSendMessageRequest.h"

#define MCT_MESSAGE_TMP_KEY_PREFIX @"_tmp/"


@interface MCTMessagesPlugin : MCTPlugin <MCT_com_mobicage_capi_messaging_IClientRPC>

@property (nonatomic, strong) MCTAlertMgr *alertMgr;
@property (nonatomic, strong) MCTMessageStore *store;
@property (nonatomic, strong) MCTMessageActivityFactory *activityFactory;

- (void)logJSMFRError:(NSException *)exception;
- (BOOL)validateFormMessage:(MCTMessage *)message withFormResult:(NSDictionary *)value;

- (void)newMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message withBrandingOK:(BOOL)brandingOK;

- (BOOL)updateMessageWithRequest:(MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *)request;

- (BOOL)messageLockedWithParentKey:(NSString *)parentKey
                            andKey:(NSString *)key
                        andMembers:(NSArray *)members
                  andDirtyBehavior:(MCTDirtyBehavior)dirtyBehavior;
- (void)lockMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message;

- (void)dismissMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message;
- (void)ackMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message
        withButton:(MCT_com_mobicage_to_messaging_ButtonTO *)btn;
- (void)ackMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message
        withButton:(MCT_com_mobicage_to_messaging_ButtonTO *)btn
    andCustomReply:(NSString *)customReply
       andIsInBulk:(BOOL)inBulk;
- (void)ackThreadWithKey:(NSString *)threadKey;
- (void)ackChatWithKey:(NSString *)threadKey;
- (void)markAsReadWithParentKey:(NSString *)parentKey andMessageKeys:(NSArray *)messageKeys;
- (BOOL)messageAckedByMe:(MCT_com_mobicage_to_messaging_MessageTO *)message;

- (void)deleteConversations:(NSArray *)threadKeys;
- (BOOL)requestConversation:(NSString *)threadKey;

- (void)sendMessageWithRequest:(MCTSendMessageRequest *)request;

- (void)replaceTmpKey:(NSString *)tmpKey
              withKey:(NSString *)key
         andParentKey:(NSString *)parentKey
         andTimestamp:(MCTlong)timestamp;
- (BOOL)isTmpKey:(NSString *)key;

- (void)messageFailed:(NSString *)key;

- (void)messageNotDirty:(NSString *)key;

- (NSString *)myAnswerTextWithMessage:(MCTMessage *)message;
- (UIImage *)threadAvatarWithHash:(NSString *)threadAvatarHash;
- (void)requestAvatarWithHash:(NSString *)threadAvatarHash
                    threadKey:(NSString *)threadKey;

#pragma mark -

- (void)startLocalFlowWithContext:(NSDictionary *)context;

- (void)submitTextLineForm:(MCTMessage *)message
                 withValue:(MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)value
                  buttonId:(NSString *)buttonId;
- (void)submitTextBlockForm:(MCTMessage *)message
                  withValue:(MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)value
                   buttonId:(NSString *)buttonId;
- (void)submitAutoCompleteForm:(MCTMessage *)message
                     withValue:(MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)value
                      buttonId:(NSString *)buttonId;
- (void)submitSingleSelectForm:(MCTMessage *)message
                     withValue:(MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)value
                      buttonId:(NSString *)buttonId;
- (void)submitMultiSelectForm:(MCTMessage *)message
                    withValue:(MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *)value
                     buttonId:(NSString *)buttonId;
- (void)submitDateSelectForm:(MCTMessage *)message
                   withValue:(MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *)value
                    buttonId:(NSString *)buttonId;
- (void)submitSingleSliderForm:(MCTMessage *)message
                     withValue:(MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *)value
                      buttonId:(NSString *)buttonId;
- (void)submitRangeSliderForm:(MCTMessage *)message
                    withValue:(MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *)value
                     buttonId:(NSString *)buttonId;
- (void)submitPhotoUploadForm:(MCTMessage *)message
                    withValue:(MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)value
                     buttonId:(NSString *)buttonId;
- (void)startPhotoUploadWithForm:(MCTMessage *)message
                           image:(UIImage *)image
                        buttonId:(NSString *)buttonId;
- (void)submitGPSLocationForm:(MCTMessage *)message
                    withValue:(MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *)value
                     buttonId:(NSString *)buttonId;
- (void)submitMyDigiPassForm:(MCTMessage *)message
                   withValue:(MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *)value
                    buttonId:(NSString *)buttonId;
- (void)submitAdvancedOrderForm:(MCTMessage *)message
                      withValue:(MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *)value
                       buttonId:(NSString *)buttonId;
#pragma mark -

- (void)uploadData:(NSData *)data withMessage:(MCTMessage *)message contentType:(NSString *)contentType;

#pragma mark - Attachments

- (NSString *)attachmentsDirWithThreadKey:(NSString *)threadKey;
- (NSString *)attachmentsDirWithMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message;
- (NSString *)attachmentsDirWithSendMessageRequest:(MCTSendMessageRequest *)request;
- (NSString *)attachmentsFileWithSendMessageRequest:(MCTSendMessageRequest *)request;

- (MCTMessageAttachmentPreviewItem *)previewItemForAttachmentWithName:(NSString *)name
                                                          downloadURL:(NSString *)downloadURL
                                                          contentType:(NSString *)contentType
                                                            threadKey:(NSString *)threadKey
                                                           messageKey:(NSString *)messageKey;

@end