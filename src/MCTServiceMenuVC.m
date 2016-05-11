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
#import "MCTMenuItemView.h"
#import "MCTMessageDetailVC.h"
#import "MCTServiceDetailVC.h"
#import "MCTServiceMenuItem.h"
#import "MCTServiceMenuVC.h"
#import "MCTServiceOwningVC.h"
#import "MCTServiceScreenBrandingVC.h"
#import "MCTShareServiceVC.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

#import "Three20Style+Additions.h"
#import "UIImage+FontAwesome.h"


#define ROW_HEIGHT 90
#define COL_COUNT 4

#define MCT_ALERT_PHONE_CALL 1

@interface MCTServiceMenuVC ()

@property (nonatomic, strong) MCTBrandingResult *brandingResult;
@property (nonatomic) CGFloat colWidth;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) int maxRow;
@property (nonatomic, copy) NSString *context;
@property (nonatomic, copy) NSString *currentBranding;
@property (nonatomic) BOOL pageControlBeingUsed;
@property (nonatomic) MCTlong itemPressStartTime;
@property (nonatomic, strong) MCTMenuItemView *messagesItem;
@property (nonatomic, strong) NSMutableArray *itemViews;

- (void)loadMenu;
- (void)loadBrandingResult;
- (void)configureItemView:(MCTMenuItemView *)itemView;
- (void)showMenu;
- (void)showMenuBranding;
- (void)onMenuItemPressed:(id)sender;
- (void)queueInBrandingManager;

@end


@implementation MCTServiceMenuVC


+ (MCTServiceMenuVC *)viewControllerWithService:(MCTFriend *)service
{
    T_UI();
    MCTServiceMenuVC *vc = [[MCTServiceMenuVC alloc] initWithNibName:@"serviceMenu" bundle:nil];
    vc.service = service;
    vc.hidesBottomBarWhenPushed = YES;
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    self.service.actionMenu = nil;

    [self loadMenu];
    [self queueInBrandingManager];

    self.pageControl.currentPage = 0;
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.contentMode = UIViewContentModeRedraw;
    self.pageControlBeingUsed = NO;

    CGSize scrollSize = [MCTUIUtils availableSizeForViewWithController:self];

    self.uberScrollView.contentSize = scrollSize;
    self.scrollView.contentSize = CGSizeMake(self.service.actionMenuPageCount * scrollSize.width, scrollSize.height);

    self.rowHeight = ROW_HEIGHT;
    self.colWidth = scrollSize.width / COL_COUNT;

    [self showMenu];

    // IntentListener
    NSArray *actions = [NSArray arrayWithObjects:kINTENT_FRIEND_MODIFIED, kINTENT_FRIEND_REMOVED,
                        kINTENT_FRIENDS_RETRIEVED, kINTENT_MESSAGE_RECEIVED_HIGH_PRIO, kINTENT_MESSAGE_MODIFIED,
                        kINTENT_THREAD_ACKED, kINTENT_THREAD_DELETED, kINTENT_THREAD_RESTORED, nil];
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:actions
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    T_UI();
    [super viewWillDisappear:animated];
    // Set navigationBar colors back to normal
    [self resetNavigationControllerAppearance];
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self];

        // Cleanup branding directories
        if (![MCTUtils isEmptyOrWhitespaceString:self.service.actionMenu.branding])
            [[MCTComponentFramework brandingMgr] cleanupBrandingWithBrandingKey:self.service.actionMenu.branding];

        for (MCT_com_mobicage_to_friends_ServiceMenuItemTO *item in self.service.actionMenu.items)
            if (![MCTUtils isEmptyOrWhitespaceString:item.screenBranding])
                [[MCTComponentFramework brandingMgr] cleanupBrandingWithBrandingKey:item.screenBranding];
    }
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    T_UI();
    // Set navigationBar colors according to brandingResult
    [self changeNavigationControllerAppearanceWithColorScheme:[self colorSchemeForBrandingResult:self.brandingResult]
                                           andBackGroundColor:[self backGroundColorForBrandingResult:self.brandingResult]];
    [super viewWillAppear:animated];
}

