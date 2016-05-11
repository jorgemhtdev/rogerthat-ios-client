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
#import "MCTDefaultMessageListVC.h"
#import "MCTFriendDetailVC.h"
#import "MCTFriendInviteLocationSharingVC.h"
#import "MCTFriendsPlugin.h"
#import "MCTLocationPlugin.h"
#import "MCTMenuVC.h"
#import "MCTMessageDetailVC.h"
#import "MCTMessageHelper.h"
#import "MCTOperation.h"
#import "MCTUIUtils.h"

#import "NSData+Base64.h"


#define SECT_LOC_SHARING 1
#define ROW_SHARE_LOC 0
#define ROW_SHARES_LOC 1
#define ROW_LOC_REQUEST 2

#define SECT_ACTIONS 0
#define ROW_COMPOSE_MSG 0
#define ROW_MSG_HISTORY 1

#define SECT_PASSPORT 2
#define ROW_PASSPORT 0


@interface MCTFriendDetailVC ()

- (BOOL)isDashboardEmail:(NSString *)email;

- (NSString *)titleNavigationBar;
- (NSString *)titleUnfriendBtn;
- (NSString *)confirmationRemoveFriend;
- (NSString *)messageFriendRemoved;
- (NSString *)pokeAction;
- (BOOL)shouldShowPassport;

- (void)alertFriendDeleted;
- (void)deleteFriend;
- (void)loadPassport;

@end


@implementation MCTFriendDetailVC



+ (NSString *)nibName
{
    T_UI();
    return @"friendDetails";
}

+ (MCTFriendDetailVC *)viewControllerWithFriend:(MCTFriend *)friend
{
    MCTFriendDetailVC *vc;
    vc = [[MCTFriendDetailVC alloc] initWithNibName:[MCTFriendDetailVC nibName] bundle:nil];
    vc.friend = friend;
    return vc;
}


- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    [MCTUIUtils addRoundedBorderToView:self.avatarImageView];
    self.headerView.clipsToBounds = NO;

    [MCTUIUtils setBackgroundStripesToView:self.view];
    [MCTUIUtils setBackgroundStripesToView:self.tableView];
    self.title = [self titleNavigationBar];
    self.friendsPlugin = [MCTComponentFramework friendsPlugin];

    if (self.friend.existence == MCTFriendExistenceActive && ![self isDashboardEmail:self.friend.email]) {
        if (!IS_FLAG_SET(self.friend.flags, MCTFriendFlagNotRemovable)) {
            self.navigationItem.rightBarButtonItem =
                [[UIBarButtonItem alloc] initWithTitle:[self titleUnfriendBtn]
                                                  style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(onDeleteButtonClicked:)];
            IF_IOS5_OR_GREATER({
                self.navigationItem.rightBarButtonItem.tintColor = RGBCOLOR(204, 51, 51);
            });
        }
    }

    [self registerIntents];
    [self reloadFriendDetailsWithForce:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.firstShowAlertText) {
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:self.firstShowAlertText];
        // no delegate
        self.firstShowAlertText = nil;
    }
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

- (BOOL)isDashboardEmail:(NSString *)email
{
    T_UI();
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", MCT_REGEX_DASHBOARD];
    BOOL matches = [regex evaluateWithObject:email];
    return matches;
}

