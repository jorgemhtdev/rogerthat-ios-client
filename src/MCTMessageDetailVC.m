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
#import "MCTFriend.h"
#import "MCTHTTPRequest.h"
#import "MCTMessage.h"
#import "MCTMessageDetailVC.h"
#import "MCTMessageDetailView.h"
#import "MCTMessageEnums.h"
#import "MCTMessageHelper.h"
#import "MCTMessagesPlugin.h"
#import "MCTMoviePlayerVC.h"
#import "MCTOperation.h"
#import "MCTQLPreviewController.h"
#import "MCTSendMessageRequest.h"
#import "MCTServiceMenuVC.h"
#import "MCTTabMessagesVC.h"
#import "MCTUIUtils.h"


@interface MCTMessageDetailVC ()

@property (nonatomic) NSInteger chunkCount;
@property (nonatomic, strong) NSMutableSet *uploadedChunks;
@property (nonatomic) NSInteger selectedAttachmentIndex;

- (BOOL)iAmOnlyRecipient;
- (void)createRightBarButtonItem;

- (void)popViewControllerWithDelay:(BOOL)delayed andSender:(NSString *)sender;
- (void)popViewControllerWithSender:(NSString *)sender;
- (BOOL)shouldPopViewControllerWithIntent:(MCTIntent *)intent;

- (void)onExpectNextTimeout:(NSTimer *)timer;
- (int)expectNextWithFlags:(MCTlong)uiFlags;

@end

@implementation MCTMessageDetailVC

+ (MCTMessageDetailVC *)viewControllerWithMessageKey:(NSString *)key
{
    T_UI();
    MCTMessageDetailVC *vc = nil;
    IF_IOS7_OR_GREATER({
        vc = [[MCTMessageDetailVC alloc] initWithNibName:@"messageDetail" bundle:nil];
    });
    IF_PRE_IOS7({
        vc = [[MCTMessageDetailVC alloc] init];
    });
    vc.messageKey = key;
    vc.message = [[[MCTComponentFramework messagesPlugin] store] messageDetailsByKey:key];
    vc.hidesBottomBarWhenPushed = YES;
    return vc;
}

#pragma mark -

- (void)loadBrandingResultAndDetailViewWithFrame:(CGRect)f andIsRefresh:(BOOL)isRefresh
{
    T_UI();

    MCT_RELEASE(self.brandingResult);
    if (self.message.branding) {
        if ([[MCTComponentFramework brandingMgr] isBrandingAvailable:self.message.branding]) {
            self.brandingResult = [[MCTComponentFramework brandingMgr] prepareBrandingWithMessage:self.message];
        } else {
            NSString *branding = self.message.branding;
            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                [[MCTComponentFramework brandingMgr] queueGenericBranding:branding];
            }];
        }
    }

    self.detailView = [[MCTMessageDetailView alloc] initWithFrame:f
                                                  inViewController:self
                                                withBrandingResult:self.brandingResult
                                                      andIsRefresh:isRefresh];
    self.detailView.message = self.message;
    self.detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    if (!self.navigationController)
        ERROR(@"self.navigationController is nil");
}

- (void)loadView
{
    T_UI();
    IF_IOS7_OR_GREATER({
        [super loadView];
    });
    IF_PRE_IOS7({
        CGSize size = [MCTUIUtils availableSizeForViewWithController:self];
        CGRect frame = CGRectMake(0, 0, size.width, size.height);
        self.view = [[UIView alloc] initWithFrame:frame];
        self.view.backgroundColor = [UIColor blackColor];
    });
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    IF_IOS7_OR_GREATER({
        self.automaticallyAdjustsScrollViewInsets = YES;
    });

    CGRect f = self.view.frame;
    f.size.height = CGRectGetMaxY([UIScreen mainScreen].applicationFrame);

    IF_PRE_IOS7({
        f.size.height -= 64;
    });

    [self loadBrandingResultAndDetailViewWithFrame:f andIsRefresh:NO];
    [self.view addSubview:self.detailView];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:@[kINTENT_MESSAGE_MODIFIED,
                                                                      kINTENT_MESSAGE_RECEIVED_HIGH_PRIO,
                                                                      kINTENT_MESSAGE_JSMFR_ERROR,
                                                                      kINTENT_MESSAGE_JSMFR_ENDED,
                                                                      kINTENT_CHUNK_UPLOADED,
                                                                      kINTENT_UPLOADING_CHUNKS_STARTED,
                                                                      kINTENT_UPLOADING_CHUNKS_FINISHED,
                                                                      kINTENT_UPLOAD_NOT_STARTED,
                                                                      kINTENT_GENERIC_BRANDING_RETRIEVED]
                                                            onQueue:[MCTComponentFramework mainQueue]];
    if (self.message.dirty) {
        NSString *messageKey = self.message.key;
        NSString *parentKey = self.message.parent_key;
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            [[MCTComponentFramework messagesPlugin] messageNotDirty:messageKey];
            if (!IS_FLAG_SET(self.message.flags, MCTMessageFlagSentByJSMFR)) {
                [[MCTComponentFramework messagesPlugin] markAsReadWithParentKey:parentKey andMessageKeys:@[messageKey]];
            }
        }];
    }
    [self createRightBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // force redraw is necessary e.g. if we were in bg
    // 1. open a2p message and click button. quickly press iphone home button
    // 2. wait 10s
    // 3. open app --> you should see the web branding

    //[self.detailView refreshViewWithIsOtherMessage:YES];

    //LOG(@"stack - %@", [MCTUtils currentStackTrace]);

    [self changeNavigationControllerAppearanceWithBrandingResult:self.brandingResult];
}

