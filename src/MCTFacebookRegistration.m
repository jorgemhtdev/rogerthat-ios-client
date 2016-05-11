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
#import "MCTEncoding.h"
#import "MCTFacebookRegistration.h"
#import "MCTFinishRegistration.h"
#import "MCTHTTPRequest.h"
#import "MCTMobileInfo.h"
#import "MCTPreRegistrationInfo.h"
#import "MCTRegistrationInfo.h"
#import "MCTUtils.h"
#import "MCTUIUtils.h"

#define MCT_FACEBOOK_REGISTRATION_VERSION @"1"
#define MCT_FACEBOOK_SIGNATURE_FORMAT_INIT @"%@ %@ %@ %@ %@ %@%@"

@interface MCTFacebookRegistration()

@property(nonatomic, strong) MCTFormDataRequest *httpRequest;
@property(nonatomic, strong) MCTFinishRegistration *finishStep;
@end


@implementation MCTFacebookRegistration


- (MCTFacebookRegistration *)initWithViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc
{
    if (self = [super init]) {
        self.vc = vc;
    }
    return self;
}

- (void)dealloc
{
    [self.httpRequest clearDelegatesAndCancel];
}

- (void)showActionSheetWithTitle:(NSString *)title
{
    if (self.vc.currentActionSheet)
        self.vc.currentActionSheet.title = title;
    else
        self.vc.currentActionSheet = [MCTUIUtils showActivityActionSheetWithTitle:NSLocalizedString(@"Finishing registration.", nil)
                                                                 inViewController:self.vc];
    self.vc.currentActionSheet.delegate = self.vc;
}

- (void)showFailurePopup
{
    if (![MCTUtils connectedToInternet]) {
        self.vc.currentAlertView = [MCTUIUtils showNetworkErrorAlert];
    } else {
        self.vc.currentAlertView = [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"A failure happened during the registration", nil)];
    }
    self.vc.currentAlertView.delegate = self.vc;
}

- (void)doRegistrationWithAccessToken:(NSString *)accessToken
{
    T_UI();
    self.vc.currentActionSheet = [MCTUIUtils showActivityActionSheetWithTitle:NSLocalizedString(@"Finishing registration.", nil)
                                                          inViewController:self.vc];

    NSString *url = [NSString stringWithFormat:@"%@%@", MCT_HTTPS_BASE_URL, MCT_REGISTRATION_URL_FACEBOOK];

    NSString *version = MCT_FACEBOOK_REGISTRATION_VERSION;
    NSString *registrationTime = [NSString stringWithFormat:@"%lld", [MCTUtils currentServerTime]];
    NSString *deviceId = [MCTUtils deviceId];
    NSString *registrationId = [MCTUtils guid];
    NSString *installId = [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_INSTALLATION_ID];

    NSString *signature = [[NSString stringWithFormat:MCT_FACEBOOK_SIGNATURE_FORMAT_INIT, version, installId,
                            registrationTime, deviceId, registrationId, accessToken, MCT_REGISTRATION_MAIN_SIGNATURE] sha256Hash];

    if (self.httpRequest) {
        [self.httpRequest clearDelegatesAndCancel];
        MCT_RELEASE(self.httpRequest);
    }
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

    [self.httpRequest setPostValue:version forKey:@"version"];
    [self.httpRequest setPostValue:registrationTime forKey:@"registration_time"];
    [self.httpRequest setPostValue:deviceId forKey:@"device_id"];
    [self.httpRequest setPostValue:registrationId forKey:@"registration_id"];
    [self.httpRequest setPostValue:signature forKey:@"signature"];
    [self.httpRequest setPostValue:installId forKey:@"install_id"];
    [self.httpRequest setPostValue:[MCTUtils guid] forKey:@"request_id"];
    MCTLocaleInfo *localeInfo = [MCTLocaleInfo info];
    [self.httpRequest setPostValue:localeInfo.language forKey:@"language"];
    [self.httpRequest setPostValue:localeInfo.country forKey:@"country"];
    [self.httpRequest setPostValue:accessToken forKey:@"access_token"];
    [self.httpRequest setPostValue:MCT_PRODUCT_ID forKey:@"app_id"];
    [self.httpRequest setPostValue:MCT_USE_XMPP_KICK_CHANNEL ? @"true" : @"false" forKey:@"use_xmpp_kick"];

    [[MCTComponentFramework workQueue] addOperation:self.httpRequest];

    LOG(@"Request was sent to server");
}

- (void)requestFailed:(MCTFormDataRequest *)request
{
    T_UI();
    BOOL customError = NO;
    if (request.responseStatusCode == 500 && ![MCTUtils isEmptyOrWhitespaceString:request.responseString] ) {
        NSDictionary *jsonDict = [[request responseString] MCT_JSONValue];
        NSString *error = [jsonDict stringForKey:@"error"];
        if (![MCTUtils isEmptyOrWhitespaceString:error]) {
            customError = YES;
            MCT_RELEASE(self.vc.currentActionSheet);
            self.vc.currentAlertView = [MCTUIUtils showErrorAlertWithText:error];
        }
    }

    if (!customError) {
        ERROR(@"%@ failed with statusCode %d", request.url, [request responseStatusCode]);
        MCT_RELEASE(self.vc.currentActionSheet);
        [self showFailurePopup];
    }

    MCT_RELEASE(self.httpRequest)
}

- (void)requestFinished:(MCTFormDataRequest *)request
{
    T_UI();
    if ([request responseStatusCode] != 200) {
        return [self requestFailed:request];
    }

    NSDictionary *jsonDict = [[request responseString] MCT_JSONValue];
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
    MCT_RELEASE(self.httpRequest);
}

#pragma mark -
#pragma mark MCTFinishRegistrationCallback

- (void)finishRegistrationSuccess
{
    T_UI();
    MCT_RELEASE(self.vc.currentActionSheet);
    [[MCTComponentFramework appDelegate] onRegistrationSuccess];
    MCT_RELEASE(self.finishStep);
}

- (void)finishRegistrationFailure
{
    T_UI();
    MCT_RELEASE(self.vc.currentActionSheet);
    [self showFailurePopup];
    MCT_RELEASE(self.finishStep);
}

- (void)finishRegistrationAttempt:(int)attempt withInfo:(MCTRegistrationInfo *)info
{
    T_UI();
    [self showActionSheetWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Registering %@ (%d)", nil),
                                    info.email, attempt]];
}


@end