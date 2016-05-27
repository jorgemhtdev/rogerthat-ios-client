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

#import "MCTPushNotificationsVC.h"
#import "MCTRegistrationPage0VC.h"
#import "MCTRegistrationPage1VC.h"
#import "MCTRegistrationForOauthVC.h"
#import "MCTComponentFramework.h"
#import "MCTConfigProvider.h"
#import "MCTUIUtils.h"
#import "MCTBulletView.h"
#import "MCTMobileInfo.h"
#import "MCTApplePush.h"

#define MARGIN 10
#define MCT_RESIGN_ACTIVE_TIMEOUT 1

@interface MCTPushNotificationsVC ()

- (void)onContinueClicked:(id)sender;
- (void)goToNextPage;
- (BOOL)hasReachedBottom;

@property (nonatomic) BOOL canGoToNextPage;

@end

@implementation MCTPushNotificationsVC



+ (MCTPushNotificationsVC *)viewController
{
    T_UI();

    MCTPushNotificationsVC *vc = [[MCTPushNotificationsVC alloc] initWithNibName:@"pushNotifications" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    return vc;
}

- (void)onContinueClicked:(id)sender
{
    if (self.canGoToNextPage) {
        if ([MCTApplePush didRegisterForPushNotifications]) {
            [self goToNextPage];
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didResignActive)
                                                         name:UIApplicationWillResignActiveNotification
                                                       object:nil];
            [self performSelector:@selector(didNotResignActive) withObject:nil afterDelay:MCT_RESIGN_ACTIVE_TIMEOUT];
            [MCTApplePush registerForPushNotifications];
        }
    } else {
        CGFloat newY = self.scrollView.contentOffset.y + ([UIScreen mainScreen].applicationFrame.size.height / 3 * 2);
        if (newY > (self.scrollView.contentSize.height - self.scrollView.frame.size.height)) {
            newY = (self.scrollView.contentSize.height - self.scrollView.frame.size.height);
        }

        [self.scrollView setContentOffset:CGPointMake(0, ceil(newY)) animated:YES];
    }
}

- (void)didNotResignActive
{
    T_UI();
    HERE();
    // User was already asked permission to push notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [self goToNextPage];
}

- (void)didResignActive
{
    T_UI();
    HERE();
    // User is asked permission to push notifications
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
    [self goToNextPage];
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    if (MCT_FULL_WIDTH_HEADERS) {
        CGFloat w = [UIScreen mainScreen].applicationFrame.size.width;
        self.imageView.frame = CGRectMake(0, 0, w, 115 * w / 320);
        self.imageView.autoresizingMask = UIViewAutoresizingNone;
    }

    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    self.hidesBottomBarWhenPushed = YES;
    self.title = NSLocalizedString(@"Notifications", nil);
    int textWidth = self.view.width - 2 * MARGIN;

    UIColor *textColor;
    if (IS_ROGERTHAT_APP) {
        [MCTUIUtils setBackgroundPlainToView:self.view];
        textColor = [UIColor blackColor];
    } else {
        self.view.backgroundColor = [UIColor MCTHomeScreenBackgroundColor];
        [self changeNavigationControllerAppearanceWithColorScheme:MCTColorSchemeLight
                                               andBackGroundColor:[UIColor MCTHomeScreenBackgroundColor]];
        textColor = [UIColor MCTHomeScreenTextColor];
    }

    UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, textWidth, 18)];
    lbl1.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    lbl1.textAlignment = NSTextAlignmentCenter;
    lbl1.backgroundColor = [UIColor clearColor];
    lbl1.textColor = textColor;
    lbl1.numberOfLines = 0;

    lbl1.text = [NSString stringWithFormat:NSLocalizedString(@"%1$@ is an app that allows you to communicate with people and organizations. The communication is done via messages. The %1$@ app uses notifications to keep you informed about new messages. Therefore it is important to allow notifications for the %1$@ app.\n\nThere are two types of messages:\n1. Messages specifically directed to you. These can come from friends or from organizations (e.g. keeping you informed about an order).\n2. General messages from organizations with for example News, Promotions, etc.\n\nYou can always unsubscribe from general messages, making sure you only receive messages that are relevant to you.\nBelow you can see an example of such a message:", nil), MCT_PRODUCT_NAME];

    lbl1.height =  [MCTUIUtils sizeForLabel:lbl1].height;

    lbl1.top = self.imageView.bottom + (MCT_FULL_WIDTH_HEADERS ? 16 : self.imageView.top);
    lbl1.left = MARGIN;
    [self.scrollView addSubview:lbl1];

    MCTLocaleInfo *locale = [MCTLocaleInfo info];
    NSString *lang = locale.language;

    UIImage *tmpImage = [UIImage imageNamed:[NSString stringWithFormat:@"broadcast-example-%1$@-1.png", lang]];
    if (!tmpImage) {
        lang = @"en";
        tmpImage = [UIImage imageNamed:[NSString stringWithFormat:@"broadcast-example-%1$@-1.png", lang]];
    }

    CGFloat ratio = ([[UIScreen mainScreen] applicationFrame].size.width - 60) / tmpImage.size.width;
    CGRect imageFrame = CGRectMake(20, 0, tmpImage.size.width * ratio, tmpImage.size.height * ratio);
    MCT_RELEASE(tmpImage);

    UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:imageFrame];
    animatedImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:[NSString stringWithFormat:@"broadcast-example-%1$@-1.png", lang]],
                                         [UIImage imageNamed:[NSString stringWithFormat:@"broadcast-example-%1$@-2.png", lang]],
                                         [UIImage imageNamed:[NSString stringWithFormat:@"broadcast-example-%1$@-3.png", lang]],
                                         [UIImage imageNamed:[NSString stringWithFormat:@"broadcast-example-%1$@-4.png", lang]],
                                         [UIImage imageNamed:[NSString stringWithFormat:@"broadcast-example-%1$@-5.png", lang]],
                                         [UIImage imageNamed:[NSString stringWithFormat:@"broadcast-example-%1$@-6.png", lang]], nil];
    animatedImageView.animationDuration = 6.0f;
    animatedImageView.animationRepeatCount = 0;
    [animatedImageView startAnimating];

    animatedImageView.contentMode = UIViewContentModeScaleAspectFit;
    animatedImageView.top = lbl1.bottom + 10;
    animatedImageView.centerX = self.view.centerX;
    [self.scrollView addSubview:animatedImageView];

    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, animatedImageView.bottom + 20);
    self.scrollView.delegate = self;
    self.canGoToNextPage = [self hasReachedBottom];

    NSArray *actions = [NSArray arrayWithObjects:kINTENT_PUSH_NOTIFICATION_SETTINGS_UPDATED, nil];
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:actions
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }

    [super viewDidDisappear:animated];
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_PUSH_NOTIFICATION_SETTINGS_UPDATED) {
        [self goToNextPage];
        return;
    }

    [super onIntent:intent];
}

