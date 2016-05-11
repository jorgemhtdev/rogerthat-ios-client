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

#import "GTMNSDictionary+URLArguments.h"

#import "MCTScanResult.h"

@implementation MCTScanResult


+ (MCTScanResult *)scanResultWithUrl:(NSString *)url
{
    if ([url hasPrefix:MCT_ROGERTHAT_PREFIX]) {
        url = [url stringByReplacingOccurrencesOfString:MCT_ROGERTHAT_PREFIX
                                             withString:MCT_SCAN_URL_PREFIX];
    }
    else if (![url hasPrefix:MCT_SCAN_URL_PREFIX] || [url length] < [MCT_SCAN_URL_PREFIX length]) {
        if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
            return [MCTScanResult scanResultWithAction:MCTScanResultActionURL andParameters:nil];
        } else {
            return nil;
        }
    }

    NSString *paramString = [url substringFromIndex:[MCT_SCAN_URL_PREFIX length]];

    if ([paramString hasPrefix:MCT_URL_PREFIX_INVITE_USER]) {
        NSString *userCode = [paramString substringFromIndex:[MCT_URL_PREFIX_INVITE_USER length]];

        NSRange r = [userCode rangeOfString:@"?"];
        if (r.length == 0) {
            return [MCTScanResult scanResultWithAction:MCTScanResultActionInviteFriend
                                         andParameters:[NSDictionary dictionaryWithObject:userCode forKey:@"userCode"]];
        } else {
            NSString *queryString = [userCode substringFromIndex:NSMaxRange(r)];
            NSDictionary *args = [NSDictionary gtm_dictionaryWithHttpArgumentsString:queryString];
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:args];
            [params setObject:[userCode substringToIndex:r.location] forKey:@"userCode"];
            return [MCTScanResult scanResultWithAction:MCTScanResultActionInvitationWithSecret andParameters:params];
        }
    }

    if ([paramString hasPrefix:MCT_URL_PREFIX_INVITE_SERVICE]) {
        NSArray *args = [[paramString substringFromIndex:[MCT_URL_PREFIX_INVITE_SERVICE length]]
                         componentsSeparatedByString:@"/"];
        if ([args count] != 2) {
            ERROR(@"Invalid amount of arguments (%@) in invite+poke service call", args);
            return nil;
        }

        NSString *userCode = [args objectAtIndex:0];
        NSString *metaData = [args objectAtIndex:1];

        NSMutableDictionary *params = [NSMutableDictionary dictionary];

        NSRange r = [metaData rangeOfString:@"?"];
        if (r.length != 0) {
            NSString *queryString = [metaData substringFromIndex:NSMaxRange(r)];
            metaData = [metaData substringToIndex:r.location];

            [params addEntriesFromDictionary:[NSDictionary gtm_dictionaryWithHttpArgumentsString:queryString]];
        }

        [params setObject:userCode forKey:@"userCode"];
        [params setObject:metaData forKey:@"metaData"];

        return [MCTScanResult scanResultWithAction:MCTScanResultActionService andParameters:params];
    }

    return nil;
}

+ (MCTScanResult *)scanResultWithAction:(MCTScanResultAction)action andParameters:(NSDictionary *)params
{
    return [[MCTScanResult alloc] initWithAction:action andParameters:params];
}

- (MCTScanResult *)initWithAction:(MCTScanResultAction)action andParameters:(NSDictionary *)params
{
    if (self = [super init]) {
        self.action = action;
        self.parameters = params;
    }
    return self;
}

@end