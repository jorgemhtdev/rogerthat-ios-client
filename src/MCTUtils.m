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

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "3rdParty/asi-http-request/Reachability.h"

#import "GTMNSDictionary+URLArguments.h"

#import "MCTEncoding.h"
#import "MCTOperation.h"
#import "MCTUtils.h"
#import "MCTComponentFramework.h"
#import "MCTLogForwarding.h"
#import "MCTMobileInfo.h"

#import "NSData+Base64.h"
#import "NSData+XMPP.h"

#import "NSStringAdditions.h"
#import "TTGlobalCore.h"

#import <SafariServices/SafariServices.h>

static MCTlong CLIENT_SERVER_EPOCH_DIFFERENCE_MILLIS;
static MCTlong LAST_TIME_SOUND_PLAYED;

void MCTLog(const char * const sourceFile, const int lineNumber, const char * const theFunction, const char * const logLevel, const char * const prefix, void *format, ...)
{
    if (MCT_DEBUG_LOGGING
        || [[MCTLogForwarder logForwarder] forwarding]
        || logLevel == LOGLEVEL_BUG
        || logLevel == LOGLEVEL_ERROR) {

        NSString *print, *file;

        va_list ap;
        
        va_start(ap, format);
        print = [[NSString alloc] initWithFormat:(__bridge NSString * _Nonnull)(format) arguments:ap];
        va_end(ap);

        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm:ss.SSS"];
        NSString *now = [formatter stringFromDate:date];

        NSString *currentQueueName = [MCTUtils mcCurrentQueueName];
        if (currentQueueName == nil)
            currentQueueName = [NSString stringWithFormat:@"? %p", [NSThread currentThread]];

        if (sourceFile != NULL)
            file = [NSString stringWithUTF8String:sourceFile];
        else
            file = @"<<Unknown file>>";

        if ([print length] == 0) {
            printf("%s (%s) %s%s %-40s (%s:%d)\n", [now UTF8String], [currentQueueName UTF8String], prefix, logLevel, theFunction, [[file lastPathComponent] UTF8String], lineNumber);
            @synchronized(MCTDebugLogLock) {
                fprintf(MCTDebugLogFile, "%s (%s) %s%s %-40s (%s:%d)\n", [now UTF8String], [currentQueueName UTF8String], prefix, logLevel, theFunction, [[file lastPathComponent] UTF8String], lineNumber);
                fflush(MCTDebugLogFile);
            }

            [[MCTLogForwarder logForwarder] logWithTimestamp:now
                                                   queueName:currentQueueName
                                                      prefix:prefix
                                                    logLevel:logLevel
                                                    function:theFunction
                                                        file:file
                                                  lineNumber:lineNumber];
        } else {
            printf("%s (%s) %s%s\n", [now UTF8String], [currentQueueName UTF8String], prefix, [print UTF8String]);
            @synchronized(MCTDebugLogLock) {
                fprintf(MCTDebugLogFile, "%s (%s) %s%s\n", [now UTF8String], [currentQueueName UTF8String], prefix, [print UTF8String]);
                fflush(MCTDebugLogFile);
            }

            [[MCTLogForwarder logForwarder] logWithTimestamp:now
                                                   queueName:currentQueueName
                                                      prefix:prefix
                                                     message:print];
        }

        if ((logLevel == LOGLEVEL_BUG) || (logLevel == LOGLEVEL_ERROR)) {
            NSString *stackTrace = [MCTUtils currentStackTrace];
            NSLog(@"%@\n%@", print, stackTrace);

            [[MCTLogForwarder logForwarder] logErrorWithMessage:print stackTrace:stackTrace];
        }
    }
}


void MCTAssertQueue(NSString *queueName, const char * const sourceFile, const int lineNumber, const char * const theFunction)
{
    NSString *currentQueueName = [MCTUtils mcCurrentQueueName];
    if (![queueName isEqualToString:currentQueueName]) {
        MCTLog(sourceFile, lineNumber, theFunction, LOGLEVEL_BUG, "", @"Queue error! expecting [%@] got [%@]", queueName, currentQueueName);
    }
}