- (void)loadMenu
{
    T_UI();
    self.itemViews = [NSMutableArray array];
    if (!self.service.actionMenu)
        [[[MCTComponentFramework friendsPlugin] store] addMenuDetailsToService:self.service];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[[self.service displayName] stringByTruncatingTailWithLength:17]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil];

    self.pageControl.numberOfPages = self.service.actionMenuPageCount;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.service.actionMenuPageCount,
                                             self.scrollView.contentSize.height);

    [self loadBrandingResult];
}

- (NSString *)getOwnedServiceEmail
{
    T_UI();
    return self.service.email;
}

- (void)queueInBrandingManager
{
    MCTFriend *bService = self.service;
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        [[MCTComponentFramework brandingMgr] queueFriend:bService];
    }];
}

- (void)loadBrandingResult
{
    T_UI();
    MCT_RELEASE(self.brandingResult);
    if (![MCTUtils isEmptyOrWhitespaceString:self.service.actionMenu.branding]) {
        if ([[MCTComponentFramework brandingMgr] isBrandingAvailable:self.service.actionMenu.branding]) {
            self.brandingResult = [[MCTComponentFramework brandingMgr] prepareBrandingWithKey:self.service.actionMenu.branding
                                                                                    forFriend:self.service];
        } else {
            [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                            forIntentAction:kINTENT_SERVICE_BRANDING_RETRIEVED
                                                                    onQueue:[MCTComponentFramework mainQueue]];
            [self queueInBrandingManager];
        }
    }

    if (!self.brandingResult || ![self.service.actionMenu.branding isEqualToString:self.currentBranding]) {
        MCT_RELEASE(self.currentBranding);
        for (UIView *subview in self.uberScrollView.subviews) {
            if ([subview isKindOfClass:[UIWebView class]]) {
                LOG(@"Removing current branding webview");
                [subview removeFromSuperview];
                if ([MCTUtils isEmptyOrWhitespaceString:self.service.actionMenu.branding]) {
                    self.uberScrollView.contentSize = self.uberScrollView.frame.size;
                    self.uberScrollView.contentOffset = CGPointZero;
                    self.scrollView.frame = CGRectMake(0, 0, self.uberScrollView.frame.size.width, self.uberScrollView.frame.size.height);
                }
                break;
            }
        }
    }

    UIColor *backGroundColor = [self backGroundColorForBrandingResult:self.brandingResult];
    MCTColorScheme scheme = [self colorSchemeForBrandingResult:self.brandingResult];
    if (scheme == MCTColorSchemeLight) {
        self.uberScrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        self.pageControl.dotStyle = @"pageControlWithLightColorScheme:";
    } else {
        self.uberScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        self.pageControl.dotStyle = @"pageControlWithDarkColorScheme:";
    }

    self.view.backgroundColor = backGroundColor;
    [self changeNavigationControllerAppearanceWithColorScheme:scheme andBackGroundColor:backGroundColor];

    for (MCTMenuItemView *itemView in self.itemViews) {
        [itemView setColorScheme:scheme];
    }

    self.title = self.brandingResult ? nil : [self.service displayName];

    // watermarkImageView is created in brandingShownWithWebView:
    if (!self.brandingResult.watermarkFilePath) {
        [self.watermarkImageView removeFromSuperview];
        MCT_RELEASE(self.watermarkImageView);
    }
}

