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
#import "MCTContactCell.h"
#import "MCTFriend.h"
#import "MCTServiceDetailVC.h"
#import "MCTServiceMenuVC.h"
#import "MCTFriendSearchVC.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"
#import "MCTDiscoveredFriendCell.h"
#import "MCTFriendDetailOrInviteVC.h"

#import "NSData+Base64.h"

#define MCT_RESIGN_ACTIVE_TIMEOUT 2


@interface MCTFriendSearchVC () 

@property (nonatomic, strong) NSMutableArray *tableDataFriends;
@property (nonatomic, copy) NSString *searchCursor;
@property (nonatomic, copy) NSString *searchId;

- (void)executeSearch;

@end


@implementation MCTFriendSearchVC



+ (MCTFriendSearchVC *)viewController
{
    MCTFriendSearchVC *vc = [[MCTFriendSearchVC alloc] initWithNibName:@"friendSearch" bundle:nil];
    switch (MCT_FRIENDS_CAPTION) {
        case MCTFriendsCaptionColleagues: {
            vc.title = NSLocalizedString(@"Colleagues", nil);
            break;
        }
        case MCTFriendsCaptionContacts: {
            vc.title = NSLocalizedString(@"Contacts", nil);
            break;
        }
        case MCTFriendsCaptionFriends:
        default: {
            vc.title = NSLocalizedString(@"Friends", nil);
            break;
        }
    }
    vc.automaticSearchString = @"";
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [MCTUIUtils setBackgroundStripesToView:self.view];

    switch (MCT_FRIENDS_CAPTION) {
        case MCTFriendsCaptionColleagues: {
            self.searchBar.placeholder = NSLocalizedString(@"Find colleagues", nil);
            break;
        }
        case MCTFriendsCaptionContacts: {
            self.searchBar.placeholder = NSLocalizedString(@"Find contacts", nil);
            break;
        }
        case MCTFriendsCaptionFriends:
        default: {
            self.searchBar.placeholder = NSLocalizedString(@"Find friends", nil);
            break;
        }
    }

    [self.searchBar setShowsCancelButton:NO];

    self.searchId = [MCTUtils guid];
    self.tableDataFriends = [NSMutableArray array];

    CGRect f = CGRectZero;
    f.origin.y = self.searchBar.frame.origin.y;
    f.size = [MCTUIUtils availableSizeForViewWithController:self];
    self.overlayView = [[UIView alloc] initWithFrame:f];
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha = 0;
    [self.view addSubview:self.overlayView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(onSearchStopped)];
    [self.overlayView addGestureRecognizer:tap];

    const CGFloat DEFAULT_LABEL_WIDTH = 280.0;
    const CGFloat DEFAULT_LABEL_HEIGHT = 50.0;
    CGRect labelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
    self.spinnerLabel = [[UILabel alloc] initWithFrame:labelFrame];
    self.spinnerLabel.text = NSLocalizedString(@"Searching…", nil);
    self.spinnerLabel.textColor = [UIColor whiteColor];
    self.spinnerLabel.backgroundColor = [UIColor clearColor];
    self.spinnerLabel.textAlignment = NSTextAlignmentCenter;
    self.spinnerLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    self.spinnerLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.spinnerLabel.hidden = YES;
    [self.overlayView addSubview:self.spinnerLabel];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.spinner.hidden = YES;
    [self.overlayView addSubview:self.spinner];

    CGFloat totalHeight = self.spinnerLabel.frame.size.height + self.spinner.frame.size.height;
    labelFrame.origin.x = floor(0.5 * (self.overlayView.frame.size.width - DEFAULT_LABEL_WIDTH));
    labelFrame.origin.y = floor(0.5 * (self.overlayView.frame.size.height - totalHeight));
    self.spinnerLabel.frame = labelFrame;

    CGRect activityIndicatorRect = self.spinner.frame;
    activityIndicatorRect.origin.x = 0.5 * (self.overlayView.frame.size.width - activityIndicatorRect.size.width);
    activityIndicatorRect.origin.y = self.spinnerLabel.frame.origin.y + self.spinnerLabel.frame.size.height;
    self.spinner.frame = activityIndicatorRect;

    NSArray *actions = [NSArray arrayWithObjects:kINTENT_SEARCH_FRIEND_RESULT, kINTENT_SEARCH_FRIEND_FAILURE, nil];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:actions
                                                            onQueue:[MCTComponentFramework mainQueue]];

    if (self.automaticSearchString != nil) {
        [self searchBarTextDidBeginEditing:self.searchBar];
        self.searchBar.text = self.automaticSearchString;
        [self searchBarSearchButtonClicked:self.searchBar];
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


#pragma mark - business code

- (void)onSearchResult:(NSArray *)friends
{
    T_UI();
    for (MCT_com_mobicage_to_friends_FindFriendItemTO *friend in friends) {
        [self.tableDataFriends addObject:friend];
    }
    [self.tableView reloadData];

    [self onSearchStopped];
}

- (void)hideNavBar
{
    T_UI();
    CGFloat navHeight = self.navigationController.navigationBar.height;
    if (self.searchBar.top >= navHeight) {
        IF_IOS7_OR_GREATER({
            [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
                self.searchBar.top -= navHeight;
                self.tableView.top -= navHeight;
                self.tableView.height += navHeight;
            }];
        });
    }
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)showNavBar
{
    T_UI();
    CGFloat navHeight = self.navigationController.navigationBar.height;
    if (self.searchBar.top < navHeight) {
        IF_IOS7_OR_GREATER({
            [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
                self.searchBar.top += navHeight;
                self.tableView.top += navHeight;
                self.tableView.height -= navHeight;
            }];
        });
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)onSearchStarted
{
    T_UI();
    [UIView animateWithDuration:0.2 animations:^{
        self.overlayView.alpha = 0.6;
        self.spinner.hidden = NO;
        [self.spinner startAnimating];
        self.spinnerLabel.hidden = NO;
    }];

    self.tableView.contentOffset = CGPointZero;
    [self.tableDataFriends removeAllObjects];
}

