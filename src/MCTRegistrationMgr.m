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

#import "MCTApplePush.h"
#import "MCTComponentFramework.h"
#import "MCTHTTPRequest.h"
#import "MCTMobileInfo.h"
#import "MCTPickler.h"
#import "MCTRegistrationMgr.h"
#import "MCTUtils.h"

#import "NSData+Base64.h"


@interface MCTRegistrationMgr ()

@property (nonatomic, strong) CLLocationManager *locationMgr;

@property (nonatomic, strong) CBCentralManager *cbCentralManager;
@property (nonatomic, strong) NSArray *regionsToMonitor;

@end

@implementation MCTRegistrationMgr

- (id)init
{
    T_UI();
    if (self = [super init]) {
        self.regionsToMonitor = @[];
        self.cbCentralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                      queue:nil
                                                                    options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];

        [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                       forIntentActions:@[kINTENT_BEACON_REGIONS_UPDATED,
                                                                          kINTENT_LOCATION_START_AUTOMATIC_DETECTION,
                                                                          kINTENT_INIT_APNS_STATUS]
                                                                onQueue:[MCTComponentFramework mainQueue]];

        // start automatic detection if app restarts during registration procedure
        NSString *beaconRegionsString = [[MCTComponentFramework configProvider] stringForKey:MCT_REGISTRATION_BEACON_REGIONS];
        if (![MCTUtils isEmptyOrWhitespaceString:beaconRegionsString]) {
            MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_BEACON_REGIONS_UPDATED];
            [[MCTComponentFramework intentFramework] broadcastIntent:intent];
        }

        NSString *discoveredBeaconsString = [[MCTComponentFramework configProvider] stringForKey:MCT_REGISTRATION_DISCOVERED_BEACONS];
        if ([MCTUtils isEmptyOrWhitespaceString:discoveredBeaconsString]) {
            self.beacons = [NSMutableDictionary dictionary];
        } else {
            self.beacons = [NSMutableDictionary dictionaryWithDictionary:[discoveredBeaconsString MCT_JSONValue]];
        }
    }
    return self;
}

+ (BOOL)isRegistered
{
    T_UI();
    return ( ([[MCTComponentFramework configProvider]  stringForKey:MCT_CONFIGKEY_USERNAME] != nil)
            && ([[MCTComponentFramework configProvider]  stringForKey:MCT_CONFIGKEY_PASSWORD] != nil) );
}

+ (BOOL)areTermsOfServiceAccepted
{
    T_UI();
    NSString *entry = [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_TOS_ACCEPTED];
    return ![MCTUtils isEmptyOrWhitespaceString:entry];
}

+ (BOOL)isLocationUsageShown
{
    T_UI();
    NSString *entry = [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_LOCATION_USAGE_SHOWN];
    return ![MCTUtils isEmptyOrWhitespaceString:entry];
}

+ (BOOL)isPushNotificationsShown
{
    T_UI();
    if (IS_CITY_APP) {
        NSString *entry = [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_PUSH_NOTIFICATION_SHOWN];
        return ![MCTUtils isEmptyOrWhitespaceString:entry];
    } else {
        return YES;
    }
}

+ (NSString *)installationId
{
    T_UI();
    NSString *installationId = [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_INSTALLATION_ID];
    if ([MCTUtils isEmptyOrWhitespaceString:installationId]) {
        installationId = [MCTUtils guid];
        [[MCTComponentFramework configProvider] setString:installationId forKey:MCT_CONFIGKEY_INSTALLATION_ID];
    }
    return installationId;
}

+ (MCTPreRegistrationInfo *)preRegistrationInfo
{
    T_UI();
    NSString *pickle = [[MCTComponentFramework configProvider] stringForKey:MCT_PRE_REG_INFO_CONFIG_KEY];
    if ([MCTUtils isEmptyOrWhitespaceString:pickle]) {
        return nil;
    } else {
        return (MCTPreRegistrationInfo *) [MCTPickler objectFromPickle:[NSData dataFromBase64String:pickle]];
    }
}

