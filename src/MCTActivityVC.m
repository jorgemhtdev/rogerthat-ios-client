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

#import "MCTActivity.h"
#import "MCTActivityCellFactory.h"
#import "MCTActivityPlugin.h"
#import "MCTActivityVC.h"
#import "MCTComponentFramework.h"
#import "MCTFriend.h"
#import "MCTFriendDetailOrInviteVC.h"
#import "MCTFriendDetailVC.h"
#import "MCTIntent.h"
#import "MCTMessageDetailVC.h"
#import "MCTMessageHelper.h"
#import "MCTOperation.h"
#import "MCTServiceMenuVC.h"
#import "MCTUIUtils.h"


@interface MCTActivityVC ()

@property (nonatomic, strong) MCTActivityPlugin *activityPlugin;
@property (nonatomic, strong) MCTFriendsPlugin *friendsPlugin;
@property (nonatomic, strong) MCTMessagesPlugin *messagesPlugin;

- (void)refresh:(BOOL)force;

@end


@implementation MCTActivityVC


+ (MCTActivityVC *)viewController
{
    return [[MCTActivityVC alloc] initWithNibName:@"activity" bundle:nil];
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    [MCTUIUtils setBackgroundPlainToView:self.view];

    IF_PRE_IOS7({
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    });

    NSArray *intents = [NSArray arrayWithObjects:kINTENT_ACTIVITY_NEW, kINTENT_FRIEND_MODIFIED,
                                                 kINTENT_ACTIVITY_DELETED, nil];
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:intents
                                                            onQueue:[MCTComponentFramework mainQueue]];
    self.title = NSLocalizedString(@"Stream", nil);
    self.activityPlugin = [MCTComponentFramework activityPlugin];
    self.friendsPlugin = [MCTComponentFramework friendsPlugin];
    self.messagesPlugin = [MCTComponentFramework messagesPlugin];
}

- (void)viewWillAppear:(BOOL)animated
{
    T_UI();
    [super viewWillAppear:animated];
    [self refresh:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    [super viewDidDisappear:animated];
    if (self.newActivities > 0) {
        MCTInvocationOperation *op = [[MCTInvocationOperation alloc] initWithTarget:self.activityPlugin.store
                                                                            selector:@selector(updateLastReadActivityId)
                                                                              object:nil];
        [[MCTComponentFramework workQueue] addOperation:op];
    }

    if (![self.navigationController.viewControllers containsObject:self]) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
    }
}


- (void)refresh:(BOOL)force
{
    T_UI();
    int prevOldActivities = self.oldActivities;
    int prevNewActivities = self.newActivities;
    self.oldActivities = [self.activityPlugin.store countReadActivities];
    self.newActivities = [self.activityPlugin.store countUnreadActivities];
    if (force || prevNewActivities != self.newActivities || prevOldActivities != self.oldActivities) {
        [self.tableView reloadData];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource & UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    T_UI();
    return (section == 0 && self.newActivities > 0) ? 1 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    T_UI();
    CGRect frame = CGRectZero;
    if (section == 0 && self.newActivities > 0) {
        frame = CGRectMake(0, 0, tableView.bounds.size.width, 1);
    }
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor redColor];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    T_UI();
    if (self.newActivities > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    int count;
    if (section == 0 && self.newActivities > 0) {
        count = self.newActivities;
    } else {
        count = self.oldActivities;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    NSInteger index = indexPath.row;
    if (indexPath.section == 1) {
        index = indexPath.row + self.newActivities;
    }

    MCTActivity *activity = [self.activityPlugin.store activityByIndex:index];
    return [MCTActivityCellFactory tableView:tableView cellForActivity:activity];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    UIViewController *vc = nil;
    MCTActivityCell *cell = (MCTActivityCell *) [self tableView:tableView cellForRowAtIndexPath:indexPath];
    switch (cell.activity.type) {
        case MCTActivityLocationSent: {
            MCTFriend *friend = [self.friendsPlugin.store friendByEmail:cell.activity.friendReference];
            if (friend != nil) {
                if (friend.type == MCTFriendTypeService) {
                    MCTServiceMenuVC *detailVC = [MCTServiceMenuVC viewControllerWithService:friend];
                    vc = detailVC;
                } else {
                    MCTFriendDetailVC *detailVC = [MCTFriendDetailVC viewControllerWithFriend:friend];
                    vc = detailVC;
                }
            }
            break;
        }
        case MCTActivityServicePoked:
        case MCTActivityFriendAdded:
        case MCTActivityFriendUpdated:
        case MCTActivityFriendRemoved: {
            MCTFriend *friend = [self.friendsPlugin.store friendByEmail:cell.activity.reference];
            if (friend != nil) {
                if (friend.type == MCTFriendTypeService) {
                    MCTServiceMenuVC *detailVC = [MCTServiceMenuVC viewControllerWithService:friend];
                    vc = detailVC;
                } else {
                    MCTFriendDetailVC *detailVC = [MCTFriendDetailVC viewControllerWithFriend:friend];
                    vc = detailVC;
                }
            }
            break;
        }
        case MCTActivityFriendBecameFriend: {
            NSString *emailHash = [cell.activity.parameters stringForKey:MCT_ACTIVITY_RELATION_EMAIL];
            MCTFriend *relation = [self.friendsPlugin.store friendByEmailHash:emailHash];
            if (relation == nil) {
                relation = [MCTFriend aFriend];
                relation.avatarId = [[cell.activity.parameters valueForKey:MCT_ACTIVITY_RELATION_AVATARID] longLongValue];
                relation.email = emailHash;
                relation.name = [cell.activity.parameters stringForKey:MCT_ACTIVITY_RELATION_NAME];
                relation.type = [[cell.activity.parameters valueForKey:MCT_ACTIVITY_RELATION_TYPE] longLongValue];
                relation.existence = -1;
            }
            MCTFriendDetailOrInviteVC *detailVC = [MCTFriendDetailOrInviteVC viewControllerWithFriend:relation];
            vc = detailVC;
            break;
        }
        case MCTActivityMessageReceived:
        case MCTActivityMessageSent:
        case MCTActivityMessageReplyReceived:
        case MCTActivityMessageReplySent:
        case MCTActivityQuickReplyReceivedForMe:
        case MCTActivityQuickReplyReceivedForOther:
        case MCTActivityQuickReplySentForMe:
        case MCTActivityQuickReplySentForOther:
        case MCTActivityQuickReplyUndone:
        case MCTActivityMessageDismissedByMe:
        case MCTActivityMessageDismissedByOther:
        case MCTActivityMessageLockedByMe:
        case MCTActivityMessageLockedByOther: {
            MCTMessage *msg = [self.messagesPlugin.store messageInfoByParentKey:cell.activity.reference andIndex:0];
            if (msg)
                vc = [MCTMessageHelper viewControllerForMessage:msg];
            break;
        }
        case MCTActivityLogDebug:
        case MCTActivityLogError:
        case MCTActivityLogFatal:
        case MCTActivityLogInfo:
        case MCTActivityLogWarning:
            break;
        default:
            break;
    }

    if (vc != nil)
        [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return 80;
}

#pragma mark -
#pragma mark Intents

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    [self refresh:YES];
}

@end