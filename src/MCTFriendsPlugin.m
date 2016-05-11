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

#import "MCTActivity.h"
#import "MCTActivityEnums.h"
#import "MCTActivityPlugin.h"
#import "MCTAddressBook.h"
#import "MCTComponentFramework.h"
#import "MCTDefaultResponseHandler.h"
#import "MCTFindFriendsViaFacebookRH.h"
#import "MCTFriendsPlugin.h"
#import "MCTFriendStore.h"
#import "MCTFindFriendResponseHandler.h"
#import "MCTFindServiceResponseHandler.h"
#import "MCTGetAvatarResponseHandler.h"
#import "MCTGetFriendResponseHandler.h"
#import "MCTGetGroupsResponseHandler.h"
#import "MCTGetGroupAvatarResponseHandler.h"
#import "MCTPutGroupResponseHandler.h"
#import "MCTGetFriendInvitationSecretsRH.h"
#import "MCTGetFriendEmailsResponseHandler.h"
#import "MCTGetServiceActionInfoRH.h"
#import "MCTGetServiceMenuIconRH.h"
#import "MCTGetStaticFlowRH.h"
#import "MCTGetUserInfoResponseHandler.h"
#import "MCTGetUserQRCodeRH.h"
#import "MCTIdentity.h"
#import "MCTIntent.h"
#import "MCTIntentFramework.h"
#import "MCTLocationPlugin.h"
#import "MCTScanAddressBookRH.h"
#import "MCTServiceApiCallbackResult.h"
#import "MCTSystemPlugin.h"
#import "MCTTransferObjects.h"
#import "MCTUtils.h"
#import "MCT_CS_API.h"
#import "MCTMobileInfo.h"

int const kSTATUS_FRIEND_REMOVED = 0;
int const kSTATUS_FRIEND_ADDED = 1;
int const kSTATUS_FRIEND_MODIFIED = 2;

@interface MCTFriendsPlugin ()

- (MCTIdentity *)myIdentity;

- (void)storePokeActivityWithEmail:(NSString *)email andAction:(NSString *)action;

@end


@implementation MCTFriendsPlugin


- (MCTFriendsPlugin *)init
{
    T_BIZZ();
    if (self = [super init]) {
        self.store = [[MCTFriendStore alloc] init];

        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_USER_QRCODE_RETRIEVED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_FRIEND_REMOVED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_FRIEND_ADDED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_SERVICE_BRANDING_RETRIEVED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_GENERIC_BRANDING_RETRIEVED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_SEARCH_SERVICE_RESULT];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_USER_INFO_RETRIEVED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_SERVICE_ACTION_RETRIEVED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_SERVICE_API_CALL_ANSWERED];
        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_JS_EMBEDDING_RETRIEVED];

        [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                       forIntentActions:@[kINTENT_DO_FRIENDS_LIST_RETRIEVAL,
                                                                          kINTENT_UPDATE_FRIEND_EMAIL_HASHES,
                                                                          kINTENT_INVITATION_SECRETS_ADDED,
                                                                          kINTENT_RECIPIENTS_GET_GROUPS,
                                                                          kINTENT_RESIZE_AVATARS]
                                                                onQueue:[MCTComponentFramework workQueue]];
    }

    return self;
}

- (void)requestFriendSetWithForce:(BOOL)force recalculateMessagesShowInList:(BOOL)recalculate
{
    T_DONTCARE();
    MCTGetFriendEmailsResponseHandler *responseHandler = [[MCTGetFriendEmailsResponseHandler alloc] init];
    responseHandler.force = force;
    responseHandler.recalculateMessagesShowInList = recalculate;

    MCT_com_mobicage_to_friends_GetFriendEmailsRequestTO *request = [MCT_com_mobicage_to_friends_GetFriendEmailsRequestTO transferObject];

    [MCT_com_mobicage_api_friends CS_API_getFriendEmailsWithResponseHandler:responseHandler andRequest:request];
}

- (void)shareMyLocationWithRequest:(MCT_com_mobicage_to_friends_ShareLocationRequestTO *)request
{
    T_BIZZ();

    MCTDefaultResponseHandler *responseHandler = [MCTDefaultResponseHandler defaultResponseHandler];

    [MCT_com_mobicage_api_friends CS_API_shareLocationWithResponseHandler:responseHandler
                                                               andRequest:request];

    [self.store updateShareMyLocation:request.enabled withFriendEmail:request.friend];
}

- (void)requestLocationSharingWithFriend:(NSString *)email andMessage:(NSString *)message
{
    T_BIZZ();

    MCTDefaultResponseHandler *responseHandler = [MCTDefaultResponseHandler defaultResponseHandler];
    MCT_com_mobicage_to_friends_RequestShareLocationRequestTO *request = [MCT_com_mobicage_to_friends_RequestShareLocationRequestTO transferObject];
    request.friend = email;
    request.message = message;

    [MCT_com_mobicage_api_friends CS_API_requestShareLocationWithResponseHandler:responseHandler andRequest:request];
}

