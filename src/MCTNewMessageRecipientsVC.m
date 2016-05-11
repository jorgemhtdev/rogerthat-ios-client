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
#import "MCTFriendCell.h"
#import "MCTIdentity.h"
#import "MCTMessageEnums.h"
#import "MCTNewMessageRecipientsVC.h"
#import "MCTNewMessageTextVC.h"
#import "MCTSystemPlugin.h"
#import "MCTTransferObjects.h"
#import "MCTUIUtils.h"
#import "MCTGroup.h"
#import "MCTGroupCell.h"
#import "MCTCheckmarkView.h"
#import "MCTGroupDetailVC.h"


@interface MCTNewMessageRecipientsVC ()

@property (nonatomic, strong) NSMutableArray *selectedIndexPaths;
@property (nonatomic, strong) NSDictionary *groups;
@property (nonatomic, strong) NSArray *groupIds;
@property (nonatomic, strong) NSMutableArray *cannedGroups;

- (void)styleCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)toggleFriend:(MCTFriend *)friend withIndex:(NSIndexPath *)indexPath;
- (void)onRecipientAvatarClicked:(id)sender;
- (void)onGroupAvatarClicked:(id)sender;
- (void)onGroupInfoClicked:(id)sender;

@end


@implementation MCTNewMessageRecipientsVC


+ (MCTNewMessageRecipientsVC *)viewControllerWithRequest:(MCTSendMessageRequest *)request
{
    T_UI();
    MCTNewMessageRecipientsVC *vc = [[MCTNewMessageRecipientsVC alloc] initWithNibName:@"newMessageRecipients"
                                                                                 bundle:nil];
    vc.request = request;
    vc.friendsPlugin = [MCTComponentFramework friendsPlugin];
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    [MCTUIUtils addShadowToView:self.headerView];

    self.isReply = self.request.parent_key != nil;
    if (self.isReply) {
        self.toBccSwitch.enabled = !self.isReply;
        self.toBccSwitch.selectedSegmentIndex = ((self.request.flags & MCTMessageFlagAllowReplyAll) == 0) ? 1 : 0;
    }

    self.selectedIndexPaths = [NSMutableArray array];
    self.selectedRecipients = [NSMutableArray array];
    self.cannedGroups = [NSMutableArray array];
    self.toLabel.text = NSLocalizedString(@"To:", nil);

    [self loadGroups];
    [self loadRecipients];
    [self registerIntents];
}

- (void)loadRecipients
{
    if ([self.selectedRecipients count]) {
        // deselect all friends
        for (NSObject *recipient in [self.selectedRecipients reverseObjectEnumerator]) {
            if ([recipient isMemberOfClass:[MCTFriend class]]) {
                [self toggleFriend:(MCTFriend *)recipient withIndex:MCTNull];
            } else if ([recipient isMemberOfClass:[MCTGroup class]]) {
                [self toggleGroup:(MCTGroup *)recipient withIndex:MCTNull];
            } else {
                ERROR(@"Unknown recipient type while loading recipients");
            }
        }

        [self.tableView reloadData];
    }

    if ([self.request.members count] != 0) {
        MCTSystemPlugin *plugin = (MCTSystemPlugin *) [MCTComponentFramework pluginForClass:[MCTSystemPlugin class]];
        MCTIdentity *myIdentity = [plugin myIdentity];

        for (NSString *email in self.request.members) {
            // Don't show myself as recipient
            if (![myIdentity.email isEqualToString:email]) {
                MCTFriend *friend = [self.friendsPlugin.store friendByEmail:email];
                if (friend == nil) {
                    friend = [MCTFriend aFriend];
                    friend.email = email;
                }
                [self toggleFriend:friend withIndex:MCTNull];
            }
        }
    }

    for (NSString *guid in self.request.groupIds) {
        MCTGroup *group = [self.friendsPlugin.store getGroupWithGuid:guid];
        if (group != nil) {
            [self.cannedGroups addObject:group.guid];
        }
    }

    if ([self.request.members count] != 0 || [self.request.groupIds count] != 0)
        [self.tableView reloadData];
}

