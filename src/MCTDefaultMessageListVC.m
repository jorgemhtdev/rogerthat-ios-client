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
#import "MCTDefaultMessageListVC.h"
#import "MCTFriendsPlugin.h"
#import "MCTMemberStatusSummaryEncoding.h"
#import "MCTMessageCell.h"
#import "MCTMessageHelper.h"
#import "MCTMessagesPlugin.h"
#import "MCTMessageThread.h"
#import "MCTUIUtils.h"


@interface MCTDefaultMessageListVC ()

@property (nonatomic) MCTlong lastTimeReloadAll;

- (void)bindEditButton;
- (void)bindDeleteButton;

@end


@implementation MCTDefaultMessageListVC


+ (MCTDefaultMessageListVC *)viewController
{
    T_UI();
    MCTDefaultMessageListVC *vc = [[MCTDefaultMessageListVC alloc] init];
    return vc;
}


- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    [MCTUIUtils setBackgroundPlainToView:self.view];
    [MCTUIUtils setBackgroundPlainToView:self.tableView];
    self.plugin = [MCTComponentFramework messagesPlugin];
    self.friendsPlugin = [MCTComponentFramework friendsPlugin];
    self.navigationItem.title = self.title = NSLocalizedString(@"Messages", nil);
    self.stashedIntents = [NSMutableSet set];

    [self bindEditButton];
    self.editButtonItem.action = @selector(onEditButtonClicked:);

    [self registerIntents];
    [self reloadThreads];

    IF_IOS5_OR_GREATER({
        UIBarButtonItem *flexibleSpaceBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];

        UIBarButtonItem *selectAllBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select all", nil)
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(onSelectAllClicked:)];

        UIBarButtonItem *deselectAllBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Deselect all", nil)
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(onDeselectAllClicked:)];

        // Max width buttons
        CGFloat w = [MCTUIUtils availableSizeForViewWithController:self].width / 2 - 10;
        if (w >= selectAllBtn.width && w >= deselectAllBtn.width) {
            selectAllBtn.width = deselectAllBtn.width = w;
        }

        self.deleteButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil)
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(onDeleteClicked:)];
        self.deleteButtonItem.tintColor = RGBCOLOR(204, 51, 51);

        self.toolbarItems = [NSArray arrayWithObjects:selectAllBtn, flexibleSpaceBtn, deselectAllBtn, nil];
    });

    IF_IOS7_OR_GREATER({
        self.tableView.separatorInset = UIEdgeInsetsZero;
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    T_UI();
    [super viewWillDisappear:animated];
    if (self.navigationController == nil || ![self.navigationController.viewControllers containsObject:self]) {
        [self unregisterIntents];
        for (MCTMessageCell *cell in [self.tableView visibleCells]) {
            [[MCTComponentFramework intentFramework] unregisterIntentListener:cell];
        }
    }
}

- (void)bindEditButton
{
    T_UI();
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)bindDeleteButton
{
    T_UI();
    self.navigationItem.leftBarButtonItem = self.tableView.allowsMultipleSelectionDuringEditing ? self.deleteButtonItem : nil;
}

- (void)onEditButtonClicked:(id)sender
{
    T_UI();
    BOOL editing = !self.editing;

    IF_IOS5_OR_GREATER({
        self.tableView.allowsMultipleSelectionDuringEditing = editing;
    });

    [self setEditing:editing animated:YES];
}

// Edit button was tapped, or user swiped on a message cell
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    T_UI();
    if (!editing) {
        self.tableView.allowsMultipleSelectionDuringEditing = NO;
    }
    [self.navigationController setToolbarHidden:!self.tableView.allowsMultipleSelectionDuringEditing animated:YES];

    [super setEditing:editing animated:animated];

    if (self.tableView.allowsMultipleSelectionDuringEditing) {
        [self setDeleteBtnTitle];
        self.editButtonItem.title = NSLocalizedString(@"Cancel", nil); // instead of 'Done'
    }

    if (!editing) {
        for (MCTIntent *intent in [NSMutableSet setWithSet:self.stashedIntents]) {
            [self onIntent:intent];
            [self.stashedIntents removeObject:intent];
        }
    }
    self.navigationItem.hidesBackButton = editing;
    [self bindDeleteButton];
}

- (void)reloadThreads
{
    T_UI();
    if (self.filter) {
        switch (self.filter.type) {
            case MCTMessageFilterByFriend:
            case MCTMessageFilterByService:
                self.threads = [NSMutableArray arrayWithArray:[self.plugin.store messageThreadsByMember:self.filter.argument]];
                break;
            case MCTMessageFilterByThread:
                self.threads = [NSMutableArray arrayWithObject:[self.plugin.store messageThreadByKey:self.filter.argument]];
                break;
            default:
                ERROR(@"Unknown filter type %d", self.filter.type);
                break;
        }
    }
    else
        self.threads = [NSMutableArray arrayWithArray:[self.plugin.store messageThreads]];
}