- (void)viewWillDisappear:(BOOL)animated
{
    T_UI();
    [super viewWillDisappear:animated];

    if (self.message.dirty) {
        NSString *messageKey = self.message.key;
        NSString *parentKey = self.message.parent_key;
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            [[MCTComponentFramework messagesPlugin] messageNotDirty:messageKey];
            if (!IS_FLAG_SET(self.message.flags, MCTMessageFlagSentByJSMFR)) {
                [[MCTComponentFramework messagesPlugin] markAsReadWithParentKey:parentKey andMessageKeys:@[messageKey]];
            }
        }];
    }

    [self resetNavigationControllerAppearance];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (![self.navigationController.viewControllers containsObject:self]) {
        // view disappears and we are not in the stack

        [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
        [self.detailView unregisterDelegatesAndListeners];

        if (self.expectNextTimer) {
            [self.expectNextTimer invalidate];
            MCT_RELEASE(self.expectNextTimer);
        }
    }
    [super viewDidDisappear:animated];
}

- (BOOL)iAmOnlyRecipient
{
    T_UI();
    if ([[MCTComponentFramework friendsPlugin] isMyEmail:self.message.sender])
        return NO;

    for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in self.message.members)
        if (![[MCTComponentFramework friendsPlugin] isMyEmail:member.member] && ![self.message.sender isEqualToString:member.member])
            return NO;

    return YES;
}

- (void)createRightBarButtonItem
{
    T_UI();
    NSString *myEmail = [[MCTComponentFramework friendsPlugin] myEmail];
    if (IS_FLAG_SET([self.message memberWithEmail:myEmail].status, MCTMessageStatusAcked) || self.message.isLocked) {
        UIBarButtonItemStyle itemStyle = UIBarButtonItemStylePlain;
        IF_PRE_IOS7({
            itemStyle = UIBarButtonItemStyleBordered;
        });

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Details", nil)
                                                                                   style:itemStyle
                                                                                  target:self
                                                                                  action:@selector(onDetailsTapped:)];
    } else {
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    }
}

- (void)onDetailsTapped:(UIBarButtonItem *)sender
{
    T_UI();
    // Toggle Details
    [self.detailView onShowDetailsTapped];
    IF_PRE_IOS7({
        IF_IOS5_OR_GREATER({
            sender.tintColor = self.detailView.detailsExpanded ? [UIColor colorWithString:@"#4a6c9b"] : nil;
        });
    });
}

#pragma mark - Intents

- (void)popToViewController:(UIViewController *)vc
{
    T_UI();
    [self.navigationController popToViewController:vc animated:YES];
}

- (void)popViewControllerWithSender:(NSString *)sender
{
    T_UI();
    [self popViewControllerWithDelay:YES andSender:sender];
}