BOOL MCTCheckQueue(NSString *queueName)
{
    NSString *currentQueueName = [MCTUtils mcCurrentQueueName];
    return [queueName isEqualToString:currentQueueName];
}

@implementation MCTUtils

+ (void)initialize
{
    NSDate *now = [[NSDate alloc] init];
    MCTlong diff1 = [now timeIntervalSinceReferenceDate] * 1000LL;
    MCTlong diff2 = [now timeIntervalSince1970] * 1000LL;
    CLIENT_SERVER_EPOCH_DIFFERENCE_MILLIS = diff2 - diff1;
    LAST_TIME_SOUND_PLAYED = [MCTUtils currentTimeMillis];
}

+ (NSString *)documentsFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)cachesFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (void)setBadgeNumber:(NSInteger)number
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];
}

+ (NSInteger)badgeNumber
{
    return [[UIApplication sharedApplication] applicationIconBadgeNumber];
}

+ (void)hideIconBadge
{
    [MCTUtils setBadgeNumber:0];
}

+ (MCTlong)currentTimeMillis
{
    return (MCTlong)([NSDate timeIntervalSinceReferenceDate] * 1000) + CLIENT_SERVER_EPOCH_DIFFERENCE_MILLIS;
}

+ (MCTlong)currentTimeSeconds
{
    return [MCTUtils currentTimeMillis] / 1000;
}

+ (MCTlong)currentServerTime
{
    return [MCTUtils serverTimeFromClientTime:[MCTUtils currentTimeMillis]];
}

+ (NSString *)guid
{
    // Copied from http://www.cocoabuilder.com/archive/cocoa/217665-how-to-create-guid.html
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return [((__bridge NSString *)uuidStringRef) lowercaseString];
}

+ (MCTlong)clientTimeFromServerTime:(MCTlong)serverTime
{
    // TODO client-server time skew adjustment
    return serverTime * 1000;
}

+ (MCTlong)serverTimeFromClientTime:(MCTlong)clientTime
{
    // TODO client-server time skew adjustment
    return clientTime / 1000;
}

+ (NSString *)timestampNotation:(MCTlong)timestampInSeconds
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestampInSeconds];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMMMd" options:0 locale:formatter.locale];
    NSString *d = [formatter stringFromDate:date];

    NSString *t = [NSDateFormatter localizedStringFromDate:date
                                                 dateStyle:NSDateFormatterNoStyle
                                                 timeStyle:NSDateFormatterShortStyle];

    return [NSString stringWithFormat:@"%@, %@", d, t];
}

+ (NSString *)timestampShortNotation:(MCTlong)timestampInSeconds andShowMinutes:(BOOL)showMinutes
{
    MCTlong now = [MCTUtils currentServerTime];
    MCTlong minute = 60;
    MCTlong hour = 60 * minute;
    MCTlong day = 24 * hour;
    MCTlong daysDifference = floor(now / day) - floor(timestampInSeconds / day);

    if (daysDifference == 1) {
        return NSLocalizedString(@"Yesterday", nil);
    } else {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestampInSeconds];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

        if (daysDifference < 1) {
            MCTlong hoursDifference = floor((now - timestampInSeconds) / hour);
            if (hoursDifference < 1) {
                formatter.dateStyle = NSDateFormatterNoStyle;
                formatter.timeStyle = NSDateFormatterShortStyle;
                if (showMinutes) {
                    MCTlong minutesDifference = floor((now - timestampInSeconds) / minute);
                    return [NSString stringWithFormat:NSLocalizedString(@"%@min ago", nil), [NSString stringWithFormat:@"%lld", minutesDifference + 1]];
                }
            } else {
                formatter.dateStyle = NSDateFormatterNoStyle;
                formatter.timeStyle = NSDateFormatterShortStyle;
            }
        } else if (daysDifference < 7) {
            [formatter setDateFormat:@"EEEE"];
        } else {
            formatter.dateStyle = NSDateFormatterShortStyle;
            formatter.timeStyle = NSDateFormatterNoStyle;
        }
        return [formatter stringFromDate:date];
    }
}