#pragma mark -
#pragma mark IBActions

- (void)setDeleteBtnTitle
{
    T_UI();
    NSInteger c = [[self.tableView indexPathsForSelectedRows] count];
    self.deleteButtonItem.title = c > 0 ? [NSString stringWithFormat:NSLocalizedString(@"Delete (%d)", nil), c]
                                 : NSLocalizedString(@"Delete", nil);
    self.deleteButtonItem.enabled = c > 0;
}

- (void)onDeleteClicked:(id)sender
{
    T_UI();
    NSMutableArray *toBeDeleted = [NSMutableArray array];
    NSArray *originalThreads = [NSArray arrayWithArray:self.threads];

    [self.tableView beginUpdates];

    for (NSIndexPath *indexPath in [NSArray arrayWithArray:[self.tableView indexPathsForSelectedRows]]) {
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationRight];
        MCTMessageThread *thread = [originalThreads objectAtIndex:indexPath.row];
        [toBeDeleted addObject:thread.key];
        [self.threads removeObject:thread];
    }

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        [[MCTComponentFramework messagesPlugin] deleteConversations:toBeDeleted];
    }];

    [self setEditing:NO animated:YES];

    [self.tableView endUpdates];
}

- (void)onSelectAllClicked:(id)sender
{
    T_UI();
    [self.tableView beginUpdates];

    NSInteger sections = [self.tableView numberOfSections];
    for (NSInteger section = 0; section < sections; section++) {
        NSInteger rows = [self.tableView numberOfRowsInSection:section];
        for (int row = 0; row < rows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            if ([self tableView:self.tableView canEditRowAtIndexPath:indexPath]) {
                [self.tableView selectRowAtIndexPath:indexPath
                                            animated:NO
                                      scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
    [self.tableView endUpdates];

    [self setDeleteBtnTitle];
}

- (void)onDeselectAllClicked:(id)sender
{
    T_UI();
    [self.tableView beginUpdates];

    NSInteger sections = [self.tableView numberOfSections];
    for (int section = 0; section < sections; section++) {
        NSInteger rows = [self.tableView numberOfRowsInSection:section];
        for (int row = 0; row < rows; row++) {
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]
                                          animated:NO];
        }
    }
    [self.tableView endUpdates];

    [self setDeleteBtnTitle];
}

#pragma mark -
#pragma mark UITableViewDelegate & UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    NSUInteger c = [self.threads count];
    self.editButtonItem.enabled = c > 0;
    if (c == 0 && self.editing) {
        [self setEditing:NO animated:YES];
    }
    return c;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTMessageThread *thread = [self.threads objectAtIndex:indexPath.row];
    MCTMessage *msg = [self.plugin.store messageDetailsByKey:thread.visibleMessage];
    msg.priority = thread.priority;
    msg.unreadCount = thread.unreadcount;

    static NSString *ident = @"MessageListIdent";
    MCTMessageCell *cell = (MCTMessageCell *) [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        MCTMessageFilterType filterType = self.filter ? self.filter.type : MCTMessageFilterNone;
        cell = [[MCTMessageCell alloc] initWithReuseIdentifier:ident andFilterType:filterType];
    }
    cell.message = msg;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    if (tableView.editing) {
        if ([self tableView:tableView canEditRowAtIndexPath:indexPath]) {
            [self setDeleteBtnTitle];
        } else {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        return;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    MCTMessageCell *cell = (MCTMessageCell *) [tableView cellForRowAtIndexPath:indexPath];
    if (cell.message.parent_key == nil && cell.message.recipientsStatus == kMemberStatusSummaryError) {
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:NSLocalizedString(@"Failed to deliver the message.", nil)];
    }
    else if (cell.message.parent_key == nil && [self.plugin isTmpKey:cell.message.key]) {
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:NSLocalizedString(@"Message not yet on server.", nil)];
    }
    else {
        MCTMessageThread *thread = [self.threads objectAtIndex:indexPath.row];
        UIViewController *vc = [MCTMessageHelper viewControllerForThread:thread
                                                             withMessage:cell.message
                                                        andSelectedIndex:thread.replyCount - 1];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    if (tableView.editing) {
        [self setDeleteBtnTitle];
        return;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCTMessageThread *thread = self.threads[indexPath.row];
    return !IS_FLAG_SET(thread.flags, MCTMessageFlagNotRemovable);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    NSArray *threadKeys = [NSArray arrayWithObject:((MCTMessageThread *) [self.threads objectAtIndex:indexPath.row]).key];
    [self.threads removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationRight];

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        [[MCTComponentFramework messagesPlugin] deleteConversations:threadKeys];
    }];
}

#pragma mark -

- (void)swipeBackwards:(BOOL)backwards fromThread:(NSString *)threadKey
{
    T_UI();
    LOG(@"Swiping to %@ thread", backwards ? @"previous" : @"next");
    for (int i = 0; i < [self.threads count]; i++) {
        MCTMessageThread *thread = [self.threads objectAtIndex:i];
        if ([thread.key isEqualToString:threadKey]) {
            int newIndex = i;
            while (YES) {
                 newIndex += (backwards ? -1 : 1);

                if (newIndex < 0 || newIndex >= [self.threads count]) {
                    LOG(@"There is no thread %@ this one.", backwards ? @"before" : @"after");
                    return;
                }

                MCTMessageThread *newThread = [self.threads objectAtIndex:newIndex];
                MCTMessage *msg = [self.plugin.store messageDetailsByKey:newThread.key];

                if (msg.recipientsStatus == kMemberStatusSummaryError) {
                    LOG(@"Thread %d its parent message is in ERROR state", newIndex);
                    continue;
                }

                if ([self.plugin isTmpKey:msg.key]) {
                    LOG(@"Thread %d is undelivered", newIndex);
                    continue;
                }

                UIViewController *vc = [MCTMessageHelper threadViewControllerForThread:newThread
                                                                     withParentMessage:msg];
                if (vc) {
                    NSMutableArray *vcs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                    if (backwards) {
                        [vcs insertObject:vc atIndex:[vcs count] - 1];
                        self.navigationController.viewControllers = vcs;
                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        [vcs replaceObjectAtIndex:[vcs count] - 1 withObject:vc];
                        [self.navigationController setViewControllers:vcs animated:YES];
                    }
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:NO];

                    return;
                }
            }
        }
    }
    ERROR(@"Thread with key %@ not found", threadKey);
}

