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
#import "MCTConfigProvider.h"
#import "MCTMainViewController.h"
#import "MCTHomeScreenVC.h"
#import "MCTContentBrandingMenuVC.h"
#import "MCTRegistrationMgr.h"
#import "MCTLocationUsageVC.h"
#import "MCTPushNotificationsVC.h"
#import "MCTRegistrationPage0VC.h"
#import "MCTRegistrationPage1VC.h"
#import "MCTRegistrationPage2VC.h"
#import "MCTRegistrationForContentBrandingVC.h"
#import "MCTRegistrationForOauthVC.h"
#import "MCTStartScreenVC.h"
#import "MCTUINavigationController.h"
#import "MCTUIUtils.h"


@interface MCTMainViewController()

- (void)presentNonAnimatedVC:(UIViewController *)vc;
- (void)switchToVC:(UIViewController *)vc;

@end



@implementation MCTMainViewController

- (void)presentNonAnimatedVC:(UIViewController *)vc
{
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)switchToVC:(UIViewController *)vc
{
    if (self.presentedViewController != nil) {
        // Dismiss + Present
        // Work around ios bug http://stackoverflow.com/questions/3919845/presenting-a-modal-view-controller-immediately-after-dismissing-another
        [self dismissViewControllerAnimated:NO completion:nil];
        [self performSelectorOnMainThread:@selector(presentNonAnimatedVC:) withObject:vc waitUntilDone:NO];
    } else {
        // Present
        [self presentViewController:vc animated:NO completion:nil];
    }
}

- (void)showRegistrationVCWithYouHaveBeenUnregisteredPopup:(BOOL)showPopup
{
    T_UI();
    NSMutableArray *vcs = [NSMutableArray array];
    if (IS_CONTENT_BRANDING_APP) {
        [vcs addObject:[MCTRegistrationForContentBrandingVC viewController]];

    } else if (![MCTRegistrationMgr areTermsOfServiceAccepted]) {
        [vcs addObject:[MCTStartScreenVC viewController]];

    } else if (![MCTRegistrationMgr isLocationUsageShown]) {
        [vcs addObject:[MCTLocationUsageVC viewController]];

    } else if (![MCTRegistrationMgr isPushNotificationsShown]) {
        [vcs addObject:[MCTPushNotificationsVC viewController]];

    } else if (IS_OAUTH_REGISTRATION) {
        [vcs addObject:[MCTRegistrationForOauthVC viewController]];
    } else {
        MCTRegistrationPage1VC *vc1 = nil;
        if (MCT_FACEBOOK_APP_ID == nil || !MCT_FACEBOOK_REGISTRATION) {
            vc1 = [MCTRegistrationPage1VC viewController];
            [vcs addObject:vc1];
        } else {
            [vcs addObject:[MCTRegistrationPage0VC viewController]];
        }

        MCTPreRegistrationInfo *preRegInfo = [MCTRegistrationMgr preRegistrationInfo];
        if (preRegInfo) {
            if (vc1 == nil) {
                vc1 = [MCTRegistrationPage1VC viewController];
                [vcs addObject:vc1];
            }
            vc1.emailTextField.text = preRegInfo.email;

            MCTRegistrationPage2VC *vc2 = [MCTRegistrationPage2VC viewController];
            vc2.preRegistrationInfo = preRegInfo;
            [vcs addObject:vc2];
        }
    }

    UINavigationController *nav = [[MCTUINavigationController alloc] init];
    nav.viewControllers = vcs;
    nav.navigationBar.tintColor = [UIColor MCTNavigationBarColor];
    [self switchToVC:nav];
    if (showPopup) {
        // TODO: own this alertview
        [MCTUIUtils showAlertWithTitle:nil
                               andText:NSLocalizedString(@"Device has been unregistered", nil)];
    }
}

- (void)showMenuWithMsgLaunchOption:(NSString *)msgLaunchOption andAckLaunchOption:(NSString *)ackLaunchOption;
{
    T_UI();
    if (IS_CONTENT_BRANDING_APP) {
        MCTContentBrandingMenuVC *vc = [MCTContentBrandingMenuVC viewController];
        [self switchToVC:vc];
    } else if (MCT_HOME_SCREEN_STYLE == MCT_HOME_SCREEN_STYLE_TABS) {
        MCTMenuVC *vc = [[MCTMenuVC alloc] init];
        vc.msgLaunchOption = msgLaunchOption;
        vc.ackLaunchOption = ackLaunchOption;

        [self switchToVC:vc];
    } else  {
        NSString *nibName = MCT_HOME_SCREEN_STYLE == MCT_HOME_SCREEN_STYLE_3X3 ? @"homescreen_3x3" : @"homescreen_2x3";
        MCTHomeScreenVC *vc = [[MCTHomeScreenVC alloc] initWithNibName:nibName bundle:nil];
        vc.msgLaunchOption = msgLaunchOption;
        vc.ackLaunchOption = ackLaunchOption;

        [self switchToVC:[[MCTUINavigationController alloc] initWithRootViewController:vc]];
    }
}

- (BOOL)shouldAutorotate
{
    T_UI();
    HERE();
    if (IS_CONTENT_BRANDING_APP) {
        return [super shouldAutorotate];
    }

    MCTMenuVC *menuVC = [MCTComponentFramework menuViewController];
    if (menuVC == nil) {
        // registration procedure
        BOOL shouldAutoRotate = !UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)
            && UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation);
        LOG(@"%@, %@", [self class], BOOLSTR(shouldAutoRotate));
        return shouldAutoRotate;
    }
    return [menuVC shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    T_UI();
    HERE();
    if (IS_CONTENT_BRANDING_APP) {
        return [super supportedInterfaceOrientations];
    }
    MCTMenuVC *menuVC = [MCTComponentFramework menuViewController];
    if (menuVC == nil) {
        // registration procedure
        return UIInterfaceOrientationMaskPortrait;
    }
    return [menuVC supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    T_UI();
    HERE();
    if (IS_CONTENT_BRANDING_APP) {
        return [super preferredInterfaceOrientationForPresentation];
    }
    MCTMenuVC *menuVC = [MCTComponentFramework menuViewController];
    if (menuVC == nil) {
        // registration procedure
        return UIInterfaceOrientationPortrait;
    }
    return [menuVC preferredInterfaceOrientationForPresentation];
}

@end