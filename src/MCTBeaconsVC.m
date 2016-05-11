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

#import "MCTBeaconsVC.h"
#import "MCTFinishRegistration.h"
#import "MCTUtils.h"
#import "MCTComponentFramework.h"
#import "MCTDiscoveredFriendCell.h"
#import "MCTUIUtils.h"

@interface MCTBeaconsVC ()

@property (nonatomic, strong) NSMutableArray *selectedBeacons;

@end

@implementation MCTBeaconsVC

+ (MCTBeaconsVC *)viewControllerWithDiscoveredBeacons:(NSArray *)beacons showProfile:(BOOL)showProfile;
{
    MCTBeaconsVC *vc = [[MCTBeaconsVC alloc] initWithNibName:@"beacons" bundle:nil];
    vc.discoveredBeacons = beacons;
    vc.showProfile = showProfile;
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.hidesBottomBarWhenPushed = YES;

    self.connectButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add to my services", nil)
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(onConnectClicked:)];

    self.cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Skip", nil)
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(onCancelClicked:)];

    self.navigationItem.rightBarButtonItem = self.connectButtonItem;
    self.navigationItem.leftBarButtonItem = self.cancelButtonItem;

    self.selectedBeacons = [NSMutableArray array];

    for (NSDictionary *beacon in self.discoveredBeacons) {
        [self.selectedBeacons addObject:[beacon stringForKey:@"friend_email"]];
    }

    LOG(@"self.selectedBeacons = %@", self.selectedBeacons);
}

- (void)onConnectClicked:(id)sender
{
    T_UI();

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        for (NSString *email in self.selectedBeacons){
            [[MCTComponentFramework friendsPlugin] inviteFriendWithEmail:email andMessage:nil];
        }
    }];

    [self finishScreen];
}

- (void)onCancelClicked:(id)sender
{
    T_UI();
    [self finishScreen];
}

-(void)finishScreen
{
    T_UI();
    [self.navigationController popViewControllerAnimated:!self.showProfile];
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_REGISTRATION_COMPLETED];
    [intent setBool:![MCTUtils isEmptyOrWhitespaceString:[[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_INVITATION_SECRET]]
             forKey:@"invitation_acked"];
    [intent setBool:![MCTUtils isEmptyOrWhitespaceString:[[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_REGISTRATION_OPENED_URL]]
             forKey:@"invitation_to_be_acked"];
    [intent setBool:!self.showProfile forKey:@"age_and_gender_set"];
    [intent setBool:YES forKey:@"discovered_beacons"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    T_UI();
    HERE();
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, view.width - 10, 18)];

    label.font = [UIFont boldSystemFontOfSize:12];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    label.numberOfLines = 0;
    label.text = [NSString stringWithFormat:NSLocalizedString(@"__detected_services_title", nil), MCT_PRODUCT_NAME];

    CGRect labelFrame = label.frame;
    labelFrame.size = [MCTUIUtils sizeForLabel:label];
    labelFrame.size.height += 10;
    label.frame = labelFrame;

    view.height = label.height;
    [view addSubview:label];
    [view setBackgroundColor:[UIColor whiteColor]];
    [MCTUIUtils addShadowToView:view];

    UIView *header = [[UIView alloc] initWithFrame:view.frame];
    [header addSubview:view];
    header.height += 5;
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    T_UI();
    return [self tableView:tableView viewForHeaderInSection:section].height;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    NSInteger c = [self.discoveredBeacons count];
    return c;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    NSDictionary *discoveredBeacon = [self.discoveredBeacons objectAtIndex:indexPath.row];
    MCTDiscoveredFriendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if (!cell){
        cell = [[MCTDiscoveredFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
    }

    [cell setName:[discoveredBeacon stringForKey:@"name"]];
    [cell setPicture:[discoveredBeacon stringForKey:@"avatar_url"]];

    if ([self.selectedBeacons containsObject:[discoveredBeacon stringForKey:@"friend_email"]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    NSDictionary *discoveredBeacon = [self.discoveredBeacons objectAtIndex:indexPath.row];
    NSString *friendEmail = [discoveredBeacon stringForKey:@"friend_email"];
    if ([self.selectedBeacons containsObject:friendEmail]) {
        [self.selectedBeacons removeObject:friendEmail];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        [self.selectedBeacons addObject:friendEmail];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }


    self.connectButtonItem.enabled = [self.selectedBeacons count] > 0;
}

@end