- (void)configureItemView:(MCTMenuItemView *)itemView
{
    T_UI();
    int x = itemView.item.x;
    int y = itemView.item.y;
    int z = itemView.item.z;

    if (x >= COL_COUNT) {
        ERROR(@"Item (%d, %d, %d) is not visible because it's coordinates exceed the grid", x, y, z);
        return;
    }

    CGRect f = itemView.frame;
    f.origin.y = y * self.rowHeight + 5;

    f.origin.x = z * [[UIScreen mainScreen] applicationFrame].size.width + x * self.colWidth + (self.colWidth - f.size.width) / 2;
    itemView.frame = f;
    [itemView addTarget:self action:@selector(onMenuItemPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self.scrollView addSubview:itemView];
    [self.itemViews addObject:itemView];

    self.maxRow = MAX(self.maxRow, y);
}

- (void)showMenu
{
    T_UI();
    self.maxRow = 0;

    MCTColorScheme colorScheme = self.brandingResult ? self.brandingResult.scheme : MCT_DEFAULT_COLOR_SCHEME;
    UIColor *menuItemColor = [UIColor colorWithString:OR(self.brandingResult.menuItemColor, @"646464")];


    NSString *infoLabel = [MCTUtils isEmptyOrWhitespaceString:self.service.actionMenu.aboutLabel]
                           ? NSLocalizedString(@"About", nil) : self.service.actionMenu.aboutLabel;
    MCTServiceMenuItem *infoItem = [MCTServiceMenuItem menuItemWithLabel:infoLabel x:0 y:0 z:0];
    MCTMenuItemView *info = [[MCTMenuItemView alloc] initWithFrame:CGRectZero
                                                           menuItem:infoItem
                                                              image:[UIImage imageWithIcon:@"fa-info"
                                                                           backgroundColor:[UIColor clearColor]
                                                                                 iconColor:menuItemColor
                                                                                   andSize:CGSizeMake(76, 76)]
                                                        colorScheme:colorScheme
                                                        badgeString:nil];
    [self configureItemView:info];

    NSString *msgsLabel = [MCTUtils isEmptyOrWhitespaceString:self.service.actionMenu.messagesLabel]
                           ? NSLocalizedString(@"History", nil) : self.service.actionMenu.messagesLabel;
    MCTServiceMenuItem *msgsItem = [MCTServiceMenuItem menuItemWithLabel:msgsLabel x:1 y:0 z:0];

    self.messagesItem = [[MCTMenuItemView alloc] initWithFrame:CGRectZero
                                                       menuItem:msgsItem
                                                          image:[UIImage imageWithIcon:@"fa-envelope"
                                                                       backgroundColor:[UIColor clearColor]
                                                                             iconColor:menuItemColor
                                                                               andSize:CGSizeMake(76, 76)]
                                                    colorScheme:colorScheme
                                                    badgeString:nil];
    [self updateMessagesBadge];
    [self configureItemView:self.messagesItem];

    if (self.service.actionMenu.phoneNumber) {
        NSString *callLabel = [MCTUtils isEmptyOrWhitespaceString:self.service.actionMenu.callLabel]
                               ? NSLocalizedString(@"Call", nil) : self.service.actionMenu.callLabel;
        MCTServiceMenuItem *callItem = [MCTServiceMenuItem menuItemWithLabel:callLabel x:2 y:0 z:0];
        MCTMenuItemView *call = [[MCTMenuItemView alloc] initWithFrame:CGRectZero
                                                               menuItem:callItem
                                                                  image:[UIImage imageWithIcon:@"fa-phone"
                                                                               backgroundColor:[UIColor clearColor]
                                                                                     iconColor:menuItemColor
                                                                                       andSize:CGSizeMake(76, 76)]
                                                            colorScheme:colorScheme
                                                            badgeString:nil];
        [self configureItemView:call];
    }

    if (self.service.actionMenu.share) {
        NSString *shareLabel = [MCTUtils isEmptyOrWhitespaceString:self.service.actionMenu.shareLabel]
                                ? NSLocalizedString(@"Recommend", nil) : self.service.actionMenu.shareLabel;
        MCTServiceMenuItem *shareItem = [MCTServiceMenuItem menuItemWithLabel:shareLabel x:3 y:0 z:0];
        MCTMenuItemView *share = [[MCTMenuItemView alloc] initWithFrame:CGRectZero
                                                                menuItem:shareItem
                                                                   image:[UIImage imageWithIcon:@"fa-thumbs-o-up"
                                                                                backgroundColor:[UIColor clearColor]
                                                                                      iconColor:menuItemColor
                                                                                        andSize:CGSizeMake(76, 76)]
                                                             colorScheme:colorScheme
                                                             badgeString:nil];
        [self configureItemView:share];
    }

    for (MCTServiceMenuItem *item in self.service.actionMenu.items) {
        MCTMenuItemView *itemView = [[MCTMenuItemView alloc] initWithFrame:CGRectZero
                                                                   menuItem:item
                                                                colorScheme:colorScheme
                                                                badgeString:nil];
        [self configureItemView:itemView];
    }

    if (self.brandingResult)
        [self showMenuBranding];

    self.pageControl.hidden = (self.pageControl.numberOfPages == 1);

    CGRect f = self.uberScrollView.frame;
    self.uberScrollView.contentSize = f.size;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, f.size.height);
}