- (void)inviteFriendWithEmail:(NSString *)email andMessage:(NSString *)message
{
    T_BIZZ();
    [self inviteFriendWithEmail:email andName:nil andMessage:message];
}

- (void)inviteFriendWithEmail:(NSString *)email andName:(NSString *)name andMessage:(NSString *)message
{
    T_BIZZ();
    MCTDefaultResponseHandler *responseHandler = [MCTDefaultResponseHandler defaultResponseHandler];
    MCT_com_mobicage_to_friends_InviteFriendRequestTO *request = [MCT_com_mobicage_to_friends_InviteFriendRequestTO transferObject];
    request.email = email;
    request.message = message;

    [MCT_com_mobicage_api_friends CS_API_inviteWithResponseHandler:responseHandler andRequest:request];

    [self.store addPendingInvitation:email];

    [[MCTComponentFramework activityPlugin] logActivityWithText:[NSString stringWithFormat:NSLocalizedString(@"Invited %@", nil), name ? name : email]
                                                    andLogLevel:MCTActivityLogInfo];
}

- (void)inviteServiceWithEmail:(NSString *)email
                       andName:(NSString *)name
                andDescription:(NSString *)description
        andDescriptionBranding:(NSString *)branding
                 andAvatarData:(NSData *)avatarData
{
    [self inviteFriendWithEmail:email andName:name andMessage:nil];

    MCTFriend *friend = [[MCTFriend alloc] init];
    friend.email = email;
    friend.name = name;
    friend.type = MCTFriendTypeService;
    friend.avatarId = 0;
    friend.existence = MCTFriendExistenceInvitePending;
    friend.descriptionX = description;
    friend.descriptionBranding = branding;

    [self.store addInvitedService:friend];
    [self.store saveAvatarWithData:avatarData andFriendEmail:email];
}


- (void)markFriendDeletePendingWithEmail:(NSString *)email
{
    T_DONTCARE();

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        MCTDefaultResponseHandler *responseHandler = [MCTDefaultResponseHandler defaultResponseHandler];
        MCT_com_mobicage_to_friends_BreakFriendshipRequestTO *request = [MCT_com_mobicage_to_friends_BreakFriendshipRequestTO transferObject];
        request.friend = email;

        [MCT_com_mobicage_api_friends CS_API_breakFriendShipWithResponseHandler:responseHandler andRequest:request];
    }];

    [self.store setFriendExistenceStatus:MCTFriendExistenceDeletePending forEmail:email];

    [self.store clearGroupMemberByEmail:email];
    [self.store clearEmptyGroups];
}

- (void)requestAvatarWithId:(MCTlong)avatarId andEmail:(NSString *)email
{
    T_DONTCARE();
    MCTGetAvatarResponseHandler *rh = [MCTGetAvatarResponseHandler responseHandlerWithFriendEmail:email];
    MCT_com_mobicage_to_friends_GetAvatarRequestTO *request = [MCT_com_mobicage_to_friends_GetAvatarRequestTO transferObject];
    request.avatarId = avatarId;
    request.size = 50 * [[UIScreen mainScreen] scale];

    [MCT_com_mobicage_api_friends CS_API_getAvatarWithResponseHandler:rh andRequest:request];
}

- (void)requestUserInfoWithEmailHash:(NSString *)emailHash
{
    T_DONTCARE();
    [self requestUserInfoWithEmailHash:emailHash andStoreAvatar:NO allowCrossApp:NO];
}

- (void)requestUserInfoWithEmailHash:(NSString *)emailHash
                      andStoreAvatar:(BOOL)storeAvatar
                       allowCrossApp:(BOOL)allowCrossApp
{
    T_DONTCARE();
    MCTGetUserInfoResponseHandler *rh = [MCTGetUserInfoResponseHandler responseHandlerWithHash:emailHash
                                                                                andStoreAvatar:storeAvatar];
    MCT_com_mobicage_to_friends_GetUserInfoRequestTO *request = [MCT_com_mobicage_to_friends_GetUserInfoRequestTO transferObject];
    request.code = emailHash;
    request.allow_cross_app = allowCrossApp;

    [MCT_com_mobicage_api_friends CS_API_getUserInfoWithResponseHandler:rh andRequest:request];
}

- (void)requestUserQRWithEmail:(NSString *)email
{
    T_DONTCARE();
    MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO *request =
        [MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO transferObject];
    request.size = @"150x150";
    request.email = email;

    MCTGetUserQRCodeRH *rh = [MCTGetUserQRCodeRH responseHandlerWithEmail:email];

    [MCT_com_mobicage_api_system CS_API_getIdentityQRCodeWithResponseHandler:rh
                                                                  andRequest:request];
}

- (void)        requestFriend:(NSString *)email
                    withForce:(BOOL)force
                       isLast:(BOOL)isLast
