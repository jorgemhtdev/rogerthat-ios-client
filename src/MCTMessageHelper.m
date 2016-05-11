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
#import "MCTFormView.h"
#import "MCTFriendDetailOrInviteVC.h"
#import "MCTFriendDetailVC.h"
#import "MCTHumanThreadVC.h"
#import "MCTMemberStatusSummaryEncoding.h"
#import "MCTMessageDetailVC.h"
#import "MCTMessageHelper.h"
#import "MCTNewMessageVC.h"
#import "MCTOperation.h"
#import "MCTProfileVC.h"
#import "MCTSendMessageRequest.h"
#import "MCTServiceMenuVC.h"
#import "MCTServiceMessageThreadVC.h"
#import "MCTTransferObjects.h"
#import "MCTUINavigationController.h"
#import "MCTUIUtils.h"
#import "MCTTermsOfServiceVC.h"

#define MCT_BTN_ACTION_PREFIX_CONFIRM   @"confirm://"
#define MCT_BTN_ACTION_PREFIX_TEL       @"tel://"
#define MCT_BTN_ACTION_PREFIX_GEO       @"geo://"
#define MCT_BTN_ACTION_PREFIX_HTTP      @"http://"
#define MCT_BTN_ACTION_PREFIX_HTTPS     @"https://"
#define MCT_BTN_ACTION_PREFIX_MAILTO    @"mailto://"

#define MCT_EXTERNAL_APP_ACTIONS [NSArray arrayWithObjects:MCT_BTN_ACTION_PREFIX_GEO, MCT_BTN_ACTION_PREFIX_HTTP, \
                                  MCT_BTN_ACTION_PREFIX_HTTPS, MCT_BTN_ACTION_PREFIX_MAILTO, MCT_BTN_ACTION_PREFIX_TEL, \
                                  nil]

@interface MCTMessageHelper ()

+ (BOOL)isMyAnswer:(MCT_com_mobicage_to_messaging_ButtonTO *)btn forMessage:(MCTMessage *)message;
+ (void)ackMessage:(MCTMessage *)message withButton:(MCT_com_mobicage_to_messaging_ButtonTO *)btn;

+ (NSString *)hintConfigkeyForTag:(NSInteger)tag;
+ (BOOL)showHintWithTag:(NSInteger)tag
             andMessage:(NSString *)hintMessage
                   inVC:(UIViewController<MCTUIViewControllerProtocol> *)vc;

@end


@implementation MCTMessageHelper

+ (BOOL)willOpenExternalAppForButtonWithAction:(NSString *)action
{
    T_UI();
    if ([MCTUtils isEmptyOrWhitespaceString:action])
        return NO;

    for (NSString *prefix in MCT_EXTERNAL_APP_ACTIONS) {
        if ([action hasPrefix:prefix])
            return YES;
    }

    return NO;
}

+ (BOOL)canLockForMessage:(MCTMessage *)message
{
    T_UI();
    if (IS_FLAG_SET(message.flags, MCTMessageFlagDynamicChat))
        return NO;

    if (![[MCTComponentFramework friendsPlugin] isMyEmail:message.sender])
        return NO;

    if ([message isLocked])
        return NO;

    if ([[MCTComponentFramework messagesPlugin] isTmpKey:message.key])
         return NO;

     return YES;
}

+ (BOOL)isMyAnswer:(MCT_com_mobicage_to_messaging_ButtonTO *)btn forMessage:(MCTMessage *)message
{
    T_UI();
    NSString *myEmail = [[MCTComponentFramework friendsPlugin] myEmail];
    MCT_com_mobicage_to_messaging_MemberStatusTO *myStatus = [message memberWithEmail:myEmail];
    if (myStatus && (myStatus.status & MCTMessageStatusAcked) == MCTMessageStatusAcked)
        return btn.idX == myStatus.button_id || [btn.idX isEqualToString:myStatus.button_id];

    return NO;
}

+ (BOOL)shouldDisableButton:(MCT_com_mobicage_to_messaging_ButtonTO *)btn forMessage:(MCTMessage *)message withSenderIsService:(BOOL)senderIsService
{
    T_UI();

    if (message.isLocked)
        return YES;

    if (senderIsService && (btn.action == nil || [btn.action hasPrefix:MCT_BTN_ACTION_PREFIX_CONFIRM]) && [MCTMessageHelper isMyAnswer:btn forMessage:message])
        return YES;

    if ([[MCTComponentFramework friendsPlugin] isMyEmail:message.sender]) {
        if (btn.idX == nil && [message.buttons count] == 0)
            return YES;

        if (message.recipientsStatus == kMemberStatusSummaryError)
            return YES;

        if ([[MCTComponentFramework messagesPlugin] isTmpKey:message.key])
            return YES;
    }

    return NO;
}