- (void)updateMessagesBadge
{
    T_UI();
    int unprocessedMessages = [[[MCTComponentFramework messagesPlugin] store] countUnprocessedMessagesForSender:self.service.email];
    if (unprocessedMessages > 0)
        [self.messagesItem updateBadgeWithString:[NSString stringWithFormat:@"%d", unprocessedMessages]];
    else {
        [self.messagesItem updateBadgeWithString:nil];
    }
}

- (void)showMenuBranding
{
    T_UI();
    if (self.brandingResult == nil)
        return;

    if (self.currentBranding && [self.currentBranding isEqualToString:self.service.actionMenu.branding]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self brandingShownWithWebView:self.webView];
        });
        return; // branding is already shown
    }

    self.currentBranding = self.service.actionMenu.branding;

    if (self.webView) {
        [self.webView removeFromSuperview];
        MCT_RELEASE(self.webView);
    }

    CGFloat w = [UIScreen mainScreen].applicationFrame.size.width;
    CGFloat h = [MCTBrandingMgr calculateHeightWithBrandingResult:self.brandingResult andWidth:w];
    if (h > 0) {
        LOG(@"Setting branding height %f", h);
    } else {
        h = 1;
    }

    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    self.webView.bounces = NO;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.delegate = self;
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    [self.webView loadBrandingResult:self.brandingResult];
    [self.uberScrollView addSubview:self.webView];

    // reposition items
    [self brandingShownWithWebView:self.webView];
}

