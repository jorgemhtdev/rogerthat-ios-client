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

#import "MCTRegistrationForOauthVC.h"
#import "MCTMobileInfo.h"
#import "MCTEncoding.h"
#import "MCTUIUtils.h"
#import "UIImage+FontAwesome.h"

#define MCT_SIGNATURE_FORMAT_INIT @"%@ %@ %@ %@ %@ %@%@"

@interface MCTRegistrationForOauthVC ()

@property(nonatomic, retain) MCTFinishRegistration *finishStep;

@end

@implementation MCTRegistrationForOauthVC

+ (MCTRegistrationForOauthVC *)viewController
{
    T_UI();
    return [[MCTRegistrationForOauthVC alloc] initWithNibName:@"registrationForOauth" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.lockImg.image = [UIImage imageWithIcon:@"fa-lock"
                                backgroundColor:[UIColor clearColor]
                                      iconColor:[UIColor MCTGreenColor]
                                        andSize:CGSizeMake(60, 60)];

    self.txtLbl.text = [NSString stringWithFormat:NSLocalizedString(@"Authenticate using your '%@' account.", nil), MCT_REGISTRATION_TYPE_OAUTH_DOMAIN];
    [self.authenticateBtn setTitle:NSLocalizedString(@"Authenticate", nil) forState:UIControlStateNormal];
}

- (IBAction)onAuthenticateTapped:(id)sender
{
    T_UI();
    HERE();
    [self getOauthRegistrationInfo];
}

#pragma mark - oauth/info

- (void)getOauthRegistrationInfo
{
    T_UI();
    [self showActionSheetWithTitle:NSLocalizedString(@"Loading ...", nil)];
    self.preRegistrationInfo = [MCTPreRegistrationInfo infoWithEmail:nil];

    NSString *s = [NSString stringWithFormat:MCT_SIGNATURE_FORMAT_INIT, self.preRegistrationInfo.version,
                   [MCTRegistrationMgr installationId], self.preRegistrationInfo.registrationTime,
                   self.preRegistrationInfo.deviceId, self.preRegistrationInfo.registrationId, @"oauth", MCT_REGISTRATION_MAIN_SIGNATURE];
    NSString *signature = [s sha256Hash];

    NSString *url = [NSString stringWithFormat:@"%@%@", MCT_HTTPS_BASE_URL, MCT_REGISTRATION_OAUTH_INFO_URL];
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
    self.httpRequest.userInfo = [NSDictionary dictionaryWithObject:@"info" forKey:@"type"];

    [self.httpRequest setPostValue:self.preRegistrationInfo.version forKey:@"version"];
    [self.httpRequest setPostValue:self.preRegistrationInfo.registrationTime forKey:@"registration_time"];
    [self.httpRequest setPostValue:self.preRegistrationInfo.deviceId forKey:@"device_id"];
    [self.httpRequest setPostValue:self.preRegistrationInfo.registrationId forKey:@"registration_id"];
    [self.httpRequest setPostValue:signature forKey:@"signature"];
    [self.httpRequest setPostValue:[MCTRegistrationMgr installationId] forKey:@"install_id"];
    MCTLocaleInfo *localeInfo = [MCTLocaleInfo info];
    [self.httpRequest setPostValue:localeInfo.language forKey:@"language"];
    [self.httpRequest setPostValue:localeInfo.country forKey:@"country"];
    [self.httpRequest setPostValue:[MCTUtils guid] forKey:@"request_id"];
    [self.httpRequest setPostValue:MCT_PRODUCT_ID forKey:@"app_id"];
    [self.httpRequest setPostValue:MCT_USE_XMPP_KICK_CHANNEL ? @"true" : @"false" forKey:@"use_xmpp_kick"];

    [[MCTComponentFramework workQueue] addOperation:self.httpRequest];
}

#pragma mark - oauth/registerd

- (void)registerWithOauthCode:(NSString*)code
{
    T_UI();
    [self showActionSheetWithTitle:NSLocalizedString(@"Loading ...", nil)];
    NSString *s = [NSString stringWithFormat:MCT_SIGNATURE_FORMAT_INIT, self.preRegistrationInfo.version,
                   [MCTRegistrationMgr installationId], self.preRegistrationInfo.registrationTime,
                   self.preRegistrationInfo.deviceId, self.preRegistrationInfo.registrationId, code, MCT_REGISTRATION_MAIN_SIGNATURE];
    NSString *signature = [s sha256Hash];

    NSString *url = [NSString stringWithFormat:@"%@%@", MCT_HTTPS_BASE_URL, MCT_REGISTRATION_OAUTH_REGISTERED_URL];
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
    self.httpRequest.userInfo = [NSDictionary dictionaryWithObject:@"registered" forKey:@"type"];

    [self.httpRequest setPostValue:self.preRegistrationInfo.version forKey:@"version"];
    [self.httpRequest setPostValue:self.preRegistrationInfo.registrationTime forKey:@"registration_time"];
    [self.httpRequest setPostValue:self.preRegistrationInfo.deviceId forKey:@"device_id"];
    [self.httpRequest setPostValue:self.preRegistrationInfo.registrationId forKey:@"registration_id"];
    [self.httpRequest setPostValue:signature forKey:@"signature"];
    [self.httpRequest setPostValue:[MCTRegistrationMgr installationId] forKey:@"install_id"];
    MCTLocaleInfo *localeInfo = [MCTLocaleInfo info];
    [self.httpRequest setPostValue:localeInfo.language forKey:@"language"];
    [self.httpRequest setPostValue:localeInfo.country forKey:@"country"];
    [self.httpRequest setPostValue:[MCTUtils guid] forKey:@"request_id"];
    [self.httpRequest setPostValue:MCT_PRODUCT_ID forKey:@"app_id"];
    [self.httpRequest setPostValue:code forKey:@"code"];
    [self.httpRequest setPostValue:MCT_USE_XMPP_KICK_CHANNEL ? @"true" : @"false" forKey:@"use_xmpp_kick"];

    [[MCTComponentFramework workQueue] addOperation:self.httpRequest];
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestFailed:(MCTFormDataRequest *)request
{
    T_UI();
    [self hideActionSheet];
    BOOL customError = NO;
    if (request.responseStatusCode == 500 && ![MCTUtils isEmptyOrWhitespaceString:request.responseString] ) {
        NSDictionary *jsonDict = [[request responseString] MCT_JSONValue];
        NSString *error = [jsonDict stringForKey:@"error"];
        if (![MCTUtils isEmptyOrWhitespaceString:error]) {
            customError = YES;
            MCT_RELEASE(self.currentActionSheet);
            self.currentAlertView = [MCTUIUtils showErrorAlertWithText:error];
        }
    }

    if (!customError) {
        ERROR(@"%@ failed with statusCode %d", request.url, [request responseStatusCode]);
        MCT_RELEASE(self.currentActionSheet);
        [self showFailurePopup];
    }

    MCT_RELEASE(self.httpRequest)
}

- (void)requestFinished:(MCTFormDataRequest *)request
{
    T_UI();
    [self hideActionSheet];

    if ([request responseStatusCode] != 200) {
        return [self requestFailed:request];
    }
    NSDictionary *jsonDict = [[request responseString] MCT_JSONValue];
    if ([@"info" isEqualToString:[request.userInfo objectForKey:@"type"]]) {
        NSString *authorizeUrl = [jsonDict stringForKey:@"authorize_url"];
        NSString *scopes = [jsonDict stringForKey:@"scopes"];
        NSString *state = [jsonDict stringForKey:@"state"];
        NSString *clientId = [jsonDict stringForKey:@"client_id"];

        [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                        forIntentAction:kINTENT_OAUTH_RESULT
                                                                onQueue:[MCTComponentFramework mainQueue]];

        MCT_RELEASE(self.currentActionSheet);
        [MCTUtils startOauthWithVC:self authorizeUrl:authorizeUrl scopes:scopes state:state clientId:clientId];

    } else if ([@"registered" isEqualToString:[request.userInfo objectForKey:@"type"]]) {
        NSString *email = [jsonDict stringForKey:@"email"];
        NSDictionary *accountDict = [jsonDict objectForKey:@"account"];
        MCTCredentials *credentials = [MCTCredentials credentials];
        credentials.username = [accountDict stringForKey:@"account"];
        credentials.password = [accountDict stringForKey:@"password"];

        LOG(@"Account has been made for %@", email);

        MCTRegistrationInfo *info = [MCTRegistrationInfo infoWithCredentials:credentials
                                                                    andEmail:email];
        self.finishStep = [[MCTFinishRegistration alloc] init]; // Problem
        self.finishStep.delegate = self;
        self.finishStep.registrationInfo = info;
        self.finishStep.ageAndGenderSet = [jsonDict boolForKey:@"age_and_gender_set"];
        [self.finishStep doFinishRegistration];
    }
    MCT_RELEASE(self.httpRequest);
}

- (void)showFailurePopup
{
    if (![MCTUtils connectedToInternet]) {
        self.currentAlertView = [MCTUIUtils showNetworkErrorAlert];
    } else {
        self.currentAlertView = [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"A failure happened during the registration", nil)];
    }
    self.currentAlertView.delegate = self;
}

#pragma mark - MCTFinishRegistrationCallback

- (void)finishRegistrationSuccess
{
    T_UI();
    [self.currentProgressHUD hide:YES];
    MCT_RELEASE(self.currentProgressHUD);
    [[MCTComponentFramework appDelegate] onRegistrationSuccess];
    MCT_RELEASE(self.finishStep);
}

- (void)finishRegistrationFailure
{
    T_UI();
    [self.currentProgressHUD hide:YES];
    MCT_RELEASE(self.currentProgressHUD);
    [self showFailurePopup];
    MCT_RELEASE(self.finishStep);
}

- (void)finishRegistrationAttempt:(int)attempt withInfo:(MCTRegistrationInfo *)info
{
    T_UI();
    LOG(@"finishRegistrationAttempt attempt %d", attempt);
}

# pragma mark - MCTIntent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_OAUTH_RESULT) {
        NSString *result = [intent stringForKey:@"result"];
        if ([intent boolForKey:@"success"]) {
            [self registerWithOauthCode:result];
        } else {
            [self hideActionSheet];
            self.currentAlertView = [MCTUIUtils showErrorAlertWithText:result];
        }
    }
}

@end
