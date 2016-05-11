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

#import "3rdParty/asi-http-request/Reachability.h"

#import "MCT_CS_API.h"
#import "MCTApplePush.h"
#import "MCTBacklogStreamer.h"
#import "MCTComponentFramework.h"
#import "MCTDefaultResponseHandler.h"
#import "MCTFriendsPlugin.h"
#import "MCTGetIdentityResponseHandler.h"
#import "MCTGetIdentityQRCodeResponseHandler.h"
#import "MCTGetJSEmbeddingReponseHandler.h"
#import "MCTHeartbeatResponseHandler.h"
#import "MCTHTTPRequest.h"
#import "MCTLogForwarding.h"
#import "MCTMobileInfo.h"
#import "MCTOperation.h"
#import "MCTSaveSettingsRH.h"
#import "MCTScanResult.h"
#import "MCTSystemPlugin.h"
#import "MCTUtils.h"

#import "TTGlobalUICommon.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>


#define MCT_MAX_ERROR_SEND_RATE 3600000 // 1 hour
#define MCT_HEARTBEAT_CONFIG_KEY @"heartbeat_system_info"

static NSTimeInterval MCTNextBackgroundFetchNever = -1;

@interface MCTSystemPlugin ()

@property (nonatomic, strong) NSArray *backgroundFetchTimestamps;
@property (nonatomic) NSTimeInterval currentBackgroundFetchInterval;

- (void)updateOldStyleShortLink;
- (void)checkSlashInShortLink;

@end


@implementation MCTSystemPlugin


- (MCTSystemPlugin *)init
{
    T_BIZZ();
    self = [super init];
    if (self) {
        self.identityStore = [[MCTIdentityStore alloc] init];
        self.store = [[MCTSystemStore alloc] init];
        self.identityRequestTimestamp = -1;
        self.errorLogTimestamp = -1;

        self.wifiOnlyDownloads = [@"YES" isEqualToString:[[MCTComponentFramework configProvider] stringForKey:MCT_CFG_KEY_WIFI_ONLY_DOWNLOADS]];

        NSString *bgFetchTimesJsonString = [[MCTComponentFramework configProvider] stringForKey:MCT_CFG_KEY_BG_FETCH_TIMES];
        if ([MCTUtils isEmptyOrWhitespaceString:bgFetchTimesJsonString]) {
            self.backgroundFetchTimestamps = [NSArray array];
        } else {
            self.backgroundFetchTimestamps = [bgFetchTimesJsonString MCT_JSONValue];
        }
        [self setBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];

        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_IDENTITY_QR_RETREIVED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_GET_MY_IDENTITY];

        [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                       forIntentActions:@[kINTENT_IDENTITY_QRCODE_ADDED,
                                                                          kINTENT_INVITATION_SECRETS_ADDED,
                                                                          kINTENT_CHECK_IDENTITY_SHORT_URL,
                                                                          kINTENT_GET_MY_IDENTITY,
                                                                          kINTENT_INIT_APNS_STATUS,
                                                                          kINTENT_DO_SETTINGS_RETRIEVAL]
                                                                onQueue:[MCTComponentFramework workQueue]];
        [self doHeartbeat];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onCurrentLocaleChanged)
                                                     name:NSCurrentLocaleDidChangeNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onTimeZoneChanged)
                                                     name:NSSystemTimeZoneDidChangeNotification
                                                   object:nil];

        CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
        info.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier* carrier) {
            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                [self doHeartbeat];
            }];
        };
    }
    return self;
}

- (void)stop
{
    T_BIZZ();
    HERE();
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
}

- (void)dealloc
{
    T_BIZZ();
    [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
    [self stop];
    
}

- (void)onCurrentLocaleChanged
{
    T_UI();
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        [self doHeartbeat];
    }];
}

- (void)onTimeZoneChanged
{
    T_UI();
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        [self doHeartbeat];
    }];
}

- (NSString *)currentNetworkState
{
    T_BIZZ();
    NSString *networkState;
    switch ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]) {
        case kNotReachable:
            networkState = @"NotReachable";
            break;
        case kReachableViaWWAN:
            networkState = @"ReachableViaWWAN";
            break;
        case kReachableViaWiFi:
            networkState = @"ReachableViaWiFi";
            break;
        default:
            networkState = @"Unknown";
            break;
    }
    return networkState;
}

