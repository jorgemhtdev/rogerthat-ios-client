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
#import "MCTDatabaseUpdateMgr.h"
#import "MCTIntent.h"

@implementation MCTDatabaseUpdateMgr

+ (MCTDatabaseUpdateMgr *)manager
{
    return [[MCTDatabaseUpdateMgr alloc] init]; // Problem
}

- (void)update_18_to_19
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_DO_FRIENDS_LIST_RETRIEVAL];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_19_to_20
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_UPDATE_FRIEND_EMAIL_HASHES];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_20_to_21
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_IDENTITY_QRCODE_ADDED];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_22_to_23
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_DO_FRIENDS_LIST_RETRIEVAL];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_29_to_30
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_IDENTITY_QRCODE_ADDED];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_31_to_32
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_INVITATION_SECRETS_ADDED];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_32_to_33
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_DO_FRIENDS_LIST_RETRIEVAL];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_35_to_36
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_DO_FRIENDS_LIST_RETRIEVAL];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_37_to_38
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_DO_FRIENDS_LIST_RETRIEVAL];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];

    MCTIntent *intent2 = [MCTIntent intentWithAction:kINTENT_CHECK_IDENTITY_SHORT_URL];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent2];
}

- (void)update_41_to_42
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_DO_FRIENDS_LIST_RETRIEVAL];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_42_to_43
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_DO_FRIENDS_LIST_RETRIEVAL];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_44_to_45
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_GET_MY_IDENTITY];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_46_to_47
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_DO_FRIENDS_LIST_RETRIEVAL];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_48_to_49
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_DO_FRIENDS_LIST_RETRIEVAL];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_49_to_50
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_DO_FRIENDS_LIST_RETRIEVAL];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_50_to_51
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_GET_MY_IDENTITY];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_51_to_52
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_DO_FRIENDS_LIST_RETRIEVAL];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_57_to_58
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_DO_FRIENDS_LIST_RETRIEVAL];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];

    [[MCTComponentFramework configProvider] deleteStringForKey:@"FRIEND_UPDATES"];
    [[MCTComponentFramework configProvider] deleteStringForKey:@"FRIENDS_UPDATING"];
}

- (void)update_58_to_59
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_RECIPIENTS_GET_GROUPS];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_59_to_60
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_DO_BEACON_REGIONS_RETRIEVAL];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_64_to_65
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_UPDATE_FRIEND_EMAIL_HASHES];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_68_to_69
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_INIT_APNS_STATUS];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
    MCTIntent *intent2 = [MCTIntent intentWithAction:kINTENT_DO_SETTINGS_RETRIEVAL];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent2];
}

- (void)update_69_to_70
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_RESIZE_AVATARS];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (void)update_70_to_71
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_IDENTITY_QRCODE_ADDED];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

@end