recalculateMessagesShowInList:(BOOL)recalculateMessagesShowInList
{
    T_DONTCARE();
    MCTGetFriendResponseHandler *responseHandler = [[MCTGetFriendResponseHandler alloc] init];
    responseHandler.force = force;
    responseHandler.recalculateMessagesShowInList = recalculateMessagesShowInList;
    responseHandler.isLast = isLast;

    MCT_com_mobicage_to_friends_GetFriendRequestTO *request = [MCT_com_mobicage_to_friends_GetFriendRequestTO transferObject];
    request.email = email;
    request.avatar_size = 50 * [[UIScreen mainScreen] scale];

    [MCT_com_mobicage_api_friends CS_API_getFriendWithResponseHandler:responseHandler andRequest:request];
}

- (MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO *)updateFriendSet:(NSArray *)emails
                                                               withVersion:(MCTlong)version
                                                                     force:(BOOL)force
                                             recalculateMessagesShowInList:(BOOL)recalculateMessagesShowInList
{
    T_DONTCARE();
    return [self updateFriendSet:emails
                     withVersion:version
                           force:force
   recalculateMessagesShowInList:recalculateMessagesShowInList
                       newFriend:nil];
}

- (MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO *)updateFriendSet:(NSArray *)emails
                                                               withVersion:(MCTlong)version
                                                                     force:(BOOL)force
                                             recalculateMessagesShowInList:(BOOL)recalculateMessagesShowInList
                                                                 newFriend:(MCT_com_mobicage_to_friends_FriendTO *)newFriend
{
    T_DONTCARE();
    MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO *response =
        [MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO transferObject];

    NSMutableArray *addedFriends = [NSMutableArray array];
    NSMutableArray *removedFriends = [NSMutableArray array];
    NSMutableDictionary *removedFriendNames = [NSMutableDictionary dictionary];

    [self.store dbLockedTransactionWithBlock:^{
        MCTlong versionInDB;
        if (!force && (versionInDB = [self.store friendSetVersion]) >= version) {
            response.updated = NO;
            response.reason = [NSString stringWithFormat:@"Version in local DB (%lld) >= version on server (%lld)",
                               versionInDB, version];
            return;
        }

        NSArray *oldFriends = [self.store friendSet];

        // Get the difference between the new and the old set
        [addedFriends addObjectsFromArray:emails];
        [addedFriends removeObjectsInArray:oldFriends];
        LOG(@"Added friends: %@", addedFriends);

        [removedFriends addObjectsFromArray:oldFriends];
        [removedFriends removeObjectsInArray:emails];
        LOG(@"Removed friends: %@", removedFriends);

        if (!force && addedFriends.count == 0 && removedFriends.count == 0) {
            response.updated = NO;
            response.reason = @"The new and old friendSets are identical";
        } else {
            for (NSString *removedFriend in removedFriends) {
                [removedFriendNames setString:[self.store friendNameByEmail:removedFriend] forKey:removedFriend];
                [self.store deleteFriendFromFriendSetWithEmail:removedFriend];
                [self.store deleteFriendWithEmail:removedFriend];
            }

            // TODO: use multi-insert if it is supported (don't forget to check iOS 4.3)
            for (NSString *addedFriend in addedFriends) {
                [self.store insertFriendIntoFriendSetWithEmail:addedFriend];
            }

            response.updated = YES;
        }

        if (newFriend) {
            [self.store storeFriend:newFriend withAvatar:nil andForce:YES]; // using force to prevent extra db query
            response.updated = YES;
            response.reason = nil;
        }

        [self.store updateFriendSetVersion:version];
    }];

    NSArray *friendsToRequest = (force ? emails : addedFriends);
    if (newFriend) {
        if ([friendsToRequest containsObject:newFriend.email]) {
            // Remove newFriend from the array
            NSMutableArray *a = [NSMutableArray arrayWithArray:friendsToRequest];
            [a removeObject:newFriend.email];
            friendsToRequest = a;
        }

        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_FRIEND_ADDED];
        [intent setString:newFriend.email forKey:@"email"];
        [intent setLong:newFriend.type forKey:@"friend_type"];
        [intent setLong:newFriend.existence forKey:@"existence"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    }

    for (NSString *friend in friendsToRequest) {
        BOOL isLast = [friendsToRequest lastObject] == friend;
        [[MCTComponentFramework friendsPlugin] requestFriend:friend
                                                   withForce:force
                                                      isLast:isLast
                               recalculateMessagesShowInList:recalculateMessagesShowInList];
    }

    [removedFriendNames enumerateKeysAndObjectsUsingBlock:^(NSString *email, NSString *name, BOOL *stop) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_FRIEND_REMOVED];
        [intent setString:email forKey:@"email"];
        [intent setLong:MCTFriendExistenceDeleted forKey:@"status"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];

        MCTActivity *activity = [MCTActivity activity];
        activity.reference = activity.friendReference = email;
        activity.parameters = [NSDictionary dictionaryWithObject:name
                                                          forKey:MCT_ACTIVITY_FRIEND_NAME];
        activity.type = MCTActivityFriendRemoved;
        [[[MCTComponentFramework activityPlugin] store] saveActivity:activity];
    }];

    return response;
}

#pragma mark -
#pragma mark Services

