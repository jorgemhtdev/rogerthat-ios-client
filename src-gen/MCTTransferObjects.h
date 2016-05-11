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

#import "MCTJSONUtils.h"

// Forward declarations
@class MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory;
@class MCT_com_mobicage_models_properties_forms_AdvancedOrderItem;
@class MCT_com_mobicage_models_properties_forms_FormResult;
@class MCT_com_mobicage_models_properties_forms_MyDigiPassAddress;
@class MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress;
@class MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile;
@class MCT_com_mobicage_models_properties_forms_MyDigiPassProfile;
@class MCT_com_mobicage_models_properties_forms_WidgetResult;
@class MCT_com_mobicage_to_activity_CallRecordTO;
@class MCT_com_mobicage_to_activity_CellTowerTO;
@class MCT_com_mobicage_to_activity_GeoPointTO;
@class MCT_com_mobicage_to_activity_GeoPointWithTimestampTO;
@class MCT_com_mobicage_to_activity_LocationRecordTO;
@class MCT_com_mobicage_to_activity_LogCallRequestTO;
@class MCT_com_mobicage_to_activity_LogCallResponseTO;
@class MCT_com_mobicage_to_activity_LogLocationRecipientTO;
@class MCT_com_mobicage_to_activity_LogLocationsRequestTO;
@class MCT_com_mobicage_to_activity_LogLocationsResponseTO;
@class MCT_com_mobicage_to_activity_RawLocationInfoTO;
@class MCT_com_mobicage_to_beacon_BeaconRegionTO;
@class MCT_com_mobicage_to_beacon_GetBeaconRegionsRequestTO;
@class MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO;
@class MCT_com_mobicage_to_beacon_UpdateBeaconRegionsRequestTO;
@class MCT_com_mobicage_to_beacon_UpdateBeaconRegionsResponseTO;
@class MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretRequestTO;
@class MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretResponseTO;
@class MCT_com_mobicage_to_friends_BecameFriendsRequestTO;
@class MCT_com_mobicage_to_friends_BecameFriendsResponseTO;
@class MCT_com_mobicage_to_friends_BreakFriendshipRequestTO;
@class MCT_com_mobicage_to_friends_BreakFriendshipResponseTO;
@class MCT_com_mobicage_to_friends_DeleteGroupRequestTO;
@class MCT_com_mobicage_to_friends_DeleteGroupResponseTO;
@class MCT_com_mobicage_to_friends_ErrorTO;
@class MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO;
@class MCT_com_mobicage_to_friends_FindFriendItemTO;
@class MCT_com_mobicage_to_friends_FindFriendRequestTO;
@class MCT_com_mobicage_to_friends_FindFriendResponseTO;
@class MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailRequestTO;
@class MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailResponseTO;
@class MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookRequestTO;
@class MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO;
@class MCT_com_mobicage_to_friends_FriendCategoryTO;
@class MCT_com_mobicage_to_friends_FriendRelationTO;
@class MCT_com_mobicage_to_friends_FriendTO;
@class MCT_com_mobicage_to_friends_GetAvatarRequestTO;
@class MCT_com_mobicage_to_friends_GetAvatarResponseTO;
@class MCT_com_mobicage_to_friends_GetCategoryRequestTO;
@class MCT_com_mobicage_to_friends_GetCategoryResponseTO;
@class MCT_com_mobicage_to_friends_GetFriendEmailsRequestTO;
@class MCT_com_mobicage_to_friends_GetFriendEmailsResponseTO;
@class MCT_com_mobicage_to_friends_GetFriendInvitationSecretsRequestTO;
@class MCT_com_mobicage_to_friends_GetFriendInvitationSecretsResponseTO;
@class MCT_com_mobicage_to_friends_GetFriendRequestTO;
@class MCT_com_mobicage_to_friends_GetFriendResponseTO;
@class MCT_com_mobicage_to_friends_GetFriendsListRequestTO;
@class MCT_com_mobicage_to_friends_GetFriendsListResponseTO;
@class MCT_com_mobicage_to_friends_GetGroupAvatarRequestTO;
@class MCT_com_mobicage_to_friends_GetGroupAvatarResponseTO;
@class MCT_com_mobicage_to_friends_GetGroupsRequestTO;
@class MCT_com_mobicage_to_friends_GetGroupsResponseTO;
@class MCT_com_mobicage_to_friends_GetUserInfoRequestTO;
@class MCT_com_mobicage_to_friends_GetUserInfoResponseTO;
@class MCT_com_mobicage_to_friends_GroupTO;
@class MCT_com_mobicage_to_friends_InviteFriendRequestTO;
@class MCT_com_mobicage_to_friends_InviteFriendResponseTO;
@class MCT_com_mobicage_to_friends_LogInvitationSecretSentRequestTO;
@class MCT_com_mobicage_to_friends_LogInvitationSecretSentResponseTO;
@class MCT_com_mobicage_to_friends_PutGroupRequestTO;
@class MCT_com_mobicage_to_friends_PutGroupResponseTO;
@class MCT_com_mobicage_to_friends_RequestShareLocationRequestTO;
@class MCT_com_mobicage_to_friends_RequestShareLocationResponseTO;
@class MCT_com_mobicage_to_friends_ServiceMenuItemTO;
@class MCT_com_mobicage_to_friends_ServiceMenuTO;
@class MCT_com_mobicage_to_friends_ShareLocationRequestTO;
@class MCT_com_mobicage_to_friends_ShareLocationResponseTO;
@class MCT_com_mobicage_to_friends_UpdateFriendRequestTO;
@class MCT_com_mobicage_to_friends_UpdateFriendResponseTO;
@class MCT_com_mobicage_to_friends_UpdateFriendSetRequestTO;
@class MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO;
@class MCT_com_mobicage_to_friends_UpdateGroupsRequestTO;
@class MCT_com_mobicage_to_friends_UpdateGroupsResponseTO;
@class MCT_com_mobicage_to_friends_UserScannedRequestTO;
@class MCT_com_mobicage_to_friends_UserScannedResponseTO;
@class MCT_com_mobicage_to_js_embedding_GetJSEmbeddingRequestTO;
@class MCT_com_mobicage_to_js_embedding_GetJSEmbeddingResponseTO;
@class MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO;
@class MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO;
@class MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingResponseTO;
@class MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO;
@class MCT_com_mobicage_to_location_BeaconDiscoveredResponseTO;
@class MCT_com_mobicage_to_location_BeaconInReachRequestTO;
@class MCT_com_mobicage_to_location_BeaconInReachResponseTO;
@class MCT_com_mobicage_to_location_BeaconOutOfReachRequestTO;
@class MCT_com_mobicage_to_location_BeaconOutOfReachResponseTO;
@class MCT_com_mobicage_to_location_DeleteBeaconDiscoveryRequestTO;
@class MCT_com_mobicage_to_location_DeleteBeaconDiscoveryResponseTO;
@class MCT_com_mobicage_to_location_FriendLocationTO;
@class MCT_com_mobicage_to_location_GetFriendLocationRequestTO;
@class MCT_com_mobicage_to_location_GetFriendLocationResponseTO;
@class MCT_com_mobicage_to_location_GetFriendsLocationRequestTO;
@class MCT_com_mobicage_to_location_GetFriendsLocationResponseTO;
@class MCT_com_mobicage_to_location_GetLocationErrorTO;
@class MCT_com_mobicage_to_location_GetLocationRequestTO;
@class MCT_com_mobicage_to_location_GetLocationResponseTO;
@class MCT_com_mobicage_to_location_LocationResultRequestTO;
@class MCT_com_mobicage_to_location_LocationResultResponseTO;
@class MCT_com_mobicage_to_location_TrackLocationRequestTO;
@class MCT_com_mobicage_to_location_TrackLocationResponseTO;
@class MCT_com_mobicage_to_messaging_AckMessageRequestTO;
@class MCT_com_mobicage_to_messaging_AckMessageResponseTO;
@class MCT_com_mobicage_to_messaging_AttachmentTO;
@class MCT_com_mobicage_to_messaging_ButtonTO;
@class MCT_com_mobicage_to_messaging_ConversationDeletedRequestTO;
@class MCT_com_mobicage_to_messaging_ConversationDeletedResponseTO;
@class MCT_com_mobicage_to_messaging_DeleteConversationRequestTO;
@class MCT_com_mobicage_to_messaging_DeleteConversationResponseTO;
@class MCT_com_mobicage_to_messaging_EndMessageFlowRequestTO;
@class MCT_com_mobicage_to_messaging_EndMessageFlowResponseTO;
@class MCT_com_mobicage_to_messaging_GetConversationAvatarRequestTO;
@class MCT_com_mobicage_to_messaging_GetConversationAvatarResponseTO;
@class MCT_com_mobicage_to_messaging_GetConversationRequestTO;
@class MCT_com_mobicage_to_messaging_GetConversationResponseTO;
@class MCT_com_mobicage_to_messaging_LockMessageRequestTO;
@class MCT_com_mobicage_to_messaging_LockMessageResponseTO;
@class MCT_com_mobicage_to_messaging_MarkMessagesAsReadRequestTO;
@class MCT_com_mobicage_to_messaging_MarkMessagesAsReadResponseTO;
@class MCT_com_mobicage_to_messaging_MemberStatusTO;
@class MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO;
@class MCT_com_mobicage_to_messaging_MemberStatusUpdateResponseTO;
@class MCT_com_mobicage_to_messaging_MessageLockedRequestTO;
@class MCT_com_mobicage_to_messaging_MessageLockedResponseTO;
@class MCT_com_mobicage_to_messaging_MessageTO;
@class MCT_com_mobicage_to_messaging_NewMessageRequestTO;
@class MCT_com_mobicage_to_messaging_NewMessageResponseTO;
@class MCT_com_mobicage_to_messaging_SendMessageRequestTO;
@class MCT_com_mobicage_to_messaging_SendMessageResponseTO;
@class MCT_com_mobicage_to_messaging_StartFlowRequestTO;
@class MCT_com_mobicage_to_messaging_StartFlowResponseTO;
@class MCT_com_mobicage_to_messaging_TransferCompletedRequestTO;
@class MCT_com_mobicage_to_messaging_TransferCompletedResponseTO;
@class MCT_com_mobicage_to_messaging_UpdateMessageRequestTO;
@class MCT_com_mobicage_to_messaging_UpdateMessageResponseTO;
@class MCT_com_mobicage_to_messaging_UploadChunkRequestTO;
@class MCT_com_mobicage_to_messaging_UploadChunkResponseTO;
@class MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO;
@class MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormTO;
@class MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO;
@class MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO;
@class MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO;
@class MCT_com_mobicage_to_messaging_forms_AutoCompleteFormTO;
@class MCT_com_mobicage_to_messaging_forms_AutoCompleteTO;
@class MCT_com_mobicage_to_messaging_forms_ChoiceTO;
@class MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO;
@class MCT_com_mobicage_to_messaging_forms_DateSelectFormTO;
@class MCT_com_mobicage_to_messaging_forms_DateSelectTO;
@class MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO;
@class MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO;
@class MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO;
@class MCT_com_mobicage_to_messaging_forms_GPSLocationFormTO;
@class MCT_com_mobicage_to_messaging_forms_GPSLocationTO;
@class MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO;
@class MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO;
@class MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO;
@class MCT_com_mobicage_to_messaging_forms_MultiSelectFormTO;
@class MCT_com_mobicage_to_messaging_forms_MultiSelectTO;
@class MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO;
@class MCT_com_mobicage_to_messaging_forms_MyDigiPassFormTO;
@class MCT_com_mobicage_to_messaging_forms_MyDigiPassTO;
@class MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO;
@class MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_NewDateSelectFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_NewDateSelectFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_NewTextBlockFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_NewTextBlockFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_NewTextLineFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_NewTextLineFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO;
@class MCT_com_mobicage_to_messaging_forms_PhotoUploadFormTO;
@class MCT_com_mobicage_to_messaging_forms_PhotoUploadTO;
@class MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO;
@class MCT_com_mobicage_to_messaging_forms_RangeSliderFormTO;
@class MCT_com_mobicage_to_messaging_forms_RangeSliderTO;
@class MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO;
@class MCT_com_mobicage_to_messaging_forms_SingleSelectFormTO;
@class MCT_com_mobicage_to_messaging_forms_SingleSelectTO;
@class MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO;
@class MCT_com_mobicage_to_messaging_forms_SingleSliderFormTO;
@class MCT_com_mobicage_to_messaging_forms_SingleSliderTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO;
@class MCT_com_mobicage_to_messaging_forms_TextBlockFormTO;
@class MCT_com_mobicage_to_messaging_forms_TextBlockTO;
@class MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO;
@class MCT_com_mobicage_to_messaging_forms_TextLineFormTO;
@class MCT_com_mobicage_to_messaging_forms_TextLineTO;
@class MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO;
@class MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormResponseTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormRequestTO;
@class MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormResponseTO;
@class MCT_com_mobicage_to_messaging_jsmfr_FlowStartedRequestTO;
@class MCT_com_mobicage_to_messaging_jsmfr_FlowStartedResponseTO;
@class MCT_com_mobicage_to_messaging_jsmfr_JsMessageFlowMemberRunTO;
@class MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorRequestTO;
@class MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorResponseTO;
@class MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedRequestTO;
@class MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedResponseTO;
@class MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultRequestTO;
@class MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultResponseTO;
@class MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageRequestTO;
@class MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageResponseTO;
@class MCT_com_mobicage_to_service_FindServiceCategoryTO;
@class MCT_com_mobicage_to_service_FindServiceItemTO;
@class MCT_com_mobicage_to_service_FindServiceRequestTO;
@class MCT_com_mobicage_to_service_FindServiceResponseTO;
@class MCT_com_mobicage_to_service_GetMenuIconRequestTO;
@class MCT_com_mobicage_to_service_GetMenuIconResponseTO;
@class MCT_com_mobicage_to_service_GetServiceActionInfoRequestTO;
@class MCT_com_mobicage_to_service_GetServiceActionInfoResponseTO;
@class MCT_com_mobicage_to_service_GetStaticFlowRequestTO;
@class MCT_com_mobicage_to_service_GetStaticFlowResponseTO;
@class MCT_com_mobicage_to_service_PokeServiceRequestTO;
@class MCT_com_mobicage_to_service_PokeServiceResponseTO;
@class MCT_com_mobicage_to_service_PressMenuIconRequestTO;
@class MCT_com_mobicage_to_service_PressMenuIconResponseTO;
@class MCT_com_mobicage_to_service_ReceiveApiCallResultRequestTO;
@class MCT_com_mobicage_to_service_ReceiveApiCallResultResponseTO;
@class MCT_com_mobicage_to_service_SendApiCallRequestTO;
@class MCT_com_mobicage_to_service_SendApiCallResponseTO;
@class MCT_com_mobicage_to_service_ShareServiceRequestTO;
@class MCT_com_mobicage_to_service_ShareServiceResponseTO;
@class MCT_com_mobicage_to_service_StartServiceActionRequestTO;
@class MCT_com_mobicage_to_service_StartServiceActionResponseTO;
@class MCT_com_mobicage_to_service_UpdateUserDataRequestTO;
@class MCT_com_mobicage_to_service_UpdateUserDataResponseTO;
@class MCT_com_mobicage_to_system_EditProfileRequestTO;
@class MCT_com_mobicage_to_system_EditProfileResponseTO;
@class MCT_com_mobicage_to_system_ForwardLogsRequestTO;
@class MCT_com_mobicage_to_system_ForwardLogsResponseTO;
@class MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO;
@class MCT_com_mobicage_to_system_GetIdentityQRCodeResponseTO;
@class MCT_com_mobicage_to_system_GetIdentityRequestTO;
@class MCT_com_mobicage_to_system_GetIdentityResponseTO;
@class MCT_com_mobicage_to_system_HeartBeatRequestTO;
@class MCT_com_mobicage_to_system_HeartBeatResponseTO;
@class MCT_com_mobicage_to_system_IdentityTO;
@class MCT_com_mobicage_to_system_IdentityUpdateRequestTO;
@class MCT_com_mobicage_to_system_IdentityUpdateResponseTO;
@class MCT_com_mobicage_to_system_LogErrorRequestTO;
@class MCT_com_mobicage_to_system_LogErrorResponseTO;
@class MCT_com_mobicage_to_system_SaveSettingsRequest;
@class MCT_com_mobicage_to_system_SaveSettingsResponse;
@class MCT_com_mobicage_to_system_SetMobilePhoneNumberRequestTO;
@class MCT_com_mobicage_to_system_SetMobilePhoneNumberResponseTO;
@class MCT_com_mobicage_to_system_SettingsTO;
@class MCT_com_mobicage_to_system_UnregisterMobileRequestTO;
@class MCT_com_mobicage_to_system_UnregisterMobileResponseTO;
@class MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenRequestTO;
@class MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenResponseTO;
@class MCT_com_mobicage_to_system_UpdateAvailableRequestTO;
@class MCT_com_mobicage_to_system_UpdateAvailableResponseTO;
@class MCT_com_mobicage_to_system_UpdateSettingsRequestTO;
@class MCT_com_mobicage_to_system_UpdateSettingsResponseTO;