+ (MCTlong)updateTimestampIn:(MCTlong)timestampInSeconds
{
    MCTlong now = [MCTUtils currentServerTime];
    MCTlong second = 1;
    MCTlong minute = 60;
    MCTlong hour = 60 * minute;
    MCTlong day = 24 * hour;
    MCTlong daysDifference = floor(now / day) - floor(timestampInSeconds / day);

    if (daysDifference < 1) {
        MCTlong hoursDifference = floor((now - timestampInSeconds) / hour);
        if (hoursDifference < 1) {
            MCTlong minutesDifference = floor((now - timestampInSeconds) / minute);

            if (minutesDifference >= 0) {
                MCTlong secondsDifference = floor((now - timestampInSeconds) / second);
                return (60 - (secondsDifference % 60));
            }
        }
    }
    return 0;
}

+ (NSString *)timestamp:(MCTlong)timestampInSeconds withFormat:(NSString *)format
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestampInSeconds];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

+ (NSString *)urlEncodeValue:(NSString *)unencodedString
{
    CFStringRef escapeChars = (CFStringRef) @":/?#[]@!$&’()*+,;=";
    NSString *encodedString = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) unencodedString, NULL, escapeChars, kCFStringEncodingUTF8));
    return encodedString;
}

+ (NSString *)mcCurrentQueueName
{
    if ([NSThread isMainThread])
         return @"UI";
    NSString *name = nil;
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    if ([currentQueue isKindOfClass:[MCTOperationQueue class]])
        name = ((MCTOperationQueue *) currentQueue).name;
    return name;
}

+ (NSString *)stackTraceFromException:(NSException *)exception
{
    return [[exception callStackSymbols] componentsJoinedByString:@"\n"];
}

+ (NSString *)currentStackTrace
{
    return [[NSThread callStackSymbols] componentsJoinedByString:@"\n"];
}