- (void)popViewControllerWithDelay:(BOOL)delayed andSender:(NSString *)sender
{
    T_UI();
    if ([[MCTComponentFramework friendsPlugin].store friendTypeByEmail:sender] == MCTFriendTypeService
        && [[MCTComponentFramework friendsPlugin].store friendExistsWithEmail:sender]) {
        for (UIViewController *vc in [self.navigationController.viewControllers reverseObjectEnumerator]) {
            if ([vc isKindOfClass:[MCTServiceMenuVC class]]) {
                MCTServiceMenuVC *menuVC = (MCTServiceMenuVC *) vc;
                if ([menuVC.service.email isEqualToString:sender]) {
                    [self performSelector:@selector(popToViewController:) withObject:menuVC afterDelay:0.5];
                    return;
                }
            }
        }

        LOG(@"Inserting ServiceMenuVC in navigationController.viewControllers");
        NSMutableArray *vcs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        MCTFriend *service =[[[MCTComponentFramework friendsPlugin] store] friendByEmail:sender];
        MCTServiceMenuVC *vc = [MCTServiceMenuVC viewControllerWithService:service];
        [vcs replaceObjectAtIndex:[vcs indexOfObject:self] withObject:vc];
        [self.navigationController setViewControllers:vcs animated:YES];
        return;
    }

    if (delayed) {
        [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:MCTYES afterDelay:0.5];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)shouldPopViewControllerWithIntent:(MCTIntent *)intent
{
    T_UI();
    if (IS_FLAG_SET(self.message.flags, MCTMessageFlagAutoLock) || [self.message.buttons count] == 0)
        return YES;

    if (![self iAmOnlyRecipient])
        return NO;

    if (intent != nil && [intent hasStringKey:@"my_button_id"]) {
        NSString *btnId = [intent stringForKey:@"my_button_id"];
        if (btnId != MCTNull) {
            NSString *action = [self.message buttonWithId:btnId].action;
            if ([MCTMessageHelper willOpenExternalAppForButtonWithAction:action]) {
                // Do not pop viewcontroller: #1961
                return NO;
            }
        }
    }

    return YES;
}

- (BOOL)expectingNextWithButtonId:(NSString *)btnId
{
    T_UI();
    MCTlong expectNextWait = 0;
    if (btnId == MCTNull) {
        expectNextWait = [self expectNextWithFlags:self.message.dismiss_button_ui_flags];
    } else {
        expectNextWait = [self expectNextWithFlags:[self.message buttonWithId:btnId].ui_flags];
    }

    if (expectNextWait && (self.message.isSentByJSMFR || [MCTUtils connectedToInternetAndXMPP])) {
        self.currentActionSheet = [self showActionSheetWithTitle:NSLocalizedString(@"Processing ...", nil)];
        self.expectNextTimer = [NSTimer scheduledTimerWithTimeInterval:expectNextWait
                                                                target:self
                                                              selector:@selector(onExpectNextTimeout:)
                                                              userInfo:nil
                                                               repeats:NO];
        return YES;
    }

    return NO;
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_MESSAGE_MODIFIED) {
        if (![[intent stringForKey:@"message_key"] isEqualToString:self.message.key])
            return;

        if (self.chunkCount != 0) {
            LOG(@"Ignoring kINTENT_MESSAGE_MODIFIED intents");
            return;
        }

        self.message = [[[MCTComponentFramework messagesPlugin] store] messageDetailsByKey:self.message.key];

        if ([intent hasStringKey:@"my_button_id"]) {
            NSString *btnId = [intent stringForKey:@"my_button_id"];
            if ([self expectingNextWithButtonId:btnId]) {
                return;
            }
        }

        if ([intent hasBoolKey:@"needsMyAnswer_changed"] && !self.message.needsMyAnswer) {
            // Message answered
            if ([self shouldPopViewControllerWithIntent:intent]) {
                [self popViewControllerWithSender:self.message.sender];
                return;
            }
            [self createRightBarButtonItem];
        }
    }
    else if (intent.action == kINTENT_MESSAGE_RECEIVED_HIGH_PRIO) {
        if ([[NSString stringWithFormat:@"DASHBOARD_%@", self.message.key] isEqualToString:[intent stringForKey:@"context"]]) {
            [self cleanupProgressHUD];
        } else if ([[NSString stringWithFormat:@"BROADCAST_%@", self.message.key] isEqualToString:[intent stringForKey:@"context"]]) {
            // User pressed notification settings
            [self.expectNextTimer invalidate];
            MCT_RELEASE(self.expectNextTimer);
        } else if ([[NSString stringWithFormat:@"CHAT_%@", self.message.threadKey] isEqualToString:[intent stringForKey:@"context"]]) {
            // Service starts a chat
            [self.expectNextTimer invalidate];
            MCT_RELEASE(self.expectNextTimer);

            NSString *messageKey = [intent stringForKey:@"message_key"];
            MCTMessage *message = [[[MCTComponentFramework messagesPlugin] store] messageDetailsByKey:messageKey];
            UIViewController *vc = [MCTMessageHelper viewControllerForMessage:message];
            NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            [viewControllers removeLastObject];
            [viewControllers addObject:vc];
            [self.navigationController setViewControllers:viewControllers animated:YES];
            return;
        } else {
            if (self.currentActionSheet == nil)
                return;

            // We are expecting a reply!
            if (![intent hasStringKey:@"parent_message_key"])
                return;

            if (![[self.message threadKey] isEqualToString:[intent stringForKey:@"parent_message_key"]])
                return;

            // We received the reply!
            [self.expectNextTimer invalidate];
            MCT_RELEASE(self.expectNextTimer);
        }

        self.rightBarButtonItem = nil;

        // Show the reply
        self.messageKey = [intent stringForKey:@"message_key"];
        self.message = [[[MCTComponentFramework messagesPlugin] store] messageDetailsByKey:self.messageKey];

        MCTMessageDetailView *oldDetailView = self.detailView;
        [oldDetailView unregisterDelegatesAndListeners];

        CGRect f = self.view.frame;
        CGFloat h = [[UIScreen mainScreen] applicationFrame].origin.y + self.navigationController.navigationBar.frame.size.height;
        IF_IOS7_OR_GREATER({
            f.size.height -= h;
            oldDetailView.height += h;
        });
        [self loadBrandingResultAndDetailViewWithFrame:f andIsRefresh:YES];
        self.detailView.top = CGRectGetMaxY(oldDetailView.frame);
        [self.view addSubview:self.detailView];

        if (self.navigationController.visibleViewController == self) {
            [self changeNavigationControllerAppearanceWithBrandingResult:self.brandingResult];
        }

        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             oldDetailView.top = -self.detailView.height;
                             IF_IOS7_OR_GREATER({
                                 self.detailView.top = h;
                             });
                             IF_PRE_IOS7({
                                 self.detailView.top = 0;
                             });
                         }
                         completion:^(BOOL finished) {
                             MCT_RELEASE(self.currentActionSheet);
                             [oldDetailView removeFromSuperview];
                             [self createRightBarButtonItem];
                         }];
    }
    else if (intent.action == kINTENT_MESSAGE_JSMFR_ERROR || intent.action == kINTENT_MESSAGE_JSMFR_ENDED) {
        if (![intent hasStringKey:@"parent_message_key"])
            return;

        if (![[self.message threadKey] isEqualToString:[intent stringForKey:@"parent_message_key"]])
            return;

        if (self.expectNextTimer == nil && self.currentActionSheet == nil)
            return;

        if (intent.action == kINTENT_MESSAGE_JSMFR_ENDED && [intent boolForKey:@"wait_for_followup"])
            return; // We must keep on waiting

        NSString *sender = [[NSString alloc] initWithString:self.message.sender];
        MCT_RELEASE(self.message); // Making sure receiving MESSAGE_MODIFIED won't do anything
        [self.expectNextTimer invalidate];
        MCT_RELEASE(self.expectNextTimer);
        MCT_RELEASE(self.currentActionSheet);

        [self popViewControllerWithSender:sender];
    }
    else if (intent.action == kINTENT_UPLOADING_CHUNKS_STARTED) {
        if (![self.message.key isEqualToString:[intent stringForKey:@"message_key"]]) {
            return;
        }

        self.currentProgressHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.currentProgressHUD];
        self.currentProgressHUD.dimBackground = YES;
        self.currentProgressHUD.delegate = self;
        self.currentProgressHUD.detailsLabelText = NSLocalizedString(@"Tap to send to background", nil);
        self.currentProgressHUD.labelText = NSLocalizedString(@"Transmitting, please wait…", nil);
        self.currentProgressHUD.mode = MBProgressHUDModeDeterminate;
        [self.currentProgressHUD show:YES];

        [self.currentProgressHUD addGestureRecognizer:
         [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(progressHudTapped:)]];

        self.chunkCount = [intent longForKey:@"total_chunks"];
        self.uploadedChunks = [NSMutableSet setWithCapacity:self.chunkCount];
        [self updateProgress];
    }
    else if (intent.action == kINTENT_UPLOADING_CHUNKS_FINISHED) {
        if (![self.message.key isEqualToString:[intent stringForKey:@"message_key"]]) {
            return;
        }

        if (self.currentProgressHUD) {
            [self cleanupProgressHUD];
        }

        BOOL expectingNext = [self expectingNextWithButtonId:MCT_FORM_POSITIVE]; // shows spinner if needed
        if (!expectingNext) {
            // Form is being submitted. Let's not wait anymore for the intent.
            [self popViewControllerWithDelay:NO andSender:self.message.sender];
            // Fixes crash in popping viewController after receiving MESSAGE_MODIFIED
            [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
        }
    }
    else if (intent.action == kINTENT_CHUNK_UPLOADED) {
        if (![self.message.key isEqualToString:[intent stringForKey:@"message_key"]]) {
            return;
        }

        if (self.currentProgressHUD && self.chunkCount > 0) {
            [self.uploadedChunks addObject:[NSNumber numberWithLong:[intent longForKey:@"number"]]];
            [self updateProgress];
        }
    }
    else if (intent.action == kINTENT_UPLOAD_NOT_STARTED) {
        if (![self.messageKey isEqualToString:[intent stringForKey:@"message_key"]]) {
            return;
        }

        self.chunkCount = -1;

        self.currentAlertView = [MCTUIUtils showAlertWithTitle:[intent stringForKey:@"title"]
                                                       andText:[intent stringForKey:@"text"]];
        self.currentAlertView.delegate = self;
        self.currentAlertView.tag = MCT_TAG_UPLOAD_NOT_STARTED;
    }
    else if (intent.action == kINTENT_GENERIC_BRANDING_RETRIEVED) {
        if (self.message.branding && self.brandingResult == nil && [[intent stringForKey:@"branding_key"] isEqualToString:self.message.branding]) {
            if ([[MCTComponentFramework brandingMgr] isBrandingAvailable:self.message.branding]) {
                self.brandingResult = [[MCTComponentFramework brandingMgr] prepareBrandingWithMessage:self.message];
            }

            self.detailView.brandingResult = self.brandingResult;
            [self.detailView refreshViewWithIsOtherMessage:YES]; // treat as a different message --> view will be rebuilt
        }
    }
}

