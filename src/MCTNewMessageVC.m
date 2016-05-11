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
#import "MCTGroupDetailVC.h"
#import "MCTIntent.h"
#import "MCTIntentFramework.h"
#import "MCTLoadCannedMessageVC.h"
#import "MCTMessagesPlugin.h"
#import "MCTNewMessageVC.h"
#import "MCTOperation.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"
#import "MCTUINavigationController.h"

#import "TTButton.h"
#import "UIViewAdditions.h"

#define MCT_NEW_MSG_CANCEL      0
#define MCT_NEW_MSG_RECIPIENTS  1
#define MCT_NEW_MSG_TEXT        2
#define MCT_NEW_MSG_BUTTONS     3
#define MCT_NEW_MSG_SEND        4

#define MCT_TAG_SAVE_CANNED_MESSAGE 1
#define MCT_TAG_HAMBURGER_MENU 2
#define MCT_TAG_NEW_GROUP 3



@interface MCTNewMessageVC ()

- (void)showCurrentPageWhileSkippingAppearanceMethods:(BOOL)skipAppearanceMethods;

@end


@implementation MCTNewMessageVC




+ (MCTNewMessageVC *)viewControllerWithRequest:(MCTSendMessageRequest *)requestOrNil
                                    andReplyOn:(MCTMessage *)msg
{
    T_UI();
    MCTNewMessageVC *vc = [[MCTNewMessageVC alloc] initWithNibName:@"newMessage" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    vc.request = requestOrNil;
    vc.replyOn = msg;
    return vc;
}

- (void)dealloc
{
    T_UI();
    HERE();

    [[NSNotificationCenter defaultCenter] removeObserver:self.vc2];
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    [MCTUIUtils setBackgroundPlainToView:self.view];

    self.backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                                        style:UIBarButtonItemStyleBordered
                                                       target:self
                                                       action:@selector(onBackClicked:)];

    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil)
                                                        style:UIBarButtonItemStyleBordered
                                                       target:self
                                                       action:@selector(onNextClicked:)];

    self.sendButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil)
                                                        style:UIBarButtonItemStyleDone
                                                       target:self
                                                       action:@selector(onSendClicked:)];

    if (!IS_FLAG_SET(self.request.flags, MCTMessageFlagDynamicChat)) {
        IF_IOS5_OR_GREATER({
            NSString *imageName = @"hamburger.png";

            IF_PRE_IOS7({
                imageName = @"hamburger-white.png";
            });

            UIImage *image = [UIImage imageNamed:imageName];
            self.hamburgerButton = [[UIBarButtonItem alloc] initWithImage:image
                                                       landscapeImagePhone:image
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(onHamburgerClicked:)];
        });
    }

    self.cannedMessages = [MCTCannedMessages cannedMessages];

    // Not showing MCT_NEW_MSG_TEXT when [self.request.members count] != 0,
    // because then you have the impression that you cannot select recipients anymore (when loading a canned message)
    self.currentPage = self.replyOn ? MCT_NEW_MSG_TEXT : MCT_NEW_MSG_RECIPIENTS;

    if (self.request == nil) {
        if ([self.cannedMessages.messages containsKey:MCT_NEW_MSG_DRAFT]) {
            self.request = [MCTSendMessageRequest requestWithRequestTO:[self.cannedMessages.messages objectForKey:MCT_NEW_MSG_DRAFT]];
            // Check if all members are still friends
            NSMutableArray *checkedMembers = [NSMutableArray arrayWithCapacity:[self.request.members count]];
            for (NSString *member in self.request.members) {
                if ([[[MCTComponentFramework friendsPlugin] store] friendByEmail:member]) {
                    [checkedMembers addObject:member];
                }
            }
            self.request.members = checkedMembers;
            self.request.parent_key = nil;
        } else {
            self.request = [MCTSendMessageRequest request];
        }
    }
    [self populateRequest];

    self.isReply = self.request.parent_key != nil;

    [self showCurrentPageWhileSkippingAppearanceMethods:YES]; // After viewDidLoad the appearance methods will be called automatically

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:MCT_NOTIFICATION_BACKGROUND
                                               object:nil];
}

