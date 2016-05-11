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

#import "MCTButton.h"
#import "MCTComponentFramework.h"
#import "MCTEncoding.h"
#import "MCTMemberStatus.h"
#import "MCTMemberStatusSummaryEncoding.h"
#import "MCTMessage.h"
#import "MCTMessageEnums.h"
#import "MCTUtils.h"

#import "MCTJSONUtils.h"


#define PICKLE_MSG_DICT @"dict"

#define MCT_MESSAGE_DIRTY @"dirty"
#define MCT_MESSAGE_RECIPIENTS @"recipients"
#define MCT_MESSAGE_NEEDSMYANSWER @"needs_my_answer"
#define MCT_MESSAGE_REPLYCOUNT @"replyCount"
#define MCT_MESSAGE_RECIPIENTS_STATUS @"recipients_status"
#define MCT_MESSAGE_FORM @"form"


#pragma mark - MCTMessageAttachmentPreviewItem

@implementation MCTMessageAttachmentPreviewItem


- (NSURL *)previewItemURL
{
    return [NSURL fileURLWithPath:self.itemPath isDirectory:NO];
}

- (NSString *)previewItemTitle
{
    return self.itemTitle;
}

@end


#pragma mark - MCTMessage

@implementation MCTMessage


+ (MCTMessage *)message
{
    T_DONTCARE()
    return [[MCTMessage alloc] init];
}

+ (MCTMessage *)messageWithMessageTO:(MCT_com_mobicage_to_messaging_MessageTO *)msgTO
{
    T_DONTCARE()
    MCTMessage *msg = [[MCTMessage alloc] initWithDict:[msgTO dictRepresentation]];
    return msg;
}

+ (MCTMessage *)messageWithFormMessageDict:(NSDictionary *)fmDict
{
    T_DONTCARE();
    MCTMessage *msg = [MCTMessage message];
    msg.alert_flags = [fmDict longForKey:@"alert_flags"];
    msg.branding = [fmDict stringForKey:@"branding"];
    if (msg.branding == MCTNull)
        msg.branding = nil;
    msg.context = [fmDict stringForKey:@"context"];
    if (msg.context == MCTNull)
        msg.context = nil;
    msg.flags = [fmDict longForKey:@"flags"];
    msg.form = [fmDict objectForKey:@"form"];
    msg.key = [fmDict stringForKey:@"key"];
    if (msg.key == MCTNull)
        msg.key = nil;
    msg.message = [fmDict stringForKey:@"message"];
    if (msg.message == MCTNull)
        msg.message = nil;
    msg.parent_key = [fmDict stringForKey:@"parent_key"];
    if (msg.parent_key == MCTNull)
        msg.parent_key = nil;
    msg.sender = [fmDict stringForKey:@"sender"];
    if (msg.sender == MCTNull)
        msg.sender = nil;
    msg.timeout = 0;
    msg.timestamp = [fmDict longForKey:@"timestamp"];

    MCTButton *posBtn = [MCTButton button];
    posBtn.caption = [msg.form objectForKey:@"positive_button"];
    posBtn.idX = MCT_FORM_POSITIVE;
    posBtn.ui_flags = [msg.form longForKey:@"positive_button_ui_flags"];

    MCTButton *negBtn = [MCTButton button];
    negBtn.caption = [msg.form objectForKey:@"negative_button"];
    negBtn.idX = MCT_FORM_NEGATIVE;
    negBtn.ui_flags = [msg.form longForKey:@"negative_button_ui_flags"];

    msg.buttons = [NSArray arrayWithObjects:posBtn, negBtn, nil];
    msg.members = [NSArray arrayWithObject:[MCTMemberStatus transferObjectWithDict:[fmDict objectForKey:@"member"]]];

    NSArray *attachmentDicts = [fmDict arrayForKey:@"attachments"];
    NSMutableArray *attachments = [NSMutableArray arrayWithCapacity:attachmentDicts.count];
    for (NSDictionary *attachmentDict in attachmentDicts) {
        [attachments addObject:[MCT_com_mobicage_to_messaging_AttachmentTO transferObjectWithDict:attachmentDict]];
    }
    msg.attachments = attachments;

    msg.thread_avatar_hash = [fmDict stringForKey:@"thread_avatar_hash" withDefaultValue:nil];
    if (msg.thread_avatar_hash == MCTNull)
        msg.thread_avatar_hash = nil;
    msg.thread_background_color = [fmDict stringForKey:@"thread_background_color" withDefaultValue:nil];
    if (msg.thread_background_color == MCTNull)
        msg.thread_background_color = nil;
    msg.thread_text_color = [fmDict stringForKey:@"thread_text_color" withDefaultValue:nil];
    if (msg.thread_text_color == MCTNull)
        msg.thread_text_color = nil;

    msg.priority = [fmDict longForKey:@"priority" withDefaultValue:MCTMessagePriorityNormal];
    return msg;
}