- (void)doHeartbeat
{
    T_BIZZ();
    MCTMobileInfo *info = [MCTMobileInfo info];

    NSString *heartbeatInfo = [info fingerPrint];

    NSString *storedInfo = [[MCTComponentFramework configProvider] stringForKey:MCT_HEARTBEAT_CONFIG_KEY];
    if (storedInfo && [heartbeatInfo isEqualToString:storedInfo])
        return;

    MCTlong now = [MCTUtils currentTimeMillis];

    MCT_com_mobicage_to_system_HeartBeatRequestTO *request = [MCT_com_mobicage_to_system_HeartBeatRequestTO transferObject];

    // general info
    request.buildFingerPrint = [info.device fingerPrint];
    request.flushBackLog = NO;
    request.networkState = [self currentNetworkState];
    request.timestamp = now;

    // app info
    request.appType = info.app.type;
    request.majorVersion = info.app.majorVersion;
    request.minorVersion = info.app.minorVersion;
    request.product = info.app.name;

    // carrier info
    request.simCountry = info.carrier.isoCountryCode;
    request.simCountryCode = info.carrier.mobileCountryCode;
    request.simCarrierCode = info.carrier.mobileNetworkCode;
    request.simCarrierName = info.carrier.carrierName;

    // net info
    request.netCountry = nil;
    request.netCountryCode = nil;
    request.netCarrierCode = nil;
    request.netCarrierName = nil;

    // locale info
    request.localeCountry = info.locale.country;
    request.localeLanguage = info.locale.language;

    // timeZone info
    request.timezone = info.timeZone.abbrevation;
    request.timezoneDeltaGMT = info.timeZone.secondsFromGMT;

    // device info
    request.deviceModelName = info.device.modelName;
    request.SDKVersion = info.device.osVersion;

    MCTHeartbeatResponseHandler *responseHandler = [[MCTHeartbeatResponseHandler alloc] init];
    responseHandler.requestSubmissionTimestamp = now;

    [MCT_com_mobicage_api_system CS_API_heartBeatWithResponseHandler:responseHandler andRequest:request];

    [[MCTComponentFramework configProvider] setString:heartbeatInfo forKey:MCT_HEARTBEAT_CONFIG_KEY];
}

- (void)requestIdentity
{
    T_BIZZ();
    if ([MCTUtils currentTimeMillis] - self.identityRequestTimestamp > 3600000) {
        LOG(@"Requesting My Identity");
        self.identityRequestTimestamp = [MCTUtils currentTimeMillis];

        MCT_com_mobicage_to_system_GetIdentityRequestTO *request = [MCT_com_mobicage_to_system_GetIdentityRequestTO transferObject];
        MCTGetIdentityResponseHandler *responseHandler = [MCTGetIdentityResponseHandler responseHandler];

        [MCT_com_mobicage_api_system CS_API_getIdentityWithResponseHandler:responseHandler andRequest:request];
    }
}

- (MCTIdentity *)myIdentity
{
    T_DONTCARE();

    MCTIdentity *me = [self.identityStore myIdentity];
    if (me == nil) {
        [[MCTComponentFramework workQueue] addOperation:[MCTInvocationOperation operationWithTarget:self
                                                                                           selector:@selector(requestIdentity)
                                                                                             object:nil]];
    }
    return me;
}

+ (NSString *)exceptionsDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"exceptions"];
}

+ (void)processUncaughtExceptionFilesWithIsRegistered:(BOOL)isRegistered
{
    T_DWNL();
    NSArray *errorFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[MCTSystemPlugin exceptionsDir]
                                                                              error:nil];
    if (errorFiles) {
        for (NSString *errorFileName in errorFiles) {
            NSString *errorFile = [[MCTSystemPlugin exceptionsDir] stringByAppendingPathComponent:errorFileName];
            NSError *error = nil;
            NSString *errorJsonString = [NSString stringWithContentsOfFile:errorFile
                                                                  encoding:NSUTF8StringEncoding
                                                                     error:&error];
            if (error) {
                LOG(@"%@ can't be opened or there is an encoding error: %@", errorFile, error);
                [[NSFileManager defaultManager] removeItemAtPath:errorFile error:nil];
                continue;
            }

            NSDictionary *errorDict = [errorJsonString MCT_JSONValue];
            if (!errorDict) {
                LOG(@"%@ can't be parsed. Content is: %@", errorFile, errorJsonString);
                [[NSFileManager defaultManager] removeItemAtPath:errorFile error:nil];
            } else {
                BOOL success = [self sendErrorToServer:errorDict];
                if (success) {
                    [[NSFileManager defaultManager] removeItemAtPath:errorFile error:nil];
                }
            }
        }
    }
}

