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

#import "MCTFriend.h"
#import "MCTFriendCategory.h"
#import "MCTServiceApiCallbackResult.h"
#import "MCTStore.h"
#import "MCTTransferObjects.h"
#import "MCTFriendBroadcastInfo.h"
#import "MCTGroup.h"

@interface MCTFriendStore : MCTStore <NSCacheDelegate>

- (BOOL)addInvitedService:(MCTFriend *)service;
- (BOOL)storeFriend:(MCT_com_mobicage_to_friends_FriendTO *)friend_
         withAvatar:(NSData *)avatar
           andForce:(BOOL)force;

- (void)deleteFriendWithEmail:(NSString *)email;

- (MCT_com_mobicage_to_friends_UpdateFriendResponseTO *)shouldUpdateFriend:(MCT_com_mobicage_to_friends_FriendTO *)friend_;
- (MCT_com_mobicage_to_friends_UpdateFriendResponseTO *)updateFriend:(MCT_com_mobicage_to_friends_FriendTO *)friend_;
- (void)updateFriendInfo:(MCT_com_mobicage_to_friends_GetUserInfoResponseTO *)result
               withEmail:(NSString *)email;

- (MCTlong)friendSetVersion;
- (BOOL)updateFriendSetVersion:(MCTlong)version;
- (void)deleteFriendFromFriendSetWithEmail:(NSString *)email;
- (void)insertFriendIntoFriendSetWithEmail:(NSString *)email;
- (NSArray *)friendSet;
- (BOOL)friendSetContainsFriend:(NSString *)email;
- (NSArray *)friendVersionsForEmail:(NSString *)email;


- (void)setFriendExistenceStatus:(int)status forEmail:(NSString *)email;
- (void)scrub;
- (BOOL)updateShareMyLocation:(BOOL)enabled withFriendEmail:(NSString *)email;
- (void)saveAvatarWithData:(NSData *)data andFriendEmail:(NSString *)email;
- (void)downloadAvatar:(MCT_com_mobicage_to_friends_FriendTO *)friend_;
- (void)updateEmailHashesForAllFriends;
- (void)resizeAvatarsForAllFriends;
- (NSArray *)friendEmails;
- (MCTFriendExistence)friendExistenceForEmail:(NSString *)email;
- (BOOL)friendExistsWithEmail:(NSString *)email;

- (void)saveInvitationSecrets:(NSArray *)secrets;
- (NSString *)popInvitationSecret;
- (int)countInvitationSecrets;
- (NSArray *)pendingInvitations;
- (void)addPendingInvitation:(NSString *)invitee;
- (void)removePendingInvitation:(NSString *)invitee;

- (void)saveMenuIcon:(NSData *)icon withHash:(NSString *)iconHash;
- (void)addMenuDetailsToService:(MCTFriend *)service;

- (void)saveCategory:(MCT_com_mobicage_to_friends_FriendCategoryTO *)category;
- (BOOL)categoryExistsWithId:(NSString *)categoryId;

- (void)saveStaticFlow:(NSString *)staticFlow withHash:(NSString *)staticFlowHash;
- (NSString *)staticFlowWithHash:(NSString *)staticFlowHash;

- (NSArray *)friendDataWithEmail:(NSString *)email;
- (void)updateUserData:(NSString *)userDataJSONString withService:(NSString*)email;
- (void)updateUserData:(NSString *)userDataJSONString
               appData:(NSString *)appDataJSONString
            forService:(NSString *)email
            withIntent:(BOOL)mustBroadcastIntent;

- (MCTlong)insertServiceApiCallWithService:(NSString *)service
                                      item:(NSString *)item
                                    method:(NSString *)method
                                       tag:(NSString *)tag
                                    status:(MCTServiceApiCallStatus)status;
- (MCTServiceApiCallbackResult *)updateServiceApiCallWithId:(MCTlong)idX
                                                      error:(NSString *)error
                                                     result:(NSString *)result
                                                     status:(MCTServiceApiCallStatus)status;
- (NSArray *)serviceApiCallbackResulstWithService:(NSString *)service item:(NSString *)item;
- (void)removeServiceApiCallWithId:(MCTlong)idX;

- (int)countFriends;
- (int)countFriendsByType:(MCTFriendType)type;
- (int)countFriendsByCategory:(NSString *)category;
- (NSDictionary *)countServicesGroupedByOrganizationType;
- (int)countServicesByOrganizationType:(MCTServiceOrganizationType)organizationType;
- (NSArray *)getServicesByOrganizationType:(MCTServiceOrganizationType)organizationType;
- (int)countFriendsSharingLocation;
- (MCTFriend *)friendByIndex:(NSInteger)index;
- (MCTFriend *)friendByType:(MCTFriendType)type andIndex:(NSInteger)index;
- (MCTFriend *)friendByCategory:(NSString *)category andIndex:(NSInteger)index;
- (MCTFriend *)serviceByOrganizationType:(MCTServiceOrganizationType)organizationType andIndex:(NSInteger)index;
- (MCTFriend *)friendByEmail:(NSString *)email;
- (MCTFriend *)friendByEmailHash:(NSString *)emailHash;
- (NSString *)friendNameByEmail:(NSString *)email;
- (NSArray *)friendNames;
- (MCTFriendType)friendTypeByEmail:(NSString *)email;
- (NSData *)friendAvatarByEmail:(NSString *)email;

- (MCTFriendBroadcastInfo *)broadcastInfoWithFriend:(NSString *)email;

- (MCTGroup *)getGroupWithGuid:(NSString *)guid;
- (void)clearGroups;
- (void)clearEmptyGroups;
- (void)clearGroupMemberByEmail:(NSString *)email;
- (NSDictionary *)getGroups;
- (void)insertGroupAvatar:(NSData *)avatar hash:(NSString *)avatarHash;
- (void)insertGroupAvatarHash:(NSString *)avatarHash guid:(NSString *)guid;
- (void)insertGroupWithGuid:(NSString *)guid name:(NSString *)name avatar:(NSData *)avatar avatarHash:(NSString *)avatarHash;
- (void)updateGroupWithGuid:(NSString *)guid name:(NSString *)name avatar:(NSData *)avatar avatarHash:(NSString *)avatarHash;
- (void)deleteGroupWithGuid:(NSString *)guid;
- (void)insertGroupMemberWithGroupGuid:(NSString *)guid email:(NSString *)email;
- (void)deleteGroupMemberWithGroupGuid:(NSString *)guid email:(NSString *)email;

@end