- (void)saveRecipients
{
    T_UI();
    if (self.request.parent_key == nil) {
        NSMutableArray *members = [NSMutableArray array];
        NSMutableArray *groupIds = [NSMutableArray array];

        if ([self.selectedRecipients count]) {
            for (NSObject *recipient in [self.selectedRecipients reverseObjectEnumerator]) {
                if ([recipient isMemberOfClass:[MCTFriend class]]) {
                    MCTFriend *friend = (MCTFriend *)recipient;
                    [members addObject:friend.email];
                } else if ([recipient isMemberOfClass:[MCTGroup class]]) {
                    MCTGroup *group = (MCTGroup *)recipient;
                    [groupIds addObject:group.guid];
                } else {
                    ERROR(@"Unknown recipient type while saving friends");
                }
            }
            [self.tableView reloadData];
        }
        self.request.members = members;
        self.request.groupIds = groupIds;
    } else {
        self.request.flags = 0;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    [super viewDidDisappear:animated];
    [self saveRecipients];
}

- (void)toggleGroup:(MCTGroup *)group withIndex:(NSIndexPath *)indexPath
{
    T_UI();
    CGFloat MARGIN = 1;
    CGFloat WIDTH = self.recipientsView.bounds.size.height;

    NSInteger count = [self.selectedIndexPaths count];

    NSInteger i = [self.selectedRecipients indexOfObject:group];

    if (i == NSNotFound) {
        CGFloat x = count * (WIDTH + MARGIN);
        UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(x, 0, WIDTH, WIDTH)];
        if (!self.isReply)
            [control addTarget:self action:@selector(onGroupAvatarClicked:) forControlEvents:UIControlEventTouchUpInside];

        UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH)];
        [MCTUIUtils addRoundedBorderToView:avatar];
        avatar.image = [group avatarImage];

        [control addSubview:avatar];

        [self.recipientsView insertSubview:control atIndex:count];

        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedRecipients addObject:group];
    } else {
        [self.selectedIndexPaths removeObjectAtIndex:i];
        [self.selectedRecipients removeObjectAtIndex:i];

        [[self.recipientsView.subviews objectAtIndex:i] removeFromSuperview];

        [UIView animateWithDuration:0.2 animations:^{
            for (NSInteger j = i; j < count - 1; j++) {
                UIView *control = [self.recipientsView.subviews objectAtIndex:j];
                CGRect frame = control.frame;
                frame.origin.x = j * (WIDTH + MARGIN);
                control.frame = frame;
            }
        }];
    }

    count = [self.selectedIndexPaths count];
    CGSize contentSize = CGSizeMake(count * (WIDTH + MARGIN), WIDTH);

    [UIView animateWithDuration:0.2 animations:^{
        self.recipientsView.contentSize = contentSize;
        if (contentSize.width > self.recipientsView.width) {
            self.recipientsView.contentOffset = CGPointMake(self.recipientsView.contentSize.width - self.recipientsView.width, 0);
        } else {
            self.recipientsView.contentOffset = CGPointZero;
        }
    }];

    self.navigationItem.rightBarButtonItem.enabled = ([self.selectedRecipients count] > 0);

}

