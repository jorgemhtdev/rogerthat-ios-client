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

#import "MCTAbstractResponseHandler.h"
#import "MCTTransferObjects.h"


@interface MCT_com_mobicage_api_activity : NSObject

+ (void)CS_API_logCallWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_activity_LogCallRequestTO *)request;

+ (void)CS_API_logLocationsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_activity_LogLocationsRequestTO *)request;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_api_friends : NSObject

+ (void)CS_API_ackInvitationByInvitationSecretWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretRequestTO *)request;

+ (void)CS_API_breakFriendShipWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_BreakFriendshipRequestTO *)request;

+ (void)CS_API_deleteGroupWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_DeleteGroupRequestTO *)request;

+ (void)CS_API_findFriendWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_FindFriendRequestTO *)request;

+ (void)CS_API_findRogerthatUsersViaEmailWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailRequestTO *)request;

+ (void)CS_API_findRogerthatUsersViaFacebookWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookRequestTO *)request;

+ (void)CS_API_getAvatarWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetAvatarRequestTO *)request;

+ (void)CS_API_getCategoryWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetCategoryRequestTO *)request;

+ (void)CS_API_getFriendWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetFriendRequestTO *)request;

+ (void)CS_API_getFriendEmailsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetFriendEmailsRequestTO *)request;

+ (void)CS_API_getFriendInvitationSecretsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetFriendInvitationSecretsRequestTO *)request;

+ (void)CS_API_getFriendsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetFriendsListRequestTO *)request;

+ (void)CS_API_getGroupAvatarWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetGroupAvatarRequestTO *)request;

+ (void)CS_API_getGroupsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetGroupsRequestTO *)request;

+ (void)CS_API_getUserInfoWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetUserInfoRequestTO *)request;

+ (void)CS_API_inviteWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_InviteFriendRequestTO *)request;

+ (void)CS_API_logInvitationSecretSentWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_LogInvitationSecretSentRequestTO *)request;

+ (void)CS_API_putGroupWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_PutGroupRequestTO *)request;

+ (void)CS_API_requestShareLocationWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_RequestShareLocationRequestTO *)request;

+ (void)CS_API_shareLocationWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_ShareLocationRequestTO *)request;

+ (void)CS_API_userScannedWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_UserScannedRequestTO *)request;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_api_location : NSObject

+ (void)CS_API_beaconDiscoveredWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO *)request;

+ (void)CS_API_beaconInReachWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_location_BeaconInReachRequestTO *)request;

+ (void)CS_API_beaconOutOfReachWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_location_BeaconOutOfReachRequestTO *)request;

+ (void)CS_API_getBeaconRegionsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_beacon_GetBeaconRegionsRequestTO *)request;

+ (void)CS_API_getFriendLocationWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_location_GetFriendLocationRequestTO *)request;

+ (void)CS_API_getFriendLocationsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_location_GetFriendsLocationRequestTO *)request;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_api_messaging : NSObject

+ (void)CS_API_ackMessageWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_AckMessageRequestTO *)request;

+ (void)CS_API_deleteConversationWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_DeleteConversationRequestTO *)request;

+ (void)CS_API_getConversationWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_GetConversationRequestTO *)request;

+ (void)CS_API_getConversationAvatarWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_GetConversationAvatarRequestTO *)request;

+ (void)CS_API_lockMessageWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_LockMessageRequestTO *)request;

+ (void)CS_API_markMessagesAsReadWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_MarkMessagesAsReadRequestTO *)request;

+ (void)CS_API_sendMessageWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_SendMessageRequestTO *)request;

+ (void)CS_API_submitAdvancedOrderFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormRequestTO *)request;

+ (void)CS_API_submitAutoCompleteFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormRequestTO *)request;

+ (void)CS_API_submitDateSelectFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormRequestTO *)request;

+ (void)CS_API_submitGPSLocationFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormRequestTO *)request;

+ (void)CS_API_submitMultiSelectFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormRequestTO *)request;

+ (void)CS_API_submitMyDigiPassFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormRequestTO *)request;

+ (void)CS_API_submitPhotoUploadFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormRequestTO *)request;

+ (void)CS_API_submitRangeSliderFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormRequestTO *)request;

+ (void)CS_API_submitSingleSelectFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormRequestTO *)request;

+ (void)CS_API_submitSingleSliderFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormRequestTO *)request;

+ (void)CS_API_submitTextBlockFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormRequestTO *)request;

+ (void)CS_API_submitTextLineFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormRequestTO *)request;

+ (void)CS_API_uploadChunkWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_UploadChunkRequestTO *)request;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_api_messaging_jsmfr : NSObject

+ (void)CS_API_flowStartedWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_jsmfr_FlowStartedRequestTO *)request;

+ (void)CS_API_messageFlowErrorWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorRequestTO *)request;

+ (void)CS_API_messageFlowFinishedWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedRequestTO *)request;

+ (void)CS_API_messageFlowMemberResultWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultRequestTO *)request;

+ (void)CS_API_newFlowMessageWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageRequestTO *)request;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_api_services : NSObject

+ (void)CS_API_findServiceWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_FindServiceRequestTO *)request;

+ (void)CS_API_getActionInfoWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_GetServiceActionInfoRequestTO *)request;

+ (void)CS_API_getMenuIconWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_GetMenuIconRequestTO *)request;

+ (void)CS_API_getStaticFlowWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_GetStaticFlowRequestTO *)request;

+ (void)CS_API_pokeServiceWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_PokeServiceRequestTO *)request;

+ (void)CS_API_pressMenuItemWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_PressMenuIconRequestTO *)request;

+ (void)CS_API_sendApiCallWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_SendApiCallRequestTO *)request;

+ (void)CS_API_shareServiceWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_ShareServiceRequestTO *)request;

+ (void)CS_API_startActionWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_StartServiceActionRequestTO *)request;

+ (void)CS_API_updateUserDataWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_UpdateUserDataRequestTO *)request;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_api_system : NSObject

+ (void)CS_API_editProfileWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_EditProfileRequestTO *)request;

+ (void)CS_API_getIdentityWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_GetIdentityRequestTO *)request;

+ (void)CS_API_getIdentityQRCodeWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO *)request;

+ (void)CS_API_getJsEmbeddingWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_js_embedding_GetJSEmbeddingRequestTO *)request;

+ (void)CS_API_heartBeatWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_HeartBeatRequestTO *)request;

+ (void)CS_API_logErrorWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_LogErrorRequestTO *)request;

+ (void)CS_API_saveSettingsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_SaveSettingsRequest *)request;

+ (void)CS_API_setMobilePhoneNumberWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_SetMobilePhoneNumberRequestTO *)request;

+ (void)CS_API_unregisterMobileWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_UnregisterMobileRequestTO *)request;

+ (void)CS_API_updateApplePushDeviceTokenWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenRequestTO *)request;

@end

///////////////////////////////////////////////////////////////////////////////////
