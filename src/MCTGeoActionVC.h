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

#import "MCTUIViewController.h"
#import "MCTHTTPRequest.h"
#import "MCTGeoActionVerifyVC.h"


@interface MCTGeoActionVC : MCTUIViewController<CLLocationManagerDelegate, MCTGeoActionVerifyDelegate,UIAlertViewDelegate, ASIHTTPRequestDelegate>

@property (nonatomic, strong) CLLocationManager *locationMgr;
@property (nonatomic, strong) IBOutlet UIControl *currentLocationButton;
@property (nonatomic, strong) IBOutlet UIControl *resolveAddressButton;
@property (nonatomic, strong) IBOutlet UITextField *addressTextField;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner1;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner2;
@property (nonatomic, strong) UITextField *actionTextField;
@property (nonatomic, strong) IBOutlet UILabel *getCurrentLocationLabel;
@property (nonatomic, strong) IBOutlet UILabel *getAddressLocationLabel;
@property (nonatomic, strong) MCTHTTPRequest *httpRequest;

+ (MCTGeoActionVC *)viewController;

- (IBAction)onBackgroundTapped:(id)sender;
- (IBAction)onCurrentLocationClicked:(id)sender;
- (IBAction)onResolveAddressClicked:(id)sender;
- (IBAction)onAddressEditingChanged:(id)sender;

@end