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
#import "MCTFriendLocationAnnotation.h"
#import "MCTGPSLocationVC.h"
#import "MCTGPSLocationView.h"
#import "MCTJSONUtils.h"
#import "MCTMessageEnums.h"
#import "MCTMessageHelper.h"
#import "MCTUtils.h"
#import "MCTUIUtils.h"

#define MARGIN 10

@interface MCTGPSLocationView ()

@property (nonatomic, strong) MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *locationResult;

@end


@implementation MCTGPSLocationView

- (id)initWithDict:(NSDictionary *)widgetDict
          andWidth:(CGFloat)width
    andColorScheme:(MCTColorScheme)colorScheme
  inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc
{
    T_UI();
    if (self = [super init]) {
        self.width = width;
        self.widgetDict = widgetDict;

        id result = [self.widgetDict objectForKey:@"value"];
        if (result) {
            self.locationResult = [MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO transferObjectWithDict:result];
        }

        self.getGPSLocationBtn = [TTButton buttonWithStyle:MCT_STYLE_EMBOSSED_SMALL_MULTILINE_BUTTON
                                                     title:NSLocalizedString(@"Get location", nil)];
        [self.getGPSLocationBtn addTarget:self
                                   action:@selector(onGetGPSLocationButtonTapped:)
                         forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.getGPSLocationBtn];

        self.showMapBtn = [TTButton buttonWithStyle:MCT_STYLE_EMBOSSED_SMALL_MULTILINE_BUTTON
                                                     title:NSLocalizedString(@"Show location", nil)];
        self.showMapBtn.enabled = (BOOL)self.locationResult;
        [self.showMapBtn addTarget:self
                            action:@selector(onShowMapButtonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.showMapBtn];

        self.viewController = vc;
    }

    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    T_UI();
    self.getGPSLocationBtn.enabled = enabled;
    self.showMapBtn.enabled = enabled && self.locationResult;
    [super setEnabled:enabled];
}

#pragma mark - MCTWidget

- (CGFloat)height
{
    T_UI();
    return MAX(self.getGPSLocationBtn.bottom, self.showMapBtn.bottom) + MARGIN;
}

- (MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *)result
{
    T_UI();
    return self.locationResult;
}

- (NSDictionary *)widget
{
    T_UI();
    [self.widgetDict setValue:[[self result] dictRepresentation] forKey:@"value"];
    return self.widgetDict;
}

+ (NSString *)valueStringForWidget:(NSDictionary *)widgetDict
{
    T_UI();
    MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *locationResult =
        [MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO transferObjectWithDict:[widgetDict objectForKey:@"value"]];
    return [NSString stringWithFormat:@"<%.03f, %.03f> ± %.02fm",
            locationResult.latitude, locationResult.longitude, locationResult.horizontal_accuracy];
}

#pragma mark -

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    CGFloat btnWidth = (self.width / 2) - MARGIN / 2;

    CGSize s1 = [MCTUIUtils sizeForTTButton:self.getGPSLocationBtn constrainedToSize:CGSizeMake(btnWidth, 126)];
    CGRect sFrame1 = CGRectMake(0, 0, btnWidth, MAX(40, s1.height));
    self.getGPSLocationBtn.frame = sFrame1;
    self.getGPSLocationBtn.left = 0;

    CGSize s2 = [MCTUIUtils sizeForTTButton:self.showMapBtn constrainedToSize:CGSizeMake(btnWidth, 126)];
    CGRect sFrame2 = CGRectMake(0, 0, btnWidth, MAX(40, s2.height));
    self.showMapBtn.frame = sFrame2;
    self.showMapBtn.right = self.width;
}

