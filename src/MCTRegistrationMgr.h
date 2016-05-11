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
#import <CoreBluetooth/CoreBluetooth.h>

#import "MCTIntentFramework.h"
#import "MCTPreRegistrationInfo.h"

#define MCT_REGISTRATION_BEACON_REGIONS @"registration_beacon_regions"
#define MCT_REGISTRATION_DISCOVERED_BEACONS @"registration_discovered_beacons"


@interface MCTRegistrationMgr : NSObject<CLLocationManagerDelegate, CBCentralManagerDelegate, IMCTIntentReceiver>

@property (nonatomic, strong) NSMutableDictionary *beacons;

+ (BOOL)isRegistered;
+ (BOOL)areTermsOfServiceAccepted;
+ (BOOL)isLocationUsageShown;
+ (BOOL)isPushNotificationsShown;
+ (NSString *)installationId;
+ (MCTPreRegistrationInfo *)preRegistrationInfo;
+ (void)sendInstallationId;
+ (void)sendRegistrationStep:(NSString *)step;
+ (void)sendRegistrationStep:(NSString *)step withPostValues:(NSDictionary *)postValues;

@end