- (void)serviceActionInfoWithEmailHash:(NSString *)emailHash andAction:(NSString *)action
{
    T_BIZZ();
    MCTGetServiceActionInfoRH *rh = [MCTGetServiceActionInfoRH responseHandlerWithHash:emailHash andAction:action];

    MCT_com_mobicage_to_service_GetServiceActionInfoRequestTO *request =
        [MCT_com_mobicage_to_service_GetServiceActionInfoRequestTO transferObject];
    request.code = emailHash;
    request.action = action;

    [MCT_com_mobicage_api_services CS_API_getActionInfoWithResponseHandler:rh andRequest:request];
}

- (void)storePokeActivityWithEmail:(NSString *)email andAction:(NSString *)action
{
    T_BIZZ();
    MCTActivity *activity = [MCTActivity activity];
    activity.reference = email;
    activity.friendReference = email;
    activity.type = MCTActivityServicePoked;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[self friendDisplayNameByEmail:email] forKey:MCT_ACTIVITY_FRIEND_NAME];
    if (action) {
        [params setObject:action forKey:MCT_ACTIVITY_POKE_ACTION];
    }
    activity.parameters = params;

    [[[MCTComponentFramework activityPlugin] store] saveActivity:activity];

}

- (void)pokeService:(NSString *)email withAction:(NSString *)action context:(NSString *)context
{
    T_BIZZ();
    MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];

    MCT_com_mobicage_to_service_StartServiceActionRequestTO *request =
        [MCT_com_mobicage_to_service_StartServiceActionRequestTO transferObject];
    request.email = email;
    request.action = action == MCTNull ? nil : action;
    request.context = context;
    request.timestamp = [MCTUtils currentServerTime];

    [MCT_com_mobicage_api_services CS_API_startActionWithResponseHandler:rh andRequest:request];

    [self storePokeActivityWithEmail:email andAction:action];
}

- (void)pokeService:(NSString *)email withHashedTag:(NSString *)hashedTag context:(NSString *)context
{
    T_BIZZ();
    MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];

    MCT_com_mobicage_to_service_PokeServiceRequestTO *request =
        [MCT_com_mobicage_to_service_PokeServiceRequestTO transferObject];
    request.email = email;
    request.hashed_tag = hashedTag;
    request.context = context;
    request.timestamp = [MCTUtils currentServerTime];

    [MCT_com_mobicage_api_services CS_API_pokeServiceWithResponseHandler:rh andRequest:request];

    [self storePokeActivityWithEmail:email andAction:hashedTag];
}

- (void)requestServiceMenuIcon:(MCT_com_mobicage_to_friends_ServiceMenuItemTO *)item withService:(NSString *)email
{
    T_BIZZ();
    MCT_com_mobicage_to_service_GetMenuIconRequestTO *req = [MCT_com_mobicage_to_service_GetMenuIconRequestTO transferObject];
    req.service = email;
    req.coords = item.coords;
    req.size = 50 * [[UIScreen mainScreen] scale];

    MCTGetServiceMenuIconRH *rh = [MCTGetServiceMenuIconRH responseHandlerWithHash:item.iconHash];

    [MCT_com_mobicage_api_services CS_API_getMenuIconWithResponseHandler:rh andRequest:req];
}

- (void)requestStaticFlowWithItem:(MCT_com_mobicage_to_friends_ServiceMenuItemTO *)item andService:(NSString *)email
{
    T_BIZZ();
    MCT_com_mobicage_to_service_GetStaticFlowRequestTO *req = [MCT_com_mobicage_to_service_GetStaticFlowRequestTO transferObject];
    req.service = email;
    req.coords = item.coords;
    req.staticFlowHash = item.staticFlowHash;

    MCTGetStaticFlowRH *rh = [MCTGetStaticFlowRH responseHandlerWithHash:item.staticFlowHash];

    [MCT_com_mobicage_api_services CS_API_getStaticFlowWithResponseHandler:rh andRequest:req];
}

- (void)pressMenuItemWithRequest:(MCT_com_mobicage_to_service_PressMenuIconRequestTO *)request
{
    T_BIZZ();
    [MCT_com_mobicage_api_services CS_API_pressMenuItemWithResponseHandler:[MCTDefaultResponseHandler defaultResponseHandler]
                                                                andRequest:request];
}

- (void)shareService:(NSString *)serviceEmail withFriend:(NSString *)friendEmail
{
    T_BIZZ();
    MCT_com_mobicage_to_service_ShareServiceRequestTO *request = [MCT_com_mobicage_to_service_ShareServiceRequestTO transferObject];
    request.service_email = serviceEmail;
    request.recipient = friendEmail;

    MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];

    [MCT_com_mobicage_api_services CS_API_shareServiceWithResponseHandler:rh andRequest:request];
}

