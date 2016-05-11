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

#import <MapKit/MapKit.h>

#import "MCTUIViewController.h"
#import "MCTAnnotation.h"
#import "MCTFriendsPlugin.h"


@protocol MCTGeoActionVerifyDelegate<NSObject>

- (void)geoLocation:(CLLocation *)location verified:(BOOL)verified;

@end


@interface MCTGeoActionVerifyVC : MCTUIViewController <MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) id<MCTGeoActionVerifyDelegate> delegate;
@property (nonatomic, strong) MCTAnnotation *annotation;
@property (nonatomic, strong) IBOutlet UILabel *verifyLabel;
@property (nonatomic, strong) IBOutlet UIControl *yesButton;
@property (nonatomic, strong) IBOutlet UIControl *noButton;

+ (MCTGeoActionVerifyVC *)viewController;

- (IBAction)onYesButtonClicked:(id)sender;
- (IBAction)onNoButtonClicked:(id)sender;

@end