+ (void)logError:(NSException *)exception withMessage:(NSString *)msg
{
    NSString *errorDescription = [NSString stringWithFormat:@"%@: %@", [exception name], [exception reason]];
    NSString *errorMessage;
    if ([MCTUtils isEmptyOrWhitespaceString:msg]) {
        errorMessage = [MCTUtils stackTraceFromException:exception];
    } else {
        errorMessage = [NSString stringWithFormat:@"%@\n%@", msg, [MCTUtils stackTraceFromException:exception]];
    }

    [MCTSystemPlugin logErrorWithMessage:errorMessage
                             description:errorDescription];
}

+ (void)logErrorWithMessage:(NSString *)errorMessage
                description:(NSString *)errorDescription
{
    MCTSystemPlugin *plugin = [MCTComponentFramework systemPlugin];
    if (plugin) {
        [plugin logErrorViaBacklogWithMessage:errorMessage
                                  description:errorDescription];
    } else {
        [MCTSystemPlugin logErrorOverHTTPWithMessage:errorMessage description:errorDescription];
    }
}

- (void)logErrorViaBacklogWithMessage:(NSString *)errorMessage
                          description:(NSString *)errorDescription
{
    T_DONTCARE();
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        if ([MCTUtils currentTimeMillis] - self.errorLogTimestamp < MCT_MAX_ERROR_SEND_RATE)
            return;

        MCT_com_mobicage_to_system_LogErrorRequestTO *request = [MCT_com_mobicage_to_system_LogErrorRequestTO transferObject];
        request.descriptionX = errorDescription;
        request.errorMessage = errorMessage;
        request.mobicageVersion = [NSString stringWithFormat:@"%@%@", (MCT_DEBUG ? @"-" : @""), MCT_PRODUCT_VERSION];
        request.platform = [MCTApplicationInfo type];
        request.platformVersion = [[UIDevice currentDevice] systemVersion];
        request.timestamp = [MCTUtils currentTimeMillis];

        NSString *errorString = [NSString stringWithFormat:@"%@\n%@", request.descriptionX, request.errorMessage];

        [MCT_com_mobicage_api_system CS_API_logErrorWithResponseHandler:[MCTDefaultResponseHandler defaultResponseHandler]
                                                             andRequest:request];
    }];
}

+ (void)logErrorOverHTTP:(NSException *)exception
{
    NSString *errorDescription = [NSString stringWithFormat:@"%@: %@", [exception name], [exception reason]];
    NSString *errorMessage = [NSString stringWithFormat:@"Uncaught exeption\n%@",
                              [MCTUtils stackTraceFromException:exception]];
    [MCTSystemPlugin logErrorOverHTTPWithMessage:errorMessage
                                     description:errorDescription];
}