- (void)onSearchStopped
{
    T_UI();
    [UIView animateWithDuration:0.2 animations:^{
        self.overlayView.alpha = 0;
        self.spinner.hidden = YES;
        self.spinnerLabel.hidden = YES;
    }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self hideNavBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    HERE();
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self showNavBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    T_UI();
    if (![MCTUtils connectedToInternet]) {
        self.currentAlertView = [MCTUIUtils showNetworkErrorAlert];
        return;
    }

    [self onSearchStarted];
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self showNavBar];
    [self executeSearch];
}

- (void)executeSearchWithCursor:(NSString *)cursor
{
    T_UI();
    HERE();
    NSString *searchString = self.searchBar.text;
    LOG(@"Starting service search for searchstring '%@'", searchString);

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [[MCTComponentFramework friendsPlugin] findFriendsWithSearchString:searchString
                                                                    cursor:cursor
                                                                identifier:self.searchId]; 
    }];
}

- (void)executeSearch
{
    T_UI();
    [self executeSearchWithCursor:nil];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LOG(@"User clicked section %d row %d", indexPath.section, indexPath.row);

    if (indexPath.row >= self.tableDataFriends.count)
        return; // User clicked the "Loading..." cell

    MCT_com_mobicage_to_friends_FindFriendItemTO *friend = [self.tableDataFriends objectAtIndex:indexPath.row];
    UIViewController *viewController;
    if ([[MCTComponentFramework friendsPlugin] isMyEmail:friend.email]) {
        viewController = [MCTProfileVC viewController];
    } else {
        MCTFriend *f = [[[MCTComponentFramework friendsPlugin] store] friendByEmail:friend.email];
        if (f == nil) {
            f = [MCTFriend aFriend];
            f.email = friend.email;
            f.existence = -1;
        }
        viewController = [MCTFriendDetailOrInviteVC viewControllerWithFriend:f];
    }
    [self.navigationController pushViewController:viewController animated:YES];
    self.navigationController.navigationBarHidden = NO;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    NSInteger c = self.tableDataFriends.count;
    if (self.searchCursor) {
        c++;
    }
    return c;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();

    if (indexPath.row == self.tableDataFriends.count) {
        // show spinner MORE cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cursor"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cursor"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = NSLocalizedString(@"Loading ...", nil);
        }

        [self executeSearchWithCursor:self.searchCursor];

        return cell;
    }
    MCT_com_mobicage_to_friends_FindFriendItemTO *friend = self.tableDataFriends[indexPath.row];

    NSString *reuseIdentifier = @"SearchResult";
    MCTDiscoveredFriendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[MCTDiscoveredFriendCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

    [cell setName:friend.name];
    [cell setPicture:friend.avatar_url];
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    T_UI();
    return 1;
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == self.currentAlertView)
        MCT_RELEASE(self.currentAlertView);
}

#pragma mark - IMCTIntentReceiver

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_SEARCH_FRIEND_RESULT) {
        if ([self.searchId isEqualToString:[intent stringForKey:@"search_id"]]) {
            NSString *error_string = [intent stringForKey:@"error_string"];

            if (![MCTUtils isEmptyOrWhitespaceString:error_string]) {
                [self onSearchStopped];
                self.currentAlertView = [MCTUIUtils showErrorAlertWithText:error_string];
                self.currentAlertView.delegate = self;
                return;
            }

            NSDictionary *resultDict = [[intent stringForKey:@"result"] MCT_JSONValue];
            MCT_com_mobicage_to_friends_FindFriendResponseTO *response =
            [[MCT_com_mobicage_to_friends_FindFriendResponseTO alloc] initWithDict:resultDict];
            self.searchCursor = response.cursor;
            [self onSearchResult:response.items];
        }
    }

    else if (intent.action == kINTENT_SEARCH_FRIEND_FAILURE) {

        if ([self.searchId isEqualToString:[intent stringForKey:@"search_id"]]) {
            [self onSearchStopped];
            self.currentAlertView = [MCTUIUtils showErrorPleaseRetryAlert];
            self.currentAlertView.delegate = self;
        }
    }

}

@end