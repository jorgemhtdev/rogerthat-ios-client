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

#import "MCTDefaultResponseHandler.h"
#import "MCTComponentFramework.h"

#define PICKLE_CLASS_VERSION 1

@implementation MCTDefaultResponseHandler

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Default response handler received error result: %@", error);
}

- (void)handleResult:(id)result
{
    T_BIZZ();
    LOG(@"Default response handler received/ignored success result: %@", result);
}

- (id)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    self = [super initWithCoder:coder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

+ (MCTDefaultResponseHandler *)defaultResponseHandler
{
    T_DONTCARE();
    return [[MCTDefaultResponseHandler alloc] init]; // Problem
}

@end