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
#import "MCTCannedMessages.h"
#import "MCTMessage.h"
#import "MCTNewMessageButtonsVC.h"
#import "MCTNewMessageRecipientsVC.h"
#import "MCTNewMessageTextVC.h"
#import "MCTSendMessageRequest.h"
#import "MCTLoadCannedMessageVC.h"

#define MCT_NEW_MSG_DRAFT @"~"

@class MCTNewMessageVC;

@protocol MCTNewMessageControllerDelegate <NSObject>

- (void)newMessageControllerDidSendMessage:(MCTNewMessageVC *)vc;
- (void)newMessageControllerDidCancel:(MCTNewMessageVC *)vc;
- (void)newMessageControllerDidSaveCannedMessage:(MCTNewMessageVC *)vc;

@end

@interface MCTNewMessageVC : MCTUIViewController <UIAlertViewDelegate, UIActionSheetDelegate, MCTLoadCannedMessageDelegate>

@property (nonatomic, strong) MCTSendMessageRequest *request;
@property (nonatomic, strong) MCTMessage *replyOn;
@property (nonatomic) BOOL isReply;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIBarButtonItem *nextButton;
@property (nonatomic, strong) UIBarButtonItem *sendButton;
@property (nonatomic, strong) UIBarButtonItem *hamburgerButton;
@property (nonatomic, strong) MCTCannedMessages *cannedMessages;

@property (nonatomic) int currentPage;
@property (nonatomic, weak) UIViewController *currentVC;
@property (nonatomic, strong) MCTNewMessageRecipientsVC *vc1;
@property (nonatomic, strong) MCTNewMessageTextVC *vc2;
@property (nonatomic, strong) MCTNewMessageButtonsVC *vc3;

@property (nonatomic, weak) id<MCTNewMessageControllerDelegate> delegate;

+ (MCTNewMessageVC *)viewControllerWithRequest:(MCTSendMessageRequest *)requestOrNil
                                    andReplyOn:(MCTMessage *)msg;
- (IBAction)onBackClicked:(id)sender;
- (IBAction)onNextClicked:(id)sender;
- (void)sendMessage;
- (void)saveDraft;

@end