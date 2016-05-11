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

#import "MCT_CS_API.h"
#import "MCTActivity.h"
#import "MCTActivityPlugin.h"
#import "MCTBeaconDiscoveredResponseHandler.h"
#import "MCTBeaconProximity.h"
#import "MCTCache.h"
#import "MCTComponentFramework.h"
#import "MCTDefaultResponseHandler.h"
#import "MCTGetBeaconRegionsRH.h"
#import "MCTIntent.h"
#import "MCTFriendsPlugin.h"
#import "MCTLocationPlugin.h"
#import "MCTLocationStore.h"
#import "MCTOperation.h"
#import "MCTUtils.h"


@interface MCT_com_mobicage_to_location_GetLocationErrorTO (MCTLocationPlugin)

+ (MCT_com_mobicage_to_location_GetLocationErrorTO *)errorWithStatus:(MCTlong)status
                                                             message:(NSString *)message;

@end


@implementation MCT_com_mobicage_to_location_GetLocationErrorTO (MCTLocationPlugin)

+ (MCT_com_mobicage_to_location_GetLocationErrorTO *)errorWithStatus:(MCTlong)status
                                                             message:(NSString *)message
{
    MCT_com_mobicage_to_location_GetLocationErrorTO *error =
    [MCT_com_mobicage_to_location_GetLocationErrorTO transferObject];
    error.status = status;
    error.message = message;
    return error;
}

@end

#pragma mark -

@interface MCTTrackerInfo : NSObject <IJSONable>

+ (instancetype)trackerInfoWithFriend:(NSString *)friend
                                until:(MCTlong)until
                               target:(MCTlong)target
                       distanceFilter:(MCTlong)distanceFilter;

- (id)initWithDict:(NSDictionary *)dict;
- (NSDictionary *)dictRepresentation;

@property (nonatomic, copy) NSString *friend;
@property (nonatomic, assign) MCTlong until;
@property (nonatomic, assign) MCTlong target;
@property (nonatomic, assign) MCTlong distanceFilter;

@end

@implementation MCTTrackerInfo

+ (instancetype)trackerInfoWithFriend:(NSString *)friend
                                until:(MCTlong)until
                               target:(MCTlong)target
                       distanceFilter:(MCTlong)distanceFilter
{
    T_DONTCARE();
    MCTTrackerInfo *info = [[MCTTrackerInfo alloc] init];
    info.friend = friend;
    info.until = until;
    info.target = target;
    info.distanceFilter = distanceFilter;
    return info;
}

- (id)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.friend = [dict stringForKey:@"friend"];
        self.until = [dict longForKey:@"until"];
        self.target = [dict longForKey:@"target"];
        self.distanceFilter = [dict longForKey:@"distance_filter"];
    }
    return self;
}

- (NSDictionary *)dictRepresentation
{
    return @{@"friend": self.friend,
             @"until": @(self.until),
             @"target": @(self.target),
             @"distance_filter": @(self.distanceFilter)};
}

@end

#pragma mark -


@interface MCTBeaconRangeInfo : NSObject

@property (nonatomic) MCTlong rangeTimestamp;
@property (nonatomic, strong) CLBeacon *beacon;

@end

@implementation MCTBeaconRangeInfo


- (void)dealloc
{
    self.beacon = nil;
}

- (NSString *)description
{
    if (MCT_DEBUG_LOGGING) {
        return [NSString stringWithFormat:@"%lldms ago: %@",
                [MCTUtils currentTimeMillis] - self.rangeTimestamp,
                [MCTUtils stringFromBeacon:self.beacon]];
    } else {
        return [super description];
    }
}

@end


#pragma mark -


@interface MCTLocationPlugin ()

@property (nonatomic, strong) MCTConfigProvider *cfgProvider;
@property (nonatomic) MCTlong trackingFrom;
@property (nonatomic) MCTlong trackingTill;
@property (nonatomic) MCTlong trackingDays;
@property (nonatomic) BOOL gpsWhileUnplugged;
@property (nonatomic) BOOL gpsWhileCharging;
@property (nonatomic, strong) NSMutableArray *locationRecipients;
@property (nonatomic, strong) NSMutableDictionary *trackingTimers;
@property (nonatomic, strong) CLLocationManager *locationMgr;
@property (nonatomic, strong) CLLocationManager *trackingMgr;
@property (nonatomic, strong) CLLocation *bestLocation;
@property (nonatomic) BOOL retrievingLocation;
@property (nonatomic) BOOL mocaProximityEnabled;
@property (nonatomic) UIBackgroundTaskIdentifier bgTask;

@property (nonatomic) BOOL gpsRequiredToGetLocation;
@property (nonatomic) MCTlong locationFixStartTime;

// mapping between beaconKey and a list with last 3 ranged MCTBeaconRangeInfos
@property (nonatomic, strong) NSMutableDictionary *last3BeaconRanges;

// beacons (with a friend as owner) currently in reach: mapping between beaconKey and MCTDiscoveredBeaconProximity
@property (nonatomic, strong) NSMutableDictionary *beaconsInProximity;

// beacons (without owner, or owner is not friend) currently in reach: mapping between beaconKey and MCTBeaconProximity
@property (nonatomic, strong) NSMutableDictionary *beaconsInProximityPending;

// cache with discovered beacons without owner. entries time out after 1 hour.
@property (nonatomic, strong) MCTCache *cachedBeaconsWithoutOwner;

@property (nonatomic, strong) CBCentralManager *cbCentralManager;
@property (nonatomic, strong) NSArray *regionsToMonitor;

- (MCT_com_mobicage_to_location_GetLocationErrorTO *)checkTrackingPolicyWithIsHighPrio:(BOOL)isHighPrio;
- (void)createActivityWithLogLocationsRequest:(MCT_com_mobicage_to_activity_LogLocationsRequestTO *)request;

@end


@implementation MCTLocationPlugin






#pragma mark -

