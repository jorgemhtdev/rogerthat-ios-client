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

#import "GTMNSData+zlib.h"

#import "MCTAckMessageResponseHandler.h"
#import "MCTButton.h"
#import "MCTComponentFramework.h"
#import "MCTDefaultResponseHandler.h"
#import "MCTEncoding.h"
#import "MCTGetConversationAvatarRH.h"
#import "MCTGetConversationRH.h"
#import "MCTIntent.h"
#import "MCTLockMessageResponseHandler.h"
#import "MCTMemberStatusUpdate.h"
#import "MCTMenuVC.h"
#import "MCTMessage.h"
#import "MCTMessageActivityFactory.h"
#import "MCTMessageEnums.h"
#import "MCTMessageFlowRun.h"
#import "MCTMessagesPlugin.h"
#import "MCTMessageStore.h"
#import "MCTMobileInfo.h"
#import "MCTSendMessageResponseHandler.h"
#import "MCTUploadChunkRH.h"
#import "MCTUtils.h"
#import "MCT_CS_API.h"


@interface MCTMessagesPlugin()

@property (nonatomic, strong) NSMutableArray *messagesWithNotification;

- (NSArray *)changedAnswersDuringLockMessage:(MCTMessage *)oldMessage andMembers:(NSArray *)newMembers;

- (void)updateFormWithParentMessageKey:(NSString *)parentKey
                            messageKey:(NSString *)key
                                result:(id)formResult
                              buttonId:(NSString *)buttonId
                     receivedTimestamp:(MCTlong)receivedTimestamp
                        ackedTimestamp:(MCTlong)ackedTimestamp
               customResultProcesssing:(void (^)(NSMutableDictionary *widget, id result))block;

@end


@implementation MCTMessagesPlugin


- (MCTMessagesPlugin *)init
{
    T_BIZZ();
    if (self = [super init]) {
        self.store = [[MCTMessageStore alloc] init];
        self.alertMgr = [MCTAlertMgr alertMgr];
        self.alertMgr.store = self.store;
        self.activityFactory = [[MCTMessageActivityFactory alloc] init];

        // messagesWithNotification
        NSString *jsonString = [[MCTComponentFramework configProvider] stringForKey:@"messagesWithNotification"];
        if ([MCTUtils isEmptyOrWhitespaceString:jsonString]) {
            self.messagesWithNotification = [NSMutableArray array];
        } else {
            self.messagesWithNotification = [NSMutableArray arrayWithArray:[jsonString MCT_JSONValue]];
        }

        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_MESSAGE_RECEIVED_HIGH_PRIO];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_MESSAGE_MODIFIED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_MESSAGE_SENT];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_MESSAGE_REPLACED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_MESSAGE_JSMFR_ERROR];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_MESSAGE_JSMFR_ENDED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_THREAD_ACKED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_THREAD_DELETED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_UPLOADING_CHUNKS_STARTED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_UPLOADING_CHUNKS_FINISHED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_CHUNK_UPLOADED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_MESSAGE_DETAIL_SCROLL_DOWN];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_ATTACHMENT_CLICKED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_ATTACHMENT_RETRIEVED];
    }
    return self;
}

- (void)stop
{
    T_BIZZ();
    HERE();
    MCT_RELEASE(self.activityFactory);
    MCT_RELEASE(self.store);
    [[MCTComponentFramework intentFramework] unregisterIntentListener:self.alertMgr];
    MCT_RELEASE(self.alertMgr);
    MCT_RELEASE(self.messagesWithNotification);
}

#pragma mark -
#pragma mark CallReceiver methods

- (MCT_com_mobicage_to_messaging_NewMessageResponseTO *)SC_API_newMessageWithRequest:(MCT_com_mobicage_to_messaging_NewMessageRequestTO *)request
{
    T_BACKLOG();

    [self newMessage:[MCTMessage messageWithMessageTO:request.message] withBrandingOK:NO];

    MCT_com_mobicage_to_messaging_NewMessageResponseTO *response = [MCT_com_mobicage_to_messaging_NewMessageResponseTO transferObject];
    response.received_timestamp = [MCTUtils currentServerTime];

    return response;
}