+ (void)logErrorOverHTTPWithMessage:(NSString *)errorMessage
                        description:(NSString *)errorDescription
{
    T_DONTCARE();
    NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
    [errorDict setString:errorDescription
                  forKey:@"description"];
    [errorDict setString:errorMessage
                  forKey:@"error_message"];

    TRY_OR_LOG_EXCEPTION({
        [errorDict setString:[MCTRegistrationMgr installationId]
                      forKey:@"install_id"];
    });
    TRY_OR_LOG_EXCEPTION({
        [errorDict setString:[MCTUtils deviceId]
                      forKey:@"device_id"];
    });
    TRY_OR_LOG_EXCEPTION({
        MCTLocaleInfo *localeInfo = [MCTLocaleInfo info];
        [errorDict setString:localeInfo.language
                      forKey:@"language"];
        [errorDict setString:localeInfo.country
                      forKey:@"country"];
    });
    TRY_OR_LOG_EXCEPTION({
        [errorDict setString:[NSString stringWithFormat:@"%@%@", (MCT_DEBUG ? @"-" : @""), MCT_PRODUCT_VERSION]
                      forKey:@"mobicage_version"];
    });
    TRY_OR_LOG_EXCEPTION({
        [errorDict setLong:[MCTApplicationInfo type]
                    forKey:@"platform"];
    });
    TRY_OR_LOG_EXCEPTION({
        [errorDict setString:[[UIDevice currentDevice] systemVersion]
                      forKey:@"platform_version"];
    });
    TRY_OR_LOG_EXCEPTION({
        [errorDict setLong:[MCTUtils currentTimeMillis]
                      forKey:@"timestamp"];
    });

    [[NSFileManager defaultManager] createDirectoryAtPath:[MCTSystemPlugin exceptionsDir]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    NSString *errorFile = [[MCTSystemPlugin exceptionsDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld", [MCTUtils currentTimeMillis]]];
    NSError *writingError = nil;
    [[errorDict MCT_JSONRepresentation] writeToFile:errorFile
                                         atomically:YES
                                           encoding:NSUTF8StringEncoding
                                              error:&writingError];

    NSString *errorString = [NSString stringWithFormat:@"%@\n%@", errorDescription, errorMessage];

    BOOL success = [self sendErrorToServer:errorDict];
    if (success) {
        [[NSFileManager defaultManager] removeItemAtPath:errorFile error:nil];
    }
}

+ (BOOL)sendErrorToServer:(NSDictionary *)errorDict
{
    T_DONTCARE();
    NSString *xmppUsername = nil;
    NSString *xmppPassword = nil;
    TRY_OR_LOG_EXCEPTION({
        xmppUsername = [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_USERNAME];
        xmppPassword = [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_PASSWORD];
    });

    BOOL isRegistered = xmppUsername && xmppPassword;

    NSString *url = [NSString stringWithFormat:@"%@%@", MCT_HTTP_BASE_URL, MCT_LOG_ERROR];
    MCTFormDataRequest *httpRequest = [MCTFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    httpRequest.timeOutSeconds = 5;
    httpRequest.requestMethod = @"POST";

    if (isRegistered) {
        [httpRequest addRequestHeader:@"X-MCTracker-User" value:[xmppUsername MCTBase64Encode]];
        [httpRequest addRequestHeader:@"X-MCTracker-Pass" value:[xmppPassword MCTBase64Encode]];
    }

    [errorDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id <NSObject> obj, BOOL *stop) {
        [httpRequest addPostValue:obj forKey:key];
    }];

    __weak typeof(httpRequest) weakHttpRequest = httpRequest;
    [httpRequest setCompletionBlock:^{
        if (MCT_DEBUG_LOGGING) {
            LOG(@"Success: %@", [weakHttpRequest responseString]);
        }
    }];
    [httpRequest setFailedBlock:^{
        if (MCT_DEBUG_LOGGING) {
            LOG(@"Failed: %@", [weakHttpRequest error]);
        }
    }];

    [httpRequest startSynchronous];

    return !httpRequest.error;
}

- (void)requestIdentityQRCode
{
    T_BIZZ();
    LOG(@"Requesting My Identity QR");

    MCTIdentity *myIdentity = [self myIdentity];
    if (myIdentity) {
        MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO *request = [MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO transferObject];
        request.size = @"150x150";
        request.email = myIdentity.email;
        MCTGetIdentityQRCodeResponseHandler *responseHandler = [MCTGetIdentityQRCodeResponseHandler responseHandler];

        [MCT_com_mobicage_api_system CS_API_getIdentityQRCodeWithResponseHandler:responseHandler andRequest:request];
    }
}

- (void)saveSettingsWithTrackingEnabled:(BOOL)trackingEnabled
{
    T_BIZZ();
    MCT_com_mobicage_to_system_SaveSettingsRequest *req = [MCT_com_mobicage_to_system_SaveSettingsRequest transferObject];
    req.tracking = trackingEnabled;
    req.callLogging = NO;

    [MCT_com_mobicage_api_system CS_API_saveSettingsWithResponseHandler:[MCTSaveSettingsRH responseHandler]
                                                             andRequest:req];
}

- (void)updateOldStyleShortLink
{
    T_BIZZ();
    MCTIdentity *myIdentity = [self.identityStore myIdentity];
    NSString *oldPrefix = [MCT_HTTPS_BASE_URL stringByAppendingFormat:@"/%@", MCT_URL_PREFIX_SHORT_LINK];
    if ([myIdentity.shortUrl hasPrefix:oldPrefix]) {
        NSString *newPrefix = [MCT_HTTPS_BASE_URL stringByAppendingFormat:@"/%@", MCT_URL_PREFIX_INVITATION_LINK];
        NSString *shortUrl = [myIdentity.shortUrl stringByReplacingOccurrencesOfString:oldPrefix withString:newPrefix];
        [self.identityStore updateShortUrl:shortUrl];
    }
}

- (void)checkSlashInShortLink
{
    T_BIZZ();
    NSString *shortUrl = [self.identityStore myIdentity].shortUrl;
    if (![MCTUtils isEmptyOrWhitespaceString:shortUrl]) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^https://rogerth.at/M/([0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ$*-./:]+)(\\?.*)?$"
                                                                               options:0
                                                                                 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:shortUrl options:regex.options range:[shortUrl range]];
        if (match) {
            NSString *code = [shortUrl substringWithRange:[match rangeAtIndex:1]];
            if ([code containsString:@"/"]) {
                [self requestIdentity];
            }
        }
    }
}

- (void)editProfileWithNewName:(NSString *)newNameOrNil
                     newAvatar:(UIImage *)newAvatarOrNil
                  newBirthdate:(MCTlong)newBirthdate
                     newGender:(MCTlong)newGender
                  hasBirthdate:(BOOL)hasBirthdate
                     hasGender:(BOOL)hasGender
{
    T_BIZZ();
    NSData *avatar = newAvatarOrNil ? UIImagePNGRepresentation(newAvatarOrNil) : nil;
    [self editProfileWithNewName:newNameOrNil
                   newAvatarData:avatar
                    accesssToken:nil
                    newBirthdate:newBirthdate
                        newGender:newGender
                    hasBirthdate:hasBirthdate
                       hasGender:hasGender];
}


- (void)editProfileWithNewName:(NSString *)newNameOrNil
                 newAvatarData:(NSData *)avatar
                  accesssToken:(NSString *)fbAccessToken
                  newBirthdate:(MCTlong)newBirthdate
                     newGender:(MCTlong)newGender
                  hasBirthdate:(BOOL)hasBirthdate
                     hasGender:(BOOL)hasGender
{
    T_BIZZ();
    MCTIdentity *myIdentity = [self myIdentity];
    NSString *name = [MCTUtils isEmptyOrWhitespaceString:newNameOrNil] ? myIdentity.name : newNameOrNil;

    myIdentity.name = name;
    myIdentity.avatar = avatar;

    if (hasBirthdate == YES){
        myIdentity.hasBirthdate = hasBirthdate;
        myIdentity.birthdate = newBirthdate;
    }
    if (hasGender == YES){
        myIdentity.hasGender = hasGender;
        myIdentity.gender = newGender;
    }

    [self.identityStore updateMyIdentityWithoutDownloadingAvatar:myIdentity];

    MCT_com_mobicage_to_system_EditProfileRequestTO *request = [MCT_com_mobicage_to_system_EditProfileRequestTO transferObject];
    request.name = name;
    request.avatar = [avatar MCTBase64Encode];
    request.access_token = fbAccessToken;
    request.birthdate = newBirthdate;
    request.gender = newGender;
    request.has_birthdate = hasBirthdate;
    request.has_gender = hasGender;

    [MCT_com_mobicage_api_system CS_API_editProfileWithResponseHandler:[MCTDefaultResponseHandler defaultResponseHandler]
                                                            andRequest:request];
}

- (void)getJSEmbedding
{
    T_BIZZ();
    LOG(@"Requesting update of js embedding");
    MCT_com_mobicage_to_js_embedding_GetJSEmbeddingRequestTO *request = [MCT_com_mobicage_to_js_embedding_GetJSEmbeddingRequestTO transferObject];
    MCTGetJSEmbeddingReponseHandler *responseHandler = [MCTGetJSEmbeddingReponseHandler responseHandler];

    [MCT_com_mobicage_api_system CS_API_getJsEmbeddingWithResponseHandler:responseHandler andRequest:request];
}


- (NSDictionary *)jsEmbeddedPackets
{
    return [self.store jsEmbeddedPackets];
}

- (void)updateJSEmbeddedWithPackets:(NSArray *)packets
{
    NSMutableDictionary *jep = [NSMutableDictionary dictionaryWithDictionary:[self jsEmbeddedPackets]];

    for (MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO *jei in packets) {
        MCTJSEmbedding *s = [jep objectForKey:jei.name];
        if (s != nil && [s.embeddingHash isEqualToString:jei.hashX] && s.status == MCTJSEmbeddingStatusAvailable) {
            [jep removeObjectForKey:jei.name];
        }
        else {
            [jep removeObjectForKey:jei.name];
            [self updateJSEmbeddedWithName:jei.name hash:jei.hashX status:MCTJSEmbeddingStatusUnavailable];
            [[MCTComponentFramework brandingMgr] queueJSEmbeddedPacketWithName:jei.name embeddingHash:jei.hashX];
        }
    }

    for (NSString *key in [jep allKeys]) {
        [self.store deleteJSEmbeddedWithName:key];
        [[MCTComponentFramework brandingMgr] cleanupJSEmbeddingDirWithName:key];
    }
}

- (void)updateJSEmbeddedWithName:(NSString *)name hash:(NSString *)hash status:(MCTJSEmbeddingStatus)status
{
    [self.store updateJSEmbeddedWithName:name hash:hash status:status];
}

#pragma mark -
#pragma mark CallReceiver methods

- (MCT_com_mobicage_to_system_IdentityUpdateResponseTO *)SC_API_identityUpdateWithRequest:(MCT_com_mobicage_to_system_IdentityUpdateRequestTO *)request
{
    T_BACKLOG();
    [self.identityStore updateMyIdentity:request.identity withShortUrl:nil];
    return [MCT_com_mobicage_to_system_IdentityUpdateResponseTO transferObject];
}

- (MCT_com_mobicage_to_system_UnregisterMobileResponseTO *)SC_API_unregisterMobileWithRequest:(MCT_com_mobicage_to_system_UnregisterMobileRequestTO *)request
{
    T_BACKLOG();
    [[MCTComponentFramework intentFramework] broadcastIntent:[MCTIntent intentWithAction:kINTENT_MOBILE_UNREGISTERED]];
    return [MCT_com_mobicage_to_system_UnregisterMobileResponseTO transferObject];
}

- (MCT_com_mobicage_to_system_UpdateAvailableResponseTO *)SC_API_updateAvailableWithRequest:(MCT_com_mobicage_to_system_UpdateAvailableRequestTO *)request
{
    T_BACKLOG();
    HERE();
    LOG(@"updateAvailable not implemented");
    return [MCT_com_mobicage_to_system_UpdateAvailableResponseTO transferObject];
}

- (MCT_com_mobicage_to_system_UpdateSettingsResponseTO *)SC_API_updateSettingsWithRequest:(MCT_com_mobicage_to_system_UpdateSettingsRequestTO *)request
{
    T_BACKLOG();
    [self updateSettings:request.settings];
    return [MCT_com_mobicage_to_system_UpdateSettingsResponseTO transferObject];
}

- (MCT_com_mobicage_to_system_ForwardLogsResponseTO *)SC_API_forwardLogsWithRequest:(MCT_com_mobicage_to_system_ForwardLogsRequestTO *)request
{
    T_BACKLOG();
    MCTLogForwarder *logForwarder = [MCTLogForwarder logForwarder];

    if ([MCTUtils isEmptyOrWhitespaceString:request.jid]) {
        [logForwarder stop];
    } else {
        [logForwarder startWithTarget:request.jid];
    }

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_FORWARDING_LOGS];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];

    [[MCTComponentFramework activityPlugin] logActivityWithText:[logForwarder forwarding] ? MCT_FORWARDING_LOGS_ON_STRING : MCT_FORWARDING_LOGS_OFF_STRING
                                                    andLogLevel:MCTActivityLogWarning];

    return [MCT_com_mobicage_to_system_ForwardLogsResponseTO transferObject];
}