- (id)init
{
    T_BIZZ();
    if (self = [super init]) {
        self.store = [[MCTLocationStore alloc] init];
        self.last3BeaconRanges = [NSMutableDictionary dictionary];
        self.beaconsInProximity = [NSMutableDictionary dictionary];
        self.beaconsInProximityPending = [NSMutableDictionary dictionary];
        self.cachedBeaconsWithoutOwner = [[MCTCache alloc] initWithTimeout:3600];
        self.regionsToMonitor = @[];
        self.cbCentralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                      queue:nil
                                                                    options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
        self.bgTask = UIBackgroundTaskInvalid;

        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_BEACON_REGIONS_UPDATED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_BEACON_IN_REACH];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_BEACON_OUT_OF_REACH];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_LOCATION_START_AUTOMATIC_DETECTION];

        [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                       forIntentActions:@[kINTENT_FRIEND_ADDED,
                                                                          kINTENT_FRIEND_REMOVED,
                                                                          kINTENT_LOCATION_START_AUTOMATIC_DETECTION,
                                                                          kINTENT_DO_BEACON_REGIONS_RETRIEVAL,
                                                                          kINTENT_BEACON_REGIONS_UPDATED]
                                                                onQueue:[MCTComponentFramework mainQueue]];

        self.cfgProvider = [MCTComponentFramework configProvider];

        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        self.trackingFrom = [[formatter numberFromString:[self.cfgProvider stringForKey:MCT_CFG_KEY_TRACKING_FROM]] longLongValue];
        self.trackingTill = [[formatter numberFromString:[self.cfgProvider stringForKey:MCT_CFG_KEY_TRACKING_TILL]] longLongValue];
        self.trackingDays = [[formatter numberFromString:[self.cfgProvider stringForKey:MCT_CFG_KEY_TRACKING_DAYS]] longLongValue];
        self.gpsWhileUnplugged = [[self.cfgProvider stringForKey:MCT_CFG_KEY_GPS_BATTERY] boolValue];
        self.gpsWhileCharging = [[self.cfgProvider stringForKey:MCT_CFG_KEY_GPS_CHARGING] boolValue];

        [[UIDevice currentDevice] setBatteryMonitoringEnabled:(self.gpsWhileUnplugged || self.gpsWhileCharging)];

        [self performSelectorOnMainThread:@selector(initLocationMgr) withObject:nil waitUntilDone:NO];
    }

    return self;
}

- (void)initLocationMgr
{
    T_UI();
    self.locationMgr = [[CLLocationManager alloc] init];
    self.locationMgr.delegate = self;
    self.locationMgr.distanceFilter = 1.0f;

    NSDictionary *currentTrackersDict = [[self.cfgProvider stringForKey:MCT_CFG_KEY_CURRENTLY_TRACKING] MCT_JSONValue];
    if (currentTrackersDict == nil)
        return;

    NSArray *currentTrackers = currentTrackersDict[@"trackers"];
    if ([currentTrackers count]) {
        self.trackingTimers = [NSMutableDictionary dictionary];

        for (NSDictionary *dict in currentTrackers) {
            MCTTrackerInfo *info = [[MCTTrackerInfo alloc] initWithDict:dict];
            MCTlong timeout = info.until - [MCTUtils currentServerTime];
            if (timeout > 0) {
                NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                                  target:self
                                                                selector:@selector(onTrackerTimeFired:)
                                                                userInfo:info
                                                                 repeats:NO];
                self.trackingTimers[[self trackerKeyWithFriend:info.friend target:info.target]] = timer;
            }
        }
        [self restartTracking];
    }
}

- (void)startUpdatingLocationWithTimeout:(NSTimeInterval)timeout
{
    T_UI();
    // Start a new background task
    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"-[MCTLocationPlugin startUpdatingLocation]"
                                                               expirationHandler:^{
                                                                   T_UI();
                                                                   LOG(@"In expirationHandler of -[MCTLocationPlugin startUpdatingLocation]");
                                                                   [[MCTComponentFramework locationPlugin] endBackgroundTask];
                                                               }];

    self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest;

    if (self.gpsRequiredToGetLocation) {
        self.locationMgr.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    } else {
        if (self.gpsWhileCharging || self.gpsWhileUnplugged) {
            switch ([UIDevice currentDevice].batteryState) {
                case UIDeviceBatteryStateUnplugged:
                    if (self.gpsWhileUnplugged)
                        self.locationMgr.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
                    break;
                case UIDeviceBatteryStateCharging:
                case UIDeviceBatteryStateFull:
                    if (self.gpsWhileCharging)
                        self.locationMgr.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
                    break;
                default:
                    LOG(@"Battery state UNKNOWN");
                    break;
            }
        }
    }

    self.locationFixStartTime = [MCTUtils currentServerTime];
    [self.locationMgr startUpdatingLocation];
    [self performSelector:@selector(stopUpdatingLocation) withObject:nil afterDelay:timeout];
}

- (void)stopUpdatingLocation
{
    T_UI();
    [self.locationMgr stopUpdatingLocation];
    self.locationFixStartTime = 0;

    // cancel any posted performSelector calls
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation) object:nil];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_BACKLOG_FINISHED
                                                            onQueue:[MCTComponentFramework mainQueue]];
    if (self.bestLocation) {
        CLLocation *location = [self.bestLocation copy];
        NSArray *recipients = [self.locationRecipients copy];
        MCT_RELEASE(self.bestLocation);
        MCT_RELEASE(self.locationRecipients);
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            T_BIZZ();
            self.retrievingLocation = NO;
            MCT_com_mobicage_to_activity_LogLocationsRequestTO *request = [self sendLocation:location
                                                                                toRecipients:recipients];
            if (request) {
                [self createActivityWithLogLocationsRequest:request];
            }
        }];
    } else {
        LOG(@"Could not find my location within %f seconds", MCT_LOCATION_TIMEOUT);
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            T_BIZZ();
            [self sendLocationError];
        }];
    }
}

#pragma mark - Location tracking

- (NSString *)trackerKeyWithFriend:(NSString *)friend
                            target:(MCTlong)target
{
    T_DONTCARE();
    return [NSString stringWithFormat:@"%lld - %@", target, friend];
}

- (void)startTrackingMyLocationWithDistanceFilter:(MCTlong)distanceFilter
                                            until:(MCTlong)until
                                           target:(MCTlong)target
                                           friend:(NSString *)friend
{
    T_UI();
    NSString *timerKey = [self trackerKeyWithFriend:friend target:target];
    NSTimer *timer = self.trackingTimers[timerKey];
    if (timer != nil) {
        [timer invalidate];
        [self.trackingTimers removeObjectForKey:timerKey];
    }

    MCTlong timeout = until - [MCTUtils currentServerTime];
    if (timeout <= 0) {
        LOG(@"%@ stops tracking my location", friend);
        if (timer == nil) {
            // Nothing changes
            return;
        }
    } else {
        if (timer != nil) {
            MCTTrackerInfo *info = timer.userInfo;
            until = MAX(until, info.until);
            distanceFilter = MIN(distanceFilter, info.distanceFilter);
        }
        if (self.trackingTimers == nil) {
            self.trackingTimers = [NSMutableDictionary dictionary];
        }

        MCTTrackerInfo *info = [MCTTrackerInfo trackerInfoWithFriend:friend
                                                               until:until
                                                              target:target
                                                      distanceFilter:distanceFilter];
        self.trackingTimers[timerKey] = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                                         target:self
                                                                       selector:@selector(onTrackerTimeFired:)
                                                                       userInfo:info
                                                                        repeats:NO];

        LOG(@"%@ is tracking my location until %@", friend, [NSDate dateWithTimeIntervalSince1970:until]);
    }

    [self storeTrackers];
    [self restartTracking];
}

- (void)storeTrackers
{
    T_UI();
    NSUInteger c = [self.trackingTimers count];
    if (c == 0) {
        [self.cfgProvider deleteStringForKey:MCT_CFG_KEY_CURRENTLY_TRACKING];
    } else {
        NSMutableArray *trackers = [NSMutableArray arrayWithCapacity:[self.trackingTimers count]];
        for (NSTimer *timer in [self.trackingTimers allValues]) {
            MCTTrackerInfo *info = timer.userInfo;
            [trackers addObject:[info dictRepresentation]];
        }
        [self.cfgProvider setString:[@{@"trackers": trackers} MCT_JSONRepresentation]
                             forKey:MCT_CFG_KEY_CURRENTLY_TRACKING];
    }
}