- (IBAction)onPageChanged:(id)sender
{
    T_UI();
    // Keep track of when scrolls happen in response to the page control value changing. If we don't do this, a
    // noticeable "flashing" occurs as the the scroll delegate will temporarily switch back the page number.
    self.pageControlBeingUsed = YES;

    // Update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

- (void)onMenuItemPressed:(id)sender
{
    T_UI();
    MCTServiceMenuItem *item = ((MCTMenuItemView *)sender).item;
    if (item.z == 0 && item.y == 0) {
        // Special menu item
        switch (item.x) {
            case 0: // About
            {
                MCTServiceDetailVC *vc = [MCTServiceDetailVC viewControllerWithService:self.service];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 1: // Messages
            {
                MCTDefaultMessageListVC *vc = [MCTDefaultMessageListVC viewController];
                vc.filter = [MCTMessageFilter filterWithType:MCTMessageFilterByService andArgument:self.service.email];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 2: // Call
            {
                if ([MCTUtils isEmptyOrWhitespaceString:self.service.actionMenu.callConfirmation]) {
                    self.currentAlertView = [MCTUIUtils showAlertViewForPhoneNumber:self.service.actionMenu.phoneNumber
                                                                       withDelegate:self
                                                                             andTag:MCT_ALERT_PHONE_CALL];
                } else {
                    self.currentAlertView = [MCTUIUtils showAlertViewForPhoneNumber:self.service.actionMenu.phoneNumber
                                                                       withDelegate:self
                                                                         andMessage:self.service.actionMenu.callConfirmation
                                                                             andTag:MCT_ALERT_PHONE_CALL];
                }
                break;
            }
            case 3: // Share
            {
                MCTShareServiceVC *vc = [MCTShareServiceVC viewControllerWithService:self.service];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    } else {
        // Other menu item
        if (item.requiresWifi && ![MCTUtils connectedToWifi]) {
            self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                           andText:NSLocalizedString(@"This action requires connection to a Wi-Fi network. Please check your network configuration and try again.", nil)];
            self.currentAlertView.delegate = self;
            return;
        }

        MCT_RELEASE(self.context);

        MCT_com_mobicage_to_service_PressMenuIconRequestTO *request = [MCT_com_mobicage_to_service_PressMenuIconRequestTO transferObject];
        request.context = [NSString stringWithFormat:@"MENU_%@", [MCTUtils guid]];
        request.service = self.service.email;
        request.coords = item.coords;
        request.hashed_tag = item.hashedTag;
        request.generation = self.service.generation;
        request.timestamp = [MCTUtils currentServerTime];

        if ([MCTUtils isEmptyOrWhitespaceString:item.staticFlowHash]) {
            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                T_BIZZ();
                [[MCTComponentFramework friendsPlugin] pressMenuItemWithRequest:request];
            }];
        }

        if ([MCTUtils isEmptyOrWhitespaceString:item.screenBranding]) {
            self.context = request.context;

            if ([MCTUtils isEmptyOrWhitespaceString:item.staticFlowHash]) {
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
                mfr.staticFlowHash = item.staticFlowHash;
                request.static_flow_hash = item.staticFlowHash;

                NSDictionary *userInput = [NSDictionary dictionaryWithObjectsAndKeys:[request dictRepresentation], @"request",
                                           @"com.mobicage.api.services.pressMenuItem", @"func", nil];

                @try {
                    [[MCTComponentFramework menuViewController] executeMFR:mfr withUserInput:userInput throwIfNotReady:YES];
                } @catch (MCTBizzException *e) {
                    self.currentAlertView = [MCTUIUtils showAlertWithTitle:e.name andText:e.reason];
                    self.currentAlertView.delegate = self;
                    //self.currentAlertView.tag = MCT_TAG_ERROR;
                    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                        [[MCTComponentFramework friendsPlugin] requestStaticFlowWithItem:item andService:self.service.email];
                    }];
                }


            }
        } else {
            if ([[MCTComponentFramework brandingMgr] isBrandingAvailable:item.screenBranding]) {
                MCTServiceScreenBrandingVC *vc = [MCTServiceScreenBrandingVC viewControllerWithService:self.service
                                                                                                  item:item];
                vc.title = item.label;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                MCTFriend *bService = self.service;
                [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                    [[MCTComponentFramework brandingMgr] queueFriend:bService];
                }];
                self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                               andText:NSLocalizedString(@"This screen is not yet downloaded. Check your network.", nil)];
            }
        }
    }
}

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

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    T_UI();
    if (self.pageControlBeingUsed)
        return;

    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    T_UI();
    self.pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    T_UI();
    self.pageControlBeingUsed = NO;
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    T_UI();
    return navigationType != UIWebViewNavigationTypeLinkClicked;
}

- (void)brandingShownWithWebView:(UIWebView *)webView
{
    T_UI();
    CGRect wFrame = webView.frame;
    CGFloat w = webView.frame.size.width;
    CGFloat h = [webView sizeThatFits:CGSizeMake(w, 0)].height;
    LOG(@"Setting branding height %f", h);
    wFrame.size.height = h;
    webView.frame = wFrame;

    CGRect sFrame = self.scrollView.frame;
    sFrame.origin.y = wFrame.size.height;
    sFrame.size.height = MAX((self.maxRow + 1) * self.rowHeight, self.uberScrollView.height - wFrame.size.height);
    self.scrollView.frame = sFrame;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, sFrame.size.height);

    CGFloat pageControlHeight = self.pageControl.hidden ? 0 : self.pageControl.height;
    self.uberScrollView.contentSize = CGSizeMake(self.uberScrollView.width,
                                                 CGRectGetMaxY(sFrame) + pageControlHeight);

    if (self.webViewDidFinishLoad && self.brandingResult.watermarkFilePath) {
        if (self.watermarkImageView) {
            [self.watermarkImageView removeFromSuperview];
            MCT_RELEASE(self.watermarkImageView);
        }
        UIImage *img = [UIImage imageWithContentsOfFile:self.brandingResult.watermarkFilePath];

        self.watermarkImageView = [[UIImageView alloc] initWithImage:img];
        self.watermarkImageView.contentMode = UIViewContentModeBottomRight;
        CGFloat y = self.view.top + self.webView.bottom;
        self.watermarkImageView.frame = CGRectMake(0, y, self.view.width, self.view.height - y);
        [self.view insertSubview:self.watermarkImageView atIndex:0];
    }
    self.webViewDidFinishLoad = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    T_UI();
    // Reposition items on page. Delayed because sizeThatFits gives unpredictable results at this point
    self.webViewDidFinishLoad = YES;
    [self performSelector:@selector(brandingShownWithWebView:) withObject:webView afterDelay:0.1];
}

