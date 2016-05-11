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

#import "MCTRPCCall.h"
#import "MCTSingleCall.h"

#import "MCTJSONUtils.h"

static NSArray *singleCalls;
static NSArray *specialSingleCalls;
static NSArray *wifiOnlyCalls;


@implementation MCTRPCCall


+ (void)initialize
{
    if (!singleCalls) {
        singleCalls = [[NSArray alloc] initWithObjects:
                       @"com.mobicage.api.friends.getGroups",
                       @"com.mobicage.api.friends.getFriendEmails",
                       @"com.mobicage.api.friends.getFriendInvitationSecrets",
                       @"com.mobicage.api.friends.findRogerthatUsersViaEmail",
                       @"com.mobicage.api.friends.findRogerthatUsersViaFacebook",
                       @"com.mobicage.api.location.getBeaconRegions",
                       @"com.mobicage.api.location.getFriendLocation",
                       @"com.mobicage.api.location.getFriendLocations",
                       @"com.mobicage.api.system.heartBeat",
                       @"com.mobicage.api.system.getIdentity",
                       @"com.mobicage.api.system.saveSettings",
                       @"com.mobicage.api.system.updateApplePushDeviceToken",
                       @"com.mobicage.api.system.unregisterMobile",
                       nil];
    }

    if (!specialSingleCalls) {
        specialSingleCalls = [MCTAbstractSingleCall specialSingleCalls];
    }

    if (!wifiOnlyCalls) {
        wifiOnlyCalls = [[NSArray alloc] initWithObjects:@"com.mobicage.api.messaging.uploadChunk", nil];
    }
}

- (MCTRPCCall *)initWithDict:(NSDictionary *)dict
{
    T_DONTCARE();
    if (self = [super initWithDict:dict]) {

        self.function = [dict stringForKey:@"f"];
        if ((self.function == nil) || (self.function == MCTNull))
            goto error_in_constructor;

        self.arguments = [dict dictForKey:@"a"];
        if ((self.arguments == nil) || (self.arguments == MCTNull))
            goto error_in_constructor;

    }
    return self;

error_in_constructor:
    ERROR(@"Cannot parse RPC call: %@", dict);
    return nil;
}

- (NSDictionary *)dictRepresentation
{
    T_DONTCARE();
    NSMutableDictionary *dict = (NSMutableDictionary *)[super dictRepresentation];
    [dict setString:self.function forKey:@"f"];
    [dict setDict:self.arguments forKey:@"a"];
    return dict;
}

+ (MCTRPCCall *)call
{
    T_BACKLOG();
    return [[MCTRPCCall alloc] init];
}

+ (MCTRPCCall *)callWithDict:(NSDictionary *)dict
{
    T_DONTCARE();
    return [[MCTRPCCall alloc] initWithDict:dict];
}

+ (BOOL)isSingleCallFunction:(NSString *)func
{
    T_DONTCARE();
    BOOL isSSingleCall = [singleCalls containsObject:func];
    return isSSingleCall;
}

- (BOOL)isSingleCall
{
    T_DONTCARE();
    return [MCTRPCCall isSingleCallFunction:self.function];
}

+ (BOOL)isSpecialSingleCallFunction:(NSString *)func
{
    T_DONTCARE();
    BOOL isSpecialSSingleCall = [specialSingleCalls containsObject:func];
    return isSpecialSSingleCall;
}

- (BOOL)isSpecialSingleCall
{
    T_DONTCARE();
    return [MCTRPCCall isSpecialSingleCallFunction:self.function];
}

+ (BOOL)isWifiOnlyCallFunction:(NSString *)func
{
    T_DONTCARE();
    BOOL isWifiOnlyCall = [wifiOnlyCalls containsObject:func];
    LOG(@"WIFI-ONLY: %@ - %@", BOOLSTR(isWifiOnlyCall), func);
    return isWifiOnlyCall;
}

- (BOOL)isWifiOnlyCall
{
    T_DONTCARE();
    return [MCTRPCCall isWifiOnlyCallFunction:self.function];
}

- (BOOL)isEqualToSpecialSingleCallWithBody:(NSString *)callBody
{
    T_DONTCARE();
    MCTAbstractSingleCall *call = [MCTAbstractSingleCall singleCallWithFunction:self.function
                                                                      arguments:[self.arguments objectForKey:@"request"]];
    if (call == nil)
        return NO;
    NSDictionary *args = [callBody MCT_JSONValue];
    return [call isEqualToFunctionWithArguments:[args objectForKey:@"a"]];
}

@end