- (void)restartTracking
{
    T_UI();
    if ([self.trackingTimers count] == 0) {
        LOG(@"Stopping location tracking");
        [self.trackingMgr stopMonitoringSignificantLocationChanges];
        [self.trackingMgr stopUpdatingLocation];
        MCT_RELEASE(self.trackingMgr);
        return;
    }

    MCTlong prevDistanceFilter;
    if (self.trackingMgr) {
        prevDistanceFilter = self.trackingMgr.distanceFilter;
    } else {
        self.trackingMgr = [[CLLocationManager alloc] init];
        self.trackingMgr.delegate = self;
        prevDistanceFilter = -1;
    }

    MCTlong newDistanceFilter = INT_MAX;
    for (NSTimer *timer in [self.trackingTimers allValues]) {
        MCTTrackerInfo *info = timer.userInfo;
        newDistanceFilter = MIN(newDistanceFilter, info.distanceFilter);
    }

    self.trackingMgr.distanceFilter = newDistanceFilter;

    if (newDistanceFilter < 500) {
        if (prevDistanceFilter < 0) {
            // we just started tracking now
            [self.trackingMgr startUpdatingLocation];
        } else if (prevDistanceFilter >= 500) {
            [self.trackingMgr stopMonitoringSignificantLocationChanges];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.trackingMgr startUpdatingLocation];
            });
        } // else: we were already updating location
    } else {
        // This method is way better for the battery
        if (prevDistanceFilter < 0) {
            // we just started tracking now
            [self.trackingMgr startMonitoringSignificantLocationChanges];
        } else if (prevDistanceFilter < 500) {
            [self.trackingMgr stopUpdatingLocation];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.trackingMgr startMonitoringSignificantLocationChanges];
            });
        } // else: we were aleady monitoring significant location changes
    }
}

- (void)onTrackerTimeFired:(NSTimer *)timer
{
    T_UI();
    MCTTrackerInfo *info = timer.userInfo;
    NSString *timerKey = [self trackerKeyWithFriend:info.friend target:info.target];
    NSTimer *trackingTimer = [self.trackingTimers objectForKey:timerKey];
    if (timer != trackingTimer) {
        ERROR(@"Weird... tracking timer is not found: %@ = %@", timerKey, trackingTimer);
        return;
    }

    [self.trackingTimers removeObjectForKey:timerKey];
    [self storeTrackers];
    [self restartTracking];
}

#pragma mark - Location fix

- (void)endBackgroundTask
{
    T_UI();
    if (self.bgTask != UIBackgroundTaskInvalid) {
        LOG(@"Ending MCTLocationPlugin background task: %d", self.bgTask);
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}

- (void)requestMyLocationWithGPS:(BOOL)gps
{
    T_BIZZ();
    [self requestMyLocationWithGPS:gps timeout:MCT_LOCATION_TIMEOUT];
}

- (void)requestMyLocationWithGPS:(BOOL)gps timeout:(NSTimeInterval)timeout
{
    T_BIZZ();
    LOG(@"Retrieving my location");
    if (!self.retrievingLocation) {
        self.gpsRequiredToGetLocation = gps;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startUpdatingLocationWithTimeout:timeout];
        });
    }
    self.retrievingLocation = YES;
}

- (void)requestLocationOfFriend:(NSString *)friendEmail
{
    T_BIZZ();
    MCT_com_mobicage_to_location_GetFriendLocationRequestTO *request = [MCT_com_mobicage_to_location_GetFriendLocationRequestTO transferObject];
    request.friend = friendEmail;

    [MCT_com_mobicage_api_location CS_API_getFriendLocationWithResponseHandler:[MCTDefaultResponseHandler defaultResponseHandler]
                                                                    andRequest:request];
}

- (void)requestLocationOfAllFriends
{
    T_BIZZ();
    [MCT_com_mobicage_api_location CS_API_getFriendLocationsWithResponseHandler:[MCTDefaultResponseHandler defaultResponseHandler]
                                                                     andRequest:[MCT_com_mobicage_to_location_GetFriendsLocationRequestTO transferObject]];
}


/*
 1. check authorizationStatus
 2. if not highPrio:  # high_prio requests actually mean: ignore tracking policy (e.g. for emergency calls))
 2.1 check invisible mode
 2.2 check tracking policy
 */
- (MCT_com_mobicage_to_location_GetLocationErrorTO *)checkTrackingPolicyWithIsHighPrio:(BOOL)isHighPrio
{
    T_BACKLOG();
    // 1. check authorizationStatus
    CLAuthorizationStatus locationAuthorizationStatus = [CLLocationManager authorizationStatus];

    if (locationAuthorizationStatus == kCLAuthorizationStatusDenied) {
        return [MCT_com_mobicage_to_location_GetLocationErrorTO errorWithStatus:kMCTLocationErrorStatusAuthorizationDenied
                                                                        message:@"authorizationStatus is kCLAuthorizationStatusDenied"];
    }
    if (locationAuthorizationStatus == kCLAuthorizationStatusRestricted) {
        return [MCT_com_mobicage_to_location_GetLocationErrorTO errorWithStatus:kMCTLocationErrorStatusAuthorizationRestricted
                                                                        message:@"authorizationStatus is kCLAuthorizationStatusRestricted"];
    }
    IF_IOS8_OR_GREATER({
        if (locationAuthorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse
            && [UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
            return [MCT_com_mobicage_to_location_GetLocationErrorTO errorWithStatus:kMCTLocationErrorStatusAuthorizationOnlyWhenInUse
                                                                            message:@"authorizationStatus is kCLAuthorizationStatusAuthorizedWhenInUse"];
        }
    });

    // 2. if not highPrio:
    if (!isHighPrio) {
        // 2.1 check invisible mode
        if ([[NSUserDefaults standardUserDefaults] boolForKey:MCT_SETTINGS_INVISIBLE]) {
            return [MCT_com_mobicage_to_location_GetLocationErrorTO errorWithStatus:kMCTLocationErrorStatusInvisible
                                                                            message:@"Tracking is disabled (invisible_mode is ON)"];
        }

        // 2.2 check tracking policy
        NSDate *now = [NSDate date];
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        int units = NSWeekdayCalendarUnit | NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit;
        NSDateComponents *comps = [cal components:units fromDate:now];
        // convert weekday starting from sunday to starting from monday
        int weekday = (([comps weekday] + 5) % 7) + 1;

        if (!IS_FLAG_SET(self.trackingDays, (int) pow(2, weekday - 1))) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEEE"];
            NSString *errorMsg = [NSString stringWithFormat:@"Tracking is disabled on %@", [formatter stringFromDate:now]];
            return [MCT_com_mobicage_to_location_GetLocationErrorTO errorWithStatus:kMCTLocationErrorStatusTrackingPolicy
                                                                            message:errorMsg];

        }

        MCTlong secs = 3600 * [comps hour] +  60 * [comps minute] + [comps second];
        if (secs < self.trackingFrom || secs > self.trackingTill) {
            return [MCT_com_mobicage_to_location_GetLocationErrorTO errorWithStatus:kMCTLocationErrorStatusTrackingPolicy
                                                                            message:@"Tracking is disabled at this time of the day"];
        }
    }
    
    return nil;
}

