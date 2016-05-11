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

#import "MCTActivity.h"
#import "MCTJSONUtils.h"
#import "MCTUtils.h"


@implementation MCTActivity


+ (MCTActivity *)activity
{
    MCTActivity *activity = [[MCTActivity alloc] init];
    activity.timestamp = [MCTUtils currentTimeMillis];
    return activity;
}

- (id)init
{
    if (self = [super init]) {
        self.parameters = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)description
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setLong:self.idX forKey:@"id"];
    [dict setLong:self.timestamp forKey:@"timestamp"];
    [dict setLong:self.type forKey:@"type"];
    [dict setString:self.reference forKey:@"reference"];
    [dict setDict:self.parameters forKey:@"parameters"];
    [dict setString:self.friendReference forKey:@"friend_reference"];
    return [dict description];
}

@end