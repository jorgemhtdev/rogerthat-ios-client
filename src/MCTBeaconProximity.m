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

#import "MCTBeaconProximity.h"
#import "MCTJSONUtils.h"
#import "MCTUtils.h"

@implementation MCTBeaconProximity

+ (MCTBeaconProximity *)beaconProximityWithUUID:(NSString *)uuid
                                          major:(NSNumber *)major
                                          minor:(NSNumber *)minor
                                      proximity:(CLProximity)proximity
{
    T_DONTCARE();
    return [[MCTDiscoveredBeaconProximity alloc] initWithUUID:uuid
                                                         major:major
                                                         minor:minor
                                                     proximity:proximity];
}

- (id)initWithUUID:(NSString *)uuid
             major:(NSNumber *)major
             minor:(NSNumber *)minor
         proximity:(CLProximity)proximity
{
    T_DONTCARE();
    if (self = [super init]) {
        self.uuid = uuid;
        self.major = major;
        self.minor = minor;
        self.proximity = proximity;
    }
    return self;
}

- (NSDictionary *)dictRepresentation
{
    T_DONTCARE();
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.uuid forKey:@"uuid"];
    [dict setLong:[self.major longLongValue] forKey:@"major"];
    [dict setLong:[self.minor longLongValue] forKey:@"minor"];
    [dict setLong:self.proximity forKey:@"proximity"];

    return dict;
}

@end


#pragma mark -

@implementation MCTDiscoveredBeaconProximity

+ (MCTDiscoveredBeaconProximity *)beaconProximityWithUUID:(NSString *)uuid
                                                    major:(NSNumber *)major
                                                    minor:(NSNumber *)minor
                                                proximity:(CLProximity)proximity
                                              friendEmail:(NSString *)friendEmail
                                                      tag:(NSString *)tag
{
    T_DONTCARE();
    return [[MCTDiscoveredBeaconProximity alloc] initWithUUID:uuid
                                                         major:major
                                                         minor:minor
                                                     proximity:proximity
                                                   friendEmail:friendEmail
                                                           tag:tag];
}

- (id)initWithUUID:(NSString *)uuid
             major:(NSNumber *)major
             minor:(NSNumber *)minor
         proximity:(CLProximity)proximity
       friendEmail:(NSString *)friendEmail
               tag:(NSString *)tag
{
    T_DONTCARE();
    if (self = [super initWithUUID:uuid
                             major:major
                             minor:minor
                         proximity:proximity]) {
        self.friendEmail = friendEmail;
        self.tag = tag;
    }
    return self;
}

- (NSDictionary *)dictRepresentation
{
    T_DONTCARE();
    NSMutableDictionary *dict = (NSMutableDictionary *) [super dictRepresentation];
    [dict setString:self.friendEmail forKey:@"friendEmail"];
    [dict setString:[MCTUtils isEmptyOrWhitespaceString:self.tag] ? @"" : self.tag forKey:@"tag"];
    return dict;
}

@end