- (MCT_com_mobicage_to_messaging_UpdateMessageResponseTO *)SC_API_updateMessageWithRequest:(MCT_com_mobicage_to_messaging_UpdateMessageRequestTO *)request
{
    T_BACKLOG();
    if (request.message_key != nil &&
        [[MCTComponentFramework brandingMgr] queueIfNeededWithFunction:@"com.mobicage.capi.messaging.updateMessage"
                                                            andRequest:request
                                                         andMessageKey:request.message_key]) {
        // the capi call is stashed
        return [MCT_com_mobicage_to_messaging_UpdateMessageResponseTO transferObject];
    }

    if ([MCTUtils isEmptyOrWhitespaceString:request.message_key] &&
        [MCTUtils isEmptyOrWhitespaceString:request.parent_message_key]) {
        // Should never happen
        return [MCT_com_mobicage_to_messaging_UpdateMessageResponseTO transferObject];
    }

    NSNumber *flags = request.has_flags ? [NSNumber numberWithLongLong:request.flags] : nil;
    NSNumber *existence = request.has_existence ? [NSNumber numberWithLongLong:request.existence] : nil;

    if (flags == nil
        && existence == nil
        && request.message == nil
        && request.thread_avatar_hash == nil
        && request.thread_background_color == nil
        && request.thread_text_color == nil) {

        // Can only happen when updateMessage is extended with extra properties
        return [MCT_com_mobicage_to_messaging_UpdateMessageResponseTO transferObject];
    }

    BOOL messageFound = [self.store updateMessageWithKey:request.message_key
                                               parentKey:request.parent_message_key
                                                   flags:flags
                                               existence:existence
                                                 message:request.message
                                        threadAvatarHash:request.thread_avatar_hash
                                   threadBackgroundColor:request.thread_background_color
                                         threadTextColor:request.thread_text_color];

    // don't request a conversation when it's existence is changed to DELETED
    if (existence == nil || [existence longLongValue] == MCTMessageExistenceActive) {
        NSString *threadKey = OR(request.parent_message_key, request.message_key);
        NSString *offset = nil;
        if (messageFound && ![MCTUtils isEmptyOrWhitespaceString:request.last_child_message]) {
            // Check if the last child message on the server is equal to the last child message on the client.
            // If not, we should request the messages we don't have.

            NSMutableArray *children = [self.store childMessageKeysInThread:threadKey];
            [children enumerateObjectsWithOptions:NSEnumerationReverse
                                       usingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
                                           if ([self isTmpKey:key]) {
                                               [children removeObject:key];
                                           }
                                       }];

            if ([children count] == 0) {
                offset = threadKey;
            } else if (![request.last_child_message isEqualToString:[children lastObject]]) {
                // We don't have all the messages
                offset = [children lastObject];
            }
        }

        if (!messageFound || offset) {
            [self requestConversation:threadKey withOffset:offset];
        }
    }

    return [MCT_com_mobicage_to_messaging_UpdateMessageResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_MemberStatusUpdateResponseTO *)SC_API_updateMessageMemberStatusWithRequest:(MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *)request
{
    T_BACKLOG();
    if (![[MCTComponentFramework brandingMgr] queueIfNeededWithFunction:@"com.mobicage.capi.messaging.updateMessageMemberStatus"
                                                             andRequest:request
                                                          andMessageKey:request.message]) {

        [self updateMessageWithRequest:request];
    }
    return [MCT_com_mobicage_to_messaging_MemberStatusUpdateResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_MessageLockedResponseTO *)SC_API_messageLockedWithRequest:(MCT_com_mobicage_to_messaging_MessageLockedRequestTO *)request
{
    T_BACKLOG();
    if (![[MCTComponentFramework brandingMgr] queueIfNeededWithFunction:@"com.mobicage.capi.messaging.messageLocked"
                                                             andRequest:request
                                                          andMessageKey:request.message_key]) {

        [self messageLockedWithParentKey:request.parent_message_key
                                  andKey:request.message_key
                              andMembers:request.members
                        andDirtyBehavior:(MCTDirtyBehavior)request.dirty_behavior];
    }
    return [MCT_com_mobicage_to_messaging_MessageLockedResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_ConversationDeletedResponseTO *)SC_API_conversationDeletedWithRequest:(MCT_com_mobicage_to_messaging_ConversationDeletedRequestTO *)request
{
    T_BACKLOG();
    [[MCTComponentFramework brandingMgr] deleteConversationWithKey:request.parent_message_key];
    [self.store deleteConversationWithKey:request.parent_message_key];
    [self removeAttachmentsWithThreadKey:request.parent_message_key];
    [[[MCTComponentFramework activityPlugin] store] deletedActivityByReference:request.parent_message_key];
    [[MCTComponentFramework brandingMgr] cleanupLocalFlowCacheDirWithThreadKey:request.parent_message_key];
    return [MCT_com_mobicage_to_messaging_ConversationDeletedResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_EndMessageFlowResponseTO *)SC_API_endMessageFlowWithRequest:(MCT_com_mobicage_to_messaging_EndMessageFlowRequestTO *)request
{
    T_BACKLOG();
    [self.store deleteMessageFlowRunWithParentKey:request.parent_message_key];
    [[MCTComponentFramework brandingMgr] cleanupLocalFlowCacheDirWithThreadKey:request.parent_message_key];

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_MESSAGE_JSMFR_ENDED];
    [intent setString:request.parent_message_key forKey:@"parent_message_key"];
    [intent setBool:request.wait_for_followup forKey:@"wait_for_followup"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];

    return [MCT_com_mobicage_to_messaging_EndMessageFlowResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_TransferCompletedResponseTO *)SC_API_transferCompletedWithRequest:(MCT_com_mobicage_to_messaging_TransferCompletedRequestTO *)request
{
    T_BACKLOG();
    if ([self isTmpKey:request.message_key]) {
        // This is a transfer of an attachment we sent along with a new message
        NSString *configKey = [NSString stringWithFormat:@"sendMessage_%@", request.message_key];
        NSString *sendMessageRequestJSON = [[MCTComponentFramework configProvider] stringForKey:configKey];

        if ([MCTUtils isEmptyOrWhitespaceString:sendMessageRequestJSON]) {
            ERROR(@"Could not find SendMessageRequest %@", configKey);
        } else {
            MCTSendMessageRequest *sendMessageRequest =
                [[MCTSendMessageRequest alloc] initWithDict:[sendMessageRequestJSON MCT_JSONValue]];

            MCT_com_mobicage_to_messaging_AttachmentTO *attachment = [MCT_com_mobicage_to_messaging_AttachmentTO transferObject];
            attachment.name = @"";
            attachment.content_type = sendMessageRequest.attachmentContentType;
            attachment.download_url = request.result_url;
            attachment.size = sendMessageRequest.attachmentSize;
            sendMessageRequest.attachments = [NSArray arrayWithObject:attachment];

            NSString *tmpFile = [self attachmentsFileWithSendMessageRequest:sendMessageRequest];
            NSString *tmpDir = [self attachmentsDirWithSendMessageRequest:sendMessageRequest];

            NSString *fileExtension = [[NSURL URLWithString:attachment.download_url] pathExtension];
            if ([MCTUtils isEmptyOrWhitespaceString:fileExtension]) {
                fileExtension = [MCTUtils fileExtensionWithMimeType:attachment.content_type];
            }

            NSString *newFile = [[tmpDir stringByAppendingPathComponent:[attachment.download_url sha256Hash]]
                                 stringByAppendingPathExtension:fileExtension];

            NSError *error = nil;
            [[NSFileManager defaultManager] moveItemAtPath:tmpFile toPath:newFile error:&error];
            if (error) {
                ERROR(@"Failed to mv %@ to %@\n%@", tmpFile, newFile, error);
                // Let's ignore for now... It will be downloaded from the server when the user would want to view it.
                error = nil;
            }

            NSString *tmpThumbFile = [tmpFile stringByAppendingString:@".thumb"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:tmpThumbFile]) {
                NSString *newThumbFile = [newFile stringByAppendingString:@".thumb"];
                [[NSFileManager defaultManager] moveItemAtPath:tmpThumbFile
                                                        toPath:newThumbFile
                                                         error:&error];
                if (error) {
                    ERROR(@"Failed to mv %@ to %@\n%@", tmpThumbFile, newThumbFile, error);
                    error = nil;
                }
            }

            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                [self sendMessageWithRequest:sendMessageRequest andAttachmentsUploaded:YES];
                [[MCTComponentFramework configProvider] deleteStringForKey:configKey];
            }];
        }
    }

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_UPLOADING_CHUNKS_FINISHED];
    [intent setString:request.message_key forKey:@"message_key"];
    [intent setString:request.parent_message_key forKey:@"parent_message_key"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];

    MCTMessage *message = [self.store messageInfoByKey:request.message_key];
    if (message && message.form) {
        if ([MCT_WIDGET_PHOTO_UPLOAD isEqualToString:[message.form objectForKey:@"type"]]) {
            MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *result =
                [MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO transferObject];
            result.value = request.result_url;
            [self submitPhotoUploadForm:message withValue:result buttonId:MCT_FORM_POSITIVE];
        }
    }
    return [MCT_com_mobicage_to_messaging_TransferCompletedResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_StartFlowResponseTO *)SC_API_startFlowWithRequest:(MCT_com_mobicage_to_messaging_StartFlowRequestTO *)request
{
    T_BACKLOG();
    [[[MCTComponentFramework friendsPlugin] store] saveStaticFlow:request.static_flow
                                                         withHash:request.static_flow_hash];

    // 1. queue brandings_to_dwnl
    // 2. queue attachments_to_dwnl
    // 3. if everything present --> start flow (feed startFlowRequest to JSMFR) + make sure it produces a local notification

    NSString *threadKey = request.parent_message_key ? request.parent_message_key : [NSString stringWithFormat:@"_js_%@", [MCTUtils guid]];

    if (!MCT_USE_XMPP_KICK_CHANNEL)
        [self addMessageWithNotification:threadKey];

    NSDictionary *context = @{@"threadKey" : threadKey,
                              @"staticFlowHash" : request.static_flow_hash,
                              @"service" : request.service,
                              @"messageFlowRunId" : request.message_flow_run_id,
                              };

    BOOL queued = [[MCTComponentFramework brandingMgr] queueLocalFlowWithContext:context
                                                                    brandingKeys:request.brandings_to_dwnl
                                                          attachmentDownloadURLs:request.attachments_to_dwnl];
    if (!queued) {
        [self startLocalFlowWithContext:context];
    }

    return [MCT_com_mobicage_to_messaging_StartFlowResponseTO transferObject];
}

- (void)startLocalFlowWithContext:(NSDictionary *)context
{
    T_DONTCARE();
    MCT_com_mobicage_to_messaging_jsmfr_FlowStartedRequestTO *flowStartedRequest = [MCT_com_mobicage_to_messaging_jsmfr_FlowStartedRequestTO transferObject];
    flowStartedRequest.thread_key = context[@"threadKey"];
    flowStartedRequest.service = context[@"service"];
    flowStartedRequest.static_flow_hash = context[@"staticFlowHash"];

    MCTMessageFlowRun *mfr = [[MCTMessageFlowRun alloc] init];
    mfr.staticFlowHash = context[@"staticFlowHash"];
    mfr.state = [@{@"message_flow_run_id" : context[@"messageFlowRunId"]} MCT_JSONRepresentation];

    NSDictionary *userInput = @{@"request": [flowStartedRequest dictRepresentation],
                                @"func": @"com.mobicage.api.messaging.jsmfr.flowStarted"};

    dispatch_async(dispatch_get_main_queue(), ^{
        T_UI();
        [[MCTComponentFramework menuViewController] executeMFR:mfr
                                                 withUserInput:userInput
                                               throwIfNotReady:NO];
    });
}

#pragma mark -
#pragma mark Receive Forms

- (MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormResponseTO *)SC_API_newAutoCompleteFormWithRequest:(MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormRequestTO *)request
{
    T_BACKLOG();

    [self newMessage:[MCTMessage messageWithFormMessageDict:[request.form_message dictRepresentation]]
      withBrandingOK:NO];

    MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormResponseTO *resp =
        [MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormResponseTO transferObject];
    resp.received_timestamp = [MCTUtils currentServerTime];
    return resp;
}

- (MCT_com_mobicage_to_messaging_forms_NewDateSelectFormResponseTO *)SC_API_newDateSelectFormWithRequest:(MCT_com_mobicage_to_messaging_forms_NewDateSelectFormRequestTO *)request
{
    T_BACKLOG();

    [self newMessage:[MCTMessage messageWithFormMessageDict:[request.form_message dictRepresentation]]
      withBrandingOK:NO];

    MCT_com_mobicage_to_messaging_forms_NewDateSelectFormResponseTO *resp =
        [MCT_com_mobicage_to_messaging_forms_NewDateSelectFormResponseTO transferObject];
    resp.received_timestamp = [MCTUtils currentServerTime];
    return resp;
}

- (MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormResponseTO *)SC_API_newMultiSelectFormWithRequest:(MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormRequestTO *)request
{
    T_BACKLOG();

    [self newMessage:[MCTMessage messageWithFormMessageDict:[request.form_message dictRepresentation]]
      withBrandingOK:NO];

    MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormResponseTO *resp =
        [MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormResponseTO transferObject];
    resp.received_timestamp = [MCTUtils currentServerTime];
    return resp;
}

- (MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormResponseTO *)SC_API_newPhotoUploadFormWithRequest:(MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormRequestTO *)request
{
    T_BACKLOG();

    [self newMessage:[MCTMessage messageWithFormMessageDict:[request.form_message dictRepresentation]]
      withBrandingOK:NO];

    MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormResponseTO *resp =
        [MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormResponseTO transferObject];
    resp.received_timestamp = [MCTUtils currentServerTime];
    return resp;
}

- (MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormResponseTO *)SC_API_newRangeSliderFormWithRequest:(MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormRequestTO *)request
{
    T_BACKLOG();

    [self newMessage:[MCTMessage messageWithFormMessageDict:[request.form_message dictRepresentation]]
      withBrandingOK:NO];

    MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormResponseTO *resp =
        [MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormResponseTO transferObject];
    resp.received_timestamp = [MCTUtils currentServerTime];
    return resp;
}