- (MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingResponseTO *)SC_API_updateJsEmbeddingWithRequest:(MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO *)request
{
    T_BACKLOG();
    [self updateJSEmbeddedWithPackets:request.items];
    return [MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingResponseTO transferObject];
}

- (void)updateSettings:(MCT_com_mobicage_to_system_SettingsTO *)settings
{
    T_BACKLOG();
    HERE();
    int currentVersion = [[[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_SETTINGS_VERSION] intValue];
    if (currentVersion < settings.version) {
        NSEnumerator *enumerator = [[[MCTComponentFramework appDelegate] plugins] objectEnumerator];
        for (MCTPlugin *plugin in enumerator)
            [plugin processSettings:settings];

        [[MCTComponentFramework configProvider] setString:[NSString stringWithFormat:@"%lld", settings.version]
                                                   forKey:MCT_CONFIGKEY_SETTINGS_VERSION];
    }
}

- (void)processSettings:(MCT_com_mobicage_to_system_SettingsTO *)settings
{
    T_BACKLOG();
    HERE();

    self.wifiOnlyDownloads = settings.wifiOnlyDownloads;
    [[MCTComponentFramework configProvider] setString:BOOLSTR(self.wifiOnlyDownloads)
                                               forKey:MCT_CFG_KEY_WIFI_ONLY_DOWNLOADS];

    self.backgroundFetchTimestamps = settings.backgroundFetchTimestamps;
    [[MCTComponentFramework configProvider] setString:[self.backgroundFetchTimestamps MCT_JSONRepresentation]
                                               forKey:MCT_CFG_KEY_BG_FETCH_TIMES];
    [self calculateNextBackgroundFetchInterval];
}

- (void)setBackgroundFetchInterval:(NSTimeInterval)fetchInterval
{
    if (self.currentBackgroundFetchInterval != fetchInterval) {
        self.currentBackgroundFetchInterval = fetchInterval;
        [self calculateNextBackgroundFetchInterval];
    }
}

- (void)calculateNextBackgroundFetchInterval
{
    // Called when app woke up for background fetch,
    // or when communication manager changes communication polling/retry interval
    NSTimeInterval nextBackgroundFetchInSeconds;
    if (self.currentBackgroundFetchInterval == UIApplicationBackgroundFetchIntervalNever) {
        nextBackgroundFetchInSeconds = MCTNextBackgroundFetchNever;
    } else {
        nextBackgroundFetchInSeconds = self.currentBackgroundFetchInterval;
    }

    LOG(@"self.backgroundFetchTimestamps = %@", self.backgroundFetchTimestamps);
    LOG(@"currentBackgroundFetchInterval = %f", self.currentBackgroundFetchInterval);

    if ([self.backgroundFetchTimestamps count]) {
        MCTlong now = [MCTUtils currentTimeSeconds] % 86400;
        for (NSNumber *number in self.backgroundFetchTimestamps) {
            MCTlong timestamp = [number longLongValue];
            NSTimeInterval delta = timestamp - now;
            if (delta < 0) {
                delta += 86400;
            }

            if (nextBackgroundFetchInSeconds == MCTNextBackgroundFetchNever || delta < nextBackgroundFetchInSeconds) {
                nextBackgroundFetchInSeconds = delta;
            }
        }
    }

    if (nextBackgroundFetchInSeconds == MCTNextBackgroundFetchNever) {
        HTTPLOG(@"Setting minimumBackgroundFetchInterval to UIApplicationBackgroundFetchIntervalNever");
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
        self.currentBackgroundFetchInterval = UIApplicationBackgroundFetchIntervalNever;
    } else {
        HTTPLOG(@"Setting minimumBackgroundFetchInterval to %f", nextBackgroundFetchInSeconds);
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:nextBackgroundFetchInSeconds];
        self.currentBackgroundFetchInterval = nextBackgroundFetchInSeconds;
    }
}

