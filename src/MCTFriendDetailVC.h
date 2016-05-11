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

#define MCT_ASKED_DELETE 1
#define MCT_DID_DELETE 2
#define MCT_REQUESTED_FRIEND_LOCATION 3
#define MCT_DID_INVITE 4
#define MCT_DID_SHOW_LOCATION_SERVICES_DENIED_ERROR 5

typedef enum {
    MCTFriendDetailCellTypeShareMyLocation,
    MCTFriendDetailCellTypeFriendSharesLocation,
    MCTFriendDetailCellTypeRequestLocation,
    MCTFriendDetailCellTypeMessageHistory,
    MCTFriendDetailCellTypeComposeMsg,
    MCTFriendDetailCellTypePoke,
    MCTFriendDetailCellTypeBecomeFriends,
    MCTFriendDetailCellTypeConnect,
    MCTFriendDetailCellTypePassport,
} MCTFriendDetailCellType;


@interface MCTFriendDetailVC : MCTUIViewController <UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, IMCTIntentReceiver>

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *emailLabel;
@property (nonatomic, strong) IBOutlet UITableViewCell *descriptionCell;
@property (nonatomic, strong) IBOutlet UILabel *descriptionAboutLabel;
@property (nonatomic, strong) IBOutlet UITableViewCell *passportCell;
@property (nonatomic, strong) IBOutlet UIImageView *passportImageView;
@property (nonatomic, strong) NSData *passport;
@property (nonatomic) BOOL friendDeletePopupShown;

@property (nonatomic, strong) MCTFriend *friend;
@property (nonatomic, strong) MCTFriendsPlugin *friendsPlugin;
@property (nonatomic, copy) NSString *context;
@property (nonatomic) MCTlong itemPressStartTime;
@property (nonatomic, copy) NSString *firstShowAlertText;


+ (NSString *)nibName;
+ (MCTFriendDetailVC *)viewControllerWithFriend:(MCTFriend *)friend;

- (void)registerIntents;
- (void)unregisterIntents;

- (MCTFriendDetailCellType)cellTypeForIndexPath:(NSIndexPath *)indexPath;
- (void)reloadFriendDetailsWithForce:(BOOL)useForce;

- (IBAction)shareMyLocation:(id)sender;

@end