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
#import "MCTBeaconDiscoveredResponseHandler.h"
#import "MCTLocationPlugin.h"
#import "MCTTransferObjects.h"

#define PICKLE_CLASS_VERSION 1
#define PICKLE_UUID_KEY @"uuid"
#define PICKLE_MAJOR_KEY @"major"
#define PICKLE_MINOR_KEY @"minor"
#define PICKLE_PROXIMITY_KEY @"proximity"

@implementation MCTBeaconDiscoveredResponseHandler


+ (MCTBeaconDiscoveredResponseHandler *)responseHandlerWithUUID:(NSString *)uuid
                                                          major:(NSNumber *)major
                                                          minor:(NSNumber *)minor
                                                      proximity:(CLProximity)proximity
{
    MCTBeaconDiscoveredResponseHandler *responseHandler = [[MCTBeaconDiscoveredResponseHandler alloc] init];
    responseHandler.uuid = uuid;
    responseHandler.major = major;
    responseHandler.minor = minor;
    responseHandler.proximity = proximity;
    return responseHandler;
}

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for BeaconDiscovered request: %@", error);
    NSString *beaconName = [MCTUtils nameForBeaconWithMajor:self.major minor:self.minor];
    [[[MCTComponentFramework locationPlugin] store] deleteBeaconDiscoveryWithUUID:self.uuid name:beaconName];
}

- (void)handleResult:(MCT_com_mobicage_to_location_BeaconDiscoveredResponseTO *)result
{
    T_BIZZ();
    LOG(@"Result received for BeaconDiscovered request");
    MCTLocationPlugin *plugin = [MCTComponentFramework locationPlugin];
    NSString *beaconName = [MCTUtils nameForBeaconWithMajor:self.major minor:self.minor];
    if (result.friend_email != nil){
        [plugin.store updateBeaconDiscoveryWithUUID:self.uuid
                                               name:beaconName
                                        friendEmail:result.friend_email
                                                tag:result.tag];
        dispatch_async(dispatch_get_main_queue(), ^{
            [plugin notifyBeaconInReachWithUUID:self.uuid
                                          major:self.major
                                          minor:self.minor
                                      proximity:self.proximity
                                        doCheck:YES];
        });
    } else {
        LOG(@"Beacon not coupled yet");
        [plugin.store deleteBeaconDiscoveryWithUUID:self.uuid name:beaconName];
        dispatch_async(dispatch_get_main_queue(), ^{
            [plugin addBeaconWithoutOwner:[MCTUtils keyForBeaconWithUUID:self.uuid name:beaconName]];
        });
    }
}

- (id)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    if (self = [super initWithCoder:coder]) {
        self.uuid = [coder decodeObjectForKey:PICKLE_UUID_KEY];
        self.major = [coder decodeObjectForKey:PICKLE_MAJOR_KEY];
        self.minor = [coder decodeObjectForKey:PICKLE_MINOR_KEY];
        self.proximity = [coder decodeIntegerForKey:PICKLE_PROXIMITY_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
    [coder encodeObject:self.uuid forKey:PICKLE_UUID_KEY];
    [coder encodeObject:self.major forKey:PICKLE_MAJOR_KEY];
    [coder encodeObject:self.minor forKey:PICKLE_MINOR_KEY];
    [coder encodeInteger:self.proximity forKey:PICKLE_PROXIMITY_KEY];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end