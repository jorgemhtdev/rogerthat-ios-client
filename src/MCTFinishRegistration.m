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
#import "MCTFinishRegistration.h"
#import "MCTJSONUtils.h"
#import "MCTMobileInfo.h"
#import "MCTPreRegistrationInfo.h"
#import "MCTRegistrationMgr.h"
#import "MCTUtils.h"

#define XMPP_CONNECT_MAX_ATTEMPTS 5
#define XMPP_CONNECT_INITIAL_ATTEMPT_SLEEP_SECONDS 0
#define XMPP_CONNECT_RETRY_ATTEMPT_SLEEP_SECONDS 5.0

@interface MCTFinishRegistration()

@property(nonatomic, assign) BOOL succeeded;

- (void)sendFinishRegistrationRequest;
- (void)stopXMPPConnection;
- (void)doFinishRegistrationAttempt;

@end


@implementation MCTFinishRegistration


// owned by UI thread

- (void)dealloc
{
    [self.testXMPPConnection disconnect];
    [self.finishRegistrationRequest clearDelegatesAndCancel];
}

#pragma mark -
#pragma mark Entry points

- (void)doFinishRegistration
{
    T_UI();
    self.attemptCount = 0;
    self.canceled = NO;

    [self doFinishRegistrationAttempt];
}

- (void)cancel
{
    T_UI();
    self.canceled = YES;
    [self stopXMPPConnection];
    [self.finishRegistrationRequest clearDelegatesAndCancel];
}

#pragma mark -
#pragma mark XMPP connectivity testing

- (void)doFinishRegistrationAttempt
{
    T_UI();
    self.succeeded = NO;
    if (self.canceled) {
        LOG(@"Finish Registration process is canceled. Not attempting to connect");
        return;
    }
    if (self.attemptCount >= XMPP_CONNECT_MAX_ATTEMPTS) {
        LOG(@"XMPP registration test failed %d times. Giving up.", self.attemptCount);
        [self.delegate finishRegistrationFailure];
    } else {
        self.attemptCount++;

        if (MCT_USE_XMPP_KICK_CHANNEL) {
            LOG(@"XMPP registration test attempt #%d", self.attemptCount);
            if (self.attemptCount == 1) {
                // This is the first time we attempt to connect; do not sleep
                [self performSelector:@selector(executeFinishRegistrationAttempt) withObject:nil afterDelay:XMPP_CONNECT_INITIAL_ATTEMPT_SLEEP_SECONDS];
            } else {
                // Sleep and then try to connect
                [self performSelector:@selector(executeFinishRegistrationAttempt) withObject:nil afterDelay:XMPP_CONNECT_RETRY_ATTEMPT_SLEEP_SECONDS];
            }
        } else {
            [self sendFinishRegistrationRequestFromUIThread];
        }
    }
}

- (void)operationXMPPConnectionTest
{
    T_BACKLOG();
    LOG(@"Doing XMPP connection test");
    [self.testXMPPConnection disconnect];
    MCT_RELEASE(self.testXMPPConnection);
    self.testXMPPConnection = [[MCTXMPPConnection alloc] initWithCredentials:self.registrationInfo.credentials];
    [self.testXMPPConnection connectWithDelegate:self];
}

- (void)executeFinishRegistrationAttempt {
    T_UI();

    if ([(id)self.delegate respondsToSelector:@selector(finishRegistrationAttempt:withInfo:)])
        [self.delegate finishRegistrationAttempt:self.attemptCount withInfo:self.registrationInfo];

    MCTInvocationOperation *op = [[MCTInvocationOperation alloc] initWithTarget:self
                                                                        selector:@selector(operationXMPPConnectionTest)
                                                                          object:nil];
    [[MCTComponentFramework commQueue] addOperation:op];
}

- (void)xmppConnected
{
    LOG(@"XMPP Test connection successful");
    self.succeeded = YES;
    [self stopXMPPConnection];
    [self sendFinishRegistrationRequest];
}

