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
#import "MCTFriendDetailOrInviteVC.h"
#import "MCTIntent.h"
#import "MCTMessageDetailVC.h"
#import "MCTMessageHelper.h"
#import "MCTServiceMessageCell.h"
#import "MCTServiceMessageThreadVC.h"
#import "MCTTabMessagesVC.h"
#import "MCTUIUtils.h"


@interface MCTServiceMessageThreadVC ()

- (void)reloadMessage:(MCTMessage *)msg atIndex:(int)i animated:(BOOL)animated;
- (void)registerIntents;
- (void)unregisterIntents;

@end


@implementation MCTServiceMessageThreadVC


+ (MCTServiceMessageThreadVC *)viewControllerWithThread:(MCTMessageThread *)thread andSelectedIndex:(NSInteger)index
{
    T_UI();
    MCTServiceMessageThreadVC *vc = [[MCTServiceMessageThreadVC alloc] initWithNibName:@"serviceThread" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    vc.thread = thread;
    vc.selectedIndex = index;
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    [MCTUIUtils setBackgroundPlainToView:self.view];

    self.title = NSLocalizedString(@"Conversation", nil);
    self.messages = [NSMutableArray arrayWithArray:[[[MCTComponentFramework messagesPlugin] store] messagesInThread:self.thread.key]];

    self.tableView.backgroundColor = [UIColor clearColor];

    [MCTMessageHelper showSwipeHintInVC:self]; 

    UISwipeGestureRecognizer *swipeLeft =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipeLeft];

    UISwipeGestureRecognizer *swipeRight =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:swipeRight];

    [self registerIntents];
}

- (void)viewWillAppear:(BOOL)animated
{
    T_UI();
    [super viewWillAppear:animated];
    if (self.selectedIndex != 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.selectedIndex + 1) inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
    }
    self.selectedIndex = 0;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [self unregisterIntents];

        NSMutableArray *dirties = [NSMutableArray array];
        for (MCTMessage *msg in self.messages)
            if (msg.dirty)
                [dirties addObject:msg.key];

        if ([dirties count])
            [[MCTComponentFramework workQueue]
             addOperation:[MCTInvocationOperation operationWithTarget:[[MCTComponentFramework messagesPlugin] store]
                                                             selector:@selector(setThreadReadWithKey:andDirtyMessages:)
                                                              objects:self.thread.key, dirties, nil]];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    return [self.messages count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTMessage *msg = [self.messages objectAtIndex:MAX(0, indexPath.row - 1)];
    NSString *ident = [NSString stringWithFormat:@"%d", indexPath.row ? 1 : 0];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        if (indexPath.row == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
            cell.imageView.image = [[MCTComponentFramework friendsPlugin] friendAvatarImageByEmail:msg.sender];
            cell.textLabel.text = [[MCTComponentFramework friendsPlugin] friendDisplayNameByEmail:msg.sender];
            cell.detailTextLabel.text = [NSString stringWithFormat:@">> %@", msg.recipients];
            cell.detailTextLabel.numberOfLines = 1;

            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.textColor = [UIColor darkGrayColor];

            [MCTUIUtils addRoundedBorderToView:cell.imageView];
        } else {
            cell = [[MCTServiceMessageCell alloc] initWithReuseIdentifier:ident];
        }
    }
    if (indexPath.row != 0)
        ((MCTServiceMessageCell *)cell).message = msg;

    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == 0) {
        MCTMessage *pmsg = [self.messages objectAtIndex:0];
        [MCTMessageHelper onParticipantClicked:pmsg.sender inNavigationController:self.navigationController];
    } else {
        MCTServiceMessageCell *cell = (MCTServiceMessageCell *) [tableView cellForRowAtIndexPath:indexPath];
        UIViewController *vc = [MCTMessageDetailVC viewControllerWithMessageKey:cell.message.key];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    if (indexPath.row == 0)
        return 54;

    return [MCTServiceMessageCell heightWithMessage:[self.messages objectAtIndex:indexPath.row - 1]];
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

#pragma mark -
#pragma mark MCTIntent

- (void)reloadMessage:(MCTMessage *)msg atIndex:(int)i animated:(BOOL)animated
{
    T_UI();
    [self.messages replaceObjectAtIndex:i
                             withObject:[[[MCTComponentFramework messagesPlugin] store] messageDetailsByKey:msg.key]];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i+1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];

    if (self == self.navigationController.visibleViewController) {
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

- (void)registerIntents
{
    T_UI();
    NSArray *actions = [NSArray arrayWithObjects:kINTENT_MESSAGE_MODIFIED, kINTENT_MESSAGE_RECEIVED,
                        kINTENT_MESSAGE_SENT, kINTENT_MESSAGE_REPLACED, kINTENT_FRIEND_REMOVED, kINTENT_FRIEND_MODIFIED,
                        nil];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:actions
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)unregisterIntents
{
    T_UI();
    [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [MCTMessageHelper processAlertViewForVC:self clickedButtonAtIndex:buttonIndex forMessage:nil];
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_MESSAGE_RECEIVED || intent.action == kINTENT_MESSAGE_SENT) {
        if([self.thread.key isEqualToString:[intent stringForKey:@"parent_key"]]) {
            MCTMessage *newMsg = [[[MCTComponentFramework messagesPlugin] store] messageDetailsByKey:[intent stringForKey:@"message_key"]];

            BOOL inserted = NO;
            for (int i=0; i < [self.messages count]; i++) {
                MCTMessage *msg = [self.messages objectAtIndex:i];
                if (newMsg.timestamp < msg.timestamp) {
                    [self.messages insertObject:newMsg atIndex:i];
                    inserted = YES;
                    break;
                }
            }
            if (!inserted)
                [self.messages addObject:newMsg];

            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.messages indexOfObject:newMsg] + 1 inSection:0];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationBottom];

            if (inserted) {
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row + 1
                                                                                                   inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationNone];
            }

            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count] inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:YES];
        }
    }
    else if (intent.action == kINTENT_MESSAGE_MODIFIED) {
        for (int i = 0; i < [self.messages count]; i++) {
            MCTMessage *msg = [self.messages objectAtIndex:i];
            if ([[intent stringForKey:@"message_key"] isEqualToString:msg.key]) {
                [self reloadMessage:msg atIndex:i animated:YES];
                break;
            }
        }
    }
    else if (intent.action == kINTENT_MESSAGE_REPLACED) {
        for (int i = 0; i < [self.messages count]; i++) {
            MCTMessage *msg = [self.messages objectAtIndex:i];
            if ([[intent stringForKey:@"tmp_key"] isEqualToString:msg.key]) {
                msg.key = [intent stringForKey:@"key"];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i+1 inSection:0];
                if ([[self.tableView indexPathsForVisibleRows] containsObject:indexPath]) {
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                          withRowAnimation:UITableViewRowAnimationNone];
                }
                break;
            }
        }
    }
    else if (intent.action == kINTENT_FRIEND_REMOVED || intent.action == kINTENT_FRIEND_MODIFIED) {
        MCTMessage *msg = [self.messages objectAtIndex:0];
        if ([msg.sender isEqualToString:[intent stringForKey:@"email"]]) {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

@end