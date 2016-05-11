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

#import <CoreLocation/CoreLocation.h>

#import "MCTBrandingMgr.h"
#import "MCTCallReceiver.h"
#import "MCTContactEntry.h"
#import "MCTFriendStore.h"
#import "MCTPlugin.h"
#import "MCTTransferObjects.h"
#import "MCTIntentFramework.h"
#import "MCTContactEntry.h"

#define MCT_SYSTEM_FRIEND_NAME (IS_ROGERTHAT_APP ? NSLocalizedString(@"Rogerthat dashboard", nil) : MCT_PRODUCT_NAME)

@interface MCTFriendsPlugin : MCTPlugin <MCT_com_mobicage_capi_friends_IClientRPC, MCT_com_mobicage_capi_services_IClientRPC, IMCTIntentReceiver>

@property (nonatomic, strong) MCTFriendStore *store;


#pragma mark - Friends

- (void)requestFriendSetWithForce:(BOOL)force recalculateMessagesShowInList:(BOOL)recalcutate;
- (void)shareMyLocationWithRequest:(MCT_com_mobicage_to_friends_ShareLocationRequestTO *)request;
- (void)requestLocationSharingWithFriend:(NSString *)email andMessage:(NSString *)message;
- (void)inviteFriendWithEmail:(NSString *)email andMessage:(NSString *)message;
- (void)inviteFriendWithEmail:(NSString *)email andName:(NSString *)name andMessage:(NSString *)message;
- (void)inviteServiceWithEmail:(NSString *)email
                       andName:(NSString *)name
                andDescription:(NSString *)description
        andDescriptionBranding:(NSString *)branding
                 andAvatarData:(NSData *)avatarData;
- (void)markFriendDeletePendingWithEmail:(NSString *)email;
- (void)requestAvatarWithId:(MCTlong)avatarId andEmail:(NSString *)email;
- (void)requestUserInfoWithEmailHash:(NSString *)emailHash;
- (void)requestUserInfoWithEmailHash:(NSString *)emailHash
                      andStoreAvatar:(BOOL)storeAvatar
                       allowCrossApp:(BOOL)allowCrossApp;
- (void)requestUserQRWithEmail:(NSString *)email;
- (void)        requestFriend:(NSString *)email
                    withForce:(BOOL)force
                       isLast:(BOOL)isLast
recalculateMessagesShowInList:(BOOL)recalculateMessagesShowInList;

- (MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO *)updateFriendSet:(NSArray *)emails
                                                               withVersion:(MCTlong)version
                                                                     force:(BOOL)force
                                             recalculateMessagesShowInList:(BOOL)recalculateMessagesShowInList;


#pragma mark - Services

- (void)serviceActionInfoWithEmailHash:(NSString *)emailHash andAction:(NSString *)action;
- (void)pokeService:(NSString *)email withAction:(NSString *)action context:(NSString *)context;
- (void)pokeService:(NSString *)email withHashedTag:(NSString *)hashedTag context:(NSString *)context;
- (void)requestServiceMenuIcon:(MCT_com_mobicage_to_friends_ServiceMenuItemTO *)item withService:(NSString *)email;
- (void)requestStaticFlowWithItem:(MCT_com_mobicage_to_friends_ServiceMenuItemTO *)item andService:(NSString *)email;
- (void)pressMenuItemWithRequest:(MCT_com_mobicage_to_service_PressMenuIconRequestTO *)request;
- (void)shareService:(NSString *)serviceEmail withFriend:(NSString *)friendEmail;
- (void)findServiceWithSearchString:(NSString *)searchString
                           location:(CLLocation *)location
                   organizationType:(MCTServiceOrganizationType)organizationType
                             cursor:(NSString *)cursor
                         identifier:(NSString *)identifier;


#pragma mark - Invitation Secrets

- (void)requestInvitationSecrets;
- (void)ackInvitationWithSecret:(NSString *)secret andInvitorCode:(NSString *)invitorShortCode;
- (void)logInvitationSecretSent:(NSString *)secret toPhoneNumber:(NSString *)phoneNumber;
- (NSString *)popInvitationSecret;


#pragma mark - Add friends
- (void)findRogerthatUsersFromAddressBook;
- (void)findRogerthatUsersViaFacebookAccessToken:(NSString *)fbAccessToken;

#pragma mark - Search friends
- (void)findFriendsWithSearchString:(NSString *)searchString cursor:(NSString *)cursor identifier:(NSString *)identifier;

#pragma mark - Branded Apps
- (void)sendApiCallWithService:(NSString *)serviceEmail
                          item:(NSString *)itemTagHash
                        method:(NSString *)method
                        params:(NSString *)params
                           tag:(NSString *)tag;
- (void)putUserDataWithService:(NSString *)serviceEmail
                      userData:(NSString *)userDataJsonString;


#pragma mark - UI friend utility functions
- (NSString *)friendDisplayNameByEmail:(NSString *)email;
- (NSData *)friendAvatarByEmail:(NSString *)email;
- (UIImage *)friendAvatarImageByEmail:(NSString *)email;
- (UIImage *)userAvatarImageByEmail:(NSString *)email; //  If user is not your friend this method returns an image showing that the non-friend can be invited
- (UIImage *)userAvatarImageByEmail:(NSString *)email
                 downloadIfNotFound:(BOOL)downloadIfNotFound;
- (NSString *)myEmail;
- (BOOL)isMyEmail:(NSString *)email;
- (BOOL)isRogerthatFriend:(MCTContactEntry *)contactEntry;

- (void)requestGroups;
- (void)requestGroupAvatarWithHash:(NSString *)avatarHash;
- (void)putGroup:(MCTGroup *)group;
- (void)deleteGroupWithGuid:(NSString *)guid;
- (NSDictionary *)getRogerthatUserAndServiceInfoByService:(MCTFriend *)service;
@end