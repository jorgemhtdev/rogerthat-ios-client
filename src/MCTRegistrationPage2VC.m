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
#import "MCTHTTPRequest.h"
#import "MCTIntent.h"
#import "MCTMobileInfo.h"
#import "MCTPendingRegistrationInfo.h"
#import "MCTRegistrationInfo.h"
#import "MCTRegistrationPage2VC.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"
#import "MCTJSONUtils.h"

#define MCT_TAG_PINFAILED 1
#define MCT_TAG_WRONGPIN 2
#define MCT_TAG_RESTART 3
#define MCT_TAG_PIN_VERIFY_REQUEST_FAILED 4


@interface MCTRegistrationPage2VC ()

@property (nonatomic, strong) NSArray *codeFieldArray;
@property (nonatomic, strong) MCTFinishRegistration *finishStep;

- (void)validatePin;

- (void)requestFailed:(MCTFormDataRequest *)request;
- (void)requestFinished:(MCTFormDataRequest *)request;

@end


@implementation MCTRegistrationPage2VC


+ (MCTRegistrationPage2VC *)viewController
{
    T_UI();
    return [[MCTRegistrationPage2VC alloc] initWithNibName:@"registration2" bundle:nil];
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

    if (MCT_FULL_WIDTH_HEADERS)
    {
        CGFloat w = [UIScreen mainScreen].applicationFrame.size.width;
        self.registrationLogo.frame = CGRectMake(0,
                                                 self.navigationController.navigationBar.height + [UIScreen mainScreen].applicationFrame.origin.y - 3,
                                                 w,
                                                 115 * w / 320);
        self.registrationLogo.autoresizingMask = UIViewAutoresizingNone;
    }


    self.view.backgroundColor = [UIColor MCTHomeScreenBackgroundColor];
    self.lblDescription.textColor = [UIColor MCTHomeScreenTextColor];


    self.title = NSLocalizedString(@"Activation", nil);
    self.navigationItem.hidesBackButton = NO;

    [[UIMenuController sharedMenuController] setMenuVisible:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name: UITextFieldTextDidChangeNotification
                                               object:self.txtHiddenPin];

    NSString *timestamp = [MCTUtils timestampShortNotation:[self.preRegistrationInfo.registrationTime longLongValue] andShowMinutes:NO];
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Your activation code has been mailed to %@ at %@\n\nDo not forget to check your Spam or Unwanted Email folders.", nil),
                         self.preRegistrationInfo.email, timestamp];
    self.lblDescription.text = message;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
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


