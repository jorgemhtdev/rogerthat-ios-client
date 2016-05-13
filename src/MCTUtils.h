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

#import "MCTTransferObjects.h"


#define MCT_FORWARDING_LOGS_ON_STRING NSLocalizedString(@"Debugging: ON", nil)
#define MCT_FORWARDING_LOGS_OFF_STRING NSLocalizedString(@"Debugging: OFF", nil)

#define KB 1000
#define MB 1000000


@interface MCTUtils : NSObject

+ (NSString *)documentsFolder;
+ (NSString *)cachesFolder;

+ (void)setBadgeNumber:(NSInteger)number;
+ (NSInteger)badgeNumber;
+ (void)hideIconBadge;

+ (MCTlong)currentTimeMillis;
+ (MCTlong)currentTimeSeconds;
+ (MCTlong)currentServerTime;

+ (NSString *)guid;

+ (MCTlong)clientTimeFromServerTime:(MCTlong)serverTime;
+ (MCTlong)serverTimeFromClientTime:(MCTlong)clientTime;

+ (NSString *)timestampNotation:(MCTlong)timestampInSeconds;
+ (NSString *)timestampShortNotation:(MCTlong)timestampInSeconds andShowMinutes:(BOOL)showMinutes;
+ (MCTlong)updateTimestampIn:(MCTlong)timestampInSeconds;
+ (NSString *)timestamp:(MCTlong)timestampInSeconds withFormat:(NSString *)format;

+ (NSString *)urlEncodeValue:(NSString *)unencodedString;

+ (NSString *)mcCurrentQueueName;

+ (NSString *)stackTraceFromException:(NSException *)exception;
+ (NSString *)currentStackTrace;

+ (NSString *)callerMethod;

+ (void)resetLastTimeSoundPlayed;

+ (void)playNotificationSound;

+ (BOOL)connectedToInternet;
+ (BOOL)connectedToWifi;
+ (BOOL)connectedToInternetAndXMPP;

+ (BOOL)deviceCanMakePhoneCalls;
+ (BOOL)deviceSupportsMultitasking;
+ (BOOL)deviceIsSimulator;

+ (BOOL)isEmptyOrWhitespaceString:(id)s;
+ (BOOL)isString:(NSString *)s1 equalToString:(NSString *)s2;

+ (NSString *)preferredLanguage;

+ (NSString *)stringByAppendingTargetForFacebookImageURL:(NSString *)fbImgURL;

+ (MCTlong)floor:(MCTlong)value withInterval:(MCTlong)interval;

+ (NSString *)deviceId;
+ (NSString *)stringForSize:(MCTlong)size;
+ (NSString *)fileExtensionWithMimeType:(NSString *)mimeType;
+ (NSString *)fileSHA256:(NSURL *)fileURL error:(NSError **)error;

+ (NSString *)nameForBeaconWithMajor:(NSNumber *)major minor:(NSNumber *)minor;
+ (NSString *)nameForBeacon:(CLBeacon *)beacon __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);

+ (NSString *)keyForBeaconWithUUID:(NSString *)uuidString
                              name:(NSString *)name;
+ (NSString *)keyForBeacon:(CLBeacon *)beacon __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
+ (NSString *)keyForBeaconRegion:(CLBeaconRegion *)region __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
+ (NSString *)keyForBeaconRegionTO:(MCT_com_mobicage_to_beacon_BeaconRegionTO *)regionTO;
+ (CLBeaconRegion *)beaconRegionFromBeaconRegionTO:(MCT_com_mobicage_to_beacon_BeaconRegionTO *)regionTO __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);

+ (NSString *)stringFromBeacon:(CLBeacon *)beacon __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
+ (NSString *)stringFromBeaconRegion:(CLBeaconRegion *)region __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
+ (NSString *)stringFromCLRegionState:(CLRegionState)state __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
+ (NSString *)stringFromCLProximity:(CLProximity)proximity __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);

+ (BOOL)iBeaconsSupported;
+ (BOOL)doesBeacon:(CLBeacon *)beacon
    belongToRegion:(CLBeaconRegion *)region __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

#pragma mark - oauth

+ (void)startOauthWithVC:(UIViewController *)vc
            authorizeUrl:(NSString *)authorizeUrl
                  scopes:(NSString *)scopes
                   state:(NSString *)state
                clientId:(NSString *)clientId;

@end


#pragma mark -

@interface NSData (MCTBase64)

- (NSString *)MCTBase64Encode;

@end


#pragma mark -

@interface NSString (MCTBase64)

- (NSString *)MCTBase64Encode;
- (NSString *)MCTBase64Decode;

@end


#pragma mark -

@interface NSString (MCTUtils)

- (NSString *)stringByTruncatingTailWithLength:(int)length;
- (NSString *)stringByTrimming;
- (BOOL)containsString:(NSString *)s;
- (NSRange)range;
+ (NSString *)stringWithUTF8StringSafe:(const unsigned char *)value;
- (BOOL)isAlphaNumeric;
- (NSInteger)numberOfLines;
+ (NSString *)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;

@end


#pragma mark -

@interface NSArray (MCTUtils)

- (BOOL)containsAll:(NSArray *)objects;

@end


#pragma mark -

@interface NSMutableArray (MCTUtils)

- (void)sortByKeys:(NSString *)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

@end