+ (NSString *)callerMethod
{
    return @"";
    NSArray *array = [[[NSThread callStackSymbols] objectAtIndex:2]
                      componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-["]];
    return [NSString stringWithFormat:@"-[%@", [array lastObject]];
}

+ (void)resetLastTimeSoundPlayed
{
    T_DONTCARE();
    LAST_TIME_SOUND_PLAYED = [MCTUtils currentTimeMillis];
}

+ (void)playNotificationSound
{
    T_DONTCARE();
    if ([MCTUtils currentTimeMillis] - LAST_TIME_SOUND_PLAYED < 5000)
        return;

    LOG(@"* playing sound notification *");

//    NSURL *filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"msg-received" ofType:@"wav"]
//                                 isDirectory:NO];
//
//    SystemSoundID soundID;
//    AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
//    AudioServicesPlaySystemSound(soundID);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    [MCTUtils resetLastTimeSoundPlayed];
}

+ (BOOL)connectedToInternet
{
    return [[Reachability reachabilityForInternetConnection] isReachable];
}

+ (BOOL)connectedToWifi
{
    return [[Reachability reachabilityForLocalWiFi] isReachable];
}

+ (BOOL)connectedToInternetAndXMPP
{
    return [MCTUtils connectedToInternet] && (!MCT_USE_XMPP_KICK_CHANNEL || [[[[MCTComponentFramework commManager] xmppConnection] xmppStream] isConnected]);
}

+ (BOOL)deviceCanMakePhoneCalls
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:+11111"]];
}

+ (BOOL)deviceSupportsMultitasking
{
    UIDevice* device = [UIDevice currentDevice];
    return [device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported;
}

+ (BOOL)isEmptyOrWhitespaceString:(id)s
{
    return !TTIsStringWithAnyText(s) || [((NSString *)s) isWhitespaceAndNewlines];
}

+ (BOOL)isString:(NSString *)s1 equalToString:(NSString *)s2
{
    if (s1 == s2)
        return YES;

    if (s1 == nil || s1 == MCTNull)
        return (s2 == nil || s2 == MCTNull);

    return [s1 isEqualToString:s2];
}

+ (NSString *)preferredLanguage
{
    return [MCTLocaleInfo info].language;
}

+ (NSString *)stringByAppendingTargetForFacebookImageURL:(NSString *)fbImgURL
{
    if ([MCTUtils isEmptyOrWhitespaceString:fbImgURL])
        return nil;

    NSDictionary * args = [NSDictionary dictionaryWithObjectsAndKeys:@"phone", @"from", @"fbWall", @"target", nil];

    NSRange r = [fbImgURL rangeOfString:@"?"];
    NSString *s = (r.length == 0) ? @"?" : @"&";
    return [NSString stringWithFormat:@"%@%@%@", fbImgURL, s, [args gtm_httpArgumentsString]];
}

+ (BOOL)deviceIsSimulator
{
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

+ (MCTlong)floor:(MCTlong)value withInterval:(MCTlong)interval
{
    return value - value % interval;
}

+ (NSString *)deviceId
{
    IF_IOS6_OR_GREATER(
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    );
    // No longer allowed by Apple
    return @"ios_device_id";
}

+ (NSString *)stringForSize:(MCTlong)size
{
    T_DONTCARE();
    if (size > MB) {
        CGFloat actualSize = (CGFloat)size / MB;
        return [NSString stringWithFormat:@"%.02f%@", actualSize, NSLocalizedString(@"MB", @"megabyte")];
    } else {
        CGFloat actualSize = size / KB;
        return [NSString stringWithFormat:@"%.00f%@", actualSize, NSLocalizedString(@"KB", @"kilobyte")];
    }
}

+ (NSString *)fileExtensionWithMimeType:(NSString *)mimeTypeString
{
    T_DONTCARE();
    // http://blog.ablepear.com/2010/08/how-to-get-file-extension-for-mime-type.html
    // get a UTI for a mime type
    CFStringRef mimeType = (__bridge CFStringRef) mimeTypeString;
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType, NULL);
    CFStringRef extension = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
    CFRelease(uti);
    NSString *extensionString = (__bridge NSString *)extension;
    return OR(extensionString, @"");
}

+ (NSString *)fileSHA256:(NSURL *)fileURL error:(NSError **)error;
{
    T_DONTCARE();
    NSInteger chunkSize = 1024;     //Read 1KB chunks.
    CC_SHA256_CTX ctx;
    CC_SHA256_Init(&ctx);

    NSError *error2 = nil;
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&error2];
    if (error2) {
        *error = error2;
        return nil;
    }

    @try {
        while (YES) {
            NSData *data = [handle readDataOfLength:chunkSize];
            CC_SHA256_Update(&ctx, [data bytes], (CC_LONG)[data length]);
            if ([data length] == 0)
                break;
        }
    }
    @finally {
        [handle closeFile];
    }

    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256_Final(digest, &ctx);

    NSInteger length = sizeof(digest);
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:(length * 2)];
    for (int i = 0; i < length; ++i)
        [stringBuffer appendFormat:@"%02x", digest[i]];

    return [stringBuffer copy];
}


#pragma mark -

+ (NSString *)nameForBeaconWithMajor:(NSNumber *)major
                               minor:(NSNumber *)minor
{
    return [NSString stringWithFormat:@"%@|%@", major, minor];
}

+ (NSString *)nameForBeacon:(CLBeacon *)beacon
{
    return [MCTUtils nameForBeaconWithMajor:beacon.major minor:beacon.minor];
}

+ (NSString *)keyForBeaconWithUUID:(NSString *)uuidString
                              name:(NSString *)name
{
    return [NSString stringWithFormat:@"%@|%@", uuidString, name];
}

+ (NSString *)keyForBeacon:(CLBeacon *)beacon
{
    return [MCTUtils keyForBeaconWithUUID:[beacon.proximityUUID UUIDString]
                                             name:[MCTUtils nameForBeacon:beacon]];
}

+ (NSString *)keyForBeaconRegion:(CLBeaconRegion *)region
{
    return [NSString stringWithFormat:@"%@|%@|%@", region.proximityUUID, region.major, region.minor];
}

+ (NSString *)keyForBeaconRegionTO:(MCT_com_mobicage_to_beacon_BeaconRegionTO *)regionTO
{
    return [NSString stringWithFormat:@"%@|%@|%@", regionTO.uuid,
            regionTO.has_major ? [NSNumber numberWithLongLong:regionTO.major] : nil,
            regionTO.has_minor ? [NSNumber numberWithLongLong:regionTO.minor] : nil];
}