- (void)populateRequest
{
    /*
     The completion of the request. Must happen here, in case there are new properties are added to the requestTO and a
     canned message has been loaded.
     */

    if (self.request.priority == 0) {
        self.request.priority = MCTMessagePriorityNormal;
    }

    if (self.request.tmpKey == nil || self.request.tmpKey == MCTNull) {
        self.request.tmpKey = [NSString stringWithFormat:@"%@%@", MCT_MESSAGE_TMP_KEY_PREFIX, [MCTUtils guid]];
    }

    self.request.flags |= MCTMessageFlagAllowDismiss | MCTMessageFlagAllowCustomReply | MCTMessageFlagAllowReply |
        MCTMessageFlagAllowReplyAll | MCTMessageFlagSharedMembers;
}

- (void)didEnterBackground
{
    HERE();
    [self.vc1 saveRecipients];
    [self.vc2 saveMessage];
    [self.vc3 saveButtons];
    [self saveDraft];
    [self.navigationController popToRootViewControllerAnimated:NO];
    if (self.delegate) {
        [self.delegate newMessageControllerDidCancel:self];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    // ios 6
    return NO;
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    // ios 5
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.currentVC viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.currentVC viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.currentVC viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.currentVC viewDidDisappear:animated];
    [self saveDraft];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    T_UI();
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MCT_NOTIFICATION_BACKGROUND object:nil];

    // Fix for device in landscape mode
    if (!UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        [MCTUIUtils forcePortrait];
    }

    [super dismissViewControllerAnimated:flag completion:completion];
}

- (void)sendMessage
{
    T_UI();
    if (self.vc2) {
        [self.vc2 saveMessage];
    }

    if (self.vc3) {
        [self.vc3 saveButtons];
        for (MCTButton *usedBtn in self.request.buttons) {
            MCTButton *cannedBtn = [self.vc3.cannedButtons buttonWithId:usedBtn.idX];
            cannedBtn.usedCount++;
        }
        [self.vc3.cannedButtons save];
    } else {
        // VC3 never opened -- make sure there are no buttons left from message draft
        self.request.sender_reply = nil;
        self.request.buttons = [NSArray array];
    }

    if ([MCTUtils isEmptyOrWhitespaceString:self.request.message]
            && [self.request.buttons count] == 0
            && self.request.attachmentHash == nil) {
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:NSLocalizedString(@"Message and/or buttons are required", nil)];
        self.currentAlertView.delegate = self;
        return;
    }

    self.currentPage = MCT_NEW_MSG_SEND;

    MCTFriendsPlugin *friendsPlugin = [MCTComponentFramework friendsPlugin];

    if (self.request.groupIds != nil && [self.request.groupIds count] > 0) {
        NSMutableSet *members = [NSMutableSet setWithArray:self.request.members];
        for (NSString *guid in self.request.groupIds) {
            MCTGroup *group = [friendsPlugin.store getGroupWithGuid:guid];
            if (group != nil) {
                for (NSString *member in group.members) {
                    [members addObject:member];
                }
            }
        }
        self.request.members = [members allObjects];
    }

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [[MCTComponentFramework messagesPlugin] sendMessageWithRequest:self.request];
    }];

    if ([self.cannedMessages.messages containsKey:MCT_NEW_MSG_DRAFT])
        [self.cannedMessages removeMessageForName:MCT_NEW_MSG_DRAFT];

    if (self.delegate) {
        [self.delegate newMessageControllerDidSendMessage:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveDraft
{
    T_UI();
    if (self.currentPage != MCT_NEW_MSG_SEND)
        [self.cannedMessages saveMessage:self.request withName:MCT_NEW_MSG_DRAFT];
}

- (void)showCurrentPageWhileSkippingAppearanceMethods:(BOOL)skipAppearanceMethods
{
    T_UI();

    if (!skipAppearanceMethods)
        [self.currentVC viewWillDisappear:YES];
    [self.currentVC.view removeFromSuperview];
    if (!skipAppearanceMethods)
        [self.currentVC viewDidDisappear:YES];
    self.currentVC = nil;
    self.title = nil;

    self.navigationItem.leftBarButtonItem = self.backButton;

    switch (self.currentPage) {
        case MCT_NEW_MSG_CANCEL:
            if (self.delegate) {
                [self.delegate newMessageControllerDidCancel:self];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            break;

        case MCT_NEW_MSG_RECIPIENTS:
            if (self.isReply) {
                // User pressed cancel
                [self.vc2.textView resignFirstResponder];
                if (self.delegate) {
                    [self.delegate newMessageControllerDidCancel:self];
                }
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            if (self.vc1 == nil) {
                self.vc1 = [MCTNewMessageRecipientsVC viewControllerWithRequest:self.request];
                self.vc1.sendMessageViewController = self;

            }
            self.currentVC = self.vc1;

            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.nextButton, self.hamburgerButton, nil];
            break;

        case MCT_NEW_MSG_TEXT:
            if (self.vc2 == nil) {
                self.vc2 = [MCTNewMessageTextVC viewControllerWithRequest:self.request];
                self.vc2.sendMessageViewController = self;
            }
            self.currentVC = self.vc2;

            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.sendButton, self.hamburgerButton, nil];
            break;

        case MCT_NEW_MSG_BUTTONS:
            if (self.vc3 == nil) {
                self.vc3 = [MCTNewMessageButtonsVC viewControllerWithRequest:self.request];
                self.vc3.sendMessageViewController = self;
            }
            self.currentVC = self.vc3;
            self.title = NSLocalizedString(@"Buttons", nil);
            
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.sendButton, self.hamburgerButton, nil];
            break;

        case MCT_NEW_MSG_SEND:
            [self sendMessage];
            break;

        default:
            break;
    }

    if (!skipAppearanceMethods)
        [self.currentVC viewWillAppear:YES];

    self.currentVC.view.frame = [[UIScreen mainScreen] applicationFrame];
    self.currentVC.view.height -= self.navigationController.navigationBar.height;

    IF_PRE_IOS7({
        self.currentVC.view.top = 0;
    });

    IF_IOS7_OR_GREATER({
        self.currentVC.view.top += self.navigationController.navigationBar.height;
    });

    [self.view addSubview:self.currentVC.view];
    if (!skipAppearanceMethods)
        [self.currentVC viewDidAppear:YES];
}

- (void)onBackClicked:(id)sender
{
    T_UI();
    self.currentPage--;
    [self showCurrentPageWhileSkippingAppearanceMethods:NO];
}

- (void)onSendClicked:(id)sender
{
    T_UI();
    [self sendMessage];
}

- (void)onHamburgerClicked:(id)sender
{
    T_UI();

    switch (self.currentPage) {
        case MCT_NEW_MSG_RECIPIENTS:
            self.currentActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"Create group", nil),
                                                                            NSLocalizedString(@"Load", nil), nil];

            break;

        case MCT_NEW_MSG_TEXT:
            self.currentActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles: NSLocalizedString(@"Save", nil), nil];
            break;

        case MCT_NEW_MSG_BUTTONS:
            self.currentActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"Save", nil), nil];
            break;

        default:
            break;
    }

    self.currentActionSheet.tag = MCT_TAG_HAMBURGER_MENU;
    [self.currentActionSheet showInView:self.view];
}

