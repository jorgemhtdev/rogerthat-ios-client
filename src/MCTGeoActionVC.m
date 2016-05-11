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

#import <CoreLocation/CoreLocation.h>

#import "MCTComponentFramework.h"
#import "MCTFriendLocationAnnotation.h"
#import "MCTFriendsPlugin.h"
#import "MCTGeoActionVerifyVC.h"
#import "MCTGeoActionVC.h"
#import "MCTUIUtils.h"

#import "MCTJSONUtils.h"

#define G_GEO_OK @"OK"
#define G_GEO_ZERO_RESULTS @"ZERO_RESULTS"
#define G_GEO_OVER_QUERY_LIMIT @"OVER_QUERY_LIMIT"
#define G_GEO_REQUEST_DENIED @"REQUEST_DENIED"
#define G_GEO_INVALID_REQUEST @"INVALID_REQUEST"
#define G_GEO_UNKNOWN_ERROR @"UNKNOWN_ERROR"

#define MCT_GEO_ACTION_ERROR_DEFAULT NSLocalizedString(@"Failed to get the geographic location", nil)
#define MCT_GEO_ACTION_ERROR_UNKNOWN_ADDRESS NSLocalizedString(@"No corresponding geographic location could be found for the specified address. Is the address specific enough?", nil)

@interface MCTGeoActionVC ()

@property (nonatomic, strong) MCTFriendsPlugin *friendsPlugin;

- (BOOL)connectedToInternet;

@end


@implementation MCTGeoActionVC


+ (MCTGeoActionVC *)viewController
{
    return [[MCTGeoActionVC alloc] initWithNibName:@"geoAction" bundle:nil];
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    
    [MCTUIUtils setBackgroundPlainToView:self.view];

    self.title = NSLocalizedString(@"Geo Location", nil);

    self.friendsPlugin = [MCTComponentFramework friendsPlugin];

    [(UIButton *) self.currentLocationButton setTitle:NSLocalizedString(@"Resolve", nil) forState:UIControlStateNormal];
    [(UIButton *) self.resolveAddressButton setTitle:NSLocalizedString(@"Resolve", nil) forState:UIControlStateNormal];
    self.resolveAddressButton.enabled = NO;
    self.getCurrentLocationLabel.text = NSLocalizedString(@"Get current location", nil);
    self.getAddressLocationLabel.text = NSLocalizedString(@"Get location of an address:", nil);

    // Replace UIButtons with TTButtons
    self.resolveAddressButton = [MCTUIUtils replaceUIButtonWithTTButton:(UIButton *) self.resolveAddressButton];
    self.currentLocationButton = [MCTUIUtils replaceUIButtonWithTTButton:(UIButton *) self.currentLocationButton];
}

