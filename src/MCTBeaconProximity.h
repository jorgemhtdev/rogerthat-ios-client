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

@interface MCTBeaconProximity : NSObject

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) NSNumber *major;
@property (nonatomic, strong) NSNumber *minor;
@property (nonatomic) CLProximity proximity;

+ (MCTBeaconProximity *)beaconProximityWithUUID:(NSString *)uuid
                                          major:(NSNumber *)major
                                          minor:(NSNumber *)minor
                                      proximity:(CLProximity)proximity;

- (id)initWithUUID:(NSString *)uuid
             major:(NSNumber *)major
             minor:(NSNumber *)minor
         proximity:(CLProximity)proximity;
- (NSDictionary *)dictRepresentation;

@end


#pragma mark -

@interface MCTDiscoveredBeaconProximity : MCTBeaconProximity {
    NSString *friendEmail_;
    NSString *tag_;
}

@property (nonatomic, copy) NSString *friendEmail;
@property (nonatomic, copy) NSString *tag;

+ (MCTDiscoveredBeaconProximity *)beaconProximityWithUUID:(NSString *)uuid
                                                    major:(NSNumber *)major
                                                    minor:(NSNumber *)minor
                                                proximity:(CLProximity)proximity
                                              friendEmail:(NSString *)friendEmail
                                                      tag:(NSString *)tag;

- (id)initWithUUID:(NSString *)uuid
             major:(NSNumber *)major
             minor:(NSNumber *)minor
         proximity:(CLProximity)proximity
       friendEmail:(NSString *)friendEmail
               tag:(NSString *)tag;
- (NSDictionary *)dictRepresentation;

@end