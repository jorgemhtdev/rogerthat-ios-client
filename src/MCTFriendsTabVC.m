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

#import "MCTAddFriendsVC.h"
#import "MCTComponentFramework.h"
#import "MCTFriendDetailVC.h"
#import "MCTFriendCell.h"
#import "MCTIntent.h"
#import "MCTFriendsTabVC.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"
#import "MCTGroupCell.h"
#import "MCTGroupDetailVC.h"


#define MCT_FRIENDSTAB_SEGMENT_INDEX_FRIENDS 0
#define MCT_FRIENDSTAB_SEGMENT_INDEX_MAP     1

@interface MCTFriendsTabVC ()

@property (nonatomic) int selectedSegment;

- (void)onAddButtonClicked:(id)button;
- (void)setFriendsTitle;
- (void)setMapTitle;
- (void)hideVC:(UIViewController *)vc;
- (void)showVC:(UIViewController *)vc;

@end


@implementation MCTFriendsTabVC



- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    // Needed for ios 5
    return NO;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    // Needed for ios 6
    return NO;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    [MCTUIUtils setBackgroundPlainToView:self.view];

    self.friendType = MCTFriendTypeUser;

    switch (MCT_FRIENDS_CAPTION) {
        case MCTFriendsCaptionColleagues: {
            self.title = NSLocalizedString(@"Colleagues", nil);
            break;
        }
        case MCTFriendsCaptionContacts: {
            self.title = NSLocalizedString(@"Contacts", nil);
            break;
        }
        case MCTFriendsCaptionFriends:
        default: {
            self.title = NSLocalizedString(@"Friends", nil);
            break;
        }
    }

    self.addButtonItem = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                target:self
                                                action:@selector(onAddButtonClicked:)];

    self.navigationItem.rightBarButtonItem = self.addButtonItem;
    if (self == [self.navigationController.viewControllers firstObject]) {
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    }

    IF_IOS7_OR_GREATER({
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 5, 0, 0);
    });

    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"", @"", nil]];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.width = 210;
    [self.segmentedControl addTarget:self
                              action:@selector(onSegmentChanged:)
                    forControlEvents:UIControlEventValueChanged];

    [self setFriendsTitle];
    [self setMapTitle];
    self.navigationItem.titleView = self.segmentedControl;

    [self loadGroups];
    [self registerIntents];
}

- (void)dealloc
{
    T_UI();
    [self unregisterIntents];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    self.navigationItem.titleView = editing ? nil : self.segmentedControl;
    self.navigationItem.rightBarButtonItem = editing ? nil : self.addButtonItem;
}

- (void)setFriendsTitle
{
    T_UI();
    int count = [self.friendsPlugin.store countFriendsByType:MCTFriendTypeUser];
    [self.segmentedControl setTitle:[NSString stringWithFormat:@"%@ (%d)", self.title, count]
                  forSegmentAtIndex:MCT_FRIENDSTAB_SEGMENT_INDEX_FRIENDS];
}

- (void)setMapTitle
{
    T_UI();
    int sharingCount = [self.friendsPlugin.store countFriendsSharingLocation];
    [self.segmentedControl setTitle:[NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(@"Map", nil), sharingCount]
                  forSegmentAtIndex:MCT_FRIENDSTAB_SEGMENT_INDEX_MAP];
}

- (void)hideVC:(UIViewController *)vc
{
    T_UI();
    if (vc) {
        [vc viewWillDisappear:NO];
        [vc.view removeFromSuperview];
        [vc viewDidDisappear:NO];
    }
}

- (void)showVC:(UIViewController *)vc
{
    T_UI();

    [vc viewWillAppear:NO];

    CGRect frame = vc.view.frame;
    frame.size = self.view.frame.size;
    vc.view.frame = frame;
    [self.view addSubview:vc.view];

    [vc viewDidAppear:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.segmentedControl.selectedSegmentIndex == MCT_FRIENDSTAB_SEGMENT_INDEX_MAP)
        [self.mapVC viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.segmentedControl.selectedSegmentIndex == MCT_FRIENDSTAB_SEGMENT_INDEX_MAP)
         [self.mapVC viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.segmentedControl.selectedSegmentIndex == MCT_FRIENDSTAB_SEGMENT_INDEX_MAP)
        [self.mapVC viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.segmentedControl.selectedSegmentIndex == MCT_FRIENDSTAB_SEGMENT_INDEX_MAP)
        [self.mapVC viewDidDisappear:animated];
}