- (void)findServiceWithSearchString:(NSString *)searchString
                           location:(CLLocation *)location
                   organizationType:(MCTServiceOrganizationType)organizationType
                             cursor:(NSString *)cursor
                         identifier:(NSString *)identifier
{
    T_BIZZ();
    MCT_com_mobicage_to_service_FindServiceRequestTO *request = [MCT_com_mobicage_to_service_FindServiceRequestTO transferObject];
    request.search_string = searchString;
    request.cursor = cursor;
    if (location) {
        request.geo_point = [MCT_com_mobicage_to_activity_GeoPointWithTimestampTO transferObject];
        request.geo_point.accuracy = location.horizontalAccuracy;
        request.geo_point.latitude = location.coordinate.latitude * MCT_LOCATION_FACTOR;
        request.geo_point.longitude = location.coordinate.longitude * MCT_LOCATION_FACTOR;
        request.geo_point.timestamp = location.timestamp.timeIntervalSince1970;
    }
    request.organization_type = organizationType;
    request.avatar_size = (MCTlong) (33.5 * [[UIScreen mainScreen] scale]);

    MCTFindServiceResponseHandler *rh = [MCTFindServiceResponseHandler responseHandlerWithSearchIdentifier:identifier];

    [MCT_com_mobicage_api_services CS_API_findServiceWithResponseHandler:rh andRequest:request];
}

#pragma mark -
#pragma mark Invitation Secrets

- (void)requestInvitationSecrets
{
    T_BIZZ();
    MCTGetFriendInvitationSecretsRH *rh = [[MCTGetFriendInvitationSecretsRH alloc] init];

    MCT_com_mobicage_to_friends_GetFriendInvitationSecretsRequestTO *request =
        [MCT_com_mobicage_to_friends_GetFriendInvitationSecretsRequestTO transferObject];

    [MCT_com_mobicage_api_friends CS_API_getFriendInvitationSecretsWithResponseHandler:rh andRequest:request];
}

- (void)ackInvitationWithSecret:(NSString *)secret andInvitorCode:(NSString *)invitorCode
{
    T_BIZZ();
    MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];

    MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretRequestTO *request =
        [MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretRequestTO transferObject];
    request.invitor_code = invitorCode;
    request.secret = secret;

    [MCT_com_mobicage_api_friends CS_API_ackInvitationByInvitationSecretWithResponseHandler:rh andRequest:request];
}

- (void)logInvitationSecretSent:(NSString *)secret toPhoneNumber:(NSString *)phoneNumber
{
    T_BIZZ();
    MCTDefaultResponseHandler *rh = [MCTDefaultResponseHandler defaultResponseHandler];

    MCT_com_mobicage_to_friends_LogInvitationSecretSentRequestTO *request =
        [MCT_com_mobicage_to_friends_LogInvitationSecretSentRequestTO transferObject];
    request.phone_number = phoneNumber;
    request.secret = secret;
    request.timestamp = [MCTUtils currentServerTime];

    [MCT_com_mobicage_api_friends CS_API_logInvitationSecretSentWithResponseHandler:rh andRequest:request];
}

- (NSString *)popInvitationSecret
{
    T_UI();
    NSString *secret = [self.store popInvitationSecret];

    if ([self.store countInvitationSecrets] <= 10) {
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            T_BIZZ();
            [self requestInvitationSecrets];
        }];
    }

    return secret;
}

#pragma mark -
#pragma mark Add friends

- (void)findRogerthatUsersFromAddressBook
{
    T_BIZZ();
    NSMutableArray *emails = [NSMutableArray array];
    for (MCTContactEntry *ce in [MCTAddressBook loadPhoneContactsWithEmail:YES andPhone:NO andSorted:NO]) {
        for (MCTContactField *emailField in ce.emails) {
            NSString *email = [emailField.value lowercaseString];
            // Filter out existing friends
            if (![self.store friendExistsWithEmail:email]) {
                [emails addObject:email];
            }
        }
    }

    MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailRequestTO *req = [MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailRequestTO transferObject];
    req.email_addresses = emails;

    MCTScanAddressBookRH *rh = [[MCTScanAddressBookRH alloc] init];
    [MCT_com_mobicage_api_friends CS_API_findRogerthatUsersViaEmailWithResponseHandler:rh andRequest:req];
}

- (void)findRogerthatUsersViaFacebookAccessToken:(NSString *)fbAccessToken
{
    T_BIZZ();
    MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookRequestTO *req = [MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookRequestTO transferObject];
    req.access_token = fbAccessToken;

    MCTFindFriendsViaFacebookRH *rh = [[MCTFindFriendsViaFacebookRH alloc] init];
    [MCT_com_mobicage_api_friends CS_API_findRogerthatUsersViaFacebookWithResponseHandler:rh andRequest:req];
}

#pragma mark - Search friends

- (void)findFriendsWithSearchString:(NSString *)searchString
                             cursor:(NSString *)cursor
                         identifier:(NSString *)identifier
{
    T_BIZZ();
    MCT_com_mobicage_to_friends_FindFriendRequestTO *request = [MCT_com_mobicage_to_friends_FindFriendRequestTO transferObject];
    request.search_string = searchString;
    request.cursor = cursor;
    request.avatar_size = (MCTlong) (33.5 * [[UIScreen mainScreen] scale]);

    MCTFindFriendResponseHandler *rh = [MCTFindFriendResponseHandler responseHandlerWithSearchIdentifier:identifier];

    [MCT_com_mobicage_api_friends CS_API_findFriendWithResponseHandler:rh andRequest:request];
}

#pragma mark - Branded Apps