- (MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormResponseTO *)SC_API_newSingleSelectFormWithRequest:(MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormRequestTO *)request
{
    T_BACKLOG();

    [self newMessage:[MCTMessage messageWithFormMessageDict:[request.form_message dictRepresentation]]
      withBrandingOK:NO];

    MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormResponseTO *resp =
        [MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormResponseTO transferObject];
    resp.received_timestamp = [MCTUtils currentServerTime];
    return resp;
}

- (MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormResponseTO *)SC_API_newSingleSliderFormWithRequest:(MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormRequestTO *)request
{
    T_BACKLOG();

    [self newMessage:[MCTMessage messageWithFormMessageDict:[request.form_message dictRepresentation]]
      withBrandingOK:NO];

    MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormResponseTO *resp =
        [MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormResponseTO transferObject];
    resp.received_timestamp = [MCTUtils currentServerTime];
    return resp;
}

- (MCT_com_mobicage_to_messaging_forms_NewTextBlockFormResponseTO *)SC_API_newTextBlockFormWithRequest:(MCT_com_mobicage_to_messaging_forms_NewTextBlockFormRequestTO *)request
{
    T_BACKLOG();

    [self newMessage:[MCTMessage messageWithFormMessageDict:[request.form_message dictRepresentation]]
      withBrandingOK:NO];

    MCT_com_mobicage_to_messaging_forms_NewTextBlockFormResponseTO *resp =
        [MCT_com_mobicage_to_messaging_forms_NewTextBlockFormResponseTO transferObject];
    resp.received_timestamp = [MCTUtils currentServerTime];
    return resp;
}

- (MCT_com_mobicage_to_messaging_forms_NewTextLineFormResponseTO *)SC_API_newTextLineFormWithRequest:(MCT_com_mobicage_to_messaging_forms_NewTextLineFormRequestTO *)request
{
    T_BACKLOG();

    [self newMessage:[MCTMessage messageWithFormMessageDict:[request.form_message dictRepresentation]]
      withBrandingOK:NO];

    MCT_com_mobicage_to_messaging_forms_NewTextLineFormResponseTO *resp =
        [MCT_com_mobicage_to_messaging_forms_NewTextLineFormResponseTO transferObject];
    resp.received_timestamp = [MCTUtils currentServerTime];
    return resp;
}

- (MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormResponseTO *)SC_API_newGPSLocationFormWithRequest:(MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormRequestTO *)request
{
    T_BACKLOG();

    [self newMessage:[MCTMessage messageWithFormMessageDict:[request.form_message dictRepresentation]]
      withBrandingOK:NO];

    MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormResponseTO *resp =
        [MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormResponseTO transferObject];
    resp.received_timestamp = [MCTUtils currentServerTime];
    return resp;
}

- (MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormResponseTO *)SC_API_newMyDigiPassFormWithRequest:(MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormRequestTO *)request
{
    T_BACKLOG();

    [self newMessage:[MCTMessage messageWithFormMessageDict:[request.form_message dictRepresentation]]
      withBrandingOK:NO];

    MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormResponseTO *resp =
        [MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormResponseTO transferObject];
    resp.received_timestamp = [MCTUtils currentServerTime];
    return resp;
}

- (MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormResponseTO *)SC_API_newAdvancedOrderFormWithRequest:(MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormRequestTO *)request
{
    T_BACKLOG();

    [self newMessage:[MCTMessage messageWithFormMessageDict:[request.form_message dictRepresentation]]
      withBrandingOK:NO];

    MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormResponseTO *resp =
    [MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormResponseTO transferObject];
    resp.received_timestamp = [MCTUtils currentServerTime];
    return resp;
}

#pragma mark -
#pragma mark Receive Form Updates

- (void)updateFormWithParentMessageKey:(NSString *)parentKey
                            messageKey:(NSString *)key
                                result:(id)result
                              buttonId:(NSString *)buttonId
                     receivedTimestamp:(MCTlong)receivedTimestamp
                        ackedTimestamp:(MCTlong)ackedTimestamp
               customResultProcesssing:(void (^)(NSMutableDictionary *widget, id result))block
{
    T_DONTCARE();
    MCTMessage *message = [self.store messageInfoByKey:key];
    if (message == nil) {
        [self requestConversation:OR(parentKey, key)];
        return;
    }

    if (result) {
        NSMutableDictionary *widget = [message.form objectForKey:@"widget"];

        if (block) {
            block(widget, result);
        }
        else if ([result isKindOfClass:[MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO class]]) {
            MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *formResult = result;
            [widget setObject:OR(formResult.value, MCTNull) forKey:@"value"];
        }
        else if ([result isKindOfClass:[MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO class]]) {
            MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *formResult = result;
            [widget setObject:OR(formResult.values, [NSArray array]) forKey:@"values"];
        }
        else if ([result isKindOfClass:[MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO class]]) {
            MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *formResult = result;
            [widget setObject:[NSNumber numberWithFloat:formResult.value] forKey:@"value"];
        }
        else if ([result isKindOfClass:[MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO class]]) {
            MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *formResult = result;
            [widget setObject:[NSNumber numberWithLongLong:formResult.value] forKey:@"value"];
        }
        else {
            ERROR(@"processing formResult of type %@ is not yet implemented", [result class]);
            return;
        }
    }

    [self.store updateFormWithMessage:message
                             buttonId:buttonId
                    receivedTimestamp:receivedTimestamp
                       ackedTimestamp:ackedTimestamp];
}