+ (CLBeaconRegion *)beaconRegionFromBeaconRegionTO:(MCT_com_mobicage_to_beacon_BeaconRegionTO *)regionTO
{
    NSString *beaconRegionKey = [MCTUtils keyForBeaconRegionTO:regionTO];
    if (regionTO.has_minor) {
        return [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:regionTO.uuid]
                                                        major:(CLBeaconMajorValue)regionTO.major
                                                        minor:(CLBeaconMajorValue)regionTO.minor
                                                   identifier:beaconRegionKey];
    } else if (regionTO.has_major) {
        return [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:regionTO.uuid]
                                                        major:(CLBeaconMajorValue)regionTO.major
                                                   identifier:beaconRegionKey];
    } else {
        return [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:regionTO.uuid]
                                                  identifier:beaconRegionKey];
    }
}

+ (NSString *)stringFromBeaconRegion:(CLBeaconRegion *)region
{
    T_DONTCARE();
    return [NSString stringWithFormat:@"{ uuid: %@, major: %@, minor: %@ }",
            [region.proximityUUID UUIDString], region.major, region.minor];
}

+ (NSString *)stringFromBeacon:(CLBeacon *)beacon
{
    T_DONTCARE();
    return [NSString stringWithFormat:@"{ uuid: %@, major: %@, minor: %@, proximity: %@ }",
            [beacon.proximityUUID UUIDString], beacon.major, beacon.minor,
            [self stringFromCLProximity:beacon.proximity]];
}

+ (NSString *)stringFromCLRegionState:(CLRegionState)state
{
    switch (state) {
        case CLRegionStateInside:
            return @"INSIDE";
        case CLRegionStateOutside:
            return @"OUTSIDE";
        case CLRegionStateUnknown:
            return @"UNKNOWN";
        default:
            return [NSString stringWithFormat:@"CLRegionState<%ld>", (long)state];
    }
}

+ (NSString *)stringFromCLProximity:(CLProximity)proximity
{
    switch (proximity) {
        case CLProximityFar:
            return @"FAR";
        case CLProximityNear:
            return @"NEAR";
        case CLProximityImmediate:
            return @"IMMEDIATE";
        case CLProximityUnknown:
            return @"UNKNOWN";
        default:
            return [NSString stringWithFormat:@"CLProximity<%ld>", (long)proximity];
    }
}

+ (BOOL)iBeaconsSupported
{
    IF_PRE_IOS7({
        BEACON_LOG(@"Pre-iOS7: iBeacons not supported");
        return NO;
    });

    if ([MCTUtils deviceIsSimulator]) {
        return NO;
    }

    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        BEACON_LOG(@"CLLocationManager: does not support CLBeaconRegions.");
        return NO;
    }

    CBCentralManager *cbMgr = [[CBCentralManager alloc] initWithDelegate:nil
                                                                    queue:nil
                                                                  options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
    CBCentralManagerState cbState = cbMgr.state;
    if (cbState == CBCentralManagerStateUnsupported) {
        BEACON_LOG(@"CBCentralManagerState: The platform does not support Bluetooth low energy.");
        return NO;
    } else if (cbState == CBCentralManagerStateUnauthorized) {
        BEACON_LOG(@"CBCentralManagerState: The app is not authorized to use Bluetooth low energy.");
        return NO;
    }

    return YES;
}

+ (BOOL)doesBeacon:(CLBeacon *)beacon
    belongToRegion:(CLBeaconRegion *)region __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0)
{
    return [region.proximityUUID isEqual:beacon.proximityUUID]
        && (region.major == nil || [region.major isEqualToNumber:beacon.major])
        && (region.minor == nil || [region.minor isEqualToNumber:beacon.minor]);
}

