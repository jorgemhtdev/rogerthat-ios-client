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
#import "MCTGPSLocationVC.h"
#import "MCTUIUtils.h"

#import "UIImage+Resize.h"

@interface MCTGPSLocationVC ()

@end


@implementation MCTGPSLocationVC


+ (MCTGPSLocationVC *)viewController
{
    T_UI();
    MCTGPSLocationVC *vc = [[MCTGPSLocationVC alloc] initWithNibName:@"gpsLocation" bundle:nil];
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    [MCTUIUtils setBackgroundPlainToView:self.view];

    // 1 degree = ± 111000 m
    CLLocationDegrees span = fmax(0.002, 2 * self.annotation.location.horizontalAccuracy / 111000.0);

    [self.mapView setRegion:MKCoordinateRegionMake(self.annotation.location.coordinate, MKCoordinateSpanMake(span, span))];
    [self.mapView addAnnotation:self.annotation];
    [self.mapView selectAnnotation:self.annotation animated:YES];
    [self.mapView addOverlay:self.annotation.circle];

    self.mapView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.mapView.layer.borderWidth = 1;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MCTFriendLocationAnnotation *)annotation
{
    T_UI();
    MKAnnotationView *view;
    view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ident"];
    view.image = [self.friendsPlugin friendAvatarImageByEmail:[annotation friend]];
    if (view.image.size.width > 50) {
        view.image = [view.image resizedImage:CGSizeMake(50, 50) interpolationQuality:kCGInterpolationLow];
    }
    view.canShowCallout = YES;
    
    return view;
}

- (id)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    T_UI();
    MKCircleView *view = [[MKCircleView alloc] initWithCircle:overlay];
    view.fillColor = [UIColor blackColor];
    view.alpha = 0.25;
    return view;
}

@end