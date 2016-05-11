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
#import "MCTFacebookRegistration.h"
#import "MCTRegistrationPage0VC.h"
#import "MCTRegistrationPage1VC.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

#import <FacebookSDK/FacebookSDK.h>

@interface MCTRegistrationPage0VC()

@end


@implementation MCTRegistrationPage0VC

+ (MCTRegistrationPage0VC *)viewController
{
    T_UI();
    return [[MCTRegistrationPage0VC alloc] initWithNibName:@"registration0" bundle:nil];
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    if (MCT_FULL_WIDTH_HEADERS) {
        CGRect appFrame = [UIScreen mainScreen].applicationFrame;
        self.imageView.frame = CGRectMake(0,
                                          self.navigationController.navigationBar.height + appFrame.origin.y - 3,
                                          appFrame.size.width,
                                          115 * appFrame.size.width / 320);
        self.imageView.autoresizingMask = UIViewAutoresizingNone;
    }

    if (IS_ROGERTHAT_APP) {
        [MCTUIUtils setBackgroundPlainToView:self.view];
    } else {
        self.view.backgroundColor = [UIColor MCTHomeScreenBackgroundColor];

        UIColor *textColor = [UIColor MCTHomeScreenTextColor];
        self.fbLbl.textColor = textColor;
        self.fbNoteLbl.textColor = textColor;
        self.mailLbl.textColor = textColor;
    }

    self.title = NSLocalizedString(@"Create account", nil);

    self.fbLbl.text = NSLocalizedString(@"Option 1:\nLog in using your Facebook account.", nil);
    self.fbNoteLbl.text = NSLocalizedString(@"We will never post on your Wall without your permission.", nil);
    [self.fbBtn setTitle:NSLocalizedString(@"Use Facebook", nil) forState:UIControlStateNormal];
    [MCTUIUtils bottomAlignLabel:self.fbLbl];

    self.mailLbl.text = NSLocalizedString(@"Option 2:\nLog in using your e-mail address.", nil);
    [self.mailBtn setTitle:NSLocalizedString(@"Use e-mail", nil) forState:UIControlStateNormal];
    [MCTUIUtils bottomAlignLabel:self.mailLbl];

    if ([@"dark" isEqualToString:MCT_APP_HOMESCREEN_COLOR_SCHEME]) {
        self.fbLogo.image = [UIImage imageNamed:@"f-dark-bg.png"];
        self.mailLogo.image = [UIImage imageNamed:@"mail-dark-bg.png"];
    }

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil];
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_FB_LOGIN
                                                            onQueue:[MCTComponentFramework mainQueue]];

}

- (void)viewDidAppear:(BOOL)animated
{
    T_UI();
    [super viewDidAppear:animated];
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        [[MCTComponentFramework configProvider] deleteStringForKey:MCT_PRE_REG_INFO_CONFIG_KEY];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
    }
}

#pragma mark -

- (IBAction)onFacebookTapped:(id)sender
{
    T_UI();
    HERE();
    if (![MCTUtils connectedToInternet]) {
        self.currentAlertView = [MCTUIUtils showNetworkErrorAlert];
    } else {
        [MCTRegistrationMgr sendRegistrationStep:@"2a"];
        [self authorizeUsingFacebook];
    }
}

- (IBAction)onEmailTapped:(id)sender
{
    T_UI();
    HERE();
    [MCTRegistrationMgr sendRegistrationStep:@"2b"];
    UIViewController *vc = [MCTRegistrationPage1VC viewController];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -

- (void)authorizeUsingFacebook
{
    T_UI();
    NSMutableArray *permissions = [NSMutableArray arrayWithObjects:@"email", @"user_friends", nil];
    if (MCT_PROFILE_SHOW_GENDER_AND_BIRTHDATE) {
        [permissions addObject:@"user_birthday"];
    }
    self.fbRegistration = [[MCTFacebookRegistration alloc] initWithViewController:self];
    [[MCTComponentFramework appDelegate] ensureOpenActiveFBSessionWithReadPermissions:permissions
                                                                   resultIntentAction:kINTENT_FB_LOGIN
                                                                   allowFastAppSwitch:YES
                                                                   fromViewController:self];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    MCT_RELEASE(self.currentAlertView);
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    T_UI();
    MCT_RELEASE(self.currentActionSheet);
}

#pragma mark - MCTIntent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_FB_LOGIN) {
        if ([intent boolForKey:@"canceled"]) {
            // Do nothing
        } else if ([intent boolForKey:@"error"]) {
            [MCTUIUtils showAlertWithFacebookErrorIntent:intent];
        } else {
            FBSession *activeSession = [FBSession activeSession];
            if (activeSession.isOpen) {
                if ([activeSession.permissions containsObject:@"email"]) {
                    [self.fbRegistration doRegistrationWithAccessToken:[FBSession activeSession].accessTokenData.accessToken];
                } else {
                    [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"facebook_registration_email_missing", nil)];
                }
            }
        }
    }
}

@end