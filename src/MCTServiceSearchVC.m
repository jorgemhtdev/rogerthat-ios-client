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
#import "MCTServiceSearchVC.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

#import "NSData+Base64.h"

#define MCT_RESIGN_ACTIVE_TIMEOUT 2


@interface MCTServiceSearchVC ()

@property (nonatomic, strong) UIColor *categoryTextColor;
@property (nonatomic, strong) NSMutableArray *categoryHeaderViews;
@property (nonatomic, strong) NSMutableArray *tableViews;
@property (nonatomic, strong) NSMutableArray *tableDataCategories;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocationManager *locationMgr;
@property (nonatomic, copy) NSString *searchId;

- (void)executeSearch;
- (void)requestLocation;

@end


@implementation MCTServiceSearchVC



+ (MCTServiceSearchVC *)viewController
{
    MCTServiceSearchVC *vc = [[MCTServiceSearchVC alloc] initWithNibName:@"serviceSearch" bundle:nil];
    vc.title = NSLocalizedString(@"Search", nil);
    vc.hidesBottomBarWhenPushed = YES;
    vc.automaticSearchString = @"";
    return vc;
}

- (void)dealloc
{
    [self.locationMgr stopUpdatingLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [MCTUIUtils setBackgroundStripesToView:self.view];

    self.searchBar.placeholder = NSLocalizedString(@"Discover services", nil);
    [self.searchBar setShowsCancelButton:NO];

    self.headerView.hidden = YES;

    self.searchId = [MCTUtils guid];
    self.categoryTextColor = [UIColor grayColor];
    self.categoryHeaderViews = [NSMutableArray array];
    self.tableViews = [NSMutableArray array];
    self.tableDataCategories = [NSMutableArray array];

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

    NSArray *actions = [NSArray arrayWithObjects:kINTENT_SEARCH_SERVICE_RESULT, kINTENT_SEARCH_SERVICE_FAILURE,
                        kINTENT_FRIEND_ADDED, kINTENT_FRIEND_REMOVED, nil];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:actions
                                                            onQueue:[MCTComponentFramework mainQueue]];

    if (self.automaticSearchString != nil) {
        [self searchBarTextDidBeginEditing:self.searchBar];
        self.searchBar.text = self.automaticSearchString;
        [self searchBarSearchButtonClicked:self.searchBar];
    }

    if (MCT_APP_TINT_COLOR) {
        self.indicatorView.backgroundColor = MCT_APP_TINT_COLOR;
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

- (void)onSearchResult:(NSArray *)matchCategories
{
    T_UI();
    // update self.tableDataCategories with the search results
    self.headerView.hidden = NO;
    NSInteger initialCategoryCount = self.tableDataCategories.count;

    for (MCT_com_mobicage_to_service_FindServiceCategoryTO *matchCategory in matchCategories) {
        BOOL updated = NO;
        for (MCT_com_mobicage_to_service_FindServiceCategoryTO *knownCategory in self.tableDataCategories) {
            if ([knownCategory.category isEqualToString:matchCategory.category]) {
                knownCategory.items = [knownCategory.items arrayByAddingObjectsFromArray:matchCategory.items];
                knownCategory.cursor = matchCategory.cursor;

                NSInteger i = [self.tableDataCategories indexOfObject:knownCategory];
                if (i < self.tableViews.count) {
                    UITableView *tableView = self.tableViews[i];
                    [tableView reloadData];
                    [tableView flashScrollIndicators];
                }
                updated = YES;
                break;
            }
        }
        if (!updated) {
            [self.tableDataCategories addObject:matchCategory];
        }
    }

    int m = 10;
    for (NSInteger i = self.tableViews.count; i < self.tableDataCategories.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(m, 0, 0, self.headerView.height - self.indicatorView.height)];
        label.font = [UIFont systemFontOfSize:13];
        label.tag = -1;
        label.text = [((MCT_com_mobicage_to_service_FindServiceCategoryTO *)self.tableDataCategories[i]).category uppercaseString];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = self.categoryTextColor;
        label.width = [MCTUIUtils sizeForLabel:label withWidth:CGFLOAT_MAX].width;

        UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, label.width + 2 * m, label.height)];
        control.clipsToBounds = NO;
        control.tag = i;
        if (i != 0) {
            control.left = ((UIView *)self.categoryHeaderViews[i - 1]).right;
        }
        [control addTarget:self action:@selector(onHeaderTapped:) forControlEvents:UIControlEventTouchUpInside];
        [control addSubview:label];

        [self.headerView addSubview:control];
        [self.categoryHeaderViews addObject:control];

        if (i != 0) {
            int sM = 5;
            UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(-1, sM, 1, control.height - 2 * sM)];
            separator.backgroundColor = [label.textColor colorWithAlphaComponent:0.25];
            separator.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
            [control addSubview:separator];
        }

        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(i * self.contentView.width,
                                                                                0,
                                                                                self.contentView.width,
                                                                                self.contentView.height)
                                                               style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.tag = i;
        [tableView reloadData];
        [self.contentView addSubview:tableView];
        [self.tableViews addObject:tableView];
    }

    if (self.categoryHeaderViews.count) {
        self.contentView.contentSize = CGSizeMake(self.contentView.width * self.tableDataCategories.count, self.contentView.height);
        self.headerView.contentSize = CGSizeMake(((UIControl *)self.categoryHeaderViews[self.categoryHeaderViews.count - 1]).right,
                                                 self.headerView.height);
    } else {
        self.contentView.contentSize = CGSizeZero;
        self.headerView.contentSize= CGSizeZero;
    }

    if (initialCategoryCount == 0) {
        [self moveIndicatorToPage:0 animated:NO];
    }

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
                self.headerView.top -= navHeight;
                self.contentView.top -= navHeight;
                self.contentView.height += navHeight;
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
                self.headerView.top += navHeight;
                self.contentView.top += navHeight;
                self.contentView.height -= navHeight;
            }];
        });
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)clearScreen
{
    T_UI();
    self.contentView.contentOffset = self.headerView.contentOffset = CGPointZero;
    self.headerView.hidden = YES;
    self.currentLocation = nil;
    [self.tableDataCategories removeAllObjects];
    for (UITableView *tableView in self.tableViews) {
        [tableView removeFromSuperview];
        tableView.delegate = nil;
        tableView.dataSource = nil;
    }
    [self.tableViews removeAllObjects];
    for (UIControl* headerView in self.categoryHeaderViews) {
        [headerView removeFromSuperview];
    }
    [self.categoryHeaderViews removeAllObjects];
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

    [self clearScreen];
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

- (void)onHeaderTapped:(UIControl *)sender
{
    T_UI();
    LOG(@"Tapped header %d", sender.tag);
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.contentView.contentOffset = CGPointMake(self.contentView.width * sender.tag, 0);
                         [self moveIndicatorToPage:sender.tag animated:NO];
                     }];
}