- (MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormResponseTO *)SC_API_updateAutoCompleteFormWithRequest:(MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormRequestTO *)request
{
    T_BACKLOG();

    if (![[MCTComponentFramework brandingMgr] queueIfNeededWithFunction:@"com.mobicage.capi.messaging.updateAutoCompleteForm"
                                                             andRequest:request
                                                          andMessageKey:request.message_key]) {

        [self updateFormWithParentMessageKey:request.parent_message_key
                                  messageKey:request.message_key
                                      result:request.result
                                    buttonId:request.button_id
                           receivedTimestamp:request.received_timestamp
                              ackedTimestamp:request.acked_timestamp
                     customResultProcesssing:nil];
    }
    return [MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormResponseTO *)SC_API_updateMultiSelectFormWithRequest:(MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormRequestTO *)request
{
    T_BACKLOG();
    if (![[MCTComponentFramework brandingMgr] queueIfNeededWithFunction:@"com.mobicage.capi.messaging.updateMultiSelectForm"
                                                             andRequest:request
                                                          andMessageKey:request.message_key]) {

        [self updateFormWithParentMessageKey:request.parent_message_key
                                  messageKey:request.message_key
                                      result:request.result
                                    buttonId:request.button_id
                           receivedTimestamp:request.received_timestamp
                              ackedTimestamp:request.acked_timestamp
                     customResultProcesssing:nil];
    }
    return [MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormResponseTO *)SC_API_updateDateSelectFormWithRequest:(MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormRequestTO *)request
{
    T_BACKLOG();
    if (![[MCTComponentFramework brandingMgr] queueIfNeededWithFunction:@"com.mobicage.capi.messaging.updateDateSelectForm"
                                                             andRequest:request
                                                          andMessageKey:request.message_key]) {

        [self updateFormWithParentMessageKey:request.parent_message_key
                                  messageKey:request.message_key
                                      result:request.result
                                    buttonId:request.button_id
                           receivedTimestamp:request.received_timestamp
                              ackedTimestamp:request.acked_timestamp
                     customResultProcesssing:^(NSMutableDictionary *widget, id result) {
                         [widget setObject:[NSNumber numberWithBool:YES]
                                    forKey:@"has_date"];
                         [widget setObject:[NSNumber numberWithLongLong:request.result.value]
                                    forKey:@"date"];
                     }];
    }
    return [MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormResponseTO *)SC_API_updatePhotoUploadFormWithRequest:(MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormRequestTO *)request
{
    T_BACKLOG();
    if (![[MCTComponentFramework brandingMgr] queueIfNeededWithFunction:@"com.mobicage.capi.messaging.updatePhotoUploadForm"
                                                             andRequest:request
                                                          andMessageKey:request.message_key]) {

        [self updateFormWithParentMessageKey:request.parent_message_key
                                  messageKey:request.message_key
                                      result:request.result
                                    buttonId:request.button_id
                           receivedTimestamp:request.received_timestamp
                              ackedTimestamp:request.acked_timestamp
                     customResultProcesssing:nil];
    }
    return [MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormResponseTO transferObject];
}


- (MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormResponseTO *)SC_API_updateRangeSliderFormWithRequest:(MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormRequestTO *)request
{
    T_BACKLOG();
    if (![[MCTComponentFramework brandingMgr] queueIfNeededWithFunction:@"com.mobicage.capi.messaging.updateRangeSliderForm"
                                                             andRequest:request
                                                          andMessageKey:request.message_key]) {

        [self updateFormWithParentMessageKey:request.parent_message_key
                                  messageKey:request.message_key
                                      result:request.result
                                    buttonId:request.button_id
                           receivedTimestamp:request.received_timestamp
                              ackedTimestamp:request.acked_timestamp
                     customResultProcesssing:^(NSMutableDictionary *widget, id result) {
                         [widget setObject:[request.result.values objectAtIndex:0]
                                    forKey:@"low_value"];
                         [widget setObject:[request.result.values objectAtIndex:1]
                                    forKey:@"high_value"];
                     }];
    }
    return [MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormResponseTO *)SC_API_updateSingleSelectFormWithRequest:(MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormRequestTO *)request
{
    T_BACKLOG();
    if (![[MCTComponentFramework brandingMgr] queueIfNeededWithFunction:@"com.mobicage.capi.messaging.updateSingleSelectForm"
                                                             andRequest:request
                                                          andMessageKey:request.message_key]) {

        [self updateFormWithParentMessageKey:request.parent_message_key
                                  messageKey:request.message_key
                                      result:request.result
                                    buttonId:request.button_id
                           receivedTimestamp:request.received_timestamp
                              ackedTimestamp:request.acked_timestamp
                     customResultProcesssing:nil];
    }
    return [MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormResponseTO *)SC_API_updateSingleSliderFormWithRequest:(MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormRequestTO *)request
{
    T_BACKLOG();
    if (![[MCTComponentFramework brandingMgr] queueIfNeededWithFunction:@"com.mobicage.capi.messaging.updateSingleSliderForm"
                                                             andRequest:request
                                                          andMessageKey:request.message_key]) {

        [self updateFormWithParentMessageKey:request.parent_message_key
                                  messageKey:request.message_key
                                      result:request.result
                                    buttonId:request.button_id
                           receivedTimestamp:request.received_timestamp
                              ackedTimestamp:request.acked_timestamp
                     customResultProcesssing:nil];
    }
    return [MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormResponseTO *)SC_API_updateTextBlockFormWithRequest:(MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormRequestTO *)request
{
    T_BACKLOG();
    if (![[MCTComponentFramework brandingMgr] queueIfNeededWithFunction:@"com.mobicage.capi.messaging.updateTextBlockForm"
                                                             andRequest:request
                                                          andMessageKey:request.message_key]) {

        [self updateFormWithParentMessageKey:request.parent_message_key
                                  messageKey:request.message_key
                                      result:request.result
                                    buttonId:request.button_id
                           receivedTimestamp:request.received_timestamp
                              ackedTimestamp:request.acked_timestamp
                     customResultProcesssing:nil];
    }
    return [MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormResponseTO *)SC_API_updateTextLineFormWithRequest:(MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormRequestTO *)request
{
    T_BACKLOG();
    if (![[MCTComponentFramework brandingMgr] queueIfNeededWithFunction:@"com.mobicage.capi.messaging.updateTextLineForm"
                                                             andRequest:request
                                                          andMessageKey:request.message_key]) {

        [self updateFormWithParentMessageKey:request.parent_message_key
                                  messageKey:request.message_key
                                      result:request.result
                                    buttonId:request.button_id
                           receivedTimestamp:request.received_timestamp
                              ackedTimestamp:request.acked_timestamp
                     customResultProcesssing:nil];
    }
    return [MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormResponseTO *)SC_API_updateGPSLocationFormWithRequest:(MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormRequestTO *)request
{
    T_BACKLOG();
    if (![[MCTComponentFramework brandingMgr] queueIfNeededWithFunction:@"com.mobicage.capi.messaging.updateGPSLocationForm"
                                                             andRequest:request
                                                          andMessageKey:request.message_key]) {

        [self updateFormWithParentMessageKey:request.parent_message_key
                                  messageKey:request.message_key
                                      result:request.result
                                    buttonId:request.button_id
                           receivedTimestamp:request.received_timestamp
                              ackedTimestamp:request.acked_timestamp
                     customResultProcesssing:^(NSMutableDictionary *widget, id result) {
                         [widget setObject:[request.result dictRepresentation] forKey:@"value"];
                     }];
    }
    return [MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormResponseTO *)SC_API_updateMyDigiPassFormWithRequest:(MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormRequestTO *)request
{
    T_BACKLOG();
    if (![[MCTComponentFramework brandingMgr] queueIfNeededWithFunction:@"com.mobicage.capi.messaging.updateMyDigiPassForm"
                                                             andRequest:request
                                                          andMessageKey:request.message_key]) {

        [self updateFormWithParentMessageKey:request.parent_message_key
                                  messageKey:request.message_key
                                      result:request.result
                                    buttonId:request.button_id
                           receivedTimestamp:request.received_timestamp
                              ackedTimestamp:request.acked_timestamp
                     customResultProcesssing:^(NSMutableDictionary *widget, id result) {
                         [widget setObject:[request.result dictRepresentation] forKey:@"value"];
                     }];
    }
    return [MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormResponseTO transferObject];
}

- (MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormResponseTO *)SC_API_updateAdvancedOrderFormWithRequest:(MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormRequestTO *)request
{
    T_BACKLOG();
    if (![[MCTComponentFramework brandingMgr] queueIfNeededWithFunction:@"com.mobicage.capi.messaging.updateAdvancedOrderForm"
                                                             andRequest:request
                                                          andMessageKey:request.message_key]) {

        [self updateFormWithParentMessageKey:request.parent_message_key
                                  messageKey:request.message_key
                                      result:request.result
                                    buttonId:request.button_id
                           receivedTimestamp:request.received_timestamp
                              ackedTimestamp:request.acked_timestamp
                     customResultProcesssing:^(NSMutableDictionary *widget, id result) {
                         [widget setObject:[request.result dictRepresentation] forKey:@"value"];
                     }];
    }
    return [MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormResponseTO transferObject];
}

#pragma mark -
#pragma mark Submit Forms

- (void)submitTextLineForm:(MCTMessage *)message
                 withValue:(MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)formResult
                  buttonId:(NSString *)buttonId
{
    T_BIZZ();
    MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormRequestTO *request =
        [MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormRequestTO transferObject];
    request.message_key = message.key;
    request.parent_message_key = message.parent_key;
    request.button_id = buttonId;
    request.timestamp = [MCTUtils currentServerTime];

    if (formResult != MCTNull) {
        request.result = formResult;
    }

    if (message.isSentByJSMFR) {
        [self answerMessageSentJSMFR:message
                         withRequest:[request dictRepresentation]
                         andFunction:@"com.mobicage.api.messaging.submitTextLineForm"];
    } else {
        MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
        [MCT_com_mobicage_api_messaging CS_API_submitTextLineFormWithResponseHandler:rh andRequest:request];
    }

    [self.store submitFormWithMessage:message andButtonId:buttonId];
}

- (void)submitTextBlockForm:(MCTMessage *)message
                  withValue:(MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)formResult
                   buttonId:(NSString *)buttonId
{
    T_BIZZ();
    MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormRequestTO *request =
        [MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormRequestTO transferObject];
    request.message_key = message.key;
    request.parent_message_key = message.parent_key;
    request.button_id = buttonId;
    request.timestamp = [MCTUtils currentServerTime];

    if (formResult != MCTNull) {
        request.result = formResult;
    }

    if (message.isSentByJSMFR) {
        [self answerMessageSentJSMFR:message
                         withRequest:[request dictRepresentation]
                         andFunction:@"com.mobicage.api.messaging.submitTextBlockForm"];
    } else {
        MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
        [MCT_com_mobicage_api_messaging CS_API_submitTextBlockFormWithResponseHandler:rh andRequest:request];
    }

    [self.store submitFormWithMessage:message andButtonId:buttonId];
}

- (void)submitAutoCompleteForm:(MCTMessage *)message
                     withValue:(MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)formResult
                      buttonId:(NSString *)buttonId
{
    T_BIZZ();
    MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormRequestTO *request =
        [MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormRequestTO transferObject];
    request.message_key = message.key;
    request.parent_message_key = message.parent_key;
    request.button_id = buttonId;
    request.timestamp = [MCTUtils currentServerTime];

    if (formResult != MCTNull) {
        request.result = formResult;
    }

    if (message.isSentByJSMFR) {
        [self answerMessageSentJSMFR:message
                         withRequest:[request dictRepresentation]
                         andFunction:@"com.mobicage.api.messaging.submitAutoCompleteForm"];
    } else {
        MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
        [MCT_com_mobicage_api_messaging CS_API_submitAutoCompleteFormWithResponseHandler:rh andRequest:request];
    }

    [self.store submitFormWithMessage:message andButtonId:buttonId];
}

- (void)submitSingleSelectForm:(MCTMessage *)message
                     withValue:(MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)formResult
                      buttonId:(NSString *)buttonId
{
    T_BIZZ();
    MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormRequestTO *request =
        [MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormRequestTO transferObject];
    request.message_key = message.key;
    request.parent_message_key = message.parent_key;
    request.button_id = buttonId;
    request.timestamp = [MCTUtils currentServerTime];

    if (formResult != MCTNull) {
        request.result = formResult;
    }

    if (message.isSentByJSMFR) {
        [self answerMessageSentJSMFR:message
                         withRequest:[request dictRepresentation]
                         andFunction:@"com.mobicage.api.messaging.submitSingleSelectForm"];
    } else {
        MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
        [MCT_com_mobicage_api_messaging CS_API_submitSingleSelectFormWithResponseHandler:rh andRequest:request];
    }

    [self.store submitFormWithMessage:message andButtonId:buttonId];
}

- (void)submitMultiSelectForm:(MCTMessage *)message
                    withValue:(MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *)formResult
                     buttonId:(NSString *)buttonId
{
    T_BIZZ();
    MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormRequestTO *request =
        [MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormRequestTO transferObject];
    request.message_key = message.key;
    request.parent_message_key = message.parent_key;
    request.button_id = buttonId;
    request.timestamp = [MCTUtils currentServerTime];

    if (formResult != MCTNull) {
        request.result = formResult;
    }

    if (message.isSentByJSMFR) {
        [self answerMessageSentJSMFR:message
                         withRequest:[request dictRepresentation]
                         andFunction:@"com.mobicage.api.messaging.submitMultiSelectForm"];
    } else {
        MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
        [MCT_com_mobicage_api_messaging CS_API_submitMultiSelectFormWithResponseHandler:rh andRequest:request];
    }

    [self.store submitFormWithMessage:message andButtonId:buttonId];
}

- (void)submitDateSelectForm:(MCTMessage *)message
                   withValue:(MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *)formResult
                    buttonId:(NSString *)buttonId
{
    T_BIZZ();
    MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormRequestTO *request =
        [MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormRequestTO transferObject];
    request.message_key = message.key;
    request.parent_message_key = message.parent_key;
    request.button_id = buttonId;
    request.timestamp = [MCTUtils currentServerTime];

    if (formResult != MCTNull) {
        request.result = formResult;
    }

    if (message.isSentByJSMFR) {
        [self answerMessageSentJSMFR:message
                         withRequest:[request dictRepresentation]
                         andFunction:@"com.mobicage.api.messaging.submitDateSelectForm"];
    } else {
        MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
        [MCT_com_mobicage_api_messaging CS_API_submitDateSelectFormWithResponseHandler:rh andRequest:request];
    }

    [self.store submitFormWithMessage:message andButtonId:buttonId];
}

- (void)submitSingleSliderForm:(MCTMessage *)message
                     withValue:(MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *)formResult
                      buttonId:(NSString *)buttonId
{
    T_BIZZ();
    MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormRequestTO *request =
        [MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormRequestTO transferObject];
    request.message_key = message.key;
    request.parent_message_key = message.parent_key;
    request.button_id = buttonId;
    request.timestamp = [MCTUtils currentServerTime];

    if (formResult != MCTNull) {
        request.result = formResult;
    }

    if (message.isSentByJSMFR) {
        [self answerMessageSentJSMFR:message
                         withRequest:[request dictRepresentation]
                         andFunction:@"com.mobicage.api.messaging.submitSingleSliderForm"];
    } else {
        MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
        [MCT_com_mobicage_api_messaging CS_API_submitSingleSliderFormWithResponseHandler:rh andRequest:request];
    }

    [self.store submitFormWithMessage:message andButtonId:buttonId];
}

- (void)submitRangeSliderForm:(MCTMessage *)message
                    withValue:(MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *)formResult
                     buttonId:(NSString *)buttonId
{
    T_BIZZ();
    MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormRequestTO *request =
        [MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormRequestTO transferObject];
    request.message_key = message.key;
    request.parent_message_key = message.parent_key;
    request.button_id = buttonId;
    request.timestamp = [MCTUtils currentServerTime];

    if (formResult != MCTNull) {
        request.result = formResult;
    }

    if (message.isSentByJSMFR) {
        [self answerMessageSentJSMFR:message
                         withRequest:[request dictRepresentation]
                         andFunction:@"com.mobicage.api.messaging.submitRangeSliderForm"];
    } else {
        MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
        [MCT_com_mobicage_api_messaging CS_API_submitRangeSliderFormWithResponseHandler:rh andRequest:request];
    }

    [self.store submitFormWithMessage:message andButtonId:buttonId];
}

- (void)submitPhotoUploadForm:(MCTMessage *)message
                    withValue:(MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)formResult
                     buttonId:(NSString *)buttonId
{
    T_DONTCARE();
    MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormRequestTO *request =
        [MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormRequestTO transferObject];
    request.message_key = message.key;
    request.parent_message_key = message.parent_key;
    request.button_id = buttonId;
    request.timestamp = [MCTUtils currentServerTime];

    if (formResult != MCTNull) {
        request.result = formResult;
    }

    if (message.isSentByJSMFR) {
        [self answerMessageSentJSMFR:message
                         withRequest:[request dictRepresentation]
                         andFunction:@"com.mobicage.api.messaging.submitPhotoUploadForm"];
    } else {
        MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
        [MCT_com_mobicage_api_messaging CS_API_submitPhotoUploadFormWithResponseHandler:rh andRequest:request];
    }

    [self.store submitFormWithMessage:message andButtonId:buttonId];
}

- (void)startPhotoUploadWithForm:(MCTMessage *)message image:(UIImage *)image buttonId:(NSString *)buttonId
{
    T_BIZZ();
    HERE();
    if ([MCT_FORM_NEGATIVE isEqualToString:buttonId]) {
        [self submitPhotoUploadForm:message withValue:MCTNull buttonId:buttonId];
    } else {
        // First start upload, then submit the form (intent order must be like this!)
        [self uploadData:UIImageJPEGRepresentation(image, 0)
             withMessage:message
         contentType:MSG_ATTACHMENT_CONTENT_TYPE_IMG_JPG];
        [self.store submitFormWithMessage:message andButtonId:buttonId];
    }
}

- (void)submitGPSLocationForm:(MCTMessage *)message
                    withValue:(MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *)formResult
                     buttonId:(NSString *)buttonId
{
    T_BIZZ();
    MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormRequestTO *request =
    [MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormRequestTO transferObject];
    request.message_key = message.key;
    request.parent_message_key = message.parent_key;
    request.button_id = buttonId;
    request.timestamp = [MCTUtils currentServerTime];

    if (formResult != MCTNull) {
        request.result = formResult;
    }

    if (message.isSentByJSMFR) {
        [self answerMessageSentJSMFR:message
                         withRequest:[request dictRepresentation]
                         andFunction:@"com.mobicage.api.messaging.submitGPSLocationForm"];
    } else {
        MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
        [MCT_com_mobicage_api_messaging CS_API_submitGPSLocationFormWithResponseHandler:rh andRequest:request];
    }

    [self.store submitFormWithMessage:message andButtonId:buttonId];
}

- (void)submitMyDigiPassForm:(MCTMessage *)message
                   withValue:(MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *)formResult
                    buttonId:(NSString *)buttonId
{
    T_BIZZ();
    MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormRequestTO *request =
        [MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormRequestTO transferObject];
    request.message_key = message.key;
    request.parent_message_key = message.parent_key;
    request.button_id = buttonId;
    request.timestamp = [MCTUtils currentServerTime];

    if (formResult != MCTNull) {
        request.result = formResult;
    }

    if (message.isSentByJSMFR) {
        [self answerMessageSentJSMFR:message
                         withRequest:[request dictRepresentation]
                         andFunction:@"com.mobicage.api.messaging.submitMyDigiPassForm"];
    } else {
        MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
        [MCT_com_mobicage_api_messaging CS_API_submitMyDigiPassFormWithResponseHandler:rh andRequest:request];
    }

    [self.store submitFormWithMessage:message andButtonId:buttonId];
}

- (void)submitAdvancedOrderForm:(MCTMessage *)message
                      withValue:(MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *)formResult
                       buttonId:(NSString *)buttonId
{
    T_BIZZ();
    MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormRequestTO *request =
        [MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormRequestTO transferObject];
    request.message_key = message.key;
    request.parent_message_key = message.parent_key;
    request.button_id = buttonId;
    request.timestamp = [MCTUtils currentServerTime];

    if (formResult != MCTNull) {
        request.result = formResult;
    }

    if (message.isSentByJSMFR) {
        [self answerMessageSentJSMFR:message
                         withRequest:[request dictRepresentation]
                         andFunction:@"com.mobicage.api.messaging.submitAdvancedOrderForm"];
    } else {
        MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
        [MCT_com_mobicage_api_messaging CS_API_submitAdvancedOrderFormWithResponseHandler:rh andRequest:request];
    }

    [self.store submitFormWithMessage:message andButtonId:buttonId];
}

- (void)uploadData:(NSData *)originalData withMessage:(MCTMessage *)message contentType:(NSString *)contentType
{
    [self uploadData:originalData
      withMessageKey:message.key
    parentMessageKey:message.parent_key
             service:message.sender
         contentType:contentType];
}

- (void)uploadData:(NSData *)originalData
    withMessageKey:(NSString *)messageKey
  parentMessageKey:(NSString *)parentMessageKey
           service:(NSString *)service
      contentType:(NSString *)contentType

{
    T_BIZZ();
    // Split base64zipped data in chunks of max 90KB

    NSData *b64zippedData = [[[NSData gtm_dataByDeflatingData:originalData] MCTBase64Encode] dataUsingEncoding:NSUTF8StringEncoding];

    NSString *photoHash = [[originalData sha256Hash] uppercaseString];
    NSInteger length = [b64zippedData length];
    int MAX_CHUNK_SIZE = 90 * 1024;
    int offset = 0;
    int chunkNumber = 0;
    int totalChunks = ceil((double)length / MAX_CHUNK_SIZE);

    LOG(@"Total chunks: %d. Total data size for message %@: %d (b64zipped: %d)", totalChunks, messageKey,
        [originalData length], length);

    originalData = nil;

    MCTIntent *intent;
    if (![MCTUtils connectedToInternetAndXMPP]) {
        intent = [MCTIntent intentWithAction:kINTENT_UPLOAD_NOT_STARTED];
        [intent setString:NSLocalizedString(@"No network available", nil)
                   forKey:@"title"];
        [intent setString:NSLocalizedString(@"No network is available, the transfer will continue when connected to a network.", nil)
                   forKey:@"text"];
    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:MCT_SETTINGS_TRANSFER_WIFI_ONLY] && ![MCTUtils connectedToWifi]) {
        intent = [MCTIntent intentWithAction:kINTENT_UPLOAD_NOT_STARTED];
        [intent setString:NSLocalizedString(@"No WIFI available", nil)
                   forKey:@"title"];
        [intent setString:NSLocalizedString(@"No WIFI connection available, the transfer will continue when you connect to WIFI or change your settings so that transfers don't need to be transferred over WIFI.", nil)
                   forKey:@"text"];
    } else {
        // UI must show the 'Transferring' popup with spinner
        intent = [MCTIntent intentWithAction:kINTENT_UPLOADING_CHUNKS_STARTED];
        [intent setLong:totalChunks forKey:@"total_chunks"];
    }

    [intent setString:messageKey forKey:@"message_key"];
    [intent setString:parentMessageKey forKey:@"parent_message_key"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];

    do {
        NSInteger thisChunkSize = MIN(length - offset, MAX_CHUNK_SIZE);
        NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[b64zippedData bytes] + offset
                                             length:thisChunkSize
                                       freeWhenDone:NO];
        offset += thisChunkSize;

        MCT_com_mobicage_to_messaging_UploadChunkRequestTO * request =
            [MCT_com_mobicage_to_messaging_UploadChunkRequestTO transferObject];
        request.message_key = messageKey;
        request.parent_message_key = parentMessageKey;
        request.service_identity_user = service;
        request.number = ++chunkNumber;
        request.content_type = contentType;
        request.chunk = [NSString stringWithData:chunk encoding:NSUTF8StringEncoding];

        if (offset == length) {
            // This is the last chunk
            request.total_chunks = request.number;
            request.photo_hash = photoHash;
        } else {
            request.total_chunks = -1;
            request.photo_hash = nil;
        }

        LOG(@"Sending chunk %d with size %d", (int)request.number, thisChunkSize);

        MCTUploadChunkRH *rh = [MCTUploadChunkRH responseHandlerWithUploadChunkRequest:request];
        [MCT_com_mobicage_api_messaging CS_API_uploadChunkWithResponseHandler:rh andRequest:request];

    } while (offset < length);
}

#pragma mark -
#pragma mark Answering JSMFR messages

- (void)answerMessageSentJSMFR:(MCTMessage *)message
                   withRequest:(NSDictionary *)request
                   andFunction:(NSString *)function
{
    T_DONTCARE();
    MCTMessageFlowRun *mfr = [self.store messageFlowRunWithParentKey:[message threadKey]];
    NSDictionary *userInput = [NSDictionary dictionaryWithObjectsAndKeys:request, @"request", function, @"func", nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MCTComponentFramework menuViewController] executeMFR:mfr withUserInput:userInput throwIfNotReady:NO];
    });
}

- (void)logJSMFRError:(NSException *)exception
{
    MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorRequestTO *request = [MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorRequestTO transferObject];
    request.descriptionX = [exception name];
    request.platform = [MCTApplicationInfo type];
    request.platformVersion = [[UIDevice currentDevice] systemVersion];
    request.timestamp = [MCTUtils currentTimeMillis];
    request.mobicageVersion = [NSString stringWithFormat:@"%@%@", (MCT_DEBUG ? @"-" : @""), MCT_PRODUCT_VERSION];
    request.errorMessage = [exception reason];
    request.stackTrace = [[exception userInfo] objectForKey:@"err_stack"];
    request.jsCommand = [[exception userInfo] objectForKey:@"js_command"];

    MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
    [MCT_com_mobicage_api_messaging_jsmfr CS_API_messageFlowErrorWithResponseHandler:rh andRequest:request];
}

- (BOOL)validateFormMessage:(MCTMessage *)message withFormResult:(NSDictionary *)value
{
    T_DONTCARE();
    NSString *javascriptValidation = [message.form stringForKey:@"javascript_validation" withDefaultValue:nil];
    if ([MCTUtils isEmptyOrWhitespaceString:javascriptValidation]) {
        return NO;
    }

    return [[MCTComponentFramework menuViewController] executeJavascriptValidationForKey:message.key
                                                                               andJSCode:javascriptValidation
                                                                                andValue:value
                                                                                andEmail:message.sender];
}

#pragma mark -

- (void)addMessageWithNotification:(NSString *)messageKey
{
    T_BACKLOG();
    [self.messagesWithNotification addObject:messageKey];
    [self storeMessagesWithNotification];
}

- (void)removeMessageWithNotification:(NSString *)messageKey
{
    T_BACKLOG();
    [self.messagesWithNotification removeObject:messageKey];
    [self storeMessagesWithNotification];
}

- (void)storeMessagesWithNotification
{
    T_BACKLOG();
    [[MCTComponentFramework configProvider] setString:[self.messagesWithNotification MCT_JSONRepresentation]
                                               forKey:@"messagesWithNotification"];
}

- (void)newMessage:(MCTMessage *)message withBrandingOK:(BOOL)brandingOK
{
    T_BACKLOG();
    MCTBrandingMgr *brandingMgr = [MCTComponentFramework brandingMgr];
    if (message.parent_key && !brandingOK && ![brandingMgr isMessageInQueue:message.parent_key]) {
        // checking if thread exist
        MCTMessageExistence existence = [self.store existenceOfMessageWithKey:message.parent_key];
        if (existence == NSNotFound) {
            BOOL messageWasNotYetRequested = [self requestConversation:message.parent_key];
            if (messageWasNotYetRequested) {
                // already start downloading branding
                if (message.branding && ![brandingMgr isBrandingAvailable:message.branding]) {
                    [brandingMgr queueGenericBranding:message.branding];
                }
            }
            return;
        } else if (existence == MCTMessageExistenceDeleted) {
            [self.store restoreConversationWithKey:message.parent_key];
        }
    }

    if ([message.attachments count]
        && [[[MCTComponentFramework friendsPlugin] store] friendTypeByEmail:message.sender] != MCTFriendTypeService) {

        for (MCT_com_mobicage_to_messaging_AttachmentTO *attachment in message.attachments) {
            [brandingMgr queueAttachment:attachment.download_url
                              forMessage:message.key
                           withThreadKey:message.threadKey
                             contentType:attachment.content_type];
        }
    }

    MCTMessageExistence existence = [self.store existenceOfMessageWithKey:message.key];
    if (existence == MCTMessageExistenceActive) {
        ERROR(@"Message %@ already exist in the database!", message.key);
        return;
    }

    if (!brandingOK) {
        if ((![MCTUtils isEmptyOrWhitespaceString:message.branding] && ![[MCTComponentFramework brandingMgr] isBrandingAvailable:message.branding])
            || (message.parent_key != nil && [brandingMgr isMessageInQueue:message.parent_key])) {

            // Branding of message is not yet downloaded, or the parent message is in the branding queue
            [brandingMgr queueMessage:message];
            return;
        }
    }

    BOOL sentFromOtherDevice = [message.sender isEqualToString:[self.store myEmail]];
    [self.store saveMessage:message withSentByMeFromOtherDevice:sentFromOtherDevice];

    if (MCT_USE_XMPP_KICK_CHANNEL || [self.messagesWithNotification containsObject:message.key]) {
        if (!IS_FLAG_SET(message.alert_flags, MCTAlertFlagSilent)) {
            UILocalNotification *ln = [[UILocalNotification alloc] init];
            NSString *messageContent;
            if (message.parent_key == nil && IS_FLAG_SET(message.flags, MCTMessageFlagDynamicChat)) {
                NSDictionary *chatData = [message.message MCT_JSONValue];
                messageContent = chatData[@"t"];
            } else {
                messageContent = message.message;
            }

            NSString *senderName = [[MCTComponentFramework friendsPlugin] friendDisplayNameByEmail:message.sender];
            ln.alertBody = [NSString stringWithFormat:NSLocalizedString(@"NM", nil), senderName, messageContent];
            ln.soundName = UILocalNotificationDefaultSoundName;
            ln.userInfo = @{@"n": message.key};
            [[UIApplication sharedApplication] presentLocalNotificationNow:ln];
        }

        if (!MCT_USE_XMPP_KICK_CHANNEL)
            [self removeMessageWithNotification:message.key];
    }

    // Clean up if this is a conversation which was requested
    if (message.parent_key == nil) {
        [self.store deleteRequestedConversationWithKey:[message threadKey]];
    }

    [self.activityFactory newMessage:message];

    if (message.alert_flags >= MCTAlertFlagRing5 && message.context == nil) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_CHANGE_TAB];
        [intent setLong:MCT_MENU_TAB_MESSAGES forKey:@"tab"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    }
}

- (BOOL)updateMessageWithRequest:(MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *)request
{
    T_BACKLOG();
    BOOL messageExisted = [self.store updateMessageMemberStatus:request];

    if (messageExisted) {
        if (request.button_id && [[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground) {
            MCTMessage *msg = [self.store messageDetailsByKey:request.message];

            if ([msg.sender isEqualToString:[self.store myEmail]] || [msg.sender isEqualToString:request.member]) {
                [MCTUtils playNotificationSound];
            }
        }

        if (IS_FLAG_SET(request.status, MCTMessageStatusAcked)) {
            [self.activityFactory statusUpdateWithMessage:request.message
                                                andMember:request.member
                                                andButton:request.button_id];
        }
    } else {
        [self requestConversation:OR(request.parent_message, request.message)];
    }

    return messageExisted;
}

- (NSArray *)changedAnswersDuringLockMessage:(MCTMessage *)oldMessage andMembers:(NSArray *)newMembers
{
    T_DONTCARE();
    NSMutableArray *changedAnswers = [NSMutableArray array];

    if (newMembers == nil || [newMembers count] == 0)
        return changedAnswers;

    for (MCT_com_mobicage_to_messaging_MemberStatusTO *newMember in newMembers) {
        NSString *oldQR = [[oldMessage memberWithEmail:newMember.member] button_id];
        NSString *newQR = newMember.button_id;

        if (!((oldQR == nil && newQR == nil) || (oldQR != nil && [oldQR isEqualToString:newQR]))) {
            [changedAnswers addObject:newMember];
        }
    }

    return changedAnswers;
}

- (BOOL)messageLockedWithParentKey:(NSString *)parentKey
                            andKey:(NSString *)key
                        andMembers:(NSArray *)members
                  andDirtyBehavior:(MCTDirtyBehavior)dirtyBehavior
{
    T_DONTCARE();
    MCTMessage *message = [self.store messageDetailsByKey:key];

    if (message == nil) {
        [self requestConversation:OR(parentKey, key)];
        return NO;
    }

    NSArray *changedAnswers = [self changedAnswersDuringLockMessage:message andMembers:members];
    if (dirtyBehavior == MCTDirtyBehaviorNormal && [changedAnswers count] != 0)
        dirtyBehavior = MCTDirtyBehaviorMakeDirty;

    BOOL updated = [self.store lockMessageWithKey:key andMembers:members andDirtyBehavior:dirtyBehavior andFlags:message.flags];
    if (updated) {
        [self.activityFactory lockedMessageWithKey:key];

        for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in changedAnswers) {
            [[self activityFactory] quickReplyUndoneDuringLockMessage:message
                                            withNewMemberStatusUpdate:member];
        }
    }
    return updated;
}

- (void)lockMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message
{
    T_BIZZ();
    MCT_com_mobicage_to_messaging_LockMessageRequestTO *request = [MCT_com_mobicage_to_messaging_LockMessageRequestTO transferObject];
    request.message_key = message.key;
    request.message_parent_key = message.parent_key;

    MCTLockMessageResponseHandler *rh = [MCTLockMessageResponseHandler responseHandlerWithParentMsgKey:message.parent_key
                                                                                             andMsgKey:message.key];
    [MCT_com_mobicage_api_messaging CS_API_lockMessageWithResponseHandler:rh andRequest:request];

    [self.store lockMessageWithKey:request.message_key andMembers:nil andDirtyBehavior:MCTDirtyBehaviorClearDirty andFlags:message.flags];
}

- (void)dismissMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message
{
    T_BIZZ();
    [self ackMessage:message withButton:nil];
}

- (void)ackMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message
        withButton:(MCT_com_mobicage_to_messaging_ButtonTO *)btn
{
    T_BIZZ();
    [self ackMessage:message withButton:btn andCustomReply:nil andIsInBulk:NO];
}

- (void)ackMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message
        withButton:(MCT_com_mobicage_to_messaging_ButtonTO *)btn
    andCustomReply:(NSString *)customReply
       andIsInBulk:(BOOL)inBulk
{
    T_BIZZ();

    MCT_com_mobicage_to_messaging_AckMessageRequestTO *request = [MCT_com_mobicage_to_messaging_AckMessageRequestTO transferObject];
    request.button_id = btn.idX;
    request.custom_reply = customReply;
    request.message_key = message.key;
    request.parent_message_key = message.parent_key;
    request.timestamp = [MCTUtils currentServerTime];

    if (message.isSentByJSMFR) {
        [self answerMessageSentJSMFR:[MCTMessage messageWithMessageTO:message]
                         withRequest:[request dictRepresentation]
                         andFunction:@"com.mobicage.api.messaging.ackMessage"];
    } else {
        MCTAckMessageResponseHandler *handler = [MCTAckMessageResponseHandler responseHandlerWithMessageKey:request.message_key
                                                                                             andMemberEmail:[self.store myEmail]
                                                                                                andButtonId:request.button_id];
        [MCT_com_mobicage_api_messaging CS_API_ackMessageWithResponseHandler:handler andRequest:request];
    }

    [self.store ackMessage:message withButtonId:btn.idX andCustomReply:customReply andIsInBulk:inBulk];
}

- (void)ackThreadWithKey:(NSString *)threadKey
{
    T_BIZZ();
    NSMutableArray *messageKeys = [NSMutableArray array];
    for (MCTMessage *message in [self.store messagesInThreadThatNeedsMyAnswer:threadKey]) {
        [messageKeys addObject:message.key];
        [self ackMessage:message withButton:nil andCustomReply:nil andIsInBulk:YES];
    }

    if ([messageKeys count]) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_THREAD_ACKED];
        [intent setString:threadKey forKey:@"thread_key"];
        [intent setString:[messageKeys MCT_JSONRepresentation] forKey:@"message_keys"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    }
}

- (void)ackChatWithKey:(NSString *)threadKey
{
    T_BIZZ();
    NSMutableArray *messageKeys = [NSMutableArray array];
    for (MCTMessage *message in [self.store messagesInThreadThatNeedsMyAnswer:threadKey]) {
        [messageKeys addObject:message.key];
        [self.store operationAckChat:message];
    }

    if ([messageKeys count]) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_THREAD_ACKED];
        [intent setString:threadKey forKey:@"thread_key"];
        [intent setString:[messageKeys MCT_JSONRepresentation] forKey:@"message_keys"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    }
}

- (void)markAsReadWithParentKey:(NSString *)parentKey andMessageKeys:(NSArray *)messageKeys
{
    T_BIZZ();
    MCT_com_mobicage_to_messaging_MarkMessagesAsReadRequestTO *req = [MCT_com_mobicage_to_messaging_MarkMessagesAsReadRequestTO transferObject];
    req.parent_message_key = parentKey;
    req.message_keys = messageKeys;

    MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
    [MCT_com_mobicage_api_messaging CS_API_markMessagesAsReadWithResponseHandler:rh andRequest:req];
}

- (BOOL)messageAckedByMe:(MCT_com_mobicage_to_messaging_MessageTO *)message
{
    T_UI();
    NSString *myEmail = [self.store myEmail];
    if ([message.sender isEqualToString:myEmail])
        return YES;

    NSArray *members = message.members;
    if (members == nil || [members count] == 0)
        members = [self.store memberStatusesWithMessageKey:message.key];

    for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in members)
        if ([myEmail isEqualToString:member.member])
            return IS_FLAG_SET(member.status, MCTMessageStatusAcked);

    ERROR(@"I, %@, am not in the member list of message %@ with members %@", myEmail, message, members);
    return NO;
}

- (void)deleteConversations:(NSArray *)threadKeys
{
    T_BIZZ();
    for (NSString *threadKey in threadKeys) {
        MCT_com_mobicage_to_messaging_DeleteConversationRequestTO *request =
            [MCT_com_mobicage_to_messaging_DeleteConversationRequestTO transferObject];
        request.parent_message_key = threadKey;

        MCTMessage *msg = [self.store messageInfoByKey:threadKey];
        if ([msg isSentByJSMFR] && [msg numAcked] == 0) {
            // Message is not yet sent to the server
        } else {
            MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
            [MCT_com_mobicage_api_messaging CS_API_deleteConversationWithResponseHandler:rh andRequest:request];
        }

        [self.store deleteConversationWithKey:threadKey];
        [self removeAttachmentsWithThreadKey:threadKey];
        [[[MCTComponentFramework activityPlugin] store] deletedActivityByReference:request.parent_message_key];
        [[MCTComponentFramework brandingMgr] cleanupLocalFlowCacheDirWithThreadKey:request.parent_message_key];
    }
}

- (BOOL)requestConversation:(NSString *)threadKey
{
    T_DONTCARE();
    return [self requestConversation:threadKey withOffset:nil];
}

- (BOOL)requestConversation:(NSString *)threadKey withOffset:(NSString *)offset
{
    T_DONTCARE();
    if ([self.store isConversationAlreadyRequestedWithKey:threadKey]) {
        LOG(@"Thread %@ is already requested", threadKey);
        return NO;
    }

    MCT_com_mobicage_to_messaging_GetConversationRequestTO *request =
        [MCT_com_mobicage_to_messaging_GetConversationRequestTO transferObject];
    request.parent_message_key = threadKey;
    request.offset = offset;

    MCTGetConversationRH *rh = [MCTGetConversationRH responseHandlerWithThreadKey:threadKey];
    [MCT_com_mobicage_api_messaging CS_API_getConversationWithResponseHandler:rh andRequest:request];

    [self.store addRequestedConversationWithKey:threadKey];
    return YES;
}

- (void)sendMessageWithRequest:(MCTSendMessageRequest *)request
{
    T_BIZZ();
    [self sendMessageWithRequest:request andAttachmentsUploaded:NO];
}

- (void)sendMessageWithRequest:(MCTSendMessageRequest *)request
        andAttachmentsUploaded:(BOOL)attachmentsUploaded
{
    T_BIZZ();
    if (!attachmentsUploaded && request.attachmentHash != nil) {
        // 1. save request in configProvider
        [[MCTComponentFramework configProvider] setString:[[request dictRepresentation] MCT_JSONRepresentation]
                                                   forKey:[NSString stringWithFormat:@"sendMessage_%@", request.tmpKey]];
        // 2. start uploading the chunks
        NSString *attachmentsDir = [self attachmentsDirWithSendMessageRequest:request];
        [self uploadData:[NSData dataWithContentsOfFile:[attachmentsDir stringByAppendingPathComponent:request.attachmentHash]]
          withMessageKey:request.tmpKey
        parentMessageKey:request.parent_key
                 service:nil
             contentType:request.attachmentContentType];

        // when all chunks are uploaded, the AttachmentTO will be created in the request
        // and sendMessageWithRequest: will be invoked again
    }

    NSString *me = [self.store myEmail];

    if (request.parent_key == nil && ![request.members containsObject:me]) {
        NSMutableArray *members = [NSMutableArray arrayWithArray:request.members];
        [members addObject:me];
        request.members = members;
    }

    if (request.attachmentHash == nil || attachmentsUploaded) {
        // Send the message to the server when there are no attachments, or all attachments are uploaded
        MCTSendMessageResponseHandler *rh = [MCTSendMessageResponseHandler responseHandlerWithTmpKey:request.tmpKey
                                                                                           parentKey:request.parent_key
                                                                                 attachmentsUploaded:attachmentsUploaded];
        MCT_com_mobicage_to_messaging_SendMessageRequestTO *r =
            [MCT_com_mobicage_to_messaging_SendMessageRequestTO transferObjectWithDict:[request dictRepresentation]];
        [MCT_com_mobicage_api_messaging CS_API_sendMessageWithResponseHandler:rh
                                                                   andRequest:r];
    }

    if (!attachmentsUploaded) {
        // This is the first time we are in this function. Store tmp message in DB.
        MCTMessage *msg = [MCTMessage message];
        msg.key = request.tmpKey;
        msg.sender = me;
        msg.flags = request.flags;
        msg.timeout = request.timeout;
        msg.timestamp = [MCTUtils currentServerTime];
        msg.parent_key = request.parent_key;
        msg.message = request.message;
        msg.buttons = request.buttons;
        msg.priority = request.priority;

        if (![MCTUtils isEmptyOrWhitespaceString:request.parent_key]) {
            MCTMessage *parentMessage = [self.store messageInfoByKey:request.parent_key];
            msg.thread_avatar_hash = parentMessage.thread_avatar_hash;
            msg.thread_background_color = parentMessage.thread_background_color;
            msg.thread_text_color = parentMessage.thread_text_color;
        }

        NSMutableArray *members = [NSMutableArray arrayWithCapacity:[request.members count]];

        for (NSString *email in request.members) {
            MCT_com_mobicage_to_messaging_MemberStatusTO *member = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObject];
            if ([email isEqualToString:me]) {
                member.status = MCTMessageStatusReceived;
                member.status |= (request.sender_reply == nil) ? MCTMessageStatusNew : MCTMessageStatusAcked;
                member.received_timestamp = msg.timestamp;
                member.acked_timestamp = (request.sender_reply == nil) ? 0 : msg.timestamp;
                member.button_id = request.sender_reply;
            } else {
                member.status = MCTMessageStatusNew;
                member.received_timestamp = 0;
                member.acked_timestamp = 0;
                member.button_id = nil;
            }
            member.member = email;
            member.custom_reply = nil;
            [members addObject:member];
        }
        msg.members = members;
        
        [self.store saveMessage:msg withSentByMeFromOtherDevice:NO];
    } else {
        // Message is already in db. We must add the attachments.
        [self.store insertAttachments:request.attachments forMessage:request.tmpKey];
    }
}

