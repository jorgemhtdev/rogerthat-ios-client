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
#import "MCTRegistrationPage2VC.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"
#import "MCTMobileInfo.h"
#import "MCTPreRegistrationInfo.h"
#import "NSData+Base64.h"


#import <FacebookSDK/FacebookSDK.h>

@interface MCTRegistrationPage0VC()

- (BOOL)validateEmail;

//- (void)startPostInstallationRequest;
- (void)startPreRegistrationRequest;
- (void)showNextPage;
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

    if (IS_ROGERTHAT_APP)
    {
        [MCTUIUtils setBackgroundPlainToView:self.view];
    } else
    {
        self.view.backgroundColor = [UIColor MCTHomeScreenBackgroundColor];

        UIColor *textColor = [UIColor MCTHomeScreenTextColor];
    }

    self.title = NSLocalizedString(@"Create account", nil);

    [self.fbBtn setTitle:NSLocalizedString(@"Sign up with Facebook", nil) forState:UIControlStateNormal];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_FB_LOGIN
                                                            onQueue:[MCTComponentFramework mainQueue]];

    [self.fbBtn setBackgroundColor:[UIColor colorWithString:@"#39527f"]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
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
    self.emailTextField.text = [self.emailTextField.text lowercaseString];
    self.emailTextField.text = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([self validateEmail]) {
        [self startPreRegistrationRequest];
    } else {
        [self showInvalidEmailPopup];
    }
}

- (IBAction)onBackgroundTapped:(id)sender
{
    [self.emailTextField resignFirstResponder];
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

- (void)showInvalidEmailPopup
{
    self.currentAlertView = [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"Please enter a valid e-mail address", nil)];
}

- (BOOL)validateEmail
{
    T_UI();
    NSPredicate *mailRegex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MCT_REGEX_EMAIL];
    BOOL valid = [mailRegex evaluateWithObject:self.emailTextField.text];
    return valid;
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    CGSize keyboardSize = [MCTUIUtils keyboardSizeWithNotification:aNotification];

    [UIView animateWithDuration:0.2
                     animations:^{
                         self.view.top = -keyboardSize.height;
                     } completion:^(BOOL finished) {
                     }];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.view.top = 0;
                     } completion:^(BOOL finished) {
                     }];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    T_UI();
    if (textField == self.emailTextField) {
        [self onEmailTapped:self.registerBtn];
    }
    return YES;
}

#pragma mark -


#pragma mark -

- (void)startPreRegistrationRequest
{
    T_UI();
    // Request pin code
    [self showActionSheetWithTitle:NSLocalizedString(@"Registering", nil)];

    self.preRegistrationInfo = [MCTPreRegistrationInfo infoWithEmail:[self.emailTextField.text lowercaseString]];

    NSString *url = [NSString stringWithFormat:@"%@%@", MCT_HTTPS_BASE_URL, MCT_REGISTRATION_URL_INIT];
    self.httpRequest = [MCTFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    self.httpRequest.delegate = self;
    self.httpRequest.didFinishSelector = @selector(requestFinished:);
    self.httpRequest.didFailSelector = @selector(requestFailed:);
    self.httpRequest.numberOfTimesToRetryOnTimeout = 3;
    self.httpRequest.shouldRedirect = NO;
    self.httpRequest.timeOutSeconds = 10;
    self.httpRequest.useCookiePersistence = NO;
    self.httpRequest.useSessionPersistence = NO;
    self.httpRequest.validatesSecureCertificate = YES;
    self.httpRequest.userInfo = [NSDictionary dictionaryWithObject:self.preRegistrationInfo forKey:@"info"];

    [self.httpRequest setPostValue:self.preRegistrationInfo.version forKey:@"version"];
    [self.httpRequest setPostValue:self.preRegistrationInfo.email forKey:@"email"];
    [self.httpRequest setPostValue:self.preRegistrationInfo.registrationTime forKey:@"registration_time"];
    [self.httpRequest setPostValue:self.preRegistrationInfo.deviceId forKey:@"device_id"];
    [self.httpRequest setPostValue:self.preRegistrationInfo.registrationId forKey:@"registration_id"];
    [self.httpRequest setPostValue:self.preRegistrationInfo.requestSignature forKey:@"request_signature"];
    [self.httpRequest setPostValue:[MCTRegistrationMgr installationId] forKey:@"install_id"];
    MCTLocaleInfo *localeInfo = [MCTLocaleInfo info];
    [self.httpRequest setPostValue:localeInfo.language forKey:@"language"];
    [self.httpRequest setPostValue:localeInfo.country forKey:@"country"];
    [self.httpRequest setPostValue:[MCTUtils guid] forKey:@"request_id"];
    [self.httpRequest setPostValue:MCT_PRODUCT_ID forKey:@"app_id"];
    [self.httpRequest setPostValue:MCT_USE_XMPP_KICK_CHANNEL ? @"true" : @"false" forKey:@"use_xmpp_kick"];

    [[MCTComponentFramework workQueue] addOperation:self.httpRequest];
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate

- (void)requestFailed:(MCTFormDataRequest *)request
{
    T_UI();
    [self hideActionSheet];

    int statusCode = [request responseStatusCode];
    ERROR(@"%@ failed with statusCode %d", request.url, statusCode);

    if (statusCode == 501) {
        [self showInvalidEmailPopup];
    }
    else if (statusCode == 502) {
        NSDictionary *jsonDict = [[request responseString] MCT_JSONValue];
        NSString *result = [jsonDict objectForKey:@"result"];

        if (result) {
            self.currentAlertView = [MCTUIUtils showErrorAlertWithText:result];
        } else {
            [self showInvalidEmailPopup];
        }
    }
    else if (![MCTUtils connectedToInternet]) {
        self.currentAlertView = [MCTUIUtils showNetworkErrorAlert];
    }
    else {
        self.currentAlertView = [MCTUIUtils showErrorPleaseRetryAlert];
    }

    [self.httpRequest clearDelegatesAndCancel];
    MCT_RELEASE(self.httpRequest);
}

- (void)requestFinished:(MCTFormDataRequest *)request
{
    T_UI();
    [self hideActionSheet];

    if ([request responseStatusCode] != 200) {
        return [self requestFailed:request];
    }

    NSData *data = [MCTPickler pickleFromObject:self.preRegistrationInfo];
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [[MCTComponentFramework configProvider] setString:[data base64EncodedString] forKey:MCT_PRE_REG_INFO_CONFIG_KEY];
    }];

    [[MCTComponentFramework workQueue] waitUntilAllOperationsAreFinished];

    [MCTUtils setBadgeNumber:1];

    [self showNextPage];

    [self.httpRequest clearDelegatesAndCancel];
    MCT_RELEASE(self.httpRequest);
}

- (void)showNextPage
{
    T_UI();
    MCTRegistrationPage2VC *nextVC = [MCTRegistrationPage2VC viewController];
    nextVC.preRegistrationInfo = self.preRegistrationInfo;
    [self.navigationController pushViewController:nextVC animated:YES];
}

@end