- (void)moveIndicatorToPage:(NSInteger)page animated:(BOOL)animated
{
    T_UI();
    dispatch_block_t animations = ^{
        UIControl *sender = self.categoryHeaderViews[page];
        self.indicatorView.left = sender.left;
        self.indicatorView.width = sender.width;
        for (UIControl *control in self.categoryHeaderViews) {
            UILabel *categoryLabel = (UILabel *) [control viewWithTag:-1];
            if (control == sender) {
                categoryLabel.textColor = self.indicatorView.backgroundColor;
            } else {
                categoryLabel.textColor = self.categoryTextColor;
            }
        }

        // Try to center sender
        self.headerView.contentOffset = CGPointMake(MAX(MIN(sender.centerX - self.headerView.width / 2,
                                                            self.headerView.contentSize.width - self.headerView.width),
                                                        0),
                                                    0);
    };

    if (animated) {
        [UIView animateWithDuration:0.2 animations:animations];
    } else {
        animations();
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    T_UI();
    if (scrollView == self.contentView) {
        // Switch the indicator when more than 50% of the previous/next page is visible
        CGFloat pageWidth = scrollView.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

        [self moveIndicatorToPage:page animated:YES];
    }
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    T_UI();
    if ([self.tableDataCategories count]) {
        [self clearScreen];
    }
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

    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusRestricted:
            LOG(@"kCLAuthorizationStatusRestricted");
            [self executeSearch];
            break;
        case kCLAuthorizationStatusDenied:
            LOG(@"kCLAuthorizationStatusDenied");
            [self executeSearch];
            break;
        case kCLAuthorizationStatusAuthorized:
            LOG(@"kCLAuthorizationStatusAuthorized");
            [self performSelector:@selector(locationTimedOut) withObject:nil afterDelay:MCT_LOCATION_TIMEOUT];
            [self requestLocation];
            break;
        case kCLAuthorizationStatusNotDetermined:
            LOG(@"kCLAuthorizationStatusNotDetermined");
            // fallback to default
        default:
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didResignActive)
                                                         name:UIApplicationWillResignActiveNotification
                                                       object:nil];
            [self performSelector:@selector(didNotResignActive) withObject:nil afterDelay:MCT_RESIGN_ACTIVE_TIMEOUT];
            [self requestLocation];
            break;
    }

}

