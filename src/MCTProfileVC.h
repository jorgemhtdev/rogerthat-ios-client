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

#import "MCTUITableViewController.h"
#import "MCTIdentity.h"
#import "MCTIntentFramework.h"


@interface MCTProfileVC : MCTUITableViewController <IMCTIntentReceiver, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate,
UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIControl *avatarControl;
@property (nonatomic, strong) IBOutlet UIImageView *avatarView;
@property (nonatomic, strong) IBOutlet UILabel *nameLbl;
@property (nonatomic, strong) IBOutlet UILabel *emailLbl;
@property (nonatomic, strong) IBOutlet UILabel *editNameLbl;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UILabel *editLbl;
@property (nonatomic, strong) IBOutlet UIView *editView;
@property (nonatomic, strong) MCTIdentity *identity;
@property (nonatomic, strong) UIImage *editedProfileImage;
@property (nonatomic, strong) UIBarButtonItem *cancelButtonItem;
@property (nonatomic) BOOL completeProfileAfterRegistration;
@property (nonatomic) BOOL hasDiscoveredBeacons;


+ (MCTProfileVC *)viewController;

- (IBAction)avatarClicked:(id)sender;
- (IBAction)headerClicked:(id)sender;

@end