+ (void)ackMessage:(MCTMessage *)message withButton:(MCT_com_mobicage_to_messaging_ButtonTO *)btn
{
    T_UI();
    NSString * myEmail = [[MCTComponentFramework friendsPlugin] myEmail];
    MCT_com_mobicage_to_messaging_MemberStatusTO *myMember = [message memberWithEmail:myEmail];
    if (IS_FLAG_SET(message.flags, MCTMessageFlagDynamicChat) && IS_FLAG_SET(message.flags, MCTMessageFlagAllowChatButtons)) {
        if (myMember == nil) {
            myMember = [[MCT_com_mobicage_to_messaging_MemberStatusTO alloc] init];
            myMember.acked_timestamp = 0;
            myMember.button_id = nil;
            myMember.custom_reply = nil;
            myMember.member = myEmail;
            myMember.received_timestamp = 0;
            myMember.status = 0;

            NSMutableArray *members = [NSMutableArray arrayWithArray:message.members];
            [members addObject:myMember];
            message.members = members;
        }
    }
    myMember.status |= MCTMessageStatusAcked;
    myMember.button_id = btn.idX;
    if (IS_FLAG_SET(message.flags, MCTMessageFlagAutoLock))
        message.flags |= MCTMessageFlagLocked;

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        [[MCTComponentFramework messagesPlugin] ackMessage:message withButton:btn];
    }];
}

+ (void)onDismissButtonClickedForMessage:(MCTMessage *)message;
{
    T_UI();
    [MCTMessageHelper ackMessage:message withButton:nil];
}

+ (void)onMagicButtonClicked:(MCT_com_mobicage_to_messaging_ButtonTO *)btn
                  forMessage:(MCTMessage *)message
                       forVC:(id<MCTUIViewControllerProtocol, UIAlertViewDelegate>)vc
{
    T_UI();
    // tel:// button is can be clicked multiple times, even if it's the recipient's answer
    if (btn.action != nil && [btn.action hasPrefix:MCT_BTN_ACTION_PREFIX_TEL]) {
        NSString *phoneNumber = [btn.action substringFromIndex:[MCT_BTN_ACTION_PREFIX_TEL length]];

        vc.currentAlertView = [MCTUIUtils showAlertViewForPhoneNumber:phoneNumber withDelegate:vc andTag:[message.buttons indexOfObject:btn]];
        vc.activeObject = message;
        return;
    }

    if (btn.action == nil && [MCTMessageHelper isMyAnswer:btn forMessage:message]) {
        // Re-clicked button --> unselect
        [MCTMessageHelper onDismissButtonClickedForMessage:message];
    } else {
        // confirm:// button can not be clicked again if it's the recipient's answer
        if (btn.action != nil && [btn.action hasPrefix:MCT_BTN_ACTION_PREFIX_CONFIRM]) {
            NSString *msg = [btn.action substringFromIndex:[MCT_BTN_ACTION_PREFIX_CONFIRM length]];
            vc.currentAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please confirm", nil)
                                                              message:msg
                                                             delegate:vc
                                                    cancelButtonTitle:NSLocalizedString(@"No", nil)
                                                    otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
            vc.currentAlertView.tag = [message.buttons indexOfObject:btn];
            [vc.currentAlertView show];
            vc.activeObject = message;
            return;
        }
        else {
            [MCTMessageHelper ackMessage:message withButton:btn];
        }

        if (btn.action != nil) {
            if ([btn.action hasPrefix:MCT_BTN_ACTION_PREFIX_HTTP] || [btn.action hasPrefix:MCT_BTN_ACTION_PREFIX_HTTPS]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:btn.action]];
            } else if ([btn.action hasPrefix:MCT_BTN_ACTION_PREFIX_GEO]) {
                NSString *s = @"google";
                IF_IOS6_OR_GREATER({
                    s = @"apple";
                });
                NSString *geoPoint = [[btn.action substringFromIndex:[MCT_BTN_ACTION_PREFIX_GEO length]]
                                      stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *url = [NSString stringWithFormat:@"http://maps.%@.com/maps?q=%@&num=1&t=m&z=14", s, geoPoint];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            } else if ([btn.action hasPrefix:MCT_BTN_ACTION_PREFIX_MAILTO]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:btn.action]];
            }
        }
    }
}

