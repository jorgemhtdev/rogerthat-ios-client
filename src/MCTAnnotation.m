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

#import "MCTAnnotation.h"
#import "MCTComponentFramework.h"
#import "MCTFriendsPlugin.h"


@implementation MCTAnnotation

@synthesize location = _location;

+ (MCTAnnotation *)annotationWithLocation:(CLLocation *)loc
{
    T_UI();
    return [[MCTAnnotation alloc] initWithLocation:loc];
}

- (id)initWithLocation:(CLLocation *)loc
{
    T_UI();
    if (self = [super init]) {
        self.location = loc;
        self.coordinate = loc.coordinate;
        self.distance = 0;
        self.circle = [MKCircle circleWithCenterCoordinate:self.coordinate radius:self.location.horizontalAccuracy];
    }
    return self;
}

#pragma mark -
#pragma mark MKAnnotation

- (void)setLocation:(CLLocation *)loc
{
    if (loc == self.location)
        return;

    _location = loc;
    if (loc == nil)
        return;

    self.coordinate = loc.coordinate;
}

- (void)setDistanceWithOtherLocation:(CLLocation *)otherLocation
{
    T_UI();
    if (self.location == nil || otherLocation == nil)
        return;

    self.distance = [self.location distanceFromLocation:otherLocation];
    self.distanceAccuracy = self.location.horizontalAccuracy + otherLocation.horizontalAccuracy;
}

- (NSString *)subtitle
{
    T_UI();
    // TODO: figer out how to show timestamp, distance AND accuracy
    if (self.distance) {
        NSString *distUnit = (self.distance > 1000) ? @"km" : @"m";
        int dist = (self.distance > 1000) ? self.distance/1000 : self.distance;
        return [NSString stringWithFormat:@"Distance: ± %d %@", dist, distUnit];
    }
    return nil;
}

@end