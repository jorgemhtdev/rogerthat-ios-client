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

#import "sqlite3.h"
#import "MCTCredentials.h"
#import "MCTStore.h"


#define MCT_CONFIGKEY_USERNAME @"username"
#define MCT_CONFIGKEY_PASSWORD @"password"
#define MCT_CONFIGKEY_PHONE_NUMBER @"PHONE_NUMBER"
#define MCT_CONFIGKEY_REGISTRATION_OPENED_URL @"REGISTRATION_OPENED_URL"
#define MCT_CONFIGKEY_TOS_ACCEPTED @"REGISTRATION_TOS_ACCEPTED"
#define MCT_CONFIGKEY_LOCATION_USAGE_SHOWN @"REGISTRATION_LOCATION_USAGE_SHOWN"
#define MCT_CONFIGKEY_PUSH_NOTIFICATION_SHOWN @"REGISTRATION_PUSH_NOTIFICATION_SHOWN"
#define MCT_CONFIGKEY_ADDRESSBOOK_SCAN @"ADDRESSBOOK_SCAN"
#define MCT_CONFIGKEY_FACEBOOK_FRIENDS_SCAN @"FACEBOOK_FRIENDS_SCAN"
#define MCT_CONFIGKEY_FACEBOOK_ACCESSTOKEN @"FACEBOOK_ACCESSTOKEN"
#define MCT_CONFIGKEY_FACEBOOK_EXPIRATIONDATE @"FACEBOOK_EXPIRATIONDATE"
#define MCT_CONFIGKEY_FACEBOOK_POST_QR_ON_WALL @"FACEBOOK_POST_QR_ON_WALL"

#define MCT_CONFIGKEY_INSTALLATION_ID @"installationId"
#define MCT_CONFIGKEY_HINT_DOUBLE_TAP @"hint_double_tap"
#define MCT_CONFIGKEY_HINT_SWIPE @"hint_swipe"
#define MCT_CONFIGKEY_HINT_MSG_DISAPPEARED @"msg_disappeared"
#define MCT_CONFIGKEY_HINT_BROADCAST @"hint_broadcast"

#define MCT_CONFIGKEY_CACHED_DOWNLOADS_CLEANUP @"CACHED_DOWNLOADS_CLEANUP"



@interface MCTConfigProvider : MCTStore

- (void)setString:(NSString *)value forKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (void)deleteStringForKey:(NSString *)key;

@end