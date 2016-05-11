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

#import "MCTUIViewController.h"
#import "MCTMessage.h"
#import "MCTMessageThread.h"
#import "MCTTransferObjects.h"
#import "MCTSendMessageRequest.h"

#import <QuickLook/QuickLook.h>


// Warning - usage of tags on UIAlertView!
// Tag >= 0 indicates index of button pressed in a button message
// Predefined tags:
#define MCT_TAG_HINT_DOUBLE_TAP -1
#define MCT_TAG_HINT_SWIPE -2
#define MCT_TAG_HINT_MSG_DISAPPEARED -3
#define MCT_TAG_HINT_BROADCAST -4
#define MCT_TAG_LAST_HINT -4

#define MCT_TAG_FORM_POSITIVE_BUTTON -100
#define MCT_TAG_FORM_NEGATIVE_BUTTON -101
#define MCT_TAG_FORM_POSITIVE_ALERT_BEFORE_SUBMIT -102
#define MCT_TAG_FORM_NEGATIVE_ALERT_BEFORE_SUBMIT -103
#define MCT_TAG_FORM_POSITIVE_ACTION_BEFORE_SUBMIT -104
#define MCT_TAG_FORM_NEGATIVE_ACTION_BEFORE_SUBMIT -105

#define MCT_TAG_WIDGET_ACTION -200
#define MCT_TAG_UPLOAD_NOT_STARTED -201
#define MCT_TAG_ERROR -202

@interface MCTMessageHelper : NSObject

+ (BOOL)willOpenExternalAppForButtonWithAction:(NSString *)action;

+ (BOOL)canLockForMessage:(MCTMessage *)message;
+ (BOOL)shouldDisableButton:(MCT_com_mobicage_to_messaging_ButtonTO *)btn
                 forMessage:(MCTMessage *)message
        withSenderIsService:(BOOL)senderIsService;

+ (void)onMagicButtonClicked:(MCT_com_mobicage_to_messaging_ButtonTO *)btn
                  forMessage:(MCTMessage *)message
                       forVC:(id<MCTUIViewControllerProtocol, UIAlertViewDelegate>)vc;
+ (void)onDismissButtonClickedForMessage:(MCTMessage *)message;
+ (void)onDismissThreadClickedForMessage:(MCTMessage *)message;
+ (void)onParticipantClicked:(NSString *)email inNavigationController:(UINavigationController *)navigationController;
+ (void)onReplyClickedForMessage:(MCTMessage *)message inNavigationController:(UINavigationController *)navigationController;
+ (void)onLockClickedForMessage:(MCTMessage *)message;

+ (UIViewController *)composeMessageViewControllerWithRequest:(MCTSendMessageRequest *)request
                                            andReplyOnMessage:(MCTMessage *)replyOn;

+ (UIViewController *)threadViewControllerForThread:(MCTMessageThread *)thread
                                  withParentMessage:(MCTMessage *)message;
+ (UIViewController *)viewControllerForMessage:(MCTMessage *)message;
+ (UIViewController *)viewControllerForThread:(MCTMessageThread *)thread
                                  withMessage:(MCTMessage *)message
                             andSelectedIndex:(NSInteger)index;
+ (BOOL)isHumanThreadWithMessage:(MCTMessage *)msg;

+ (BOOL)showDoubleTapHintInVC:(id<MCTUIViewControllerProtocol>)vc;
+ (BOOL)showSwipeHintInVC:(id<MCTUIViewControllerProtocol>)vc;
+ (BOOL)showMsgDisappearedHintWithServiceName:(NSString *)serviceName
                                         inVC:(id<MCTUIViewControllerProtocol>)vc;
+ (BOOL)showBroadcastHintWithServiceName:(NSString *)serviceName andBroadcastType:(NSString *)broadcastType inVC:(UIViewController<MCTUIViewControllerProtocol> *)vc;

+ (NSString *)formValueStringForMessage:(MCTMessage *)message;

+ (BOOL)processAlertViewForVC:(id<MCTUIViewControllerProtocol>)vc
         clickedButtonAtIndex:(NSInteger)buttonIndex
                   forMessage:(MCTMessage *)message;

+ (UIImage *)imageForContentType:(NSString *)contentType;

@end