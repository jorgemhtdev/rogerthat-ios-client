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

#import "MCTButton.h"

#define PICKLE_CLASS_VERSION 1
#define PICKLE_BUTTON_ID @"id"
#define PICKLE_BUTTON_CAPTION @"caption"
#define PICKLE_BUTTON_ACTION @"action"
#define PICKLE_BUTTON_USEDCOUNT @"usedCount"


@implementation MCTButton


+ (MCTButton *)button
{
    T_DONTCARE();
    return [[MCTButton alloc] init];
}

+ (MCTButton *)buttonWithButtonTO:(MCT_com_mobicage_to_messaging_ButtonTO *)btnTO
{
    T_DONTCARE();
    MCTButton *btn = [[MCTButton alloc] initWithDict:[btnTO dictRepresentation]];
    btn.usedCount = 0;
    return btn;
}

- (id)initWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    if (self = [super init]) {
        self.idX = [coder decodeObjectForKey:PICKLE_BUTTON_ID];
        self.caption = [coder decodeObjectForKey:PICKLE_BUTTON_CAPTION];
        self.action = [coder decodeObjectForKey:PICKLE_BUTTON_ACTION];
        if ([coder containsValueForKey:PICKLE_BUTTON_USEDCOUNT]) {
            self.usedCount = [((NSNumber *)[coder decodeObjectForKey:PICKLE_BUTTON_USEDCOUNT]) longLongValue];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    [coder encodeObject:self.idX forKey:PICKLE_BUTTON_ID];
    [coder encodeObject:self.caption forKey:PICKLE_BUTTON_CAPTION];
    [coder encodeObject:self.action forKey:PICKLE_BUTTON_ACTION];
    [coder encodeObject:[NSNumber numberWithLongLong:self.usedCount] forKey:PICKLE_BUTTON_USEDCOUNT];
}

- (BOOL)isEqual:(id)object
{
    T_DONTCARE();
    if ([super isEqual:object]) {
        return YES;
    }
    if ([object isKindOfClass:[MCTButton class]]) {
        MCTButton *btn = object;
        if ([self.idX isEqualToString:btn.idX]) {
            return YES;
        }
        if ([self.caption isEqualToString:btn.caption] && [self.action isEqualToString:btn.action]) {
            return YES;
        }
    }
    return NO;
}

- (void)dealloc
{
    T_DONTCARE();
}

@end