#pragma mark -
#pragma mark IMCTIntentReceiver

- (void)registerIntents
{
    T_UI();
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:@[kINTENT_MESSAGE_RECEIVED,
                                                                      kINTENT_MESSAGE_SENT,
                                                                      kINTENT_MESSAGE_REPLACED,
                                                                      kINTENT_MESSAGE_MODIFIED,
                                                                      kINTENT_THREAD_ACKED,
                                                                      kINTENT_THREAD_DELETED,
                                                                      kINTENT_THREAD_RESTORED,
                                                                      kINTENT_THREAD_MODIFIED,
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
    if (self.editing) {
        [self.stashedIntents addObject:intent];
        return;
    }

    if (intent.action == kINTENT_MESSAGE_REPLACED) {
        // Update key in cached thread info
        for (MCTMessageThread *thread in self.threads) {
            BOOL found = NO;
            if ([thread.key isEqualToString:[intent stringForKey:@"tmp_key"]]) {
                thread.key = [intent stringForKey:@"key"];
                found = YES;
            }
            if ([thread.visibleMessage isEqualToString:[intent stringForKey:@"tmp_key"]]) {
                thread.visibleMessage = [intent stringForKey:@"key"];
                found = YES;
            }
            if (found) {
                break;
            }
        }
    }
    else if (intent.action == kINTENT_MESSAGE_RECEIVED || intent.action == kINTENT_MESSAGE_SENT ||
             intent.action == kINTENT_THREAD_ACKED || intent.action == kINTENT_THREAD_RESTORED ||
             intent.action == kINTENT_THREAD_MODIFIED ||
             (intent.action == kINTENT_MESSAGE_MODIFIED && ([intent hasBoolKey:@"needsMyAnswer_changed"]
                                                            || [intent hasBoolKey:@"dirty_changed"] || [intent hasBoolKey:@"existence_changed"]))) {
        // Reload data
        if (self.lastTimeReloadAll < intent.creationTimestamp) {
            [self reloadThreads];
            [self.tableView reloadData];
            self.lastTimeReloadAll = intent.creationTimestamp;
        }
    }
    else if (intent.action == kINTENT_THREAD_DELETED) {
        if (self.lastTimeReloadAll < intent.creationTimestamp) {
            for (MCTMessageThread *thread in self.threads) {
                if ([thread.key isEqualToString:[intent stringForKey:@"key"]]) {
                    // Reload data
                    [self reloadThreads];
                    [self.tableView reloadData];
                    self.lastTimeReloadAll = intent.creationTimestamp;
                    break;
                }
             }
        }
    }
}

@end