- (void)replaceTmpKey:(NSString *)tmpKey
              withKey:(NSString *)key
         andParentKey:(NSString *)parentKey
         andTimestamp:(MCTlong)timestamp
{
    T_BIZZ();
    [self.store replaceTmpKey:tmpKey withKey:key andTimestamp:timestamp];
}

- (BOOL)isTmpKey:(NSString *)key
{
    T_DONTCARE();
    return [key hasPrefix:MCT_MESSAGE_TMP_KEY_PREFIX];
}

- (void)messageFailed:(NSString *)key
{
    T_BIZZ();
    [self.store messageFailed:key];
}

- (void)messageNotDirty:(NSString *)key
{
    T_BIZZ();
    [self.store setMessageIsDirty:NO withKey:key];
}

- (NSString *)myAnswerTextWithMessage:(MCTMessage *)message
{
    T_DONTCARE();
    MCT_com_mobicage_to_messaging_MemberStatusTO *me = [message memberWithEmail:self.store.myEmail];
    if (me && IS_FLAG_SET(me.status, MCTMessageStatusAcked)) {
        if (me.button_id)
            return [message buttonWithId:me.button_id].caption;

        return NSLocalizedString(@"Roger that", nil);
    }

    return nil;
}

- (UIImage *)threadAvatarWithHash:(NSString *)threadAvatarHash
{
    T_UI();
    NSData *data = [self.store threadAvatarWithHash:threadAvatarHash];
    if (data == nil) {
        return nil;
    }

    return [UIImage imageWithData:data];
}

