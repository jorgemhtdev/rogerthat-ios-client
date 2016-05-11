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

#import "MCTComponentFramework.h"
#import "MCTIntent.h"
#import "MCTStartServiceActionRH.h"

#define PICKLE_HASH_KEY @"hash"
#define PICKLE_ACTION_KEY @"action"
#define PICKLE_CLASS_VERSION 1


@implementation MCTStartServiceActionRH


+ (MCTStartServiceActionRH *)responseHandlerWithHash:(NSString *)emailHash andAction:(NSNumber *)action
{
    MCTStartServiceActionRH *rh = [[MCTStartServiceActionRH alloc] init];
    rh.hash = emailHash;
    rh.action = action;
    return rh;
}

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for StartServiceAction request: %@", error);
}

- (void)handleResult:(MCT_com_mobicage_to_service_StartServiceActionResponseTO *)result
{
    T_BIZZ();
    LOG(@"Result received for StartServiceAction request");
    HERE();
}

- (id)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (self = [super initWithCoder:coder]) {
        self.hash = [coder decodeObjectForKey:PICKLE_HASH_KEY];
        self.action = [coder decodeObjectForKey:PICKLE_ACTION_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
    [coder encodeObject:self.hash forKey:PICKLE_HASH_KEY];
    [coder encodeObject:self.action forKey:PICKLE_ACTION_KEY];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

- (void)dealloc
{
    T_DONTCARE();
}

@end