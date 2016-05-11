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

#import "MCTAnnotation.h"
#import "MCTComponentFramework.h"
#import "MCTFriendLocationAnnotation.h"
#import "MCTFriendsPlugin.h"
#import "MCTGeoActionVerifyVC.h"
#import "MCTUIUtils.h"

#import "UIImage+Resize.h"

@interface MCTGeoActionVerifyVC ()

@property (nonatomic, strong) MCTFriendsPlugin *friendsPlugin;

@end


@implementation MCTGeoActionVerifyVC


+ (MCTGeoActionVerifyVC *)viewController
{
    T_UI();
    MCTGeoActionVerifyVC *vc = [[MCTGeoActionVerifyVC alloc] initWithNibName:@"geoActionVerify" bundle:nil];
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    [MCTUIUtils setBackgroundPlainToView:self.view];
    self.friendsPlugin = [MCTComponentFramework friendsPlugin];

    // 1 degree = ± 111000 m
    CLLocationDegrees span = fmax(0.002, 2 * self.annotation.location.horizontalAccuracy / 111000.0);

    [self.mapView setRegion:MKCoordinateRegionMake(self.annotation.location.coordinate, MKCoordinateSpanMake(span, span))];
    [self.mapView addAnnotation:self.annotation];
    [self.mapView selectAnnotation:self.annotation animated:YES];
    self.mapView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.mapView.layer.borderWidth = 1;

    self.verifyLabel.text = NSLocalizedString(@"Is the location correct?", nil);

    // Replace UIButtons with TTButtons
    [(UIButton *)self.yesButton setTitle:NSLocalizedString(@"Yes", nil)
                                forState:UIControlStateNormal];
    self.yesButton = [MCTUIUtils replaceUIButtonWithTTButton:(UIButton *)self.yesButton];

    [(UIButton *)self.noButton setTitle:NSLocalizedString(@"No", nil)
                                forState:UIControlStateNormal];
    self.noButton = [MCTUIUtils replaceUIButtonWithTTButton:(UIButton *)self.noButton];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MCTAnnotation *)annotation
{
    T_UI();
    MKAnnotationView *view;
    if ([annotation isKindOfClass:[MCTFriendLocationAnnotation class]]) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ident"];
        view.image = [self.friendsPlugin friendAvatarImageByEmail:[(MCTFriendLocationAnnotation *)annotation friend]];
        if (view.image.size.width > 50) {
            view.image = [view.image resizedImage:CGSizeMake(50, 50) interpolationQuality:kCGInterpolationLow];
        }
    } else {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ident"];
    }
    view.canShowCallout = YES;
    return view;
}

- (IBAction)onYesButtonClicked:(id)sender
{
    T_UI();
    if (self.delegate != nil)
        [self.delegate geoLocation:self.annotation.location verified:YES];
}

- (IBAction)onNoButtonClicked:(id)sender
{
    T_UI();
    if (self.delegate != nil)
        [self.delegate geoLocation:self.annotation.location verified:NO];
}

@end