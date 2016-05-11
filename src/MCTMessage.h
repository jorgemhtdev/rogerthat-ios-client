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

#import "MCTTransferObjects.h"

#import <QuickLook/QuickLook.h>

#define MSG_ATTACHMENT_CONTENT_TYPE_VIDEO_MP4 @"video/mp4"
#define MSG_ATTACHMENT_CONTENT_TYPE_IMG_JPG @"image/jpeg"
#define MSG_ATTACHMENT_CONTENT_TYPE_IMG_PNG @"image/png"
#define MSG_ATTACHMENT_CONTENT_TYPE_PDF @"application/pdf"

typedef enum {
    MCTMessagePriorityNormal = 1,
    MCTMessagePriorityHigh = 2,
    MCTMessagePriorityUrgent = 3,
    MCTMessagePriorityUrgentWithAlarm = 4,
} MCTMessagePriority;

@interface MCTMessageAttachmentPreviewItem : NSObject<QLPreviewItem>

@property (nonatomic, copy) NSString *itemDir;
@property (nonatomic, copy) NSString *itemPath;
@property (nonatomic, copy) NSString *itemTitle;

- (NSURL *)previewItemURL;
- (NSString *)previewItemTitle;

@end


#pragma mark -

@interface MCTMessage : MCT_com_mobicage_to_messaging_MessageTO <NSCoding>

@property (nonatomic) BOOL dirty;
@property (nonatomic) BOOL threadDirty;
@property (nonatomic) BOOL needsMyAnswer;
@property (nonatomic) BOOL threadNeedsMyAnswer;
@property (nonatomic) BOOL threadShowInList;
@property (nonatomic, copy) NSString *recipients;
@property (nonatomic, copy) NSString *lastThreadMessage;
@property (nonatomic) NSInteger replyCount;
@property (nonatomic) NSInteger unreadCount;
@property (nonatomic,) MCTlong recipientsStatus;
@property (nonatomic, strong) NSDictionary *form;

+ (MCTMessage *)message;
+ (MCTMessage *)messageWithMessageTO:(MCT_com_mobicage_to_messaging_MessageTO *)msgTO;
+ (MCTMessage *)messageWithFormMessageDict:(NSDictionary *)fmDict;

- (NSDictionary *)dictRepresentation;

- (void)loadFormWithJSON:(NSString *)jsonString;
- (NSString *)formJSONRepresentation;

- (NSInteger)numRecipients;
- (NSInteger)numReceived;
- (NSInteger)numDismissed;
- (NSInteger)numQuickReplied;
- (NSInteger)numAcked;

@end


#pragma mark -

@interface MCT_com_mobicage_to_messaging_MessageTO (MCTMessageAdditions)

- (NSString *)threadKey;

- (MCT_com_mobicage_to_messaging_ButtonTO *)buttonWithId:(NSString *)idX;
- (MCT_com_mobicage_to_messaging_MemberStatusTO *)memberWithEmail:(NSString *)email;
- (NSArray *)membersWithAnswer:(NSString *)btnId;

- (BOOL)isLocked;
- (BOOL)isSentByJSMFR;

- (MCTMessageAttachmentPreviewItem *)attachmentPreviewItemAtIndex:(NSInteger)index;
- (MCTMessageAttachmentPreviewItem *)attachmentPreviewItemWithAttachment:(MCT_com_mobicage_to_messaging_AttachmentTO *)attachment;

@end


#pragma mark -

@interface MCT_com_mobicage_to_messaging_AttachmentTO (MCTAttachmentAdditions)

- (NSString *)displaySize;

@end


#pragma mark -

@interface MCT_com_mobicage_models_properties_forms_MyDigiPassAddress (MCTMyDigiPassAddressAdditions)

- (NSString *)displayValue;

@end


@interface MCT_com_mobicage_models_properties_forms_MyDigiPassProfile (MCTMyDigiPassProfileAdditions)

- (NSString *)displayName;
- (NSString *)displayLanguage;
- (NSString *)displayValue;

@end


@interface MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress (MCTMyDigiPassEidAddressAdditions)

- (NSString *)displayValue;

@end


@interface MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile (MCTMyDigiPassEidProfileAdditions)

- (NSString *)displayName;
- (NSString *)displayGender;
- (NSString *)displayCardInfo;
- (NSString *)displayValue;

@end