#pragma mark -
#pragma mark Server to clients calls

- (MCT_com_mobicage_to_location_GetLocationResponseTO *)SC_API_getLocationWithRequest:(MCT_com_mobicage_to_location_GetLocationRequestTO *)request
{
    T_BACKLOG();
    MCT_com_mobicage_to_location_GetLocationResponseTO *response = [MCT_com_mobicage_to_location_GetLocationResponseTO transferObject];
    if ((response.error = [self checkTrackingPolicyWithIsHighPrio:request.high_prio]) != nil) {
        return response;
    }

    MCT_com_mobicage_to_activity_LogLocationRecipientTO *recipient =
    [MCT_com_mobicage_to_activity_LogLocationRecipientTO transferObject];
    recipient.friend = request.friend;
    recipient.target = request.target;

    if (self.locationRecipients == nil) {
        self.locationRecipients = [NSMutableArray array];
    }
    [self.locationRecipients addObject:recipient];

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        [self requestMyLocationWithGPS:NO];
    }];

    return [MCT_com_mobicage_to_location_GetLocationResponseTO transferObject];
}

- (MCT_com_mobicage_to_location_TrackLocationResponseTO *)SC_API_trackLocationWithRequest:(MCT_com_mobicage_to_location_TrackLocationRequestTO *)request
{
    T_BACKLOG();
    dispatch_async(dispatch_get_main_queue(), ^{
        T_UI();
        [self startTrackingMyLocationWithDistanceFilter:request.distance_filter
                                                  until:request.until
                                                 target:request.target
                                                 friend:request.friend];
    });

    return [MCT_com_mobicage_to_location_TrackLocationResponseTO transferObject];
}

- (MCT_com_mobicage_to_location_LocationResultResponseTO *)SC_API_locationResultWithRequest:(MCT_com_mobicage_to_location_LocationResultRequestTO *)request
{
    T_BACKLOG();
    LOG(@"Received location of %@", request.friend);
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_LOCATION_RETRIEVED];
    [intent setLong:request.location.accuracy forKey:@"accuracy"];
    [intent setLong:request.location.latitude forKey:@"latitude"];
    [intent setLong:request.location.longitude forKey:@"longitude"];
    [intent setLong:request.location.timestamp forKey:@"timestamp"];
    [intent setString:request.friend forKey:@"friend"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];

    return [MCT_com_mobicage_to_location_LocationResultResponseTO transferObject];
}

- (MCT_com_mobicage_to_location_DeleteBeaconDiscoveryResponseTO *)SC_API_deleteBeaconDiscoveryWithRequest:(MCT_com_mobicage_to_location_DeleteBeaconDiscoveryRequestTO *)request
{
    T_BACKLOG();
    LOG(@"Received delete beaconDiscovery with uuid: %@ name: %@", request.uuid, request.name);
    [self.store deleteBeaconDiscoveryWithUUID:request.uuid name:request.name];

    NSString *beaconKey = [MCTUtils keyForBeaconWithUUID:request.uuid name:request.name];
    [self removeBeaconFromCaches:beaconKey];

    return [MCT_com_mobicage_to_location_DeleteBeaconDiscoveryResponseTO transferObject];
}

- (MCT_com_mobicage_to_beacon_UpdateBeaconRegionsResponseTO *)SC_API_updateBeaconRegionsWithRequest:(MCT_com_mobicage_to_beacon_UpdateBeaconRegionsRequestTO *)request
{
    T_BACKLOG();
    [self requestBeaconRegions];
    return [MCT_com_mobicage_to_beacon_UpdateBeaconRegionsResponseTO transferObject];
}

#pragma mark -
#pragma mark Client to server calls

- (MCT_com_mobicage_to_activity_LogLocationsRequestTO *)sendLocation:(CLLocation *)myLocation toRecipients:(NSArray *)recipients
{
    T_BIZZ();
    MCT_com_mobicage_to_activity_LocationRecordTO *record = [MCT_com_mobicage_to_activity_LocationRecordTO transferObject];
    record.timestamp = (MCTlong) [myLocation.timestamp timeIntervalSince1970];
    record.geoPoint = [MCT_com_mobicage_to_activity_GeoPointTO transferObject];
    record.geoPoint.accuracy = myLocation.horizontalAccuracy;
    record.geoPoint.latitude = myLocation.coordinate.latitude * MCT_LOCATION_FACTOR;
    record.geoPoint.longitude = myLocation.coordinate.longitude * MCT_LOCATION_FACTOR;

    MCTFriendsPlugin *friendsPlugin = [MCTComponentFramework friendsPlugin];
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_LOCATION_RETRIEVED];
    [intent setLong:myLocation.altitude * MCT_LOCATION_FACTOR forKey:@"altitude"];
    [intent setLong:myLocation.verticalAccuracy forKey:@"vertical_accuracy"];
    [intent setLong:record.geoPoint.accuracy forKey:@"accuracy"];
    [intent setLong:record.geoPoint.latitude forKey:@"latitude"];
    [intent setLong:record.geoPoint.longitude forKey:@"longitude"];
    [intent setLong:record.timestamp forKey:@"timestamp"];
    [intent setString:[friendsPlugin myEmail] forKey:@"friend"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];

    if ([recipients count] == 0)
        return nil;

    MCT_com_mobicage_to_activity_LogLocationsRequestTO *request = [MCT_com_mobicage_to_activity_LogLocationsRequestTO transferObject];
    request.recipients = recipients;
    request.records = @[record];

    [MCT_com_mobicage_api_activity CS_API_logLocationsWithResponseHandler:[MCTDefaultResponseHandler defaultResponseHandler]
                                                               andRequest:request];
    return request;
}

- (void)sendLocationError
{
    T_BIZZ();

    self.retrievingLocation = NO;

    if (self.locationRecipients && self.locationRecipients.count > 0) {
        // Only send error if there is someone interested in it
        // E.g. not in case i locally refuse to let Rogerthat access location info and I open MCTMapVC
        MCT_com_mobicage_to_activity_LogLocationsRequestTO *request = [MCT_com_mobicage_to_activity_LogLocationsRequestTO transferObject];
        request.recipients = self.locationRecipients;
        request.records = MCTEmptyArray;
        [MCT_com_mobicage_api_activity CS_API_logLocationsWithResponseHandler:[MCTDefaultResponseHandler defaultResponseHandler]
                                                                   andRequest:request];
    }

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_LOCATION_RETRIEVING_FAILED];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];

    MCT_RELEASE(self.locationRecipients);
}