#pragma mark
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (alertView.tag == MCT_ALERT_PHONE_CALL) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",
                                               [self.service.actionMenu.phoneNumber stringByReplacingOccurrencesOfString:@" "
                                                                                                              withString:@""]]];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    MCT_RELEASE(self.currentAlertView);
}

#pragma mark -
#pragma mark MCTIntent

- (void)loadMessageWithKey:(NSString *)key
{
    T_UI();
    MCT_RELEASE(self.currentActionSheet);

    MCTMessageDetailVC *vc = [MCTMessageDetailVC viewControllerWithMessageKey:key];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();

    if (intent.action == kINTENT_MESSAGE_RECEIVED_HIGH_PRIO && self.context && [self.context isEqualToString:[intent stringForKey:@"context"]]) {
        MCT_RELEASE(self.context);
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setProgress) object:nil];
        ((UIProgressView *)[self.currentActionSheet viewWithTag:1]).progress = 1;
        [self loadMessageWithKey:[intent stringForKey:@"message_key"]];
        [self updateMessagesBadge];
    }
    else if (intent.action == kINTENT_MESSAGE_RECEIVED_HIGH_PRIO || intent.action == kINTENT_MESSAGE_MODIFIED
             || intent.action == kINTENT_THREAD_ACKED || intent.action == kINTENT_THREAD_DELETED
             || intent.action == kINTENT_THREAD_RESTORED) {
        [self updateMessagesBadge];
    }
    else if (intent.action == kINTENT_FRIEND_REMOVED) {
        if ([self.service.email isEqualToString:[intent stringForKey:@"email"]] &&
            [self.navigationController.viewControllers containsObject:self])
        {
            UIViewController *keepVC = nil;
            NSArray *vcs = self.navigationController.viewControllers;
            for (UIViewController *vc in vcs) {
                if ([vc conformsToProtocol:@protocol(MCTServiceOwningVC)]) {
                    id<MCTServiceOwningVC> myVC = (id<MCTServiceOwningVC>) vc;
                    if ([[myVC getOwnedServiceEmail] isEqualToString:self.service.email]) {
                        if (keepVC) {
                            [self.navigationController popToViewController:keepVC animated:YES];
                        }
                        break;
                    }
                }
                keepVC = vc;
            }

            // TODO: own the following alert
            [MCTUIUtils showAlertWithTitle:nil andText:NSLocalizedString(@"Disconnected service", nil)];
        }
    }
    else if (intent.action == kINTENT_SERVICE_BRANDING_RETRIEVED
             && [[intent stringForKey:@"branding_key"] isEqualToString:self.service.actionMenu.branding]) {

        [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                          forIntentAction:kINTENT_SERVICE_BRANDING_RETRIEVED];
        [self loadBrandingResult];
        [self showMenuBranding];
    }
    else if (intent.action == kINTENT_FRIENDS_RETRIEVED ||
             (intent.action == kINTENT_FRIEND_MODIFIED && [self.service.email isEqualToString:[intent stringForKey:@"email"]])) {

        self.service = [[[MCTComponentFramework friendsPlugin] store] friendByEmail:self.service.email];

        if (self.service == nil) {
            self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:NSLocalizedString(@"Disconnected service", nil)];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }

        //Reload view
        for (UIView *subview in self.scrollView.subviews) {
            if ([subview isKindOfClass:[MCTMenuItemView class]]) {
                [subview removeFromSuperview];
            }
        }

        [self loadMenu];
        [self showMenu];
    }
}

@end