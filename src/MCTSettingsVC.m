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

#import "MCTAboutVC.h"
#import "MCTAlarmPickerVC.h"
#import "MCTComponentFramework.h"
#import "MCTIntent.h"
#import "MCTSettingsVC.h"
#import "MCTUIUtils.h"


#define MCT_SECT_GENERAL 0

#define MCT_SECT_SOUND -1
#define MCT_ROW_ALARM 0

#define MCT_SECT_PRODUCT 1
#define MCT_ROW_VERSION 0
#define MCT_ROW_ABOUT 1

static NSString *const kRowInvisible = @"invisible";
static NSString *const kRowTransferWifiOnly = @"wifi only";


@implementation MCTSettingsVC


+ (MCTSettingsVC *)viewController
{
    T_UI();
    MCTSettingsVC *vc = [[MCTSettingsVC alloc] initWithNibName:@"settings" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
 
    self.title = NSLocalizedString(@"Settings", nil);
    [MCTUIUtils setBackgroundStripesToView:self.tableView];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_SETTINGS_UPDATED
                                                            onQueue:[MCTComponentFramework mainQueue]];

    NSMutableArray *generalRows = [NSMutableArray array];
    if (MCT_FRIENDS_ENABLED) {
        [generalRows addObject:kRowInvisible];
    }
    [generalRows addObject:kRowTransferWifiOnly];
    self.generalRows = generalRows;
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
    }
}

#pragma mark -

- (void)onInvisibleSwitchChanged:(UISwitch *)sender
{
    T_UI();
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:MCT_SETTINGS_INVISIBLE];
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        [[MCTComponentFramework systemPlugin] saveSettingsWithTrackingEnabled:sender.on];
    }];
}

- (void)onUploadWifiOnlySwitchChanged:(UISwitch *)sender
{
    T_UI();
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:MCT_SETTINGS_TRANSFER_WIFI_ONLY];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    T_UI();
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    if (section == MCT_SECT_GENERAL)
        return [self.generalRows count];

    if (section == MCT_SECT_SOUND)
        return 1;

    if (section == MCT_SECT_PRODUCT)
        return 2;

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == MCT_SECT_PRODUCT || section == MCT_SECT_GENERAL || section == MCT_SECT_SOUND)
        return 36;

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    T_UI();
    if (section == MCT_SECT_GENERAL)
        return NSLocalizedString(@"General", nil);

    if (section == MCT_SECT_SOUND)
        return NSLocalizedString(@"Sounds", nil);

    if (section == MCT_SECT_PRODUCT)
        return NSLocalizedString(@"Product information", nil);

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == MCT_SECT_GENERAL)
        return NSLocalizedString(@"Upload photos only when connected to WIFI", nil);
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    NSString *ident = [NSString stringWithFormat:@"%d,%d", (int)indexPath.section, (int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ident];
        cell.backgroundColor = [UIColor whiteColor];

        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [cell.detailTextLabel.font fontWithSize:15];
        cell.detailTextLabel.textColor = [UIColor blackColor];

        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [cell.textLabel.font fontWithSize:15];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.textColor = [UIColor blackColor];
    }

    if (indexPath.section == MCT_SECT_GENERAL) {
        NSString *row = self.generalRows[indexPath.row];
        if (row == kRowInvisible) {
            cell.textLabel.text = NSLocalizedString(@"Invisible mode", nil);
            UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectZero];
            switcher.on = [[NSUserDefaults standardUserDefaults] boolForKey:MCT_SETTINGS_INVISIBLE];
            [switcher addTarget:self action:@selector(onInvisibleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if (row == kRowTransferWifiOnly) {
            cell.textLabel.text = NSLocalizedString(@"WIFI-only uploads", nil);
            UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectZero];
            switcher.on = [[NSUserDefaults standardUserDefaults] boolForKey:MCT_SETTINGS_TRANSFER_WIFI_ONLY];
            [switcher addTarget:self action:@selector(onUploadWifiOnlySwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }

    else if (indexPath.section == MCT_SECT_SOUND) {
        if (indexPath.row == MCT_ROW_ALARM) {
            cell.textLabel.text = NSLocalizedString(@"Alarm sound", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
    }
    else if (indexPath.section == MCT_SECT_PRODUCT) {
        if (indexPath.row == MCT_ROW_VERSION) {
            cell.textLabel.text = NSLocalizedString(@"Version", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", MCT_PRODUCT_VERSION, MCT_DEBUG ? @" (debug)" : @""];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if (indexPath.row == MCT_ROW_ABOUT) {
            cell.textLabel.text = NSLocalizedString(@"About", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
    }

    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == MCT_SECT_SOUND && indexPath.row == MCT_ROW_ALARM) {
        MCTAlarmPickerVC *vc = [[MCTAlarmPickerVC alloc] initWithNibName:@"alarmPicker" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }

    else if (indexPath.section == MCT_SECT_PRODUCT && indexPath.row == MCT_ROW_ABOUT) {
        MCTAboutVC *vc = [[MCTAboutVC alloc] initWithNibName:@"about" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -
#pragma mark MCTIntent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_SETTINGS_UPDATED) {
        if ([intent boolForKey:@"invisible_mode_changed"] && [self.generalRows containsObject:kRowInvisible]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.generalRows indexOfObject:kRowInvisible]
                                                        inSection:MCT_SECT_GENERAL];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            UISwitch *switcher = (UISwitch *) cell.accessoryView;
            [switcher setOn:[[NSUserDefaults standardUserDefaults] boolForKey:MCT_SETTINGS_INVISIBLE] animated:YES];
        }
    }
}

@end