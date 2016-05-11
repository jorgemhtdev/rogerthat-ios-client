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


#define PICKLE_FUNCTION_KEY @"__MCTFunction"

#import "MCTComponentFramework.h"
#import "MCTAbstractResponseHandler.h"

@implementation MCTAbstractResponseHandler


- (BOOL)isCalledFromSubclass
{
    T_DONTCARE();
    return [self class] != [MCTAbstractResponseHandler class];
}

- /* abstract */ (void)handleError:(NSString *)error
{
    T_BIZZ();
    ERROR(@"Abstract method called");
}

- /* abstract */ (void)handleResult:(id)result
{
    T_BIZZ();
    ERROR(@"Abstract method called");
}

- (id)init
{
    T_DONTCARE();
    self = [super init];
    if (self) {
        if (![self isCalledFromSubclass]) {
            ERROR(@"Cannot instantiate abstract class");
            return nil;
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    ERROR(@"Abstract method called");
    return nil;
}

- (id)initWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    self = [super init];
    if (self) {
        if (![self isCalledFromSubclass]) {
            ERROR(@"Cannot instantiate abstract class");
            return nil;
        }
        self.function = [coder decodeObjectForKey:PICKLE_FUNCTION_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    if (![self isCalledFromSubclass]) {
        ERROR(@"Method should be called from subclass");
    }
    [coder encodeObject:self.function forKey:PICKLE_FUNCTION_KEY];
}

- (int)classVersion
{
    T_BACKLOG();
    ERROR(@"Abstract method called");
    return 0;
}

@end