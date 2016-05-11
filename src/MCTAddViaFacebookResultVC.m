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

#import "MCTAddViaFacebookResultVC.h"
#import "MCTComponentFramework.h"
#import "MCTFacebookFriendCell.h"
#import "MCTIntent.h"
#import "MCTMenuVC.h"
#import "MCTTransferObjects.h"
#import "MCTUIUtils.h"

#import "NSData+Base64.h"
#import "NSString+MCT_SBJSON.h"


@implementation MCTAddViaFacebookResultVC


+ (MCTAddViaFacebookResultVC *)viewController
{
    T_UI();
    return [[MCTAddViaFacebookResultVC alloc] initWithNibName:@"addViaFacebookResult" bundle:nil];
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    [MCTUIUtils setBackgroundStripesToView:self.view];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_FRIEND_ADDED
                                                            onQueue:[MCTComponentFramework mainQueue]];

    self.pendingInvites = [NSMutableArray arrayWithArray:[[[MCTComponentFramework friendsPlugin] store] pendingInvitations]];
    self.currentInvites = [NSMutableArray array];

    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    T_UI();
    [super viewWillAppear:animated];
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        // Cancel LocalNotification
        NSString *serialized = [[MCTComponentFramework configProvider] stringForKey:MCT_GOTO_ADD_FRIENDS_VIA_FACEBOOK];
        if (serialized) {
            UILocalNotification *ln = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataFromBase64String:serialized]];
            [[UIApplication sharedApplication] cancelLocalNotification:ln];
        }
    }];
}

- (void)refresh
{
    T_UI();
    HERE();
    NSString *fbScanStr = [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_FACEBOOK_FRIENDS_SCAN];
    NSMutableArray *matchDicts = [fbScanStr MCT_JSONValue];
    self.matches = [NSMutableArray arrayWithCapacity:[matchDicts count]];
    for (NSDictionary *match in matchDicts) {
        [self.matches addObject:[MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO transferObjectWithDict:match]];
    }

    // Filter out existing Rogerthat friends
    BOOL rtMatchesUpdated = NO;
    for (MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO *match in [NSArray arrayWithArray:self.matches]) {
        if ([[[MCTComponentFramework friendsPlugin] store] friendExistsWithEmail:match.rtId] ||
                [[MCTComponentFramework friendsPlugin] isMyEmail:match.rtId]) {
            rtMatchesUpdated = YES;
            LOG(@"Not displaying existing friend %@ in the facebook friends list", match.rtId);
            [self.matches removeObject:match];
        }
    }
    if (rtMatchesUpdated) {
        matchDicts = [NSMutableArray arrayWithCapacity:[self.matches count]];
        for (MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO *match in self.matches) {
            [matchDicts addObject:[match dictRepresentation]];
        }
        NSString *json = [self.matches MCT_JSONRepresentation];
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            [[MCTComponentFramework configProvider] setString:json forKey:MCT_CONFIGKEY_FACEBOOK_FRIENDS_SCAN];
        }];
    }

    [self.tableView reloadData];
}

- (void)onInviteTapped:(TTButton *)sender
{
    T_UI();
    MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO *match = [self.matches objectAtIndex:sender.tag];
    NSString *email = match.rtId;
    NSString *name = match.fbName;
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        [[MCTComponentFramework friendsPlugin] inviteFriendWithEmail:email andName:name andMessage:nil];
    }];
    [self.pendingInvites addObject:email];
    [self.currentInvites addObject:email];
    sender.enabled = NO;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:sender.tag inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    T_UI();
    return self.matches ? 1 : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    T_UI();
    NSInteger c = [self.matches count];
    if (c == 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"__fb_friends_found_none", nil), MCT_PRODUCT_NAME];
    } else if (c == 1) {
        return [NSString stringWithFormat:NSLocalizedString(@"__fb_friends_found_1", nil), MCT_PRODUCT_NAME];
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"__fb_friends_found_more", nil), c, MCT_PRODUCT_NAME];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    return [self.matches count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO *match = [self.matches objectAtIndex:indexPath.row];
    NSString *ident = match.fbId;

    MCTFacebookFriendCell *cell = (MCTFacebookFriendCell *) [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[MCTFacebookFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        [cell.ttButton addTarget:self action:@selector(onInviteTapped:) forControlEvents:UIControlEventTouchUpInside];
    }

    cell.name = match.fbName;
    cell.picture = match.fbPicture;

    BOOL pendingInvite = [self.pendingInvites containsObject:match.rtId];

    [cell.ttButton setTitle:pendingInvite ? NSLocalizedString(@"Sent", nil) : NSLocalizedString(@"Add", nil)
                   forState:UIControlStateNormal];
    cell.ttButton.enabled = ![self.currentInvites containsObject:match.rtId];
    cell.ttButton.tag = indexPath.row;

    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return 50;
}

#pragma mark -
#pragma mark MCTIntent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_FRIEND_ADDED) {
        if (self.matches) {
            for (MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO *match in self.matches) {
                if ([[intent stringForKey:@"email"] isEqualToString:match.rtId]) {
                    [self.matches removeObject:match];
                    [self.tableView reloadData];
                    break;
                }
            }
        }
    }
}

@end