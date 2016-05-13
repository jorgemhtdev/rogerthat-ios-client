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

#import "MCTIntent.h"
#import "MCTJSONUtils.h"
#import "MCTUtils.h"

// Warning: NEVER use these strings directly; they only serve
// for printing and debugging purposes !
NSString * const kINTENT_FRIEND_ADDED               = @"friend added";
NSString * const kINTENT_FRIEND_MODIFIED            = @"friend modified";
NSString * const kINTENT_FRIEND_REMOVED             = @"friend removed";
NSString * const kINTENT_FRIENDS_RETRIEVED          = @"friends retrieved";
NSString * const kINTENT_ADDRESSBOOK_SCANNED        = @"address book scanned";
NSString * const kINTENT_ADDRESSBOOK_SCAN_FAILED    = @"address book scan failed";
NSString * const kINTENT_FB_FRIENDS_SCANNED         = @"facebook friends scanned";
NSString * const kINTENT_FB_FRIENDS_SCAN_FAILED     = @"facebook friends scan failed";

NSString * const kINTENT_USER_INFO_RETRIEVED        = @"user info retrieved";
NSString * const kINTENT_USER_AVATAR_RETRIEVED      = @"user avatar retrieved";
NSString * const kINTENT_USER_QRCODE_RETRIEVED      = @"user qrcode retreived";
NSString * const kINTENT_SERVICE_ACTION_RETRIEVED   = @"service action retrieved";
NSString * const kINTENT_SERVICE_API_CALL_ANSWERED  = @"service api call answered";
NSString * const kINTENT_SERVICE_DATA_UPDATED       = @"service data updated";

NSString * const kINTENT_SERVICE_BRANDING_RETRIEVED = @"service branding retrieved";
NSString * const kINTENT_GENERIC_BRANDING_RETRIEVED = @"generic branding retrieved";

NSString * const kINTENT_JS_EMBEDDING_RETRIEVED     = @"js embedding retrieved";

NSString * const kINTENT_IDENTITY_MODIFIED          = @"identity modified";
NSString * const kINTENT_IDENTITY_QR_RETREIVED      = @"identity qr retreived";

NSString * const kINTENT_SETTINGS_UPDATED           = @"settings updated";

NSString * const kINTENT_KICK_BACKLOG               = @"kick backlog";
NSString * const kINTENT_BACKLOG_STARTED            = @"backlog started";
NSString * const kINTENT_BACKLOG_FINISHED           = @"backlog finished";

NSString * const kINTENT_MESSAGE_RECEIVED_HIGH_PRIO = @"message received high prio";
NSString * const kINTENT_MESSAGE_RECEIVED           = @"message received";
NSString * const kINTENT_MESSAGE_SENT               = @"message sent";
NSString * const kINTENT_MESSAGE_MODIFIED           = @"message modified";
NSString * const kINTENT_MESSAGE_REPLACED           = @"message replaced";
NSString * const kINTENT_MESSAGE_JSMFR_ERROR        = @"message jsmfr error";
NSString * const kINTENT_MESSAGE_JSMFR_ENDED        = @"message jsmfr ended";
NSString * const kINTENT_MESSAGE_JS_VALIDATION_RESULT = @"message js validation result";
NSString * const kINTENT_THREAD_ACKED               = @"thread acked";
NSString * const kINTENT_THREAD_DELETED             = @"thread deleted";
NSString * const kINTENT_THREAD_RESTORED            = @"thread restored";
NSString * const kINTENT_THREAD_MODIFIED            = @"thread modified";
NSString * const kINTENT_THREAD_AVATAR_RETREIVED    = @"thread avatar retrieved";

NSString * const kINTENT_ATTACHMENT_CLICKED         = @"attachment clicked";
NSString * const kINTENT_ATTACHMENT_RETRIEVED       = @"attachment retrieved";

NSString * const kINTENT_UPLOADING_CHUNKS_STARTED   = @"uploading chunks started";
NSString * const kINTENT_UPLOADING_CHUNKS_FINISHED  = @"uploading chunks finished";
NSString * const kINTENT_CHUNK_UPLOADED             = @"chunk uploaded";
NSString * const kINTENT_UPLOAD_NOT_STARTED         = @"upload not started";

