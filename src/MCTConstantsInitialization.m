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

#import "MCTUtils.h"
#import "MCTUIUtils.h"

id MCTNull;
id MCTYES;
id MCTNO;
id MCTONE;
id MCTEmptyArray;
id MCTEmptyDict;

id MCTDictClass;
id MCTMutableDictClass;
id MCTArrayClass;
id MCTMutableArrayClass;
id MCTStringClass;
id MCTMutableStringClass;
id MCTBooleanClass;
id MCTLongClass;
id MCTFloatClass;

NSString *MCT_HTTP_BASE_URL;
NSString *MCT_HTTPS_BASE_URL;
NSString *MCT_HTTPS_BASE_URL_HOST;
NSURL *MCT_LOG_FORWARDING_URL;
BOOL MCT_USE_XMPP_KICK_CHANNEL;
NSString *MCT_XMPP_KICK_COMPONENT;
BOOL MCT_DEBUG_LOGGING;
BOOL MCT_USE_SECURE_XMPP_CONNECTION;
BOOL MCT_USE_TRUSTSTORE;
BOOL MCT_FRIENDS_ENABLED;
MCTFriendsCaption MCT_FRIENDS_CAPTION;
BOOL MCT_SHOW_FRIENDS_IN_MORE;
BOOL MCT_SHOW_PROFILE_IN_MORE;
BOOL MCT_SHOW_HOMESCREEN_FOOTER;
NSString *MCT_SCAN_URL_PREFIX;
NSString *MCT_PRODUCT_VERSION;
NSString *MCT_PRODUCT_NAME;
NSString *MCT_PRODUCT_ID;
BOOL MCT_FACEBOOK_REGISTRATION;
NSString *MCT_REGISTRATION_MAIN_SIGNATURE;
NSString *MCT_REGISTRATION_EMAIL_SIGNATURE;
NSString *MCT_REGISTRATION_PIN_SIGNATURE;
NSString *MCT_EMAIL_HASH_ENCRYPTION_KEY;
BOOL MCT_MESSAGES_SHOW_REPLY_VS_UNREAD_COUNT;
NSString *MCT_ABOUT_WEBSITE;
NSString *MCT_ABOUT_WEBSITE_URL;
NSString *MCT_ABOUT_EMAIL;
NSString *MCT_ABOUT_TWITTER;
NSString *MCT_ABOUT_TWITTER_APP_URL;
NSString *MCT_ABOUT_TWITTER_URL;
NSString *MCT_ABOUT_FACEBOOK;
NSString *MCT_ABOUT_FACEBOOK_URL;

NSString *MCT_APP_EMAIL;
NSString *MCT_APP_HOMESCREEN_BACKGROUND_COLOR;
NSString *MCT_APP_HOMESCREEN_TEXT_COLOR;
UIColor *MCT_APP_TINT_COLOR;
NSString *MCT_APP_HOMESCREEN_COLOR_SCHEME;
BOOL MCT_FULL_WIDTH_HEADERS;
NSString *MCT_FACEBOOK_APP_ID;

int MCT_APP_TYPE;
int MCT_REGISTRATION_TYPE;

NSString *MCT_HOME_SCREEN_STYLE_TABS = @"tabs";
NSString *MCT_HOME_SCREEN_STYLE_2X3 = @"2x3";
NSString *MCT_HOME_SCREEN_STYLE_3X3 = @"3x3";
NSString *MCT_HOME_SCREEN_STYLE;

NSArray *MCT_SEARCH_SERVICES_IF_NONE_CONNECTED;
NSArray *MCT_PROFILE_DATA_FIELDS;
BOOL MCT_PROFILE_SHOW_GENDER_AND_BIRTHDATE;


@implementation JsonException
@end

@implementation SqlException
@end

@implementation SqlConstraintException
@end

@implementation MCTBizzException
@end

JsonException *JSON_EXCEPTION;
SqlException *SQL_EXCEPTION;
SqlConstraintException *SQL_CONSTRAINT_EXCEPTION;

