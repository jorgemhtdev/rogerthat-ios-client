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
#import "MCTGroup.h"
#import "MCTIntentFramework.h"

@interface MCTGroupDetailVC : MCTUIViewController <IMCTIntentReceiver, UINavigationControllerDelegate,
UIImagePickerControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIControl *avatarControl;
@property (nonatomic, strong) IBOutlet UIImageView *avatarView;
@property (nonatomic, strong) IBOutlet UILabel *nameLbl;
@property (nonatomic, strong) IBOutlet UILabel *emailLbl;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UILabel *editLbl;
@property (nonatomic, strong) IBOutlet UIView *editView;
@property (nonatomic, strong) MCTGroup *group;
@property (nonatomic, strong) UIImage *editedProfileImage;
@property (nonatomic, strong) UIBarButtonItem *cancelButtonItem;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) MCTFriendsPlugin *friendsPlugin;
@property (nonatomic, strong) IBOutlet UIControl *deleteGroupBtn;
@property (nonatomic, strong) IBOutlet UIControl *sendMessageBtn;
@property (nonatomic, strong) NSMutableArray *backupMembers;

+ (MCTGroupDetailVC *)viewControllerWithGroup:(MCTGroup *)group
                                   isNewGroup:(BOOL)isNewGroup
                            showComposeButton:(BOOL)showComposeButton;

- (IBAction)avatarClicked:(id)sender;
- (IBAction)onBackgroundTapped:(id)sender;
- (IBAction)onDeleteGroupClicked:(id)sender;
- (IBAction)onSendMessageClicked:(id)sender;

@end