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
#import "MCTDefaultFriendListVC.h"
#import "MCTFriendCell.h"
#import "MCTFriendsPlugin.h"
#import "MCTIntent.h"
#import "MCTServiceSearchVC.h"
#import "MCTUIUtils.h"


@implementation MCTDefaultFriendListVC

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    IF_IOS7_OR_GREATER({
        self.tableView.separatorInset = UIEdgeInsetsZero;
    });

    self.friendsPlugin = [MCTComponentFramework friendsPlugin];
    self.friendType = -1;
    self.stashedIntents = [NSMutableSet set];
    if (self.organizationType == 0) {
        // organizationType was not set --> set it to UNSPECIFIED
        self.organizationType = MCTServiceOrganizationTypeUnspecified;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    T_UI();
    HERE();
    [super setEditing:editing animated:animated];
    if (!editing) {
        for (MCTIntent *intent in [NSMutableSet setWithSet:self.stashedIntents]) {
            [self onIntent:intent];
            [self.stashedIntents removeObject:intent];
        }
    }
    self.navigationItem.hidesBackButton = editing;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    int c;
    if (self.filteredCategory) {
        c = [self.friendsPlugin.store countFriendsByCategory:self.filteredCategory];
        if (c == 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } else if (self.organizationType > 0) {
        c = [self.friendsPlugin.store countServicesByOrganizationType:self.organizationType];

        if (!self.searchAlertShown && c == 0
                && [MCT_SEARCH_SERVICES_IF_NONE_CONNECTED containsObject:@(self.organizationType)]) {
            NSString *format = NSLocalizedString(@"Would you like to search for %@ in your neighbourhood?", nil);
            self.currentAlertView = [[UIAlertView alloc] initWithTitle:self.title
                                                                message:[NSString stringWithFormat:format, self.title]
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"No", nil)
                                                      otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
            self.currentAlertView.tag = MCT_ALERT_TAG_ASK_TO_SEARCH_FOR_SERVICES;
            [self.currentAlertView show];
            self.searchAlertShown = YES;
        }

    } else if (self.friendType > 0) {
        c = [self.friendsPlugin.store countFriendsByType:self.friendType];
    } else {
        c = [self.friendsPlugin.store countFriends]; // XXX - Should not be used
    }
    
    self.editButtonItem.enabled = c > 0;
    if (c == 0 && self.editing) {
        [self setEditing:NO animated:YES];
    }

    return c;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTFriend *friend;
    if (self.filteredCategory) {
        friend = [self.friendsPlugin.store friendByCategory:self.filteredCategory andIndex:indexPath.row];
    } else if (self.organizationType > 0) {
        friend = [self.friendsPlugin.store serviceByOrganizationType:self.organizationType andIndex:indexPath.row];
    } else if (self.friendType > 0) {
        friend = [self.friendsPlugin.store friendByType:self.friendType andIndex:indexPath.row];
    } else {
        friend = [self.friendsPlugin.store friendByIndex:indexPath.row];
    }

    NSString *ident = [NSString stringWithFormat:@"%d", self.friendType];

    MCTFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        cell = [[MCTFriendCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:ident];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.textColor = [UIColor blackColor];
        [MCTUIUtils addRoundedBorderToView:cell.imageView];
    }
    
    if (friend.existence == MCTFriendExistenceInvitePending) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = spinner;
        [spinner startAnimating];
    } else {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.friend = friend;
    cell.textLabel.text = [friend displayName];
    cell.imageView.image = [friend avatarImage];

    if (friend.category.friendCount > 1) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, …", friend.name];
    } else {
        cell.detailTextLabel.text = nil;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    if (IS_ENTERPRISE_APP || self.friendType == MCTFriendTypeService) {
        return NSLocalizedString(@"Disconnect", nil);
    } else {
        return NSLocalizedString(@"Unfriend", nil);
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTFriendCell *cell = (MCTFriendCell *) [tableView cellForRowAtIndexPath:indexPath];
    if (cell.friend.category.friendCount > 1)
        return NO;
    if (IS_FLAG_SET(cell.friend.flags, MCTFriendFlagNotRemovable))
        return NO;
    return YES;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();    
    MCTFriendCell *cell = (MCTFriendCell *) [tableView cellForRowAtIndexPath:indexPath];
    [[MCTComponentFramework friendsPlugin] markFriendDeletePendingWithEmail:cell.friend.email];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationRight];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return 0;
}

#pragma mark -
#pragma mark IMCTIntentReceiver

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (self.editing) {
        [self.stashedIntents addObject:intent];
        return;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (alertView == self.currentAlertView) {
        if (alertView.tag == MCT_ALERT_TAG_ASK_TO_SEARCH_FOR_SERVICES) {
            if (buttonIndex != alertView.cancelButtonIndex) {
                MCTServiceSearchVC *vc = [MCTServiceSearchVC viewController];
                vc.organizationType = self.organizationType;
                vc.automaticSearchString = @"";
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        MCT_RELEASE(self.currentAlertView);
    }
}

@end