- (void)goToNextPage
{
    T_UI();
    [[MCTComponentFramework configProvider] setString:@"YES" forKey:MCT_CONFIGKEY_PUSH_NOTIFICATION_SHOWN];
    NSMutableArray *enabledTypes = [NSMutableArray array];
    IF_PRE_IOS8({
        UIRemoteNotificationType types = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
        if (IS_FLAG_SET(types, UIRemoteNotificationTypeAlert)) {
            [enabledTypes addObject:@"Alert"];
        }
        if (IS_FLAG_SET(types, UIRemoteNotificationTypeBadge)) {
            [enabledTypes addObject:@"Badge"];
        }
        if (IS_FLAG_SET(types, UIRemoteNotificationTypeSound)) {
            [enabledTypes addObject:@"Sound"];
        }
    });
    IF_IOS8_OR_GREATER({
        UIUserNotificationType types = [UIApplication sharedApplication].currentUserNotificationSettings.types;
        if (IS_FLAG_SET(types, UIUserNotificationTypeAlert)) {
            [enabledTypes addObject:@"Alert"];
        }
        if (IS_FLAG_SET(types, UIUserNotificationTypeBadge)) {
            [enabledTypes addObject:@"Badge"];
        }
        if (IS_FLAG_SET(types, UIUserNotificationTypeSound)) {
            [enabledTypes addObject:@"Sound"];
        }
    });
    NSDictionary *dict = @{@"enabled_remote_notification_types" : [enabledTypes componentsJoinedByString:@", "]};
    [MCTRegistrationMgr sendRegistrationStep:@"1b" withPostValues:dict];
    if (IS_OAUTH_REGISTRATION) {
        [self.navigationController setViewControllers:@[[MCTRegistrationForOauthVC viewController]]
                                             animated:YES];
    } else {
        if (MCT_FACEBOOK_APP_ID == nil || !MCT_FACEBOOK_REGISTRATION) {
            [MCTRegistrationMgr sendRegistrationStep:@"2b"];
            [self.navigationController setViewControllers:@[[MCTRegistrationPage1VC viewController]]
                                                 animated:YES];
        } else {
            [self.navigationController setViewControllers:@[[MCTRegistrationPage0VC viewController]]
                                                 animated:YES];
        }
    }
}

- (BOOL)hasReachedBottom
{
    if (self.scrollView.contentOffset.y >= (self.scrollView.contentSize.height - self.scrollView.frame.size.height)) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    T_UI();
    if (self.canGoToNextPage) {
        return;
    }
    if ([self hasReachedBottom]) {
        self.canGoToNextPage = YES;
    }
}

#pragma mark -

@end