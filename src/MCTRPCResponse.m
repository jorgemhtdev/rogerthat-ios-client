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

#import "MCTRPCResponse.h"
#import "MCTUtils.h"

#define STATUS_SUCCESS @"success"
#define STATUS_FAILURE @"fail"

@implementation MCTRPCResponse


- (NSDictionary *)dictRepresentation
{
    T_BACKLOG();
    NSMutableDictionary *dict = (NSMutableDictionary *)[super dictRepresentation];

    if (self.success) {
        [dict setDict:self.resultDict forKey:@"r"];
        [dict setString:STATUS_SUCCESS forKey:@"s"];
    } else {
        [dict setString:self.error forKey:@"e"];
        [dict setString:STATUS_FAILURE forKey:@"s"];
    }
    return dict;
}

- (MCTRPCResponse *)initWithDict:(NSDictionary *)dict
{
    T_BACKLOG();
    self = (MCTRPCResponse *)[super initWithDict:dict];

    if (self) {

        NSString *status = [dict stringForKey:@"s"];
        if ((status == nil) || (status == MCTNull))
            goto error_in_constructor;
        if ([status isEqualToString:STATUS_SUCCESS])
            self.success = YES;
        else
            if ([status isEqualToString:STATUS_FAILURE])
                self.success = NO;
            else
                goto error_in_constructor;

        if (self.success) {
            self.resultDict = [dict dictForKey:@"r"];
            if (self.resultDict == nil) {
                ERROR(@"No result dict in response %@", self.callid);
                goto error_in_constructor;
            }
            if (self.resultDict == MCTNull) {
                MCT_RELEASE(self.resultDict);
            }
        } else {
            self.error = [dict stringForKey:@"e"];
        }

    }

    return self;

error_in_constructor:
    ERROR(@"Cannot parse RPC response: %@", dict);
    return nil;
}

+ (MCTRPCResponse *)response
{
    T_BACKLOG();
    return [[MCTRPCResponse alloc] init];
}

+ (MCTRPCResponse *)responseWithDict:(NSDictionary *)dict
{
    T_BACKLOG();
    return [[MCTRPCResponse alloc] initWithDict:dict];
}

@end