- (void)geoLocation:(CLLocation *)location verified:(BOOL)verified
{
    T_UI();
    [self dismissViewControllerAnimated:YES completion:nil];
    if (verified) {
        [self.navigationController popViewControllerAnimated:YES];
        self.actionTextField.text = [NSString stringWithFormat:@"%g,%g", location.coordinate.latitude,
                               location.coordinate.longitude];
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    T_UI();
    HERE();
    MCTlong tenMinutes = 600;
    NSTimeInterval secondsAgo = fabs([newLocation.timestamp timeIntervalSinceNow]);
    if (secondsAgo > tenMinutes)
        return;

    [self.locationMgr stopUpdatingLocation];
    [self.spinner1 stopAnimating];
    self.currentLocationButton.enabled = YES;

    MCTGeoActionVerifyVC *vc = [MCTGeoActionVerifyVC viewController];
    vc.delegate = self;
    vc.annotation = [MCTFriendLocationAnnotation annotationWithFriend:[self.friendsPlugin myEmail]
                                                          andLocation:newLocation];
    [self presentViewController:vc animated:YES completion:nil];
}

- (BOOL)connectedToInternet
{
    if (![MCTUtils connectedToInternet]) {
        self.currentAlertView = [MCTUIUtils showNetworkErrorAlert];
        return NO;
    }
    return YES;
}

- (IBAction)onCurrentLocationClicked:(id)sender
{
    T_UI();
    if (![self connectedToInternet])
        return;

    self.currentLocationButton.enabled = NO;
    [self.spinner1 startAnimating];

    if (self.locationMgr == nil) {
        self.locationMgr = [[CLLocationManager alloc] init];
        self.locationMgr.delegate = self;
        self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationMgr.distanceFilter = 1.0f;
    }
    [self.locationMgr startUpdatingLocation];
}

- (void)resolveAddressFailed:(MCTHTTPRequest *)request
{
    T_UI();
    self.currentAlertView = [MCTUIUtils showErrorAlertWithText:MCT_GEO_ACTION_ERROR_DEFAULT];

    [self.spinner2 stopAnimating];
    self.resolveAddressButton.enabled = YES;
    self.addressTextField.enabled = YES;
}

- (void)resolveAddressFinished:(MCTHTTPRequest *)request
{
    T_UI();
    NSString *jsonString = [request responseString];
    NSDictionary *json = [jsonString MCT_JSONValue];

    NSString *status = [json stringForKey:@"status"];
    LOG(@"Got status '%@' when resolving '%@'", status, self.addressTextField.text);

    if ([G_GEO_OK isEqualToString:status]) {
        NSDictionary *jsonResult = [[json objectForKey:@"results"] firstObject];
        NSDictionary *jsonLocation = [[jsonResult objectForKey:@"geometry"] objectForKey:@"location"];

        CLLocationCoordinate2D coordinate;
        coordinate.longitude = [[jsonLocation objectForKey:@"lng"] doubleValue];
        coordinate.latitude = [[jsonLocation objectForKey:@"lat"] doubleValue];

        CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate
                                                              altitude:0
                                                    horizontalAccuracy:0
                                                      verticalAccuracy:0
                                                             timestamp:[NSDate date]];

        MCTGeoActionVerifyVC *vc = [MCTGeoActionVerifyVC viewController];
        vc.annotation = [MCTAnnotation annotationWithLocation:location];
        vc.annotation.title = [jsonResult stringForKey:@"formatted_address"];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([G_GEO_ZERO_RESULTS isEqualToString:status]) {
        self.currentAlertView = [MCTUIUtils showErrorAlertWithText:MCT_GEO_ACTION_ERROR_UNKNOWN_ADDRESS];
        self.currentAlertView.delegate = self;
    } else {
        self.currentAlertView = [MCTUIUtils showErrorAlertWithText:MCT_GEO_ACTION_ERROR_DEFAULT];
        self.currentAlertView.delegate = self;
    }

    [self.spinner2 stopAnimating];
    self.resolveAddressButton.enabled = YES;
    self.addressTextField.enabled = YES;
}

- (IBAction)onResolveAddressClicked:(id)sender
{
    T_UI();
    if (![self connectedToInternet])
        return;

    [self.spinner2 startAnimating];
    self.resolveAddressButton.enabled = NO;
    self.addressTextField.enabled = NO;

    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@",
                           [self.addressTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    if (self.httpRequest) {
        [self.httpRequest clearDelegatesAndCancel];
        MCT_RELEASE(self.httpRequest);
    }
    self.httpRequest = [MCTHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    self.httpRequest.timeOutSeconds = 30;
    self.httpRequest.delegate = self;
    self.httpRequest.didFailSelector = @selector(resolveAddressFailed:);
    self.httpRequest.didFinishSelector = @selector(resolveAddressFinished:);
    self.httpRequest.validatesSecureCertificate = YES;

    [[MCTComponentFramework workQueue] addOperation:self.httpRequest];
}

- (IBAction)onAddressEditingChanged:(id)sender
{
    T_UI();
    UITextField *txtField = sender;
    self.resolveAddressButton.enabled = [txtField.text length] > 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)txtField
{
    T_UI();
    [txtField resignFirstResponder];
    [self onResolveAddressClicked:self.resolveAddressButton];
    return YES;
}

- (IBAction)onBackgroundTapped:(id)sender
{
    T_UI();
    [self.addressTextField resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    MCT_RELEASE(self.currentAlertView);
}

- (void)dealloc
{
    T_UI();
    [self.httpRequest clearDelegatesAndCancel];
}

@end