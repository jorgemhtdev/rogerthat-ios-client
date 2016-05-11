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

// This file is generated. DO NOT MODIFY

#import "MCTComponentFramework.h"
#import "MCTHomeScreenVC.h"
#import "MCTLocationUsageVC.h"

@implementation MCTHomeScreenVC


- (void)viewDidLoad
{
    self.items = [NSMutableDictionary dictionary];

    [self.items setObject:[MCTHomeScreenItem homeScreenItemWithPositionY:0
                                                                       x:0
                                                                   label:NSLocalizedString(@"Messages", nil)
                                                                   click:@"messages"
                                                                  coords:nil
                                                                collapse:NO]
                   forKey:@"0x0"];

    [self.items setObject:[MCTHomeScreenItem homeScreenItemWithPositionY:0
                                                                       x:1
                                                                   label:NSLocalizedString(@"Report Card", nil)
                                                                   click:nil
                                                                  coords:@[@(2), @(1), @(0)]
                                                                collapse:NO]
                   forKey:@"0x1"];

    [self.items setObject:[MCTHomeScreenItem homeScreenItemWithPositionY:0
                                                                       x:2
                                                                   label:NSLocalizedString(@"Community Services", nil)
                                                                   click:@"community_services"
                                                                  coords:nil
                                                                collapse:YES]
                   forKey:@"0x2"];

    [self.items setObject:[MCTHomeScreenItem homeScreenItemWithPositionY:1
                                                                       x:0
                                                                   label:NSLocalizedString(@"Agenda", nil)
                                                                   click:nil
                                                                  coords:@[@(0), @(2), @(0)]
                                                                collapse:NO]
                   forKey:@"1x0"];

    [self.items setObject:[MCTHomeScreenItem homeScreenItemWithPositionY:1
                                                                       x:1
                                                                   label:NSLocalizedString(@"Merchants", nil)
                                                                   click:@"merchants"
                                                                  coords:nil
                                                                collapse:NO]
                   forKey:@"1x1"];

    [self.items setObject:[MCTHomeScreenItem homeScreenItemWithPositionY:1
                                                                       x:2
                                                                   label:NSLocalizedString(@"Associations", nil)
                                                                   click:@"associations"
                                                                  coords:nil
                                                                collapse:NO]
                   forKey:@"1x2"];

    [self.items setObject:[MCTHomeScreenItem homeScreenItemWithPositionY:2
                                                                       x:0
                                                                   label:NSLocalizedString(@"Scan", nil)
                                                                   click:@"scan"
                                                                  coords:nil
                                                                collapse:NO]
                   forKey:@"2x0"];

    [self.items setObject:[MCTHomeScreenItem homeScreenItemWithPositionY:2
                                                                       x:1
                                                                   label:NSLocalizedString(@"Care", nil)
                                                                   click:@"emergency_services"
                                                                  coords:nil
                                                                collapse:NO]
                   forKey:@"2x1"];

    [self.items setObject:[MCTHomeScreenItem homeScreenItemWithPositionY:2
                                                                       x:2
                                                                   label:NSLocalizedString(@"More", nil)
                                                                   click:@"more"
                                                                  coords:nil
                                                                collapse:NO]
                   forKey:@"2x2"];

    [super viewDidLoad];
}

- (void)startLocationUsage
{
    T_UI();
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_LOCATION_START_AUTOMATIC_DETECTION];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (MCTHomeScreenItem *)itemForPositionX:(MCTlong)x y:(MCTlong)y
{
    NSString *key = [NSString stringWithFormat:@"%lldx%lld", y, x];

    if ([self.items containsKey:key]) {
        return [self.items valueForKey:key];
    }
    return nil;
}

@end