- (void)onCreateGroupClicked
{
    T_UI();
    self.currentAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Create a new group", nil)
                                                        message:NSLocalizedString(@"Provide a name for the group", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"Save", nil), nil];
    self.currentAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    self.currentAlertView.tag = MCT_TAG_NEW_GROUP;
    UITextField *textField = [self.currentAlertView textFieldAtIndex:0];
    textField.text = NSLocalizedString(@"no name", nil);
    textField.clearButtonMode = UITextFieldViewModeAlways;
    [self.currentAlertView show];

}

- (void)onSaveClicked
{
    T_UI();
    [self.vc1 saveRecipients];
    [self.vc2 saveMessage];
    [self.vc3 saveButtons];

    [self.vc2.textView resignFirstResponder];

    self.currentAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Create new canned message", nil)
                                                        message:NSLocalizedString(@"Provide a name for the saved message", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"Save", nil), nil];
    self.currentAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    self.currentAlertView.tag = MCT_TAG_SAVE_CANNED_MESSAGE;
    UITextField *textField = [self.currentAlertView textFieldAtIndex:0];
    textField.text = NSLocalizedString(@"no name", nil);
    textField.clearButtonMode = UITextFieldViewModeAlways;
    [self.currentAlertView show];
}

- (void)onLoadButtonClicked
{
    T_UI();
    HERE();
    MCTLoadCannedMessageVC *vc = [MCTLoadCannedMessageVC viewControllerWithCannedMessagesMgr:self.cannedMessages];
    vc.delegate = self;
    [self presentViewController:[[MCTUINavigationController alloc] initWithRootViewController:vc]
                       animated:YES
                     completion:nil];
}

