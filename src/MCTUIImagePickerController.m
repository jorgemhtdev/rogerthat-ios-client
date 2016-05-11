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

#import "MCTUIImagePickerController.h"
#import "MCTUIUtils.h"

@implementation MCTUIImagePickerController

- (BOOL)shouldAutorotate
{
    T_UI();
    HERE();
    BOOL shouldAutoRotate = !UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)
        && UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation);
    LOG(@"%@, %@", [self class], BOOLSTR(shouldAutoRotate));
    return shouldAutoRotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    T_UI();
    HERE();
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    T_UI();
    HERE();
    return UIInterfaceOrientationPortrait;
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (!self.view.window) {
        // Fix for device in landscape mode
        if (!UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
            [MCTUIUtils forcePortrait];
        }
    }

    [super viewDidDisappear:animated];
}

@end