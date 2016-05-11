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
#import "MCTMobileInfo.h"
#import "MCTRegistrationPage1VC.h"
#import "MCTRegistrationPage2VC.h"
#import "MCTPreRegistrationInfo.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

#import "NSData+Base64.h"

#define MCT_TAG_MAILSENT 1

static int MARGIN = 10;

@interface MCTRegistrationPage1VC ()

- (BOOL)validateEmail;

//- (void)startPostInstallationRequest;
- (void)startPreRegistrationRequest;
- (void)showNextPage;

@end


@implementation MCTRegistrationPage1VC


+ (MCTRegistrationPage1VC *)viewController
{
    T_UI();
    return [[MCTRegistrationPage1VC alloc] initWithNibName:@"registration1" bundle:nil];
}

- (void)dealloc
{
    T_UI();
    [self.httpRequest clearDelegatesAndCancel];
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    if (MCT_FULL_WIDTH_HEADERS) {
        CGFloat w = [UIScreen mainScreen].applicationFrame.size.width;
        self.registrationLogo.frame = CGRectMake(0,
                                                 self.navigationController.navigationBar.height + [UIScreen mainScreen].applicationFrame.origin.y - 3,
                                                 w,
                                                 115 * w / 320);
        self.registrationLogo.autoresizingMask = UIViewAutoresizingNone;
    }

    if (IS_ROGERTHAT_APP) {
        [MCTUIUtils setBackgroundPlainToView:self.view];
        [MCTUIUtils setBackgroundPlainToView:self.contentView];
    } else {
        self.view.backgroundColor = [UIColor MCTHomeScreenBackgroundColor];
        self.contentView.backgroundColor = [UIColor MCTHomeScreenBackgroundColor];

        self.descrLbl.textColor = [UIColor MCTHomeScreenTextColor];
    }
    [self.emailTextField becomeFirstResponder];

    self.title = NSLocalizedString(@"E-mail validation", nil);

    if (IS_ENTERPRISE_APP) {
        self.descrLbl.text = NSLocalizedString(@"To validate your account we will send you an e-mail containing your activation code.", nil);
        self.emailTextField.placeholder = NSLocalizedString(@"Enter company e-mail address", nil);
        self.navigationItem.hidesBackButton = YES;
    } else {
        self.descrLbl.text = NSLocalizedString(@"To validate your e-mail address we will send an e-mail containing your activation code.", nil);
        self.emailTextField.placeholder = NSLocalizedString(@"Enter e-mail address", nil);

        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithTitle:NSLocalizedString(@"Back", nil)
                                                  style:UIBarButtonItemStyleBordered
                                                  target:nil
                                                  action:nil];
    }

    if (CGRectGetMaxY([UIScreen mainScreen].applicationFrame) < MCT_IPHONE_6_HEIGHT) {
        self.registrationLogo.hidden = YES;
        IF_PRE_IOS7({
            self.contentView.top = 0;
        });
        IF_IOS7_OR_GREATER({
            self.contentView.top = 64;
        });
    }

    [self.registerBtn setTitle:NSLocalizedString(@"Send activation code", nil) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated
{
    T_UI();
    [super viewDidAppear:animated];
    [self.emailTextField becomeFirstResponder];
}

- (void)showInvalidEmailPopup
{
    self.currentAlertView = [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"Please enter a valid e-mail address", nil)];
}

- (IBAction)onBackgroundTapped:(id)sender
{
    T_UI();
    [self.emailTextField resignFirstResponder];
}

- (BOOL)validateEmail
{
    T_UI();
    NSPredicate *mailRegex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MCT_REGEX_EMAIL];
    BOOL valid = [mailRegex evaluateWithObject:self.emailTextField.text];
    return valid;
}

- (IBAction)onLoginTapped:(id)sender
{
    T_UI();
    self.emailTextField.text = [self.emailTextField.text lowercaseString];
    self.emailTextField.text = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([self validateEmail]) {
        [self startPreRegistrationRequest];
    } else {
        [self showInvalidEmailPopup];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    T_UI();
    if (textField == self.emailTextField) {
        [self onLoginTapped:self.registerBtn];
    }
    return YES;
}

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