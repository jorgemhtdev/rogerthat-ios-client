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

#import "MCTAlarmPickerVC.h"
#import "MCTAlertMgr.h"
#import "MCTComponentFramework.h"
#import "MCTDisclosureIndicatorView.h"
#import "MCTIntent.h"
#import "MCTSettingsVC.h"
#import "MCTUIUtils.h"


#define MCT_SECT_ALARMS 0
#define MCT_ROW_DEFAULT 0
#define MCT_ROW_CUSTOM 1

#define MCT_SECT_PLAY 1
#define MCT_ROW_PLAY 0


@interface MCTAlarmPickerVC ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) MCTAlarmPicker *alarmPicker;
@property (nonatomic, copy) NSString *alarmTitle;

- (void)playAlarm;
- (void)registerIntents;

@end


@implementation MCTAlarmPickerVC

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    [MCTUIUtils setBackgroundStripesToView:self.view];
    self.title = NSLocalizedString(@"Alarm sound", nil);
    self.alarmTitle = [[NSUserDefaults standardUserDefaults] valueForKey:MCT_SETTINGS_CUSTOM_ALARM];
    if ([MCTUtils isEmptyOrWhitespaceString:self.alarmTitle])
        MCT_RELEASE(self.alarmTitle);

    self.descriptionLbl.text = NSLocalizedString(@"Services can send high priority messages, which have a configurable alarm ringtone.", nil);

    [self registerIntents];
}

- (void)viewWillDisappear:(BOOL)animated
{
    T_UI();
    [super viewWillDisappear:animated];

    if (![self.navigationController.viewControllers containsObject:self]) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
    }
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
    if (section == MCT_SECT_ALARMS)
        return 2;

    if (section == MCT_SECT_PLAY)
        return 1;

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    NSString *ident = [NSString stringWithFormat:@"%d,%d", (int)indexPath.section, (int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
        cell.backgroundColor = [UIColor whiteColor];

        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [cell.textLabel.font fontWithSize:15];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.textColor = [UIColor blackColor];

        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [cell.detailTextLabel.font fontWithSize:13];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }

    if (indexPath.section == MCT_SECT_ALARMS) {
        if (indexPath.row == MCT_ROW_DEFAULT) {
            cell.textLabel.text = NSLocalizedString(@"Default sound", nil);
            if (self.alarmTitle) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        else if (indexPath.row == MCT_ROW_CUSTOM) {
            cell.textLabel.text = NSLocalizedString(@"Custom sound", nil);
            cell.detailTextLabel.text = self.alarmTitle;
            if (self.alarmTitle) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    else if (indexPath.section == MCT_SECT_PLAY) {
        if (indexPath.row == MCT_ROW_PLAY) {
            cell.textLabel.text = NSLocalizedString(@"Play alarm sound", nil);
            cell.textLabel.textColor = self.view.tintColor;
            cell.accessoryType = UITableViewCellAccessoryNone;
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

    if (indexPath.section == MCT_SECT_ALARMS) {
        if (indexPath.row == MCT_ROW_DEFAULT) {
            MCT_RELEASE(self.alarmTitle);
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:MCT_SETTINGS_CUSTOM_ALARM];

            MCTAlertMgr *alertMgr = [[MCTComponentFramework messagesPlugin] alertMgr];
            alertMgr.alarmSound = alertMgr.defaultAlarmSound;

            NSString *alarmFolder = [[MCTUtils documentsFolder] stringByAppendingPathComponent:@"alarm"];
            LOG(@"Removing alarmFolder: %@", alarmFolder);
            [[NSFileManager defaultManager] removeItemAtPath:alarmFolder error:nil];

            [tableView reloadSections:[NSIndexSet indexSetWithIndex:MCT_SECT_ALARMS] withRowAnimation:NO];
        }
        if (indexPath.row == MCT_ROW_CUSTOM) {
            // TODO: why not autorelease *picker ?
            MCTAlarmPicker *picker = [[MCTAlarmPicker alloc] initWithViewController:self];
            [picker pickAlarm];
            self.alarmPicker = picker;
        }
    }
    else if (indexPath.section == MCT_SECT_PLAY) {
        if (indexPath.row == MCT_ROW_PLAY) {
            [self playAlarm];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    CGFloat h = 44;

    if (indexPath.section == MCT_SECT_ALARMS && indexPath.row == MCT_ROW_CUSTOM)
        h = [MCTUIUtils heightForCell:[self tableView:tableView cellForRowAtIndexPath:indexPath]];

    return h;
}

#pragma mark -
#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    T_UI();
    MCT_RELEASE(self.currentActionSheet);
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    T_UI();
    MCT_RELEASE(self.currentActionSheet);
    self.currentAlertView = [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"An error occured while trying to play the alarm sound", nil)];
}

#pragma mark -

- (void)playAlarm
{
    T_UI();
    MCTAlertMgr *alertMgr = [[MCTComponentFramework messagesPlugin] alertMgr];
    NSString *alarm = alertMgr.alarmSound;
    NSError *error;
    // audioPlayer gets released by its delegate
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:alarm] error:&error];
    if (self.audioPlayer == nil) {
        ERROR(@"%@", error);
        self.currentAlertView = [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"An error occured while trying to play the alarm sound", nil)];
        return;
    }
    self.audioPlayer.numberOfLoops = ([alertMgr.defaultAlarmSound isEqualToString:alarm]) ? -1 : 0;
    self.audioPlayer.volume = 1;
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];

    self.currentActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Stop playing", nil)
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:nil];

    UITabBar *tabBar = self.tabBarController.tabBar;
    if (tabBar)
        [self.currentActionSheet showFromTabBar:tabBar];
    else
        [self.currentActionSheet showInView:self.view];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    // Possibly self.audioPlayer is nil
    [self.audioPlayer stop];
    MCT_RELEASE(self.audioPlayer);
    MCT_RELEASE(self.currentActionSheet);
}

#pragma mark -
#pragma mark MCTIntent

- (void)registerIntents
{
    T_UI();
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_NEW_ALARM_SOUND
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_NEW_ALARM_SOUND) {
        self.alarmTitle = [[NSUserDefaults standardUserDefaults] valueForKey:MCT_SETTINGS_CUSTOM_ALARM];
        if ([MCTUtils isEmptyOrWhitespaceString:self.alarmTitle]) {
            MCT_RELEASE(self.alarmTitle);
        }

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:MCT_SECT_ALARMS] withRowAnimation:NO];
    }
}

@end