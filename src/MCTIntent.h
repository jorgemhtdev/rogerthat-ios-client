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


#import "MCTPickler.h"


extern NSString * const kINTENT_FRIEND_ADDED;
extern NSString * const kINTENT_FRIEND_MODIFIED;
extern NSString * const kINTENT_FRIEND_REMOVED;
extern NSString * const kINTENT_FRIENDS_RETRIEVED;
extern NSString * const kINTENT_ADDRESSBOOK_SCANNED;
extern NSString * const kINTENT_ADDRESSBOOK_SCAN_FAILED;
extern NSString * const kINTENT_FB_FRIENDS_SCANNED;
extern NSString * const kINTENT_FB_FRIENDS_SCAN_FAILED;

extern NSString * const kINTENT_USER_INFO_RETRIEVED;
extern NSString * const kINTENT_USER_AVATAR_RETRIEVED;
extern NSString * const kINTENT_USER_QRCODE_RETRIEVED;
extern NSString * const kINTENT_SERVICE_ACTION_RETRIEVED;
extern NSString * const kINTENT_SERVICE_API_CALL_ANSWERED;
extern NSString * const kINTENT_SERVICE_DATA_UPDATED;

extern NSString * const kINTENT_SERVICE_BRANDING_RETRIEVED;
extern NSString * const kINTENT_GENERIC_BRANDING_RETRIEVED;

extern NSString * const kINTENT_JS_EMBEDDING_RETRIEVED;

extern NSString * const kINTENT_IDENTITY_MODIFIED;
extern NSString * const kINTENT_IDENTITY_QR_RETREIVED;

extern NSString * const kINTENT_SETTINGS_UPDATED;

extern NSString * const kINTENT_KICK_BACKLOG;
extern NSString * const kINTENT_BACKLOG_STARTED;
extern NSString * const kINTENT_BACKLOG_FINISHED;

extern NSString * const kINTENT_MESSAGE_RECEIVED_HIGH_PRIO;
extern NSString * const kINTENT_MESSAGE_RECEIVED;
extern NSString * const kINTENT_MESSAGE_SENT;
extern NSString * const kINTENT_MESSAGE_MODIFIED;
extern NSString * const kINTENT_MESSAGE_REPLACED;
extern NSString * const kINTENT_MESSAGE_JSMFR_ERROR;
extern NSString * const kINTENT_MESSAGE_JSMFR_ENDED;
extern NSString * const kINTENT_MESSAGE_JS_VALIDATION_RESULT;
extern NSString * const kINTENT_THREAD_ACKED;
extern NSString * const kINTENT_THREAD_DELETED;
extern NSString * const kINTENT_THREAD_RESTORED;
extern NSString * const kINTENT_THREAD_MODIFIED;
extern NSString * const kINTENT_THREAD_AVATAR_RETREIVED;

extern NSString * const kINTENT_ATTACHMENT_CLICKED;
extern NSString * const kINTENT_ATTACHMENT_RETRIEVED;

extern NSString * const kINTENT_UPLOADING_CHUNKS_STARTED;
extern NSString * const kINTENT_UPLOADING_CHUNKS_FINISHED;
extern NSString * const kINTENT_CHUNK_UPLOADED;
extern NSString * const kINTENT_UPLOAD_NOT_STARTED;

extern NSString * const kINTENT_ACTIVITY_NEW;
extern NSString * const kINTENT_ACTIVITY_READ_ALL;
extern NSString * const kINTENT_ACTIVITY_DELETED;

extern NSString * const kINTENT_LOCATION_RETRIEVED;
extern NSString * const kINTENT_LOCATION_RETRIEVING_FAILED;
extern NSString * const kINTENT_LOCATION_START_AUTOMATIC_DETECTION;
extern NSString * const kINTENT_BEACON_IN_REACH;
extern NSString * const kINTENT_BEACON_OUT_OF_REACH;
extern NSString * const kINTENT_BEACON_REGIONS_UPDATED;