#pragma mark -

+ (void)sendInstallationId
{
    T_UI();

    NSString *installationId = [MCTRegistrationMgr installationId];

    NSString *url = [NSString stringWithFormat:@"%@%@", MCT_HTTPS_BASE_URL, MCT_REGISTRATION_URL_INSTALL];
    MCTFormDataRequest *request = [MCTFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    request.numberOfTimesToRetryOnTimeout = 3;
    request.shouldRedirect = NO;
    request.timeOutSeconds = 10;
    request.useCookiePersistence = NO;
    request.useSessionPersistence = NO;
    request.validatesSecureCertificate = YES;

    __weak typeof(request) weakHttpRequest = request;
    [request setCompletionBlock:^{
        T_UI();
        if (weakHttpRequest.responseStatusCode == 200) {
            LOG(@"Successfully sent installation id");

            NSDictionary *responseDict = [weakHttpRequest.responseString MCT_JSONValue];
            if ([@"success" isEqualToString:[responseDict stringForKey:@"result"]]) {
                NSDictionary *beaconRegionsDict = [responseDict dictForKey:@"beacon_regions"];

                BEACON_LOG(@"Received beacon regions: %@", responseDict);
                [[MCTComponentFramework configProvider] setString:[beaconRegionsDict MCT_JSONRepresentation]
                                                           forKey:MCT_REGISTRATION_BEACON_REGIONS];

                MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_BEACON_REGIONS_UPDATED];
                [[MCTComponentFramework intentFramework] broadcastIntent:intent];
            } else {
                LOG("Result of sendInstallationId call was not 'success': %@", weakHttpRequest.responseString);
            }

        } else {
            LOG(@"Failed to send installation id");
        }
    }];
    [request setFailedBlock:^{
        T_UI();
        LOG(@"Failed to send installation id");
    }];
    
    [request setPostValue:MCT_PRODUCT_VERSION forKey:@"version"];
    [request setPostValue:MCT_PRODUCT_ID forKey:@"app_id"];
    [request setPostValue:installationId forKey:@"install_id"];
    [request setPostValue:@"iphone" forKey:@"platform"];
    MCTLocaleInfo *localeInfo = [MCTLocaleInfo info];
    [request setPostValue:localeInfo.language forKey:@"language"];
    [request setPostValue:localeInfo.country forKey:@"country"];
    [request setPostValue:MCT_USE_XMPP_KICK_CHANNEL ? @"true" : @"false" forKey:@"use_xmpp_kick"];

    [[MCTComponentFramework workQueue] addOperation:request];
}

#pragma mark -

+ (void)sendRegistrationStep:(NSString *)step
{
    [self sendRegistrationStep:step withPostValues:@{}];
}

+ (void)sendRegistrationStep:(NSString *)step withPostValues:(NSDictionary *)postValues
{
    T_UI();

    NSString *url = [NSString stringWithFormat:@"%@%@", MCT_HTTPS_BASE_URL, MCT_REGISTRATION_URL_LOG_STEP];
    MCTFormDataRequest *request = [MCTFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    request.numberOfTimesToRetryOnTimeout = 3;
    request.shouldRedirect = NO;
    request.timeOutSeconds = 10;
    request.useCookiePersistence = NO;
    request.useSessionPersistence = NO;
    request.validatesSecureCertificate = YES;

    [request setCompletionBlock:^{
        T_UI();
        if (request.responseStatusCode == 200) {
            LOG(@"Successfully logged registration step %@", step);
        } else {
            LOG(@"Failed to log registration step %@", step);
        }
    }];
    [request setFailedBlock:^{
        T_UI();
        LOG(@"Failed to log registration step %@", step);
    }];

    [request setPostValue:[MCTRegistrationMgr installationId] forKey:@"install_id"];
    [request setPostValue:step forKey:@"step"];
    [postValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [request setPostValue:obj forKey:key];
    }];

    [[MCTComponentFramework workQueue] addOperation:request];
}

