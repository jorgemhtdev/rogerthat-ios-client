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

#import "NSData+Base64.h"

#import "MCTComponentFramework.h"
#import "MCTGetUserInfoResponseHandler.h"
#import "MCTTransferObjects.h"
#import "MCTUtils.h"

#define PICKLE_CLASS_VERSION 1
#define PICKLE_HASH_KEY @"hash"
#define PICKLE_STORE_AVATAR_KEY @"storeAvatar"


@implementation MCTGetUserInfoResponseHandler


+ (MCTGetUserInfoResponseHandler *)responseHandlerWithHash:(NSString *)hashOrEmail
                                            andStoreAvatar:(BOOL)storeAvatar
{
    MCTGetUserInfoResponseHandler *rh = [[MCTGetUserInfoResponseHandler alloc] init];
    rh.hashOrEmail = hashOrEmail;
    rh.storeAvatar = storeAvatar;
    return rh;
}

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for GetUserInfo request: %@", error);

    if (self.storeAvatar && [self.hashOrEmail containsString:@"@"]) {
        MCTFriendsPlugin *friendsPlugin = [MCTComponentFramework friendsPlugin];
        if ([friendsPlugin.store friendExistenceForEmail:self.hashOrEmail] == MCTFriendExistenceNotFound) {
            MCTFriend *friend = [MCTFriend aFriend];
            friend.existence = MCTFriendExistenceDeleted;
            friend.avatarId = -1;
            friend.email = self.hashOrEmail;
            friend.name = self.hashOrEmail;
            friend.type = MCTFriendTypeUser;
            [friendsPlugin.store storeFriend:friend
                                  withAvatar:nil
                                    andForce:YES];
        }
    }

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_USER_INFO_RETRIEVED];
    [intent setString:self.hashOrEmail forKey:@"hash"];
    [intent setBool:NO forKey:@"success"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (void)handleResult:(MCT_com_mobicage_to_friends_GetUserInfoResponseTO *)result
{
    T_BIZZ();
    LOG(@"Result received for GetUserInfo request");

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_USER_INFO_RETRIEVED];
    [intent setString:result.avatar forKey:@"avatar"];
    [intent setString:result.name forKey:@"name"];
    [intent setLong:result.type forKey:@"type"];
    [intent setString:result.app_id forKey:@"app_id"];
    if (![MCTUtils isEmptyOrWhitespaceString:result.email])
        [intent setString:result.email forKey:@"email"];
    if (![MCTUtils isEmptyOrWhitespaceString:result.descriptionX])
        [intent setString:result.descriptionX forKey:@"description"];
    if (![MCTUtils isEmptyOrWhitespaceString:result.descriptionBranding])
        [intent setString:result.descriptionBranding forKey:@"descriptionBranding"];
    if (![MCTUtils isEmptyOrWhitespaceString:result.qualifiedIdentifier])
        [intent setString:result.qualifiedIdentifier forKey:@"qualifiedIdentifier"];
    [intent setString:self.hashOrEmail forKey:@"hash"];
    if (result.error) {
        [intent setBool:NO forKey:@"success"];
        [intent setString:result.error.message forKey:@"errorMessage"];
        [intent setString:result.error.title forKey:@"errorTitle"];
        [intent setString:result.error.action forKey:@"errorAction"];
        [intent setString:result.error.caption forKey:@"errorCaption"];
    } else {
        [intent setBool:YES forKey:@"success"];

        if (self.storeAvatar && [self.hashOrEmail containsString:@"@"]) {
            MCTFriendsPlugin *friendsPlugin = [MCTComponentFramework friendsPlugin];
            if ([friendsPlugin.store friendExistenceForEmail:self.hashOrEmail] != MCTFriendExistenceActive) {
                MCTFriend *friend = [MCTFriend aFriend];
                friend.existence = MCTFriendExistenceDeleted;
                friend.avatarId = result.avatar_id;
                friend.email = self.hashOrEmail;
                friend.name = result.name;
                friend.type = result.type;
                friend.descriptionX = result.descriptionX;
                friend.descriptionBranding = result.descriptionBranding;
                friend.qualifiedIdentifier = result.qualifiedIdentifier;
                friend.profileData = result.profileData;
                [friendsPlugin.store storeFriend:friend
                                      withAvatar:[NSData dataFromBase64String:result.avatar]
                                        andForce:YES];
            } else {
                [friendsPlugin.store updateFriendInfo:result withEmail:self.hashOrEmail];
            }
        }

    }
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (id)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    if (self = [super initWithCoder:coder]) {
        self.hashOrEmail = [coder decodeObjectForKey:PICKLE_HASH_KEY];
        self.storeAvatar = [coder containsValueForKey:PICKLE_STORE_AVATAR_KEY] && [coder decodeBoolForKey:PICKLE_STORE_AVATAR_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
    [coder encodeObject:self.hashOrEmail forKey:PICKLE_HASH_KEY];
    [coder encodeBool:self.storeAvatar forKey:PICKLE_STORE_AVATAR_KEY];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end