- (IBAction)shareMyLocation:(id)sender
{
    T_UI();
    UISwitch *switcher = (UISwitch *)sender;

    if (switcher.on) {
        // Show an error message if Location Services are not enabled
        NSString *error = nil;
        CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
        if (authStatus == kCLAuthorizationStatusDenied) {
            error = [NSString stringWithFormat:NSLocalizedString(@"_share_location_error_authorization_denied", nil),
                       MCT_PRODUCT_NAME, self.friend.displayName];
        } else {
            IF_IOS8_OR_GREATER({
                if (authStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
                    error = [NSString stringWithFormat:
                               NSLocalizedString(@"_share_location_error_authorization_when_in_use", nil),
                               MCT_PRODUCT_NAME, self.friend.displayName];
                }
            });
        }

        if (error) {
            NSString *howToEnable = @"";
            IF_IOS8_OR_GREATER({
                howToEnable = [NSString stringWithFormat:NSLocalizedString(@"_enable_location_services_ios8", nil),
                               MCT_PRODUCT_NAME];
            });
            IF_PRE_IOS8({
                howToEnable = [NSString stringWithFormat:NSLocalizedString(@"_enable_location_services_ios7", nil),
                               MCT_PRODUCT_NAME];
            });

            self.currentAlertView = [MCTUIUtils showAlertWithTitle:NSLocalizedString(@"Error", nil)
                                                           andText:[NSString stringWithFormat:@"%@\n\n%@",
                                                                    error, howToEnable]
                                                            andTag:MCT_DID_SHOW_LOCATION_SERVICES_DENIED_ERROR];
            self.currentAlertView.delegate = self;

            [switcher setOn:NO animated:YES];
            return;
        }
    }

    self.friend.shareLocation = switcher.on;

    MCT_com_mobicage_to_friends_ShareLocationRequestTO *request =
            [MCT_com_mobicage_to_friends_ShareLocationRequestTO transferObject];
    request.enabled = self.friend.shareLocation;
    request.friend = self.friend.email;

    [[MCTComponentFramework workQueue]
     addOperation:[MCTInvocationOperation operationWithTarget:self.friendsPlugin
                                                     selector:@selector(shareMyLocationWithRequest:)
                                                       object:request]];
}

#pragma mark -
#pragma mark Private methods

- (NSString *)titleNavigationBar
{
    switch (MCT_FRIENDS_CAPTION) {
        case MCTFriendsCaptionColleagues:
            return NSLocalizedString(@"Colleague", nil);
        case MCTFriendsCaptionContacts:
            return NSLocalizedString(@"Contact", nil);
        case MCTFriendsCaptionFriends:
        default:
            return NSLocalizedString(@"Friend", nil);
    }
}

- (NSString *)titleUnfriendBtn
{
    switch (MCT_FRIENDS_CAPTION) {
        case MCTFriendsCaptionColleagues:
        case MCTFriendsCaptionContacts:
            return NSLocalizedString(@"Disconnect", nil);
        case MCTFriendsCaptionFriends:
        default:
            return NSLocalizedString(@"Unfriend", nil);
    }
}

- (NSString *)confirmationRemoveFriend
{
    switch (MCT_FRIENDS_CAPTION) {
        case MCTFriendsCaptionColleagues:
        case MCTFriendsCaptionContacts:
            return NSLocalizedString(@"Are you sure you wish to disconnect %@?", nil);
        case MCTFriendsCaptionFriends:
        default:
            return NSLocalizedString(@"Are you sure you wish to unfriend %@?", nil);
    }
}

- (NSString *)messageFriendRemoved
{
    switch (MCT_FRIENDS_CAPTION) {
        case MCTFriendsCaptionColleagues:
            return NSLocalizedString(@"Colleague has been removed", nil);
        case MCTFriendsCaptionContacts:
            return NSLocalizedString(@"Contact has been removed", nil);
        case MCTFriendsCaptionFriends:
        default:
            return NSLocalizedString(@"Friend has been removed", nil);
    }
}

- (NSString *)pokeAction
{
    return nil;
}

- (BOOL)shouldShowPassport
{
    return self.friend.existence == MCTFriendExistenceActive;
}