- (void)onNextClicked:(id)sender
{
    T_UI();
    switch (self.currentPage) {
        case MCT_NEW_MSG_BUTTONS:
            if ([MCTUtils isEmptyOrWhitespaceString:self.request.message] && [self.vc3.selectedButtons count] == 0) {
                self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                               andText:NSLocalizedString(@"Message and/or buttons are required", nil)
                                                  andCancelButtonTitle:NSLocalizedString(@"Ok", nil) andTag:0];
                self.currentAlertView.delegate = self;
                return;
            }
            break;
        case MCT_NEW_MSG_RECIPIENTS:
            if (!self.isReply && [self.vc1.selectedRecipients count] == 0) {
                self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                               andText:NSLocalizedString(@"Add recipients before proceeding", nil)];
                self.currentAlertView.delegate = self;

                return;
            }
            break;
        default:
            break;
    }

    self.currentPage++;
    [self showCurrentPageWhileSkippingAppearanceMethods:NO];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (alertView.tag == MCT_TAG_SAVE_CANNED_MESSAGE) {
        LOG(@"ButtonIndex save canned message: %d", buttonIndex);
        if (buttonIndex != alertView.cancelButtonIndex) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            [self.cannedMessages saveMessage:self.request withName:textField.text];
            if (self.delegate) {
                [self.delegate newMessageControllerDidSaveCannedMessage:self];
            }
        }
        if (self.currentPage == MCT_NEW_MSG_TEXT) {
            [self.vc2.textView becomeFirstResponder];
        }
    } else if (alertView.tag == MCT_TAG_NEW_GROUP) {
        LOG(@"ButtonIndex create group: %d", buttonIndex);
        if (buttonIndex != alertView.cancelButtonIndex) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSString *guid = [MCTUtils guid];
            [[[MCTComponentFramework friendsPlugin] store] insertGroupWithGuid:guid
                                                                          name:textField.text
                                                                        avatar:nil
                                                                    avatarHash:nil];

            MCTGroup *group = [MCTGroup groupWithGuid:guid
                                                 name:textField.text
                                              members:[NSMutableArray array]
                                               avatar:nil
                                           avatarHash:nil];

            MCTGroupDetailVC *vc = [MCTGroupDetailVC viewControllerWithGroup:group
                                                                  isNewGroup:YES
                                                           showComposeButton:NO];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }

    if (self.currentAlertView == alertView) {
        MCT_RELEASE(self.currentAlertView);
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (actionSheet.tag == MCT_TAG_HAMBURGER_MENU) {
        LOG(@"ButtonIndex hamburger menu: %d", buttonIndex);
        switch (self.currentPage) {
            case MCT_NEW_MSG_RECIPIENTS:
                if (buttonIndex == 0) {
                    [self onCreateGroupClicked];
                } else if(buttonIndex == 1)  {
                    [self onLoadButtonClicked];
                }

                break;

            case MCT_NEW_MSG_TEXT:
                if (buttonIndex == 0) {
                    [self onSaveClicked];
                }
                break;

            case MCT_NEW_MSG_BUTTONS:
                if (buttonIndex == 0) {
                    [self onSaveClicked];
                }
                break;

            default:
                break;
        }
    }

    if (self.currentActionSheet == actionSheet) {
        MCT_RELEASE(self.currentActionSheet);
    }
}

#pragma mark - MCTLoadCannedMessageDelegate

- (void)loadCannedMessageDidFinishWithRequest:(MCTSendMessageRequest *)request
{
    request.parent_key = self.request.parent_key;

    self.request = self.vc1.request = self.vc2.request = self.vc3.request = request;
    [self populateRequest];
    [self.vc1 loadRecipients];
    [self.vc2 loadMessage];
    [self.vc3 loadButtons];
    IF_PRE_IOS5({
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    IF_IOS5_OR_GREATER({
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}


- (void)loadCannedMessageDidCancel
{
    IF_PRE_IOS5({
        [self dismissViewControllerAnimated:YES completion:nil];
    });
     IF_IOS5_OR_GREATER({
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

@end