- (void)xmppDisconnectedWithWasAnalysing:(BOOL)wasAnalysing
{
    if (!self.succeeded) {
        LOG(@"XMPP Test connection failed");
        [self stopXMPPConnection];
        [self performSelectorOnMainThread:@selector(doFinishRegistrationAttempt) withObject:nil waitUntilDone:NO];
    }
}

- (void)stopXMPPConnection
{
    MCTInvocationOperation *op = [[MCTInvocationOperation alloc] initWithTarget:self.testXMPPConnection
                                                                        selector:@selector(disconnect)
                                                                          object:nil];
    [[MCTComponentFramework workQueue] addOperation:op];
    [[MCTComponentFramework workQueue] waitUntilAllOperationsAreFinished];
}

#pragma mark -
#pragma mark Sending FinishRegistration HTTP message

- (void)sendFinishRegistrationRequest
{
    T_DONTCARE();
    [self performSelectorOnMainThread:@selector(sendFinishRegistrationRequestFromUIThread) withObject:nil waitUntilDone:NO];
}

- (void)sendFinishRegistrationRequestFromUIThread
{
    T_UI();
    NSMutableDictionary *mobileInfoDict = [NSMutableDictionary dictionary];

    MCTMobileInfo *info = [MCTMobileInfo info];

    [mobileInfoDict setLong:2 forKey:@"version"];

    [mobileInfoDict setLong:info.app.type forKey:@"app_type"];
    [mobileInfoDict setLong:info.app.majorVersion forKey:@"app_major_version"];
    [mobileInfoDict setLong:info.app.minorVersion forKey:@"app_minor_version"];

    [mobileInfoDict setString:info.device.modelName forKey:@"device_model_name"];
    [mobileInfoDict setString:info.device.osVersion forKey:@"device_os_version"];

    [mobileInfoDict setString:info.carrier.isoCountryCode forKey:@"sim_country"];
    [mobileInfoDict setString:info.carrier.mobileCountryCode forKey:@"sim_country_code"];
    [mobileInfoDict setString:info.carrier.mobileNetworkCode forKey:@"sim_carrier_code"];
    [mobileInfoDict setString:info.carrier.carrierName forKey:@"sim_carrier_name"];

    [mobileInfoDict setString:info.locale.language forKey:@"locale_language"];
    [mobileInfoDict setString:info.locale.country forKey:@"locale_country"];

    [mobileInfoDict setString:info.timeZone.abbrevation forKey:@"timezone"];
    [mobileInfoDict setLong:info.timeZone.secondsFromGMT forKey:@"timezone_delta_gmt"];

    [mobileInfoDict setArray:[[[MCTComponentFramework registrationMgr] beacons] allValues]
                      forKey:@"beacons"];

    NSString *mobileInfoStr = [mobileInfoDict MCT_JSONRepresentation];

    NSString *urlStr = [NSString stringWithFormat:@"%@%@", MCT_HTTPS_BASE_URL, MCT_REGISTRATION_URL_FINISH];
    NSURL *url = [NSURL URLWithString:urlStr];

    if (self.finishRegistrationRequest) {
        [self.finishRegistrationRequest clearDelegatesAndCancel];
        MCT_RELEASE(self.finishRegistrationRequest);
    }
    self.finishRegistrationRequest = [MCTFormDataRequest requestWithURL:url];
    [self.finishRegistrationRequest setPostValue:mobileInfoStr forKey:@"mobileInfo"];
    [self.finishRegistrationRequest setPostValue:self.registrationInfo.credentials.username forKey:@"account"];
    [self.finishRegistrationRequest setPostValue:self.registrationInfo.credentials.password forKey:@"password"];
    [self.finishRegistrationRequest setPostValue:MCT_PRODUCT_ID forKey:@"app_id"];

    self.finishRegistrationRequest.delegate = self;
    self.finishRegistrationRequest.didFinishSelector = @selector(HTTPFinishRegistrationSuccess:);
    self.finishRegistrationRequest.didFailSelector = @selector(HTTPFinishRegistrationFailure:);
    self.finishRegistrationRequest.numberOfTimesToRetryOnTimeout = 3;
    self.finishRegistrationRequest.shouldRedirect = NO;
    self.finishRegistrationRequest.timeOutSeconds = 10;
    self.finishRegistrationRequest.allowCompressedResponse = YES;
    self.finishRegistrationRequest.useCookiePersistence = NO;
    self.finishRegistrationRequest.useSessionPersistence = NO;
    self.finishRegistrationRequest.validatesSecureCertificate = YES;

    NSString *invitorCode = [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_INVITATION_USERCODE];
    NSString *secret = [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_INVITATION_SECRET];

    if (invitorCode && secret) {
        [self.finishRegistrationRequest setPostValue:invitorCode forKey:@"invitor_code"];
        [self.finishRegistrationRequest setPostValue:secret forKey:@"invitor_secret"];
    }

    [[MCTComponentFramework workQueue] addOperation:self.finishRegistrationRequest];
}