- (void)reloadFriendDetailsWithForce:(BOOL)useForce
{
    T_UI();
    if (useForce) {
        self.friend = [self.friendsPlugin.store friendByEmail:self.friend.email];
        if (self.friend == nil) {
            [self alertFriendDeleted];
            return;
        }
    }

    if (self.friend) {
        self.avatarImageView.image = [self.friend avatarImage];
        self.nameLabel.text = [self.friend displayName];
        self.nameLabel.textColor = [UIColor blackColor];
        self.emailLabel.text = [self.friend displayEmail];
        self.emailLabel.textColor = [UIColor blackColor];

        if ([self shouldShowPassport]) {
            if (self.passport == nil) {
                [[MCTComponentFramework workQueue]
                 addOperation:[MCTInvocationOperation operationWithTarget:self.friendsPlugin
                                                                 selector:@selector(requestUserQRWithEmail:)
                                                                   object:self.friend.email]];
            } else {
                [self loadPassport];
            }
        }
        [self.tableView reloadData];
    }
}

- (void)onDeleteButtonClicked:(id)sender
{
    T_UI();
    NSString *msg = [NSString stringWithFormat:[self confirmationRemoveFriend], [self.friend displayName]];
    self.currentAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                     message:msg
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"No", nil)
                                              otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    self.currentAlertView.tag = MCT_ASKED_DELETE;
    [self.currentAlertView show];
}

- (void)alertFriendDeleted
{
    T_UI();
    LOG(@"alertFriendDeleted - %@", self);
    if (self.friendDeletePopupShown)
        return;

    self.friendDeletePopupShown = YES;
    if (self.view.window == nil) {
        // View is not being showed
        while ([self.navigationController.viewControllers containsObject:self]) {
            [self.navigationController popViewControllerAnimated:NO];
        }
        return;
    }

    self.currentAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                     message:[self messageFriendRemoved]
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"Roger that", nil)
                                           otherButtonTitles:nil];
    self.currentAlertView.tag = MCT_DID_DELETE;
    [self.currentAlertView show];
}

- (void)deleteFriend
{
    T_UI();
    [self.friendsPlugin markFriendDeletePendingWithEmail:self.friend.email];
}

- (void)loadPassport
{
    T_UI();
    if (!self.passportCell) {
        self.passportCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"passport"];
        self.passportCell.backgroundColor = [UIColor whiteColor];
        self.passportCell.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, 44);
        self.passportCell.selectionStyle = UITableViewCellSelectionStyleNone;

        self.passportImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:self.passport]];
        self.passportImageView.frame = CGRectMake(20, 0, [[UIScreen mainScreen] applicationFrame].size.width - 40, [[UIScreen mainScreen] applicationFrame].size.width - 40);
        [self.passportCell.contentView addSubview:self.passportImageView];
    }
}

#pragma mark -
#pragma mark Intent methods

