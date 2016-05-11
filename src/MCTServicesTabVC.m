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
#import "MCTIntent.h"
#import "MCTServiceMenuVC.h"
#import "MCTServiceDetailVC.h"
#import "MCTServiceSearchVC.h"
#import "MCTServicesTabVC.h"
#import "MCTUIUtils.h"


@interface MCTServicesTabVC ()

- (void)registerIntents;
- (void)unregisterIntents;

@end


@implementation MCTServicesTabVC

+ (MCTServicesTabVC *)viewController
{
    T_UI();
    return [[MCTServicesTabVC alloc] initWithNibName:@"servicesList" bundle:nil];
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    [MCTUIUtils setBackgroundPlainToView:self.view];
    self.friendType = MCTFriendTypeService;

    if (self.filteredCategory == nil) {
        if (IS_CITY_APP) {
            if (self.organizationType == MCTServiceOrganizationTypeCity) {
                self.title = NSLocalizedString(@"Community Services", nil);
            } else if (self.organizationType == MCTServiceOrganizationTypeProfit) {
                self.title = NSLocalizedString(@"Merchants", nil);
            } else if (self.organizationType == MCTServiceOrganizationTypeNonProfit) {
                self.title = NSLocalizedString(@"Associations", nil);
            } else if (self.organizationType == MCTServiceOrganizationTypeEmergency) {
                self.title = NSLocalizedString(@"Care", nil);
            } else {
                self.title = NSLocalizedString(@"Services", nil);
            }
        } else {
            self.title = NSLocalizedString(@"Services", nil);
        }

        self.searchButtonItem = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                       target:self
                                                       action:@selector(onSearchServiceButtonTapped:)];

        self.navigationItem.rightBarButtonItem = self.searchButtonItem;
        if (self == [self.navigationController.viewControllers firstObject]) {
            self.navigationItem.leftBarButtonItem = self.editButtonItem;
        }
    } else {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }

    [self registerIntents];
}

- (void)onSearchServiceButtonTapped:(id)sender
{
    T_UI();
    MCTServiceSearchVC *vc = [MCTServiceSearchVC viewController];
    if (IS_CITY_APP) {
        vc.organizationType = self.organizationType;
    } else {
        vc.organizationType = MCTServiceOrganizationTypeUnspecified;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    T_UI();
    [super setEditing:editing animated:animated];
    if (self.filteredCategory == nil) {
        self.navigationItem.rightBarButtonItem = editing ? nil : self.searchButtonItem;
    }
}

#pragma mark -
#pragma mark IMCTIntentReceiver

- (void)registerIntents
{
    T_UI();
    NSArray *actions = [NSArray arrayWithObjects:kINTENT_FRIENDS_RETRIEVED, kINTENT_FRIEND_ADDED,
                          kINTENT_FRIEND_REMOVED, kINTENT_FRIEND_MODIFIED, nil];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:actions
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

    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UITableViewDataDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTFriendCell *cell = (MCTFriendCell *)[tableView cellForRowAtIndexPath:indexPath];

    if (cell.friend.category.friendCount > 1) {
        MCTServicesTabVC *vc = [MCTServicesTabVC viewController];
        vc.filteredCategory = cell.friend.category.idX;
        vc.title = cell.friend.category.name;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (cell.friend.existence == MCTFriendExistenceInvitePending) {
        MCTServiceDetailVC *vc = [MCTServiceDetailVC viewControllerWithService:cell.friend];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        MCTServiceMenuVC *vc = [MCTServiceMenuVC viewControllerWithService:cell.friend];
        [self.navigationController pushViewController:vc animated:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end