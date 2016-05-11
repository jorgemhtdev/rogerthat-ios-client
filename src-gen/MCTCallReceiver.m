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

#import "MCTCallReceiver.h"
#import "MCTJSONUtils.h"

@implementation MCTCallReceiver

@synthesize com_mobicage_capi_friends_IClientRPC_instance = com_mobicage_capi_friends_IClientRPC_instance_;

@synthesize com_mobicage_capi_location_IClientRPC_instance = com_mobicage_capi_location_IClientRPC_instance_;

@synthesize com_mobicage_capi_messaging_IClientRPC_instance = com_mobicage_capi_messaging_IClientRPC_instance_;

@synthesize com_mobicage_capi_services_IClientRPC_instance = com_mobicage_capi_services_IClientRPC_instance_;

@synthesize com_mobicage_capi_system_IClientRPC_instance = com_mobicage_capi_system_IClientRPC_instance_;


- (id<IJSONable>)processIncomingCall:(MCTRPCCall *)call
{
    NSDictionary *dict = call.arguments;
    NSRange match;

    match = [call.function rangeOfString:@"com.mobicage.capi.friends."];
    if (match.location == 0) {

        if ([call.function isEqualToString:@"com.mobicage.capi.friends.becameFriends"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_friends_BecameFriendsRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_friends_BecameFriendsRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_friends_IClientRPC_instance SC_API_becameFriendsWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.friends.updateFriend"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_friends_UpdateFriendRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_friends_UpdateFriendRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_friends_IClientRPC_instance SC_API_updateFriendWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.friends.updateFriendSet"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_friends_UpdateFriendSetRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_friends_UpdateFriendSetRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_friends_IClientRPC_instance SC_API_updateFriendSetWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.friends.updateGroups"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_friends_UpdateGroupsRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_friends_UpdateGroupsRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_friends_IClientRPC_instance SC_API_updateGroupsWithRequest:request];
        }

        goto processIncomingCallError;

    }

    match = [call.function rangeOfString:@"com.mobicage.capi.location."];
    if (match.location == 0) {

        if ([call.function isEqualToString:@"com.mobicage.capi.location.deleteBeaconDiscovery"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_location_DeleteBeaconDiscoveryRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_location_DeleteBeaconDiscoveryRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_location_IClientRPC_instance SC_API_deleteBeaconDiscoveryWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.location.getLocation"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_location_GetLocationRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_location_GetLocationRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_location_IClientRPC_instance SC_API_getLocationWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.location.locationResult"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_location_LocationResultRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_location_LocationResultRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_location_IClientRPC_instance SC_API_locationResultWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.location.trackLocation"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_location_TrackLocationRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_location_TrackLocationRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_location_IClientRPC_instance SC_API_trackLocationWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.location.updateBeaconRegions"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_beacon_UpdateBeaconRegionsRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_beacon_UpdateBeaconRegionsRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_location_IClientRPC_instance SC_API_updateBeaconRegionsWithRequest:request];
        }

        goto processIncomingCallError;

    }

    match = [call.function rangeOfString:@"com.mobicage.capi.messaging."];
    if (match.location == 0) {

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.conversationDeleted"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_ConversationDeletedRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_ConversationDeletedRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_conversationDeletedWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.endMessageFlow"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_EndMessageFlowRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_EndMessageFlowRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_endMessageFlowWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.messageLocked"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_MessageLockedRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_MessageLockedRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_messageLockedWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.newAdvancedOrderForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_newAdvancedOrderFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.newAutoCompleteForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_newAutoCompleteFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.newDateSelectForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_NewDateSelectFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_NewDateSelectFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_newDateSelectFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.newGPSLocationForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_newGPSLocationFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.newMessage"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_NewMessageRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_NewMessageRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_newMessageWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.newMultiSelectForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_newMultiSelectFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.newMyDigiPassForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_newMyDigiPassFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.newPhotoUploadForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_newPhotoUploadFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.newRangeSliderForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_newRangeSliderFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.newSingleSelectForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_newSingleSelectFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.newSingleSliderForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_newSingleSliderFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.newTextBlockForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_NewTextBlockFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_NewTextBlockFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_newTextBlockFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.newTextLineForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_NewTextLineFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_NewTextLineFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_newTextLineFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.startFlow"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_StartFlowRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_StartFlowRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_startFlowWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.transferCompleted"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_TransferCompletedRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_TransferCompletedRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_transferCompletedWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.updateAdvancedOrderForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_updateAdvancedOrderFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.updateAutoCompleteForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_updateAutoCompleteFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.updateDateSelectForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_updateDateSelectFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.updateGPSLocationForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_updateGPSLocationFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.updateMessage"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_UpdateMessageRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_UpdateMessageRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_updateMessageWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.updateMessageMemberStatus"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_updateMessageMemberStatusWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.updateMultiSelectForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_updateMultiSelectFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.updateMyDigiPassForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_updateMyDigiPassFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.updatePhotoUploadForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_updatePhotoUploadFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.updateRangeSliderForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_updateRangeSliderFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.updateSingleSelectForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_updateSingleSelectFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.updateSingleSliderForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_updateSingleSliderFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.updateTextBlockForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_updateTextBlockFormWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.messaging.updateTextLineForm"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_messaging_IClientRPC_instance SC_API_updateTextLineFormWithRequest:request];
        }

        goto processIncomingCallError;

    }

    match = [call.function rangeOfString:@"com.mobicage.capi.services."];
    if (match.location == 0) {

        if ([call.function isEqualToString:@"com.mobicage.capi.services.receiveApiCallResult"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_service_ReceiveApiCallResultRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_service_ReceiveApiCallResultRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_services_IClientRPC_instance SC_API_receiveApiCallResultWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.services.updateUserData"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_service_UpdateUserDataRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_service_UpdateUserDataRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_services_IClientRPC_instance SC_API_updateUserDataWithRequest:request];
        }

        goto processIncomingCallError;

    }

    match = [call.function rangeOfString:@"com.mobicage.capi.system."];
    if (match.location == 0) {

        if ([call.function isEqualToString:@"com.mobicage.capi.system.forwardLogs"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_system_ForwardLogsRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_system_ForwardLogsRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_system_IClientRPC_instance SC_API_forwardLogsWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.system.identityUpdate"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_system_IdentityUpdateRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_system_IdentityUpdateRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_system_IClientRPC_instance SC_API_identityUpdateWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.system.unregisterMobile"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_system_UnregisterMobileRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_system_UnregisterMobileRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_system_IClientRPC_instance SC_API_unregisterMobileWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.system.updateAvailable"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_system_UpdateAvailableRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_system_UpdateAvailableRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_system_IClientRPC_instance SC_API_updateAvailableWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.system.updateJsEmbedding"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_system_IClientRPC_instance SC_API_updateJsEmbeddingWithRequest:request];
        }

        if ([call.function isEqualToString:@"com.mobicage.capi.system.updateSettings"]) {

            NSDictionary *tmp_dict_0 = [dict dictForKey:@"request"];
            MCT_com_mobicage_to_system_UpdateSettingsRequestTO *request;
            if (tmp_dict_0 == nil)
                goto processIncomingCallError;
            if (tmp_dict_0 == MCTNull)
                request = nil;
            else {
                request = [MCT_com_mobicage_to_system_UpdateSettingsRequestTO transferObjectWithDict:tmp_dict_0];
                if (request == nil)
                    goto processIncomingCallError;
            }

            return [self.com_mobicage_capi_system_IClientRPC_instance SC_API_updateSettingsWithRequest:request];
        }

        goto processIncomingCallError;

    }


processIncomingCallError:
    ERROR(@"Cannot process incoming call %@ for callid %@", call.function, call.callid);
    return nil;
}

@end