- (void)registerIntents
{
    T_UI();
    NSArray *actions = [NSArray arrayWithObjects:kINTENT_FRIENDS_RETRIEVED, kINTENT_FRIEND_MODIFIED,
                        kINTENT_FRIEND_REMOVED, kINTENT_SERVICE_BRANDING_RETRIEVED, kINTENT_USER_QRCODE_RETRIEVED, nil];

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
    if (intent.action == kINTENT_FRIENDS_RETRIEVED) {
        [self reloadFriendDetailsWithForce:YES];
    }

    else if (intent.action == kINTENT_FRIEND_MODIFIED || intent.action == kINTENT_FRIEND_REMOVED) {
        if ([self.friend.email isEqualToString:[intent stringForKey:@"email"]]) {
            // The intent is about the user currently showed
            if (intent.action == kINTENT_FRIEND_MODIFIED) {
                [self reloadFriendDetailsWithForce:YES];
            } else if (intent.action == kINTENT_FRIEND_REMOVED) {
                [self alertFriendDeleted];
            }
        }
    }

    else if (intent.action == kINTENT_SERVICE_BRANDING_RETRIEVED) {
        if ([self.friend.email isEqualToString:[intent stringForKey:@"email"]]) {
            [self reloadFriendDetailsWithForce:NO];
        }
    }

    else if (intent.action == kINTENT_USER_QRCODE_RETRIEVED) {
        if ([self.friend.email isEqualToString:[intent stringForKey:@"email"]] && [intent hasStringKey:@"qrcode"]) {

            self.passport = [NSData dataFromBase64String:[intent stringForKey:@"qrcode"]];
            [self reloadFriendDetailsWithForce:NO];
        }
    }

    else if (intent.action == kINTENT_MESSAGE_RECEIVED_HIGH_PRIO) {
        if (self.context && [self.context isEqualToString:[intent stringForKey:@"context"]]) {
            MCT_RELEASE(self.context);
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setProgress) object:nil];
            [self performSelector:@selector(loadMessageWithKey:)
                       withObject:[intent stringForKey:@"message_key"]
                       afterDelay:0.4];
        }
    }
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (MCTFriendDetailCellType)cellTypeForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECT_LOC_SHARING && indexPath.row == ROW_SHARE_LOC)
        return MCTFriendDetailCellTypeShareMyLocation;

    if (indexPath.section == SECT_LOC_SHARING && indexPath.row == ROW_SHARES_LOC)
        return MCTFriendDetailCellTypeFriendSharesLocation;

    if (indexPath.section == SECT_LOC_SHARING && indexPath.row == ROW_LOC_REQUEST)
        return MCTFriendDetailCellTypeRequestLocation;

    if (indexPath.section == SECT_ACTIONS && indexPath.row == ROW_COMPOSE_MSG)
        return MCTFriendDetailCellTypeComposeMsg;

    if (indexPath.section == SECT_ACTIONS && indexPath.row == ROW_MSG_HISTORY)
        return MCTFriendDetailCellTypeMessageHistory;

    if (indexPath.section == SECT_PASSPORT && indexPath.row == ROW_PASSPORT)
        return MCTFriendDetailCellTypePassport;

    ERROR(@"NSIndexPath (%d,%d) not expected for table in %@", indexPath.section, indexPath.row, [self class]);
    return -1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    T_UI();
    return 3;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    switch (section) {
        case SECT_LOC_SHARING:
            return (self.friend.sharesLocation) ? 3 : 2;
        case SECT_ACTIONS:
            return 2;
        case SECT_PASSPORT:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTFriendDetailCellType cellType = [self cellTypeForIndexPath:indexPath];
    if (cellType == MCTFriendDetailCellTypePassport && self.passport) {
        return self.passportCell;
    }

    NSString *ident = [NSString stringWithFormat:@"%d", cellType];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        UITableViewCellStyle cellStyle = UITableViewCellStyleValue1;

        cell = [[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:ident];

        cell.selectionStyle = UITableViewCellSelectionStyleBlue;

        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [cell.detailTextLabel.font fontWithSize:13];
        cell.detailTextLabel.textColor = [UIColor grayColor];

        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [cell.textLabel.font fontWithSize:13];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.textColor = [UIColor blackColor];
    }

    switch (cellType)
    {
        case MCTFriendDetailCellTypeShareMyLocation: {
            cell.textLabel.text = NSLocalizedString(@"Can see my location", nil);
            UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectZero];
            switcher.on = self.friend.shareLocation;
            [switcher addTarget:self action:@selector(shareMyLocation:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
            break;
        }
        case MCTFriendDetailCellTypeFriendSharesLocation: {
            cell.textLabel.text = NSLocalizedString(@"Shares location with me", nil);
            if (self.friend.sharesLocation) {
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                cell.detailTextLabel.text = NSLocalizedString(@"No...", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
            break;
        }
        case MCTFriendDetailCellTypeRequestLocation: {
            cell.textLabel.text = NSLocalizedString(@"Request location now", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case MCTFriendDetailCellTypeMessageHistory:
            cell.textLabel.text = NSLocalizedString(@"View message history", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;

        case MCTFriendDetailCellTypeComposeMsg:
            cell.textLabel.text = NSLocalizedString(@"Compose new message", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;

        case MCTFriendDetailCellTypePoke:
            cell.textLabel.text = self.friend.pokeDescription;
            cell.textLabel.font = [cell.textLabel.font fontWithSize:17];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;

        case MCTFriendDetailCellTypeBecomeFriends: {
            NSString *format = IS_ENTERPRISE_APP ? NSLocalizedString(@"Connect to %@", nil)
                                                 : NSLocalizedString(@"Become friends with %@", nil);
            cell.textLabel.text = [NSString stringWithFormat:format, [self.friend displayName]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case MCTFriendDetailCellTypeConnect:
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Connect to %@", nil),
                                   [self.friend displayName]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;

        case MCTFriendDetailCellTypePassport: {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Fetching Rogerthat passport...", nil), MCT_PRODUCT_NAME];
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [spinner startAnimating];
            cell.accessoryView = spinner;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        default:
            break;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    CGFloat h = 44;

    switch ([self cellTypeForIndexPath:indexPath]) {
        case MCTFriendDetailCellTypePoke: {
            h = [MCTUIUtils heightForCell:[self tableView:tableView cellForRowAtIndexPath:indexPath]];
            break;
        }
        case MCTFriendDetailCellTypePassport:
            if (self.passport) {
                h = [[UIScreen mainScreen] applicationFrame].size.width - 20;
            }
        default:
            break;
    }

    return h;
}

#pragma mark -
#pragma mark UITableViewDataDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section ? 0 /* default */ : 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    switch ([self cellTypeForIndexPath:indexPath]) {
        case MCTFriendDetailCellTypeFriendSharesLocation: {
            if (!self.friend.sharesLocation) {
                MCTFriendInviteLocationSharingVC *inviteLocSharingVC =
                [MCTFriendInviteLocationSharingVC viewControllerWithFriend:self.friend];
                [self.navigationController pushViewController:inviteLocSharingVC animated:YES];
            }
            break;
        }

        case MCTFriendDetailCellTypeRequestLocation: {
            [[MCTComponentFramework workQueue]
             addOperation:[MCTInvocationOperation operationWithTarget:[MCTComponentFramework locationPlugin]
                                                             selector:@selector(requestLocationOfFriend:)
                                                               object:self.friend.email]];
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"You will receive a message when the location of %@ is retrieved.", nil),
                             [self.friend displayName]];
            self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:msg];
            self.currentAlertView.tag = MCT_REQUESTED_FRIEND_LOCATION;
            self.currentAlertView.delegate = self;
            break;
        }

        case MCTFriendDetailCellTypeComposeMsg: {
            MCTSendMessageRequest *request = [MCTSendMessageRequest request];
            request.members = [NSArray arrayWithObjects:self.friend.email, nil];

            [self presentViewController:[MCTMessageHelper composeMessageViewControllerWithRequest:request
                                                                                     andReplyOnMessage:nil]
                                    animated:YES completion:nil];
            break;
        }

        case MCTFriendDetailCellTypeMessageHistory: {
            MCTDefaultMessageListVC *vc = [MCTDefaultMessageListVC viewController];
            vc.filter = [MCTMessageFilter filterWithType:MCTMessageFilterByFriend andArgument:self.friend.email];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }

        default:
            break;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (alertView.tag == MCT_ASKED_DELETE && buttonIndex == 1) {
        // Clicked OK button
        [self deleteFriend];
    } else if (alertView.tag == MCT_DID_DELETE || alertView.tag == MCT_DID_INVITE) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (alertView.tag == MCT_REQUESTED_FRIEND_LOCATION) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_CHANGE_TAB];
        [intent setLong:MCT_MENU_TAB_MESSAGES forKey:@"tab"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    } else if (alertView.tag == MCT_DID_SHOW_LOCATION_SERVICES_DENIED_ERROR) {
        // Do nothing
    }
    MCT_RELEASE(self.currentAlertView);
}

@end