- (id)initWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    NSDictionary *dict = [coder decodeObjectForKey:PICKLE_MSG_DICT];
    if (self = [super initWithDict:dict]) {
        self.dirty = [dict boolForKey:MCT_MESSAGE_DIRTY];
        self.needsMyAnswer = [dict boolForKey:MCT_MESSAGE_NEEDSMYANSWER];
        self.recipients = [dict stringForKey:MCT_MESSAGE_RECIPIENTS];
        if (self.recipients == MCTNull)
            MCT_RELEASE(self.recipients);
        if ([dict containsKey:MCT_MESSAGE_REPLYCOUNT])
            self.replyCount = [dict longForKey:MCT_MESSAGE_REPLYCOUNT];
        if ([dict containsKey:MCT_MESSAGE_RECIPIENTS_STATUS])
            self.recipientsStatus = [dict longForKey:MCT_MESSAGE_RECIPIENTS_STATUS];
        if ([dict containsKey:MCT_MESSAGE_FORM]) {
            NSString *json = [dict stringForKey:MCT_MESSAGE_FORM];
            if (![MCTUtils isEmptyOrWhitespaceString:json])
                [self loadFormWithJSON:json];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    [coder encodeObject:[self dictRepresentation] forKey:PICKLE_MSG_DICT];
}

- (BOOL)isEqual:(id)obj
{
    T_DONTCARE();
    if ([super isEqual:obj]) {
        return YES;
    }
    if ([obj isKindOfClass:[MCT_com_mobicage_to_messaging_MessageTO class]]) {
        MCT_com_mobicage_to_messaging_MessageTO *msg = obj;
        if ([self.key isEqualToString:msg.key]) {
            return YES;
        }
    }
    return NO;
}

- (NSDictionary *)dictRepresentation
{
    T_DONTCARE()
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictRepresentation]];
    [dict setBool:self.dirty forKey:MCT_MESSAGE_DIRTY];
    [dict setBool:self.needsMyAnswer forKey:MCT_MESSAGE_NEEDSMYANSWER];
    [dict setString:self.recipients forKey:MCT_MESSAGE_RECIPIENTS];
    [dict setLong:self.replyCount forKey:MCT_MESSAGE_REPLYCOUNT];
    [dict setLong:self.recipientsStatus forKey:MCT_MESSAGE_RECIPIENTS_STATUS];
    [dict setString:[self formJSONRepresentation] forKey:MCT_MESSAGE_FORM];
    return dict;
}

- (NSString *)description
{
    T_DONTCARE();
    return [[self dictRepresentation] description];
}

- (void)loadFormWithJSON:(NSString *)jsonString
{
    T_DONTCARE();
    self.form = [jsonString MCT_JSONValue];
}

- (NSString *)formJSONRepresentation
{
    T_DONTCARE();
    return [self.form MCT_JSONRepresentation];
}

#pragma mark -

- (NSInteger)numRecipients
{
    if (self.recipientsStatus < 0)
        return self.recipientsStatus;

    return [MCTMemberStatusSummaryEncoding decodeNumNonSenderMembers:self.recipientsStatus];
}

- (NSInteger)numReceived
{
    if (self.recipientsStatus < 0)
        return self.recipientsStatus;

    return [MCTMemberStatusSummaryEncoding decodeNumNonSenderMembersReceived:self.recipientsStatus];
}

- (NSInteger)numDismissed
{
    if (self.recipientsStatus < 0)
        return self.recipientsStatus;

    return [MCTMemberStatusSummaryEncoding decodeNumNonSenderMembersDismissed:self.recipientsStatus];
}

- (NSInteger)numQuickReplied
{
    if (self.recipientsStatus < 0)
        return self.recipientsStatus;

    return [MCTMemberStatusSummaryEncoding decodeNumNonSenderMembersQuickReplied:self.recipientsStatus];
}

- (NSInteger)numAcked
{
    return [self numDismissed] + [self numQuickReplied];
}

@end


#pragma mark - MCTMessageAdditions

@implementation MCT_com_mobicage_to_messaging_MessageTO (MCTMessageAdditions)

- (NSString *)threadKey
{
    T_DONTCARE();
    return OR(self.parent_key, self.key);
}

- (MCT_com_mobicage_to_messaging_ButtonTO *)buttonWithId:(NSString *)idX
{
    T_DONTCARE();
    for (MCT_com_mobicage_to_messaging_ButtonTO *btn in self.buttons)
        if ([btn.idX isEqualToString:idX])
            return btn;
    return nil;
}

- (MCT_com_mobicage_to_messaging_MemberStatusTO *)memberWithEmail:(NSString *)email
{
    T_DONTCARE();
    for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in self.members)
        if ([member.member isEqualToString:email])
            return member;
    return nil;
}

- (NSArray *)membersWithAnswer:(NSString *)btnId
{
    T_DONTCARE();
    NSMutableArray *members = [NSMutableArray array];
    for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in self.members)
        if ((member.status & MCTMessageStatusAcked) == MCTMessageStatusAcked)
            if (member.button_id == btnId || (btnId && [btnId isEqualToString:member.button_id]))
                [members addObject:member];
    return members;
}