#pragma mark - MBProgressHUD

- (void)updateProgress
{
    T_UI();
    float progress = (float) ([self.uploadedChunks count] + 1) / self.chunkCount;
    if (progress >= 1) {
        progress = MAX(0.95f, 1 - 0.5 / self.chunkCount);
    }
    LOG(@"Transfer progress: %f", progress);
    [self smoothUpdateProgressHudFrom:self.currentProgressHUD.progress to:progress fast:NO];
}

- (void)progressHudTapped:(id)sender
{
    T_UI();
    // Send to background
    [self cleanupProgressHUD];
    [self popViewControllerWithSender:self.message.sender];
}

- (void)cleanupProgressHUD
{
    T_UI();
    self.currentProgressHUD.progress = 1;
    [self.currentProgressHUD hide:YES afterDelay:0.4];
    MCT_RELEASE(self.currentProgressHUD);
    MCT_RELEASE(self.uploadedChunks);
    self.chunkCount = 0;
}

- (void)smoothUpdateProgressHudFrom:(float)fromProgress to:(float)toProgress fast:(BOOL)fast
{
    T_UI();
    if (self.currentProgressHUD) {
        if (self.currentProgressHUD.progress < toProgress) {
            fast = fast || toProgress >= 1.0f; // update fast when toProgress == 100%
            int steps = fast ? 10 : 50;
            NSTimeInterval animationTime = fast ? 0.5f : 1.5f;
            float newProgress = self.currentProgressHUD.progress + (toProgress - fromProgress) / steps;
            self.currentProgressHUD.progress = newProgress;

            // GCD - Dispatch after
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationTime/steps * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self smoothUpdateProgressHudFrom:fromProgress to:toProgress fast:fast];
            });
        } else if (toProgress >= 1.0f && self.currentProgressHUD.progress >= 1.0f) {
            [self cleanupProgressHUD];
        }
    }
}