- (void)createActivityWithLogLocationsRequest:(MCT_com_mobicage_to_activity_LogLocationsRequestTO *)request
{
    T_BIZZ();
    MCTActivityPlugin *activityPlugin = (MCTActivityPlugin *) [MCTComponentFramework pluginForClass:[MCTActivityPlugin class]];
    MCTFriendsPlugin *friendsPlugin = (MCTFriendsPlugin *) [MCTComponentFramework pluginForClass:[MCTFriendsPlugin class]];

    MCT_com_mobicage_to_activity_LocationRecordTO *record = [request.records objectAtIndex:0];

    for (MCT_com_mobicage_to_activity_LogLocationRecipientTO *recipient in request.recipients) {
        MCTActivity *activity = [MCTActivity activity];
        activity.type = MCTActivityLocationSent;
        activity.reference = recipient.friend;
        activity.friendReference = recipient.friend;

        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setString:[friendsPlugin friendDisplayNameByEmail:recipient.friend] forKey:MCT_ACTIVITY_FRIEND_NAME];
        [parameters setLong:record.geoPoint.accuracy forKey:MCT_ACTIVITY_LOCATION_ACCURACY];
        [parameters setLong:record.geoPoint.latitude forKey:MCT_ACTIVITY_LOCATION_LATITUDE];
        [parameters setLong:record.geoPoint.longitude forKey:MCT_ACTIVITY_LOCATION_LONGITUDE];
        activity.parameters = parameters;

        [activityPlugin.store saveActivity:activity];
    }
}

- (void)requestBeaconRegions
{
    T_DONTCARE();
    MCT_com_mobicage_to_beacon_GetBeaconRegionsRequestTO *request =
        [MCT_com_mobicage_to_beacon_GetBeaconRegionsRequestTO transferObject];

    MCTGetBeaconRegionsRH *responseHandler = [[MCTGetBeaconRegionsRH alloc] init];

    [MCT_com_mobicage_api_location CS_API_getBeaconRegionsWithResponseHandler:responseHandler
                                                                   andRequest:request];
}

#pragma mark -

- (void)processSettings:(MCT_com_mobicage_to_system_SettingsTO *)settings
{
    T_BACKLOG();
    HERE();
    if ([[NSUserDefaults standardUserDefaults] boolForKey:MCT_SETTINGS_INVISIBLE] == settings.geoLocationTracking) {
        // Settings changed

        [[NSUserDefaults standardUserDefaults] setBool:!settings.geoLocationTracking forKey:MCT_SETTINGS_INVISIBLE];

        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_SETTINGS_UPDATED];
        [intent setBool:YES forKey:@"invisible_mode_changed"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    }

    self.trackingDays = settings.geoLocationTrackingDays;
    [self.cfgProvider setString:[NSString stringWithFormat:@"%lld", self.trackingDays]
                         forKey:MCT_CFG_KEY_TRACKING_DAYS];

    if ([settings.geoLocationTrackingTimeslot count] == 2) {
        self.trackingFrom = [[settings.geoLocationTrackingTimeslot objectAtIndex:0] longLongValue];
        self.trackingTill = [[settings.geoLocationTrackingTimeslot objectAtIndex:1] longLongValue];

        [self.cfgProvider setString:[NSString stringWithFormat:@"%lld", self.trackingFrom]
                             forKey:MCT_CFG_KEY_TRACKING_FROM];
        [self.cfgProvider setString:[NSString stringWithFormat:@"%lld", self.trackingTill]
                             forKey:MCT_CFG_KEY_TRACKING_TILL];
    } else {
        ERROR(@"geoLocationTrackingTimeslot.length != 2");
    }

    self.gpsWhileUnplugged = settings.useGPSBattery;
    self.gpsWhileCharging = settings.useGPSCharging;

    [[UIDevice currentDevice] setBatteryMonitoringEnabled:(self.gpsWhileUnplugged || self.gpsWhileCharging)];

    [self.cfgProvider setString:[NSString stringWithFormat:@"%d", self.gpsWhileUnplugged]
                         forKey:MCT_CFG_KEY_GPS_BATTERY];
    [self.cfgProvider setString:[NSString stringWithFormat:@"%d", self.gpsWhileCharging]
                         forKey:MCT_CFG_KEY_GPS_CHARGING];
}


#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    T_UI();
    if (central != self.cbCentralManager) {
        return;
    }

    [self setBeaconRegionsToMonitor:self.regionsToMonitor];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations
{
    T_UI();
    CLLocation *newLocation = [locations lastObject];
    NSTimeInterval secondsAgo = fabs([newLocation.timestamp timeIntervalSinceNow]);
    LOG(@"newLocation time: %@", newLocation.timestamp);
    LOG(@"newLocation age: %d seconds", (int)secondsAgo);
    LOG(@"newLocation accuracy: %f", newLocation.horizontalAccuracy);
    CLLocation *oldLocation = self.bestLocation;
    self.bestLocation = newLocation;

    if (secondsAgo > 30) {
        return; // Too old
    }

    if (manager == self.locationMgr) {
        MCTlong timeTrying = [MCTUtils currentServerTime] - self.locationFixStartTime;
        if (timeTrying < MCT_LOCATION_TIMEOUT) {
            if ((self.gpsRequiredToGetLocation && self.bestLocation.horizontalAccuracy > 50) ||
                (!self.gpsRequiredToGetLocation && self.bestLocation.horizontalAccuracy > 500)) {
                LOG(@"We might do better (trying %llds, GPS=%@). Wait at least MCT_LOCATION_TIMEOUT seconds.",
                    timeTrying, BOOLSTR(self.gpsRequiredToGetLocation));
                return;
            }
        }

        [self stopUpdatingLocation];
    } else if (manager == self.trackingMgr) {
        if (oldLocation) {
            LOG(@"Distance from previous location: %f (distanceFilter=%lld)",
                [newLocation distanceFromLocation:oldLocation], manager.distanceFilter);
        }

        NSMutableArray *recipients = [NSMutableArray array];
        for (NSTimer *timer in [self.trackingTimers allValues]) {
            MCTTrackerInfo *info = timer.userInfo;
            MCT_com_mobicage_to_activity_LogLocationRecipientTO *recipient =
                [MCT_com_mobicage_to_activity_LogLocationRecipientTO transferObject];
            recipient.friend = info.friend;
            recipient.target = info.target;
            [recipients addObject:recipient];
        }

        if ([recipients count] ==0) {
            [self restartTracking]; // stop tracking
        }

        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            T_BIZZ();
            [self sendLocation:newLocation toRecipients:recipients];
        }];
    } else {
        ERROR(@"Unexpected LocationManager: %@", manager);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    T_UI();
    LOG(@"Failed to resolve my location with error: %@", error);
}

