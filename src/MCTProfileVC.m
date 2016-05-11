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
#import "MCTFinishRegistration.h"
#import "MCTIntent.h"
#import "MCTProfileVC.h"
#import "MCTUIUtils.h"
#import "MCTIdentity.h"
#import "MCTReflectiveFillStyle.h"
#import "MCTUIImagePickerController.h"

#import "TTView.h"
#import "Three20Style+Additions.h"


#define BUBBLE_POINT_W 10
#define AVATAR_SIZE 150

NSString *const kSectionGenderAndBirthdate = @"genderAndBirthdate";
NSString *const kSectionProfileData = @"profileData";
NSString *const kSectionQRCode = @"qrCode";


@interface MCTProfileVC ()

@property (nonatomic, strong) TTView *datePickerSpeechBubble;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UISegmentedControl *doneBtn;
@property (nonatomic, strong) UIImage *qrCode;
@property (nonatomic, strong) UIPickerView *genderPicker;
@property (nonatomic, strong) TTView *genderPickerSpeechBubble;
@property (nonatomic) BOOL canceled;
@property (nonatomic, strong) NSMutableArray *sections;

- (void)loadIdentity;
- (void)registerIntents;

- (void)showPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType;

@end



@implementation MCTProfileVC




+ (MCTProfileVC *)viewController
{
    T_UI();

    MCTProfileVC *vc = [[MCTProfileVC alloc] initWithNibName:@"profile" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Profile", nil);
    self.editNameLbl.text = NSLocalizedString(@"Edit name:", nil);
    self.editLbl.text = NSLocalizedString(@"Edit", nil);
    [MCTUIUtils setBackgroundStripesToView:self.view];
    [MCTUIUtils setBackgroundStripesToView:self.tableView];

    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.datePicker.timeZone = [MCTProfileVC timeZone];
    
    [self loadIdentity];
    [self loadQR];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (self.completeProfileAfterRegistration){
        self.cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Skip", nil)
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(onCancelClicked:)];
    } else {
        self.cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(onCancelClicked:)];
    }

    self.sections = [NSMutableArray array];
    if (MCT_PROFILE_SHOW_GENDER_AND_BIRTHDATE)
        [self.sections addObject:kSectionGenderAndBirthdate];
    if ([MCT_PROFILE_DATA_FIELDS count] > 0)
        [self.sections addObject:kSectionProfileData];
    if (MCT_FRIENDS_ENABLED)
        [self.sections addObject:kSectionQRCode];

    [self.tableView reloadData];

    [MCTUIUtils addRoundedBorderToView:self.avatarControl];
    [self registerIntents];
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
    }
}

+ (NSTimeZone *)timeZone
{
    T_UI();
    return [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
}

- (void)loadIdentity
{
    T_UI();
    self.identity = [MCTIdentity identityFromIdentity:[[MCTComponentFramework systemPlugin] myIdentity]];
    if (self.identity.avatar == nil){
        self.avatarView.image = [UIImage imageNamed:@"unknown_avatar.png"];
    }
    else{
        self.avatarView.image = [UIImage imageWithData:self.identity.avatar];
    }
    self.nameLbl.text = self.nameTextField.text = self.identity.name;
    self.datePicker.date = [NSDate dateWithTimeIntervalSince1970:self.identity.birthdate];

    // Bottom aligning label
    CGFloat h = fmin(40, [MCTUIUtils sizeForLabel:self.nameLbl].height);
    if (h != self.nameLbl.frame.size.height) {
        CGRect f = self.nameLbl.frame;
        f.origin.y = CGRectGetMaxY(f) - h;
        f.size.height = h;
        self.nameLbl.frame = f;
    }

    self.emailLbl.text = [self.identity displayEmail];
}

- (void)loadQR
{
    T_UI();
    if (MCT_FRIENDS_ENABLED) {
        NSData *qr = [[[MCTComponentFramework systemPlugin] identityStore] qrCode];
        if (qr == nil) {
            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                [[MCTComponentFramework systemPlugin] requestIdentityQRCode];
            }];
            self.qrCode = nil;
        } else {
            self.qrCode = [UIImage imageWithData:qr];
        }
    } else {
        self.qrCode = nil;
    }
}

