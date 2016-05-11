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
#import "MCTAbstractHomeScreenVC.h"
#import "MCTFriendsTabVC.h"
#import "MCTMessageDetailVC.h"
#import "MCTMoreVC.h"
#import "MCTProfileVC.h"
#import "MCTScannerVC.h"
#import "MCTServiceMenuVC.h"
#import "MCTServiceScreenBrandingVC.h"
#import "MCTServicesTabVC.h"
#import "MCTTabMessagesVC.h"
#import "MCTUIUtils.h"
#import "MCTFriendSearchVC.h"

@interface MCTHomeScreenItem ()

@end

@implementation MCTHomeScreenItem


+ (MCTHomeScreenItem *)homeScreenItemWithPositionY:(MCTlong)y
                                                 x:(MCTlong)x
                                             label:(NSString *)label
                                             click:(NSString *)click
                                            coords:(NSArray *)coords
                                          collapse:(BOOL)collapse
{
    MCTHomeScreenItem *hsi = [[MCTHomeScreenItem alloc] init];
    hsi.x = x;
    hsi.y = y;
    hsi.label = label;
    hsi.click = click;
    hsi.coords = coords;
    hsi.collapse = collapse;
    return hsi;
}
@end

@interface MCTAbstractHomeScreenVC () {
    BOOL alreadyAppeared_;
    MCTlong itemPressStartTime_;
    NSDictionary *serviceCountByOrganizationType_;
    MCTlong lastTimeServiceCountLoaded_;
    NSMutableDictionary *clickHandlers_;
}

@property (nonatomic) BOOL alreadyAppeared;
@property (nonatomic) MCTlong itemPressStartTime;
@property (nonatomic, strong) NSDictionary *serviceCountByOrganizationType;
@property (nonatomic) MCTlong lastTimeServiceCountLoaded;
@property (nonatomic, strong) NSMutableDictionary *clickHandlers;


@end

@implementation MCTAbstractHomeScreenVC


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if ([@"dark" isEqualToString:MCT_APP_HOMESCREEN_COLOR_SCHEME]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                                                    animated:NO];
        [self setNeedsStatusBarAppearanceUpdate];
    }

    if (!self.alreadyAppeared) {
        self.alreadyAppeared = YES;
        if (IS_CITY_APP) {
            UIView *qrView = [self.scrollView viewWithTag:-1];
            self.scrollView.contentSize = CGSizeMake(self.scrollView.width, 2 * self.scrollView.height);
            self.scrollView.contentOffset = CGPointZero;
            qrView.top = self.scrollView.height;

            // Making sure the margin between every subview is the same
            CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
            CGFloat h = appFrame.size.height;
            if (!self.homescreenFooter.hidden) {
                h -= self.homescreenFooter.height;
            }

            CGFloat m = (h - self.myQrDescriptionLbl.height - self.myQrImageView.height - self.myQrBackBtn.height) / 4;
            self.myQrDescriptionLbl.top = appFrame.origin.y + m;
            self.myQrImageView.top = self.myQrDescriptionLbl.bottom + m;
            self.myQrBackBtn.top = self.myQrImageView.bottom + m;
            self.myQrSpinner.center = self.myQrImageView.center;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if ([@"dark" isEqualToString:MCT_APP_HOMESCREEN_COLOR_SCHEME]) {
        [self resetNavigationControllerAppearance];
    }
}

- /* abstract */ (MCTHomeScreenItem *)itemForPositionX:(MCTlong)x y:(MCTlong)y
{
    ERROR(@"abstract method called");
    return nil;
}

- (void)viewDidLoad
{
    T_UI();
    HERE();
    self.title = MCT_PRODUCT_NAME;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil];
    [self registerIntents];
    [self loadServiceCount];

    self.view.backgroundColor = [UIColor MCTHomeScreenBackgroundColor];

    if (MCT_FULL_WIDTH_HEADERS) {
        CGRect appFrame = [UIScreen mainScreen].applicationFrame;
        self.homescreenHeader.frame = CGRectMake(0, appFrame.origin.y, appFrame.size.width, 115 * appFrame.size.width / 320);
        self.homescreenHeader.autoresizingMask = UIViewAutoresizingNone;
    }

    self.clickHandlers = [NSMutableDictionary dictionary];

    int columCount = 0;
    if (MCT_HOME_SCREEN_STYLE == MCT_HOME_SCREEN_STYLE_3X3) {
        columCount = 3;
    } else if (MCT_HOME_SCREEN_STYLE == MCT_HOME_SCREEN_STYLE_2X3) {
        columCount = 2;
    }

    int tagcount = 1;
    for (int y = 0; y <3; y++) {
        for (int x = 0; x < columCount; x++) {
            UIView *v = [self.view viewWithTag:tagcount];
            MCTHomeScreenItem *hsi = [self itemForPositionX:x y:y];
            [self.clickHandlers setObject:hsi forKey:[NSString stringWithFormat:@"%d", tagcount]];

            for (UIView *subview in v.subviews) {
                if ([subview isKindOfClass:[UILabel class]]) {
                    UILabel *lbl = (UILabel *) subview;
                    lbl.text = hsi.label;
                    lbl.textColor = [UIColor MCTHomeScreenTextColor];
                }
            }
            tagcount++;
        }
    }

    if (MCT_SHOW_HOMESCREEN_FOOTER) {
        // Resize footer, but keep aspect ratio and place at the bottom of the screen
        CGFloat bottom = self.homescreenFooter.bottom;
        self.homescreenFooter.width = [UIScreen mainScreen].applicationFrame.size.width;
        [MCTUIUtils resizeImageView:self.homescreenFooter withAllowShrinking:NO];
        self.homescreenFooter.bottom = bottom;
    } else {
        self.homescreenFooter.hidden = YES;
    }

    self.jsMFRs = [NSMutableDictionary dictionary];

    self.badgeView.style = TTSTYLE(largeBadge);
    self.badgeView.backgroundColor = [UIColor clearColor];
    self.badgeView.userInteractionEnabled = NO;
    [self setMessageBadgeValue];

    if (IS_CITY_APP) {
        [self initQRView];
    }

    [self startLocationUsage];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_IDENTITY_QR_RETREIVED
                                                            onQueue:[MCTComponentFramework mainQueue]];
    // dont call [super viewDidLoad]
}

