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

#import "MCTBrandingMgr.h"
#import "MCTComponentFramework.h"
#import "MCTIntent.h"
#import "MCTServiceDetailVC.h"
#import "MCTServiceMenuVC.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"


#define MCT_ASKED_DELETE 0


@interface MCTServiceDetailVC ()

- (void)reloadServiceDetailsWithForce:(BOOL)useForce;

@end


@implementation MCTServiceDetailVC


+ (MCTServiceDetailVC *)viewControllerWithService:(MCTFriend *)service
{
    MCTServiceDetailVC *vc = [[MCTServiceDetailVC alloc] initWithNibName:@"serviceDetails" bundle:nil];
    vc.service = service;
    vc.hidesBottomBarWhenPushed = YES;
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    
    [MCTUIUtils addRoundedBorderToView:self.avatarImageView];

    self.title = NSLocalizedString(@"About", nil);
    self.friendsPlugin = [MCTComponentFramework friendsPlugin];

    [self reloadServiceDetailsWithForce:NO];

    if (![self isDashboardEmail:self.service.email]) {
        if (self.service.existence == MCTFriendExistenceActive || self.service.existence == MCTFriendExistenceInvitePending) {
            if (!IS_FLAG_SET(self.service.flags, MCTFriendFlagNotRemovable)) {
                self.navigationItem.rightBarButtonItem =
                [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Disconnect", nil)
                                                  style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(onDisconnectButtonClicked:)];
                IF_IOS5_OR_GREATER({
                    self.navigationItem.rightBarButtonItem.tintColor = RGBCOLOR(204, 51, 51);
                });
            }

        } else {
            self.navigationItem.rightBarButtonItem =
                [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Connect", nil)
                                                  style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(onConnectButtonClicked:)];
        }
    }

    NSArray *actions = [NSArray arrayWithObjects:kINTENT_FRIENDS_RETRIEVED, kINTENT_FRIEND_MODIFIED,
                        kINTENT_SERVICE_BRANDING_RETRIEVED, kINTENT_FRIEND_REMOVED, nil];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:actions
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.firstShowAlertText) {
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:self.firstShowAlertText];
        // no delegate
        self.firstShowAlertText = nil;
    }

    // Set navigationBar colors according to brandingResult
    [self changeNavigationControllerAppearanceWithColorScheme:[self colorSchemeForBrandingResult:self.brandingResult]
                                           andBackGroundColor:[self backGroundColorForBrandingResult:self.brandingResult]];
    if ([self colorSchemeForBrandingResult:self.brandingResult] == MCTColorSchemeDark) {
        self.navigationItem.rightBarButtonItem.tintColor = nil;
    }
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

        if (self.service.branded)
            [[MCTComponentFramework brandingMgr] cleanupBrandingWithBrandingKey:self.service.descriptionBranding];
    }
    [super viewDidDisappear:animated];
}

- (NSString *)getOwnedServiceEmail
{
    T_UI();
    return self.service.email;
}

- (BOOL)isDashboardEmail:(NSString *)email
{
    T_UI();
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", MCT_REGEX_DASHBOARD];
    BOOL matches = [regex evaluateWithObject:email];
    return matches;
}

