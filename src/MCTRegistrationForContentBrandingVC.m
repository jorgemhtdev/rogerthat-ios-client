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

#import "MCTRegistrationForContentBrandingVC.h"
#import "MCTEncoding.h"
#import "MCTZXingUtils.h"
#import "MCTScannerVC.h"
#import "MCTScanResult.h"
#import "MCTMobileInfo.h"
#import "MCTRegistrationInfo.h"

#define MCT_SIGNATURE_FORMAT_INIT @"%@ %@ %@ %@ %@ %@%@"

@interface MCTRegistrationForContentBrandingVC ()

@property(nonatomic, retain) MCTFinishRegistration *finishStep;

@end

@implementation MCTRegistrationForContentBrandingVC


+ (MCTRegistrationForContentBrandingVC *)viewController
{
    T_UI();
    return [[MCTRegistrationForContentBrandingVC alloc] initWithNibName:@"registrationForContentBranding" bundle:nil];
}

- (void)dealloc
{
    T_UI();
    [self.httpRequest clearDelegatesAndCancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;

    self.txtLbl.text = NSLocalizedString(@"osa_loyalty_welcome", nil);

    [self.scanBtn setTitle:NSLocalizedString(@"Scan QR code", nil) forState:UIControlStateNormal];
}


#pragma mark -

- (IBAction)onScanTapped:(id)sender
{
    T_UI();
    HERE();

    if (![MCTScannerVC checkScanningSupportedInVC:self])
        return;

    [MCTZXingUtils presentZXingWidgetWithDelegate:self handleOrientation:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideZXingController)
                                                 name:MCT_NOTIFICATION_BACKGROUND
                                               object:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (self.httpRequest) {
        [self.httpRequest clearDelegatesAndCancel];
        MCT_RELEASE(self.httpRequest);
    }
    MCT_RELEASE(self.currentAlertView);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (alertView.tag == MCT_TAG_OPEN_URL) {
        if (buttonIndex != alertView.cancelButtonIndex) {
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
        }
//        MCT_RELEASE(self.url);
    } else if (alertView.tag == MCT_TAG_ASK_CAMERA_PERMISSION) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self onScanTapped:self];
                    });
                }
            }];
        }
    } else if (alertView.tag == MCT_TAG_GO_TO_CAMERA_SETTINGS) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    MCT_RELEASE(self.currentAlertView);
}

#pragma mark - ZXingDelegate

- (void)handleScanResult:(NSString *)result
{
    T_UI();
    [self activateLoyaltyWithUrl:result];
}

- (void)hideZXingController
{
    T_UI();
    // Fix for device in landscape mode
    if (!UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MCT_NOTIFICATION_BACKGROUND object:nil];
}

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result
{
    T_UI();
    [self hideZXingController];
    LOG(@"Scanned %@", result);
    [self handleScanResult:result];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller
{
    T_UI();
    [self hideZXingController];
}

#pragma mark - Activate

- (void)showFailurePopup
{
    if (![MCTUtils connectedToInternet]) {
        self.currentAlertView = [MCTUIUtils showNetworkErrorAlert];
    } else {
        self.currentAlertView = [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"A failure happened during the registration", nil)];
    }
    self.currentAlertView.delegate = self;
}

- (void)onActivateLoyaltyFailed:(MCTFormDataRequest *)request
{
    T_UI();
    [self.currentProgressHUD hide:YES];
    MCT_RELEASE(self.currentProgressHUD);
    LOG(@"Failed to activate loyalty tablet with status code %d and message '%@'", request.responseStatusCode,
        request.responseStatusMessage);

    BOOL customError = NO;
    if (request.responseStatusCode == 500 && ![MCTUtils isEmptyOrWhitespaceString:request.responseString] ) {
        NSDictionary *jsonDict = [[request responseString] MCT_JSONValue];
        NSString *error = [jsonDict stringForKey:@"error"];
        if (![MCTUtils isEmptyOrWhitespaceString:error]) {
            customError = YES;
            self.currentAlertView = [MCTUIUtils showErrorAlertWithText:error];
        }
    }

    if (!customError) {
        ERROR(@"%@ failed with statusCode %d", request.url, [request responseStatusCode]);
        [self.currentProgressHUD hide:YES];
        MCT_RELEASE(self.currentProgressHUD);
        [self showFailurePopup];
    }
}

- (void)onActivateLoyaltyFinished:(MCTFormDataRequest *)request
{
    T_UI();
    LOG(@"Activated loyalty tablet with status code %d and message '%@'", request.responseStatusCode,
        request.responseStatusMessage);

    if ([request responseStatusCode] != 200) {
        return [self onActivateLoyaltyFailed:request];
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
    self.finishStep = [[MCTFinishRegistration alloc] init];
    self.finishStep.delegate = self;
    self.finishStep.registrationInfo = info;
    self.finishStep.ageAndGenderSet = [jsonDict boolForKey:@"age_and_gender_set"];
    [self.finishStep doFinishRegistration];

}

- (void)activateLoyaltyWithUrl:(NSString *)qrUrl
{
    T_UI();
    NSString *version = @"1";
    NSString *installationId = [MCTRegistrationMgr installationId];
    NSString *registrationTime = [NSString stringWithFormat:@"%lld", [MCTUtils currentServerTime]];
    NSString *deviceId = [MCTUtils deviceId];
    NSString *registrationId = [MCTUtils guid];

    NSString *signature = [[NSString stringWithFormat:MCT_SIGNATURE_FORMAT_INIT, version, installationId,
                            registrationTime, deviceId, registrationId, qrUrl, MCT_REGISTRATION_MAIN_SIGNATURE] sha256Hash];

    NSString *url = [NSString stringWithFormat:@"%@%@", MCT_HTTPS_BASE_URL, MCT_REGISTRATION_URL_QR_URL];
    MCTFormDataRequest *request = [MCTFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    request.delegate = self;
    request.didFailSelector = @selector(onActivateLoyaltyFailed:);
    request.didFinishSelector = @selector(onActivateLoyaltyFinished:);
    request.timeOutSeconds = 60.0;
    request.shouldRedirect = NO;
    request.validatesSecureCertificate = YES;
    [request addRequestHeader:@"User-Agent" value:@"Rogerthat"];
    [request setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [request setPostValue:version forKey:@"version"];
    [request setPostValue:@"iphone" forKey:@"platform"];
    [request setPostValue:registrationTime forKey:@"registration_time"];
    [request setPostValue:deviceId forKey:@"device_id"];
    [request setPostValue:registrationId forKey:@"registration_id"];
    [request setPostValue:signature forKey:@"signature"];
    [request setPostValue:installationId forKey:@"install_id"];
    [request setPostValue:qrUrl forKey:@"qr_url"];
    MCTLocaleInfo *localeInfo = [MCTLocaleInfo info];
    [request setPostValue:localeInfo.language forKey:@"language"];
    [request setPostValue:localeInfo.country forKey:@"country"];
    [request setPostValue:MCT_PRODUCT_ID forKey:@"app_id"];
    [request setPostValue:MCT_USE_XMPP_KICK_CHANNEL ? @"true" : @"false" forKey:@"use_xmpp_kick"];
    [[MCTComponentFramework downloadQueue] addOperation:request];

    self.currentProgressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.currentProgressHUD];
    self.currentProgressHUD.labelText = NSLocalizedString(@"Activating…", nil);
    self.currentProgressHUD.mode = MBProgressHUDModeIndeterminate;
    self.currentProgressHUD.dimBackground = YES;
    [self.currentProgressHUD show:YES];
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


@end