- (void)initQRView
{
    if ([@"dark" isEqualToString:MCT_APP_HOMESCREEN_COLOR_SCHEME]) {
        self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    } else {
        self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    }

    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"homescreen_qr_code" owner:self options:nil];
    UIView *qrView = views[0];

    self.myQrDescriptionLbl = (UILabel *) [qrView viewWithTag:-2];
    self.myQrImageView = (UIImageView *) [qrView viewWithTag:-4];
    self.myQrSpinner = (UIActivityIndicatorView *) [qrView viewWithTag:-5];
    UIButton *tmpBackBtn = (UIButton *) [qrView viewWithTag:-6];

    self.myQrDescriptionLbl.text = [NSString stringWithFormat:NSLocalizedString(@"__loyalty_card_description", nil),
                                    MCT_PRODUCT_NAME];
    self.myQrDescriptionLbl.textColor = [UIColor MCTHomeScreenTextColor];
    self.myQrDescriptionLbl.height = fmin(self.myQrDescriptionLbl.height,
                                          [MCTUIUtils sizeForLabel:self.myQrDescriptionLbl
                                                         withWidth:self.myQrDescriptionLbl.width].height);

    self.myQrBackBtn = [MCTUIUtils replaceUIButtonWithTTButton:tmpBackBtn];
    [self.myQrBackBtn setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    [self.myQrBackBtn addTarget:self action:@selector(onBackPressed:) forControlEvents:UIControlEventTouchUpInside];

    self.myQrBackBtn.width = fmax(80, [MCTUIUtils sizeForTTButton:self.myQrBackBtn
                                                constrainedToSize:CGSizeMake(self.scrollView.width, self.myQrBackBtn.height)].width);
    self.myQrBackBtn.centerX = self.myQrBackBtn.superview.width / 2;

    [MCTUIUtils addRoundedBorderToView:self.myQrImageView
                       withBorderColor:[UIColor lightGrayColor]
                       andCornerRadius:5];
    [self loadQR];

    [self.scrollView addSubview:qrView];
}