NSString * const kINTENT_ACTIVITY_NEW               = @"new activity";
NSString * const kINTENT_ACTIVITY_READ_ALL          = @"activities read";
NSString * const kINTENT_ACTIVITY_DELETED           = @"deleted activity";

NSString * const kINTENT_LOCATION_RETRIEVED         = @"location retrieved";
NSString * const kINTENT_LOCATION_RETRIEVING_FAILED = @"location retrieving failed";
NSString * const kINTENT_LOCATION_START_AUTOMATIC_DETECTION  = @"location start automatic detection";
NSString * const kINTENT_BEACON_IN_REACH            = @"beacon in reach";
NSString * const kINTENT_BEACON_OUT_OF_REACH        = @"beacon out of reach";
NSString * const kINTENT_BEACON_REGIONS_UPDATED     = @"beacon regions updated";

NSString * const kINTENT_PUSH_NOTIFICATION          = @"push notification";
NSString * const kINTENT_APPLICATION_OPEN_URL       = @"application open url";
NSString * const kINTENT_PUSH_NOTIFICATION_SETTINGS_UPDATED = @"push notification settings updated";

NSString * const kINTENT_MOBILE_UNREGISTERED        = @"mobile unregistered";

NSString * const kINTENT_CHANGE_TAB                 = @"change tab";
NSString * const kINTENT_REGISTRATION_COMPLETED     = @"registration completed";
NSString * const kINTENT_NEW_ALARM_SOUND            = @"new alarm sound";
NSString * const kINTENT_FORWARDING_LOGS            = @"forwarding logs";

NSString * const kINTENT_DO_SETTINGS_RETRIEVAL      = @"do settings retrieval";
NSString * const kINTENT_DO_FRIENDS_LIST_RETRIEVAL  = @"do friend list retrieval";
NSString * const kINTENT_RESIZE_AVATARS             = @"resize avatars";
NSString * const kINTENT_UPDATE_FRIEND_EMAIL_HASHES = @"update friend email hashes";
NSString * const kINTENT_IDENTITY_QRCODE_ADDED      = @"identity qr code added";
NSString * const kINTENT_GET_MY_IDENTITY            = @"get my identity";
NSString * const kINTENT_INVITATION_SECRETS_ADDED   = @"invitation secrets added";
NSString * const kINTENT_CHECK_IDENTITY_SHORT_URL   = @"check slash in myIdentity short url";
NSString * const kINTENT_RECIPIENTS_GET_GROUPS      = @"recipients get groups";
NSString * const kINTENT_DO_BEACON_REGIONS_RETRIEVAL = @"do beacon regions retrieval";
NSString * const kINTENT_INIT_APNS_STATUS           = @"init apns status";

NSString * const kINTENT_SEARCH_FRIEND_RESULT       = @"search friend result";
NSString * const kINTENT_SEARCH_FRIEND_FAILURE      = @"search friend failure";
NSString * const kINTENT_SEARCH_SERVICE_RESULT      = @"search service result";
NSString * const kINTENT_SEARCH_SERVICE_FAILURE     = @"search service failure";

NSString * const kINTENT_CONTACTS_LOADED_FOR_ADD_VIA_CONTACTS = @"MCTAddViaContactsResultVC: contacts loaded";
NSString * const kINTENT_CONTACTS_LOADED_FOR_ADD_VIA_EMAIL    = @"MCTAddViaEmailVC: contacts loaded";
NSString * const kINTENT_CONTACTS_LOADED_FOR_SHARE_SERVICE    = @"MCTShareServiceVC: contacts loaded";

NSString * const kINTENT_MESSAGE_DETAIL_SCROLL_DOWN = @"message detail scroll down";

NSString * const kINTENT_FB_LOGIN                   = @"fb login";
NSString * const kINTENT_FB_POST                    = @"fb post";
NSString * const kINTENT_FB_TICKER                  = @"fb ticker";

NSString * const kINTENT_RECIPIENTS_GROUPS_UPDATED  = @"recipients groups updated";
NSString * const kINTENT_RECIPIENTS_GROUP_ADDED     = @"recipients group added";
NSString * const kINTENT_RECIPIENTS_GROUP_MODIFIED  = @"recipients group modified";
NSString * const kINTENT_RECIPIENTS_GROUP_REMOVED   = @"recipients group removed";

NSString * const kINTENT_OAUTH_RESULT               = @"oauth result";