@interface MCTTransferObject : NSObject
- (id)errorDuringInitBecauseOfFieldWithName:(NSString *)fieldName;
@end


///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *items;
@property(nonatomic, copy)   NSString *idX;
@property(nonatomic, copy)   NSString *name;

+ (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *)transferObject;
+ (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_models_properties_forms_AdvancedOrderItem : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *descriptionX;
@property(nonatomic)         BOOL      has_price;
@property(nonatomic, copy)   NSString *idX;
@property(nonatomic, copy)   NSString *image_url;
@property(nonatomic, copy)   NSString *name;
@property(nonatomic)         MCTlong   step;
@property(nonatomic, copy)   NSString *step_unit;
@property(nonatomic)         MCTlong   step_unit_conversion;
@property(nonatomic, copy)   NSString *unit;
@property(nonatomic)         MCTlong   unit_price;
@property(nonatomic)         MCTlong   value;

+ (MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *)transferObject;
+ (MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_models_properties_forms_FormResult : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_models_properties_forms_WidgetResult *result;
@property(nonatomic, copy)   NSString *type;

+ (MCT_com_mobicage_models_properties_forms_FormResult *)transferObject;
+ (MCT_com_mobicage_models_properties_forms_FormResult *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_models_properties_forms_MyDigiPassAddress : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *address_1;
@property(nonatomic, copy)   NSString *address_2;
@property(nonatomic, copy)   NSString *city;
@property(nonatomic, copy)   NSString *country;
@property(nonatomic, copy)   NSString *state;
@property(nonatomic, copy)   NSString *zip;

+ (MCT_com_mobicage_models_properties_forms_MyDigiPassAddress *)transferObject;
+ (MCT_com_mobicage_models_properties_forms_MyDigiPassAddress *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *municipality;
@property(nonatomic, copy)   NSString *street_and_number;
@property(nonatomic, copy)   NSString *zip_code;

+ (MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress *)transferObject;
+ (MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *card_number;
@property(nonatomic, copy)   NSString *chip_number;
@property(nonatomic, copy)   NSString *created_at;
@property(nonatomic, copy)   NSString *date_of_birth;
@property(nonatomic, copy)   NSString *first_name;
@property(nonatomic, copy)   NSString *first_name_3;
@property(nonatomic, copy)   NSString *gender;
@property(nonatomic, copy)   NSString *issuing_municipality;
@property(nonatomic, copy)   NSString *last_name;
@property(nonatomic, copy)   NSString *location_of_birth;
@property(nonatomic, copy)   NSString *nationality;
@property(nonatomic, copy)   NSString *noble_condition;
@property(nonatomic, copy)   NSString *validity_begins_at;
@property(nonatomic, copy)   NSString *validity_ends_at;

+ (MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile *)transferObject;
+ (MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_models_properties_forms_MyDigiPassProfile : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *born_on;
@property(nonatomic, copy)   NSString *first_name;
@property(nonatomic, copy)   NSString *last_name;
@property(nonatomic, copy)   NSString *preferred_locale;
@property(nonatomic, copy)   NSString *updated_at;
@property(nonatomic, copy)   NSString *uuid;

+ (MCT_com_mobicage_models_properties_forms_MyDigiPassProfile *)transferObject;
+ (MCT_com_mobicage_models_properties_forms_MyDigiPassProfile *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_models_properties_forms_WidgetResult : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_models_properties_forms_WidgetResult *)transferObject;
+ (MCT_com_mobicage_models_properties_forms_WidgetResult *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_activity_CallRecordTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_activity_GeoPointTO *geoPoint;
@property(nonatomic, strong) MCT_com_mobicage_to_activity_RawLocationInfoTO *rawLocation;
@property(nonatomic, copy)   NSString *countrycode;
@property(nonatomic)         MCTlong   duration;
@property(nonatomic)         MCTlong   idX;
@property(nonatomic, copy)   NSString *phoneNumber;
@property(nonatomic)         MCTlong   starttime;
@property(nonatomic)         MCTlong   type;

+ (MCT_com_mobicage_to_activity_CallRecordTO *)transferObject;
+ (MCT_com_mobicage_to_activity_CallRecordTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_activity_CellTowerTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   cid;
@property(nonatomic)         MCTlong   strength;

+ (MCT_com_mobicage_to_activity_CellTowerTO *)transferObject;
+ (MCT_com_mobicage_to_activity_CellTowerTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_activity_GeoPointTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   accuracy;
@property(nonatomic)         MCTlong   latitude;
@property(nonatomic)         MCTlong   longitude;

+ (MCT_com_mobicage_to_activity_GeoPointTO *)transferObject;
+ (MCT_com_mobicage_to_activity_GeoPointTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_activity_GeoPointWithTimestampTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   accuracy;
@property(nonatomic)         MCTlong   latitude;
@property(nonatomic)         MCTlong   longitude;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *)transferObject;
+ (MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_activity_LocationRecordTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_activity_GeoPointTO *geoPoint;
@property(nonatomic, strong) MCT_com_mobicage_to_activity_RawLocationInfoTO *rawLocation;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_activity_LocationRecordTO *)transferObject;
+ (MCT_com_mobicage_to_activity_LocationRecordTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_activity_LogCallRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_activity_CallRecordTO *record;

+ (MCT_com_mobicage_to_activity_LogCallRequestTO *)transferObject;
+ (MCT_com_mobicage_to_activity_LogCallRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_activity_LogCallResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   recordId;

+ (MCT_com_mobicage_to_activity_LogCallResponseTO *)transferObject;
+ (MCT_com_mobicage_to_activity_LogCallResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_activity_LogLocationRecipientTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *friend;
@property(nonatomic)         MCTlong   target;

+ (MCT_com_mobicage_to_activity_LogLocationRecipientTO *)transferObject;
+ (MCT_com_mobicage_to_activity_LogLocationRecipientTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_activity_LogLocationsRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *recipients;
@property(nonatomic, strong) NSArray  *records;

+ (MCT_com_mobicage_to_activity_LogLocationsRequestTO *)transferObject;
+ (MCT_com_mobicage_to_activity_LogLocationsRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_activity_LogLocationsResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_activity_LogLocationsResponseTO *)transferObject;
+ (MCT_com_mobicage_to_activity_LogLocationsResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_activity_RawLocationInfoTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *towers;
@property(nonatomic)         MCTlong   cid;
@property(nonatomic)         MCTlong   lac;
@property(nonatomic)         MCTlong   mobileDataType;
@property(nonatomic)         MCTlong   net;
@property(nonatomic)         MCTlong   signalStrength;

+ (MCT_com_mobicage_to_activity_RawLocationInfoTO *)transferObject;
+ (MCT_com_mobicage_to_activity_RawLocationInfoTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_beacon_BeaconRegionTO : MCTTransferObject <IJSONable>


@property(nonatomic)         BOOL      has_major;
@property(nonatomic)         BOOL      has_minor;
@property(nonatomic)         MCTlong   major;
@property(nonatomic)         MCTlong   minor;
@property(nonatomic, copy)   NSString *uuid;

+ (MCT_com_mobicage_to_beacon_BeaconRegionTO *)transferObject;
+ (MCT_com_mobicage_to_beacon_BeaconRegionTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_beacon_GetBeaconRegionsRequestTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_beacon_GetBeaconRegionsRequestTO *)transferObject;
+ (MCT_com_mobicage_to_beacon_GetBeaconRegionsRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *regions;

+ (MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO *)transferObject;
+ (MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_beacon_UpdateBeaconRegionsRequestTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_beacon_UpdateBeaconRegionsRequestTO *)transferObject;
+ (MCT_com_mobicage_to_beacon_UpdateBeaconRegionsRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_beacon_UpdateBeaconRegionsResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_beacon_UpdateBeaconRegionsResponseTO *)transferObject;
+ (MCT_com_mobicage_to_beacon_UpdateBeaconRegionsResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *invitor_code;
@property(nonatomic, copy)   NSString *secret;

+ (MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_BecameFriendsRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_friends_FriendRelationTO *friend;
@property(nonatomic, copy)   NSString *user;

+ (MCT_com_mobicage_to_friends_BecameFriendsRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_BecameFriendsRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_BecameFriendsResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_friends_BecameFriendsResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_BecameFriendsResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_BreakFriendshipRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *friend;

+ (MCT_com_mobicage_to_friends_BreakFriendshipRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_BreakFriendshipRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_BreakFriendshipResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_friends_BreakFriendshipResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_BreakFriendshipResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_DeleteGroupRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *guid;

+ (MCT_com_mobicage_to_friends_DeleteGroupRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_DeleteGroupRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_DeleteGroupResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_friends_DeleteGroupResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_DeleteGroupResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_ErrorTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *action;
@property(nonatomic, copy)   NSString *caption;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic, copy)   NSString *title;

+ (MCT_com_mobicage_to_friends_ErrorTO *)transferObject;
+ (MCT_com_mobicage_to_friends_ErrorTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *fbId;
@property(nonatomic, copy)   NSString *fbName;
@property(nonatomic, copy)   NSString *fbPicture;
@property(nonatomic, copy)   NSString *rtId;

+ (MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO *)transferObject;
+ (MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_FindFriendItemTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *avatar_url;
@property(nonatomic, copy)   NSString *email;
@property(nonatomic, copy)   NSString *name;

+ (MCT_com_mobicage_to_friends_FindFriendItemTO *)transferObject;
+ (MCT_com_mobicage_to_friends_FindFriendItemTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_FindFriendRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   avatar_size;
@property(nonatomic, copy)   NSString *cursor;
@property(nonatomic, copy)   NSString *search_string;

+ (MCT_com_mobicage_to_friends_FindFriendRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_FindFriendRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_FindFriendResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *items;
@property(nonatomic, copy)   NSString *cursor;
@property(nonatomic, copy)   NSString *error_string;

+ (MCT_com_mobicage_to_friends_FindFriendResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_FindFriendResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *email_addresses;

+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *matched_addresses;

+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *access_token;

+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *matches;

+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_FriendCategoryTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *avatar;
@property(nonatomic, copy)   NSString *guid;
@property(nonatomic, copy)   NSString *name;

+ (MCT_com_mobicage_to_friends_FriendCategoryTO *)transferObject;
+ (MCT_com_mobicage_to_friends_FriendCategoryTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_FriendRelationTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   avatarId;
@property(nonatomic, copy)   NSString *email;
@property(nonatomic, copy)   NSString *name;
@property(nonatomic)         MCTlong   type;

+ (MCT_com_mobicage_to_friends_FriendRelationTO *)transferObject;
+ (MCT_com_mobicage_to_friends_FriendRelationTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_FriendTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_friends_ServiceMenuTO *actionMenu;
@property(nonatomic, copy)   NSString *appData;
@property(nonatomic, copy)   NSString *avatarHash;
@property(nonatomic)         MCTlong   avatarId;
@property(nonatomic, copy)   NSString *broadcastFlowHash;
@property(nonatomic)         MCTlong   callbacks;
@property(nonatomic, copy)   NSString *category_id;
@property(nonatomic, copy)   NSString *contentBrandingHash;
@property(nonatomic, copy)   NSString *descriptionX;
@property(nonatomic, copy)   NSString *descriptionBranding;
@property(nonatomic, copy)   NSString *email;
@property(nonatomic)         MCTlong   existence;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic)         MCTlong   generation;
@property(nonatomic)         BOOL      hasUserData;
@property(nonatomic, copy)   NSString *name;
@property(nonatomic)         MCTlong   organizationType;
@property(nonatomic, copy)   NSString *pokeDescription;
@property(nonatomic, copy)   NSString *profileData;
@property(nonatomic, copy)   NSString *qualifiedIdentifier;
@property(nonatomic)         BOOL      shareLocation;
@property(nonatomic)         BOOL      sharesContacts;
@property(nonatomic)         BOOL      sharesLocation;
@property(nonatomic)         MCTlong   type;
@property(nonatomic, copy)   NSString *userData;
@property(nonatomic, strong) NSArray  *versions;

+ (MCT_com_mobicage_to_friends_FriendTO *)transferObject;
+ (MCT_com_mobicage_to_friends_FriendTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetAvatarRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   avatarId;
@property(nonatomic)         MCTlong   size;

+ (MCT_com_mobicage_to_friends_GetAvatarRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetAvatarRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetAvatarResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *avatar;

+ (MCT_com_mobicage_to_friends_GetAvatarResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetAvatarResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetCategoryRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *category_id;

+ (MCT_com_mobicage_to_friends_GetCategoryRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetCategoryRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetCategoryResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_friends_FriendCategoryTO *category;

+ (MCT_com_mobicage_to_friends_GetCategoryResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetCategoryResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetFriendEmailsRequestTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_friends_GetFriendEmailsRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetFriendEmailsRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetFriendEmailsResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *emails;
@property(nonatomic)         MCTlong   friend_set_version;
@property(nonatomic)         MCTlong   generation;

+ (MCT_com_mobicage_to_friends_GetFriendEmailsResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetFriendEmailsResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetFriendInvitationSecretsRequestTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_friends_GetFriendInvitationSecretsRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetFriendInvitationSecretsRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetFriendInvitationSecretsResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *secrets;

+ (MCT_com_mobicage_to_friends_GetFriendInvitationSecretsResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetFriendInvitationSecretsResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetFriendRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   avatar_size;
@property(nonatomic, copy)   NSString *email;

+ (MCT_com_mobicage_to_friends_GetFriendRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetFriendRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetFriendResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_friends_FriendTO *friend;
@property(nonatomic, copy)   NSString *avatar;
@property(nonatomic)         MCTlong   generation;

+ (MCT_com_mobicage_to_friends_GetFriendResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetFriendResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetFriendsListRequestTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_friends_GetFriendsListRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetFriendsListRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetFriendsListResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *friends;
@property(nonatomic)         MCTlong   generation;

+ (MCT_com_mobicage_to_friends_GetFriendsListResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetFriendsListResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetGroupAvatarRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *avatar_hash;
@property(nonatomic)         MCTlong   size;

+ (MCT_com_mobicage_to_friends_GetGroupAvatarRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetGroupAvatarRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetGroupAvatarResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *avatar;

+ (MCT_com_mobicage_to_friends_GetGroupAvatarResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetGroupAvatarResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetGroupsRequestTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_friends_GetGroupsRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetGroupsRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetGroupsResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *groups;

+ (MCT_com_mobicage_to_friends_GetGroupsResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetGroupsResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetUserInfoRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic)         BOOL      allow_cross_app;
@property(nonatomic, copy)   NSString *code;

+ (MCT_com_mobicage_to_friends_GetUserInfoRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetUserInfoRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GetUserInfoResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_friends_ErrorTO *error;
@property(nonatomic, copy)   NSString *app_id;
@property(nonatomic, copy)   NSString *avatar;
@property(nonatomic)         MCTlong   avatar_id;
@property(nonatomic, copy)   NSString *descriptionX;
@property(nonatomic, copy)   NSString *descriptionBranding;
@property(nonatomic, copy)   NSString *email;
@property(nonatomic, copy)   NSString *name;
@property(nonatomic, copy)   NSString *profileData;
@property(nonatomic, copy)   NSString *qualifiedIdentifier;
@property(nonatomic)         MCTlong   type;

+ (MCT_com_mobicage_to_friends_GetUserInfoResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GetUserInfoResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_GroupTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *avatar_hash;
@property(nonatomic, copy)   NSString *guid;
@property(nonatomic, strong) NSArray  *members;
@property(nonatomic, copy)   NSString *name;

+ (MCT_com_mobicage_to_friends_GroupTO *)transferObject;
+ (MCT_com_mobicage_to_friends_GroupTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_InviteFriendRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *email;
@property(nonatomic, copy)   NSString *message;

+ (MCT_com_mobicage_to_friends_InviteFriendRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_InviteFriendRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_InviteFriendResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_friends_InviteFriendResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_InviteFriendResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_LogInvitationSecretSentRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *phone_number;
@property(nonatomic, copy)   NSString *secret;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_friends_LogInvitationSecretSentRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_LogInvitationSecretSentRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_LogInvitationSecretSentResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_friends_LogInvitationSecretSentResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_LogInvitationSecretSentResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_PutGroupRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *avatar;
@property(nonatomic, copy)   NSString *guid;
@property(nonatomic, strong) NSArray  *members;
@property(nonatomic, copy)   NSString *name;

+ (MCT_com_mobicage_to_friends_PutGroupRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_PutGroupRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_PutGroupResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *avatar_hash;

+ (MCT_com_mobicage_to_friends_PutGroupResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_PutGroupResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_RequestShareLocationRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *friend;
@property(nonatomic, copy)   NSString *message;

+ (MCT_com_mobicage_to_friends_RequestShareLocationRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_RequestShareLocationRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_RequestShareLocationResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_friends_RequestShareLocationResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_RequestShareLocationResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_ServiceMenuItemTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *coords;
@property(nonatomic, copy)   NSString *hashedTag;
@property(nonatomic, copy)   NSString *iconHash;
@property(nonatomic, copy)   NSString *label;
@property(nonatomic)         BOOL      requiresWifi;
@property(nonatomic)         BOOL      runInBackground;
@property(nonatomic, copy)   NSString *screenBranding;
@property(nonatomic, copy)   NSString *staticFlowHash;

+ (MCT_com_mobicage_to_friends_ServiceMenuItemTO *)transferObject;
+ (MCT_com_mobicage_to_friends_ServiceMenuItemTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_ServiceMenuTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *items;
@property(nonatomic, copy)   NSString *aboutLabel;
@property(nonatomic, copy)   NSString *branding;
@property(nonatomic, copy)   NSString *callConfirmation;
@property(nonatomic, copy)   NSString *callLabel;
@property(nonatomic, copy)   NSString *messagesLabel;
@property(nonatomic, copy)   NSString *phoneNumber;
@property(nonatomic)         BOOL      share;
@property(nonatomic, copy)   NSString *shareCaption;
@property(nonatomic, copy)   NSString *shareDescription;
@property(nonatomic, copy)   NSString *shareImageUrl;
@property(nonatomic, copy)   NSString *shareLabel;
@property(nonatomic, copy)   NSString *shareLinkUrl;
@property(nonatomic, strong) NSArray  *staticFlowBrandings;

+ (MCT_com_mobicage_to_friends_ServiceMenuTO *)transferObject;
+ (MCT_com_mobicage_to_friends_ServiceMenuTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_ShareLocationRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic)         BOOL      enabled;
@property(nonatomic, copy)   NSString *friend;

+ (MCT_com_mobicage_to_friends_ShareLocationRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_ShareLocationRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_ShareLocationResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_friends_ShareLocationResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_ShareLocationResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_UpdateFriendRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_friends_FriendTO *friend;
@property(nonatomic)         MCTlong   generation;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_friends_UpdateFriendRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_UpdateFriendRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_UpdateFriendResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *reason;
@property(nonatomic)         BOOL      updated;

+ (MCT_com_mobicage_to_friends_UpdateFriendResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_UpdateFriendResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_UpdateFriendSetRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_friends_FriendTO *added_friend;
@property(nonatomic, strong) NSArray  *friends;
@property(nonatomic)         MCTlong   version;

+ (MCT_com_mobicage_to_friends_UpdateFriendSetRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_UpdateFriendSetRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *reason;
@property(nonatomic)         BOOL      updated;

+ (MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_UpdateGroupsRequestTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_friends_UpdateGroupsRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_UpdateGroupsRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_UpdateGroupsResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_friends_UpdateGroupsResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_UpdateGroupsResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_UserScannedRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *app_id;
@property(nonatomic, copy)   NSString *email;
@property(nonatomic, copy)   NSString *service_email;

+ (MCT_com_mobicage_to_friends_UserScannedRequestTO *)transferObject;
+ (MCT_com_mobicage_to_friends_UserScannedRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_friends_UserScannedResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_friends_UserScannedResponseTO *)transferObject;
+ (MCT_com_mobicage_to_friends_UserScannedResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_js_embedding_GetJSEmbeddingRequestTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_js_embedding_GetJSEmbeddingRequestTO *)transferObject;
+ (MCT_com_mobicage_to_js_embedding_GetJSEmbeddingRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_js_embedding_GetJSEmbeddingResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *items;

+ (MCT_com_mobicage_to_js_embedding_GetJSEmbeddingResponseTO *)transferObject;
+ (MCT_com_mobicage_to_js_embedding_GetJSEmbeddingResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *hashX;
@property(nonatomic, copy)   NSString *name;

+ (MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO *)transferObject;
+ (MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *items;

+ (MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO *)transferObject;
+ (MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingResponseTO *)transferObject;
+ (MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *name;
@property(nonatomic, copy)   NSString *uuid;

+ (MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO *)transferObject;
+ (MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_BeaconDiscoveredResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *friend_email;
@property(nonatomic, copy)   NSString *tag;

+ (MCT_com_mobicage_to_location_BeaconDiscoveredResponseTO *)transferObject;
+ (MCT_com_mobicage_to_location_BeaconDiscoveredResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_BeaconInReachRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *friend_email;
@property(nonatomic, copy)   NSString *name;
@property(nonatomic)         MCTlong   proximity;
@property(nonatomic, copy)   NSString *uuid;

+ (MCT_com_mobicage_to_location_BeaconInReachRequestTO *)transferObject;
+ (MCT_com_mobicage_to_location_BeaconInReachRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_BeaconInReachResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_location_BeaconInReachResponseTO *)transferObject;
+ (MCT_com_mobicage_to_location_BeaconInReachResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_BeaconOutOfReachRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *friend_email;
@property(nonatomic, copy)   NSString *name;
@property(nonatomic, copy)   NSString *uuid;

+ (MCT_com_mobicage_to_location_BeaconOutOfReachRequestTO *)transferObject;
+ (MCT_com_mobicage_to_location_BeaconOutOfReachRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_BeaconOutOfReachResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_location_BeaconOutOfReachResponseTO *)transferObject;
+ (MCT_com_mobicage_to_location_BeaconOutOfReachResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_DeleteBeaconDiscoveryRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *name;
@property(nonatomic, copy)   NSString *uuid;

+ (MCT_com_mobicage_to_location_DeleteBeaconDiscoveryRequestTO *)transferObject;
+ (MCT_com_mobicage_to_location_DeleteBeaconDiscoveryRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_DeleteBeaconDiscoveryResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_location_DeleteBeaconDiscoveryResponseTO *)transferObject;
+ (MCT_com_mobicage_to_location_DeleteBeaconDiscoveryResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_FriendLocationTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *location;
@property(nonatomic, copy)   NSString *email;

+ (MCT_com_mobicage_to_location_FriendLocationTO *)transferObject;
+ (MCT_com_mobicage_to_location_FriendLocationTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_GetFriendLocationRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *friend;

+ (MCT_com_mobicage_to_location_GetFriendLocationRequestTO *)transferObject;
+ (MCT_com_mobicage_to_location_GetFriendLocationRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_GetFriendLocationResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *location;

+ (MCT_com_mobicage_to_location_GetFriendLocationResponseTO *)transferObject;
+ (MCT_com_mobicage_to_location_GetFriendLocationResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_GetFriendsLocationRequestTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_location_GetFriendsLocationRequestTO *)transferObject;
+ (MCT_com_mobicage_to_location_GetFriendsLocationRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_GetFriendsLocationResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *locations;

+ (MCT_com_mobicage_to_location_GetFriendsLocationResponseTO *)transferObject;
+ (MCT_com_mobicage_to_location_GetFriendsLocationResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_GetLocationErrorTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *message;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_location_GetLocationErrorTO *)transferObject;
+ (MCT_com_mobicage_to_location_GetLocationErrorTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_GetLocationRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *friend;
@property(nonatomic)         BOOL      high_prio;
@property(nonatomic)         MCTlong   target;

+ (MCT_com_mobicage_to_location_GetLocationRequestTO *)transferObject;
+ (MCT_com_mobicage_to_location_GetLocationRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_GetLocationResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_location_GetLocationErrorTO *error;

+ (MCT_com_mobicage_to_location_GetLocationResponseTO *)transferObject;
+ (MCT_com_mobicage_to_location_GetLocationResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_LocationResultRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *location;
@property(nonatomic, copy)   NSString *friend;

+ (MCT_com_mobicage_to_location_LocationResultRequestTO *)transferObject;
+ (MCT_com_mobicage_to_location_LocationResultRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_LocationResultResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_location_LocationResultResponseTO *)transferObject;
+ (MCT_com_mobicage_to_location_LocationResultResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_TrackLocationRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   distance_filter;
@property(nonatomic, copy)   NSString *friend;
@property(nonatomic)         BOOL      high_prio;
@property(nonatomic)         MCTlong   target;
@property(nonatomic)         MCTlong   until;

+ (MCT_com_mobicage_to_location_TrackLocationRequestTO *)transferObject;
+ (MCT_com_mobicage_to_location_TrackLocationRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_location_TrackLocationResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_location_GetLocationErrorTO *error;

+ (MCT_com_mobicage_to_location_TrackLocationResponseTO *)transferObject;
+ (MCT_com_mobicage_to_location_TrackLocationResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_AckMessageRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *custom_reply;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_AckMessageRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_AckMessageRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_AckMessageResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   result;

+ (MCT_com_mobicage_to_messaging_AckMessageResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_AckMessageResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_AttachmentTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *content_type;
@property(nonatomic, copy)   NSString *download_url;
@property(nonatomic, copy)   NSString *name;
@property(nonatomic)         MCTlong   size;

+ (MCT_com_mobicage_to_messaging_AttachmentTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_AttachmentTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_ButtonTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *action;
@property(nonatomic, copy)   NSString *caption;
@property(nonatomic, copy)   NSString *idX;
@property(nonatomic)         MCTlong   ui_flags;

+ (MCT_com_mobicage_to_messaging_ButtonTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_ButtonTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_ConversationDeletedRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *parent_message_key;

+ (MCT_com_mobicage_to_messaging_ConversationDeletedRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_ConversationDeletedRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_ConversationDeletedResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_ConversationDeletedResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_ConversationDeletedResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_DeleteConversationRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *parent_message_key;

+ (MCT_com_mobicage_to_messaging_DeleteConversationRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_DeleteConversationRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_DeleteConversationResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_DeleteConversationResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_DeleteConversationResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_EndMessageFlowRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *message_flow_run_id;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         BOOL      wait_for_followup;

+ (MCT_com_mobicage_to_messaging_EndMessageFlowRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_EndMessageFlowRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_EndMessageFlowResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_EndMessageFlowResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_EndMessageFlowResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_GetConversationAvatarRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *avatar_hash;
@property(nonatomic, copy)   NSString *thread_key;

+ (MCT_com_mobicage_to_messaging_GetConversationAvatarRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_GetConversationAvatarRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_GetConversationAvatarResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *avatar;

+ (MCT_com_mobicage_to_messaging_GetConversationAvatarResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_GetConversationAvatarResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_GetConversationRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *offset;
@property(nonatomic, copy)   NSString *parent_message_key;

+ (MCT_com_mobicage_to_messaging_GetConversationRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_GetConversationRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_GetConversationResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         BOOL      conversation_sent;

+ (MCT_com_mobicage_to_messaging_GetConversationResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_GetConversationResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_LockMessageRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *message_parent_key;

+ (MCT_com_mobicage_to_messaging_LockMessageRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_LockMessageRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_LockMessageResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *members;

+ (MCT_com_mobicage_to_messaging_LockMessageResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_LockMessageResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_MarkMessagesAsReadRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *message_keys;
@property(nonatomic, copy)   NSString *parent_message_key;

+ (MCT_com_mobicage_to_messaging_MarkMessagesAsReadRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_MarkMessagesAsReadRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_MarkMessagesAsReadResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_MarkMessagesAsReadResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_MarkMessagesAsReadResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_MemberStatusTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   acked_timestamp;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *custom_reply;
@property(nonatomic, copy)   NSString *member;
@property(nonatomic)         MCTlong   received_timestamp;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_messaging_MemberStatusTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_MemberStatusTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   acked_timestamp;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *custom_reply;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic, copy)   NSString *member;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic, copy)   NSString *parent_message;
@property(nonatomic)         MCTlong   received_timestamp;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_MemberStatusUpdateResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_MemberStatusUpdateResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_MemberStatusUpdateResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_MessageLockedRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *members;
@property(nonatomic)         MCTlong   dirty_behavior;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;

+ (MCT_com_mobicage_to_messaging_MessageLockedRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_MessageLockedRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_MessageLockedResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_MessageLockedResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_MessageLockedResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_MessageTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *attachments;
@property(nonatomic, strong) NSArray  *buttons;
@property(nonatomic, strong) NSArray  *members;
@property(nonatomic)         MCTlong   alert_flags;
@property(nonatomic, copy)   NSString *branding;
@property(nonatomic, copy)   NSString *broadcast_type;
@property(nonatomic, copy)   NSString *context;
@property(nonatomic)         MCTlong   default_priority;
@property(nonatomic)         BOOL      default_sticky;
@property(nonatomic)         MCTlong   dismiss_button_ui_flags;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic, copy)   NSString *key;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic)         MCTlong   message_type;
@property(nonatomic, copy)   NSString *parent_key;
@property(nonatomic)         MCTlong   priority;
@property(nonatomic, copy)   NSString *sender;
@property(nonatomic)         MCTlong   threadTimestamp;
@property(nonatomic, copy)   NSString *thread_avatar_hash;
@property(nonatomic, copy)   NSString *thread_background_color;
@property(nonatomic)         MCTlong   thread_size;
@property(nonatomic, copy)   NSString *thread_text_color;
@property(nonatomic)         MCTlong   timeout;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_MessageTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_MessageTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_NewMessageRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_MessageTO *message;

+ (MCT_com_mobicage_to_messaging_NewMessageRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_NewMessageRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_NewMessageResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   received_timestamp;

+ (MCT_com_mobicage_to_messaging_NewMessageResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_NewMessageResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_SendMessageRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *attachments;
@property(nonatomic, strong) NSArray  *buttons;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic, strong) NSArray  *members;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic, copy)   NSString *parent_key;
@property(nonatomic)         MCTlong   priority;
@property(nonatomic, copy)   NSString *sender_reply;
@property(nonatomic)         MCTlong   timeout;

+ (MCT_com_mobicage_to_messaging_SendMessageRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_SendMessageRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_SendMessageResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *key;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_SendMessageResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_SendMessageResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_StartFlowRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *attachments_to_dwnl;
@property(nonatomic, strong) NSArray  *brandings_to_dwnl;
@property(nonatomic, copy)   NSString *message_flow_run_id;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic, copy)   NSString *service;
@property(nonatomic, copy)   NSString *static_flow;
@property(nonatomic, copy)   NSString *static_flow_hash;

+ (MCT_com_mobicage_to_messaging_StartFlowRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_StartFlowRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_StartFlowResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_StartFlowResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_StartFlowResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_TransferCompletedRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic, copy)   NSString *result_url;

+ (MCT_com_mobicage_to_messaging_TransferCompletedRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_TransferCompletedRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_TransferCompletedResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_TransferCompletedResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_TransferCompletedResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_UpdateMessageRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   existence;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic)         BOOL      has_existence;
@property(nonatomic)         BOOL      has_flags;
@property(nonatomic, copy)   NSString *last_child_message;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic, copy)   NSString *thread_avatar_hash;
@property(nonatomic, copy)   NSString *thread_background_color;
@property(nonatomic, copy)   NSString *thread_text_color;

+ (MCT_com_mobicage_to_messaging_UpdateMessageRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_UpdateMessageRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_UpdateMessageResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_UpdateMessageResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_UpdateMessageResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_UploadChunkRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *chunk;
@property(nonatomic, copy)   NSString *content_type;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic)         MCTlong   number;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic, copy)   NSString *photo_hash;
@property(nonatomic, copy)   NSString *service_identity_user;
@property(nonatomic)         MCTlong   total_chunks;

+ (MCT_com_mobicage_to_messaging_UploadChunkRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_UploadChunkRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_UploadChunkResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_UploadChunkResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_UploadChunkResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *attachments;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormTO *form;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_MemberStatusTO *member;
@property(nonatomic)         MCTlong   alert_flags;
@property(nonatomic, copy)   NSString *branding;
@property(nonatomic, copy)   NSString *broadcast_type;
@property(nonatomic, copy)   NSString *context;
@property(nonatomic)         MCTlong   default_priority;
@property(nonatomic)         BOOL      default_sticky;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic, copy)   NSString *key;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic)         MCTlong   message_type;
@property(nonatomic, copy)   NSString *parent_key;
@property(nonatomic)         MCTlong   priority;
@property(nonatomic, copy)   NSString *sender;
@property(nonatomic)         MCTlong   threadTimestamp;
@property(nonatomic, copy)   NSString *thread_avatar_hash;
@property(nonatomic, copy)   NSString *thread_background_color;
@property(nonatomic)         MCTlong   thread_size;
@property(nonatomic, copy)   NSString *thread_text_color;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO *widget;
@property(nonatomic, copy)   NSString *javascript_validation;
@property(nonatomic, copy)   NSString *negative_button;
@property(nonatomic)         MCTlong   negative_button_ui_flags;
@property(nonatomic, copy)   NSString *negative_confirmation;
@property(nonatomic, copy)   NSString *positive_button;
@property(nonatomic)         MCTlong   positive_button_ui_flags;
@property(nonatomic, copy)   NSString *positive_confirmation;
@property(nonatomic, copy)   NSString *type;

+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *categories;
@property(nonatomic, copy)   NSString *currency;
@property(nonatomic)         MCTlong   leap_time;

+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *categories;
@property(nonatomic, copy)   NSString *currency;

+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *attachments;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_AutoCompleteFormTO *form;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_MemberStatusTO *member;
@property(nonatomic)         MCTlong   alert_flags;
@property(nonatomic, copy)   NSString *branding;
@property(nonatomic, copy)   NSString *broadcast_type;
@property(nonatomic, copy)   NSString *context;
@property(nonatomic)         MCTlong   default_priority;
@property(nonatomic)         BOOL      default_sticky;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic, copy)   NSString *key;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic)         MCTlong   message_type;
@property(nonatomic, copy)   NSString *parent_key;
@property(nonatomic)         MCTlong   priority;
@property(nonatomic, copy)   NSString *sender;
@property(nonatomic)         MCTlong   threadTimestamp;
@property(nonatomic, copy)   NSString *thread_avatar_hash;
@property(nonatomic, copy)   NSString *thread_background_color;
@property(nonatomic)         MCTlong   thread_size;
@property(nonatomic, copy)   NSString *thread_text_color;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_AutoCompleteFormTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_AutoCompleteTO *widget;
@property(nonatomic, copy)   NSString *javascript_validation;
@property(nonatomic, copy)   NSString *negative_button;
@property(nonatomic)         MCTlong   negative_button_ui_flags;
@property(nonatomic, copy)   NSString *negative_confirmation;
@property(nonatomic, copy)   NSString *positive_button;
@property(nonatomic)         MCTlong   positive_button_ui_flags;
@property(nonatomic, copy)   NSString *positive_confirmation;
@property(nonatomic, copy)   NSString *type;

+ (MCT_com_mobicage_to_messaging_forms_AutoCompleteFormTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_AutoCompleteFormTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_AutoCompleteTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *choices;
@property(nonatomic)         MCTlong   max_chars;
@property(nonatomic, copy)   NSString *place_holder;
@property(nonatomic, strong) NSArray  *suggestions;
@property(nonatomic, copy)   NSString *value;

+ (MCT_com_mobicage_to_messaging_forms_AutoCompleteTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_AutoCompleteTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_ChoiceTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *label;
@property(nonatomic, copy)   NSString *value;

+ (MCT_com_mobicage_to_messaging_forms_ChoiceTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_ChoiceTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *attachments;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_DateSelectFormTO *form;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_MemberStatusTO *member;
@property(nonatomic)         MCTlong   alert_flags;
@property(nonatomic, copy)   NSString *branding;
@property(nonatomic, copy)   NSString *broadcast_type;
@property(nonatomic, copy)   NSString *context;
@property(nonatomic)         MCTlong   default_priority;
@property(nonatomic)         BOOL      default_sticky;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic, copy)   NSString *key;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic)         MCTlong   message_type;
@property(nonatomic, copy)   NSString *parent_key;
@property(nonatomic)         MCTlong   priority;
@property(nonatomic, copy)   NSString *sender;
@property(nonatomic)         MCTlong   threadTimestamp;
@property(nonatomic, copy)   NSString *thread_avatar_hash;
@property(nonatomic, copy)   NSString *thread_background_color;
@property(nonatomic)         MCTlong   thread_size;
@property(nonatomic, copy)   NSString *thread_text_color;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_DateSelectFormTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_DateSelectTO *widget;
@property(nonatomic, copy)   NSString *javascript_validation;
@property(nonatomic, copy)   NSString *negative_button;
@property(nonatomic)         MCTlong   negative_button_ui_flags;
@property(nonatomic, copy)   NSString *negative_confirmation;
@property(nonatomic, copy)   NSString *positive_button;
@property(nonatomic)         MCTlong   positive_button_ui_flags;
@property(nonatomic, copy)   NSString *positive_confirmation;
@property(nonatomic, copy)   NSString *type;

+ (MCT_com_mobicage_to_messaging_forms_DateSelectFormTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_DateSelectFormTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_DateSelectTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   date;
@property(nonatomic)         BOOL      has_date;
@property(nonatomic)         BOOL      has_max_date;
@property(nonatomic)         BOOL      has_min_date;
@property(nonatomic)         MCTlong   max_date;
@property(nonatomic)         MCTlong   min_date;
@property(nonatomic)         MCTlong   minute_interval;
@property(nonatomic, copy)   NSString *mode;
@property(nonatomic, copy)   NSString *unit;

+ (MCT_com_mobicage_to_messaging_forms_DateSelectTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_DateSelectTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *values;

+ (MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTFloat  value;

+ (MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *attachments;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_GPSLocationFormTO *form;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_MemberStatusTO *member;
@property(nonatomic)         MCTlong   alert_flags;
@property(nonatomic, copy)   NSString *branding;
@property(nonatomic, copy)   NSString *broadcast_type;
@property(nonatomic, copy)   NSString *context;
@property(nonatomic)         MCTlong   default_priority;
@property(nonatomic)         BOOL      default_sticky;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic, copy)   NSString *key;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic)         MCTlong   message_type;
@property(nonatomic, copy)   NSString *parent_key;
@property(nonatomic)         MCTlong   priority;
@property(nonatomic, copy)   NSString *sender;
@property(nonatomic)         MCTlong   threadTimestamp;
@property(nonatomic, copy)   NSString *thread_avatar_hash;
@property(nonatomic, copy)   NSString *thread_background_color;
@property(nonatomic)         MCTlong   thread_size;
@property(nonatomic, copy)   NSString *thread_text_color;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_GPSLocationFormTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_GPSLocationTO *widget;
@property(nonatomic, copy)   NSString *javascript_validation;
@property(nonatomic, copy)   NSString *negative_button;
@property(nonatomic)         MCTlong   negative_button_ui_flags;
@property(nonatomic, copy)   NSString *negative_confirmation;
@property(nonatomic, copy)   NSString *positive_button;
@property(nonatomic)         MCTlong   positive_button_ui_flags;
@property(nonatomic, copy)   NSString *positive_confirmation;
@property(nonatomic, copy)   NSString *type;

+ (MCT_com_mobicage_to_messaging_forms_GPSLocationFormTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_GPSLocationFormTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_GPSLocationTO : MCTTransferObject <IJSONable>


@property(nonatomic)         BOOL      gps;

+ (MCT_com_mobicage_to_messaging_forms_GPSLocationTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_GPSLocationTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTFloat  altitude;
@property(nonatomic)         MCTFloat  horizontal_accuracy;
@property(nonatomic)         MCTFloat  latitude;
@property(nonatomic)         MCTFloat  longitude;
@property(nonatomic)         MCTlong   timestamp;
@property(nonatomic)         MCTFloat  vertical_accuracy;

+ (MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   value;

+ (MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *attachments;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_MultiSelectFormTO *form;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_MemberStatusTO *member;
@property(nonatomic)         MCTlong   alert_flags;
@property(nonatomic, copy)   NSString *branding;
@property(nonatomic, copy)   NSString *broadcast_type;
@property(nonatomic, copy)   NSString *context;
@property(nonatomic)         MCTlong   default_priority;
@property(nonatomic)         BOOL      default_sticky;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic, copy)   NSString *key;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic)         MCTlong   message_type;
@property(nonatomic, copy)   NSString *parent_key;
@property(nonatomic)         MCTlong   priority;
@property(nonatomic, copy)   NSString *sender;
@property(nonatomic)         MCTlong   threadTimestamp;
@property(nonatomic, copy)   NSString *thread_avatar_hash;
@property(nonatomic, copy)   NSString *thread_background_color;
@property(nonatomic)         MCTlong   thread_size;
@property(nonatomic, copy)   NSString *thread_text_color;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_MultiSelectFormTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_MultiSelectTO *widget;
@property(nonatomic, copy)   NSString *javascript_validation;
@property(nonatomic, copy)   NSString *negative_button;
@property(nonatomic)         MCTlong   negative_button_ui_flags;
@property(nonatomic, copy)   NSString *negative_confirmation;
@property(nonatomic, copy)   NSString *positive_button;
@property(nonatomic)         MCTlong   positive_button_ui_flags;
@property(nonatomic, copy)   NSString *positive_confirmation;
@property(nonatomic, copy)   NSString *type;

+ (MCT_com_mobicage_to_messaging_forms_MultiSelectFormTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_MultiSelectFormTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_MultiSelectTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *choices;
@property(nonatomic, strong) NSArray  *values;

+ (MCT_com_mobicage_to_messaging_forms_MultiSelectTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_MultiSelectTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *attachments;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_MyDigiPassFormTO *form;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_MemberStatusTO *member;
@property(nonatomic)         MCTlong   alert_flags;
@property(nonatomic, copy)   NSString *branding;
@property(nonatomic, copy)   NSString *broadcast_type;
@property(nonatomic, copy)   NSString *context;
@property(nonatomic)         MCTlong   default_priority;
@property(nonatomic)         BOOL      default_sticky;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic, copy)   NSString *key;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic)         MCTlong   message_type;
@property(nonatomic, copy)   NSString *parent_key;
@property(nonatomic)         MCTlong   priority;
@property(nonatomic, copy)   NSString *sender;
@property(nonatomic)         MCTlong   threadTimestamp;
@property(nonatomic, copy)   NSString *thread_avatar_hash;
@property(nonatomic, copy)   NSString *thread_background_color;
@property(nonatomic)         MCTlong   thread_size;
@property(nonatomic, copy)   NSString *thread_text_color;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_MyDigiPassFormTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_MyDigiPassTO *widget;
@property(nonatomic, copy)   NSString *javascript_validation;
@property(nonatomic, copy)   NSString *negative_button;
@property(nonatomic)         MCTlong   negative_button_ui_flags;
@property(nonatomic, copy)   NSString *negative_confirmation;
@property(nonatomic, copy)   NSString *positive_button;
@property(nonatomic)         MCTlong   positive_button_ui_flags;
@property(nonatomic, copy)   NSString *positive_confirmation;
@property(nonatomic, copy)   NSString *type;

+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassFormTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassFormTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_MyDigiPassTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *scope;

+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_models_properties_forms_MyDigiPassAddress *address;
@property(nonatomic, strong) MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress *eid_address;
@property(nonatomic, strong) MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile *eid_profile;
@property(nonatomic, strong) MCT_com_mobicage_models_properties_forms_MyDigiPassProfile *profile;
@property(nonatomic, copy)   NSString *eid_photo;
@property(nonatomic, copy)   NSString *email;
@property(nonatomic, copy)   NSString *phone;

+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO *form_message;

+ (MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   received_timestamp;

+ (MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO *form_message;

+ (MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   received_timestamp;

+ (MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewDateSelectFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO *form_message;

+ (MCT_com_mobicage_to_messaging_forms_NewDateSelectFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewDateSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewDateSelectFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   received_timestamp;

+ (MCT_com_mobicage_to_messaging_forms_NewDateSelectFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewDateSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO *form_message;

+ (MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   received_timestamp;

+ (MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO *form_message;

+ (MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   received_timestamp;

+ (MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO *form_message;

+ (MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   received_timestamp;

+ (MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO *form_message;

+ (MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   received_timestamp;

+ (MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO *form_message;

+ (MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   received_timestamp;

+ (MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO *form_message;

+ (MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   received_timestamp;

+ (MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO *form_message;

+ (MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   received_timestamp;

+ (MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewTextBlockFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO *form_message;

+ (MCT_com_mobicage_to_messaging_forms_NewTextBlockFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewTextBlockFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewTextBlockFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   received_timestamp;

+ (MCT_com_mobicage_to_messaging_forms_NewTextBlockFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewTextBlockFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewTextLineFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO *form_message;

+ (MCT_com_mobicage_to_messaging_forms_NewTextLineFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewTextLineFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_NewTextLineFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   received_timestamp;

+ (MCT_com_mobicage_to_messaging_forms_NewTextLineFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_NewTextLineFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *attachments;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_PhotoUploadFormTO *form;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_MemberStatusTO *member;
@property(nonatomic)         MCTlong   alert_flags;
@property(nonatomic, copy)   NSString *branding;
@property(nonatomic, copy)   NSString *broadcast_type;
@property(nonatomic, copy)   NSString *context;
@property(nonatomic)         MCTlong   default_priority;
@property(nonatomic)         BOOL      default_sticky;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic, copy)   NSString *key;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic)         MCTlong   message_type;
@property(nonatomic, copy)   NSString *parent_key;
@property(nonatomic)         MCTlong   priority;
@property(nonatomic, copy)   NSString *sender;
@property(nonatomic)         MCTlong   threadTimestamp;
@property(nonatomic, copy)   NSString *thread_avatar_hash;
@property(nonatomic, copy)   NSString *thread_background_color;
@property(nonatomic)         MCTlong   thread_size;
@property(nonatomic, copy)   NSString *thread_text_color;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_PhotoUploadFormTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_PhotoUploadTO *widget;
@property(nonatomic, copy)   NSString *javascript_validation;
@property(nonatomic, copy)   NSString *negative_button;
@property(nonatomic)         MCTlong   negative_button_ui_flags;
@property(nonatomic, copy)   NSString *negative_confirmation;
@property(nonatomic, copy)   NSString *positive_button;
@property(nonatomic)         MCTlong   positive_button_ui_flags;
@property(nonatomic, copy)   NSString *positive_confirmation;
@property(nonatomic, copy)   NSString *type;

+ (MCT_com_mobicage_to_messaging_forms_PhotoUploadFormTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_PhotoUploadFormTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_PhotoUploadTO : MCTTransferObject <IJSONable>


@property(nonatomic)         BOOL      camera;
@property(nonatomic)         BOOL      gallery;
@property(nonatomic, copy)   NSString *quality;
@property(nonatomic, copy)   NSString *ratio;

+ (MCT_com_mobicage_to_messaging_forms_PhotoUploadTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_PhotoUploadTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *attachments;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_RangeSliderFormTO *form;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_MemberStatusTO *member;
@property(nonatomic)         MCTlong   alert_flags;
@property(nonatomic, copy)   NSString *branding;
@property(nonatomic, copy)   NSString *broadcast_type;
@property(nonatomic, copy)   NSString *context;
@property(nonatomic)         MCTlong   default_priority;
@property(nonatomic)         BOOL      default_sticky;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic, copy)   NSString *key;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic)         MCTlong   message_type;
@property(nonatomic, copy)   NSString *parent_key;
@property(nonatomic)         MCTlong   priority;
@property(nonatomic, copy)   NSString *sender;
@property(nonatomic)         MCTlong   threadTimestamp;
@property(nonatomic, copy)   NSString *thread_avatar_hash;
@property(nonatomic, copy)   NSString *thread_background_color;
@property(nonatomic)         MCTlong   thread_size;
@property(nonatomic, copy)   NSString *thread_text_color;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_RangeSliderFormTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_RangeSliderTO *widget;
@property(nonatomic, copy)   NSString *javascript_validation;
@property(nonatomic, copy)   NSString *negative_button;
@property(nonatomic)         MCTlong   negative_button_ui_flags;
@property(nonatomic, copy)   NSString *negative_confirmation;
@property(nonatomic, copy)   NSString *positive_button;
@property(nonatomic)         MCTlong   positive_button_ui_flags;
@property(nonatomic, copy)   NSString *positive_confirmation;
@property(nonatomic, copy)   NSString *type;

+ (MCT_com_mobicage_to_messaging_forms_RangeSliderFormTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_RangeSliderFormTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_RangeSliderTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTFloat  high_value;
@property(nonatomic)         MCTFloat  low_value;
@property(nonatomic)         MCTFloat  max;
@property(nonatomic)         MCTFloat  min;
@property(nonatomic)         MCTlong   precision;
@property(nonatomic)         MCTFloat  step;
@property(nonatomic, copy)   NSString *unit;

+ (MCT_com_mobicage_to_messaging_forms_RangeSliderTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_RangeSliderTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *attachments;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_SingleSelectFormTO *form;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_MemberStatusTO *member;
@property(nonatomic)         MCTlong   alert_flags;
@property(nonatomic, copy)   NSString *branding;
@property(nonatomic, copy)   NSString *broadcast_type;
@property(nonatomic, copy)   NSString *context;
@property(nonatomic)         MCTlong   default_priority;
@property(nonatomic)         BOOL      default_sticky;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic, copy)   NSString *key;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic)         MCTlong   message_type;
@property(nonatomic, copy)   NSString *parent_key;
@property(nonatomic)         MCTlong   priority;
@property(nonatomic, copy)   NSString *sender;
@property(nonatomic)         MCTlong   threadTimestamp;
@property(nonatomic, copy)   NSString *thread_avatar_hash;
@property(nonatomic, copy)   NSString *thread_background_color;
@property(nonatomic)         MCTlong   thread_size;
@property(nonatomic, copy)   NSString *thread_text_color;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SingleSelectFormTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_SingleSelectTO *widget;
@property(nonatomic, copy)   NSString *javascript_validation;
@property(nonatomic, copy)   NSString *negative_button;
@property(nonatomic)         MCTlong   negative_button_ui_flags;
@property(nonatomic, copy)   NSString *negative_confirmation;
@property(nonatomic, copy)   NSString *positive_button;
@property(nonatomic)         MCTlong   positive_button_ui_flags;
@property(nonatomic, copy)   NSString *positive_confirmation;
@property(nonatomic, copy)   NSString *type;

+ (MCT_com_mobicage_to_messaging_forms_SingleSelectFormTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SingleSelectFormTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SingleSelectTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *choices;
@property(nonatomic, copy)   NSString *value;

+ (MCT_com_mobicage_to_messaging_forms_SingleSelectTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SingleSelectTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *attachments;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_SingleSliderFormTO *form;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_MemberStatusTO *member;
@property(nonatomic)         MCTlong   alert_flags;
@property(nonatomic, copy)   NSString *branding;
@property(nonatomic, copy)   NSString *broadcast_type;
@property(nonatomic, copy)   NSString *context;
@property(nonatomic)         MCTlong   default_priority;
@property(nonatomic)         BOOL      default_sticky;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic, copy)   NSString *key;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic)         MCTlong   message_type;
@property(nonatomic, copy)   NSString *parent_key;
@property(nonatomic)         MCTlong   priority;
@property(nonatomic, copy)   NSString *sender;
@property(nonatomic)         MCTlong   threadTimestamp;
@property(nonatomic, copy)   NSString *thread_avatar_hash;
@property(nonatomic, copy)   NSString *thread_background_color;
@property(nonatomic)         MCTlong   thread_size;
@property(nonatomic, copy)   NSString *thread_text_color;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SingleSliderFormTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_SingleSliderTO *widget;
@property(nonatomic, copy)   NSString *javascript_validation;
@property(nonatomic, copy)   NSString *negative_button;
@property(nonatomic)         MCTlong   negative_button_ui_flags;
@property(nonatomic, copy)   NSString *negative_confirmation;
@property(nonatomic, copy)   NSString *positive_button;
@property(nonatomic)         MCTlong   positive_button_ui_flags;
@property(nonatomic, copy)   NSString *positive_confirmation;
@property(nonatomic, copy)   NSString *type;

+ (MCT_com_mobicage_to_messaging_forms_SingleSliderFormTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SingleSliderFormTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SingleSliderTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTFloat  max;
@property(nonatomic)         MCTFloat  min;
@property(nonatomic)         MCTlong   precision;
@property(nonatomic)         MCTFloat  step;
@property(nonatomic, copy)   NSString *unit;
@property(nonatomic)         MCTFloat  value;

+ (MCT_com_mobicage_to_messaging_forms_SingleSliderTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SingleSliderTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *result;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   result;

+ (MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *result;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   result;

+ (MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *result;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   result;

+ (MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *result;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   result;

+ (MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *result;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   result;

+ (MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *result;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   result;

+ (MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *result;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   result;

+ (MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *result;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   result;

+ (MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *result;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   result;

+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *result;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   result;

+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *result;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   result;

+ (MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *result;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   result;

+ (MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *attachments;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_TextBlockFormTO *form;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_MemberStatusTO *member;
@property(nonatomic)         MCTlong   alert_flags;
@property(nonatomic, copy)   NSString *branding;
@property(nonatomic, copy)   NSString *broadcast_type;
@property(nonatomic, copy)   NSString *context;
@property(nonatomic)         MCTlong   default_priority;
@property(nonatomic)         BOOL      default_sticky;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic, copy)   NSString *key;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic)         MCTlong   message_type;
@property(nonatomic, copy)   NSString *parent_key;
@property(nonatomic)         MCTlong   priority;
@property(nonatomic, copy)   NSString *sender;
@property(nonatomic)         MCTlong   threadTimestamp;
@property(nonatomic, copy)   NSString *thread_avatar_hash;
@property(nonatomic, copy)   NSString *thread_background_color;
@property(nonatomic)         MCTlong   thread_size;
@property(nonatomic, copy)   NSString *thread_text_color;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_TextBlockFormTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_TextBlockTO *widget;
@property(nonatomic, copy)   NSString *javascript_validation;
@property(nonatomic, copy)   NSString *negative_button;
@property(nonatomic)         MCTlong   negative_button_ui_flags;
@property(nonatomic, copy)   NSString *negative_confirmation;
@property(nonatomic, copy)   NSString *positive_button;
@property(nonatomic)         MCTlong   positive_button_ui_flags;
@property(nonatomic, copy)   NSString *positive_confirmation;
@property(nonatomic, copy)   NSString *type;

+ (MCT_com_mobicage_to_messaging_forms_TextBlockFormTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_TextBlockFormTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_TextBlockTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   max_chars;
@property(nonatomic, copy)   NSString *place_holder;
@property(nonatomic, copy)   NSString *value;

+ (MCT_com_mobicage_to_messaging_forms_TextBlockTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_TextBlockTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *attachments;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_TextLineFormTO *form;
@property(nonatomic, strong) MCT_com_mobicage_to_messaging_MemberStatusTO *member;
@property(nonatomic)         MCTlong   alert_flags;
@property(nonatomic, copy)   NSString *branding;
@property(nonatomic, copy)   NSString *broadcast_type;
@property(nonatomic, copy)   NSString *context;
@property(nonatomic)         MCTlong   default_priority;
@property(nonatomic)         BOOL      default_sticky;
@property(nonatomic)         MCTlong   flags;
@property(nonatomic, copy)   NSString *key;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic)         MCTlong   message_type;
@property(nonatomic, copy)   NSString *parent_key;
@property(nonatomic)         MCTlong   priority;
@property(nonatomic, copy)   NSString *sender;
@property(nonatomic)         MCTlong   threadTimestamp;
@property(nonatomic, copy)   NSString *thread_avatar_hash;
@property(nonatomic, copy)   NSString *thread_background_color;
@property(nonatomic)         MCTlong   thread_size;
@property(nonatomic, copy)   NSString *thread_text_color;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_TextLineFormTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_TextLineTO *widget;
@property(nonatomic, copy)   NSString *javascript_validation;
@property(nonatomic, copy)   NSString *negative_button;
@property(nonatomic)         MCTlong   negative_button_ui_flags;
@property(nonatomic, copy)   NSString *negative_confirmation;
@property(nonatomic, copy)   NSString *positive_button;
@property(nonatomic)         MCTlong   positive_button_ui_flags;
@property(nonatomic, copy)   NSString *positive_confirmation;
@property(nonatomic, copy)   NSString *type;

+ (MCT_com_mobicage_to_messaging_forms_TextLineFormTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_TextLineFormTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_TextLineTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   max_chars;
@property(nonatomic, copy)   NSString *place_holder;
@property(nonatomic, copy)   NSString *value;

+ (MCT_com_mobicage_to_messaging_forms_TextLineTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_TextLineTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *values;

+ (MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *value;

+ (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *result;
@property(nonatomic)         MCTlong   acked_timestamp;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   received_timestamp;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *result;
@property(nonatomic)         MCTlong   acked_timestamp;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   received_timestamp;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *result;
@property(nonatomic)         MCTlong   acked_timestamp;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   received_timestamp;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *result;
@property(nonatomic)         MCTlong   acked_timestamp;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   received_timestamp;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *result;
@property(nonatomic)         MCTlong   acked_timestamp;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   received_timestamp;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *result;
@property(nonatomic)         MCTlong   acked_timestamp;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   received_timestamp;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *result;
@property(nonatomic)         MCTlong   acked_timestamp;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   received_timestamp;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *result;
@property(nonatomic)         MCTlong   acked_timestamp;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   received_timestamp;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *result;
@property(nonatomic)         MCTlong   acked_timestamp;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   received_timestamp;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *result;
@property(nonatomic)         MCTlong   acked_timestamp;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   received_timestamp;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *result;
@property(nonatomic)         MCTlong   acked_timestamp;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   received_timestamp;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *result;
@property(nonatomic)         MCTlong   acked_timestamp;
@property(nonatomic, copy)   NSString *button_id;
@property(nonatomic, copy)   NSString *message_key;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic)         MCTlong   received_timestamp;
@property(nonatomic)         MCTlong   status;

+ (MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_jsmfr_FlowStartedRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *message_flow_run_id;
@property(nonatomic, copy)   NSString *service;
@property(nonatomic, copy)   NSString *static_flow_hash;
@property(nonatomic, copy)   NSString *thread_key;

+ (MCT_com_mobicage_to_messaging_jsmfr_FlowStartedRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_jsmfr_FlowStartedRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_jsmfr_FlowStartedResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_jsmfr_FlowStartedResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_jsmfr_FlowStartedResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_jsmfr_JsMessageFlowMemberRunTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *hashed_tag;
@property(nonatomic, copy)   NSString *message_flow_run_id;
@property(nonatomic, copy)   NSString *parent_message_key;
@property(nonatomic, copy)   NSString *sender;
@property(nonatomic, copy)   NSString *service_action;

+ (MCT_com_mobicage_to_messaging_jsmfr_JsMessageFlowMemberRunTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_jsmfr_JsMessageFlowMemberRunTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *descriptionX;
@property(nonatomic, copy)   NSString *errorMessage;
@property(nonatomic, copy)   NSString *jsCommand;
@property(nonatomic, copy)   NSString *mobicageVersion;
@property(nonatomic)         MCTlong   platform;
@property(nonatomic, copy)   NSString *platformVersion;
@property(nonatomic, copy)   NSString *stackTrace;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *end_id;
@property(nonatomic, copy)   NSString *message_flow_run_id;
@property(nonatomic, copy)   NSString *parent_message_key;

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_messaging_jsmfr_JsMessageFlowMemberRunTO *run;
@property(nonatomic)         BOOL      email_admins;
@property(nonatomic, strong) NSArray  *emails;
@property(nonatomic, copy)   NSString *end_id;
@property(nonatomic, copy)   NSString *flush_id;
@property(nonatomic, copy)   NSString *message_flow_name;
@property(nonatomic)         BOOL      results_email;

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_models_properties_forms_FormResult *form_result;
@property(nonatomic, copy)   NSString *message_flow_run_id;
@property(nonatomic, copy)   NSString *step_id;

+ (MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageRequestTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageResponseTO *)transferObject;
+ (MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_FindServiceCategoryTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *items;
@property(nonatomic, copy)   NSString *category;
@property(nonatomic, copy)   NSString *cursor;

+ (MCT_com_mobicage_to_service_FindServiceCategoryTO *)transferObject;
+ (MCT_com_mobicage_to_service_FindServiceCategoryTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_FindServiceItemTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *avatar;
@property(nonatomic)         MCTlong   avatar_id;
@property(nonatomic, copy)   NSString *descriptionX;
@property(nonatomic, copy)   NSString *description_branding;
@property(nonatomic, copy)   NSString *detail_text;
@property(nonatomic, copy)   NSString *email;
@property(nonatomic, copy)   NSString *name;
@property(nonatomic, copy)   NSString *qualified_identifier;

+ (MCT_com_mobicage_to_service_FindServiceItemTO *)transferObject;
+ (MCT_com_mobicage_to_service_FindServiceItemTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_FindServiceRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *geo_point;
@property(nonatomic)         MCTlong   avatar_size;
@property(nonatomic, copy)   NSString *cursor;
@property(nonatomic)         MCTlong   organization_type;
@property(nonatomic, copy)   NSString *search_string;

+ (MCT_com_mobicage_to_service_FindServiceRequestTO *)transferObject;
+ (MCT_com_mobicage_to_service_FindServiceRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_FindServiceResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *matches;
@property(nonatomic, copy)   NSString *error_string;

+ (MCT_com_mobicage_to_service_FindServiceResponseTO *)transferObject;
+ (MCT_com_mobicage_to_service_FindServiceResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_GetMenuIconRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *coords;
@property(nonatomic, copy)   NSString *service;
@property(nonatomic)         MCTlong   size;

+ (MCT_com_mobicage_to_service_GetMenuIconRequestTO *)transferObject;
+ (MCT_com_mobicage_to_service_GetMenuIconRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_GetMenuIconResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *icon;
@property(nonatomic, copy)   NSString *iconHash;

+ (MCT_com_mobicage_to_service_GetMenuIconResponseTO *)transferObject;
+ (MCT_com_mobicage_to_service_GetMenuIconResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_GetServiceActionInfoRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *action;
@property(nonatomic)         BOOL      allow_cross_app;
@property(nonatomic, copy)   NSString *code;

+ (MCT_com_mobicage_to_service_GetServiceActionInfoRequestTO *)transferObject;
+ (MCT_com_mobicage_to_service_GetServiceActionInfoRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_GetServiceActionInfoResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_friends_ErrorTO *error;
@property(nonatomic, copy)   NSString *actionDescription;
@property(nonatomic, copy)   NSString *app_id;
@property(nonatomic, copy)   NSString *avatar;
@property(nonatomic)         MCTlong   avatar_id;
@property(nonatomic, copy)   NSString *descriptionX;
@property(nonatomic, copy)   NSString *descriptionBranding;
@property(nonatomic, copy)   NSString *email;
@property(nonatomic, copy)   NSString *name;
@property(nonatomic, copy)   NSString *profileData;
@property(nonatomic, copy)   NSString *qualifiedIdentifier;
@property(nonatomic, copy)   NSString *staticFlow;
@property(nonatomic, strong) NSArray  *staticFlowBrandings;
@property(nonatomic, copy)   NSString *staticFlowHash;
@property(nonatomic)         MCTlong   type;

+ (MCT_com_mobicage_to_service_GetServiceActionInfoResponseTO *)transferObject;
+ (MCT_com_mobicage_to_service_GetServiceActionInfoResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_GetStaticFlowRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *coords;
@property(nonatomic, copy)   NSString *service;
@property(nonatomic, copy)   NSString *staticFlowHash;

+ (MCT_com_mobicage_to_service_GetStaticFlowRequestTO *)transferObject;
+ (MCT_com_mobicage_to_service_GetStaticFlowRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_GetStaticFlowResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *staticFlow;

+ (MCT_com_mobicage_to_service_GetStaticFlowResponseTO *)transferObject;
+ (MCT_com_mobicage_to_service_GetStaticFlowResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_PokeServiceRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *context;
@property(nonatomic, copy)   NSString *email;
@property(nonatomic, copy)   NSString *hashed_tag;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_service_PokeServiceRequestTO *)transferObject;
+ (MCT_com_mobicage_to_service_PokeServiceRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_PokeServiceResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_service_PokeServiceResponseTO *)transferObject;
+ (MCT_com_mobicage_to_service_PokeServiceResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_PressMenuIconRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *context;
@property(nonatomic, strong) NSArray  *coords;
@property(nonatomic)         MCTlong   generation;
@property(nonatomic, copy)   NSString *hashed_tag;
@property(nonatomic, copy)   NSString *message_flow_run_id;
@property(nonatomic, copy)   NSString *service;
@property(nonatomic, copy)   NSString *static_flow_hash;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_service_PressMenuIconRequestTO *)transferObject;
+ (MCT_com_mobicage_to_service_PressMenuIconRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_PressMenuIconResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_service_PressMenuIconResponseTO *)transferObject;
+ (MCT_com_mobicage_to_service_PressMenuIconResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_ReceiveApiCallResultRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *error;
@property(nonatomic)         MCTlong   idX;
@property(nonatomic, copy)   NSString *result;

+ (MCT_com_mobicage_to_service_ReceiveApiCallResultRequestTO *)transferObject;
+ (MCT_com_mobicage_to_service_ReceiveApiCallResultRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_ReceiveApiCallResultResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_service_ReceiveApiCallResultResponseTO *)transferObject;
+ (MCT_com_mobicage_to_service_ReceiveApiCallResultResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_SendApiCallRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *hashed_tag;
@property(nonatomic)         MCTlong   idX;
@property(nonatomic, copy)   NSString *method;
@property(nonatomic, copy)   NSString *params;
@property(nonatomic, copy)   NSString *service;

+ (MCT_com_mobicage_to_service_SendApiCallRequestTO *)transferObject;
+ (MCT_com_mobicage_to_service_SendApiCallRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_SendApiCallResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_service_SendApiCallResponseTO *)transferObject;
+ (MCT_com_mobicage_to_service_SendApiCallResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_ShareServiceRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *recipient;
@property(nonatomic, copy)   NSString *service_email;

+ (MCT_com_mobicage_to_service_ShareServiceRequestTO *)transferObject;
+ (MCT_com_mobicage_to_service_ShareServiceRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_ShareServiceResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_service_ShareServiceResponseTO *)transferObject;
+ (MCT_com_mobicage_to_service_ShareServiceResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_StartServiceActionRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *action;
@property(nonatomic, copy)   NSString *context;
@property(nonatomic, copy)   NSString *email;
@property(nonatomic, copy)   NSString *message_flow_run_id;
@property(nonatomic, copy)   NSString *static_flow_hash;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_service_StartServiceActionRequestTO *)transferObject;
+ (MCT_com_mobicage_to_service_StartServiceActionRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_StartServiceActionResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_service_StartServiceActionResponseTO *)transferObject;
+ (MCT_com_mobicage_to_service_StartServiceActionResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_UpdateUserDataRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *app_data;
@property(nonatomic, copy)   NSString *service;
@property(nonatomic, copy)   NSString *user_data;

+ (MCT_com_mobicage_to_service_UpdateUserDataRequestTO *)transferObject;
+ (MCT_com_mobicage_to_service_UpdateUserDataRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_service_UpdateUserDataResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_service_UpdateUserDataResponseTO *)transferObject;
+ (MCT_com_mobicage_to_service_UpdateUserDataResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_EditProfileRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *access_token;
@property(nonatomic, copy)   NSString *avatar;
@property(nonatomic)         MCTlong   birthdate;
@property(nonatomic, copy)   NSString *extra_fields;
@property(nonatomic)         MCTlong   gender;
@property(nonatomic)         BOOL      has_birthdate;
@property(nonatomic)         BOOL      has_gender;
@property(nonatomic, copy)   NSString *name;

+ (MCT_com_mobicage_to_system_EditProfileRequestTO *)transferObject;
+ (MCT_com_mobicage_to_system_EditProfileRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_EditProfileResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_system_EditProfileResponseTO *)transferObject;
+ (MCT_com_mobicage_to_system_EditProfileResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_ForwardLogsRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *jid;

+ (MCT_com_mobicage_to_system_ForwardLogsRequestTO *)transferObject;
+ (MCT_com_mobicage_to_system_ForwardLogsRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_ForwardLogsResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_system_ForwardLogsResponseTO *)transferObject;
+ (MCT_com_mobicage_to_system_ForwardLogsResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *email;
@property(nonatomic, copy)   NSString *size;

+ (MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO *)transferObject;
+ (MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_GetIdentityQRCodeResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *qrcode;
@property(nonatomic, copy)   NSString *shortUrl;

+ (MCT_com_mobicage_to_system_GetIdentityQRCodeResponseTO *)transferObject;
+ (MCT_com_mobicage_to_system_GetIdentityQRCodeResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_GetIdentityRequestTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_system_GetIdentityRequestTO *)transferObject;
+ (MCT_com_mobicage_to_system_GetIdentityRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_GetIdentityResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_system_IdentityTO *identity;
@property(nonatomic, copy)   NSString *shortUrl;

+ (MCT_com_mobicage_to_system_GetIdentityResponseTO *)transferObject;
+ (MCT_com_mobicage_to_system_GetIdentityResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_HeartBeatRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *SDKVersion;
@property(nonatomic)         MCTlong   appType;
@property(nonatomic, copy)   NSString *buildFingerPrint;
@property(nonatomic, copy)   NSString *deviceModelName;
@property(nonatomic)         BOOL      flushBackLog;
@property(nonatomic, copy)   NSString *localeCountry;
@property(nonatomic, copy)   NSString *localeLanguage;
@property(nonatomic)         MCTlong   majorVersion;
@property(nonatomic)         MCTlong   minorVersion;
@property(nonatomic, copy)   NSString *netCarrierCode;
@property(nonatomic, copy)   NSString *netCarrierName;
@property(nonatomic, copy)   NSString *netCountry;
@property(nonatomic, copy)   NSString *netCountryCode;
@property(nonatomic, copy)   NSString *networkState;
@property(nonatomic, copy)   NSString *product;
@property(nonatomic, copy)   NSString *simCarrierCode;
@property(nonatomic, copy)   NSString *simCarrierName;
@property(nonatomic, copy)   NSString *simCountry;
@property(nonatomic, copy)   NSString *simCountryCode;
@property(nonatomic)         MCTlong   timestamp;
@property(nonatomic, copy)   NSString *timezone;
@property(nonatomic)         MCTlong   timezoneDeltaGMT;

+ (MCT_com_mobicage_to_system_HeartBeatRequestTO *)transferObject;
+ (MCT_com_mobicage_to_system_HeartBeatRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_HeartBeatResponseTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   systemTime;

+ (MCT_com_mobicage_to_system_HeartBeatResponseTO *)transferObject;
+ (MCT_com_mobicage_to_system_HeartBeatResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_IdentityTO : MCTTransferObject <IJSONable>


@property(nonatomic)         MCTlong   avatarId;
@property(nonatomic)         MCTlong   birthdate;
@property(nonatomic, copy)   NSString *email;
@property(nonatomic)         MCTlong   gender;
@property(nonatomic)         BOOL      hasBirthdate;
@property(nonatomic)         BOOL      hasGender;
@property(nonatomic, copy)   NSString *name;
@property(nonatomic, copy)   NSString *profileData;
@property(nonatomic, copy)   NSString *qualifiedIdentifier;

+ (MCT_com_mobicage_to_system_IdentityTO *)transferObject;
+ (MCT_com_mobicage_to_system_IdentityTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_IdentityUpdateRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_system_IdentityTO *identity;

+ (MCT_com_mobicage_to_system_IdentityUpdateRequestTO *)transferObject;
+ (MCT_com_mobicage_to_system_IdentityUpdateRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_IdentityUpdateResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_system_IdentityUpdateResponseTO *)transferObject;
+ (MCT_com_mobicage_to_system_IdentityUpdateResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_LogErrorRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *descriptionX;
@property(nonatomic, copy)   NSString *errorMessage;
@property(nonatomic, copy)   NSString *mobicageVersion;
@property(nonatomic)         MCTlong   platform;
@property(nonatomic, copy)   NSString *platformVersion;
@property(nonatomic)         MCTlong   timestamp;

+ (MCT_com_mobicage_to_system_LogErrorRequestTO *)transferObject;
+ (MCT_com_mobicage_to_system_LogErrorRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_LogErrorResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_system_LogErrorResponseTO *)transferObject;
+ (MCT_com_mobicage_to_system_LogErrorResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_SaveSettingsRequest : MCTTransferObject <IJSONable>


@property(nonatomic)         BOOL      callLogging;
@property(nonatomic)         BOOL      tracking;

+ (MCT_com_mobicage_to_system_SaveSettingsRequest *)transferObject;
+ (MCT_com_mobicage_to_system_SaveSettingsRequest *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_SaveSettingsResponse : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_system_SettingsTO *settings;

+ (MCT_com_mobicage_to_system_SaveSettingsResponse *)transferObject;
+ (MCT_com_mobicage_to_system_SaveSettingsResponse *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_SetMobilePhoneNumberRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *phoneNumber;

+ (MCT_com_mobicage_to_system_SetMobilePhoneNumberRequestTO *)transferObject;
+ (MCT_com_mobicage_to_system_SetMobilePhoneNumberRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_SetMobilePhoneNumberResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_system_SetMobilePhoneNumberResponseTO *)transferObject;
+ (MCT_com_mobicage_to_system_SetMobilePhoneNumberResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_SettingsTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) NSArray  *backgroundFetchTimestamps;
@property(nonatomic)         MCTlong   geoLocationSamplingIntervalBattery;
@property(nonatomic)         MCTlong   geoLocationSamplingIntervalCharging;
@property(nonatomic)         BOOL      geoLocationTracking;
@property(nonatomic)         MCTlong   geoLocationTrackingDays;
@property(nonatomic, strong) NSArray  *geoLocationTrackingTimeslot;
@property(nonatomic)         MCTlong   operatingVersion;
@property(nonatomic)         BOOL      recordGeoLocationWithPhoneCalls;
@property(nonatomic)         BOOL      recordPhoneCalls;
@property(nonatomic)         MCTlong   recordPhoneCallsDays;
@property(nonatomic, strong) NSArray  *recordPhoneCallsTimeslot;
@property(nonatomic)         BOOL      useGPSBattery;
@property(nonatomic)         BOOL      useGPSCharging;
@property(nonatomic)         MCTlong   version;
@property(nonatomic)         BOOL      wifiOnlyDownloads;
@property(nonatomic)         MCTlong   xmppReconnectInterval;

+ (MCT_com_mobicage_to_system_SettingsTO *)transferObject;
+ (MCT_com_mobicage_to_system_SettingsTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_UnregisterMobileRequestTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_system_UnregisterMobileRequestTO *)transferObject;
+ (MCT_com_mobicage_to_system_UnregisterMobileRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_UnregisterMobileResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_system_UnregisterMobileResponseTO *)transferObject;
+ (MCT_com_mobicage_to_system_UnregisterMobileResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *token;

+ (MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenRequestTO *)transferObject;
+ (MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenResponseTO *)transferObject;
+ (MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_UpdateAvailableRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, copy)   NSString *downloadUrl;
@property(nonatomic)         MCTlong   majorVersion;
@property(nonatomic)         MCTlong   minorVersion;
@property(nonatomic, copy)   NSString *releaseNotes;

+ (MCT_com_mobicage_to_system_UpdateAvailableRequestTO *)transferObject;
+ (MCT_com_mobicage_to_system_UpdateAvailableRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_UpdateAvailableResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_system_UpdateAvailableResponseTO *)transferObject;
+ (MCT_com_mobicage_to_system_UpdateAvailableResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_UpdateSettingsRequestTO : MCTTransferObject <IJSONable>


@property(nonatomic, strong) MCT_com_mobicage_to_system_SettingsTO *settings;

+ (MCT_com_mobicage_to_system_UpdateSettingsRequestTO *)transferObject;
+ (MCT_com_mobicage_to_system_UpdateSettingsRequestTO *)transferObjectWithDict:(NSDictionary *)dict;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MCT_com_mobicage_to_system_UpdateSettingsResponseTO : MCTTransferObject <IJSONable>

+ (MCT_com_mobicage_to_system_UpdateSettingsResponseTO *)transferObject;
+ (MCT_com_mobicage_to_system_UpdateSettingsResponseTO *)transferObjectWithDict:(NSDictionary *)dict;

@end
