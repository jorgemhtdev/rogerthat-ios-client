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

#import "MCTChatInfoVC.h"
#import "MCTComponentFramework.h"
#import "MCTContactCell.h"
#import "MCTFriendDetailVC.h"
#import "MCTHTTPRequest.h"
#import "MCTHumanMessageCell.h"
#import "MCTHumanThreadVC.h"
#import "MCTIntent.h"
#import "MCTMessageHelper.h"
#import "MCTMoviePlayerVC.h"
#import "MCTQLPreviewController.h"
#import "MCTRogerThatCell.h"
#import "MCTTabMessagesVC.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

#define MS_W 40
#define MS_PADDING 5
#define MS_SPACING 3

#define MCT_TAG_THREAD_DELETED -10


@interface MCTHumanThreadVC ()

@property (nonatomic, strong) MCTMessage *selectedAttachmentMessage;
@property (nonatomic) NSInteger selectedAttachmentIndex;

- (NSInteger)indexOfFirstUnReadMessage;
- (void)updateMemberSummaryView;
- (void)registerIntents;
- (void)unregisterIntents;

@end


@implementation MCTHumanThreadVC


+ (MCTHumanThreadVC *)viewControllerWithThread:(MCTMessageThread *)thread andSelectedIndex:(NSInteger)index
{
    T_UI();
    MCTHumanThreadVC *vc = [[MCTHumanThreadVC alloc] initWithNibName:@"humanThread" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    vc.thread = thread;
    vc.selectedIndex = index;
    return vc;
}

- (MCTMessageStatus)threadMemberStatusWithEmail:(NSString *)email
{
    MCTMessageStatus status = 100;
    for (MCTMessage *msg in self.messages) {
        MCT_com_mobicage_to_messaging_MemberStatusTO *ms = [msg memberWithEmail:email];
        if (ms == nil)
            continue;
        status = (int) MIN(status, ([msg.sender isEqualToString:ms.member]) ? MCTMessageStatusAcked : ms.status);
    }
    return status;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    [self registerIntents];

    self.title = NSLocalizedString(@"Conversation", nil);
    self.view.backgroundColor = [UIColor MCTMercuryColor];

    self.messagesPlugin = [MCTComponentFramework messagesPlugin];
    self.myEmail = [self.messagesPlugin.store myEmail];

    [self loadMessages];
    self.renderedMessages = [NSMutableArray arrayWithCapacity:self.messages.count];

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showShadows = NO;

    [MCTUIUtils addShadowToView:self.scrollView];

    if (self.isDynamicChat) {
        CGFloat delta = self.tableView.top - self.scrollView.top;
        self.tableView.top -= delta;
        self.tableView.height += delta;
        [self.scrollView removeFromSuperview];
        MCT_RELEASE(self.scrollView);

        if (self.selectedIndex > 0) {
            self.selectedIndex--;
        }
    }

    if (self.selectedIndex == 0) {
        // find first to-be-acked message
        NSInteger i = [self indexOfFirstUnReadMessage];
        if (i != NSNotFound) {
            self.selectedIndex = i;
        }
    }

    [self updateMemberSummaryView];

    [MCTMessageHelper showDoubleTapHintInVC:self] || [MCTMessageHelper showSwipeHintInVC:self];

    UISwipeGestureRecognizer *swipeLeft =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipeLeft];

    UISwipeGestureRecognizer *swipeRight =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:swipeRight];
}