- (void)HTTPFinishRegistrationFailure:(MCTFormDataRequest *)request
{
    T_UI();
    LOG(@"Finish registration failure (2)");
    LOG(@"ERROR: %@", [request responseString]);
    LOG(@"RESPONSE STATUS: %d", [request responseStatusCode]);
    [self performSelectorOnMainThread:@selector(doFinishRegistrationAttempt) withObject:nil waitUntilDone:NO];
}

- (void)HTTPFinishRegistrationSuccess:(MCTFormDataRequest *)request
{
    T_UI();
    if ([request responseStatusCode] == 200) {
        LOG(@"Finish registration success");

        NSString *responseString = [request responseString];
        LOG(@"Finish registration response: %@", responseString);
        NSDictionary *jsonDict = [responseString MCT_JSONValue];
        NSArray *discoveredBeacons = [jsonDict arrayForKey:@"discovered_beacons"];
        if (discoveredBeacons == nil) {
            discoveredBeacons = [NSArray array];
        }

        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            [[MCTComponentFramework configProvider] deleteStringForKey:MCT_PRE_REG_INFO_CONFIG_KEY];
            [[MCTComponentFramework configProvider] deleteStringForKey:MCT_REGISTRATION_BEACON_REGIONS];
            [[MCTComponentFramework configProvider] deleteStringForKey:MCT_REGISTRATION_DISCOVERED_BEACONS];
            [[MCTComponentFramework configProvider] setString:self.registrationInfo.credentials.username forKey:MCT_CONFIGKEY_USERNAME];
            [[MCTComponentFramework configProvider] setString:self.registrationInfo.credentials.password forKey:MCT_CONFIGKEY_PASSWORD];
        }];

        [[MCTComponentFramework appDelegate] setForceMyEmail:self.registrationInfo.email];

        [MCTUtils setBadgeNumber:0];

        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_REGISTRATION_COMPLETED];
        [intent setBool:![MCTUtils isEmptyOrWhitespaceString:[[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_INVITATION_SECRET]]
                 forKey:@"invitation_acked"];
        [intent setBool:![MCTUtils isEmptyOrWhitespaceString:[[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_REGISTRATION_OPENED_URL]]
                 forKey:@"invitation_to_be_acked"];
        [intent setBool:self.ageAndGenderSet forKey:@"age_and_gender_set"];

        [intent setString:[discoveredBeacons MCT_JSONRepresentation] forKey:@"discovered_beacons"];

        [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];

        [[MCTComponentFramework workQueue] waitUntilAllOperationsAreFinished];
        [self.delegate finishRegistrationSuccess];
    } else {
        LOG(@"Finish registration failure (1)");
        [self HTTPFinishRegistrationFailure:request];
    }
}

@end