- (void)sendApiCallWithService:(NSString *)serviceEmail
                          item:(NSString *)itemTagHash
                        method:(NSString *)method
                        params:(NSString *)params
                           tag:(NSString *)tag
{
    T_BIZZ();
    MCTlong idX = [self.store insertServiceApiCallWithService:serviceEmail
                                                         item:itemTagHash
                                                       method:method
                                                          tag:tag
                                                       status:MCTServiceApiCallStatusSent];

    MCT_com_mobicage_to_service_SendApiCallRequestTO *req = [MCT_com_mobicage_to_service_SendApiCallRequestTO transferObject];
    req.idX = idX;
    req.method = method;
    req.params = params;
    req.service = serviceEmail;
    req.hashed_tag = itemTagHash;
    [MCT_com_mobicage_api_services CS_API_sendApiCallWithResponseHandler:[MCTDefaultResponseHandler defaultResponseHandler]
                                                              andRequest:req];
}

- (void)putUserDataWithService:(NSString *)serviceEmail
                      userData:(NSString *)userDataJsonString
{
    T_UI();
    [self.store updateUserData:userDataJsonString withService:serviceEmail];

    MCT_com_mobicage_to_service_UpdateUserDataRequestTO *req = [MCT_com_mobicage_to_service_UpdateUserDataRequestTO transferObject];
    req.user_data = userDataJsonString;
    req.service = serviceEmail;
    [MCT_com_mobicage_api_services CS_API_updateUserDataWithResponseHandler:[MCTDefaultResponseHandler defaultResponseHandler]
                                                                 andRequest:req];
}

#pragma mark - CallReceiver methods

- (MCT_com_mobicage_to_friends_UpdateFriendResponseTO *)SC_API_updateFriendWithRequest:(MCT_com_mobicage_to_friends_UpdateFriendRequestTO *)request
{
    T_BACKLOG();
    MCT_com_mobicage_to_friends_UpdateFriendResponseTO *response;

    if (request.status != kSTATUS_FRIEND_MODIFIED) {
        response = [MCT_com_mobicage_to_friends_UpdateFriendResponseTO transferObject];
        response.updated = NO;
        response.reason = @"Ignoring updateFriend request because it's status is not STATUS_MODIFIED";
    } else if (!request.friend) {
        response = [MCT_com_mobicage_to_friends_UpdateFriendResponseTO transferObject];
        response.updated = NO;
        response.reason = @"friend was nil";
    } else {
        response = [self.store updateFriend:request.friend];
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            [[MCTComponentFramework brandingMgr] queueFriend:[MCTFriend friendWithFriendTO:request.friend]];
        }];

        MCTActivity *activity = [MCTActivity activity];
        activity.reference = request.friend.email;
        activity.friendReference = request.friend.email;
        activity.parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                               [request.friend displayName], MCT_ACTIVITY_FRIEND_NAME,
                               @(request.friend.type), MCT_ACTIVITY_FRIEND_TYPE,
                               nil];
        activity.type = MCTActivityFriendUpdated;
        [[[MCTComponentFramework activityPlugin] store] saveActivity:activity];
    }

    if (!response.updated) {
        LOG(@"%@", response.reason);
    }

    return response;
}

- (MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO *)SC_API_updateFriendSetWithRequest:(MCT_com_mobicage_to_friends_UpdateFriendSetRequestTO *)request
{
    T_BACKLOG();
    return [self updateFriendSet:request.friends
                     withVersion:request.version
                           force:NO
   recalculateMessagesShowInList:NO
                       newFriend:request.added_friend];
}

- (MCT_com_mobicage_to_friends_BecameFriendsResponseTO *)SC_API_becameFriendsWithRequest:(MCT_com_mobicage_to_friends_BecameFriendsRequestTO *)request
{
    T_BACKLOG();

    MCTActivity *activity = [MCTActivity activity];
    activity.reference = request.user;
    activity.friendReference = request.user;
    activity.type = MCTActivityFriendBecameFriend;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[self friendDisplayNameByEmail:activity.reference] forKey:MCT_ACTIVITY_FRIEND_NAME];
    [params setObject:@(request.friend.type) forKey:MCT_ACTIVITY_RELATION_TYPE];
    [params setObject:@(request.friend.avatarId) forKey:MCT_ACTIVITY_RELATION_AVATARID];
    [params setObject:request.friend.email forKey:MCT_ACTIVITY_RELATION_EMAIL];
    [params setObject:request.friend.name forKey:MCT_ACTIVITY_RELATION_NAME];
    activity.parameters = params;

    [[[MCTComponentFramework activityPlugin] store] saveActivity:activity];

    return [MCT_com_mobicage_to_friends_BecameFriendsResponseTO transferObject];
}

