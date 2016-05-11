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


#import "MCTHeartbeatResponseHandler.h"
#import "MCTComponentFramework.h"

#define PICKLE_CLASS_VERSION 2

#define PICKLE_TIMESTAMP_KEY @"requestSubmissionTimestamp"


@implementation MCTHeartbeatResponseHandler


- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response got heartbeat request: %@", error);
}

- (void)handleResult:(id)result
{
    T_BIZZ();
    LOG(@"Result received for heartbeat request: %@", result);
}

- (MCTHeartbeatResponseHandler *)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    self = [super initWithCoder:coder];
    if (self) {
        self.requestSubmissionTimestamp = [coder decodeInt64ForKey:PICKLE_TIMESTAMP_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
    [coder encodeInt64:self.requestSubmissionTimestamp forKey:PICKLE_TIMESTAMP_KEY];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end