- (void)loadQR
{
    T_UI();
    NSData *qr = [[[MCTComponentFramework systemPlugin] identityStore] qrCode];
    if (qr == nil) {
        [self.myQrSpinner startAnimating];
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            [[MCTComponentFramework systemPlugin] requestIdentityQRCode];
        }];
    } else {
        [self.myQrSpinner stopAnimating];
        self.myQrImageView.image = [UIImage imageWithData:qr];
    }
}

- (void)onBackPressed:(UIControl *)sender
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}


- (IBAction)onIconTapped:(UIControl *)sender
{
    T_UI();
    UIViewController *vc = nil;
    NSString *key = [NSString stringWithFormat:@"%ld", (long)sender.tag];
    if ([self.clickHandlers containsKey:key]) {
        MCTHomeScreenItem *hsi = [self.clickHandlers valueForKey:key];
        if (hsi.click == nil) {
            MCTFriend *service = [[[MCTComponentFramework friendsPlugin] store] friendByEmail:MCT_APP_EMAIL];
            if (service) {
                [[[MCTComponentFramework friendsPlugin] store] addMenuDetailsToService:service];

                MCTServiceMenuItem *smi = nil;
                for (MCTServiceMenuItem *i in service.actionMenu.items) {
                    if (i.x == [hsi.coords[0] integerValue] && i.y == [hsi.coords[1] integerValue] && i.z == [hsi.coords[2] integerValue]) {
                        smi = i;
                        break;
                    }
                }
                if (smi != nil) {
                    if (smi.requiresWifi && ![MCTUtils connectedToWifi]) {
                        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                                       andText:NSLocalizedString(@"This action requires connection to a Wi-Fi network. Please check your network configuration and try again.", nil)];
                        self.currentAlertView.delegate = self;
                        return;
                    }

                    MCT_RELEASE(self.context);

                    MCT_com_mobicage_to_service_PressMenuIconRequestTO *request = [MCT_com_mobicage_to_service_PressMenuIconRequestTO transferObject];
                    request.context = [NSString stringWithFormat:@"MENU_%@", [MCTUtils guid]];
                    request.service = service.email;
                    request.coords = smi.coords;
                    request.hashed_tag = smi.hashedTag;
                    request.generation = service.generation;
                    request.timestamp = [MCTUtils currentServerTime];

                    if ([MCTUtils isEmptyOrWhitespaceString:smi.staticFlowHash]) {
                        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                            T_BIZZ();
                            [[MCTComponentFramework friendsPlugin] pressMenuItemWithRequest:request];
                        }];
                    }

                    if ([MCTUtils isEmptyOrWhitespaceString:smi.screenBranding]) {
                        self.context = request.context;

                        if ([MCTUtils isEmptyOrWhitespaceString:smi.staticFlowHash]) {
                            if ([MCTUtils connectedToInternetAndXMPP]) {
                                self.currentActionSheet = [MCTUIUtils showProgressActionSheetWithTitle:NSLocalizedString(@"Processing ...", nil)
                                                                                      inViewController:self];
                                self.itemPressStartTime = [MCTUtils currentTimeMillis];
                                [self performSelector:@selector(setProgress) withObject:nil afterDelay:0.08];
                            } else {
                                self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                                               andText:NSLocalizedString(@"Action will start when you have network connectivity.", nil)];
                            }

                        } else {
                            MCTMessageFlowRun *mfr = [MCTMessageFlowRun messageFlowRun];
                            mfr.staticFlowHash = smi.staticFlowHash;
                            request.static_flow_hash = smi.staticFlowHash;

                            NSDictionary *userInput = [NSDictionary dictionaryWithObjectsAndKeys:[request dictRepresentation], @"request",
                                                       @"com.mobicage.api.services.pressMenuItem", @"func", nil];

                            @try {
                                [[MCTComponentFramework menuViewController] executeMFR:mfr withUserInput:userInput throwIfNotReady:YES];
                            } @catch (MCTBizzException *e) {
                                self.currentAlertView = [MCTUIUtils showAlertWithTitle:e.name andText:e.reason];
                                self.currentAlertView.delegate = self;
                                //self.currentAlertView.tag = MCT_TAG_ERROR;
                                [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                                    [[MCTComponentFramework friendsPlugin] requestStaticFlowWithItem:smi andService:service.email];
                                }];
                            }


                        }
                    } else {
                        if ([[MCTComponentFramework brandingMgr] isBrandingAvailable:smi.screenBranding]) {
                            MCTServiceScreenBrandingVC *vc = [MCTServiceScreenBrandingVC viewControllerWithService:service
                                                                                                              item:smi];
                            vc.title = smi.label;
                            [self.navigationController pushViewController:vc animated:YES];
                        } else {
                            MCTFriend *bService = service;
                            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                                [[MCTComponentFramework brandingMgr] queueFriend:bService];
                            }];
                            self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                                           andText:NSLocalizedString(@"This screen is not yet downloaded. Check your network.", nil)];
                        }
                    }
                } else {
                    LOG(@"SMI NOT FOUND");
                }
            } else {
                LOG(@"NOT READY YET");
            }

        } else if ([hsi.click isEqualToString:@"messages"]) {
            vc = [[MCTTabMessagesVC alloc] init];
        } else if ([hsi.click isEqualToString:@"scan"]) {
            vc = [[MCTScannerVC alloc] init];
        } else if ([hsi.click isEqualToString:@"services"]) {
            vc = [self servicesViewControllerWithOrganizationType:MCTServiceOrganizationTypeUnspecified
                                                         collapse:hsi.collapse];
        } else if ([hsi.click isEqualToString:@"friends"]) {
            vc = [[MCTFriendsTabVC alloc] init];
        } else if ([hsi.click isEqualToString:@"directory"]) {
            vc = [MCTFriendSearchVC viewController];
        } else if ([hsi.click isEqualToString:@"profile"]) {
            vc = [MCTProfileVC viewController];
        } else if ([hsi.click isEqualToString:@"more"]) {
            vc = [[MCTMoreVC alloc] init];
        } else if ([hsi.click isEqualToString:@"community_services"]) {
            vc = [self servicesViewControllerWithOrganizationType:MCTServiceOrganizationTypeCity
                                                         collapse:hsi.collapse];
        } else if ([hsi.click isEqualToString:@"merchants"]) {
            vc = [self servicesViewControllerWithOrganizationType:MCTServiceOrganizationTypeProfit
                                                         collapse:hsi.collapse];
        } else if ([hsi.click isEqualToString:@"associations"]) {
            vc = [self servicesViewControllerWithOrganizationType:MCTServiceOrganizationTypeNonProfit
                                                         collapse:hsi.collapse];
        } else if ([hsi.click isEqualToString:@"emergency_services"]) {
            vc = [self servicesViewControllerWithOrganizationType:MCTServiceOrganizationTypeEmergency
                                                         collapse:hsi.collapse];
        } else {
            ERROR(@"unknown onIconTapped action: %@", hsi.click);
        }
    }

    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UIViewController *)servicesViewControllerWithOrganizationType:(MCTServiceOrganizationType)organizationType
                                                        collapse:(BOOL)collapse
{
    if (collapse) {
        int serviceCount = 0;
        if (organizationType == MCTServiceOrganizationTypeUnspecified) {
            for (NSNumber *count in [self.serviceCountByOrganizationType allValues]) {
                serviceCount += [count intValue];
            }
        } else {
            NSNumber *serviceCountNumber = self.serviceCountByOrganizationType[@(organizationType)];
            if (serviceCountNumber != nil) {
                serviceCount = [serviceCountNumber intValue];
            }
        }

        if (serviceCount == 1) {
            MCTFriend *service = [[[MCTComponentFramework friendsPlugin] store] serviceByOrganizationType:organizationType
                                                                                    andIndex:0];
            return [MCTServiceMenuVC viewControllerWithService:service];
        }
    }

    MCTServicesTabVC *svc = [MCTServicesTabVC viewController];
    svc.organizationType = organizationType;
    return svc;
}

