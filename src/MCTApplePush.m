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

#import "MCTApplePush.h"

#import "MCTDefaultResponseHandler.h"
#import "MCT_CS_API.h"
#import "MCTComponentFramework.h"


/* The following keys are used by the Apple push messages.
 * We want the localization tools to process them in Localizable.strings
 * DO NOT DELETE THESE CONSTANTS
 */
#define MCT_PLACEHOLDER_MA NSLocalizedString(@"MA", nil)
#define MCT_PLACEHOLDER_RM NSLocalizedString(@"RM", nil)
#define MCT_PLACEHOLDER_NM NSLocalizedString(@"NM", nil)


@interface MCTApplePush()
+ (NSString *)serializeDeviceToken:(NSData *)deviceToken;
@end


#pragma mark -
#pragma mark UpdateDeviceTokenOperation

@interface UpdateDeviceTokenOperation : MCTOperation {
    NSData *deviceToken_;
}

- (id)initWithDeviceToken:(NSData *)token;

@property (nonatomic, strong) NSData *deviceToken;

@end


@implementation UpdateDeviceTokenOperation


- (id)initWithDeviceToken:(NSData *)token
{
    if (self = [super init]) {
        self.deviceToken = token;
    }
    return self;
}

- (void)main
{
    T_BIZZ();
    MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenRequestTO *request = [MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenRequestTO transferObject];
    request.token = [MCTApplePush serializeDeviceToken:self.deviceToken];
    MCTDefaultResponseHandler *responseHandler = [MCTDefaultResponseHandler defaultResponseHandler];
    [MCT_com_mobicage_api_system CS_API_updateApplePushDeviceTokenWithResponseHandler:responseHandler andRequest:request];
    LOG(@"Registered APNS device token %@", [self.deviceToken description]);
}


@end


#pragma mark -
#pragma mark MCTApplePush


@implementation MCTApplePush

+ (void)registerForPushNotifications
{
    T_UI();
    UIRemoteNotificationType types = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
    IF_PRE_IOS8({
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    });
    IF_IOS8_OR_GREATER({
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    });
    [[MCTComponentFramework configProvider] setString:@"YES" forKey:MCT_DID_REGISTER_FOR_PUSH_NOTIFICATIONS];
}

+ (void)unregisterForPushNotifications
{
    T_UI();
    BUG(@"unregisterForPushNotifications: Should not be used in production");
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

+ (BOOL)didRegisterForPushNotifications
{
    NSString *boolStr = [[MCTComponentFramework configProvider] stringForKey:MCT_DID_REGISTER_FOR_PUSH_NOTIFICATIONS];
    return boolStr != nil && [boolStr isEqualToString:@"YES"];
}

+ (void)sendToken:(NSData *)deviceToken
{
    T_UI();
    UpdateDeviceTokenOperation *op = [[UpdateDeviceTokenOperation alloc] initWithDeviceToken:deviceToken];
    [[MCTComponentFramework workQueue] addOperation:op];
}

// Code from http://stackoverflow.com/questions/1305225/best-way-to-serialize-a-nsdata-into-an-hexadeximal-string
+ (NSString *)serializeDeviceToken:(NSData *)deviceToken
{
    NSMutableString *str = [NSMutableString stringWithCapacity:64];
    NSInteger length = [deviceToken length];
    char *bytes = malloc(sizeof(char) * length);

    [deviceToken getBytes:bytes length:length];

    for (int i = 0; i < length; i++)
    {
        [str appendFormat:@"%02.2hhX", bytes[i]];
    }
    free(bytes);

    return str;
}

@end