#pragma mark - Expect Next

- (UIActionSheet *)showActionSheetWithTitle:(NSString *)title
{
    T_UI();
    if (self.currentActionSheet == nil) {
        self.currentActionSheet = [MCTUIUtils showActivityActionSheetWithTitle:title inViewController:self];
    } else {
        self.currentActionSheet.title = title;
    }
    return self.currentActionSheet;
}

- (void)onExpectNextTimeout:(NSTimer *)timer
{
    T_UI();
    if (timer == self.expectNextTimer && self.currentActionSheet) {
        [self.expectNextTimer invalidate];
        MCT_RELEASE(self.expectNextTimer);
        MCT_RELEASE(self.currentActionSheet);
        if ([self shouldPopViewControllerWithIntent:nil])
            [self popViewControllerWithSender:self.message.sender];
        else
            [self createRightBarButtonItem];
    }
}

- (int)expectNextWithFlags:(MCTlong)uiFlags
{
    if (IS_FLAG_SET(uiFlags, MCTButtonUIFlagExpectNextWait10))
        return 10;

    return 0;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == MCT_TAG_UPLOAD_NOT_STARTED) {
        MCT_RELEASE(self.currentAlertView);
        [self popViewControllerWithSender:self.message.sender];
    } else {
        [self.detailView processAlertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.detailView processActionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
}

#pragma mark - Attachments

- (void)onAttachmentClickedWithIndex:(NSInteger)index
{
    T_UI();
    self.selectedAttachmentIndex = index;
    MCTMessageAttachmentPreviewItem *preview = [self.message attachmentPreviewItemAtIndex:self.selectedAttachmentIndex];
    MCT_com_mobicage_to_messaging_AttachmentTO *attachment = [self.message.attachments objectAtIndex:self.selectedAttachmentIndex];

    if (![attachment.content_type hasPrefix:@"video/"] && ![QLPreviewController canPreviewItem:preview]) {
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:NSLocalizedString(@"Error", nil)
                                                       andText:NSLocalizedString(@"The selected attachment can not be displayed.", nil)];
        self.currentAlertView.delegate = self;
    } else {
        NSFileManager *fileMgr = [NSFileManager defaultManager];

        if ([fileMgr fileExistsAtPath:preview.itemPath]) {
            [self loadSelectedAttachment];
            return;
        }

        NSString *downloadedLocalFlowAttachmentPath = [[MCTComponentFramework brandingMgr] localFlowAttachmentFileWithThreadKey:self.message.threadKey
                                                                                                                    downloadURL:attachment.download_url];
        if ([fileMgr fileExistsAtPath:downloadedLocalFlowAttachmentPath]) {
            if ([self symlinkLocalFlowAttachment:preview withDownloadPath:downloadedLocalFlowAttachmentPath]) {
                [self loadSelectedAttachment];
                return;
            }
        }

        if ([MCTUtils connectedToInternet]) {
            [self downloadAttachmentWithPreviewItem:preview];
        } else {
            self.currentAlertView = [MCTUIUtils showNetworkErrorAlert];
            self.currentAlertView.delegate = self;
        }
    }
}