- (void)didNotResignActive
{
    T_UI();
    HERE();
    // User was already asked permission to get location, locationManager is resolving location atm
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [self performSelector:@selector(locationTimedOut) withObject:nil afterDelay:MCT_LOCATION_TIMEOUT - MCT_RESIGN_ACTIVE_TIMEOUT];
}

- (void)didResignActive
{
    T_UI();
    HERE();
    // User is asked permission to get location
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didNotResignActive) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)didBecomeActive
{
    T_UI();
    HERE();
    // User answered the permission popup
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    // LocationManager started resolving location if user Allowed, else it does nothing

    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            LOG(@"kCLAuthorizationStatusNotDetermined");
            ERROR(@"Should not come here");
        case kCLAuthorizationStatusRestricted:
            LOG(@"kCLAuthorizationStatusRestricted");
            [self executeSearch];
            break;
        case kCLAuthorizationStatusDenied:
            LOG(@"kCLAuthorizationStatusDenied");
            [self executeSearch];
            break;
        case kCLAuthorizationStatusAuthorized:
            LOG(@"kCLAuthorizationStatusAuthorized");
        default:
            [self performSelector:@selector(locationTimedOut) withObject:nil afterDelay:MCT_LOCATION_TIMEOUT];
            break;
    }
}


- (void)executeSearchWithCursor:(NSString *)cursor
{
    T_UI();
    HERE();
    NSString *searchString = self.searchBar.text;
    LOG(@"Starting service search for searchstring '%@' organizationType '%d' and location %@",
        searchString, self.organizationType,  self.currentLocation);

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [[MCTComponentFramework friendsPlugin] findServiceWithSearchString:searchString
                                                                  location:self.currentLocation
                                                          organizationType:self.organizationType
                                                                    cursor:cursor
                                                                identifier:self.searchId];
    }];
}

- (void)executeSearch
{
    T_UI();
    [self executeSearchWithCursor:nil];
}

- (void)requestLocation
{
    T_UI();
    HERE();
    self.currentLocation = nil;
    if (self.locationMgr == nil) {
        self.locationMgr = [[CLLocationManager alloc] init];
        self.locationMgr.delegate = self;
        self.locationMgr.desiredAccuracy = kCLLocationAccuracyKilometer;
        self.locationMgr.distanceFilter = 1.0f;
    }
    [self.locationMgr startUpdatingLocation];
}

