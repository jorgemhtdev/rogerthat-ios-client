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

#import "MCTActivityVC.h"
#import "MCTMoreVC.h"
#import "MCTProfileVC.h"
#import "MCTSettingsVC.h"
#import "MCTUIUtils.h"
#import "MCTFriendsTabVC.h"


#define NUM_ROWS 4

#define MCT_ROW_FRIENDS 0
#define MCT_ROW_PROFILE 1
#define MCT_ROW_SETTINGS 2
#define MCT_ROW_STREAM 3

@implementation MCTMoreVC

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"More", nil);
    self.navigationItem.title = self.title;
    [MCTUIUtils setBackgroundPlainToView:self.view];


    CGRect frame = CGRectZero;
    frame.size = [MCTUIUtils availableSizeForViewWithController:self];

    if ([self.navigationController.viewControllers firstObject] != self) {
        frame.origin.y += 64;
        frame.size.height -= 64;
    }

    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView.bounces = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.view addSubview:self.tableView];
}

- (NSInteger)rowForIndexPahRow:(NSInteger)oldRow
{
    NSInteger row = oldRow;

    if (oldRow == MCT_ROW_FRIENDS) {
        if (!MCT_SHOW_FRIENDS_IN_MORE) {
            row += 1;
            if (!MCT_SHOW_PROFILE_IN_MORE) {
                row += 1;
            }
        }
    } else {
        if (!MCT_SHOW_FRIENDS_IN_MORE) {
            row += 1;
        }
        if (!MCT_SHOW_PROFILE_IN_MORE) {
            row += 1;
        }
    }

    return row;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    T_UI();
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    NSInteger numRows = NUM_ROWS;
    if (!MCT_SHOW_FRIENDS_IN_MORE)
        numRows -= 1;

    if(!MCT_SHOW_PROFILE_IN_MORE)
        numRows -= 1;
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    NSString *ident = [NSString stringWithFormat:@"%d,%d", (int)indexPath.section, (int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];

        CGFloat y = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        IF_IOS7_OR_GREATER({
            y -= 1;
        });
        UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.width, 1)];
        sep.backgroundColor = [UIColor MCTSeparatorColor];
        [cell addSubview:sep];

        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor blackColor];
    }

    NSInteger row = [self rowForIndexPahRow:indexPath.row];

    if (row == MCT_ROW_STREAM) {
        cell.imageView.image = [UIImage imageNamed:@"more_network_monitor.png"];
        cell.textLabel.text = NSLocalizedString(@"Stream", nil);
    }
    else if (row == MCT_ROW_PROFILE) {
        cell.imageView.image = [UIImage imageNamed:@"more_id.png"];
        cell.textLabel.text = NSLocalizedString(@"Profile", nil);
    }
    else if (row== MCT_ROW_SETTINGS) {
        cell.imageView.image = [UIImage imageNamed:@"more_gear.png"];
        cell.textLabel.text = NSLocalizedString(@"Settings", nil);
    }
    else if (row == MCT_ROW_FRIENDS) {
        cell.imageView.image = [UIImage imageNamed:@"more_messenger.png"];
        switch (MCT_FRIENDS_CAPTION) {
            case MCTFriendsCaptionColleagues: {
                cell.textLabel.text = NSLocalizedString(@"Colleagues", nil);
                break;
            }
            case MCTFriendsCaptionContacts: {
                cell.textLabel.text = NSLocalizedString(@"Contacts", nil);
                break;
            }
            case MCTFriendsCaptionFriends:
            default: {
                cell.textLabel.text = NSLocalizedString(@"Friends", nil);
                break;
            }
        }
    }

    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    UIViewController *vc = nil;

    NSInteger row = [self rowForIndexPahRow:indexPath.row];

    if (row == MCT_ROW_STREAM) {
        vc = [MCTActivityVC viewController];
    }
    else if (row == MCT_ROW_PROFILE) {
        vc = [MCTProfileVC viewController];
    }
    else if (row == MCT_ROW_SETTINGS) {
        vc = [MCTSettingsVC viewController];
    }
    else if (row == MCT_ROW_FRIENDS) {
        vc = [[MCTFriendsTabVC alloc] init];
    }

    if (vc) {
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end