extern NSString * const kINTENT_PUSH_NOTIFICATION;
extern NSString * const kINTENT_APPLICATION_OPEN_URL;
extern NSString * const kINTENT_PUSH_NOTIFICATION_SETTINGS_UPDATED;

extern NSString * const kINTENT_MOBILE_UNREGISTERED;

extern NSString * const kINTENT_CHANGE_TAB;
extern NSString * const kINTENT_REGISTRATION_COMPLETED;
extern NSString * const kINTENT_NEW_ALARM_SOUND;
extern NSString * const kINTENT_FORWARDING_LOGS;

// Database updates
extern NSString * const kINTENT_DO_SETTINGS_RETRIEVAL;
extern NSString * const kINTENT_DO_FRIENDS_LIST_RETRIEVAL;
extern NSString * const kINTENT_RESIZE_AVATARS;
extern NSString * const kINTENT_UPDATE_FRIEND_EMAIL_HASHES;
extern NSString * const kINTENT_IDENTITY_QRCODE_ADDED;
extern NSString * const kINTENT_GET_MY_IDENTITY;
extern NSString * const kINTENT_INVITATION_SECRETS_ADDED;
extern NSString * const kINTENT_CHECK_IDENTITY_SHORT_URL;
extern NSString * const kINTENT_RECIPIENTS_GET_GROUPS;
extern NSString * const kINTENT_DO_BEACON_REGIONS_RETRIEVAL;
extern NSString * const kINTENT_INIT_APNS_STATUS;

extern NSString * const kINTENT_SEARCH_FRIEND_RESULT;
extern NSString * const kINTENT_SEARCH_FRIEND_FAILURE;
extern NSString * const kINTENT_SEARCH_SERVICE_RESULT;
extern NSString * const kINTENT_SEARCH_SERVICE_FAILURE;

extern NSString * const kINTENT_CONTACTS_LOADED_FOR_SHARE_SERVICE;
extern NSString * const kINTENT_CONTACTS_LOADED_FOR_ADD_VIA_EMAIL;
extern NSString * const kINTENT_CONTACTS_LOADED_FOR_ADD_VIA_CONTACTS;

extern NSString * const kINTENT_MESSAGE_DETAIL_SCROLL_DOWN;

extern NSString * const kINTENT_FB_LOGIN;
extern NSString * const kINTENT_FB_POST;
extern NSString * const kINTENT_FB_TICKER;

extern NSString * const kINTENT_RECIPIENTS_GROUPS_UPDATED;
extern NSString * const kINTENT_RECIPIENTS_GROUP_ADDED;
extern NSString * const kINTENT_RECIPIENTS_GROUP_MODIFIED;
extern NSString * const kINTENT_RECIPIENTS_GROUP_REMOVED;

extern NSString * const kINTENT_OAUTH_RESULT;

extern NSString * const kINTENT_MDP_LOGIN;

extern NSString * const kINTENT_CACHED_FILE_RETRIEVED;


@interface MCTIntent : NSObject <MCTPickleable>

@property(nonatomic, copy) NSString *action;
@property(nonatomic, assign) MCTlong creationTimestamp;
@property(nonatomic, assign) BOOL forceStash;

+ (MCTIntent *)intentWithAction:(NSString *)action;

- (id)initWithAction:(NSString *)action;

- (void)setString:(NSString *)value forKey:(NSString *)key;

- (void)setLong:(MCTlong)value forKey:(NSString *)key;

- (void)setBool:(BOOL)value forKey:(NSString *)key;

- (BOOL)hasStringKey:(NSString *)key;

- (BOOL)hasLongKey:(NSString *)key;

- (BOOL)hasBoolKey:(NSString *)key;

- (NSString *)stringForKey:(NSString *)key;

- (MCTlong)longForKey:(NSString *)key;

- (BOOL)boolForKey:(NSString *)key;

@end