- (MCT_com_mobicage_to_service_ReceiveApiCallResultResponseTO *)SC_API_receiveApiCallResultWithRequest:(MCT_com_mobicage_to_service_ReceiveApiCallResultRequestTO *)request
{
    T_BACKLOG();
    HERE();
    MCTServiceApiCallbackResult *r = [self.store updateServiceApiCallWithId:request.idX
                                                                      error:request.error
                                                                     result:request.result
                                                                     status:MCTServiceApiCallStatusAnswered];
    if (r) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_SERVICE_API_CALL_ANSWERED];
        [intent setString:r.service forKey:@"service"];
        [intent setString:r.item forKey:@"item"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    } else {
        // Double execution?
        [MCTSystemPlugin logError:nil
                      withMessage:[NSString stringWithFormat:@"Could not find service_api_call with id %lld", request.idX]];
    }

    return [MCT_com_mobicage_to_service_ReceiveApiCallResultResponseTO transferObject];
}


- (MCT_com_mobicage_to_friends_UpdateGroupsResponseTO *)SC_API_updateGroupsWithRequest:(MCT_com_mobicage_to_friends_UpdateGroupsRequestTO *)request
{
    T_BACKLOG();
    [self requestGroups];
    return [MCT_com_mobicage_to_friends_UpdateGroupsResponseTO transferObject];
}

- (MCT_com_mobicage_to_service_UpdateUserDataResponseTO *)SC_API_updateUserDataWithRequest:(MCT_com_mobicage_to_service_UpdateUserDataRequestTO *)request
{
    T_BACKLOG();
    [self.store updateUserData:request.user_data
                       appData:request.app_data
                    forService:request.service
                    withIntent:YES];
    return [MCT_com_mobicage_to_service_UpdateUserDataResponseTO transferObject];
}

#pragma mark -

- (MCTIdentity *)myIdentity
{
    T_DONTCARE();
    return [[MCTComponentFramework systemPlugin] myIdentity];
}

- (NSString *)friendDisplayNameByEmail:(NSString *)email
{
    T_DONTCARE();
    if ([MCT_SYSTEM_FRIEND_EMAIL isEqualToString:email])
        return MCT_SYSTEM_FRIEND_NAME;

    MCTIdentity *myIdentity = [self myIdentity];

    NSString *name;
    if ([myIdentity.email isEqualToString:email]) {
        name = myIdentity.name;
    } else {
        name = [self.store friendNameByEmail:email];
    }
    return ([MCTUtils isEmptyOrWhitespaceString:name]) ? email : name;
}

- (NSData *)friendAvatarByEmail:(NSString *)email
{
    T_DONTCARE();
    MCTIdentity *myIdentity = [self myIdentity];
    if ([myIdentity.email isEqualToString:email])
        return myIdentity.avatar;

    return [self.store friendAvatarByEmail:email];
}

- (UIImage *)friendAvatarImageByEmail:(NSString *)email
{
    T_UI();
    if ([MCT_SYSTEM_FRIEND_EMAIL isEqualToString:email])
        return [UIImage imageNamed:MCT_SYSTEM_FRIEND_ICON];

    NSData *avatar = [self friendAvatarByEmail:email];
    return (avatar == nil) ? [UIImage imageNamed:MCT_UNKNOWN_AVATAR] : [UIImage imageWithData:avatar];
}

- (UIImage *)userAvatarImageByEmail:(NSString *)email
{
    T_UI();
    return [self userAvatarImageByEmail:email downloadIfNotFound:NO];
}


- (UIImage *)userAvatarImageByEmail:(NSString *)email
                 downloadIfNotFound:(BOOL)downloadIfNotFound
{
    T_UI();
    if ([MCT_SYSTEM_FRIEND_EMAIL isEqualToString:email])
        return [UIImage imageNamed:MCT_SYSTEM_FRIEND_ICON];

    MCTIdentity *myIdentity = [self myIdentity];
    if ([myIdentity.email isEqualToString:email])
        return [UIImage imageWithData:myIdentity.avatar];

    MCTFriend *friend = [self.store friendByEmail:email];
    if (friend == nil || friend.existence != MCTFriendExistenceActive) {

        if (downloadIfNotFound) {
            // Download avatar if needed
            if (friend == nil || friend.avatar == nil) {
                [self requestUserInfoWithEmailHash:email andStoreAvatar:YES allowCrossApp:NO];
            }
            // Fallback to default avatar image, without the '+' sign
        } else {
            return [UIImage imageNamed:MCT_UNKNOWN_AVATAR_NON_FRIEND];
        }
    }
    return (friend.avatar == nil) ? [UIImage imageNamed:MCT_UNKNOWN_AVATAR] : [UIImage imageWithData:friend.avatar];
}

- (NSString *)myEmail
{
    T_DONTCARE();
    MCTIdentity *myIdentity = [self myIdentity];
    return myIdentity.email;
}

- (BOOL)isMyEmail:(NSString *)email
{
    T_DONTCARE();
    return [[self myEmail] isEqualToString:email];
}

- (BOOL)isRogerthatFriend:(MCTContactEntry *)contact
{
    T_BIZZ();
    for (MCTContactField *emailField in contact.emails) {
        if ([[[MCTComponentFramework friendsPlugin] store] friendExistsWithEmail:[emailField.value lowercaseString]]) {
            return YES;
        }
        if ([self.myIdentity.email localizedCaseInsensitiveCompare:emailField.value] == NSOrderedSame) {
            return YES;
        }
    }

    return NO;
}


