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


typedef enum {
    // General: 1-99
    MCTActivityLogDebug = 1,
    MCTActivityLogInfo = 2,
    MCTActivityLogWarning = 3,
    MCTActivityLogError = 4,
    MCTActivityLogFatal = 5,

    // Messages: 100-199
    MCTActivityMessageReceived = 100,
    MCTActivityMessageSent = 101,
    MCTActivityQuickReplyReceivedForMe = 102,
    MCTActivityQuickReplyReceivedForOther = 103,
    MCTActivityQuickReplySentForMe = 104,
    MCTActivityQuickReplySentForOther = 105,
    MCTActivityMessageLockedByMe = 106,
    MCTActivityMessageLockedByOther = 107,
    MCTActivityMessageReplyReceived = 108,
    MCTActivityMessageReplySent = 109,
    MCTActivityMessageDismissedByMe = 111,
    MCTActivityMessageDismissedByOther = 112,
    MCTActivityQuickReplyUndone = 113,

    // Friends: 200-299
    MCTActivityFriendAdded = 200,
    MCTActivityFriendRemoved = 201,
    MCTActivityFriendUpdated = 202,
    MCTActivityFriendBecameFriend = 203,
    MCTActivityServicePoked = 204,

    // Location: 300-399
    MCTActivityLocationSent = 301,
} MCTActivityType;


#define MCT_ACTIVITY_POKE_ACTION @"pokeAction"
#define MCT_ACTIVITY_FRIEND_NAME @"friendname"
#define MCT_ACTIVITY_FRIEND_TYPE @"friend_type"
#define MCT_ACTIVITY_RELATION_AVATARID @"relation_avatarid"
#define MCT_ACTIVITY_RELATION_EMAIL @"relation_email"
#define MCT_ACTIVITY_RELATION_NAME @"relation_name"
#define MCT_ACTIVITY_RELATION_TYPE @"relation_type"

#define MCT_ACTIVITY_MESSAGE_CONTENT @"message"
#define MCT_ACTIVITY_MESSAGE_PARENT_CONTENT @"parentmessage"
#define MCT_ACTIVITY_MESSAGE_FROM @"from"
#define MCT_ACTIVITY_MESSAGE_TO @"to"
#define MCT_ACTIVITY_MESSAGE_QRBUTTON @"qrbutton"

#define MCT_ACTIVITY_LOG_MAX_LOGLEVEL MCTActivityLogFatal
#define MCT_ACTIVITY_LOG_LINE @"log"

#define MCT_ACTIVITY_LOCATION_ACCURACY @"accuracy"
#define MCT_ACTIVITY_LOCATION_LATITUDE @"latitude"
#define MCT_ACTIVITY_LOCATION_LONGITUDE @"longitude"