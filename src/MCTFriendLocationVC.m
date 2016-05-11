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
#import "MCTFriendLocationVC.h"
#import "MCTFriendsPlugin.h"
#import "MCTFriendLocationAnnotation.h"
#import "MCTIntent.h"
#import "MCTUIUtils.h"

#import "UIImage+Resize.h"


#define MCT_LOCATION_FACTOR 1000000


@interface MCTFriendLocationVC ()

- (void)zoomToFitAnnotations;

@end


@implementation MCTFriendLocationVC


+ (id)viewController
{
    T_UI();
    MCTFriendLocationVC *vc = [[MCTFriendLocationVC alloc] initWithNibName:@"friendLocation" bundle:nil];
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    [MCTUIUtils setBackgroundPlainToView:self.view];
}


- (MCTFriendsPlugin *)friendsPlugin
{
    T_UI();
    return (MCTFriendsPlugin *) [MCTComponentFramework pluginForClass:[MCTFriendsPlugin class]];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MCTFriendLocationAnnotation *)annotation
{
    T_UI();
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@""];
    view.image = [[self friendsPlugin] friendAvatarImageByEmail:annotation.friend];
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

- (void)addAnnotationWithFriend:(NSString *)friendEmail andLocation:(CLLocation *)location
{
    T_UI();
    BOOL isMyAnnotation = [[self friendsPlugin] isMyEmail:friendEmail];
    MCTFriendLocationAnnotation *myAnnotation = nil;

    for (MCTFriendLocationAnnotation *annotation in [self.mapView.annotations reverseObjectEnumerator]) {
        if ([annotation.friend isEqualToString:friendEmail]) {
            annotation.location = location;
            [self zoomToFitAnnotations];
            return;
        }
        if (!isMyAnnotation && [[self friendsPlugin] isMyEmail:annotation.friend]) {
            myAnnotation = annotation;
        }
    }

    MCTFriendLocationAnnotation *addedAnnotation = [MCTFriendLocationAnnotation annotationWithFriend:friendEmail
                                                                                    andLocation:location];

    [self.mapView addAnnotation:addedAnnotation];
    [self.mapView addOverlay:addedAnnotation.circle];

    if (isMyAnnotation) {
        // Set distance between myself and friends to all other annotations + select others
        for (MCTFriendLocationAnnotation *annotation in self.mapView.annotations)
            if (annotation != addedAnnotation)
                [annotation setDistanceWithOtherLocation:location];

        [self.mapView selectAnnotation:addedAnnotation animated:YES];

    } else if (myAnnotation) {
        // Set distance between friend and myself on this annotation
        [addedAnnotation setDistanceWithOtherLocation:myAnnotation.location];
    }

    [self zoomToFitAnnotations];
}

- (void)zoomToFitAnnotations
{
    T_UI();
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;

    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;

    CLLocationAccuracy maxAccuracy = 0;

    for(MCTFriendLocationAnnotation *annotation in self.mapView.annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);

        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);

        maxAccuracy = fmax(maxAccuracy, annotation.location.horizontalAccuracy);
    }

    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides

    // 1 degree = 111000 m
    CLLocationDegrees minDelta = 2 * maxAccuracy / 111000.0;
    if (region.span.latitudeDelta < minDelta)
        region.span.latitudeDelta = minDelta;
    if (region.span.longitudeDelta < minDelta)
        region.span.longitudeDelta = minDelta;

    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

@end