- (void)registerIntents
{
    [super registerIntents];
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:@[kINTENT_MESSAGE_RECEIVED_HIGH_PRIO,
                                                                      kINTENT_FRIEND_ADDED,
                                                                      kINTENT_FRIEND_REMOVED,
                                                                      kINTENT_FRIENDS_RETRIEVED]
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)switchToTab:(NSInteger)tabIndex popToRootViewController:(BOOL)popToRoot animated:(BOOL)animated
{
    T_UI();
    HERE();
    UIViewController *vc;
    switch (tabIndex) {
        case MCT_MENU_TAB_FRIENDS: {
            vc = [[MCTFriendsTabVC alloc] init];
            break;
        }
        case MCT_MENU_TAB_MESSAGES: {
            vc = [[MCTTabMessagesVC alloc] init];
            break;
        }
        case MCT_MENU_TAB_MORE: {
            vc = [[MCTMoreVC alloc] init];
            break;
        }
        case MCT_MENU_TAB_SCAN: {
            vc = [[MCTScannerVC alloc] init];
            break;
        }
        case MCT_MENU_TAB_SERVICES: {
            vc = [[MCTServicesTabVC alloc] init];
            break;
        }
        default: {
            ERROR(@"switchToTab:popToRootViewController:animated: - Unknown tab: %d", tabIndex);
            vc = nil;
            break;
        }
    }

    if (vc) {
        if (popToRoot) {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        [self.navigationController pushViewController:vc animated:animated];
    }
}

- (void)setMessageBadgeValue
{
    T_UI();
    HERE();
    self.updatedMessageCount = [[[MCTComponentFramework messagesPlugin] store] countDirtyThreads];

    NSInteger number = self.updatedMessageCount;

    [UIApplication sharedApplication].applicationIconBadgeNumber = number ? 1 : 0;

    if (number) {
        self.badgeView.hidden = NO;
        self.badgeView.text = [NSString stringWithFormat:@"%ld", (long)number];
        CGPoint center = self.badgeView.center;
        [self.badgeView sizeToFit];
        self.badgeView.center = center;
    } else {
        self.badgeView.hidden = YES;
        self.badgeView.text = @"";
    }

    LOG(@"Updated badge to '%@'", self.badgeView.text);
}

- (void)loadMessageWithKey:(NSString *)key
{
    T_UI();
    MCT_RELEASE(self.currentActionSheet);

    MCTMessageDetailVC *vc = [MCTMessageDetailVC viewControllerWithMessageKey:key];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loadServiceCount
{
    self.serviceCountByOrganizationType = [[[MCTComponentFramework friendsPlugin] store] countServicesGroupedByOrganizationType];
    self.lastTimeServiceCountLoaded = [MCTUtils currentTimeMillis];
}

#pragma mark -

- (void)setProgress
{
    T_UI();
    UIProgressView *progressView = (UIProgressView *) [self.currentActionSheet viewWithTag:1];
    float progress = [MCTUtils currentTimeMillis] - self.itemPressStartTime;
    if (self.itemPressStartTime && progress < 10000) {
        progressView.progress = progress / 10000.0f;

        [self performSelector:@selector(setProgress) withObject:nil afterDelay:0.08];
    } else {
        progressView.progress = 1;
        MCT_RELEASE(self.currentActionSheet);
        MCT_RELEASE(self.context);
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:NSLocalizedString(@"Action scheduled successfully", nil)];
    }
}

- (void)showViewController:(UIViewController *)vc
{
    T_UI();
    [self.navigationController pushViewController:vc animated:NO];
}

# pragma mark - MCTIntent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_PUSH_NOTIFICATION) {
        [[MCTComponentFramework intentFramework] removeStickyIntent:intent];
        [MCTTabMessagesVC gotoMessageDetail:[intent stringForKey:@"messageKey"]
                     inNavigationController:self.navigationController];
        return;
    }

    [super onIntent:intent];

    if (intent.action == kINTENT_MESSAGE_RECEIVED_HIGH_PRIO && self.context && [self.context isEqualToString:[intent stringForKey:@"context"]]) {
        MCT_RELEASE(self.context);
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setProgress) object:nil];
        ((UIProgressView *)[self.currentActionSheet viewWithTag:1]).progress = 1;
        [self loadMessageWithKey:[intent stringForKey:@"message_key"]];
    }
    else if (intent.action == kINTENT_FRIEND_REMOVED || intent.action == kINTENT_FRIEND_ADDED || intent.action == kINTENT_FRIENDS_RETRIEVED) {
        if (intent.creationTimestamp > self.lastTimeServiceCountLoaded) {
            [self loadServiceCount];
        }
    }
    else if (intent.action == kINTENT_IDENTITY_QR_RETREIVED) {
        [self loadQR];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // Making sure the scrollView is not stuck in negative offsetY
    if (scrollView.contentOffset.y < 0) {
        [scrollView setContentOffset:CGPointZero animated:YES];
    }
}

@end