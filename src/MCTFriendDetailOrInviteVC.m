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
#import "MCTFriendDetailOrInviteVC.h"
#import "MCTOperation.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"
#import "MCTProfileDataCell.h"

#import "NSData+Base64.h"


NSString *const kSectionFriendProfileData = @"friendProfileData";
NSString *const kSectionConnect = @"connect";


@interface MCTFriendDetailOrInviteVC ()

@property (nonatomic, strong) NSMutableArray *sections;

@end


@implementation MCTFriendDetailOrInviteVC


+ (MCTFriendDetailOrInviteVC *)viewControllerWithFriend:(MCTFriend *)friend
{
    MCTFriendDetailOrInviteVC *vc = [[MCTFriendDetailOrInviteVC alloc] initWithNibName:@"friendDetails" bundle:nil];
    vc.friend = friend;
    vc.hidesBottomBarWhenPushed = YES;
    return vc;
}


- (void)viewDidLoad
{
    T_UI();
    if (self.friend.existence != MCTFriendExistenceActive) {
        self.sections = [NSMutableArray array];

        if (MCT_FRIENDS_ENABLED) {
            [self.sections addObject:kSectionConnect];
        }

        if ([MCT_PROFILE_DATA_FIELDS count]) {
            [self.sections addObject:kSectionFriendProfileData];
        }
    } else {
        self.sections = [NSMutableArray arrayWithCapacity:0];
    }

    [super viewDidLoad];

    self.emailLabel.hidden = (self.friend.existence != MCTFriendExistenceActive);

    if ([MCT_PROFILE_DATA_FIELDS count] && self.friend.existence != MCTFriendExistenceActive) {
        if ([MCTUtils connectedToInternet]) {
            [self showSpinner];
        }

        NSString *bEmail = [self.friend.email copy];
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            [[MCTComponentFramework friendsPlugin] requestUserInfoWithEmailHash:bEmail andStoreAvatar:YES allowCrossApp:NO];
        }];
    } else if (self.friend.existence == -1 && self.friend.avatarId > 0 && [MCTUtils connectedToInternet]) {
        [self showSpinner];

        MCTlong bAvatarId = self.friend.avatarId;
        NSString *bEmail = [self.friend.email copy];
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            [[MCTComponentFramework friendsPlugin] requestAvatarWithId:bAvatarId andEmail:bEmail];
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)showSpinner
{
    T_UI();
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];

    CGFloat M = 4;
    CGFloat sW = 25;
    spinner.frame = CGRectMake(M / 2, M / 2, sW, sW);

    [spinner startAnimating];

    CGRect avFrame = self.avatarImageView.frame;
    CGRect vFrame;
    vFrame.origin.x = avFrame.origin.x + avFrame.size.width - sW;
    vFrame.origin.y = avFrame.origin.y + avFrame.size.height - sW;
    vFrame.size.width = sW + M;
    vFrame.size.height = sW + M;

    UIView *overlayView = [[UIView alloc] initWithFrame:vFrame];
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.alpha = 0.8;
    overlayView.tag = 22000;
    [MCTUIUtils addRoundedBorderToView:overlayView];
    [overlayView addSubview:spinner];

    [self.avatarImageView.superview addSubview:overlayView];
}

- (void)hideSpinner
{
    T_UI();
    UIView *overlayView = [self.avatarImageView.superview viewWithTag:22000];
    if (overlayView) {
        UIActivityIndicatorView *spinner = [overlayView.subviews objectAtIndex:0];
        [spinner stopAnimating];
        [overlayView removeFromSuperview];
    }
}

#pragma mark -
#pragma mark Intents

- (void)registerIntents
{
    T_UI();
    [super registerIntents];
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:@[kINTENT_USER_AVATAR_RETRIEVED, kINTENT_USER_INFO_RETRIEVED]
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (self.friend.existence == MCTFriendExistenceActive || intent.action != kINTENT_FRIEND_MODIFIED) {
        [super onIntent:intent];
    }

    if (intent.action == kINTENT_USER_AVATAR_RETRIEVED) {
        if ([[intent stringForKey:@"email_hash"] isEqualToString:self.friend.email]) {
            self.friend.avatar = [NSData dataFromBase64String:[intent stringForKey:@"avatar"]];
            self.avatarImageView.image = [UIImage imageWithData:self.friend.avatar];
            [self hideSpinner];
        }
    } else if (intent.action == kINTENT_USER_INFO_RETRIEVED) {
        if ([[intent stringForKey:@"hash"] isEqualToString:self.friend.email]) {
            [self reloadFriendDetailsWithForce:YES];
            [self hideSpinner];
        }
    }
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    T_UI();
    if (self.friend.existence == MCTFriendExistenceActive)
        return [super numberOfSectionsInTableView:tableView];

    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    if (self.friend.existence == MCTFriendExistenceActive)
        return [super tableView:table numberOfRowsInSection:section];

    NSString *sectionId = self.sections[section];

    if (sectionId == kSectionConnect) {
        return 1;
    }

    if (sectionId == kSectionFriendProfileData) {
        return [MCT_PROFILE_DATA_FIELDS count];
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.friend.existence != MCTFriendExistenceActive && self.sections[indexPath.section] == kSectionFriendProfileData) {
        MCTProfileDataCell *cell = (MCTProfileDataCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];

        return [MCTProfileDataCell calculateHeight:cell];
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    if (self.friend.existence == MCTFriendExistenceActive)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];

    NSString *sectionId = self.sections[indexPath.section];

    NSString *ident = [NSString stringWithFormat:@"%ld:%ld", (long)indexPath.section, (long)indexPath.row];

    if (sectionId == kSectionConnect) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ident];
        }

        NSString *format = IS_ENTERPRISE_APP ? NSLocalizedString(@"Connect to %@", nil)
                                             : NSLocalizedString(@"Become friends with %@", nil);
        cell.textLabel.text = [NSString stringWithFormat:format, [self.friend displayName]];
        cell.textLabel.font = [cell.textLabel.font fontWithSize:13];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else if (sectionId == kSectionFriendProfileData) {
        MCTProfileDataCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        NSDictionary *profileDataDict = [self.friend getProfileDataDict];
        NSString *k = MCT_PROFILE_DATA_FIELDS[indexPath.row];
        NSString *v = profileDataDict[k];

        if (cell == nil) {
            cell = [[MCTProfileDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        }

        [cell setKey:NSLocalizedString(k, nil)];
        [cell setKeyTextColor:self.view.tintColor];

        if (v == nil) {
            v = NSLocalizedString(@"Unknown", nil);
        }
        [cell setData:v];
        return cell;
    }
}

#pragma mark -
#pragma mark UITableViewDataDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    if (self.friend.existence == MCTFriendExistenceActive) {
        return [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *sectionId = self.sections[indexPath.section];
    if (sectionId != kSectionFriendProfileData) {
        if (self.friend.existence != MCTFriendExistenceActive) {
            NSString *bEmail = self.friend.email;
            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                [[MCTComponentFramework friendsPlugin] inviteFriendWithEmail:bEmail andMessage:nil];
            }];

            self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                           andText:NSLocalizedString(@"The invitation has been sent", nil)
                                                            andTag:MCT_DID_INVITE];
            self.currentAlertView.delegate = self;
        }
    }
}

@end