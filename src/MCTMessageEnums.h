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

#define MCT_FORM_POSITIVE @"positive"
#define MCT_FORM_NEGATIVE @"negative"

#define MCT_WIDGET_TEXT_LINE        @"text_line"
#define MCT_WIDGET_TEXT_BLOCK       @"text_block"
#define MCT_WIDGET_AUTO_COMPLETE    @"auto_complete"
#define MCT_WIDGET_SINGLE_SELECT    @"single_select"
#define MCT_WIDGET_MULTI_SELECT     @"multi_select"
#define MCT_WIDGET_DATE_SELECT      @"date_select"
#define MCT_WIDGET_SINGLE_SLIDER    @"single_slider"
#define MCT_WIDGET_RANGE_SLIDER     @"range_slider"
#define MCT_WIDGET_PHOTO_UPLOAD     @"photo_upload"
#define MCT_WIDGET_GPS_LOCATION     @"gps_location"
#define MCT_WIDGET_MYDIGIPASS       @"mydigipass"
#define MCT_WIDGET_ADVANCED_ORDER   @"advanced_order"

#define MCT_DATE_SELECT_MODE_TIME       @"time"
#define MCT_DATE_SELECT_MODE_DATE       @"date"
#define MCT_DATE_SELECT_MODE_DATE_TIME  @"date_time"

#define MCT_UNIT_VALUE @"<value/>"
#define MCT_UNIT_LOW_VALUE @"<low_value/>"
#define MCT_UNIT_HIGH_VALUE @"<high_value/>"

typedef enum {
    MCTMessageStatusNew = 0,
    MCTMessageStatusReceived = 1,
    MCTMessageStatusAcked = 2,
    MCTMessageStatusRead = 4,
    MCTMessageStatusDeleted = 8,
} MCTMessageStatus;

typedef enum {
    MCTMessageFlagAllowDismiss = 1,
    MCTMessageFlagAllowCustomReply = 2,
    MCTMessageFlagAllowReply = 4,
    MCTMessageFlagAllowReplyAll = 8,
    MCTMessageFlagSharedMembers = 16,
    MCTMessageFlagLocked = 32,
    MCTMessageFlagAutoLock = 64,
    MCTMessageFlagSentByMFR = 128,
    MCTMessageFlagSentByJSMFR = 256,
    MCTMessageFlagDynamicChat = 512,
    MCTMessageFlagNotRemovable = 1024,
    MCTMessageFlagAllowChatButtons = 2048,
    MCTMessageFlagChatSticky = 4096,
    MCTMessageFlagAllowChatPicture = 8192,
    MCTMessageFlagAllowChatVideo = 16384,
    MCTMessageFlagAllowChatPriority = 32768,
    MCTMessageFlagAllowChatSticky = 65536,
} MCTMessageFlag;

typedef enum {
    MCTDirtyBehaviorNormal = 1,
    MCTDirtyBehaviorMakeDirty = 2,
    MCTDirtyBehaviorClearDirty = 3,
} MCTDirtyBehavior;

typedef enum {
    MCTAlertFlagSilent = 1,
    MCTAlertFlagVibrate = 2,
    MCTAlertFlagRing5 = 4,
    MCTAlertFlagRing15 = 8,
    MCTAlertFlagRing30 = 16,
    MCTAlertFlagRing60 = 32,
    MCTAlertFlagInterval5 = 64,
    MCTAlertFlagInterval15 = 128,
    MCTAlertFlagInterval30 = 256,
    MCTAlertFlagInterval60 = 512,
    MCTAlertFlagInterval300 = 1024,
    MCTAlertFlagInterval900 = 2048,
    MCTAlertFlagInterval3600 = 4096,
} MCTAlertFlag;

typedef enum {
    MCTButtonUIFlagExpectNextWait10 = 1,
} MCTButtonUIFlag;

typedef enum {
    MCTMessageExistenceDeleted = 0,
    MCTMessageExistenceActive = 1,
    MCTMessageExistenceNotFound = NSNotFound,
} MCTMessageExistence;