- (void)loadMessages
{
    T_UI();
    self.messages = [NSMutableArray arrayWithArray:[self.messagesPlugin.store messagesInThread:self.thread.key]];
    self.parentMessage = self.messages[0];
    self.isDynamicChat = IS_FLAG_SET(self.parentMessage.flags, MCTMessageFlagDynamicChat);
    if (self.isDynamicChat) {
        [self.messages removeObjectAtIndex:0];
        self.threadNeedsMyAnswer = NO;
        self.chatData = [self.parentMessage.message MCT_JSONValue];
        self.title = self.chatData[@"t"];
    } else {
        self.threadNeedsMyAnswer = self.parentMessage.threadNeedsMyAnswer;
        self.chatData = nil;
    }

    NSMutableArray *rightBarButtonItems = [NSMutableArray array];

    if (self.isDynamicChat) {
        UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [infoBtn addTarget:self action:@selector(onInfoClicked:) forControlEvents:UIControlEventTouchUpInside];
        [rightBarButtonItems addObject:[[UIBarButtonItem alloc] initWithCustomView:infoBtn]];

        NSString *bThreadKey = self.thread.key;
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            [[MCTComponentFramework messagesPlugin] ackChatWithKey:bThreadKey];
        }];
    }

    if (IS_FLAG_SET(self.parentMessage.flags, MCTMessageFlagAllowReply)) {
        [rightBarButtonItems addObject:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reply", nil)
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(onReplyClicked:)]];

        if (self.doubleTapGestureRecognizer == nil) {
            self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(onDoubleTap:)];
            self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
            [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
        }
    } else {
        if (self.doubleTapGestureRecognizer != nil) {
            [self.view removeGestureRecognizer:self.doubleTapGestureRecognizer];
            MCT_RELEASE(self.doubleTapGestureRecognizer);
        }
    }

    self.navigationItem.rightBarButtonItems = rightBarButtonItems;
}

- (void)viewWillAppear:(BOOL)animated
{
    T_UI();
    [super viewWillAppear:animated];
    if (self.selectedIndex != 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
    }
    self.selectedIndex = 0;
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self];

        NSMutableArray *dirties = [NSMutableArray array];
        for (MCTMessage *msg in self.messages)
            if (msg.dirty && ![self.messagesPlugin isTmpKey:msg.key])
                [dirties addObject:msg.key];

        if (self.isDynamicChat && self.parentMessage.dirty) {
            [dirties addObject:self.parentMessage.key];
        }

        if ([dirties count]) {
            NSString *bThreadKey = self.thread.key;
            NSArray *bDirties = dirties;
            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                [[[MCTComponentFramework messagesPlugin] store] setThreadReadWithKey:bThreadKey
                                                                    andDirtyMessages:bDirties];
            }];
        }

        if (!self.isDynamicChat && self.parentMessage.threadDirty && self.renderedMessages.count) {
            NSString *bThreadKey = self.thread.key;
            NSArray *bRenderedMessages = self.renderedMessages;
            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                [[MCTComponentFramework messagesPlugin] markAsReadWithParentKey:bThreadKey
                                                                 andMessageKeys:bRenderedMessages];
            }];
        }
    }
}

- (NSInteger)indexOfFirstUnReadMessage
{
    T_UI();
    for (NSInteger i = 0; i < [self.messages count]; i++) {
        MCTMessage *msg = [self.messages objectAtIndex:i];
        if (![msg.sender isEqualToString:self.myEmail] && ![msg isLocked]
                && !IS_FLAG_SET([msg memberWithEmail:self.myEmail].status, MCTMessageStatusAcked)) {
            return i;
        }
    }
    return NSNotFound;
}

- (void)addBorderToMemberView:(UIView *)memberView withMemberStatus:(MCTlong)status
{
    T_UI();
    UIColor *borderColor;
    if (IS_FLAG_SET(status, MCTMessageStatusAcked)) {
        borderColor = [UIColor colorWithString:@"0AC0FF"];
    } else if (IS_FLAG_SET(status, MCTMessageStatusReceived)) {
        borderColor = [UIColor colorWithString:@"97C201"];
    } else {
        borderColor = [UIColor colorWithString:@"FFE602"];
    }

    [MCTUIUtils addRoundedBorderToView:memberView withBorderColor:borderColor andCornerRadius:5];
    memberView.layer.borderWidth = 2;
}