- (void)onGetGPSLocationButtonTapped:(id)sender
{
    T_UI();
    self.locationResult = nil;
    self.showMapBtn.enabled = NO;

    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        BOOL gpsRequired = [self.widgetDict boolForKey:@"gps"];

        MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *vc = self.viewController;
        UIView *view = vc.navigationController ? vc.navigationController.view : vc.view;

        self.viewController.currentProgressHUD = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:self.viewController.currentProgressHUD];
        self.viewController.currentProgressHUD.labelText = NSLocalizedString(@"Updating location…", nil);
        self.viewController.currentProgressHUD.mode = MBProgressHUDModeIndeterminate;
        self.viewController.currentProgressHUD.dimBackground = YES;
        [self.viewController.currentProgressHUD show:YES];

        NSArray *intents = [NSArray arrayWithObjects:kINTENT_LOCATION_RETRIEVED, kINTENT_LOCATION_RETRIEVING_FAILED, nil];
        [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                       forIntentActions:intents
                                                                onQueue:[MCTComponentFramework mainQueue]];

        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            T_BIZZ();
            [[MCTComponentFramework locationPlugin] requestMyLocationWithGPS:gpsRequired timeout:30];
        }];
    } else {
        NSString *msg = NSLocalizedString(@"You need to turn on location services in order to continue.", nil);
        NSString *howToEnable = @"";
        IF_IOS8_OR_GREATER({
            howToEnable = [NSString stringWithFormat:NSLocalizedString(@"_enable_location_services_ios8", nil),
                           MCT_PRODUCT_NAME];
        });
        IF_PRE_IOS8({
            howToEnable = [NSString stringWithFormat:NSLocalizedString(@"_enable_location_services_ios7", nil),
                           MCT_PRODUCT_NAME];
        });

        [MCTUIUtils showAlertWithTitle:NSLocalizedString(@"Location services disabled", nil)
                               andText:[NSString stringWithFormat:@"%@\n\n%@", msg, howToEnable]];
    }
}

- (void)onShowMapButtonTapped:(id)sender
{
    T_UI();
    MCTFriendsPlugin *friendsPlugin = [MCTComponentFramework friendsPlugin];
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.locationResult.latitude,
                                                                                              self.locationResult.longitude)
                                                          altitude:self.locationResult.altitude
                                                horizontalAccuracy:self.locationResult.horizontal_accuracy
                                                  verticalAccuracy:self.locationResult.vertical_accuracy
                                                         timestamp:[NSDate dateWithTimeIntervalSince1970:self.locationResult.timestamp]];

    MCTGPSLocationVC *vc = [MCTGPSLocationVC viewController];
    vc.friendsPlugin = friendsPlugin;
    vc.annotation = [MCTFriendLocationAnnotation annotationWithFriend:[friendsPlugin myEmail]
                                                          andLocation:location];

    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (id)toBeShownBeforeSubmitWithPositiveButton:(BOOL)isPositiveButton
{
    T_UI();
    if (isPositiveButton && !self.locationResult) {
        return [MCTUIUtils showAlertWithTitle:NSLocalizedString(@"No location", nil)
                                      andText:NSLocalizedString(@"You need to get your current location before you can continue.", nil)];
    }

    return nil;
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_LOCATION_RETRIEVED) {
        [self.viewController.currentProgressHUD hide:YES];
        MCT_RELEASE(self.viewController.currentProgressHUD);

        [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                          forIntentAction:kINTENT_LOCATION_RETRIEVED];
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                          forIntentAction:kINTENT_LOCATION_RETRIEVING_FAILED];

        self.locationResult = [MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO transferObject];
        self.locationResult.horizontal_accuracy = [intent longForKey:@"accuracy"];
        self.locationResult.vertical_accuracy = [intent longForKey:@"vertical_accuracy"];
        self.locationResult.latitude = (double)[intent longForKey:@"latitude"] / MCT_LOCATION_FACTOR;
        self.locationResult.longitude = (double)[intent longForKey:@"longitude"] / MCT_LOCATION_FACTOR;
        self.locationResult.altitude = (double)[intent longForKey:@"altitude"] / MCT_LOCATION_FACTOR;
        self.locationResult.timestamp = [intent longForKey:@"timestamp"];

        self.showMapBtn.enabled = YES;
    }

    else if (intent.action == kINTENT_LOCATION_RETRIEVING_FAILED) {
        [self.viewController.currentProgressHUD hide:YES];
        MCT_RELEASE(self.viewController.currentProgressHUD);

        [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                          forIntentAction:kINTENT_LOCATION_RETRIEVED];
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                          forIntentAction:kINTENT_LOCATION_RETRIEVING_FAILED];

        self.viewController.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                                      andText:NSLocalizedString(@"An error occurred. Please try again.", nil)];
        self.viewController.currentAlertView.tag = MCT_TAG_WIDGET_ACTION;
        self.viewController.currentAlertView.delegate = self.viewController;
    }
}

@end