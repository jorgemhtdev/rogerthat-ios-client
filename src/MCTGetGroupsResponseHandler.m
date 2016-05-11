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

#import "MCTGetGroupsResponseHandler.h"
#import "MCTComponentFramework.h"
#import "MCTTransferObjects.h"

#import "NSData+Base64.h"

#define PICKLE_CLASS_VERSION 1

@implementation MCTGetGroupsResponseHandler

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for GetGroups request: %@", error);
}

- (void)handleResult:(MCT_com_mobicage_to_friends_GetGroupsResponseTO *)result
{
    T_BIZZ();
    LOG(@"Result received for GetGroups request");
    MCTFriendsPlugin *plugin = [MCTComponentFramework friendsPlugin];
    [plugin.store clearGroups];
    NSMutableSet *avatarHashes = [NSMutableSet set];
    for(MCT_com_mobicage_to_friends_GroupTO *g in result.groups) {
        [plugin.store insertGroupWithGuid:g.guid name:g.name avatar:nil avatarHash:g.avatar_hash];
        if (g.avatar_hash != nil) {
            [avatarHashes addObject:g.avatar_hash];
        }

        for (NSString *member in g.members) {
            [plugin.store insertGroupMemberWithGroupGuid:g.guid email:member];
        }
    }

    for (NSString *avatarHash in avatarHashes) {
        [plugin requestGroupAvatarWithHash:avatarHash];
    }

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_RECIPIENTS_GROUPS_UPDATED];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}


- (MCTGetGroupsResponseHandler *)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    return [super initWithCoder:coder];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end