- (void)updateMemberSummaryView
{
    T_UI();
    if (!self.isDynamicChat) {
        for (UIView *subview in self.scrollView.subviews)
            [subview removeFromSuperview];
    }

    self.threadMembers = [self.messagesPlugin.store membersStatusesInThread:self.thread.key];

    if (!self.isDynamicChat) {
        int i = 0, x = MS_PADDING, y = MS_PADDING;
        for (MCT_com_mobicage_to_messaging_MemberStatusTO *ms in self.threadMembers) {
            CGRect ctrlFrame = CGRectMake(x, y, MS_W, MS_W);
            UIControl *uiCtrl = [[UIControl alloc] initWithFrame:ctrlFrame];
            uiCtrl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            uiCtrl.tag = i++;
            [uiCtrl addTarget:self action:@selector(onParticipantTapped:) forControlEvents:UIControlEventTouchUpInside];

            CGRect avaFrame = ctrlFrame;
            avaFrame.origin = CGPointZero;
            UIImage *ava = [[MCTComponentFramework friendsPlugin] userAvatarImageByEmail:ms.member];
            UIImageView *avaView = [[UIImageView alloc] initWithImage:ava];
            avaView.frame = avaFrame;

            x += MS_SPACING + MS_W;

            [self addBorderToMemberView:avaView withMemberStatus:ms.status];
            
            [uiCtrl addSubview:avaView];
            [self.scrollView addSubview:uiCtrl];
        }
        self.scrollView.contentSize = CGSizeMake(MS_PADDING + i * MS_W + (i - 1) * MS_SPACING + MS_PADDING,
                                                 self.scrollView.frame.size.height);
    }
}

- (void)onParticipantTapped:(id)sender
{
    T_UI();
    UIControl *uiCtrl = sender;
    NSString *email = [[self.threadMembers objectAtIndex:uiCtrl.tag] member];
    [MCTMessageHelper onParticipantClicked:email inNavigationController:self.navigationController];
}

- (void)onReplyClicked:(id)sender
{
    T_UI();
    // Double check write permissions
    if (IS_FLAG_SET(self.parentMessage.flags, MCTMessageFlagAllowReply)) {
        [MCTMessageHelper onReplyClickedForMessage:self.parentMessage
                            inNavigationController:self.navigationController];
    }
}

- (void)onInfoClicked:(UIControl *)sender
{
    T_UI();
    [self.navigationController pushViewController:[MCTChatInfoVC viewControllerWithParentMessage:self.parentMessage]
                                         animated:YES];
}

- (void)alertThreadDeleted
{
    T_UI();
    LOG(@"alertThreadDeleted - %@", self.parentMessage.key);
    if (self.threadDeletePopupShown)
        return;

    self.threadDeletePopupShown = YES;

    if (self.view.window == nil) {
        // View is not being showed
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [viewControllers removeObject:self];
        [self.navigationController setViewControllers:viewControllers];
        return;
    }

    self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                   andText:NSLocalizedString(@"Conversation has been removed", nil)
                                                    andTag:MCT_TAG_THREAD_DELETED];
    self.currentAlertView.delegate = self;
}


#pragma mark - Attachments

- (void)onAttachmentClickedWithIndex:(NSInteger)attachmentIndex
                          forMessage:(MCTMessage *)message
{
    T_UI();
    assert(attachmentIndex < [message.attachments count]);
    self.selectedAttachmentIndex = attachmentIndex;
    self.selectedAttachmentMessage = message;

    MCTMessageAttachmentPreviewItem *preview = [message attachmentPreviewItemAtIndex:self.selectedAttachmentIndex];
    MCT_com_mobicage_to_messaging_AttachmentTO *attachment = [message.attachments objectAtIndex:self.selectedAttachmentIndex];

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

        if ([MCTUtils connectedToInternet]) {
            [self downloadAttachmentWithPreviewItem:preview];
        } else {
            self.currentAlertView = [MCTUIUtils showNetworkErrorAlert];
            self.currentAlertView.delegate = self;
        }
    }
}

