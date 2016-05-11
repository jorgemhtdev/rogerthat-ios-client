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

#import "MCT_CS_API.h"
#import "MCTComponentFramework.h"


@implementation MCT_com_mobicage_api_activity


+ (void)CS_API_logCallWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_activity_LogCallRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.activity.logCall" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_logLocationsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_activity_LogLocationsRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.activity.logLocations" andArguments:dict andResponseHandler:responseHandler];
    }];
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_api_friends


+ (void)CS_API_ackInvitationByInvitationSecretWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.ackInvitationByInvitationSecret" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_breakFriendShipWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_BreakFriendshipRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.breakFriendShip" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_deleteGroupWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_DeleteGroupRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.deleteGroup" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_findFriendWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_FindFriendRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.findFriend" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_findRogerthatUsersViaEmailWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.findRogerthatUsersViaEmail" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_findRogerthatUsersViaFacebookWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.findRogerthatUsersViaFacebook" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getAvatarWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetAvatarRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.getAvatar" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getCategoryWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetCategoryRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.getCategory" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getFriendWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetFriendRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.getFriend" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getFriendEmailsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetFriendEmailsRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.getFriendEmails" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getFriendInvitationSecretsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetFriendInvitationSecretsRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.getFriendInvitationSecrets" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getFriendsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetFriendsListRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.getFriends" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getGroupAvatarWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetGroupAvatarRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.getGroupAvatar" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getGroupsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetGroupsRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.getGroups" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getUserInfoWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_GetUserInfoRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.getUserInfo" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_inviteWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_InviteFriendRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.invite" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_logInvitationSecretSentWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_LogInvitationSecretSentRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.logInvitationSecretSent" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_putGroupWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_PutGroupRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.putGroup" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_requestShareLocationWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_RequestShareLocationRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.requestShareLocation" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_shareLocationWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_ShareLocationRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.shareLocation" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_userScannedWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_friends_UserScannedRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.friends.userScanned" andArguments:dict andResponseHandler:responseHandler];
    }];
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_api_location


+ (void)CS_API_beaconDiscoveredWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.location.beaconDiscovered" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_beaconInReachWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_location_BeaconInReachRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.location.beaconInReach" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_beaconOutOfReachWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_location_BeaconOutOfReachRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.location.beaconOutOfReach" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getBeaconRegionsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_beacon_GetBeaconRegionsRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.location.getBeaconRegions" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getFriendLocationWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_location_GetFriendLocationRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.location.getFriendLocation" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getFriendLocationsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_location_GetFriendsLocationRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.location.getFriendLocations" andArguments:dict andResponseHandler:responseHandler];
    }];
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_api_messaging


+ (void)CS_API_ackMessageWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_AckMessageRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.ackMessage" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_deleteConversationWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_DeleteConversationRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.deleteConversation" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getConversationWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_GetConversationRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.getConversation" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getConversationAvatarWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_GetConversationAvatarRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.getConversationAvatar" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_lockMessageWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_LockMessageRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.lockMessage" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_markMessagesAsReadWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_MarkMessagesAsReadRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.markMessagesAsRead" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_sendMessageWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_SendMessageRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.sendMessage" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_submitAdvancedOrderFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.submitAdvancedOrderForm" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_submitAutoCompleteFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.submitAutoCompleteForm" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_submitDateSelectFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.submitDateSelectForm" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_submitGPSLocationFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.submitGPSLocationForm" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_submitMultiSelectFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.submitMultiSelectForm" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_submitMyDigiPassFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.submitMyDigiPassForm" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_submitPhotoUploadFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.submitPhotoUploadForm" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_submitRangeSliderFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.submitRangeSliderForm" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_submitSingleSelectFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.submitSingleSelectForm" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_submitSingleSliderFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.submitSingleSliderForm" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_submitTextBlockFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.submitTextBlockForm" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_submitTextLineFormWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.submitTextLineForm" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_uploadChunkWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_UploadChunkRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.uploadChunk" andArguments:dict andResponseHandler:responseHandler];
    }];
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_api_messaging_jsmfr


+ (void)CS_API_flowStartedWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_jsmfr_FlowStartedRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.jsmfr.flowStarted" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_messageFlowErrorWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.jsmfr.messageFlowError" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_messageFlowFinishedWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.jsmfr.messageFlowFinished" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_messageFlowMemberResultWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.jsmfr.messageFlowMemberResult" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_newFlowMessageWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.messaging.jsmfr.newFlowMessage" andArguments:dict andResponseHandler:responseHandler];
    }];
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_api_services


+ (void)CS_API_findServiceWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_FindServiceRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.services.findService" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getActionInfoWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_GetServiceActionInfoRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.services.getActionInfo" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getMenuIconWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_GetMenuIconRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.services.getMenuIcon" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getStaticFlowWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_GetStaticFlowRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.services.getStaticFlow" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_pokeServiceWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_PokeServiceRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.services.pokeService" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_pressMenuItemWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_PressMenuIconRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.services.pressMenuItem" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_sendApiCallWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_SendApiCallRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.services.sendApiCall" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_shareServiceWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_ShareServiceRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.services.shareService" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_startActionWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_StartServiceActionRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.services.startAction" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_updateUserDataWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_service_UpdateUserDataRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.services.updateUserData" andArguments:dict andResponseHandler:responseHandler];
    }];
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_api_system


+ (void)CS_API_editProfileWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_EditProfileRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.system.editProfile" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getIdentityWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_GetIdentityRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.system.getIdentity" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getIdentityQRCodeWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.system.getIdentityQRCode" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_getJsEmbeddingWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_js_embedding_GetJSEmbeddingRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.system.getJsEmbedding" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_heartBeatWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_HeartBeatRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.system.heartBeat" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_logErrorWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_LogErrorRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.system.logError" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_saveSettingsWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_SaveSettingsRequest *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.system.saveSettings" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_setMobilePhoneNumberWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_SetMobilePhoneNumberRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.system.setMobilePhoneNumber" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_unregisterMobileWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_UnregisterMobileRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.system.unregisterMobile" andArguments:dict andResponseHandler:responseHandler];
    }];
}


+ (void)CS_API_updateApplePushDeviceTokenWithResponseHandler:(MCTAbstractResponseHandler *)responseHandler andRequest:(MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenRequestTO *)request
{
    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setDict:[request dictRepresentation] forKey:@"request"];

        [[MCTComponentFramework protocol] callToServerWithFunction:@"com.mobicage.api.system.updateApplePushDeviceToken" andArguments:dict andResponseHandler:responseHandler];
    }];
}

@end

///////////////////////////////////////////////////////////////////////////////////
