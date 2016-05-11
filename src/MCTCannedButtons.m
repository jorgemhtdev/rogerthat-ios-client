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
#import "MCTComponentFramework.h"
#import "MCTPickler.h"
#import "MCTCannedButtons.h"
#import "MCTUtils.h"

#import "NSData+Base64.h"

#define PICKLE_CLASS_VERSION 1
#define PICKLE_BUTTON_KEY @"buttons"

#define BUTTON_CONFIG_KEY @"CANNED_BUTTONS"


@implementation MCTCannedButtons


+ (MCTCannedButtons *)buttons
{
    T_DONTCARE();
    MCTConfigProvider *cfg = [MCTComponentFramework configProvider];
    NSString *base64String = [cfg stringForKey:BUTTON_CONFIG_KEY];

    MCTCannedButtons *btns;
    if (base64String == nil) {
        btns = [[MCTCannedButtons alloc] init];
        btns.buttons = [NSMutableArray array];
    } else {
        btns = (MCTCannedButtons *) [MCTPickler objectFromPickle:[NSData dataFromBase64String:base64String]];
        NSSortDescriptor *sortUsed = [[NSSortDescriptor alloc] initWithKey:@"usedCount" ascending:NO];
        NSSortDescriptor *sortCaption = [[NSSortDescriptor alloc] initWithKey:@"caption"
                                                                     ascending:YES
                                                                      selector:@selector(localizedCaseInsensitiveCompare:)];
        [btns.buttons sortUsingDescriptors:[NSArray arrayWithObjects:sortUsed, sortCaption, nil]];
    }

    if ([btns.buttons count] == 0) {
        [btns addButtonWithCaption:NSLocalizedString(@"No idea", nil) andAction:nil];
        [btns addButtonWithCaption:NSLocalizedString(@"Don't like", nil) andAction:nil];
        [btns addButtonWithCaption:NSLocalizedString(@"Like", nil) andAction:nil];
        [btns addButtonWithCaption:NSLocalizedString(@"Ok", nil) andAction:nil];
        [btns addButtonWithCaption:NSLocalizedString(@"Maybe", nil) andAction:nil];
        [btns addButtonWithCaption:NSLocalizedString(@"No", nil) andAction:nil];
        [btns addButtonWithCaption:NSLocalizedString(@"Yes", nil) andAction:nil];

        [[btns.buttons objectAtIndex:0] setUsedCount:1];
    }

    return btns;
}

- (id)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_DONTCARE();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    if (self = [super init]) {
        self.buttons = (NSMutableArray *) [coder decodeObjectForKey:PICKLE_BUTTON_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    [coder encodeObject:self.buttons forKey:PICKLE_BUTTON_KEY];
}

- (int)classVersion
{
    T_DONTCARE();
    return PICKLE_CLASS_VERSION;
}

- (void)save
{
    T_DONTCARE();
    NSData *pickle = [MCTPickler pickleFromObject:self];
    NSString *base64String = [pickle base64EncodedString];

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [[MCTComponentFramework configProvider] setString:base64String forKey:BUTTON_CONFIG_KEY];
    }];
}

- (void)addButtonWithCaption:(NSString *)caption andAction:(NSString *)action
{
    T_DONTCARE();
    MCTButton *btn = [MCTButton button];
    btn.caption = caption;
    btn.action = [MCTUtils isEmptyOrWhitespaceString:action] ? nil : action;
    btn.idX = [MCTUtils guid];
    btn.usedCount = 0;
    [self.buttons insertObject:btn atIndex:0];
    [self save];
}

- (MCTButton *)buttonWithId:(NSString *)idX
{
    T_DONTCARE();
    for (MCTButton *btn in self.buttons)
        if ([btn.idX isEqualToString:idX])
            return btn;
    return nil;
}


@end