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

#import "MCTQLPreviewController.h"
#import "MCTUIUtils.h"

@implementation MCTQLPreviewController

- (void)forcePortrait
{
    self.navigationController.navigationBar.translucent = YES;

    [MCTUIUtils forcePortrait];

    // Force resize of navigationBar after rotation
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    T_UI();
    if (![self.navigationController.viewControllers containsObject:self]) {
        // Force change to portrait
        [self forcePortrait];
    }

    [super viewWillDisappear:animated];
}

@end