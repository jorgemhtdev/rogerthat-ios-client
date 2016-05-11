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
#import "MCTLogForwarding.h"
#import "MCTUITableViewController.h"

@implementation MCTUITableViewController

- (void)dealloc
{
    T_UI();
    if ([self conformsToProtocol:@protocol(IMCTIntentReceiver)])
        if ([[MCTComponentFramework intentFramework] unregisterIntentListener:(NSObject<IMCTIntentReceiver> *)self])
            LOG(@"IFW - dealloc called but not all intentListeners are unregistered: %@", self);
    if (self.currentAlertView != nil)
        BUG(@"BUG/ERROR !!!!!!! currentAlertView not nil in dealloc: %@", self);
    if (self.currentActionSheet != nil)
        BUG(@"BUG/ERROR !!!!!!! currentActionSheet not nil in dealloc: %@", self);
    if (self.activeObject != nil)
        BUG(@"BUG/ERROR !!!!!!! activeObject not nil in dealloc: %@", self);
}

- (void)viewWillDisappear:(BOOL)animated {
    T_UI();
    LOG(@"top viewWillDisappear %@", self);
    MCT_RELEASE(self.currentActionSheet);
    MCT_RELEASE(self.currentAlertView);
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    LOG(@"top viewDidDisappear %@", self);
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    LOG(@"top viewWillAppear %@", self);
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    LOG(@"top viewDidAppear %@", self);
    [super viewDidAppear:animated];
}


- (void)setCurrentActionSheet:(UIActionSheet *)currentActionSheet
{
    T_UI();
    if (currentActionSheet != self.currentActionSheet) {
        self.currentActionSheet.delegate = nil;
        [self.currentActionSheet dismissWithClickedButtonIndex:self.currentAlertView.cancelButtonIndex animated:YES];
        _currentActionSheet = currentActionSheet;
    }
}

- (void)setCurrentAlertView:(UIAlertView *)currentAlertView
{
    T_UI();
    if (currentAlertView != self.currentAlertView) {
        self.currentAlertView.delegate = nil;
        [self.currentAlertView dismissWithClickedButtonIndex:self.currentAlertView.cancelButtonIndex animated:YES];
        _currentAlertView = currentAlertView;
    }
}

- (void)setTitle:(NSString *)title
{
    if (MCTLogForwarder.logForwarder.forwarding) {
        if (self.originalTitle == nil) {
            self.originalTitle = self.title;
        }
        [super setTitle:title];
        self.navigationItem.title = MCT_FORWARDING_LOGS_ON_STRING;
    } else {
        NSString *t = OR(self.originalTitle, title);
        [super setTitle:t];
        self.navigationItem.title = t;
    }
}

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

@end