+ (void)onDismissThreadClickedForMessage:(MCTMessage *)message
{
    T_UI();
    NSString *pkey = [message threadKey];
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        [[MCTComponentFramework messagesPlugin] ackThreadWithKey:pkey];
    }];
}

+ (void)onParticipantClicked:(NSString *)email inNavigationController:(UINavigationController *)navigationController
{
    T_UI();
    if (navigationController == nil) {
        ERROR(@"Set navigationController property first!");
        return;
    }

    UIViewController *viewController = nil;
    if ([[MCTComponentFramework friendsPlugin] isMyEmail:email]) {
        viewController = [MCTProfileVC viewController];
    } else if (![email isEqual:MCT_SYSTEM_FRIEND_EMAIL]) {
        MCTFriend *friend = [[[MCTComponentFramework friendsPlugin] store] friendByEmail:email];
        if (friend == nil) {
            friend = [MCTFriend aFriend];
            friend.email = email;
            friend.existence = -1;

            viewController = [MCTFriendDetailOrInviteVC viewControllerWithFriend:friend];
        } else if (friend.type == MCTFriendTypeService) {
            viewController = [MCTServiceMenuVC viewControllerWithService:friend];
        } else {
            viewController = [MCTFriendDetailOrInviteVC viewControllerWithFriend:friend];
        }
    }

    if (viewController) {
        [navigationController pushViewController:viewController animated:YES];
    }
}

+ (void)onReplyClickedForMessage:(MCTMessage *)message inNavigationController:(UINavigationController *)navigationController
{
    T_UI();
    if (navigationController == nil) {
        ERROR(@"Set navigationController property first!");
        return;
    }

    NSMutableArray *memberEmails = [NSMutableArray arrayWithCapacity:[message.members count]];
    for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in message.members) {
        [memberEmails addObject:member.member];
    }
    MCTSendMessageRequest *request = [MCTSendMessageRequest request];
    request.members = memberEmails;
    request.parent_key = [message threadKey];
    // The following flags need to be copied from the parent message. The other (default) flags are set by newMessageVC.
    request.flags = 0;
    request.flags |= message.flags & MCTMessageFlagDynamicChat;
    request.flags |= message.flags & MCTMessageFlagNotRemovable;
    request.flags |= message.flags & MCTMessageFlagAllowChatButtons;
    request.flags |= message.flags & MCTMessageFlagAllowChatPicture;
    request.flags |= message.flags & MCTMessageFlagAllowChatVideo;
    request.flags |= message.flags & MCTMessageFlagAllowChatPriority;
    request.flags |= message.flags & MCTMessageFlagAllowChatSticky;

    request.priority = message.default_priority;
    if (message.default_sticky) {
        request.flags |= MCTMessageFlagChatSticky;
    }

    UIViewController *vc = [MCTMessageHelper composeMessageViewControllerWithRequest:request
                                                                   andReplyOnMessage:message];
    [navigationController presentViewController:vc animated:YES completion:nil];
}

+ (void)onLockClickedForMessage:(MCTMessage *)message
{
    T_UI();
    if ([[MCTComponentFramework messagesPlugin] isTmpKey:message.key])
        return;

    [[MCTComponentFramework workQueue]
     addOperation:[MCTInvocationOperation operationWithTarget:[MCTComponentFramework messagesPlugin]
                                                     selector:@selector(lockMessage:)
                                                       object:message]];
}

