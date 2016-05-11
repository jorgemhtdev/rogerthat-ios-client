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
#import "MCTActivityEnums.h"
#import "MCTActivityPlugin.h"
#import "MCTActivityStore.h"


@implementation MCTActivityPlugin


- (MCTActivityPlugin *)init
{
    T_BIZZ();
    if (self = [super init]) {
        self.store = [[MCTActivityStore alloc] init];
    }
    return self;
}

- (void)logActivityWithText:(NSString *)text andLogLevel:(int)logLevel
{
    T_DONTCARE();
    if (logLevel > MCT_ACTIVITY_LOG_MAX_LOGLEVEL) {
        ERROR(@"%d is not a valid activity log level", logLevel);
        return;
    }

    MCTActivity *activity = [MCTActivity activity];
    activity.type = logLevel;
    activity.reference = nil;
    activity.friendReference = nil;
    [activity.parameters setValue:text forKey:MCT_ACTIVITY_LOG_LINE];

    [self.store saveActivity:activity];
}

- (void)stop
{
    T_BIZZ();
    HERE();
    MCT_RELEASE(self.store);
}

- (void)dealloc
{
    T_BIZZ();
    [self stop];
}

@end