- (void)requestAvatarWithHash:(NSString *)threadAvatarHash
                    threadKey:(NSString *)threadKey
{
    T_BIZZ();
    MCT_com_mobicage_to_messaging_GetConversationAvatarRequestTO *request =
        [MCT_com_mobicage_to_messaging_GetConversationAvatarRequestTO transferObject];
    request.avatar_hash = threadAvatarHash;
    request.thread_key = threadKey;

    MCTGetConversationAvatarRH *rh = [MCTGetConversationAvatarRH responseHandlerWithAvatarHash:threadAvatarHash];

    [MCT_com_mobicage_api_messaging CS_API_getConversationAvatarWithResponseHandler:rh
                                                                         andRequest:request];
}

#pragma mark - attachments

- (NSString *)attachmentsDirWithThreadKey:(NSString *)threadKey
{
    return [[[MCTUtils documentsFolder]
             stringByAppendingPathComponent:@"attachments"]
            stringByAppendingPathComponent:threadKey];
}

- (NSString *)attachmentsDirWithMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message;
{
    return [[self attachmentsDirWithThreadKey:message.threadKey] stringByAppendingPathComponent:message.key];
}

- (NSString *)attachmentsDirWithSendMessageRequest:(MCTSendMessageRequest *)request
{
    return [[self attachmentsDirWithThreadKey:request.threadKey] stringByAppendingPathComponent:request.tmpKey];
}

