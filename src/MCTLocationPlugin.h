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

#import "MCTCallReceiver.h"
#import "MCTConfigProvider.h"
#import "MCTIntentFramework.h"
#import "MCTPlugin.h"
#import "MCTLocationStore.h"

#define MCT_LOCATION_FACTOR 1000000
#define MCT_LOCATION_TIMEOUT 6.66

#define MCT_CFG_KEY_CURRENTLY_TRACKING @"currentlyTrackingMyLocation"
#define MCT_CFG_KEY_TRACKING_FROM @"geoLocationTrackingFromTimeSeconds"
#define MCT_CFG_KEY_TRACKING_TILL @"geoLocationTrackingTillTimeSeconds"
#define MCT_CFG_KEY_TRACKING_DAYS @"geoLocationTrackingDays"
#define MCT_CFG_KEY_GPS_BATTERY   @"useGPSWhileOnBattery"
#define MCT_CFG_KEY_GPS_CHARGING  @"useGPSWhileCharging"

typedef NS_ENUM(int, MCTLocationErrorStatus) {
    kMCTLocationErrorStatusInvisible = 1,
    kMCTLocationErrorStatusTrackingPolicy = 2,
    kMCTLocationErrorStatusAuthorizationDenied = 3,
    kMCTLocationErrorStatusAuthorizationOnlyWhenInUse = 4,
    kMCTLocationErrorStatusAuthorizationRestricted = 5,
};

@interface MCTLocationPlugin : MCTPlugin <MCT_com_mobicage_capi_location_IClientRPC, IMCTIntentReceiver,
    CLLocationManagerDelegate, CBCentralManagerDelegate>

@property (nonatomic, strong) MCTLocationStore *store;

- (void)requestBeaconRegions;
- (void)requestMyLocationWithGPS:(BOOL)gps;
- (void)requestMyLocationWithGPS:(BOOL)gps timeout:(NSTimeInterval)timeout;
- (void)requestLocationOfFriend:(NSString *)friendEmail;
- (void)requestLocationOfAllFriends;
- (void)notifyBeaconInReachWithUUID:(NSString *)uuid
                              major:(NSNumber *)major
                              minor:(NSNumber *)minor
                          proximity:(CLProximity)proximity
                            doCheck:(BOOL)doCheck __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
- (NSArray *)beaconsInReachWithFriendEmail:(NSString *)friendEmail; // returns array of dicts
- (void)addBeaconWithoutOwner:(NSString *)beaconKey;

@end