- (BOOL)symlinkLocalFlowAttachment:(MCTMessageAttachmentPreviewItem *)preview
                  withDownloadPath:(NSString *)downloadedLocalFlowAttachmentPath
{
    T_UI();
    // 1. Create the directory for the preview item, if it does not exist.
    // 2. If the symlink destination exists, but pointed to a non-existing file, then we need to remove it.
    //    (can happen after app update, then the app location changes)
    // 3. Symlink the downloaded local flow attachment to the preview item's path.
    // 4. Show the attachment.

    NSError *error = nil;
    NSFileManager *fileMgr = [NSFileManager defaultManager];

    if (![fileMgr fileExistsAtPath:preview.itemDir] && ![fileMgr createDirectoryAtPath:preview.itemDir
                                                           withIntermediateDirectories:YES
                                                                            attributes:nil
                                                                                 error:&error]) {
        ERROR(@"Could not create directory at path %@\n\nError: %@",
              preview.itemDir, error);
        return NO;
    }

    if ([fileMgr destinationOfSymbolicLinkAtPath:preview.itemPath error:nil] &&
        ![fileMgr removeItemAtPath:preview.itemPath error:&error]) {
        ERROR(@"Could not remove symlink %@\n\nError: %@",
              preview.itemPath, error);
        return NO;
    }

    if (![fileMgr createSymbolicLinkAtPath:preview.itemPath
                       withDestinationPath:downloadedLocalFlowAttachmentPath
                                     error:&error]) {
        ERROR(@"Could not symlink downloaded attachment \nfrom %@ \nto %@\n\nError: %@",
              downloadedLocalFlowAttachmentPath, preview.itemPath, error);
        return NO;
    }

    return YES;
}