#pragma mark -

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    T_UI();
    BEACON_HERE();
    BEACON_ERROR(@"monitoringDidFailForRegion: %@ withError: %@",
                 [MCTUtils stringFromBeaconRegion:region], error);
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    T_UI();
    BEACON_HERE();
    BEACON_ERROR(@"rangingBeaconsDidFailForRegion: %@ withError: %@",
                 [MCTUtils stringFromBeaconRegion:region], error);
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLBeaconRegion *)region
{
    T_UI();
    BEACON_HERE();
    BEACON_LOG(@"didDetermineState: %@ forRegion: %@",
               [MCTUtils stringFromCLRegionState:state],
               [MCTUtils stringFromBeaconRegion:region]);
    switch (state) {
        case CLRegionStateInside:
            [self.locationMgr startRangingBeaconsInRegion:region];
            break;
        case CLRegionStateOutside:
            [self.locationMgr stopRangingBeaconsInRegion:region];
            [self findBeaconsOutOfReachBelongingToRegion:region withRangeTimestamp:-1];
            break;
        case CLRegionStateUnknown:
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLBeaconRegion *)region
{
    T_UI();
    BEACON_HERE();
    BEACON_LOG(@"didEnterRegion: %@", [MCTUtils stringFromBeaconRegion:region]);
    [self.locationMgr startRangingBeaconsInRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLBeaconRegion *)region
{
    T_UI();
    BEACON_HERE();
    BEACON_LOG(@"didExitRegion: %@", [MCTUtils stringFromBeaconRegion:region]);
    [self.locationMgr stopRangingBeaconsInRegion:region];
    [self findBeaconsOutOfReachBelongingToRegion:region withRangeTimestamp:-1];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    T_UI();
#if MCT_DEBUG
    BEACON_LOG(@" ");
#endif
    BEACON_LOG(@"%d beacon(s) in region %@", beacons.count, region.identifier);

    MCTlong now = [MCTUtils currentTimeMillis];

    for (CLBeacon *beacon in beacons) {
        NSString *beaconKey = [MCTUtils keyForBeacon:beacon];

        if ([self.cachedBeaconsWithoutOwner objectForKey:beaconKey]) {
            continue;
        }

        NSString *beaconName = [MCTUtils nameForBeacon:beacon];
        NSString *beaconUUID = beacon.proximityUUID.UUIDString;

        // Add the beacon to the cache
        MCTBeaconRangeInfo *beaconRangeInfo = [[MCTBeaconRangeInfo alloc] init];
        beaconRangeInfo.beacon = beacon;
        beaconRangeInfo.rangeTimestamp = now;
        NSArray *lastBeacons = [self cacheBeaconRangeInfo:beaconRangeInfo
                                            withBeaconKey:beaconKey];

        BOOL isPending = [self.beaconsInProximityPending containsKey:beaconKey];

#if MCT_DEBUG
        [self logRangedBeacons:lastBeacons withRangeTimestamp:now isPending:isPending];
#endif

        // Check if we need to send a beaconDiscovered or a beaconInReach request
        BOOL alreadyDiscovered = isPending
            || [self.beaconsInProximity containsKey:beaconKey]
            || [self.store beaconDiscoveryExistsWithUUID:beaconUUID name:beaconName];

        if (isPending) {
            // Do nothing
        } else if (alreadyDiscovered) {
            // Using a delay to filter beacons which have been ranged, then not ranged and later ranged again
            if ([self shouldNotifyBeaconInReach:beaconRangeInfo
                                        withKey:beaconKey
                                    lastBeacons:lastBeacons]) {
                [self notifyBeaconInReachWithUUID:beaconUUID
                                            major:beacon.major
                                            minor:beacon.minor
                                        proximity:beacon.proximity
                                          doCheck:NO];
            }
        } else {
            BEACON_LOG(@"First discovery of beacon: %@", beaconKey);
            MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO *request =
                [MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO transferObject];
            request.uuid = beaconUUID;
            request.name = beaconName;

            MCTBeaconDiscoveredResponseHandler *responseHandler =
                [MCTBeaconDiscoveredResponseHandler responseHandlerWithUUID:beaconUUID
                                                                      major:beacon.major
                                                                      minor:beacon.minor
                                                                  proximity:beacon.proximity];

            [MCT_com_mobicage_api_location CS_API_beaconDiscoveredWithResponseHandler:responseHandler
                                                                           andRequest:request];

            [self.store saveBeaconDiscoveryWithUUID:beaconUUID name:beaconName];
            [self.beaconsInProximityPending setObject:[MCTBeaconProximity beaconProximityWithUUID:beaconUUID
                                                                                            major:beacon.major
                                                                                            minor:beacon.minor
                                                                                        proximity:beacon.proximity]
                                               forKey:beaconKey];
        }
    }

    // Find beacons in this region which are not in range anymore
    [self findBeaconsOutOfReachBelongingToRegion:region withRangeTimestamp:now];
}

#pragma mark - Beacons

- (void)setBeaconRegionsToMonitor:(NSArray *)regionsToMonitor
{
    T_UI();
    self.regionsToMonitor = regionsToMonitor;

    if (![MCTUtils iBeaconsSupported]) {
        return;
    }

    if (!self.locationMgr) {
        if (!regionsToMonitor.count)
            return;

        self.locationMgr = [[CLLocationManager alloc] init];
        self.locationMgr.delegate = self;
    }

#if MCT_DEBUG
    for (id obj in regionsToMonitor) {
        assert([obj isKindOfClass:[CLBeaconRegion class]]);
    }
#endif

    NSArray *monitoringRegions = [self.locationMgr.monitoredRegions allObjects];

    if (self.cbCentralManager.state != CBCentralManagerStatePoweredOn) {
        LOG(@"CBCentralManagerState = %d", self.cbCentralManager.state);
        for (CLBeaconRegion *region in monitoringRegions) {
            [self.locationMgr stopMonitoringForRegion:region];
        }
        return;
    }

    NSMutableArray *removedRegions = [NSMutableArray arrayWithArray:monitoringRegions];
    [removedRegions removeObjectsInArray:regionsToMonitor];

    for (CLBeaconRegion *region in removedRegions) {
        BEACON_LOG(@"stopMonitoringForRegion: %@", [MCTUtils stringFromBeaconRegion:region]);
        [self.locationMgr stopMonitoringForRegion:region];
    }

    for (CLBeaconRegion *region in self.locationMgr.monitoredRegions) {
        BEACON_LOG(@"requestStateForRegion: %@", [MCTUtils stringFromBeaconRegion:region]);
        [self.locationMgr requestStateForRegion:region];
    }

    NSMutableArray *addedRegions = [NSMutableArray arrayWithArray:regionsToMonitor];
    [addedRegions removeObjectsInArray:monitoringRegions];

    for (CLBeaconRegion *region in addedRegions) {
        BEACON_LOG(@"startMonitoringForRegion: %@", [MCTUtils stringFromBeaconRegion:region]);
        [self.locationMgr requestStateForRegion:region];
        [self.locationMgr startMonitoringForRegion:region];
    }
}

- (NSArray *)cacheBeaconRangeInfo:(MCTBeaconRangeInfo *)beaconRangeInfo
                    withBeaconKey:(NSString *)beaconKey
{
    T_UI();
    NSMutableArray *lastBeacons = [self.last3BeaconRanges objectForKey:beaconKey];
    if (lastBeacons == nil) {
        lastBeacons = [NSMutableArray arrayWithCapacity:3];
        [self.last3BeaconRanges setObject:lastBeacons forKey:beaconKey];
    } else if (lastBeacons.count > 2) {
        [lastBeacons removeObjectAtIndex:0];
    }
    [lastBeacons addObject:beaconRangeInfo];
    return lastBeacons;
}

- (void)logRangedBeacons:(NSArray *)lastBeacons
      withRangeTimestamp:(MCTlong)now
               isPending:(BOOL)isPending
{
    T_UI();
    NSMutableString *stringBuilder = [NSMutableString string];
    BOOL isFirst = YES;
    MCTBeaconRangeInfo *lastRangeInfo = nil;
    for (MCTBeaconRangeInfo *rangeInfo in lastBeacons) {
        if (isFirst) {
            [stringBuilder appendFormat:@"%@: [", [MCTUtils nameForBeacon:rangeInfo.beacon]];
            isFirst = NO;
        } else {
            [stringBuilder appendString:@", "];
        }
        [stringBuilder appendFormat:@"%@ (%lldms ago)",
         [MCTUtils stringFromCLProximity:rangeInfo.beacon.proximity],
         now - rangeInfo.rangeTimestamp];
        lastRangeInfo = rangeInfo;
    }
    [stringBuilder appendFormat:@"] %.2fm%@", lastRangeInfo.beacon.accuracy, isPending ? @" (isPending)" : @""];
    BEACON_LOG(@"%@", stringBuilder);
}

- (void)findBeaconsOutOfReachBelongingToRegion:(CLBeaconRegion *)region
                            withRangeTimestamp:(MCTlong)now
{
    T_UI();
    NSArray *beaconKeysInRange = self.last3BeaconRanges.allKeys;
    for (NSString *beaconKey in beaconKeysInRange) {
        MCTBeaconRangeInfo *rangeInfo = [[self.last3BeaconRanges objectForKey:beaconKey] lastObject];
        CLBeacon *beacon = rangeInfo.beacon;

        // First check if this beacon belongs to this region
        if ([MCTUtils doesBeacon:beacon belongToRegion:region]) {
            if (now < 0 || rangeInfo.rangeTimestamp < now - 5000) {
                // Beacon is not ranged since 5 seconds
                BEACON_LOG(@"Beacon out of reach: %@", rangeInfo);
                [self notifyBeaconOutOfReachWithUUID:[beacon.proximityUUID UUIDString]
                                               major:beacon.major
                                               minor:beacon.minor];
                [self.last3BeaconRanges removeObjectForKey:beaconKey];
            }
        }
    }

}

// Using a delay to filter beacons which have been ranged, then not ranged and later ranged again
- (BOOL)shouldNotifyBeaconInReach:(MCTBeaconRangeInfo *)currentRangeInfo
                          withKey:(NSString *)beaconKey
                      lastBeacons:(NSArray *)lastBeacons
{
    T_UI();
    MCTBeaconProximity *currentBeaconInProximity = [self.beaconsInProximity objectForKey:beaconKey];
    if (currentBeaconInProximity) {
        // Did this beacon have the same proximity for the last 3 times?
        if (currentRangeInfo.beacon.proximity == currentBeaconInProximity.proximity || lastBeacons.count < 3) {
            return NO;
        } else {
            for (MCTBeaconRangeInfo *oldRangeInfo in lastBeacons) {
                if (oldRangeInfo.beacon.proximity != currentRangeInfo.beacon.proximity) {
                    return NO;
                }
            }
        }
    }

    return YES;
}

- (void)notifyBeaconInReachWithUUID:(NSString *)uuid
                              major:(NSNumber *)major
                              minor:(NSNumber *)minor
                          proximity:(CLProximity)proximity
                            doCheck:(BOOL)doCheckIsStillPending
{
    T_UI();
    NSString *beaconName = [MCTUtils nameForBeaconWithMajor:major minor:minor];
    NSString *beaconKey = [MCTUtils keyForBeaconWithUUID:uuid name:beaconName];

    if (doCheckIsStillPending) {
        // Just received result of beaconDiscovered request. Check if beacon is still in reach.
        MCTBeaconProximity *beaconInProximity = [self.beaconsInProximityPending objectForKey:beaconKey];
        if (beaconInProximity) {
            proximity = beaconInProximity.proximity;
            [self.beaconsInProximityPending removeObjectForKey:beaconKey];
        } else if ([self.cachedBeaconsWithoutOwner objectForKey:beaconKey]) {
            [self.cachedBeaconsWithoutOwner removeObjectForKey:beaconKey];
        } else {
            BEACON_LOG(@"Just received beaconDiscovered response, but beacon %@ is not in reach anymore", beaconKey);
            return;
        }
    }

    if (![self.beaconsInProximityPending containsKey:beaconKey]) {
        NSDictionary *beaconInfo = [self.store friendConnectedToBeaconDiscoveryWithUUID:uuid name:beaconName];
        if (beaconInfo == nil) {
            // Beacon is already discovered, but the owner is not in the friend list
            [self.beaconsInProximityPending setObject:[MCTBeaconProximity beaconProximityWithUUID:uuid
                                                                                            major:major
                                                                                            minor:minor
                                                                                        proximity:proximity]
                                               forKey:beaconKey];
        } else {
            NSString *friendEmail = [beaconInfo stringForKey:@"email"];
            NSString *tag = [beaconInfo stringForKey:@"tag"];
            MCTlong friendCallbacks = [beaconInfo longForKey:@"callbacks"];

            MCTDiscoveredBeaconProximity *beaconProximity = [MCTDiscoveredBeaconProximity beaconProximityWithUUID:uuid
                                                                                                            major:major
                                                                                                            minor:minor
                                                                                                        proximity:proximity
                                                                                                      friendEmail:friendEmail
                                                                                                              tag:tag];
            [self.beaconsInProximity setObject:beaconProximity forKey:beaconKey];

            MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_BEACON_IN_REACH];
            [intent setString:friendEmail forKey:@"email"];
            [intent setString:[[beaconProximity dictRepresentation] MCT_JSONRepresentation] forKey:@"beacon_json"];
            [[MCTComponentFramework intentFramework] broadcastIntent:intent];

            if (IS_FLAG_SET(friendCallbacks, MCTServiceCallbackFriendInReach)) {
                MCT_com_mobicage_to_location_BeaconInReachRequestTO *request =
                    [MCT_com_mobicage_to_location_BeaconInReachRequestTO transferObject];
                request.uuid = uuid;
                request.name = beaconName;
                request.friend_email = friendEmail;
                request.proximity = proximity;

                MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
                [MCT_com_mobicage_api_location CS_API_beaconInReachWithResponseHandler:rh andRequest:request];
            }
        }
    }
}

- (void)notifyBeaconOutOfReachWithUUID:(NSString *)uuid
                                 major:(NSNumber *)major
                                 minor:(NSNumber *)minor
{
    T_UI();
    NSString *beaconName = [MCTUtils nameForBeaconWithMajor:major minor:minor];
    NSString *beaconKey = [MCTUtils keyForBeaconWithUUID:uuid name:beaconName];

    MCTDiscoveredBeaconProximity *beaconProximity = [self.beaconsInProximity objectForKey:beaconKey];
    if (beaconProximity) {
        NSDictionary *beaconInfo = [self.store friendConnectedToBeaconDiscoveryWithUUID:uuid name:beaconName];
        if (beaconInfo != nil) {
            NSString *friendEmail = [beaconInfo stringForKey:@"email"];
            MCTlong friendCallbacks = [beaconInfo longForKey:@"callbacks"];

            MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_BEACON_OUT_OF_REACH];
            [intent setString:friendEmail forKey:@"email"];
            [intent setString:[[beaconProximity dictRepresentation] MCT_JSONRepresentation] forKey:@"beacon_json"];
            [[MCTComponentFramework intentFramework] broadcastIntent:intent];

            if (IS_FLAG_SET(friendCallbacks, MCTServiceCallbackFriendOutOfReach)) {
                MCT_com_mobicage_to_location_BeaconOutOfReachRequestTO *request =
                    [MCT_com_mobicage_to_location_BeaconOutOfReachRequestTO transferObject];
                request.uuid = uuid;
                request.name = beaconName;
                request.friend_email = friendEmail;

                MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];
                [MCT_com_mobicage_api_location CS_API_beaconOutOfReachWithResponseHandler:rh andRequest:request];
            }
        }

        [self.beaconsInProximity removeObjectForKey:beaconKey];
    }

    // removeObjectForKey does nothing if beaconKey does not exist.
    [self.beaconsInProximityPending removeObjectForKey:beaconKey];
}