#pragma mark - Groups

- (void)requestGroups
{
    T_DONTCARE();
    MCTGetGroupsResponseHandler *responseHandler = [[MCTGetGroupsResponseHandler alloc] init];
    MCT_com_mobicage_to_friends_GetGroupsRequestTO *request = [MCT_com_mobicage_to_friends_GetGroupsRequestTO transferObject];
    [MCT_com_mobicage_api_friends CS_API_getGroupsWithResponseHandler:responseHandler andRequest:request];
}

- (void)requestGroupAvatarWithHash:(NSString *)avatarHash
{
    T_DONTCARE();
    MCTGetGroupAvatarResponseHandler *responseHandler = [MCTGetGroupAvatarResponseHandler responseHandlerWithAvatarHash:avatarHash];
    MCT_com_mobicage_to_friends_GetGroupAvatarRequestTO *request = [MCT_com_mobicage_to_friends_GetGroupAvatarRequestTO transferObject];
    request.avatar_hash = avatarHash;
    request.size = 50 * [[UIScreen mainScreen] scale];
    [MCT_com_mobicage_api_friends CS_API_getGroupAvatarWithResponseHandler:responseHandler andRequest:request];
}

- (void)putGroup:(MCTGroup *)group
{
    T_DONTCARE();
    MCTPutGroupResponseHandler *responseHandler = [MCTPutGroupResponseHandler responseHandlerWithGuid:group.guid];
    MCT_com_mobicage_to_friends_PutGroupRequestTO *request = [MCT_com_mobicage_to_friends_PutGroupRequestTO transferObject];
    request.guid = group.guid;
    request.name = group.name;
    request.avatar = [group.avatar MCTBase64Encode];
    request.members = group.members;
    [MCT_com_mobicage_api_friends CS_API_putGroupWithResponseHandler:responseHandler andRequest:request];
}

- (void)deleteGroupWithGuid:(NSString *)guid
{
    T_DONTCARE();
    MCT_com_mobicage_to_friends_DeleteGroupRequestTO *request = [MCT_com_mobicage_to_friends_DeleteGroupRequestTO transferObject];
    request.guid = guid;
    [MCT_com_mobicage_api_friends CS_API_deleteGroupWithResponseHandler:[MCTDefaultResponseHandler defaultResponseHandler] andRequest:request];
}

- (NSDictionary *)getRogerthatUserAndServiceInfoByService:(MCTFriend *)service;
{
    MCTIdentity *myIdentity = [[MCTComponentFramework systemPlugin] myIdentity];
    NSArray *data = [self.store friendDataWithEmail:service.email];

    NSString *avatarUrl = [NSString stringWithFormat:@"%@%@%lld", MCT_HTTPS_BASE_URL, MCT_AVATAR_URL_PREFIX, myIdentity.avatarId];

    MCTLocaleInfo *localeInfo = [MCTLocaleInfo info];
    NSString *language = localeInfo.language;
    NSString *country = localeInfo.country;
    if (country != nil) {
        language = [NSString stringWithFormat:@"%@_%@", language, country];
    }

    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              myIdentity.displayName, @"name",
                              avatarUrl, @"avatarUrl",
                              myIdentity.email, @"account",
                              language, @"language",
                              [data objectAtIndex:0], @"data",
                              nil];
    NSDictionary *serviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [service displayName], @"name",
                                 [service displayEmail], @"email",
                                 service.email, @"account",
                                 [data objectAtIndex:1], @"data",
                                 nil];
    MCTDeviceInfo *deviceInfo = [MCTDeviceInfo info];
    NSDictionary *systemInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"ios", @"os",
                                deviceInfo.osVersion, @"version",
                                MCT_PRODUCT_VERSION, @"appVersion",
                                MCT_PRODUCT_NAME, @"appName",
                                MCT_PRODUCT_ID, @"appId",
                                nil];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          serviceInfo, @"service",
                          userInfo, @"user",
                          systemInfo, @"system", nil];
    return info;
}

#pragma mark -
#pragma mark Intents

- (void)onIntent:(MCTIntent *)intent
{
    T_BIZZ();
    if (intent.action == kINTENT_DO_FRIENDS_LIST_RETRIEVAL) {
        [self requestFriendSetWithForce:YES recalculateMessagesShowInList:NO];
    } else if (intent.action == kINTENT_UPDATE_FRIEND_EMAIL_HASHES) {
        [self.store updateEmailHashesForAllFriends];
    } else if (intent.action == kINTENT_INVITATION_SECRETS_ADDED) {
        [self requestInvitationSecrets];
    } else if (intent.action == kINTENT_RECIPIENTS_GET_GROUPS) {
        [self requestGroups];
    } else if (intent.action == kINTENT_RESIZE_AVATARS) {
        [self.store resizeAvatarsForAllFriends];
    }
}

#pragma mark -

- (void)stop
{
    T_BIZZ();
    HERE();
    [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
    MCT_RELEASE(self.store);
}

- (void)dealloc
{
    T_BIZZ();
    [self stop];
    [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
    
}

@end