- (void)toggleFriend:(MCTFriend *)friend withIndex:(NSIndexPath *)indexPath
{
    T_UI();
    CGFloat MARGIN = 1;
    CGFloat WIDTH = self.recipientsView.bounds.size.height;

    NSInteger count = [self.selectedIndexPaths count];

    NSInteger i = [self.selectedRecipients indexOfObject:friend];

    if (i == NSNotFound) {
        CGFloat x = count * (WIDTH + MARGIN);
        UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(x, 0, WIDTH, WIDTH)];
        if (!self.isReply)
            [control addTarget:self action:@selector(onRecipientAvatarClicked:) forControlEvents:UIControlEventTouchUpInside];

        UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH)];
        [MCTUIUtils addRoundedBorderToView:avatar];
        avatar.image = [friend avatarImage];

        [control addSubview:avatar];

        [self.recipientsView insertSubview:control atIndex:count];
        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedRecipients addObject:friend];
    } else {
        [self.selectedIndexPaths removeObjectAtIndex:i];
        [self.selectedRecipients removeObjectAtIndex:i];
        [[self.recipientsView.subviews objectAtIndex:i] removeFromSuperview];

        [UIView animateWithDuration:0.2 animations:^{
            for (NSInteger j = i; j < count - 1; j++) {
                UIView *control = [self.recipientsView.subviews objectAtIndex:j];
                CGRect frame = control.frame;
                frame.origin.x = j * (WIDTH + MARGIN);
                control.frame = frame;
            }
        }];
    }

    count = [self.selectedIndexPaths count];
    CGSize contentSize = CGSizeMake(count * (WIDTH + MARGIN), WIDTH);

    [UIView animateWithDuration:0.2 animations:^{
        self.recipientsView.contentSize = contentSize;
        if (contentSize.width > self.recipientsView.width) {
            self.recipientsView.contentOffset = CGPointMake(self.recipientsView.contentSize.width - self.recipientsView.width, 0);
        } else {
            self.recipientsView.contentOffset = CGPointZero;
        }
    }];
    
    self.navigationItem.rightBarButtonItem.enabled = ([self.selectedRecipients count] > 0);
}