#pragma mark -

- (void)onIntent:(MCTIntent *)intent
{
    T_BIZZ();
    if (intent.action == kINTENT_IDENTITY_QRCODE_ADDED) {
        [self requestIdentityQRCode];
    }

    else if (intent.action == kINTENT_INVITATION_SECRETS_ADDED) {
        [self updateOldStyleShortLink];
    }

    else if (intent.action == kINTENT_CHECK_IDENTITY_SHORT_URL) {
        [self checkSlashInShortLink];
    }

    else if (intent.action == kINTENT_GET_MY_IDENTITY) {
        [self requestIdentity];
    }

    else if (intent.action == kINTENT_INIT_APNS_STATUS) {
        if ([[MCTComponentFramework appDelegate] isRegistered]) {
            [[MCTComponentFramework configProvider] setString:@"YES" forKey:MCT_DID_REGISTER_FOR_PUSH_NOTIFICATIONS];
        }
        [[MCTComponentFramework intentFramework] removeStickyIntent:intent];
    }

    else if (intent.action == kINTENT_DO_SETTINGS_RETRIEVAL) {
        [self saveSettingsWithTrackingEnabled:![[NSUserDefaults standardUserDefaults] boolForKey:MCT_SETTINGS_INVISIBLE]];
    }
}

@end