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
#import "MCTLogForwarding.h"
#import "MCTUIViewController.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"
#import "UIImage+FontAwesome.h"
#import "SWRevealViewController.h"

@implementation MCTUIViewController

- (void)dealloc
{
    T_UI();
    if ([self conformsToProtocol:@protocol(IMCTIntentReceiver)])
        if ([[MCTComponentFramework intentFramework] unregisterIntentListener:(NSObject<IMCTIntentReceiver> *)self])
            LOG(@"IFW - dealloc called but not all intentListeners are unregistered: %@", self);
    if (self.currentAlertController != nil)
        BUG(@"BUG/ERROR !!!!!!! currentAlertController not nil in dealloc: %@", self);
    if (self.currentAlertView != nil)
        BUG(@"BUG/ERROR !!!!!!! currentAlertView not nil in dealloc: %@", self);
    if (self.currentActionSheet != nil)
        BUG(@"BUG/ERROR !!!!!!! currentActionSheet not nil in dealloc: %@", self);
    if (self.currentProgressHUD != nil)
        BUG(@"BUG/ERROR !!!!!!! currentProgressHUD not nil in dealloc: %@", self);
    if (self.activeObject != nil)
        BUG(@"BUG/ERROR !!!!!!! activeObject not nil in dealloc: %@", self);
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    IF_IOS7_OR_GREATER({
        self.automaticallyAdjustsScrollViewInsets = NO;
    });

    if (MCT_HOME_SCREEN_STYLE == MCT_HOME_SCREEN_STYLE_NEWS) {
        // TODO: add hamburger icon to self.navigationItem.leftBarButtonItem

        SWRevealViewController *revealController = [self revealViewController];
        [revealController panGestureRecognizer];
        [revealController tapGestureRecognizer];

//        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
//        self.navigationItem.leftBarButtonItem = revealButtonItem;
//
//        //Add an image to your project & set that image here.
//        UIBarButtonItem *rightRevealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]style:UIBarButtonItemStyleBordered target:revealController action:@selector(rightRevealToggle:)];
//        self.navigationItem.rightBarButtonItem = rightRevealButtonItem;

        //

        UIImage *barsImg = [UIImage imageWithIcon:@"fa-bars"
                                  backgroundColor:[UIColor clearColor]
                                        iconColor:[UIColor colorWithString:MCT_APP_PRIMARY_COLOR]
                                          andSize:CGSizeMake(30, 30)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:barsImg
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:nil
                                                                                action:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    T_UI();
    LOG(@"top viewWillDisappear %@", self);
    MCT_RELEASE(self.currentActionSheet);
    MCT_RELEASE(self.currentAlertView);
    MCT_RELEASE(self.currentProgressHUD);
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    LOG(@"top viewDidDisappear %@", self);
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    LOG(@"top viewWillAppear %@", self);
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    LOG(@"top viewDidAppear %@", self);
    [super viewDidAppear:animated];
}

- (void)setCurrentActionSheet:(UIActionSheet *)currentActionSheet
{
    T_UI();
    if (currentActionSheet != self.currentActionSheet) {
        if (self.currentActionSheet) {
            if (currentActionSheet)
                ERROR(@"Trying to show 2 actionSheets at the same time");
            self.currentActionSheet.delegate = nil;
            [self.currentActionSheet dismissWithClickedButtonIndex:self.currentAlertView.cancelButtonIndex animated:YES];
        }
        _currentActionSheet = currentActionSheet;
    }
}

- (void)setCurrentAlertView:(UIAlertView *)currentAlertView
{
    T_UI();
    if (currentAlertView != self.currentAlertView) {
        if (self.currentAlertView) {
            if (currentAlertView)
                ERROR(@"Trying to show 2 alertViews at the same time");
            self.currentAlertView.delegate = nil;
            [self.currentAlertView dismissWithClickedButtonIndex:self.currentAlertView.cancelButtonIndex animated:YES];
        }
        _currentAlertView = currentAlertView;
    }
}

- (void)setCurrentProgressHUD:(MBProgressHUD *)currentProgressHUD
{
    T_UI();
    if (currentProgressHUD != self.currentProgressHUD) {
        if (self.currentProgressHUD) {
            if (currentProgressHUD)
                ERROR(@"Trying to show 2 progressHUDs at the same time");
            self.currentProgressHUD.delegate = nil;
            [self.currentProgressHUD hide:YES];
        }
        _currentProgressHUD = currentProgressHUD;
    }
}

- (void)resetNavigationControllerAppearance
{
    T_UI();
    IF_PRE_IOS7({
        return;
    });

    self.navigationController.navigationBar.barTintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.titleTextAttributes = nil;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault // Dark content, for use on light backgrounds
                                                animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)changeNavigationControllerAppearanceWithBrandingResult:(MCTBrandingResult *)br
{
    IF_PRE_IOS7({
        return;
    });

    [self changeNavigationControllerAppearanceWithColorScheme:[self colorSchemeForBrandingResult:br]
                                           andBackGroundColor:[self backGroundColorForBrandingResult:br]];
}

- (void)changeNavigationControllerAppearanceWithColorScheme:(MCTColorScheme)colorScheme
                                         andBackGroundColor:(UIColor *)backGroundColor
{
    T_UI();
    IF_PRE_IOS7({
        return;
    });

    if (self.navigationController.visibleViewController != self) {
        return;
    }

    UIColor *tintColor = nil;
    UIColor *barTintColor = nil;
    NSDictionary *titleAttributes = nil;
    UIStatusBarStyle statusBarStyle = UIStatusBarStyleDefault;

    if (colorScheme != MCTColorSchemeLight) {
        CGFloat hue;
        CGFloat saturation;
        CGFloat brightness;
        CGFloat alpha;
        BOOL success = [backGroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        if (success) {
            barTintColor = [UIColor colorWithHue:hue
                                      saturation:saturation
                                      brightness:brightness * 0.9
                                           alpha:alpha];

            // If darkening the color made it almost completely black, then brighten the tint color
            CGFloat white2;
            CGFloat alpha2;
            BOOL success2 = [barTintColor getWhite:&white2 alpha:&alpha2];
            if (success2 && white2 < 0.2) {
                barTintColor = [UIColor colorWithHue:hue
                                          saturation:saturation
                                          brightness:fmax(brightness * 1.2, 0.12)
                                               alpha:alpha];
            }

            tintColor = [UIColor whiteColor];
            titleAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                          forKey:NSForegroundColorAttributeName];
            statusBarStyle = UIStatusBarStyleLightContent; // Light content, for use on dark backgrounds
        }
    }

    self.navigationController.navigationBar.barTintColor = barTintColor;
    self.navigationController.navigationBar.tintColor = tintColor;
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle
                                                animated:YES];
}

- (MCTColorScheme)colorSchemeForBrandingResult:(MCTBrandingResult *)brandingResultOrNil
{
    T_UI();
    return brandingResultOrNil ? brandingResultOrNil.scheme : MCT_DEFAULT_COLOR_SCHEME;
}

- (UIColor *)backGroundColorForBrandingResult:(MCTBrandingResult *)brandingResultOrNil
{
    T_UI();
    if (![MCTUtils isEmptyOrWhitespaceString:brandingResultOrNil.color]) {
        return [UIColor colorWithString:brandingResultOrNil.color];
    }

    MCTColorScheme scheme = [self colorSchemeForBrandingResult:brandingResultOrNil];
    if (scheme == MCTColorSchemeDark) {
        return [UIColor blackColor];
    } else {
        // Color scheme LIGHT or nil
        return [UIColor whiteColor];
    }
}

- (void)setTitle:(NSString *)title
{
    if (MCTLogForwarder.logForwarder.forwarding) {
        if (self.originalTitle == nil) {
            self.originalTitle = self.title;
        }
        [super setTitle:title];
        self.navigationItem.title = MCT_FORWARDING_LOGS_ON_STRING;
    } else {
        NSString *t = OR(self.originalTitle, title);
        [super setTitle:t];
        self.navigationItem.title = t;
    }
}

- (BOOL)shouldAutorotate
{
    T_UI();
    HERE();
    if (IS_CONTENT_BRANDING_APP) {
        return YES;
    }
    BOOL shouldAutoRotate = !UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)
        && UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation);
    LOG(@"%@, %@", [self class], BOOLSTR(shouldAutoRotate));
    return shouldAutoRotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    T_UI();
    HERE();
    if (IS_CONTENT_BRANDING_APP) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    T_UI();
    HERE();
    if (IS_CONTENT_BRANDING_APP) {
        return UIInterfaceOrientationLandscapeRight;
    }
    return UIInterfaceOrientationPortrait;
}

@end