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

#import "MCTContactEntry.h"
#import "MCTUtils.h"

#import "NSData+Base64.h"

#pragma mark MCTPhoneNumber

@implementation MCTContactField


+ (MCTContactField *)fieldWithLabel:(NSString *)label andValue:(NSString *)value
{
    T_DONTCARE();
    MCTContactField *cf = [[MCTContactField alloc] init];
    cf.label = label;
    cf.value = value;
    return cf;
}

- (MCTContactField *)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.label = [dict stringForKey:@"label"];
        self.value = [dict stringForKey:@"value"];
    }
    return self;
}

- (NSDictionary *)dictRepresentation
{
    T_DONTCARE();
    return [NSDictionary dictionaryWithObjectsAndKeys:self.value, @"value", self.label, @"label", nil];
}

- (NSString *)description
{
    T_DONTCARE();
    return [NSString stringWithFormat:@"%@ (%@)", self.value, self.label];
}

@end


#pragma mark -
#pragma mark MCTContactEntry

@implementation MCTContactEntry

- (MCTContactEntry *)init
{
    if (self = [super init]) {
        self.emails = [NSArray array];
        self.numbers = [NSArray array];
    }
    return self;
}

- (MCTContactEntry *)initWithDict:(NSDictionary *)dict
{
    T_DONTCARE();
    if (self = [super init]) {
        self.name = [dict objectForKey:@"name"];

        NSMutableArray *emails = [NSMutableArray array];
        for (NSDictionary *d in [dict arrayForKey:@"emails"]) {
            [emails addObject:[[MCTContactField alloc] initWithDict:d]];
        }
        self.emails = emails;

        NSMutableArray *numbers = [NSMutableArray array];
        for (NSDictionary *d in [dict arrayForKey:@"numbers"]) {
            [numbers addObject:[[MCTContactField alloc] initWithDict:d]];
        }
        self.numbers = numbers;

        NSString *imageStr = [dict objectForKey:@"image"];
        if (![MCTUtils isEmptyOrWhitespaceString:imageStr]) {
            self.image = [NSData dataFromBase64String:imageStr];
        }
    }
    return self;
}

- (NSDictionary *)dictRepresentation
{
    T_DONTCARE();
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [d setString:self.name forKey:@"name"];

    [d setString:[self.image base64EncodedString] forKey:@"image"];

    NSMutableArray *emails = [NSMutableArray array];
    for (MCTContactField *field in self.emails) {
        [emails addObject:[field dictRepresentation]];
    }
    [d setArray:emails forKey:@"emails"];

    NSMutableArray *numbers = [NSMutableArray array];
    for (MCTContactField *field in self.numbers) {
        [numbers addObject:[field dictRepresentation]];
    }
    [d setArray:numbers forKey:@"numbers"];

    return d;
}


@end