+ (UIViewController *)composeMessageViewControllerWithRequest:(MCTSendMessageRequest *)request
                                            andReplyOnMessage:(MCTMessage *)replyOn
{
    T_UI();
    MCTNewMessageVC *vc = [MCTNewMessageVC viewControllerWithRequest:request andReplyOn:replyOn];
    UINavigationController *nav = [[MCTUINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.tintColor = [UIColor MCTNavigationBarColor];
    return nav;
}

+ (UIViewController *)threadViewControllerForThread:(MCTMessageThread *)thread
                                  withParentMessage:(MCTMessage *)message
{
    T_UI();
    UIViewController *vc = nil;

    if (IS_FLAG_SET(message.flags, MCTMessageFlagDynamicChat) || [MCTMessageHelper isHumanThreadWithMessage:message]) {
        vc = [MCTHumanThreadVC viewControllerWithThread:thread
                                       andSelectedIndex:0];
    } else {
        vc = [MCTServiceMessageThreadVC viewControllerWithThread:thread
                                                andSelectedIndex:0];
    }

    return vc;
}

+ (UIViewController *)viewControllerForMessage:(MCTMessage *)message
{
    T_UI();
    if (message == nil)
        return nil;

    NSString *pkey = message.parent_key;
    if (pkey == nil)
        pkey = message.key;

    int i = 0;
    if (message.parent_key) {
        for (NSString *key in [[[MCTComponentFramework messagesPlugin] store] repliesWithParentKey:pkey]) {
            if ([message.key isEqualToString:key])
                break;
            i++;
        }
    }

    MCTMessageThread *thread = [[[MCTComponentFramework messagesPlugin] store] messageThreadByKey:pkey];
    return [MCTMessageHelper viewControllerForThread:thread withMessage:message andSelectedIndex:i];
}

+ (UIViewController *)viewControllerForThread:(MCTMessageThread *)thread
                                  withMessage:(MCTMessage *)message
                             andSelectedIndex:(NSInteger)index
{
    T_UI();
    UIViewController *vc = nil;

    if (IS_FLAG_SET(message.flags, MCTMessageFlagDynamicChat) || [MCTMessageHelper isHumanThreadWithMessage:message]) {
        vc = [MCTHumanThreadVC viewControllerWithThread:thread
                                       andSelectedIndex:index];
    }
    else if (message.dirty || message.needsMyAnswer || message.replyCount == 1) {
        vc = [MCTMessageDetailVC viewControllerWithMessageKey:message.key];
    }
    else {
        vc = [MCTServiceMessageThreadVC viewControllerWithThread:thread
                                                andSelectedIndex:index];
    }

    return vc;
}

+ (BOOL)isHumanThreadWithMessage:(MCTMessage *)msg
{
    T_UI();
    if ([[MCTComponentFramework friendsPlugin] isMyEmail:msg.sender])
        return YES;

    if ([[[MCTComponentFramework friendsPlugin] store] friendTypeByEmail:msg.sender] == MCTFriendTypeUser)
        return YES;

    if (msg.parent_key != nil)
        return [MCTMessageHelper isHumanThreadWithMessage:[[[MCTComponentFramework messagesPlugin] store] messageInfoByKey:msg.parent_key]];

    return NO;
}

+ (NSString *)hintConfigkeyForTag:(NSInteger)tag
{
    switch (tag) {
        case MCT_TAG_HINT_DOUBLE_TAP:
            return MCT_CONFIGKEY_HINT_DOUBLE_TAP;
        case MCT_TAG_HINT_SWIPE:
            return MCT_CONFIGKEY_HINT_SWIPE;
        case MCT_TAG_HINT_MSG_DISAPPEARED:
            return MCT_CONFIGKEY_HINT_MSG_DISAPPEARED;
        case MCT_TAG_HINT_BROADCAST:
            return MCT_CONFIGKEY_HINT_BROADCAST;
        default:
            return nil;
    }
}

+ (BOOL)showHintWithTag:(NSInteger)tag
             andMessage:(NSString *)hintMessage
                   inVC:(UIViewController<MCTUIViewControllerProtocol> *)vc
{
    T_UI();

    NSString *configKey = [MCTMessageHelper hintConfigkeyForTag:tag];

    if (![[MCTComponentFramework configProvider] stringForKey:configKey]) {
        vc.currentAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Hint", nil)
                                                          message:hintMessage
                                                         delegate:vc
                                                cancelButtonTitle:NSLocalizedString(@"Do not show again", nil)
                                                otherButtonTitles:NSLocalizedString(@"Close", nil), nil];
        vc.currentAlertView.tag = tag;
        [vc.currentAlertView show];
        vc.activeObject = nil;
        return YES;
    }
    return NO;
}

+ (BOOL)showDoubleTapHintInVC:(UIViewController<MCTUIViewControllerProtocol> *)vc
{
    T_UI();
    return [MCTMessageHelper showHintWithTag:MCT_TAG_HINT_DOUBLE_TAP
                                  andMessage:NSLocalizedString(@"Double tap to reply.", nil)
                                        inVC:vc];
}

+ (BOOL)showSwipeHintInVC:(UIViewController<MCTUIViewControllerProtocol> *)vc
{
    T_UI();
    return [MCTMessageHelper showHintWithTag:MCT_TAG_HINT_SWIPE
                                  andMessage:NSLocalizedString(@"Swipe to jump to another message thread.", nil)
                                        inVC:vc];
}

+ (BOOL)showMsgDisappearedHintWithServiceName:(NSString *)serviceName inVC:(UIViewController<MCTUIViewControllerProtocol> *)vc
{
    T_UI();
    NSString *f = NSLocalizedString(@"If you want to resume this conversation, you can find it in the History of service %@.", nil);
    return [MCTMessageHelper showHintWithTag:MCT_TAG_HINT_MSG_DISAPPEARED
                                  andMessage:[NSString stringWithFormat:f, serviceName]
                                        inVC:vc];
}

+ (BOOL)showBroadcastHintWithServiceName:(NSString *)serviceName andBroadcastType:(NSString *)broadcastType inVC:(UIViewController<MCTUIViewControllerProtocol> *)vc
{
    T_UI();
    NSString *f = NSLocalizedString(@"Check the bottom bar to see why you received this message.\n\nNote: You can unsubscribe using 'Notification settings' if you don't want '%1$@' messages from %2$@ any more.", nil);
    return [MCTMessageHelper showHintWithTag:MCT_TAG_HINT_BROADCAST
                                  andMessage:[NSString stringWithFormat:f, broadcastType, serviceName]
                                        inVC:vc];
}


+ (BOOL)processAlertViewForVC:(id<MCTUIViewControllerProtocol>)vc clickedButtonAtIndex:(NSInteger)buttonIndex forMessage:(MCTMessage *)message
{

    T_UI();
    if (vc.currentAlertView.tag == MCT_TAG_ERROR) {
        MCT_RELEASE(vc.currentAlertView);
        vc.activeObject = nil;
        return YES;
    }
    if (vc.currentAlertView.tag < 0) {

        if (vc.currentAlertView.tag < MCT_TAG_LAST_HINT) {
            // We cannot process this callback (is probably for MCTFormView)
            return NO;
        }

        // This is a hint
        NSString *s;
        if (vc.currentAlertView.cancelButtonIndex == buttonIndex && (s = [MCTMessageHelper hintConfigkeyForTag:vc.currentAlertView.tag])) {
            [[MCTComponentFramework workQueue]
             addOperation:[MCTInvocationOperation operationWithTarget:[MCTComponentFramework configProvider]
                                                             selector:@selector(setString:forKey:)
                                                              objects:@"false", s, nil]];
        }
    } else {
        assert(message);
        // Magic button clicked
        if (vc.currentAlertView.cancelButtonIndex != buttonIndex) {
            MCT_com_mobicage_to_messaging_ButtonTO *btn = [message.buttons objectAtIndex:vc.currentAlertView.tag];
            [MCTMessageHelper ackMessage:message withButton:btn];

            if ([btn.action hasPrefix:MCT_BTN_ACTION_PREFIX_TEL]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[btn.action stringByReplacingOccurrencesOfString:@" "
                                                                                                                      withString:@""]]];
            }
        } else {
            MCT_com_mobicage_to_messaging_ButtonTO *btn = [message.buttons objectAtIndex:vc.currentAlertView.tag];
            if ([btn.action hasPrefix:MCT_BTN_ACTION_PREFIX_TEL]
                && ![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[btn.action stringByReplacingOccurrencesOfString:@" "
                                                                                                                             withString:@""]]]) {
                // iPad user dismissed CALL popup
                [MCTMessageHelper ackMessage:message withButton:btn];
            }
        }
    }

    MCT_RELEASE(vc.currentAlertView);
    MCT_RELEASE(vc.activeObject);
    return YES;
}

#pragma mark -

+ (NSString *)formValueStringForMessage:(MCTMessage *)message
{
    T_UI();
    if (message.form) {
        MCT_com_mobicage_to_messaging_MemberStatusTO *myMemberStatus =
            [message memberWithEmail:[[MCTComponentFramework friendsPlugin] myEmail]];

        if (IS_FLAG_SET(myMemberStatus.status, MCTMessageStatusAcked)
                && [myMemberStatus.button_id isEqualToString:MCT_FORM_POSITIVE]) {

            return [MCTFormView valueStringForForm:message.form];
        }
    }

    return nil;
}

#pragma mark -

+ (UIImage *)imageForContentType:(NSString *)contentType
{
    T_UI();
    if ([MSG_ATTACHMENT_CONTENT_TYPE_PDF isEqualToString:contentType]) {
        return [UIImage imageNamed:@"attachment_pdf.png"];
    } else if ([contentType hasPrefix:@"image/"]) {
        return [UIImage imageNamed:@"attachment_img.png"];
    } else if ([contentType hasPrefix:@"video/"]) {
        return [UIImage imageNamed:@"attachment_video.png"];
    } else {
        return [UIImage imageNamed:@"attachment_unknown.png"];
    }
}

@end