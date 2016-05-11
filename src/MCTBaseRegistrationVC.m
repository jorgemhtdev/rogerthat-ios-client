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

#import "MCTBaseRegistrationVC.h"
#import "MCTComponentFramework.h"
#import "MCTFinishRegistration.h"
#import "MCTIntent.h"
#import "MCTScanResult.h"
#import "MCTUIUtils.h"


@implementation MCTBaseRegistrationVC

- (void)viewDidAppear:(BOOL)animated
{
    T_UI();
    [super viewDidAppear:animated];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_APPLICATION_OPEN_URL
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                          forIntentAction:kINTENT_APPLICATION_OPEN_URL];
    }
}

- (void)showActionSheetWithTitle:(NSString *)title
{
    T_UI();
    // Get the window with the highest windowLevel
    UIWindow *window = nil;
    for (UIWindow *w in [UIApplication sharedApplication].windows) {
        if (window == nil || w.windowLevel > window.windowLevel) {
            window = w;
        }
    }
    self.currentProgressHUD = [[MBProgressHUD alloc] initWithWindow:window];
    [window addSubview:self.currentProgressHUD];
    self.currentProgressHUD.detailsLabelText = title;
    self.currentProgressHUD.mode = MBProgressHUDModeIndeterminate;
    self.currentProgressHUD.dimBackground = YES;
    self.currentProgressHUD.removeFromSuperViewOnHide = YES;
    [self.currentProgressHUD show:YES];
}

- (void)setActionSheetTitle:(NSString *)title
{
    T_UI();
    self.currentProgressHUD.detailsLabelText = title;
}

- (void)hideActionSheet
{
    T_UI();
    [self.currentProgressHUD hide:YES];
    MCT_RELEASE(self.currentProgressHUD);
}

- (void)showAlertBasedOnScanResult:(MCTScanResult *)scanResult
{
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Complete the registration\nto communicate with\n%@.", nil),
            [scanResult.parameters stringForKey:@"u"]];
    self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:msg];
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_APPLICATION_OPEN_URL) {
        NSString *url = [intent stringForKey:@"url"];
        MCTScanResult *scanResult = [MCTScanResult scanResultWithUrl:url];
        if (scanResult) {
            switch (scanResult.action) {
                case MCTScanResultActionInvitationWithSecret:
                {
                    [self showAlertBasedOnScanResult:scanResult];

                    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                        T_BIZZ();
                        [[MCTComponentFramework configProvider] setString:[scanResult.parameters stringForKey:@"userCode"]
                                                                   forKey:MCT_CONFIGKEY_INVITATION_USERCODE];
                        [[MCTComponentFramework configProvider] setString:[scanResult.parameters stringForKey:@"s"]
                                                                   forKey:MCT_CONFIGKEY_INVITATION_SECRET];
                    }];
                    break;
                }
                case MCTScanResultActionInviteFriend:
                case MCTScanResultActionService:
                {
                    [self showAlertBasedOnScanResult:scanResult];

                    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                        T_BIZZ();
                        [[MCTComponentFramework configProvider] setString:url
                                                                   forKey:MCT_CONFIGKEY_REGISTRATION_OPENED_URL];
                    }];
                    break;
                }
                default:
                    break;
            }

            [[MCTComponentFramework intentFramework] removeStickyIntent:intent];
        }
    }
}

@end