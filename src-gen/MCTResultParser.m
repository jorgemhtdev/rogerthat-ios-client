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

#import "MCTResultParser.h"
#import "MCTTransferObjects.h"

@implementation MCTResultParser

+ (id)resultObjectFromResultDict:(NSDictionary *)resultDict forFunction:(NSString *)function
{
    NSRange match;

    match = [function rangeOfString:@"com.mobicage.api.activity."];
    if (match.location == 0) {

        if ([function isEqualToString:@"com.mobicage.api.activity.logCall"]) {

            MCT_com_mobicage_to_activity_LogCallResponseTO *result = [MCT_com_mobicage_to_activity_LogCallResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.activity.logLocations"]) {

            MCT_com_mobicage_to_activity_LogLocationsResponseTO *result = [MCT_com_mobicage_to_activity_LogLocationsResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        goto resultParserError;
    }

    match = [function rangeOfString:@"com.mobicage.api.friends."];
    if (match.location == 0) {

        if ([function isEqualToString:@"com.mobicage.api.friends.ackInvitationByInvitationSecret"]) {

            MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretResponseTO *result = [MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.breakFriendShip"]) {

            MCT_com_mobicage_to_friends_BreakFriendshipResponseTO *result = [MCT_com_mobicage_to_friends_BreakFriendshipResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.deleteGroup"]) {

            MCT_com_mobicage_to_friends_DeleteGroupResponseTO *result = [MCT_com_mobicage_to_friends_DeleteGroupResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.findFriend"]) {

            MCT_com_mobicage_to_friends_FindFriendResponseTO *result = [MCT_com_mobicage_to_friends_FindFriendResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.findRogerthatUsersViaEmail"]) {

            MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailResponseTO *result = [MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.findRogerthatUsersViaFacebook"]) {

            MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO *result = [MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.getAvatar"]) {

            MCT_com_mobicage_to_friends_GetAvatarResponseTO *result = [MCT_com_mobicage_to_friends_GetAvatarResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.getCategory"]) {

            MCT_com_mobicage_to_friends_GetCategoryResponseTO *result = [MCT_com_mobicage_to_friends_GetCategoryResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.getFriend"]) {

            MCT_com_mobicage_to_friends_GetFriendResponseTO *result = [MCT_com_mobicage_to_friends_GetFriendResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.getFriendEmails"]) {

            MCT_com_mobicage_to_friends_GetFriendEmailsResponseTO *result = [MCT_com_mobicage_to_friends_GetFriendEmailsResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.getFriendInvitationSecrets"]) {

            MCT_com_mobicage_to_friends_GetFriendInvitationSecretsResponseTO *result = [MCT_com_mobicage_to_friends_GetFriendInvitationSecretsResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.getFriends"]) {

            MCT_com_mobicage_to_friends_GetFriendsListResponseTO *result = [MCT_com_mobicage_to_friends_GetFriendsListResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.getGroupAvatar"]) {

            MCT_com_mobicage_to_friends_GetGroupAvatarResponseTO *result = [MCT_com_mobicage_to_friends_GetGroupAvatarResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.getGroups"]) {

            MCT_com_mobicage_to_friends_GetGroupsResponseTO *result = [MCT_com_mobicage_to_friends_GetGroupsResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.getUserInfo"]) {

            MCT_com_mobicage_to_friends_GetUserInfoResponseTO *result = [MCT_com_mobicage_to_friends_GetUserInfoResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.invite"]) {

            MCT_com_mobicage_to_friends_InviteFriendResponseTO *result = [MCT_com_mobicage_to_friends_InviteFriendResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.logInvitationSecretSent"]) {

            MCT_com_mobicage_to_friends_LogInvitationSecretSentResponseTO *result = [MCT_com_mobicage_to_friends_LogInvitationSecretSentResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.putGroup"]) {

            MCT_com_mobicage_to_friends_PutGroupResponseTO *result = [MCT_com_mobicage_to_friends_PutGroupResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.requestShareLocation"]) {

            MCT_com_mobicage_to_friends_RequestShareLocationResponseTO *result = [MCT_com_mobicage_to_friends_RequestShareLocationResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.shareLocation"]) {

            MCT_com_mobicage_to_friends_ShareLocationResponseTO *result = [MCT_com_mobicage_to_friends_ShareLocationResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.friends.userScanned"]) {

            MCT_com_mobicage_to_friends_UserScannedResponseTO *result = [MCT_com_mobicage_to_friends_UserScannedResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        goto resultParserError;
    }

    match = [function rangeOfString:@"com.mobicage.api.location."];
    if (match.location == 0) {

        if ([function isEqualToString:@"com.mobicage.api.location.beaconDiscovered"]) {

            MCT_com_mobicage_to_location_BeaconDiscoveredResponseTO *result = [MCT_com_mobicage_to_location_BeaconDiscoveredResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.location.beaconInReach"]) {

            MCT_com_mobicage_to_location_BeaconInReachResponseTO *result = [MCT_com_mobicage_to_location_BeaconInReachResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.location.beaconOutOfReach"]) {

            MCT_com_mobicage_to_location_BeaconOutOfReachResponseTO *result = [MCT_com_mobicage_to_location_BeaconOutOfReachResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.location.getBeaconRegions"]) {

            MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO *result = [MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.location.getFriendLocation"]) {

            MCT_com_mobicage_to_location_GetFriendLocationResponseTO *result = [MCT_com_mobicage_to_location_GetFriendLocationResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.location.getFriendLocations"]) {

            MCT_com_mobicage_to_location_GetFriendsLocationResponseTO *result = [MCT_com_mobicage_to_location_GetFriendsLocationResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        goto resultParserError;
    }

    match = [function rangeOfString:@"com.mobicage.api.messaging."];
    if (match.location == 0) {

        if ([function isEqualToString:@"com.mobicage.api.messaging.ackMessage"]) {

            MCT_com_mobicage_to_messaging_AckMessageResponseTO *result = [MCT_com_mobicage_to_messaging_AckMessageResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.deleteConversation"]) {

            MCT_com_mobicage_to_messaging_DeleteConversationResponseTO *result = [MCT_com_mobicage_to_messaging_DeleteConversationResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.getConversation"]) {

            MCT_com_mobicage_to_messaging_GetConversationResponseTO *result = [MCT_com_mobicage_to_messaging_GetConversationResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.getConversationAvatar"]) {

            MCT_com_mobicage_to_messaging_GetConversationAvatarResponseTO *result = [MCT_com_mobicage_to_messaging_GetConversationAvatarResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.lockMessage"]) {

            MCT_com_mobicage_to_messaging_LockMessageResponseTO *result = [MCT_com_mobicage_to_messaging_LockMessageResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.markMessagesAsRead"]) {

            MCT_com_mobicage_to_messaging_MarkMessagesAsReadResponseTO *result = [MCT_com_mobicage_to_messaging_MarkMessagesAsReadResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.sendMessage"]) {

            MCT_com_mobicage_to_messaging_SendMessageResponseTO *result = [MCT_com_mobicage_to_messaging_SendMessageResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.submitAdvancedOrderForm"]) {

            MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormResponseTO *result = [MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.submitAutoCompleteForm"]) {

            MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormResponseTO *result = [MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.submitDateSelectForm"]) {

            MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormResponseTO *result = [MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.submitGPSLocationForm"]) {

            MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormResponseTO *result = [MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.submitMultiSelectForm"]) {

            MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormResponseTO *result = [MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.submitMyDigiPassForm"]) {

            MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormResponseTO *result = [MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.submitPhotoUploadForm"]) {

            MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormResponseTO *result = [MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.submitRangeSliderForm"]) {

            MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormResponseTO *result = [MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.submitSingleSelectForm"]) {

            MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormResponseTO *result = [MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.submitSingleSliderForm"]) {

            MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormResponseTO *result = [MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.submitTextBlockForm"]) {

            MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormResponseTO *result = [MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.submitTextLineForm"]) {

            MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormResponseTO *result = [MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.uploadChunk"]) {

            MCT_com_mobicage_to_messaging_UploadChunkResponseTO *result = [MCT_com_mobicage_to_messaging_UploadChunkResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        goto resultParserError;
    }

    match = [function rangeOfString:@"com.mobicage.api.messaging.jsmfr."];
    if (match.location == 0) {

        if ([function isEqualToString:@"com.mobicage.api.messaging.jsmfr.flowStarted"]) {

            MCT_com_mobicage_to_messaging_jsmfr_FlowStartedResponseTO *result = [MCT_com_mobicage_to_messaging_jsmfr_FlowStartedResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.jsmfr.messageFlowError"]) {

            MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorResponseTO *result = [MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.jsmfr.messageFlowFinished"]) {

            MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedResponseTO *result = [MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.jsmfr.messageFlowMemberResult"]) {

            MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultResponseTO *result = [MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.messaging.jsmfr.newFlowMessage"]) {

            MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageResponseTO *result = [MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        goto resultParserError;
    }

    match = [function rangeOfString:@"com.mobicage.api.services."];
    if (match.location == 0) {

        if ([function isEqualToString:@"com.mobicage.api.services.findService"]) {

            MCT_com_mobicage_to_service_FindServiceResponseTO *result = [MCT_com_mobicage_to_service_FindServiceResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.services.getActionInfo"]) {

            MCT_com_mobicage_to_service_GetServiceActionInfoResponseTO *result = [MCT_com_mobicage_to_service_GetServiceActionInfoResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.services.getMenuIcon"]) {

            MCT_com_mobicage_to_service_GetMenuIconResponseTO *result = [MCT_com_mobicage_to_service_GetMenuIconResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.services.getStaticFlow"]) {

            MCT_com_mobicage_to_service_GetStaticFlowResponseTO *result = [MCT_com_mobicage_to_service_GetStaticFlowResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.services.pokeService"]) {

            MCT_com_mobicage_to_service_PokeServiceResponseTO *result = [MCT_com_mobicage_to_service_PokeServiceResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.services.pressMenuItem"]) {

            MCT_com_mobicage_to_service_PressMenuIconResponseTO *result = [MCT_com_mobicage_to_service_PressMenuIconResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.services.sendApiCall"]) {

            MCT_com_mobicage_to_service_SendApiCallResponseTO *result = [MCT_com_mobicage_to_service_SendApiCallResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.services.shareService"]) {

            MCT_com_mobicage_to_service_ShareServiceResponseTO *result = [MCT_com_mobicage_to_service_ShareServiceResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.services.startAction"]) {

            MCT_com_mobicage_to_service_StartServiceActionResponseTO *result = [MCT_com_mobicage_to_service_StartServiceActionResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.services.updateUserData"]) {

            MCT_com_mobicage_to_service_UpdateUserDataResponseTO *result = [MCT_com_mobicage_to_service_UpdateUserDataResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        goto resultParserError;
    }

    match = [function rangeOfString:@"com.mobicage.api.system."];
    if (match.location == 0) {

        if ([function isEqualToString:@"com.mobicage.api.system.editProfile"]) {

            MCT_com_mobicage_to_system_EditProfileResponseTO *result = [MCT_com_mobicage_to_system_EditProfileResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.system.getIdentity"]) {

            MCT_com_mobicage_to_system_GetIdentityResponseTO *result = [MCT_com_mobicage_to_system_GetIdentityResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.system.getIdentityQRCode"]) {

            MCT_com_mobicage_to_system_GetIdentityQRCodeResponseTO *result = [MCT_com_mobicage_to_system_GetIdentityQRCodeResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.system.getJsEmbedding"]) {

            MCT_com_mobicage_to_js_embedding_GetJSEmbeddingResponseTO *result = [MCT_com_mobicage_to_js_embedding_GetJSEmbeddingResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.system.heartBeat"]) {

            MCT_com_mobicage_to_system_HeartBeatResponseTO *result = [MCT_com_mobicage_to_system_HeartBeatResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.system.logError"]) {

            MCT_com_mobicage_to_system_LogErrorResponseTO *result = [MCT_com_mobicage_to_system_LogErrorResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.system.saveSettings"]) {

            MCT_com_mobicage_to_system_SaveSettingsResponse *result = [MCT_com_mobicage_to_system_SaveSettingsResponse transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.system.setMobilePhoneNumber"]) {

            MCT_com_mobicage_to_system_SetMobilePhoneNumberResponseTO *result = [MCT_com_mobicage_to_system_SetMobilePhoneNumberResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.system.unregisterMobile"]) {

            MCT_com_mobicage_to_system_UnregisterMobileResponseTO *result = [MCT_com_mobicage_to_system_UnregisterMobileResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        if ([function isEqualToString:@"com.mobicage.api.system.updateApplePushDeviceToken"]) {

            MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenResponseTO *result = [MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenResponseTO transferObjectWithDict:resultDict];
            if (result == nil)
                goto resultParserError;
            return result;

        }

        goto resultParserError;
    }


resultParserError:
    ERROR(@"Error while parsing result for function %@\n%@", function, resultDict);
    return nil;
}

@end
