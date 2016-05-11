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

#import "MCTPlugin.h"
#import "MCTCallReceiver.h"
#import "MCTIdentity.h"
#import "MCTIdentityStore.h"
#import "MCTIntentFramework.h"
#import "MCTSystemStore.h"
#import "MCTJSEmbedding.h"


#define TRY_OR_LOG_EXCEPTION(...) \
    @try { \
        __VA_ARGS__ \
    } \
    @catch (NSException *e) { \
        if (MCT_DEBUG_LOGGING) \
            LOG(@"%@", e); \
    }

#define MCT_CFG_KEY_WIFI_ONLY_DOWNLOADS @"wifiOnlyDownloads"
#define MCT_CFG_KEY_BG_FETCH_TIMES @"iosBackgroundFetchTimestamps"


@interface MCTSystemPlugin : MCTPlugin <MCT_com_mobicage_capi_system_IClientRPC, IMCTIntentReceiver>

@property MCTlong identityRequestTimestamp;
@property MCTlong errorLogTimestamp;
@property (nonatomic, strong) MCTIdentityStore *identityStore;
@property (nonatomic, strong) MCTSystemStore *store;
@property (nonatomic) BOOL wifiOnlyDownloads;

- (void)updateSettings:(MCT_com_mobicage_to_system_SettingsTO *)settings;

- (void)setBackgroundFetchInterval:(NSTimeInterval)fetchInterval;
- (void)calculateNextBackgroundFetchInterval;

- (void)doHeartbeat;
- (void)requestIdentity;
- (void)requestIdentityQRCode;
- (void)saveSettingsWithTrackingEnabled:(BOOL)trackingEnabled;
- (void)editProfileWithNewName:(NSString *)name
                     newAvatar:(UIImage *)newAvatar
                  newBirthdate:(MCTlong)newBirthdate
                  newGender:(MCTlong)newGender
                  hasBirthdate:(BOOL)hasBirthdate
                     hasGender:(BOOL)hasGender;
- (void)editProfileWithNewName:(NSString *)newNameOrNil
                 newAvatarData:(NSData *)avatar
                  accesssToken:(NSString *)fbAccessToken
                  newBirthdate:(MCTlong)newBirthdate
                     newGender:(MCTlong)newGender
                  hasBirthdate:(BOOL)hasBirthdate
                     hasGender:(BOOL)hasGender;
- (MCTIdentity *)myIdentity;

+ (NSString *)exceptionsDir;
+ (void)processUncaughtExceptionFilesWithIsRegistered:(BOOL)isRegistered;

+ (void)logErrorOverHTTP:(NSException *)exception;
+ (void)logErrorOverHTTPWithMessage:(NSString *)errorMessage
                        description:(NSString *)errorDescription;

+ (void)logError:(NSException *)exception withMessage:(NSString *)msg;
+ (void)logErrorWithMessage:(NSString *)errorMessage
                description:(NSString *)errorDescription;

- (void)getJSEmbedding;
- (NSDictionary *)jsEmbeddedPackets;
- (void)updateJSEmbeddedWithPackets:(NSArray *)packets;
- (void)updateJSEmbeddedWithName:(NSString *)name hash:(NSString *)hash status:(MCTJSEmbeddingStatus)status;

@end