- (NSArray *)beaconsInReachWithFriendEmail:(NSString *)friendEmail
{
    T_UI();
    NSMutableArray *isInReachWith = [NSMutableArray array];
    for (MCTDiscoveredBeaconProximity *prox in self.beaconsInProximity.allValues) {
        if ([friendEmail isEqualToString:prox.friendEmail]) {
            [isInReachWith addObject:prox];
        }
    }
    return isInReachWith;
}

- (void)addBeaconWithoutOwner:(NSString *)beaconKey
{
    T_UI();
    BEACON_LOG(@"Adding beacon without owner: %@", beaconKey);
    [self.cachedBeaconsWithoutOwner setObject:beaconKey forKey:beaconKey];
    [self.last3BeaconRanges removeObjectForKey:beaconKey];
    [self.beaconsInProximityPending removeObjectForKey:beaconKey];
}

- (void)removeBeaconFromCaches:(NSString *)beaconKey
{
    T_UI();
    BEACON_LOG(@"Removing beacon from caches: %@", beaconKey);
    [self.beaconsInProximity removeObjectForKey:beaconKey];
    [self.beaconsInProximityPending removeObjectForKey:beaconKey];
    [self.last3BeaconRanges removeObjectForKey:beaconKey];
    [self.cachedBeaconsWithoutOwner removeObjectForKey:beaconKey];
}