- (void)reloadServiceDetailsWithForce:(BOOL)useForce
{
    T_UI();
    if (useForce)
        self.service = [self.friendsPlugin.store friendByEmail:self.service.email];

    if (self.service == nil)
        return; // Do nothing. MCTServiceMenuVC will pop to root viewController

    self.avatarImageView.image = [self.service avatarImage];
    self.nameLabel.text = [self.service displayName];
    self.emailLabel.text = [self.service displayEmail];

    if (self.webView) {
        [self.webView removeFromSuperview];
        MCT_RELEASE(self.webView);
    }
    self.brandingResult = nil;

    if ([self.service branded]) {
        if (self.textView) {
            [self.textView removeFromSuperview];
            MCT_RELEASE(self.textView);
        }

        if ([[MCTComponentFramework brandingMgr] isBrandingAvailable:self.service.descriptionBranding]) {
            self.brandingResult = [[MCTComponentFramework brandingMgr] prepareBrandingWithFriend:self.service];

            CGFloat w = [[UIScreen mainScreen] applicationFrame].size.width;
            CGFloat h = [MCTBrandingMgr calculateHeightWithBrandingResult:self.brandingResult andWidth:w];
            if (h > 0) {
                LOG(@"Setting branding height %f", h);
            } else {
                h = 1;
            }

            CGRect f = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), w, h);
            self.webView = [[UIWebView alloc] initWithFrame:f];
            self.webView.bounces = NO;
            self.webView.delegate = self;
            [self.scrollView addSubview:self.webView];

            [self.webView loadBrandingResult:self.brandingResult];
        } else {
            MCTFriend *bService = self.service;
            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                T_BIZZ();
                [[MCTComponentFramework brandingMgr] queueFriend:bService];
            }];
        }
    } else if (![MCTUtils isEmptyOrWhitespaceString:self.service.descriptionX]) {
        if (!self.textView) {
            self.textView = [[UITextView alloc] init];
            self.textView.backgroundColor = [UIColor clearColor];
            self.textView.editable = NO;
            self.textView.font = [UIFont systemFontOfSize:15];
            self.textView.scrollEnabled = NO;
        }

        self.textView.text = self.service.descriptionX;

        CGFloat w = [[UIScreen mainScreen] applicationFrame].size.width;
        CGSize s = [MCTUIUtils sizeForTextView:self.textView withWidth:w];
        CGRect f = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), w, s.height);
        self.textView.frame = f;

        [self.scrollView addSubview:self.textView];

        self.scrollView.contentSize = CGSizeMake(w, CGRectGetMaxY(f));
    } else {
        if (self.textView) {
            [self.textView removeFromSuperview];
            MCT_RELEASE(self.textView);
        }
    }

    MCTColorScheme scheme = [self colorSchemeForBrandingResult:self.brandingResult];
    UIColor *backgroundColor = [self backGroundColorForBrandingResult:self.brandingResult];
    self.view.backgroundColor = backgroundColor;

    if (self.navigationController.visibleViewController == self) {
        [self changeNavigationControllerAppearanceWithColorScheme:scheme andBackGroundColor:backgroundColor];
        if ([self colorSchemeForBrandingResult:self.brandingResult] == MCTColorSchemeDark) {
            self.navigationItem.rightBarButtonItem.tintColor = nil;
        }
    }

    UIColor *textColor = (scheme == MCTColorSchemeLight) ? [UIColor blackColor] : [UIColor whiteColor];
    self.emailLabel.textColor = self.nameLabel.textColor = self.textView.textColor = textColor;
    self.scrollView.indicatorStyle = (scheme == MCTColorSchemeLight) ? UIScrollViewIndicatorStyleBlack : UIScrollViewIndicatorStyleWhite;
}

- (void)onDisconnectButtonClicked:(id)sender
{
    T_UI();
    NSString *msg = NSLocalizedString(@"Are you sure you wish to disconnect %@?", nil);
    self.currentAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:msg, [self.service displayName]]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"No", nil)
                                              otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    self.currentAlertView.tag = MCT_ASKED_DELETE;
    [self.currentAlertView show];
}

- (void)onConnectButtonClicked:(id)sender
{
    T_UI();
    NSString *email = self.service.email;
    NSString *name = self.service.name;
    NSString *description = self.service.descriptionX;
    NSString *descriptionBranding = self.service.descriptionBranding;
    NSData *avatar = self.service.avatar;
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [[MCTComponentFramework friendsPlugin] inviteServiceWithEmail:email
                                                              andName:name
                                                       andDescription:description
                                               andDescriptionBranding:descriptionBranding
                                                        andAvatarData:avatar];
    }];

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    T_UI();
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        LOG(@"Opening URL of request: %@", request);
        [[UIApplication sharedApplication] openURL:[request URL]];
    }
    return navigationType != UIWebViewNavigationTypeLinkClicked;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    T_UI();
    [self performSelector:@selector(resizeWebView) withObject:nil afterDelay:0.1];
}

- (void)resizeWebView
{
    T_UI();
    HERE();
    CGSize s = [self.webView sizeThatFits:CGSizeMake(self.scrollView.frame.size.width, 0)];
    LOG(@"Setting branding height %f", s.height);
    CGRect f = self.webView.frame;
    f.size.height = MAX(s.height, self.scrollView.frame.size.height - f.origin.y);
    self.webView.frame = f;

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(f));
    LOG(@"Reset scrollView.contentSize to %@", NSStringFromCGSize(self.scrollView.contentSize));
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (alertView.tag == MCT_ASKED_DELETE && buttonIndex == 1) {
        // Clicked OK button
        NSString *email = self.service.email;
        [[MCTComponentFramework friendsPlugin] markFriendDeletePendingWithEmail:email];
    }
    MCT_RELEASE(self.currentAlertView);
}

#pragma mark -
#pragma mark MCTIntent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if ((intent.action == kINTENT_FRIEND_MODIFIED && [self.service.email isEqualToString:[intent stringForKey:@"email"]])
         || intent.action == kINTENT_FRIENDS_RETRIEVED) {

        [self reloadServiceDetailsWithForce:YES];
    } else if (intent.action == kINTENT_FRIEND_REMOVED) {
        if ([self.service.email isEqualToString:[intent stringForKey:@"email"]] && [self.navigationController.viewControllers containsObject:self]) {

            NSArray *vcs = self.navigationController.viewControllers;
            UIViewController *keepVC = nil;
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

            // TODO: alert should be owned by parent
            [MCTUIUtils showAlertWithTitle:nil andText:NSLocalizedString(@"Disconnected service", nil)];

        }
    } else if (intent.action == kINTENT_SERVICE_BRANDING_RETRIEVED) {
        [self reloadServiceDetailsWithForce:NO];
    }
}

@end