- (void)downloadAttachmentWithPreviewItem:(MCTMessageAttachmentPreviewItem *)previewItem
{
    T_UI();
    MCT_com_mobicage_to_messaging_AttachmentTO *attachment = [self.selectedAttachmentMessage.attachments objectAtIndex:self.selectedAttachmentIndex];
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

        if (weakHttpRequest.responseStatusCode != 200) {
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
    MCT_com_mobicage_to_messaging_AttachmentTO *attachment = [self.selectedAttachmentMessage.attachments objectAtIndex:self.selectedAttachmentIndex];
    if ([attachment.content_type hasPrefix:@"video/"]) {
        MCTMessageAttachmentPreviewItem *preview = [self.selectedAttachmentMessage attachmentPreviewItemAtIndex:self.selectedAttachmentIndex];
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
    [self.tableView reloadData];
}


#pragma mark - MBProgressHUD

- (void)cleanupProgressHUD
{
    T_UI();
    self.currentProgressHUD.progress = 1;
    [self.currentProgressHUD hide:YES afterDelay:0.4];
    MCT_RELEASE(self.currentProgressHUD);
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
    MCTMessageAttachmentPreviewItem *preview = [self.selectedAttachmentMessage attachmentPreviewItemAtIndex:self.selectedAttachmentIndex];
    LOG(@"canPreviewItem: %@", BOOLSTR([QLPreviewController canPreviewItem:preview]));
    return preview;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    NSInteger count = [self.messages count];

    if (self.threadNeedsMyAnswer)
        count++;

    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    if (indexPath.row == [self.messages count]) {
        // Rogerthat button
        MCTRogerThatCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MCT_RT_IDENTIFIER];
        if (cell == nil) {
            cell = [MCTRogerThatCell cellWithMessage:self.parentMessage];
        }
        cell.ttBtn.enabled = YES;
        return cell;
    }

    MCTMessage *msg = self.messages[indexPath.row];
    CGFloat h = [MCTHumanMessageCell heightOfCellWithMessage:msg];
    NSString *ident = [NSString stringWithFormat:@"%f", h];
    MCTHumanMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        cell = [[MCTHumanMessageCell alloc] initWithReuseIdentifier:ident];
        cell.viewController = self;
    }
    cell.message = msg;
    if (![self.renderedMessages containsObject:msg.key])
        [self.renderedMessages addObject:msg.key];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    if (indexPath.row == [self.messages count]) {
        return 50;
    }
    return [MCTHumanMessageCell heightOfCellWithMessage:[self.messages objectAtIndex:indexPath.row]];
}


#pragma mark -
#pragma mark MCTIntent