NSString * const kINTENT_MDP_LOGIN                  = @"mdp login";

NSString * const kINTENT_CACHED_FILE_RETRIEVED = @"cached file retrieved";


#define PICKLE_CLASS_VERSION 1
#define PICKLE_KEY_LONG_DICT @"longDict"
#define PICKLE_KEY_BOOL_DICT @"boolDict"
#define PICKLE_KEY_STRING_DICT @"stringDict"
#define PICKLE_KEY_ACTION @"action"
#define PICKLE_KEY_CREATION_TIMESTAMP @"creationTimestamp"
#define PICKLE_KEY_FORCE_STASH @"forceStash"

@interface MCTIntent()

@property(nonatomic, strong) NSMutableDictionary *longDict;
@property(nonatomic, strong) NSMutableDictionary *boolDict;
@property(nonatomic, strong) NSMutableDictionary *stringDict;

@end


@implementation MCTIntent


- (MCTIntent *)init
{
    if (self = [super init]) {
        self.stringDict = [NSMutableDictionary dictionary];
        self.longDict = [NSMutableDictionary dictionary];
        self.boolDict = [NSMutableDictionary dictionary];
        self.creationTimestamp = [MCTUtils currentTimeMillis];
        self.forceStash = NO;
    }
    return self;
}

+ (MCTIntent *)intentWithAction:(NSString *)action
{
    MCTIntent *intent = [[MCTIntent alloc] initWithAction:action];
    return intent;
}

- (MCTIntent *)initWithAction:(NSString *)action
{
    if (self = [self init]) {
        self.action = action;
    }
    return self;
}

- (void)setString:(NSString *)value forKey:(NSString *)key
{
    [self.stringDict setString:value forKey:key];
}

- (void)setLong:(MCTlong)value forKey:(NSString *)key
{
    [self.longDict setLong:value forKey:key];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key
{
    [self.boolDict setBool:value forKey:key];
}

- (BOOL)hasStringKey:(NSString *)key
{
    return [self.stringDict containsKey:key];
}

- (BOOL)hasLongKey:(NSString *)key
{
    return [self.longDict containsLongObjectForKey:key];
}

- (BOOL)hasBoolKey:(NSString *)key
{
    return [self.boolDict containsBoolObjectForKey:key];
}

- (NSString *)stringForKey:(NSString *)key
{
    return [self.stringDict stringForKey:key];
}

- (MCTlong)longForKey:(NSString *)key
{
    return [self.longDict longForKey:key];
}

- (BOOL)boolForKey:(NSString *)key
{
    return [self.boolDict boolForKey:key];
}

- (NSString *)description
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.longDict];
    [dict addEntriesFromDictionary:self.stringDict];
    [dict addEntriesFromDictionary:self.boolDict];
    return [NSString stringWithFormat:@"%@ - %@", self.action, dict];
}

# pragma mark - MCTPickable

- (MCTIntent *)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_DONTCARE();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }
    if (self = [super init]) {
        self.stringDict = [coder decodeObjectForKey:PICKLE_KEY_STRING_DICT];
        self.longDict = [coder decodeObjectForKey:PICKLE_KEY_LONG_DICT];
        self.boolDict = [coder decodeObjectForKey:PICKLE_KEY_BOOL_DICT];
        self.creationTimestamp = [coder decodeInt64ForKey:PICKLE_KEY_CREATION_TIMESTAMP];
        self.forceStash = [coder decodeBoolForKey:PICKLE_KEY_FORCE_STASH];
        self.action = [coder decodeObjectForKey:PICKLE_KEY_ACTION];
    }
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    [coder encodeObject:self.stringDict forKey:PICKLE_KEY_STRING_DICT];
    [coder encodeObject:self.longDict forKey:PICKLE_KEY_LONG_DICT];
    [coder encodeObject:self.boolDict forKey:PICKLE_KEY_BOOL_DICT];
    [coder encodeInt64:self.creationTimestamp forKey:PICKLE_KEY_CREATION_TIMESTAMP];
    [coder encodeBool:self.forceStash forKey:PICKLE_KEY_FORCE_STASH];
    [coder encodeObject:self.action forKey:PICKLE_KEY_ACTION];
}

- (int)classVersion
{
    T_DONTCARE();
    return PICKLE_CLASS_VERSION;
}

@end