// See https://developer.apple.com/library/ios/qa/qa1719/_index.html
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);

    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        ERROR(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

#pragma mark - oauth

+ (void)startOauthWithVC:(UIViewController *)vc
            authorizeUrl:(NSString *)authorizeUrl
                  scopes:(NSString *)scopes
                   state:(NSString *)state
                clientId:(NSString *)clientId
{
    T_UI();

    NSDictionary *params = @{@"state": state,
                             @"client_id": clientId,
                             @"scope": scopes,
                             @"redirect_uri": [NSString stringWithFormat:@"oauth-%@://x-callback-url", MCT_PRODUCT_ID],
                             @"response_type": @"code"};

    NSString *url = [authorizeUrl stringByAddingURLEncodedQueryDictionary:params];

    IF_PRE_IOS9({
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    })

    IF_IOS9_OR_GREATER({
        SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
        [vc presentViewController:safari animated:YES completion:nil];
    })
}

@end



@implementation NSData (MCTBase64)

- (NSString *)MCTBase64Encode
{
    NSString *encodedStrWithNewlines = [self base64EncodedString];
    const char *orig = [encodedStrWithNewlines cStringUsingEncoding:NSASCIIStringEncoding];
    char *result = malloc(([encodedStrWithNewlines length] + 1) * sizeof(char));
    if (result == NULL)
        return nil;

    char *p = (char *)orig;
    char *q = result;
    while (*p) {
        if ((*p == '\r') || (*p == '\n')) {
            p++;
            continue;
        }
        *q++ = *p++;
    }
    *q = '\0';
    NSString *resultStr = [NSString stringWithCString:result encoding:NSASCIIStringEncoding];
    free(result);
    return resultStr;
}

@end


@implementation NSString (MCTBase64)

// Base64 encode this string into another string with no newlines
// E.g. can be used as value in a HTTP header
// Assume NSASCIIEncoding
- (NSString *)MCTBase64Encode
{
    return [[self dataUsingEncoding:NSASCIIStringEncoding] MCTBase64Encode];
}

// Base64 decode this string into a string (assume NSASCIIStringEncoding)
- (NSString *)MCTBase64Decode
{
    NSData *decodedData = [NSData dataFromBase64String:self];
    return [NSString stringWithCString:[decodedData bytes] encoding:NSASCIIStringEncoding];
}

@end


@implementation NSString (MCTUtils)

- (NSString *)stringByTruncatingTailWithLength:(int)length
{
    if ([self length] > length)
        return [NSString stringWithFormat:@"%@…", [self substringToIndex:length - 4]];

    return self;
}

- (NSString *)stringByTrimming
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)containsString:(NSString *)s
{
    return [self rangeOfString:s].location != NSNotFound;
}

- (NSRange)range
{
    return NSMakeRange(0, [self length]);
}

+ (NSString *)stringWithUTF8StringSafe:(const unsigned char *)value
{
    return (value == NULL) ? nil : [NSString stringWithUTF8String:(const char *)value];
}

- (BOOL)isAlphaNumeric
{
    NSCharacterSet *unwantedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    return [self rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound;
}

- (NSInteger)numberOfLines
{
    NSInteger numberOfLines, index, stringLength = [self length];
    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++)
        index = NSMaxRange([self lineRangeForRange:NSMakeRange(index, 0)]);
    return numberOfLines;
}

+ (NSString *)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
    return [[NSString alloc] initWithData:data encoding:encoding];
}

@end


@implementation NSArray (MCTUtils)

- (BOOL)containsAll:(NSArray *)objects
{
    for (id object in objects)
        if (![self containsObject:object])
            return NO;

    return YES;
}

@end


@implementation NSMutableArray (MCTUtils)

- (void)sortByKeys:(NSString *)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray *sortDescriptors = [NSMutableArray array];

    if (firstKey) {
        [sortDescriptors addObject:[[NSSortDescriptor alloc] initWithKey:firstKey
                                                                ascending:YES
                                                                 selector:@selector(localizedCaseInsensitiveCompare:)]];

        id eachKey;
        va_list keyList;

        va_start(keyList, firstKey);
        while ((eachKey = va_arg(keyList, id)))
            [sortDescriptors addObject:[[NSSortDescriptor alloc] initWithKey:eachKey
                                                                    ascending:YES
                                                                     selector:@selector(localizedCaseInsensitiveCompare:)]];
        va_end(keyList);
    }

    [self sortUsingDescriptors:sortDescriptors];
}

@end