- (IBAction)onSegmentChanged:(id)sender
{
    T_UI();
    switch (self.segmentedControl.selectedSegmentIndex) {
        case MCT_FRIENDSTAB_SEGMENT_INDEX_FRIENDS:
            [self hideVC:self.mapVC];
            self.tableView.scrollEnabled = YES;
            self.editButtonItem.enabled = YES;
            break;

        case MCT_FRIENDSTAB_SEGMENT_INDEX_MAP:
            if (self.mapVC == nil)
                self.mapVC = [MCTMapVC viewController];
            self.tableView.scrollEnabled = NO;
            [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
            self.editButtonItem.enabled = NO;

            CGRect f = self.view.frame;
            f.origin = self.tableView.contentOffset;
            self.mapVC.view.frame = f;
            [self showVC:self.mapVC];
            break;

        default:
            break;
    }
}

- (void)onAddButtonClicked:(id)button
{
    T_UI();
    NSString *addButtonTitle;
    switch (MCT_FRIENDS_CAPTION) {
        case MCTFriendsCaptionColleagues: {
            addButtonTitle = NSLocalizedString(@"Add colleagues", nil);
            break;
        }
        case MCTFriendsCaptionContacts:{
            addButtonTitle = NSLocalizedString(@"Add contacts", nil);
            break;
        }
        case MCTFriendsCaptionFriends:
        default:{
            addButtonTitle = NSLocalizedString(@"Add friends", nil);
            break;
        }
    }
    self.currentActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"Create group", nil), addButtonTitle, nil];

    [MCTUIUtils showActionSheet:self.currentActionSheet inViewController:self];
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
    UITextField *textField = [self.currentAlertView textFieldAtIndex:0];
    textField.text = NSLocalizedString(@"no name", nil);
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [self.currentAlertView show];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    LOG(@"ButtonIndex hamburger menu: %d", buttonIndex);
    if (buttonIndex == 0) {
        [self onCreateGroupClicked];
    } else if(buttonIndex == 1)  {
        [self.navigationController pushViewController:[MCTAddFriendsVC viewController] animated:YES];
    }

    if (self.currentActionSheet == actionSheet) {
        MCT_RELEASE(self.currentActionSheet);
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
        return self.title;
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
            cell = [[MCTGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident infoViewEnabled:NO];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
            cell.textLabel.textColor = [UIColor blackColor];
            [MCTUIUtils addRoundedBorderToView:cell.imageView];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

        cell.group = group;
        cell.textLabel.text = [group name];
        cell.imageView.image = [group avatarImage];
        cell.detailTextLabel.text = nil;

        return cell;

    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    LOG(@"ButtonIndex create group: %d", buttonIndex);
    if (buttonIndex == 1) {
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
                                                       showComposeButton:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }

    if (self.currentAlertView == alertView) {
        MCT_RELEASE(self.currentAlertView);
    }
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

    return c;
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    if (indexPath.section == 0) {
        return NSLocalizedString(@"Delete group", nil);
    } else {
        return [super tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    if (indexPath.section == 0) {
        return YES;
    } else {
        return [super tableView:tableView canEditRowAtIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    if (indexPath.section == 0) {
        MCTGroupCell *cell = (MCTGroupCell *) [tableView cellForRowAtIndexPath:indexPath];
        [self.friendsPlugin.store deleteGroupWithGuid:cell.group.guid];
        [self.friendsPlugin deleteGroupWithGuid:cell.group.guid];
        [self loadGroups];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationRight];
    } else {
        [super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        MCTGroupDetailVC *groupDetailVC = [MCTGroupDetailVC viewControllerWithGroup:((MCTGroupCell *) cell).group
                                                                         isNewGroup:NO
                                                                  showComposeButton:YES];
        groupDetailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:groupDetailVC animated:YES];

    } else if (indexPath.section == 1) {
        MCTFriendDetailVC *friendDetailVC = [MCTFriendDetailVC viewControllerWithFriend:((MCTFriendCell *) cell).friend];
        friendDetailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:friendDetailVC animated:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Groups

- (void)loadGroups
{
    T_UI();
    self.groups = [self.friendsPlugin.store getGroups];

    self.groupIds = [self.groups keysSortedByValueUsingComparator:^NSComparisonResult(MCTGroup *group1, MCTGroup *group2) {
        return [group1.name caseInsensitiveCompare:group2.name];
    }];
}

#pragma mark -
#pragma mark Intent methods

- (void)registerIntents
{
    T_UI();
    NSArray *intentActions = [NSArray arrayWithObjects:kINTENT_FRIENDS_RETRIEVED, kINTENT_FRIEND_ADDED,
                              kINTENT_FRIEND_REMOVED, kINTENT_FRIEND_MODIFIED, kINTENT_RECIPIENTS_GROUP_ADDED,
                              kINTENT_RECIPIENTS_GROUP_MODIFIED, kINTENT_RECIPIENTS_GROUP_REMOVED, kINTENT_RECIPIENTS_GROUPS_UPDATED, nil];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:intentActions
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
    if (intent.action == kINTENT_RECIPIENTS_GROUPS_UPDATED || intent.action == kINTENT_RECIPIENTS_GROUP_ADDED
        || intent.action == kINTENT_RECIPIENTS_GROUP_MODIFIED || intent.action == kINTENT_RECIPIENTS_GROUP_REMOVED) {
        [self loadGroups];
    }

    [self.tableView reloadData];

    if (intent.action == kINTENT_FRIEND_MODIFIED) {
        [self setMapTitle];
    } else if (intent.action == kINTENT_FRIEND_ADDED || intent.action == kINTENT_FRIEND_REMOVED ||
               intent.action == kINTENT_FRIENDS_RETRIEVED) {
        [self setFriendsTitle];
    }
}

@end