- (void)registerIntents
{
    T_UI();
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:@[kINTENT_MESSAGE_MODIFIED,
                                                                      kINTENT_MESSAGE_RECEIVED,
                                                                      kINTENT_MESSAGE_SENT,
                                                                      kINTENT_IDENTITY_MODIFIED,
                                                                      kINTENT_MESSAGE_REPLACED,
                                                                      kINTENT_FRIEND_MODIFIED,
                                                                      kINTENT_FRIEND_REMOVED,
                                                                      kINTENT_THREAD_ACKED,
                                                                      kINTENT_THREAD_MODIFIED,
                                                                      kINTENT_THREAD_DELETED,
                                                                      kINTENT_USER_INFO_RETRIEVED,
                                                                      kINTENT_ATTACHMENT_CLICKED,
                                                                      kINTENT_ATTACHMENT_RETRIEVED,
                                                                      ]
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)unregisterIntents
{
    T_UI();
    [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_IDENTITY_MODIFIED) {
        [self.tableView reloadData];
        [self updateMemberSummaryView];
    }
    else if (intent.action == kINTENT_MESSAGE_RECEIVED || intent.action == kINTENT_MESSAGE_SENT) {
        if([self.thread.key isEqualToString:[intent stringForKey:@"parent_key"]]) {

            [self updateMemberSummaryView];

            NSString *key = [intent stringForKey:@"message_key"];
            BOOL found = NO;
            for (MCTMessage *msg in self.messages)
                if ([msg.key isEqualToString:key])
                    found = YES;

            if (!found) {
                MCTMessage *newMsg = [self.messagesPlugin.store messageDetailsByKey:key];
                if (newMsg) {
                    MCTMessage *previousMsg = [self.messages lastObject];
                    [self.messages addObject:newMsg];
                    if (newMsg.timestamp < previousMsg.timestamp) {
                        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
                        [self.messages sortUsingDescriptors:[NSArray arrayWithObject:sd]];
                    }
                    self.threadNeedsMyAnswer = !self.isDynamicChat && newMsg.threadNeedsMyAnswer;
                } else {
                    [self loadMessages];
                }
                [self.tableView reloadData];

                // Do not call tableview delegate to get number of rows, since it is not yet rendered
                // Instead calculate it ourself
                NSInteger scrollToRow = [self.messages count] - 1;
                if (self.threadNeedsMyAnswer)
                    scrollToRow++;

                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:scrollToRow inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

                if (!self.isDynamicChat && intent.action == kINTENT_MESSAGE_SENT) {
                    // Ack thread
                    NSString *pkey = [newMsg threadKey];
                    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                        [[MCTComponentFramework messagesPlugin] ackThreadWithKey:pkey];
                    }];
                } else {
                    [self.tableView flashScrollIndicators];
                }
            }
        }
    }
    else if (intent.action == kINTENT_MESSAGE_MODIFIED) {
        if (self.isDynamicChat && [[intent stringForKey:@"message_key"] isEqualToString:self.parentMessage.key]) {
            self.parentMessage = [self.messagesPlugin.store messageInfoByKey:self.parentMessage.key];
            self.chatData = [self.parentMessage.message MCT_JSONValue];
            self.title = self.chatData[@"t"];
        } else {
            for (int i = 0; i < [self.messages count]; i++) {
                MCTMessage *msg = [self.messages objectAtIndex:i];
                if ([[intent stringForKey:@"message_key"] isEqualToString:msg.key]) {
                    MCTMessage *updatedMsg = [self.messagesPlugin.store messageDetailsByKey:msg.key];
                    if ([intent hasBoolKey:@"existence_changed"] && [intent longForKey:@"existence"] == MCTMessageExistenceDeleted) {
                        [self.messages removeObjectAtIndex:i];
                    } else {
                        [self.messages replaceObjectAtIndex:i withObject:updatedMsg];
                    }
                    self.threadNeedsMyAnswer = updatedMsg.threadNeedsMyAnswer;
                    [self.tableView reloadData];
                    [self updateMemberSummaryView];

                    if ([intent hasBoolKey:@"needsMyAnswer_changed"]) {
                        if (!self.isDynamicChat) {
                            NSInteger unReadIndex = [self indexOfFirstUnReadMessage];
                            if (unReadIndex != NSNotFound) {
                                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:unReadIndex inSection:0]
                                                      atScrollPosition:UITableViewScrollPositionTop
                                                              animated:YES];
                            }
                        }
                    }
                    break;
                }
            }
        }
    }
    else if (intent.action == kINTENT_THREAD_ACKED) {
        if ([self.thread.key isEqualToString:[intent stringForKey:@"thread_key"]]) {
            [self loadMessages];
            [self.tableView reloadData];
            if ([self.messages count]) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count] - 1
                                                                          inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom
                                              animated:YES];
            }
            [self updateMemberSummaryView];
        }
    }
    else if (intent.action == kINTENT_THREAD_MODIFIED) {
        if ([self.thread.key isEqualToString:[intent stringForKey:@"thread_key"]]) {
            [self loadMessages];
            [self.tableView reloadData];
        }
    }
    else if (intent.action == kINTENT_MESSAGE_REPLACED) {
        NSString *tmpKey = [intent stringForKey:@"tmp_key"];
        for (int i = 0; i < [self.messages count]; i++) {
            MCTMessage *msg = [self.messages objectAtIndex:i];
            if ([tmpKey isEqualToString:msg.key]) {
                MCTMessage *newMsg = [self.messagesPlugin.store messageDetailsByKey:[intent stringForKey:@"key"]];
                [self.messages replaceObjectAtIndex:i withObject:newMsg];

                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                if ([[self.tableView indexPathsForVisibleRows] containsObject:indexPath]) {
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                          withRowAnimation:UITableViewRowAnimationNone];
                }
                break;
            }
        }
    }
    else if (intent.action == kINTENT_FRIEND_MODIFIED || intent.action == kINTENT_FRIEND_REMOVED) {
        for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in self.threadMembers) {
            if ([[intent stringForKey:@"email"] isEqualToString:member.member]) {
                [self.tableView reloadData];
                [self updateMemberSummaryView];
                break;
            }
        }
    }
    else if (intent.action == kINTENT_USER_INFO_RETRIEVED) {
        if ([intent boolForKey:@"success"]) {
            for (MCTMessage *message in self.messages) {
                if ([message.sender isEqualToString:[intent stringForKey:@"hash"]]) {
                    [self.tableView reloadData];
                    break;
                }
            }
        }
    }
    else if (intent.action == kINTENT_THREAD_DELETED) {
        if ([self.parentMessage.key isEqualToString:[intent stringForKey:@"key"]]) {
            [self alertThreadDeleted];
        }
    }
    else if (intent.action == kINTENT_ATTACHMENT_CLICKED) {
        NSString *key = [intent stringForKey:@"message_key"];
        for (MCTMessage *message in self.messages) {
            if ([key isEqualToString:message.key]) {
                [self onAttachmentClickedWithIndex:[intent longForKey:@"index"]
                                        forMessage:message];
                break;
            }
        }
    }
    else if (intent.action == kINTENT_ATTACHMENT_RETRIEVED) {
        if ([self.parentMessage.key isEqualToString:[intent stringForKey:@"thread_key"]]) {
            NSString *messageKey = [intent stringForKey:@"message_key"];
            for (int i = 0; i < [self.messages count]; i++) {
                MCTMessage *msg = [self.messages objectAtIndex:i];
                if ([messageKey isEqualToString:msg.key]) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    if ([[self.tableView indexPathsForVisibleRows] containsObject:indexPath]) {
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                              withRowAnimation:UITableViewRowAnimationFade];
                    }
                    break;
                }
            }
        }
    }
}

#pragma mark -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == MCT_TAG_THREAD_DELETED) {
        [self.navigationController popViewControllerAnimated:YES];
        MCT_RELEASE(self.currentAlertView);
    } else {
        MCTMessage *message = (MCTMessage *)self.activeObject;
        [MCTMessageHelper processAlertViewForVC:self clickedButtonAtIndex:buttonIndex forMessage:message];
    }
}

#pragma mark -
#pragma mark Gestures

- (IBAction)onSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    T_UI();
    MCTDefaultMessageListVC *msgListVC = nil;
    for (UIViewController *vc in [self.navigationController.viewControllers reverseObjectEnumerator]) {
        if ([vc isKindOfClass:[MCTDefaultMessageListVC class]]) {
            msgListVC = (MCTDefaultMessageListVC *) vc;
            break;
        }
    }
    if (msgListVC) {
        [msgListVC swipeBackwards:(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight)
                        fromThread:self.thread.key];
    }
}

- (IBAction)onDoubleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    T_UI();
    [self onReplyClicked:nil];
}

@end