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

#import "MCTUIViewController.h"
#import "MCTFriend.h"
#import "MCTFriendsPlugin.h"
#import "MCTIntentFramework.h"
#import "MCTShareServiceViaEmailVC.h"

#import <FacebookSDK/FacebookSDK.h>


@interface MCTShareServiceVC : MCTUIViewController <UIScrollViewDelegate, UITableViewDataSource, UIAlertViewDelegate, IMCTIntentReceiver> 

@property (nonatomic, strong) MCTFriend *service;
@property (nonatomic, strong) MCTFriendsPlugin *friendsPlugin;
@property (nonatomic, strong) MCTShareServiceViaEmailVC *shareViaEmailVC;
@property (nonatomic) BOOL pageControlBeingUsed;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *currentShares;
@property (nonatomic, strong) NSMutableDictionary *friendEmails;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIView *selectionView;

@property (nonatomic, strong) IBOutlet UITableView *addressBookTableView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *addressBookSpinner;
@property (nonatomic, strong) IBOutlet UITableView *rogerthatTableView;
@property (nonatomic, strong) IBOutlet UIView *facebookView;
@property (nonatomic, strong) IBOutlet UIControl *facebookBtn;
@property (nonatomic, strong) IBOutlet UILabel *facebookLabel;

@property (nonatomic, strong) IBOutlet UIControl *recommendViaRogerthat;
@property (nonatomic, strong) IBOutlet UIControl *recommendViaContacts;
@property (nonatomic, strong) IBOutlet UIControl *recommendViaEmail;
@property (nonatomic, strong) IBOutlet UIControl *recommendViaFacebook;

@property (nonatomic, strong) IBOutlet UIImageView *recommendViaRogerthatImageView;
@property (nonatomic, strong) IBOutlet UIImageView *recommendViaContactsImageView;
@property (nonatomic, strong) IBOutlet UIImageView *recommendViaEmailImageView;
@property (nonatomic, strong) IBOutlet UIImageView *recommendViaFacebookImageView;

@property(nonatomic, assign) int currentPage;

+ (MCTShareServiceVC *)viewControllerWithService:(MCTFriend *)service;

- (IBAction)onControlTapped:(id)sender;
- (IBAction)onFacebookBtnTapped:(id)sender;

@end