- (void)downloadAttachmentWithPreviewItem:(MCTMessageAttachmentPreviewItem *)previewItem
{
    T_UI();
    MCT_com_mobicage_to_messaging_AttachmentTO *attachment = [self.message.attachments objectAtIndex:self.selectedAttachmentIndex];
    MCTHTTPRequest *req = [MCTHTTPRequest requestWithURL:[NSURL URLWithString:attachment.download_url]];
    __weak typeof(req) weakHttpRequest = req;

    self.currentProgressHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.currentProgressHUD];
    self.currentProgressHUD.dimBackground = YES;
    self.currentProgressHUD.delegate = self;
    self.currentProgressHUD.labelText = NSLocalizedString(@"Downloading…", nil);
    self.currentProgressHUD.mode = MBProgressHUDModeDeterminate;
    [self.currentProgressHUD show:YES];

    __block float downloadedPct = 0;

    [req setBytesReceivedBlock:^(unsigned long long size, unsigned long long total){
        float stepPct = size / (float)total;
        LOG(@"downloaded: %lld/%lld = %f", size, total, stepPct);
        LOG(@"Updating progress to %f", downloadedPct + stepPct);
        [self smoothUpdateProgressHudFrom:downloadedPct
                                       to:downloadedPct + stepPct
                                     fast:YES];
        downloadedPct += stepPct;
    }];

    [req setCompletionBlock:^{
        [self cleanupProgressHUD];

        if (req.responseStatusCode != 200) {
            self.currentAlertView = [MCTUIUtils showErrorPleaseRetryAlert];
            self.currentAlertView.delegate = self;
            return;
        }

        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if (![fileMgr fileExistsAtPath:previewItem.itemDir] && ![fileMgr createDirectoryAtPath:previewItem.itemDir
                                                                   withIntermediateDirectories:YES
                                                                                    attributes:nil
                                                                                         error:nil]) {
            ERROR(@"Could not create dir %@", previewItem.itemDir);
            self.currentAlertView = [MCTUIUtils showErrorPleaseRetryAlert];
            self.currentAlertView.delegate = self;
            return;
        }

        LOG(@"Saving attachment file to '%@'", previewItem.itemPath);
        if (![weakHttpRequest.responseData writeToFile:previewItem.itemPath atomically:YES]) {
            ERROR(@"Failed to save attachment file to '%@'", previewItem.itemPath);
            self.currentAlertView = [MCTUIUtils showErrorPleaseRetryAlert];
            self.currentAlertView.delegate = self;
            return;
        }

        [self loadSelectedAttachment];
    }];

    [req setFailedBlock:^{
        [self cleanupProgressHUD];
        self.currentAlertView = [MCTUIUtils showErrorPleaseRetryAlert];
        self.currentAlertView.delegate = self;
    }];

    req.timeOutSeconds = 60;
    [req setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [[MCTComponentFramework downloadQueue] addOperation:req];
}

- (void)loadSelectedAttachment
{
    T_UI();
    MCT_com_mobicage_to_messaging_AttachmentTO *attachment = [self.message.attachments objectAtIndex:self.selectedAttachmentIndex];
    if ([attachment.content_type hasPrefix:@"video/"]) {
        MCTMessageAttachmentPreviewItem *preview = [self.message attachmentPreviewItemAtIndex:self.selectedAttachmentIndex];
        MCTMoviePlayerVC *vc = [MCTMoviePlayerVC viewControllerWithContentURL:preview.previewItemURL];
        vc.title = preview.itemTitle;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        MCTQLPreviewController *vc = [[MCTQLPreviewController alloc] init];
        vc.dataSource = self;
        vc.delegate = self;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    T_UI();
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    T_UI();
    HERE();
    MCTMessageAttachmentPreviewItem *preview = [self.message attachmentPreviewItemAtIndex:self.selectedAttachmentIndex];
    LOG(@"canPreviewItem: %@", BOOLSTR([QLPreviewController canPreviewItem:preview]));
    return preview;
}

#pragma mark -

- (void)dealloc
{
    T_UI();
    [[MCTComponentFramework brandingMgr] cleanupBrandingWithBrandingKey:self.message.branding];
    [self.expectNextTimer invalidate];
}

@end