- (BOOL)isLocked
{
    return IS_FLAG_SET(self.flags, MCTMessageFlagLocked);
}

- (BOOL)isSentByJSMFR
{
    return IS_FLAG_SET(self.flags, MCTMessageFlagSentByJSMFR);
}

- (MCTMessageAttachmentPreviewItem *)attachmentPreviewItemAtIndex:(NSInteger)index
{
    return [self attachmentPreviewItemWithAttachment:self.attachments[index]];
}

- (MCTMessageAttachmentPreviewItem *)attachmentPreviewItemWithAttachment:(MCT_com_mobicage_to_messaging_AttachmentTO *)attachment
{
    return [[MCTComponentFramework messagesPlugin] previewItemForAttachmentWithName:attachment.name
                                                                        downloadURL:attachment.download_url
                                                                        contentType:attachment.content_type
                                                                          threadKey:self.threadKey
                                                                         messageKey:self.key];
}

@end


#pragma mark - MCTAttachmentAdditions

@implementation MCT_com_mobicage_to_messaging_AttachmentTO (MCTAttachmentAdditions)

- (NSString *)displaySize
{
    return self.size < 0 ? nil : [MCTUtils stringForSize:self.size];
}

@end


#pragma mark - MCTMyDigiPassAdditions

@implementation MCT_com_mobicage_models_properties_forms_MyDigiPassAddress (MCTMyDigiPassAddressAdditions)

- (NSString *)displayValue
{
    NSMutableArray *addressLines = [NSMutableArray arrayWithCapacity:4];
    if (![MCTUtils isEmptyOrWhitespaceString:self.address_1])
        [addressLines addObject:self.address_1];

    if (![MCTUtils isEmptyOrWhitespaceString:self.address_2])
        [addressLines addObject:self.address_2];

    NSMutableArray *line2 = [NSMutableArray array];
    if (![MCTUtils isEmptyOrWhitespaceString:self.zip])
        [line2 addObject:self.zip];
    if (![MCTUtils isEmptyOrWhitespaceString:self.city])
        [line2 addObject:self.city];
    if ([line2 count])
        [addressLines addObject:[line2 componentsJoinedByString:@" "]];

    NSMutableArray *line3 = [NSMutableArray array];
    if (![MCTUtils isEmptyOrWhitespaceString:self.state])
        [line3 addObject:self.state];
    if (![MCTUtils isEmptyOrWhitespaceString:self.country])
        [line3 addObject:self.country];
    if ([line3 count])
        [addressLines addObject:[line3 componentsJoinedByString:@", "]];

    return [addressLines componentsJoinedByString:@"\n"];
}

@end


@implementation MCT_com_mobicage_models_properties_forms_MyDigiPassProfile (MCTMyDigiPassProfileAdditions)

- (NSString *)displayName
{
    return [NSString stringWithFormat:@"%@ %@", OR(self.first_name, @""), OR(self.last_name, @"")];
}

- (NSString *)displayLanguage
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:self.preferred_locale];
    return [locale displayNameForKey:NSLocaleIdentifier value:self.preferred_locale];
}

- (NSString *)displayValue
{
    return [self displayName];
}

@end


@implementation MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress (MCTMyDigiPassEidAddressAdditions)

- (NSString *)displayValue
{
    NSMutableArray *addressLines = [NSMutableArray arrayWithCapacity:2];
    if (![MCTUtils isEmptyOrWhitespaceString:self.street_and_number])
        [addressLines addObject:self.street_and_number];

    NSMutableArray *line2 = [NSMutableArray array];
    if (![MCTUtils isEmptyOrWhitespaceString:self.zip_code])
        [line2 addObject:self.zip_code];
    if (![MCTUtils isEmptyOrWhitespaceString:self.municipality])
        [line2 addObject:self.municipality];

    if ([line2 count])
        [addressLines addObject:[line2 componentsJoinedByString:@" "]];

    return [addressLines componentsJoinedByString:@"\n"];
}

@end


@implementation MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile (MCTMyDigiPassEidProfileAdditions)

- (NSString *)displayName
{
    NSMutableArray *parts = [NSMutableArray arrayWithCapacity:3];
    if (self.first_name)
        [parts addObject:self.first_name];
    if (self.first_name_3)
        [parts addObject:self.first_name_3];
    if (self.last_name)
        [parts addObject:self.last_name];
    return [parts componentsJoinedByString:@" "];
}

- (NSString *)displayGender
{
    if ([@"M" isEqualToString:self.gender]) {
        return NSLocalizedString(@"Male", nil);
    } else if ([@"F" isEqualToString:self.gender]) {
        return NSLocalizedString(@"Female", nil);
    } else {
        return self.gender;
    }
}

- (NSString *)displayCardInfo
{
    return [NSString stringWithFormat:@"%@: %@\n%@: %@",
            NSLocalizedString(@"Card Nº", nil), self.card_number,
            NSLocalizedString(@"Chip Nº", nil), self.chip_number];
}

- (NSString *)displayValue
{
    return [self displayName];
}

@end