- (void)locationTimedOut
{
    T_UI();
    HERE();
    self.currentLocation = self.locationMgr.location;
    [self executeSearch];
    [self.locationMgr stopUpdatingLocation];
    MCT_RELEASE(self.locationMgr);
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    T_UI();
    HERE();
    if (self.locationMgr != manager)
        return;

    MCTlong tenMinutes = 600;
    NSTimeInterval secondsAgo = fabs([newLocation.timestamp timeIntervalSinceNow]);
    if (secondsAgo > tenMinutes)
        return;

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locationTimedOut) object:nil];
    [self.locationMgr stopUpdatingLocation];
    MCT_RELEASE(self.locationMgr);
    self.currentLocation = newLocation;
    [self executeSearch];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LOG(@"User clicked section %d row %d", indexPath.section, indexPath.row);

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    MCT_com_mobicage_to_service_FindServiceCategoryTO *category = [self.tableDataCategories objectAtIndex:tableView.tag];
    if (indexPath.row >= category.items.count)
        return; // User clicked the "Loading..." cell

    MCT_com_mobicage_to_service_FindServiceItemTO *item = [category.items objectAtIndex:indexPath.row];
    MCTFriend *service = [MCTFriend aFriend];
    service.name = item.name;
    service.avatar = [NSData dataFromBase64String:item.avatar];
    service.descriptionX = item.descriptionX;
    service.email = item.email;
    service.qualifiedIdentifier = item.qualified_identifier;
    service.type = MCTFriendTypeService;
    service.existence = cell.tag;
    service.descriptionBranding = item.description_branding;

    UIViewController *viewController;
    if (service.existence == MCTFriendExistenceActive) {
        MCTServiceMenuVC *vc = [MCTServiceMenuVC viewControllerWithService:service];
        viewController = vc;
    } else {
        MCTServiceDetailVC *vc = [MCTServiceDetailVC viewControllerWithService:service];
        viewController = vc;
    }
    [self.navigationController pushViewController:viewController animated:YES];
    self.navigationController.navigationBarHidden = NO;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    MCT_com_mobicage_to_service_FindServiceCategoryTO *category = self.tableDataCategories[tableView.tag];
    NSInteger c = category.items.count;
    if (category.cursor) {
        c++;
    }
    return c;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCT_com_mobicage_to_service_FindServiceCategoryTO *category = self.tableDataCategories[tableView.tag];

    if (indexPath.row == category.items.count) {
        // show spinner MORE cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cursor"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cursor"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = NSLocalizedString(@"Loading ...", nil);
        }

        if (!category.cursor) {
            ERROR(@"Expecting a cursor in category %@", category);
        } else {
            [self executeSearchWithCursor:category.cursor];
        }

        return cell;
    }

    MCT_com_mobicage_to_service_FindServiceItemTO *item = category.items[indexPath.row];

    long cellStyle = item.detail_text == nil ? UITableViewCellStyleDefault : UITableViewCellStyleSubtitle;

    NSString *reuseIdentifier = [NSString stringWithFormat:@"SearchResult-%ld", cellStyle];
    MCTContactCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[MCTContactCell alloc] initWithStyle:cellStyle reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.detail_text;

    MCTFriendExistence existence = [[[MCTComponentFramework friendsPlugin] store] friendExistenceForEmail:item.email];
    if (existence == MCTFriendExistenceActive) {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.tag = MCTFriendExistenceActive;
    } else if (existence == MCTFriendExistenceInvitePending) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = spinner;
        [spinner startAnimating];
        cell.tag = MCTFriendExistenceInvitePending;
    } else {
        // MCTFriendExistenceNotFound, MCTFriendExistenceDeletePending, MCTFriendExistenceDeleted
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.tag = MCTFriendExistenceNotFound;
    }

    if (![MCTUtils isEmptyOrWhitespaceString:item.avatar])
        cell.imageView.image = [UIImage imageWithData:[NSData dataFromBase64String:item.avatar]];
    else
        cell.imageView.image = [UIImage imageNamed:MCT_UNKNOWN_AVATAR];

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
    if (intent.action == kINTENT_SEARCH_SERVICE_RESULT) {
        if ([self.searchId isEqualToString:[intent stringForKey:@"search_id"]]) {
            NSString *error_string = [intent stringForKey:@"error_string"];

            if (![MCTUtils isEmptyOrWhitespaceString:error_string]) {
                [self onSearchStopped];
                self.currentAlertView = [MCTUIUtils showErrorAlertWithText:error_string];
                self.currentAlertView.delegate = self;
                return;
            }

            NSDictionary *resultDict = [[intent stringForKey:@"result"] MCT_JSONValue];
            MCT_com_mobicage_to_service_FindServiceResponseTO *response =
                [[MCT_com_mobicage_to_service_FindServiceResponseTO alloc] initWithDict:resultDict];

            [self onSearchResult:response.matches];
        }
    }

    else if (intent.action == kINTENT_SEARCH_SERVICE_FAILURE) {

        if ([self.searchId isEqualToString:[intent stringForKey:@"search_id"]]) {
            [self onSearchStopped];
            self.currentAlertView = [MCTUIUtils showErrorPleaseRetryAlert];
            self.currentAlertView.delegate = self;
        }
    }

    else if ((intent.action == kINTENT_FRIEND_ADDED && [intent longForKey:@"friend_type"] == MCTFriendTypeService)
             || intent.action == kINTENT_FRIEND_REMOVED) {

        NSString *email = [intent stringForKey:@"email"];
        for (MCT_com_mobicage_to_service_FindServiceCategoryTO *category in self.tableDataCategories) {
            for (MCT_com_mobicage_to_service_FindServiceItemTO *item in category.items) {
                if ([email isEqualToString:item.email]) {
                    [self.tableViews[[self.tableDataCategories indexOfObject:category]] reloadData];
                }
            }
        }
    }
}

@end