- (void)deleteBeaconDiscoveryWithFriend:(NSString *)friendEmail
{
    T_UI();
    [self.store deleteBeaconDiscoveryWithFriendEmail:friendEmail];

    for (MCTBeaconProximity *beacon in [self beaconsInReachWithFriendEmail:friendEmail]) {
        NSString *beaconName = [MCTUtils nameForBeaconWithMajor:beacon.major minor:beacon.minor];
        NSString *beaconKey = [MCTUtils keyForBeaconWithUUID:beacon.uuid name:beaconName];
        [self removeBeaconFromCaches:beaconKey];
    }
}

#pragma mark -

- (void)stop
{
    T_BIZZ();
    HERE();
    if (self.trackingTimers != nil) {
        for (NSTimer *timer in [self.trackingTimers allValues]) {
            [timer invalidate];
        }
    }
    [self.locationMgr stopUpdatingLocation];
    [self.trackingMgr stopMonitoringSignificantLocationChanges];
    [self.trackingMgr stopUpdatingLocation];

    MCT_RELEASE(self.store);
    MCT_RELEASE(self.cfgProvider);
    MCT_RELEASE(self.locationRecipients);
    MCT_RELEASE(self.trackingTimers);
    MCT_RELEASE(self.locationMgr);
    MCT_RELEASE(self.trackingMgr);
    MCT_RELEASE(self.bestLocation);

    MCT_RELEASE(self.last3BeaconRanges);
    MCT_RELEASE(self.beaconsInProximity);
    MCT_RELEASE(self.beaconsInProximityPending);
    MCT_RELEASE(self.cachedBeaconsWithoutOwner);

    MCT_RELEASE(self.regionsToMonitor);
    MCT_RELEASE(self.cbCentralManager);
}

- (void)dealloc
{
    T_BIZZ();
    [self stop];
    
}


#pragma mark - MCTIntent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_LOCATION_START_AUTOMATIC_DETECTION || intent.action == kINTENT_BEACON_REGIONS_UPDATED) {
        if ([MCTUtils iBeaconsSupported]) {
            NSArray *regionTOs = [self.store beaconRegions];
            NSMutableArray *regions = [NSMutableArray arrayWithCapacity:regionTOs.count];
            for (MCT_com_mobicage_to_beacon_BeaconRegionTO *regionTO in regionTOs) {
                [regions addObject:[MCTUtils beaconRegionFromBeaconRegionTO:regionTO]];
            }
            [self setBeaconRegionsToMonitor:regions];
        }

        [[MCTComponentFramework intentFramework] removeStickyIntent:intent];
    }

    else if (intent.action == kINTENT_DO_BEACON_REGIONS_RETRIEVAL) {
        [self requestBeaconRegions];
    }

    else if (intent.action == kINTENT_FRIEND_REMOVED) {
        [self deleteBeaconDiscoveryWithFriend:[intent stringForKey:@"email"]];
    }

    else if (intent.action == kINTENT_FRIEND_ADDED) {
        if ([intent longForKey:@"friend_type"] == MCTFriendTypeService
                && [intent longForKey:@"existence"] == MCTFriendExistenceActive) {
            NSArray *discoveredBeacons = [self.store beaconDiscoveriesWithFriendEmail:[intent stringForKey:@"email"]];
            for (MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO *beaconDiscovery in discoveredBeacons) {
                NSString *beaconKey = [MCTUtils keyForBeaconWithUUID:beaconDiscovery.uuid
                                                                name:beaconDiscovery.name];
                BEACON_LOG(@"Not pending anymore: %@", beaconKey);
                [self.beaconsInProximityPending removeObjectForKey:beaconKey];
            }
        }
    }

    else if (intent.action == kINTENT_BACKLOG_FINISHED) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                          forIntentAction:kINTENT_BACKLOG_FINISHED];
        [self endBackgroundTask];
    }
}

@end