#pragma mark - Beacons

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    T_UI();
    if (central != self.cbCentralManager) {
        return;
    }

    [self setBeaconRegionsToMonitor:self.regionsToMonitor];
}

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

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    T_UI();
    BEACON_HERE();
    BEACON_LOG(@"monitoringDidFailForRegion: %@ withError: %@", [MCTUtils stringFromBeaconRegion:region], error);
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    T_UI();
    BEACON_HERE();
    BEACON_LOG(@"rangingBeaconsDidFailForRegion: %@ withError: %@", [MCTUtils stringFromBeaconRegion:region], error);
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLBeaconRegion *)region
{
    T_UI();
    BEACON_HERE();
    BEACON_LOG(@"didDetermineState: %@ forRegion: %@", [MCTUtils stringFromCLRegionState:state], [MCTUtils stringFromBeaconRegion:region]);
    switch (state) {
        case CLRegionStateInside:
            [self.locationMgr startRangingBeaconsInRegion:region];
            break;
        case CLRegionStateOutside:
            [self.locationMgr stopRangingBeaconsInRegion:region];
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
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    T_UI();
    BOOL updated = NO;
    for (CLBeacon *beacon in beacons) {
        NSString *beaconKey = [MCTUtils keyForBeacon:beacon];
        if (![self.beacons containsKey:beaconKey]) {
            BEACON_LOG(@"discovered iBeacon: %@", [MCTUtils stringFromBeacon:beacon]);
            NSString *beaconUUID = [[beacon.proximityUUID UUIDString] lowercaseString];
            NSString *beaconName = [MCTUtils nameForBeacon:beacon];

            MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO *request =
                [MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO transferObject];
            request.uuid = beaconUUID;
            request.name = beaconName;
            [self.beacons setObject:[request dictRepresentation] forKey:beaconKey];

            updated = YES;
        }
    }
    if (updated) {
        [[MCTComponentFramework configProvider] setString:[self.beacons MCT_JSONRepresentation]
                                                   forKey:MCT_REGISTRATION_DISCOVERED_BEACONS];
    }
}

#pragma mark - MCTIntent

- (BOOL)startAutomaticDetection
{
    T_UI();
    if (![MCTUtils iBeaconsSupported]) {
        return NO;
    }

    NSString *regionsJSON = [[MCTComponentFramework configProvider] stringForKey:MCT_REGISTRATION_BEACON_REGIONS];
    if (regionsJSON) {
        NSDictionary *beaconRegionsDict = [regionsJSON MCT_JSONValue];
        MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO *beaconRegionsTO =
            [MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO transferObjectWithDict:beaconRegionsDict];

        NSMutableArray *regions = [NSMutableArray arrayWithCapacity:beaconRegionsTO.regions.count];
        for (MCT_com_mobicage_to_beacon_BeaconRegionTO *regionTO in beaconRegionsTO.regions) {
            [regions addObject:[MCTUtils beaconRegionFromBeaconRegionTO:regionTO]];
        }

        [[MCTComponentFramework registrationMgr] setBeaconRegionsToMonitor:regions];
        return YES;
    }
    return NO;
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_LOCATION_START_AUTOMATIC_DETECTION) {
        [self startAutomaticDetection];
    } else if (intent.action == kINTENT_BEACON_REGIONS_UPDATED) {
        if ([MCTRegistrationMgr isLocationUsageShown]) {
            [self startAutomaticDetection];
        }
    } else if (intent.action == kINTENT_INIT_APNS_STATUS) {
        if ([MCTRegistrationMgr isRegistered]) {
            [[MCTComponentFramework configProvider] setString:@"YES" forKey:MCT_DID_REGISTER_FOR_PUSH_NOTIFICATIONS];
        }
        [[MCTComponentFramework intentFramework] removeStickyIntent:intent];
    }
}

@end