- (void)onGroupAvatarClicked:(UIControl *)control
{
    T_UI();
    NSInteger i = [self.recipientsView.subviews indexOfObject:control];

    NSIndexPath *indexPath = [self.selectedIndexPaths objectAtIndex:i];
    if (indexPath != MCTNull && [self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    } else {
        [self toggleGroup:[self.selectedRecipients objectAtIndex:i] withIndex:indexPath];
    }
}

- (void)onRecipientAvatarClicked:(UIControl *)control
{
    T_UI();
    NSInteger i = [self.recipientsView.subviews indexOfObject:control];

    NSIndexPath *indexPath = [self.selectedIndexPaths objectAtIndex:i];
    if (indexPath != MCTNull && [self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    } else {
        [self toggleFriend:[self.selectedRecipients objectAtIndex:i] withIndex:indexPath];
    }
}

- (void)onGroupInfoClicked:(UIButton *)control
{
    T_UI();
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:control.tag inSection:0];

    MCTGroupCell *cell = (MCTGroupCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil) {
        MCTGroupDetailVC *vc = [MCTGroupDetailVC viewControllerWithGroup:cell.group
                                                              isNewGroup:NO
                                                       showComposeButton:NO];
        [self.sendMessageViewController.navigationController pushViewController:vc animated:YES];
    }
}

- (void)styleCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    BOOL isSelected = [self.selectedIndexPaths containsObject:indexPath];
    cell.textLabel.textColor = isSelected ? [UIColor MCTSelectedCellTextColor] : [UIColor blackColor];
    cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    if (indexPath.section != 0 && self.isReply) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    T_UI();
    if (section == 0) {
        return NSLocalizedString(@"Groups", nil);
    }
    if (section == 1) {
        switch (MCT_FRIENDS_CAPTION) {
            case MCTFriendsCaptionColleagues:
                return NSLocalizedString(@"Colleagues", nil);
            case MCTFriendsCaptionContacts:
                return NSLocalizedString(@"Contacts", nil);
            case MCTFriendsCaptionFriends:
            default:
                return NSLocalizedString(@"Friends", nil);
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    if (indexPath.section == 0) {
        MCTGroup *group = [self.groups objectForKey:[self.groupIds objectAtIndex:indexPath.row]];

        NSString *ident = @"group";
        MCTGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        if (cell == nil) {
            cell = [[MCTGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident infoViewEnabled:YES];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
            cell.textLabel.textColor = [UIColor blackColor];
            [MCTUIUtils addRoundedBorderToView:cell.imageView];
            [cell.infoButton addTarget:self
                                action:@selector(onGroupInfoClicked:)
                      forControlEvents:UIControlEventTouchUpInside];
        }

        cell.group = group;
        cell.textLabel.text = [group name];
        cell.imageView.image = [group avatarImage];
        cell.detailTextLabel.text = nil;
        cell.infoButton.tag = indexPath.row;

        if([self.cannedGroups containsObject:cell.group.guid]) {
            [self toggleGroup:cell.group withIndex:indexPath];
            [self.cannedGroups removeObject:cell.group.guid];
        }

        NSInteger i = [self.selectedRecipients indexOfObject:cell.group];
        if (i != NSNotFound && [self.selectedIndexPaths objectAtIndex:i] == MCTNull) {
            [self.selectedIndexPaths replaceObjectAtIndex:i withObject:indexPath];
        }
        [self styleCell:cell forRowAtIndexPath:indexPath];
        return cell;

    } else {
        MCTFriend *friend = [self.friendsPlugin.store friendByType:MCTFriendTypeUser andIndex:indexPath.row];

        NSString *ident = [NSString stringWithFormat:@"%d", MCTFriendTypeUser];
        MCTFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        if (cell == nil) {
            cell = [[MCTFriendCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                         reuseIdentifier:ident];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
            cell.textLabel.textColor = [UIColor blackColor];
            [MCTUIUtils addRoundedBorderToView:cell.imageView];
        }


        cell.friend = friend;
        cell.textLabel.text = [friend displayName];
        cell.imageView.image = [friend avatarImage];

        if (friend.category.friendCount > 1) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, …", friend.name];
        } else {
            cell.detailTextLabel.text = nil;
        }

        NSInteger i = [self.selectedRecipients indexOfObject:cell.friend];
        if (i != NSNotFound && [self.selectedIndexPaths objectAtIndex:i] == MCTNull) {
            [self.selectedIndexPaths replaceObjectAtIndex:i withObject:indexPath];
        }
        [self styleCell:cell forRowAtIndexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    NSInteger c = 0;

    if (section == 0) {
        c = [self.groups count];
    } else if (section == 1) {
        c = [self.friendsPlugin.store countFriendsByType:MCTFriendTypeUser];
    }

    self.editButtonItem.enabled = YES;
    if (c == 0 && self.editing) {
        [self setEditing:NO animated:YES];
    }
    return c;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    if (self.isReply)
        return;

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        [self toggleGroup:((MCTGroupCell *) cell).group withIndex:indexPath];
    } else if (indexPath.section == 1) {
        [self toggleFriend:((MCTFriendCell *) cell).friend withIndex:indexPath];
    }

    [self styleCell:cell forRowAtIndexPath:indexPath];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.currentAlertView) {
        MCT_RELEASE(self.currentAlertView);
    }
}

- (void)registerIntents
{
    T_UI();
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:[NSArray arrayWithObjects:
                                                                     kINTENT_RECIPIENTS_GROUP_ADDED,
                                                                     kINTENT_RECIPIENTS_GROUP_MODIFIED,
                                                                     kINTENT_RECIPIENTS_GROUP_REMOVED,
                                                                     kINTENT_RECIPIENTS_GROUPS_UPDATED,
                                                                     nil]
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)loadGroups
{
    T_UI();
    self.groups = [self.friendsPlugin.store getGroups];

    self.groupIds = [self.groups keysSortedByValueUsingComparator:^NSComparisonResult(MCTGroup *group1, MCTGroup *group2) {
        return [group1.name caseInsensitiveCompare:group2.name];
    }];
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_RECIPIENTS_GROUP_ADDED || intent.action == kINTENT_RECIPIENTS_GROUP_MODIFIED
        || intent.action == kINTENT_RECIPIENTS_GROUP_REMOVED) {
        if (intent.action == kINTENT_RECIPIENTS_GROUP_REMOVED) {
            NSString *guid  =  [intent stringForKey:@"guid"];
            MCTGroup *group = [self.groups objectForKey:guid];

            if (group != nil) {
                if ([self.selectedRecipients containsObject:group]) {
                    [self toggleGroup:group withIndex:MCTNull];
                }
            }
        }
        [self loadGroups];
        [self.tableView reloadData];
    } else if (intent.action == kINTENT_RECIPIENTS_GROUPS_UPDATED) {
        [self loadGroups];
        [self loadRecipients];
        [self.tableView reloadData];
    }
}

@end