#pragma mark - Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    T_UI();
    if (self.editing
        && (MCT_PROFILE_SHOW_GENDER_AND_BIRTHDATE && (!self.identity.hasBirthdate || !self.identity.hasGender))
        && !self.canceled) {

        NSMutableArray *reasons = [NSMutableArray array];
        if (!self.identity.hasBirthdate) {
            [reasons addObject:NSLocalizedString(@"Day of birth is missing", nil)];
        }
        if (!self.identity.hasGender) {
            [reasons addObject:NSLocalizedString(@"Gender is missing", nil)];
        }
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:NSLocalizedString(@"Complete your profile", nil)
                                                       andText:[reasons componentsJoinedByString:@"\n"]];
        self.currentAlertView.delegate = self;
        return;
    }

    [super setEditing:editing animated:animated];

    [UIView animateWithDuration:0.4 animations:^{
        self.emailLbl.alpha = (int) !editing;
        self.nameLbl.alpha = (int) !editing;

        self.editNameLbl.alpha = (int) editing;
        self.nameTextField.alpha = (int) editing;
        self.editLbl.alpha = (int) editing;
        self.editView.alpha = editing ? 0.7 : 0;
    }];

    self.navigationItem.hidesBackButton = editing;
    if (!editing) {
        if (MCT_PROFILE_SHOW_GENDER_AND_BIRTHDATE) {
            if (self.datePickerSpeechBubble.alpha == 1) {
                [self toggleDatePicker:NO];
                if (!self.canceled)
                    self.identity.birthdate = [self.datePicker.date timeIntervalSince1970];
            }

            if (self.genderPickerSpeechBubble.alpha == 1) {
                [self toggleGenderPicker:NO];
                if (!self.canceled)
                    [self updateGender];
            }
        }

        if (!self.canceled){
            BOOL nameEdited = ![self.nameTextField.text isEqualToString:self.nameLbl.text];
            NSString *newName = nameEdited ? self.nameTextField.text : nil;
            UIImage *newAvatar = self.editedProfileImage;

            MCTlong newBirthdate = MCT_PROFILE_SHOW_GENDER_AND_BIRTHDATE ? self.identity.birthdate : 0;
            MCTlong newGender = MCT_PROFILE_SHOW_GENDER_AND_BIRTHDATE ? self.identity.gender : 0;

            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                [[MCTComponentFramework systemPlugin] editProfileWithNewName:newName
                                                                   newAvatar:newAvatar
                                                                newBirthdate:newBirthdate
                                                                   newGender:newGender
                                                                hasBirthdate:MCT_PROFILE_SHOW_GENDER_AND_BIRTHDATE
                                                                   hasGender:MCT_PROFILE_SHOW_GENDER_AND_BIRTHDATE];
            }];
        }
        self.nameLbl.text = self.nameTextField.text;
        [self.nameTextField resignFirstResponder];
        self.navigationItem.leftBarButtonItem = nil;
    }
    else{
        self.navigationItem.leftBarButtonItem = self.cancelButtonItem;
    }

    if (self.completeProfileAfterRegistration && ((self.identity.hasBirthdate && self.identity.hasGender) || self.canceled)) {
        [self.navigationController popViewControllerAnimated:YES];
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_REGISTRATION_COMPLETED];
        [intent setBool:![MCTUtils isEmptyOrWhitespaceString:[[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_INVITATION_SECRET]]
                 forKey:@"invitation_acked"];
        [intent setBool:![MCTUtils isEmptyOrWhitespaceString:[[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_REGISTRATION_OPENED_URL]]
                 forKey:@"invitation_to_be_acked"];
        [intent setBool:YES forKey:@"age_and_gender_set"];
        [intent setBool:self.hasDiscoveredBeacons forKey:@"discovered_beacons"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    }
    self.canceled = NO;
    [self loadIdentity];
    [self.tableView reloadData];
}

- (void)onCancelClicked:(id)sender
{
    T_UI();
    self.canceled = YES;
    [self setEditing:NO animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    T_UI();
    BOOL shouldReloadTableView = NO;
    if (self.genderPickerSpeechBubble.alpha == 1) {
        [self toggleGenderPicker:NO];
        [self updateGender];
        shouldReloadTableView = YES;
    }

    if (self.datePickerSpeechBubble.alpha == 1) {
        [self toggleDatePicker:NO];
        self.identity.birthdate = [self.datePicker.date timeIntervalSince1970];
        shouldReloadTableView = YES;
    }

    if (shouldReloadTableView) {
        [self.tableView reloadData];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)s
{
    T_UI();
    // Block Done btn when name is left empty
    NSInteger newLength = [textField.text length] + [s length] - range.length;
    self.navigationItem.rightBarButtonItem.enabled = newLength > 0;
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    T_UI();
    self.navigationItem.rightBarButtonItem.enabled = NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    T_UI();
    [textField resignFirstResponder];
    [self setEditing:NO animated:YES];
    return YES;
}

- (IBAction)avatarClicked:(id)sender
{
    T_UI();
    if (self.editing) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.currentActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:
                                        NSLocalizedString(@"Take a picture", nil),
                                        NSLocalizedString(@"Select from photo library", nil), nil];
            [MCTUIUtils showActionSheet:self.currentActionSheet inViewController:self];
        } else {
            [self showPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }
}

- (IBAction)headerClicked:(id)sender
{
    T_UI();
    if (self.datePickerSpeechBubble.alpha) {
        [self onBirthdateDoneClicked:nil];
    } else if (self.genderPickerSpeechBubble.alpha) {
        [self onGenderDoneClicked:nil];
    }
}

- (void)showPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    T_UI();
    MCTUIImagePickerController *vc = [[MCTUIImagePickerController alloc] init];
    vc.sourceType = sourceType;
    vc.delegate = self;
    vc.allowsEditing = YES;

    // Using menuViewController to prevent "Presenting view controllers on detached view controllers is discouraged"
    // Apparently everything under the More tab is detached. This was causing rotation issues.
    [[MCTComponentFramework menuViewController] presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    switch (buttonIndex) {
        case 0: // Camera
            [self showPickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
        case 1: // Library
            [self showPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        default: // Cancel
            break;
    }
    MCT_RELEASE(self.currentActionSheet);
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[MCTComponentFramework menuViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    T_UI();
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.editedProfileImage = self.avatarView.image = [image imageByScalingAndCroppingForSize:CGSizeMake(AVATAR_SIZE, AVATAR_SIZE)];

    [[MCTComponentFramework menuViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    NSString *sectionId = self.sections[section];

    if (sectionId == kSectionGenderAndBirthdate) {
        return 2;
    } else if (sectionId == kSectionProfileData) {
        return [MCT_PROFILE_DATA_FIELDS count];
    } else if (sectionId == kSectionQRCode) {
        return 1;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    NSString *sectionId = self.sections[indexPath.section];

    NSString *identifier = [NSString stringWithFormat:@"%ld:%ld", (long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        if (sectionId == kSectionGenderAndBirthdate || sectionId == kSectionProfileData) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
            if (MCT_APP_TINT_COLOR) {
                cell.textLabel.textColor = MCT_APP_TINT_COLOR;
            }
            if (sectionId == kSectionGenderAndBirthdate) {
                cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor whiteColor];
        }
        cell.selectionStyle = UITableViewCellEditingStyleNone;
    }

    if (sectionId == kSectionGenderAndBirthdate) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Day of birth", nil);
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            if (!self.identity.hasBirthdate) {
                cell.detailTextLabel.text = NSLocalizedString(@"Unknown", nil);
            } else {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.locale = [NSLocale currentLocale];
                dateFormatter.dateStyle = NSDateFormatterLongStyle;
                dateFormatter.timeZone = [MCTProfileVC timeZone];
                dateFormatter.timeStyle = NSDateFormatterNoStyle;

                cell.detailTextLabel.text = [dateFormatter stringFromDate:self.datePicker.date];
                [cell.detailTextLabel sizeToFit];
            }
        } else {
            cell.textLabel.text = NSLocalizedString(@"Gender", nil);
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            if (!self.identity.hasGender) {
                cell.detailTextLabel.text = NSLocalizedString(@"Unknown", nil);
            } else if (self.identity.gender == MCTIdentityGenderFemale) {
                cell.detailTextLabel.text = NSLocalizedString(@"Female", nil);
            } else {
                cell.detailTextLabel.text = NSLocalizedString(@"Male", nil);
            }
        }
    } else if (sectionId == kSectionProfileData) {
        NSDictionary *profileDataDict = [self.identity getProfileDataDict];
        NSString *k = MCT_PROFILE_DATA_FIELDS[indexPath.row];
        NSString *v = profileDataDict[k];
        if (v == nil) {
            v = NSLocalizedString(@"Unknown", nil);
        }
        cell.textLabel.text = NSLocalizedString(k, nil);
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.text = v;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = [v numberOfLines] < 2;
    } else if (sectionId == kSectionQRCode) {
        if (indexPath.row == 0) {
            UIImageView *imageView = (UIImageView *) [cell viewWithTag:1];
            if (imageView == nil) {
                imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, self.view.width - 40, self.view.width - 40)];
                imageView.tag = 1;
                [cell.contentView addSubview:imageView];
            }
            imageView.image = self.qrCode;
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    T_UI();
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    NSString *sectionId = self.sections[indexPath.section];
    if (sectionId == kSectionQRCode) {
        return self.view.width - 40;
    }
    if (sectionId == kSectionProfileData) {
        NSDictionary *profileDataDict = [self.identity getProfileDataDict];
        NSString *k = MCT_PROFILE_DATA_FIELDS[indexPath.row];
        NSString *v = profileDataDict[k];
        if ([v numberOfLines] > 1) {
            return [MCTUIUtils heightForCell:[self tableView:tableView cellForRowAtIndexPath:indexPath]];
        }
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    T_UI();
    if (section == 0) {
        return self.headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    T_UI();
    if (section == 0) {
        return 80;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    T_UI();
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    NSString *sectionId = self.sections[indexPath.section];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (sectionId == kSectionGenderAndBirthdate) {
        [self.nameTextField resignFirstResponder];

        if (indexPath.row == 0) {
            [self initDatePickerSpeechBubble];
            self.datePickerSpeechBubble.top = cell.bottom;
            [self toggleDatePicker:YES];
            self.identity.hasBirthdate = YES;

            if (self.genderPickerSpeechBubble.alpha == 1) {
                [self toggleGenderPicker:NO];
                [self updateGender];
            }

        } else if (indexPath.row == 1) {
            [self initGenderPickerSpeechBubble];
            NSInteger row = (self.identity.gender == MCTIdentityGenderFemale) ? 1 : 0;
            [self.genderPicker selectRow:row inComponent:0 animated:YES];
            self.genderPickerSpeechBubble.top = cell.bottom;
            [self toggleGenderPicker:YES];
            self.identity.hasGender = YES;

            if (self.datePickerSpeechBubble.alpha == 1) {
                [self toggleDatePicker:NO];
                self.identity.birthdate = [self.datePicker.date timeIntervalSince1970];
            }
        }
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return row == 0 ? NSLocalizedString(@"Male", nil) : NSLocalizedString(@"Female", nil);
}

#pragma mark - UIDatePickerView

- (void)initDatePickerSpeechBubble
{
    T_UI();
    if (self.datePickerSpeechBubble == nil) {

        IF_PRE_IOS7({
            [MCTUIUtils addRoundedBorderToView:self.datePicker];
        });

        self.datePicker.datePickerMode = UIDatePickerModeDate;
        int minuteInterval = 24 * 60;
        self.datePicker.minuteInterval = minuteInterval;
        NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[MCTUtils floor:[NSDate timeIntervalSinceReferenceDate]
                                                                         withInterval:60 * minuteInterval] + [[NSTimeZone localTimeZone] secondsFromGMT]];

        self.datePicker.maximumDate = date;

        self.datePickerSpeechBubble = [[TTView alloc] init];
        self.datePickerSpeechBubble.backgroundColor = [UIColor clearColor];
        self.datePickerSpeechBubble.exclusiveTouch = YES;
        [self.datePickerSpeechBubble addSubview:self.datePicker];

        self.doneBtn = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:NSLocalizedString(@"Done", nil)]];
        self.doneBtn.momentary = YES;
        self.doneBtn.tintColor = OR(MCT_APP_TINT_COLOR, RGBCOLOR(109, 132, 255));
        [self.doneBtn addTarget:self action:@selector(onBirthdateDoneClicked:) forControlEvents:UIControlEventValueChanged];
        [self.datePickerSpeechBubble addSubview:self.doneBtn];

        CGFloat w = [[UIScreen mainScreen] applicationFrame].size.width;
        CGFloat m = 5;
        CGFloat btnW = 60;
        CGFloat btnH = 34;

        [self.doneBtn sizeToFit];
        self.doneBtn.top = BUBBLE_POINT_W + m;
        self.doneBtn.width = MAX(btnW, self.doneBtn.width);
        self.doneBtn.height = btnH;
        self.doneBtn.right = w - m;

        CGRect dFrame = self.datePicker.frame;
        CGFloat dX = 1;
        dFrame.origin = CGPointMake(dX, CGRectGetMaxY(self.doneBtn.frame) + m);
        dFrame.size.width = w - 2 * dX;
        self.datePicker.frame = dFrame;

        CGRect bFrame = CGRectMake(0, 0, w, CGRectGetMaxY(self.datePicker.frame) + m);
        self.datePickerSpeechBubble.frame = bFrame;

        if (!self.datePickerSpeechBubble.style) {
            UIColor *color = nil;
            IF_IOS7_OR_GREATER({
                color = RGBCOLOR(230, 230, 230);
            });
            IF_PRE_IOS7({
                color = RGBCOLOR(16, 16, 16);
            });
            CGSize pointSize = CGSizeMake(2 * BUBBLE_POINT_W, BUBBLE_POINT_W);
            self.datePickerSpeechBubble.style = [TTShapeStyle styleWithShape:[TTSpeechBubbleShape shapeWithRadius:5
                                                                                          pointLocation:90
                                                                                             pointAngle:90
                                                                                              pointSize:pointSize]
                                                              next:
                                       [MCTReflectiveFillStyle styleWithColor:color
                                                      topEndHighlightLocation:(2 + BUBBLE_POINT_W + m + btnH / 2) / bFrame.size.height
                                                                         next:
                                        [TTBevelBorderStyle styleWithHighlight:[color shadow]
                                                                        shadow:[color multiplyHue:1 saturation:0.5 value:0.5]
                                                                         width:1
                                                                   lightSource:0
                                                                          next:
                                         [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1)
                                                                 next:
                                          [TTBevelBorderStyle styleWithHighlight:nil
                                                                          shadow:RGBACOLOR(0,0,0,0.15)
                                                                           width:1
                                                                     lightSource:0
                                                                            next:nil]]]]];
        }
    }
}

- (void)onBirthdateDoneClicked:(id)sender
{
    T_UI();
    [self toggleDatePicker:NO];
    self.identity.birthdate = [self.datePicker.date timeIntervalSince1970];
    [self.tableView reloadData];
}

- (void)toggleDatePicker:(BOOL)visible
{
    T_UI();
    if (visible) {
        self.datePickerSpeechBubble.alpha = 1;
        [self.tableView addSubview:self.datePickerSpeechBubble];
    } else {
        self.datePickerSpeechBubble.alpha = 0;
        [self.datePickerSpeechBubble removeFromSuperview];
    }
}

#pragma mark - UIPickerView

- (void)initGenderPickerSpeechBubble
{
    T_UI();
    if (self.genderPickerSpeechBubble == nil) {
        self.genderPicker = [[UIPickerView alloc] init];
        self.genderPicker.dataSource = self;
        self.genderPicker.delegate = self;
        self.genderPicker.tag = 2;
        self.genderPicker.height = 150;

        self.genderPickerSpeechBubble = [[TTView alloc] init];
        self.genderPickerSpeechBubble.backgroundColor = [UIColor clearColor];
        self.genderPickerSpeechBubble.exclusiveTouch = YES;
        [self.genderPickerSpeechBubble addSubview:self.genderPicker];

        self.doneBtn = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:NSLocalizedString(@"Done", nil)]];
        self.doneBtn.momentary = YES;
        self.doneBtn.tintColor = OR(MCT_APP_TINT_COLOR, RGBCOLOR(109, 132, 255));
        [self.doneBtn addTarget:self action:@selector(onGenderDoneClicked:) forControlEvents:UIControlEventValueChanged];
        [self.genderPickerSpeechBubble addSubview:self.doneBtn];

        CGFloat w = [[UIScreen mainScreen] applicationFrame].size.width;
        CGFloat m = 5;
        CGFloat btnW = 60;
        CGFloat btnH = 34;

        [self.doneBtn sizeToFit];
        self.doneBtn.top = BUBBLE_POINT_W + m;
        self.doneBtn.width = MAX(btnW, self.doneBtn.width);
        self.doneBtn.height = btnH;
        self.doneBtn.right = w - m;

        CGRect dFrame = self.genderPicker.frame;
        CGFloat dX = 1;
        dFrame.origin = CGPointMake(dX, CGRectGetMaxY(self.doneBtn.frame) + m);
        dFrame.size.width = w - 2 * dX;
        self.genderPicker.frame = dFrame;


        CGRect bFrame = CGRectMake(0, 0, w, CGRectGetMaxY(self.genderPicker.frame) + m);
        self.genderPickerSpeechBubble.frame = bFrame;

        if (!self.genderPickerSpeechBubble.style) {
            UIColor *color = nil;
            IF_IOS7_OR_GREATER({
                color = RGBCOLOR(230, 230, 230);
            });
            IF_PRE_IOS7({
                color = RGBCOLOR(16, 16, 16);
            });
            CGSize pointSize = CGSizeMake(2 * BUBBLE_POINT_W, BUBBLE_POINT_W);
            self.genderPickerSpeechBubble.style = [TTShapeStyle styleWithShape:[TTSpeechBubbleShape shapeWithRadius:5
                                                                                                    pointLocation:90
                                                                                                       pointAngle:90
                                                                                                        pointSize:pointSize]
                                                                        next:
                                                 [MCTReflectiveFillStyle styleWithColor:color
                                                                topEndHighlightLocation:(2 + BUBBLE_POINT_W + m + btnH / 2) / bFrame.size.height
                                                                                   next:
                                                  [TTBevelBorderStyle styleWithHighlight:[color shadow]
                                                                                  shadow:[color multiplyHue:1 saturation:0.5 value:0.5]
                                                                                   width:1
                                                                             lightSource:0
                                                                                    next:
                                                   [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1)
                                                                           next:
                                                    [TTBevelBorderStyle styleWithHighlight:nil
                                                                                    shadow:RGBACOLOR(0,0,0,0.15)
                                                                                     width:1
                                                                               lightSource:0
                                                                                      next:nil]]]]];
        }
    }
}

- (void)updateGender
{
    T_UI();
    NSInteger row = [self.genderPicker selectedRowInComponent:0];
    self.identity.gender = row == 0 ? MCTIdentityGenderMale : MCTIdentityGenderFemale;
}

- (void)onGenderDoneClicked:(id)sender
{
    T_UI();
    [self toggleGenderPicker:NO];
    [self updateGender];
    [self.tableView reloadData];
}

- (void)toggleGenderPicker:(BOOL)visible
{
    T_UI();

    if (visible) {
        self.genderPickerSpeechBubble.alpha = 1;
        [self.tableView addSubview:self.genderPickerSpeechBubble];
    } else {
        self.genderPickerSpeechBubble.alpha = 0;
        [self.genderPickerSpeechBubble removeFromSuperview];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    T_UI();
    MCT_RELEASE(self.currentAlertView);
}

#pragma mark - MCTIntent

- (void)registerIntents
{
    T_UI();
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:@[kINTENT_IDENTITY_MODIFIED,
                                                                      kINTENT_IDENTITY_QR_RETREIVED]
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_IDENTITY_MODIFIED) {
        if (!self.editing) {
            [self loadIdentity];
            [self.tableView reloadData];
        }
    } else if (intent.action == kINTENT_IDENTITY_QR_RETREIVED) {
        [self loadQR];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        if (cell) {
            UIImageView *imageView = (UIImageView *) [cell viewWithTag:1];
            if (imageView) {
                imageView.image = self.qrCode;
            }
        }
    }
}

@end