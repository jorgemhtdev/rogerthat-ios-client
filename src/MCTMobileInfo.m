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

#import "MCTMobileInfo.h"
#import "MCTUtils.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "UIDeviceHardware.h"

#define TYPE_IPHONE_LEGACY          2 // legacy ... used when version < 0.94 (location support)
#define TYPE_IPHONE_XMPP_LEGACY     5 // legacy ... used when version < 0.216 (xmpp backlog)
#define TYPE_IPHONE_HTTP_APNS_KICK  7
#define TYPE_IPHONE_HTTP_XMPP_KICK  8


@implementation MCTCarrierInfo

+ (MCTCarrierInfo *)info
{
    CTTelephonyNetworkInfo *network = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = network.subscriberCellularProvider;

    MCTCarrierInfo *info = [[MCTCarrierInfo alloc] init];
    info.isoCountryCode = carrier.isoCountryCode;
    info.mobileCountryCode = carrier.mobileCountryCode;
    info.mobileNetworkCode = carrier.mobileNetworkCode;
    info.carrierName = carrier.carrierName;
    return info;
}

- (NSString *)fingerPrint
{
    return [NSString stringWithFormat:@"%@ | %@ | %@ | %@", self.isoCountryCode, self.mobileCountryCode,
            self.mobileNetworkCode, self.carrierName];
}

@end

#pragma mark -

@implementation MCTLocaleInfo

+ (MCTLocaleInfo *)info
{
    NSLocale *locale = [NSLocale currentLocale];

    MCTLocaleInfo *info = [[MCTLocaleInfo alloc] init];
    NSString *language = [NSLocale preferredLanguages][0];
    if ([@"pt-PT" isEqualToString:language]) {
        info.language = @"pt";
        info.country = @"PT";
    } else if ([@"pt" isEqualToString:language]) {
        info.language = @"pt";
        info.country = @"BR";
    } else if ([language containsString:@"-"]) {
        NSArray *splitted = [language componentsSeparatedByString:@"-"];
        info.language = splitted[0];
        info.country = splitted[1];
    } else {
        info.language = language;
        info.country = [locale objectForKey:NSLocaleCountryCode];
    }
    return info;
}

- (NSString *)fingerPrint
{
    return [NSString stringWithFormat:@"%@ | %@", self.language, self.country];
}

@end

#pragma mark -

@implementation MCTTimeZoneInfo

+ (MCTTimeZoneInfo *)info
{
    NSTimeZone *localTimeZone =[NSTimeZone localTimeZone];

    MCTTimeZoneInfo *info = [[MCTTimeZoneInfo alloc] init];
    info.abbrevation = localTimeZone.abbreviation;
    info.secondsFromGMT = localTimeZone.secondsFromGMT;
    return info;
}

- (NSString *)fingerPrint
{
    return [NSString stringWithFormat:@"%@ | %ld", self.abbrevation, (long)self.secondsFromGMT];
}

@end

#pragma mark -

@implementation MCTDeviceInfo

+ (MCTDeviceInfo *)info
{
    MCTDeviceInfo *info = [[MCTDeviceInfo alloc] init];
    info.modelName = [UIDeviceHardware platformString];
    info.osVersion = [UIDevice currentDevice].systemVersion;
    return info;
}

- (NSString *)fingerPrint
{
    return [NSString stringWithFormat:@"%@ | %@", self.modelName, self.osVersion];
}

@end

#pragma mark -

@implementation MCTApplicationInfo

+ (MCTApplicationInfo *)info
{

    MCTApplicationInfo *info = [[MCTApplicationInfo alloc] init];
    info.name = [NSString stringWithFormat:@"iOS %@", MCT_PRODUCT_NAME];
    info.type = [MCTApplicationInfo type];
    NSArray *splitted = [MCT_PRODUCT_VERSION componentsSeparatedByString:@"."];
    info.majorVersion = [[splitted objectAtIndex:1] intValue];
    info.minorVersion = [[splitted objectAtIndex:2] intValue];
    return info;
}

+ (NSInteger)type
{
    return MCT_USE_XMPP_KICK_CHANNEL ? TYPE_IPHONE_HTTP_XMPP_KICK : TYPE_IPHONE_HTTP_APNS_KICK;
}

- (NSString *)fingerPrint
{
    return [NSString stringWithFormat:@"%@ | %ld | %ld | %ld",
            self.name, (long)self.type, (long)self.minorVersion, (long)self.majorVersion];
}

@end

#pragma mark -

@implementation MCTMobileInfo

+ (MCTMobileInfo *)info
{
    MCTMobileInfo *info = [[MCTMobileInfo alloc] init];
    info.carrier = [MCTCarrierInfo info];
    info.locale = [MCTLocaleInfo info];
    info.timeZone = [MCTTimeZoneInfo info];
    info.device = [MCTDeviceInfo info];
    info.app = [MCTApplicationInfo info];
    return info;
}

- (NSString *)fingerPrint
{
    return [[NSArray arrayWithObjects:[self.carrier fingerPrint],
             [self.locale fingerPrint],
             [self.timeZone fingerPrint],
             [self.device fingerPrint],
             [self.app fingerPrint], nil] componentsJoinedByString:@" | "];
}

@end