- (void)viewWillDisappear:(BOOL)animated
{
    T_UI();
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)validatePin
{
    T_UI();
    [self showActionSheetWithTitle:NSLocalizedString(@"Validating activation PIN ...", nil)];

    MCTPendingRegistrationInfo *info = [MCTPendingRegistrationInfo infoWithPreRegistrationInfo:self.preRegistrationInfo
                                                                                    andPinCode:self.txtHiddenPin.text];

    NSString *url = [NSString stringWithFormat:@"%@%@", MCT_HTTPS_BASE_URL, MCT_REGISTRATION_URL_VERIFY];
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
    self.httpRequest.userInfo = [NSDictionary dictionaryWithObject:info forKey:@"info"];

    LOG(@"%@", info);

    [self.httpRequest setPostValue:info.version forKey:@"version"];
    [self.httpRequest setPostValue:info.email forKey:@"email"];
    [self.httpRequest setPostValue:info.registrationTime forKey:@"registration_time"];
    [self.httpRequest setPostValue:info.deviceId forKey:@"device_id"];
    [self.httpRequest setPostValue:info.registrationId forKey:@"registration_id"];
    [self.httpRequest setPostValue:info.pinCode forKey:@"pin_code"];
    [self.httpRequest setPostValue:info.pinSignature forKey:@"pin_signature"];
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

    ERROR(@"%@ failed with statusCode %d", request.url, [request responseStatusCode]);

    if (![MCTUtils connectedToInternet]) {
        self.currentAlertView = [MCTUIUtils showNetworkErrorAlert];
    } else {
        self.currentAlertView = [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"Activation PIN could not be validated", nil)];
    }
    self.currentAlertView.delegate = self;
    self.currentAlertView.tag = MCT_TAG_PIN_VERIFY_REQUEST_FAILED;
    self.txtHiddenPin.text = @"";

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

    NSDictionary *jsonDict = [[request responseString] MCT_JSONValue];
    NSString *result = [jsonDict objectForKey:@"result"];

    if (result && [result isEqualToString:@"fail"]) {
        NSNumber *numberAttemptsLeft = [jsonDict objectForKey:@"attempts_left"];
        if (numberAttemptsLeft == nil) {
            [self requestFailed:request];
        }

        int attemptsLeft = [numberAttemptsLeft intValue];

        if (attemptsLeft > 0) {
            NSString *message;
            if (attemptsLeft == 1)
                message = NSLocalizedString(@"Please try again\n(last attempt)", nil);
            else
                message = [NSString stringWithFormat:NSLocalizedString(@"Please try again\n(%d attempts remaining)", nil),
                           attemptsLeft];

            self.currentAlertView = [MCTUIUtils showAlertWithTitle:NSLocalizedString(@"Wrong activation PIN", nil)
                                                           andText:message
                                                            andTag:MCT_TAG_WRONGPIN];

        } else {
            self.currentAlertView = [MCTUIUtils showAlertWithTitle:NSLocalizedString(@"Wrong activation PIN", nil)
                                                           andText:NSLocalizedString(@"Too many failed attempts. The registration will be restarted.", nil)
                                                            andTag:MCT_TAG_PINFAILED];
        }
        self.currentAlertView.delegate = self;

        self.txtHiddenPin.text = @"";
    }
    else if (result && [result isEqualToString:@"success"]) {
        NSDictionary *accountDict = [jsonDict objectForKey:@"account"];

        MCTCredentials *credentials = [MCTCredentials credentials];
        credentials.username = [accountDict stringForKey:@"account"];
        credentials.password = [accountDict stringForKey:@"password"];
        MCTRegistrationInfo *info = [MCTRegistrationInfo infoWithCredentials:credentials
                                                                    andEmail:self.preRegistrationInfo.email];
        self.finishStep = [[MCTFinishRegistration alloc] init];
        self.finishStep.delegate = self;
        self.finishStep.registrationInfo = info;
        self.finishStep.ageAndGenderSet = [jsonDict boolForKey:@"age_and_gender_set"];
        [self.finishStep doFinishRegistration];

        [self showActionSheetWithTitle:NSLocalizedString(@"Finishing registration.", nil)];
    }
    else {
        return [self requestFailed:request];
    }

    [self.httpRequest clearDelegatesAndCancel];
    MCT_RELEASE(self.httpRequest);

}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)s
{
    T_UI();
    if (textField == self.txtHiddenPin) {
        BOOL isNumeric = [[[NSNumberFormatter alloc] init] numberFromString:s] != nil;
        return (isNumeric && [self.txtHiddenPin.text length] < 4) || [s length] == 0;
    }

    return YES;
}

- (void)textDidChange:(NSNotification *)notif
{
    T_UI();
    if ([notif object] == self.txtHiddenPin) {
        NSString *pin = self.txtHiddenPin.text;

        if ([pin length] == 4) {
            [self validatePin];
        }
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    switch (alertView.tag) {
        case MCT_TAG_PINFAILED:
        case MCT_TAG_RESTART:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case MCT_TAG_WRONGPIN:
            // Do nothing
            break;
        case MCT_TAG_PIN_VERIFY_REQUEST_FAILED:
            [self.txtHiddenPin becomeFirstResponder];
            break;
        default:
            break;
    }

    MCT_RELEASE(self.currentAlertView);
}

- (IBAction)onBackgroundTapped:(id)sender
{
    T_UI();
    [self.txtHiddenPin resignFirstResponder];
}

#pragma mark -
#pragma mark MCTFinishRegistrationCallback

- (void)finishRegistrationSuccess
{
    T_UI();
    [self hideActionSheet];
    [[MCTComponentFramework appDelegate] onRegistrationSuccess];
    MCT_RELEASE(self.finishStep);
}

- (void)finishRegistrationFailure
{
    T_UI();
    [self hideActionSheet];
    self.currentAlertView = [MCTUIUtils showAlertWithTitle:NSLocalizedString(@"Error", nil)
                                                   andText:[NSString stringWithFormat:NSLocalizedString(@"Cannot contact the Rogerthat gateway. Please try again later.", nil), MCT_PRODUCT_NAME]
                                                    andTag:MCT_TAG_RESTART];
    self.currentAlertView.delegate = self;
    MCT_RELEASE(self.finishStep);
}

- (void)finishRegistrationAttempt:(int)attempt withInfo:(MCTRegistrationInfo *)info
{
    T_UI();
    [self setActionSheetTitle:[NSString stringWithFormat:NSLocalizedString(@"Registering %@ (%d)", nil),
                               info.email, attempt]];
}

@end