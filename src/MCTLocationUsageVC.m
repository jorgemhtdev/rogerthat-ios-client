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

#import "MCTLocationUsageVC.h"
#import "MCTPushNotificationsVC.h"
#import "MCTRegistrationPage0VC.h"
#import "MCTRegistrationPage1VC.h"
#import "MCTComponentFramework.h"
#import "MCTConfigProvider.h"
#import "MCTUIUtils.h"
#import "MCTBulletView.h"

#define MARGIN 10

@interface MCTLocationUsageVC ()

@property (nonatomic, strong) CLLocationManager *locationMgr;


- (void)onContinueClicked:(id)sender;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)gotoNextPage;

@end

@implementation MCTLocationUsageVC


+ (MCTLocationUsageVC *)viewController
{
    T_UI();

    MCTLocationUsageVC *vc = [[MCTLocationUsageVC alloc] initWithNibName:@"locationUsage" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    return vc;
}


- (void)onContinueClicked:(id)sender
{
    CLAuthorizationStatus locationAuthorizationStatus = [CLLocationManager authorizationStatus];

    if (locationAuthorizationStatus == kCLAuthorizationStatusNotDetermined) {
        self.locationMgr = [[CLLocationManager alloc] init];
        self.locationMgr.delegate = self;
        self.locationMgr.distanceFilter = 1.0f;
        [self performSelectorOnMainThread:@selector(startUpdatingLocation) withObject:nil waitUntilDone:NO];
    } else {
        [self gotoNextPage];
    }
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
    self.continueButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Continue", nil)
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action:@selector(onContinueClicked:)];

    self.title = NSLocalizedString(@"Location usage", nil);
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = self.continueButtonItem;

    int textWidth = MCT_FULL_WIDTH_HEADERS ? self.view.width - 60 : self.imageView.right - self.imageView.left;

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

    UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, textWidth, 18)];
    lblDescription.font = [UIFont boldSystemFontOfSize:17];
    lblDescription.backgroundColor = [UIColor clearColor];
    lblDescription.textColor = textColor;
    lblDescription.numberOfLines = 0;
    lblDescription.text = [NSString stringWithFormat:NSLocalizedString(@"__location_usage_augment_experience", nil), MCT_PRODUCT_NAME];
    lblDescription.height =  [MCTUIUtils sizeForLabel:lblDescription].height;

    lblDescription.top = self.imageView.bottom + (MCT_FULL_WIDTH_HEADERS ? 16 : self.imageView.top);
    lblDescription.left = MCT_FULL_WIDTH_HEADERS ? 30 : self.imageView.left;
    [self.scrollView addSubview:lblDescription];

    UILabel *lblGreen = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, textWidth, 18)];
    lblGreen.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    lblGreen.backgroundColor = [UIColor clearColor];
    lblGreen.textColor = textColor;
    lblGreen.numberOfLines = 0;
    lblGreen.text = [NSString stringWithFormat:NSLocalizedString(@"__location_usage_used_for", nil), MCT_PRODUCT_NAME];
    lblGreen.height =  [MCTUIUtils sizeForLabel:lblGreen].height + 10;

    lblGreen.top = lblDescription.bottom + 10;
    lblGreen.left = lblDescription.left;
    [self.scrollView addSubview:lblGreen];

    UILabel *bv1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, textWidth - MARGIN, 18)];
    bv1.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    bv1.backgroundColor = [UIColor clearColor];
    bv1.textColor = textColor;
    bv1.numberOfLines = 0;
    bv1.text = [NSString stringWithFormat:@"\u2022 %1$@", NSLocalizedString(@"Discover customer services automatically", nil)];
    bv1.height =  [MCTUIUtils sizeForLabel:bv1].height + 10;

    bv1.top = lblGreen.bottom;
    bv1.left = lblDescription.left + MARGIN;
    [self.scrollView addSubview:bv1];

    UILabel *bv2 = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, textWidth - MARGIN, 18)];
    bv2.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    bv2.backgroundColor = [UIColor clearColor];
    bv2.textColor = textColor;
    bv2.numberOfLines = 0;
    NSString *bv2Text;
    switch (MCT_FRIENDS_CAPTION) {
        case MCTFriendsCaptionColleagues: {
            bv2Text = NSLocalizedString(@"Share location with your colleagues (only when you allow this)", nil);
            break;
        }
        case MCTFriendsCaptionContacts: {
            bv2Text = NSLocalizedString(@"Share location with your contacts (only when you allow this)", nil);
            break;
        }
        case MCTFriendsCaptionFriends:
        default: {
            bv2Text = NSLocalizedString(@"Share location with your friends (only when you allow this)", nil);
            break;
        }
    }
    bv2.text = [NSString stringWithFormat:@"\u2022 %1$@", bv2Text];
    bv2.height =  [MCTUIUtils sizeForLabel:bv2].height + 10;

    bv2.top = bv1.bottom;
    bv2.left = bv1.left;
    [self.scrollView addSubview:bv2];

    UILabel *bv3 = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, textWidth - MARGIN, 18)];
    bv3.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    bv3.backgroundColor = [UIColor clearColor];
    bv3.textColor = textColor;
    bv3.numberOfLines = 0;
    bv3.text = [NSString stringWithFormat:@"\u2022 %1$@", NSLocalizedString(@"Find customer services in your area", nil)];
    bv3.height =  [MCTUIUtils sizeForLabel:bv3].height + 10;

    bv3.top = bv2.bottom;
    bv3.left = bv1.left;
    [self.scrollView addSubview:bv3];

    UILabel *lblRed = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, textWidth, 18)];
    lblRed.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    lblRed.backgroundColor = [UIColor clearColor];
    lblRed.textColor = textColor;
    lblRed.numberOfLines = 0;
    lblRed.text = [NSString stringWithFormat:NSLocalizedString(@"__location_usage_not_used_for", nil), MCT_PRODUCT_NAME];
    lblRed.height =  [MCTUIUtils sizeForLabel:lblRed].height + 10;

    lblRed.top = bv3.bottom + 10;
    lblRed.left = lblDescription.left;
    [self.scrollView addSubview:lblRed];

    UILabel *bv4 = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, textWidth - MARGIN, 18)];
    bv4.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    bv4.backgroundColor = [UIColor clearColor];
    bv4.textColor = textColor;
    bv4.numberOfLines = 0;
    bv4.text = [NSString stringWithFormat:@"\u2022 %1$@", NSLocalizedString(@"Store your location", nil)];
    bv4.height =  [MCTUIUtils sizeForLabel:bv4].height + 10;

    bv4.top = lblRed.bottom;
    bv4.left = bv1.left;
    [self.scrollView addSubview:bv4];

    UILabel *bv5 = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, textWidth - MARGIN, 18)];
    bv5.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    bv5.backgroundColor = [UIColor clearColor];
    bv5.textColor = textColor;
    bv5.numberOfLines = 0;
    bv5.text = [NSString stringWithFormat:@"\u2022 %1$@", NSLocalizedString(@"Track your location without your prior consent", nil)];
    bv5.height =  [MCTUIUtils sizeForLabel:bv5].height + 10;

    bv5.top = bv4.bottom;
    bv5.left = bv1.left;
    [self.scrollView addSubview:bv5];

    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, bv5.bottom + 5);
}

- (void)gotoNextPage
{
    T_UI();
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_LOCATION_START_AUTOMATIC_DETECTION];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];

    if ([MCTRegistrationMgr isRegistered]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [[MCTComponentFramework configProvider] setString:@"YES" forKey:MCT_CONFIGKEY_LOCATION_USAGE_SHOWN];
        [MCTRegistrationMgr sendRegistrationStep:@"1a"];
        if (IS_CITY_APP) {
            [self.navigationController setViewControllers:@[[MCTPushNotificationsVC viewController]]
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
}

- (void)startUpdatingLocation
{
    T_UI();
    IF_IOS8_OR_GREATER({
        [self.locationMgr requestAlwaysAuthorization];
    });
    IF_PRE_IOS8({
        self.locationMgr.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        [self.locationMgr startUpdatingLocation];
        [self performSelectorOnMainThread:@selector(stopUpdatingLocation) withObject:nil waitUntilDone:NO];
    });
}

- (void)stopUpdatingLocation
{
    T_UI();
    [self.locationMgr stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    T_UI();
    if (status != kCLAuthorizationStatusNotDetermined) {
        [self gotoNextPage];
    }
}

@end