- (NSString *)attachmentsFileWithSendMessageRequest:(MCTSendMessageRequest *)request
{
    return [[self attachmentsDirWithSendMessageRequest:request] stringByAppendingPathComponent:request.attachmentHash];
}

- (MCTMessageAttachmentPreviewItem *)previewItemForAttachmentWithName:(NSString *)name
                                                          downloadURL:(NSString *)downloadURL
                                                          contentType:(NSString *)contentType
                                                            threadKey:(NSString *)threadKey
                                                           messageKey:(NSString *)messageKey
{
    MCTMessageAttachmentPreviewItem *previewItem = [[MCTMessageAttachmentPreviewItem alloc] init];
    previewItem.itemTitle = name;
    previewItem.itemDir = [[self attachmentsDirWithThreadKey:threadKey] stringByAppendingPathComponent:messageKey];
    NSString *fileExtension = [[NSURL URLWithString:downloadURL] pathExtension];
    if ([MCTUtils isEmptyOrWhitespaceString:fileExtension]) {
        fileExtension = [MCTUtils fileExtensionWithMimeType:contentType];
    }
    previewItem.itemPath = [[previewItem.itemDir stringByAppendingPathComponent:[downloadURL sha256Hash]]
                            stringByAppendingPathExtension:fileExtension];
    return previewItem;
}

- (void)removeAttachmentsWithThreadKey:(NSString *)threadKey
{
    NSString *dir = [self attachmentsDirWithThreadKey:threadKey];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:dir]) {
        [fileMgr removeItemAtPath:dir error:nil];
    }
}

@end