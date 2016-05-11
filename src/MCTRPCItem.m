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

#import "MCTRPCItem.h"
#import "MCTRPCProtocol.h"

@implementation MCTRPCItem


- (MCTRPCItem *)initWithDict:(NSDictionary *)dict
{
    T_DONTCARE();
    self = [super init];

    if (dict == nil)
        goto error_in_constructor;

    if (self) {

        if (![dict containsLongObjectForKey:@"av"])
            goto error_in_constructor;
        if ([dict longForKey:@"av"] != MCT_PROTOCOL_VERSION)
            goto error_in_constructor;

        self.callid = [dict stringForKey:@"ci"];
        if ((self.callid == nil) || (self.callid == MCTNull))
            goto error_in_constructor;

        if (![dict containsLongObjectForKey:@"t"])
            goto error_in_constructor;
        self.timestamp = [MCTUtils clientTimeFromServerTime:[dict longForKey:@"t"]];

    }
    return self;

error_in_constructor:
    ERROR(@"Cannot construct MCTRPCItem");
    return nil;
}

- (NSDictionary *)dictRepresentation
{
    T_DONTCARE();
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setLong:MCT_PROTOCOL_VERSION forKey:@"av"];
    [dict setString:self.callid forKey:@"ci"];
    [dict setLong:[MCTUtils serverTimeFromClientTime:self.timestamp] forKey:@"t"];
    return dict;
}

- (NSString *)description
{
    T_DONTCARE();
    return [[self dictRepresentation] description];
}

+ (MCTRPCItem *)item
{
    T_DONTCARE();
    return [[MCTRPCItem alloc] init];
}

@end