void MCTInitializeConstants()
{
    T_UI();

    MCTNull = [NSNull null];

    MCTYES = [NSNumber numberWithBool:YES];

    MCTNO = [NSNumber numberWithBool:NO];

    MCTONE = [NSNumber numberWithInt:1];

    MCTEmptyArray = [NSArray array];

    MCTEmptyDict = [NSDictionary dictionary];

    MCTDictClass = [NSDictionary class];

    MCTMutableDictClass = [NSMutableDictionary class];

    MCTArrayClass = [NSArray class];

    MCTMutableArrayClass = [NSMutableArray class];

    MCTStringClass = [NSString class];

    MCTMutableStringClass = [NSMutableString class];

    MCTLongClass = [[NSNumber numberWithLongLong:0] class];

    MCTFloatClass = [[NSDecimalNumber numberWithFloat:0.01f] class];

    MCTBooleanClass = [MCTYES class];


    SQL_EXCEPTION = [[SqlException alloc] init];

    SQL_CONSTRAINT_EXCEPTION = [[SqlConstraintException alloc] init];

    JSON_EXCEPTION = [[JsonException alloc] init];

    NSBundle *mainBundle = [NSBundle mainBundle];

    NSString *path = [[mainBundle bundlePath] stringByAppendingPathComponent:@"RogerthatConfig.plist"];
    NSDictionary *configDict = [NSDictionary dictionaryWithContentsOfFile:path];
    MCT_HTTP_BASE_URL = [configDict objectForKey:@"HTTP_BASE_URL"];
    MCT_HTTPS_BASE_URL = [configDict objectForKey:@"HTTPS_BASE_URL"];
    MCT_HTTPS_BASE_URL_HOST = [[NSURL URLWithString:MCT_HTTPS_BASE_URL] host];

    MCT_LOG_FORWARDING_URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/unauthenticated/debug_log", MCT_HTTPS_BASE_URL]];

    MCT_USE_XMPP_KICK_CHANNEL = [[configDict objectForKey:@"USE_XMPP_KICK_CHANNEL"] boolValue];
    MCT_XMPP_KICK_COMPONENT = [configDict objectForKey:@"XMPP_KICK_COMPONENT"];
    MCT_DEBUG_LOGGING = MCT_DEBUG || [[configDict objectForKey:@"DEBUG_LOGGING"] boolValue];
    MCT_USE_SECURE_XMPP_CONNECTION = [[configDict objectForKey:@"XMPP_CONNECTION_IS_SECURE"] boolValue];
    MCT_USE_TRUSTSTORE = [[configDict objectForKey:@"USE_TRUSTSTORE"] boolValue];
    MCT_FRIENDS_ENABLED = [[configDict objectForKey:@"FRIENDS_ENABLED"] boolValue];
    MCT_SHOW_FRIENDS_IN_MORE = [[configDict objectForKey:@"SHOW_FRIENDS_IN_MORE"] boolValue];
    MCT_SHOW_PROFILE_IN_MORE = [[configDict objectForKey:@"SHOW_PROFILE_IN_MORE"] boolValue];
    MCT_SHOW_HOMESCREEN_FOOTER = [[configDict objectForKey:@"SHOW_HOMESCREEN_FOOTER"] boolValue];
    MCT_SCAN_URL_PREFIX = [MCT_HTTPS_BASE_URL stringByAppendingString:@"/"];
    MCT_APP_EMAIL = [configDict objectForKey:@"APP_EMAIL"];
    MCT_APP_HOMESCREEN_BACKGROUND_COLOR = [configDict objectForKey:@"APP_HOMESCREEN_BACKGROUND_COLOR"];
    MCT_APP_HOMESCREEN_TEXT_COLOR = [configDict objectForKey:@"APP_HOMESCREEN_TEXT_COLOR"];
    NSString *appTintColor = [configDict objectForKey:@"APP_TINT_COLOR"];
    MCT_APP_TINT_COLOR = [MCTUtils isEmptyOrWhitespaceString:appTintColor] ? nil : [UIColor colorWithString:appTintColor];
    MCT_APP_HOMESCREEN_COLOR_SCHEME = [configDict objectForKey:@"APP_HOMESCREEN_COLOR_SCHEME"];
    MCT_FULL_WIDTH_HEADERS = [[configDict objectForKey:@"FULL_WIDTH_HEADERS"] boolValue];
    MCT_APP_TYPE = [[configDict objectForKey:@"APP_TYPE"] intValue];
    MCT_REGISTRATION_TYPE = [[configDict objectForKey:@"REGISTRATION_TYPE"] intValue];

    NSString *friendsCaption = configDict[@"FRIENDS_CAPTION"];
    if ([@"contacts" isEqualToString:friendsCaption]) {
        MCT_FRIENDS_CAPTION = MCTFriendsCaptionContacts;
    } else if ([@"colleagues" isEqualToString:friendsCaption]) {
        MCT_FRIENDS_CAPTION = MCTFriendsCaptionColleagues;
    } else if ([@"friends" isEqualToString:friendsCaption]) {
        MCT_FRIENDS_CAPTION = MCTFriendsCaptionFriends;
    } else {
        if (IS_ENTERPRISE_APP) {
            MCT_FRIENDS_CAPTION = MCTFriendsCaptionColleagues;
        } else {
            MCT_FRIENDS_CAPTION = MCTFriendsCaptionFriends;
        }
    }

    NSString *homeScreenStyle = [configDict objectForKey:@"HOME_SCREEN_STYLE"];
    if ([MCT_HOME_SCREEN_STYLE_2X3 isEqualToString:homeScreenStyle]) {
        MCT_HOME_SCREEN_STYLE = MCT_HOME_SCREEN_STYLE_2X3;
    } else if ([MCT_HOME_SCREEN_STYLE_3X3 isEqualToString:homeScreenStyle]) {
        MCT_HOME_SCREEN_STYLE = MCT_HOME_SCREEN_STYLE_3X3;
    } else {
        MCT_HOME_SCREEN_STYLE = MCT_HOME_SCREEN_STYLE_TABS;
    }

    MCT_SEARCH_SERVICES_IF_NONE_CONNECTED = [configDict objectForKey:@"SEARCH_SERVICES_IF_NONE_CONNECTED"];
    if (MCT_SEARCH_SERVICES_IF_NONE_CONNECTED == nil) {
        MCT_SEARCH_SERVICES_IF_NONE_CONNECTED = [NSArray array];
    }
    MCT_PROFILE_DATA_FIELDS = [configDict objectForKey:@"PROFILE_DATA_FIELDS"];
    if (MCT_PROFILE_DATA_FIELDS == nil) {
        MCT_PROFILE_DATA_FIELDS = [NSArray array];
    }
    MCT_PROFILE_SHOW_GENDER_AND_BIRTHDATE = [configDict boolForKey:@"PROFILE_SHOW_GENDER_AND_BIRTHDATE"
                                                  withDefaultValue:YES];
    MCT_FACEBOOK_REGISTRATION = [configDict boolForKey:@"FACEBOOK_REGISTRATION"
                                      withDefaultValue:NO];
    MCT_REGISTRATION_MAIN_SIGNATURE = [configDict objectForKey:@"REGISTRATION_MAIN_SIGNATURE"];
    MCT_REGISTRATION_EMAIL_SIGNATURE = [configDict objectForKey:@"REGISTRATION_EMAIL_SIGNATURE"];
    MCT_REGISTRATION_PIN_SIGNATURE = [configDict objectForKey:@"REGISTRATION_PIN_SIGNATURE"];
    MCT_EMAIL_HASH_ENCRYPTION_KEY = [configDict objectForKey:@"EMAIL_HASH_ENCRYPTION_KEY"];
    MCT_MESSAGES_SHOW_REPLY_VS_UNREAD_COUNT = [configDict boolForKey:@"MESSAGES_SHOW_REPLY_VS_UNREAD_COUNT"
                                                    withDefaultValue:YES];
    MCT_ABOUT_WEBSITE = [configDict objectForKey:@"ABOUT_WEBSITE"];
    MCT_ABOUT_WEBSITE_URL = [configDict objectForKey:@"ABOUT_WEBSITE_URL"];
    MCT_ABOUT_EMAIL = [configDict objectForKey:@"ABOUT_EMAIL"];
    MCT_ABOUT_TWITTER = [configDict objectForKey:@"ABOUT_TWITTER"];
    MCT_ABOUT_TWITTER_APP_URL = [configDict objectForKey:@"ABOUT_TWITTER_APP_URL"];
    MCT_ABOUT_TWITTER_URL = [configDict objectForKey:@"ABOUT_TWITTER_URL"];
    MCT_ABOUT_FACEBOOK = [configDict objectForKey:@"ABOUT_FACEBOOK"];
    MCT_ABOUT_FACEBOOK_URL = [configDict objectForKey:@"ABOUT_FACEBOOK_URL"];

    // Product version
    // Note: format is giga.major.minor.i
    //       Do not change format without checking dependent code e.g. MCTSystemPlugin.m
    MCT_PRODUCT_VERSION = [NSString stringWithFormat:@"%@.i", [mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"]];

    MCT_PRODUCT_NAME = [mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    MCT_PRODUCT_ID = [mainBundle objectForInfoDictionaryKey:@"CFBundleName"];
    MCT_FACEBOOK_APP_ID = [mainBundle objectForInfoDictionaryKey:@"FacebookAppID"];
}