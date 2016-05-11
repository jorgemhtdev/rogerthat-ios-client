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
#import "MCTEncoding.h"
#import "MCTFriendsPlugin.h"
#import "MCTFriendStore.h"
#import "MCTFriend.h"
#import "MCTGetFriendCategoryRH.h"
#import "MCTIntent.h"
#import "MCTJSONUtils.h"
#import "MCTOperation.h"
#import "MCTServiceMenuItem.h"
#import "MCTGroup.h"

#import "GTMNSData+zlib.h"
#import "NSData+Base64.h"
#import "UIImage+Resize.h"

@interface MCTFriendStore ()

@property (nonatomic, strong) NSCache *friendCache;

- (BOOL)initPreparedStatements;
- (void)destroyPreparedStatements;
- (MCTlong)friendSetVersion;
- (BOOL)updateFriendSetVersion:(MCTlong)version;
- (BOOL)insertFriend:(MCT_com_mobicage_to_friends_FriendTO *)friend withExistence:(MCTFriendExistence)existence;
- (void)updateEmailHashForFriend:(NSString *)email withFriendType:(MCTFriendType)friendType;

- (MCTFriend *)friendWithStatement:(sqlite3_stmt *)stmt;

- (void)operationRebuildServiceMenuWithFriend:(MCT_com_mobicage_to_friends_FriendTO *)friend cleanup:(BOOL)cleanup;
- (BOOL)isMenuIconAvailableWithHash:(NSString *)hash;
- (void)operationScrubMenuIcons;
- (void)operationDeleteMenuIconWithHash:(NSString *)iconHash;
- (void)operationDeleteAllServiceMenus;
- (BOOL)isStaticFlowAvailableWithHash:(NSString *)hash;
- (void)operationScrubStaticFlows;
- (void)operationDeleteStaticFlowWithHash:(NSString *)hash;
- (void)operationDeleteServiceMenuForFriendEmail:(NSString *)friendEmail;

- (void)addFriendToCache:(MCTFriend *)friend;
- (void)addNonFriendToCacheWithEmail:(NSString *)email;
- (MCTFriend *)getFriendFromCache:(NSString *)email;
- (void)removeFriendFromCache:(NSString *)email;

@end


@implementation MCTFriendStore


static sqlite3_stmt *stmtCountFriendsByTypeUI_;
static sqlite3_stmt *stmtCountServices_;
static sqlite3_stmt *stmtCountFriendsByCategory_;
static sqlite3_stmt *stmtCountFriendsSharingLocation_;
static sqlite3_stmt *stmtCountFriendsUI_;
static sqlite3_stmt *stmtGetFriendByEmailUI_;
static sqlite3_stmt *stmtGetFriendByEmailHashUI_;
static sqlite3_stmt *stmtGetFriendByIndexUI_;
static sqlite3_stmt *stmtGetFriendByTypeAndIndexUI_;
static sqlite3_stmt *stmtGetFriendAvatarByEmailUI_;
static sqlite3_stmt *stmtGetFriendTypeByEmailUI_;
static sqlite3_stmt *stmtGetFriendNamesUI_;
static sqlite3_stmt *stmtGetServicesByIndex_;
static sqlite3_stmt *stmtGetFriendByCategoryAndIndex_;

static sqlite3_stmt *stmtCountServicesGroupedByOrganizationType_;
static sqlite3_stmt *stmtCountServicesByOrganizationType_;
static sqlite3_stmt *stmtGetServicesByIndexAndOrganizationType_;
static sqlite3_stmt *stmtGetServicesByOrganizationType_;

static sqlite3_stmt *stmtDeleteFriendCOMM_;
static sqlite3_stmt *stmtGetFriendEmailsCOMM_;
static sqlite3_stmt *stmtGetFriendEmailsByType_;
static sqlite3_stmt *stmtInsertFriendCOMM_;
static sqlite3_stmt *stmtUpdateEmailHashCOMM_;
static sqlite3_stmt *stmtUpdateExistenceCOMM_;
static sqlite3_stmt *stmtUpdateExistenceAndClearVersionCOMM_;
static sqlite3_stmt *stmtUpdateFriendInfo_;
static sqlite3_stmt *stmtUpdateFriendCOMM_;
static sqlite3_stmt *stmtUpdateFriendAvatarCOMM_;
static sqlite3_stmt *stmtUpdateShareMyLocationCOMM_;
static sqlite3_stmt *stmtFriendisFriend_;
static sqlite3_stmt *stmtGetFriendExistence_;
static sqlite3_stmt *stmtGetFriendVersions_;
static sqlite3_stmt *stmtFriendSetVersionGet_;
static sqlite3_stmt *stmtFriendSetVersionSet_;
static sqlite3_stmt *stmtFriendSetDeleteFrom_;
static sqlite3_stmt *stmtFriendSetInsertInto_;
static sqlite3_stmt *stmtFriendSetContains_;
static sqlite3_stmt *stmtFriendSetGet_;

static sqlite3_stmt *stmtCountInvitationSecrets_;
static sqlite3_stmt *stmtDeleteInvitationSecret_;
static sqlite3_stmt *stmtGetInvitationSecret_;
static sqlite3_stmt *stmtInsertInvitationSecret_;
static sqlite3_stmt *stmtGetPendingInvitations_;
static sqlite3_stmt *stmtInsertPendingInvitation_;
static sqlite3_stmt *stmtRemovePendingInvitation_;

static sqlite3_stmt *stmtCheckMenuIconAvailable_;
static sqlite3_stmt *stmtDeleteAllServiceMenus_;
static sqlite3_stmt *stmtDeleteMenuIcon_;
static sqlite3_stmt *stmtDeleteServiceMenu_;
static sqlite3_stmt *stmtInsertMenuIcon_;
static sqlite3_stmt *stmtInsertServiceMenu_;
static sqlite3_stmt *stmtGetMenu_;
static sqlite3_stmt *stmtGetMenuDetails_;
static sqlite3_stmt *stmtGetMenuIconUsage_;

static sqlite3_stmt *stmtDataGet_;

static sqlite3_stmt *stmtCategoryExists_;
static sqlite3_stmt *stmtCategoryInsert_;

static sqlite3_stmt *stmtStaticFlowGet_;
static sqlite3_stmt *stmtStaticFlowCheckAvailable_;
static sqlite3_stmt *stmtStaticFlowInsert_;
static sqlite3_stmt *stmtStaticFlowGetUsage_;
static sqlite3_stmt *stmtStaticFlowDelete_;

static sqlite3_stmt *stmtServiceApiCallInsert_;
static sqlite3_stmt *stmtServiceApiCallSetResult_;
static sqlite3_stmt *stmtServiceApiCallRemove_;
static sqlite3_stmt *stmtServiceApiCallGetById_;
static sqlite3_stmt *stmtServiceApiCallGetByItem_;
static sqlite3_stmt *stmtUpdateServiceUserData_;
static sqlite3_stmt *stmtUpdateServiceAppData_;
static sqlite3_stmt *stmtUpdateServiceData_;

static sqlite3_stmt *stmtGetFriendBroadcastInfo_;

static sqlite3_stmt *stmtGetGroup_;
static sqlite3_stmt *stmtGetGroups_;
static sqlite3_stmt *stmtInsertGroup_;
static sqlite3_stmt *stmtUpdateGroup_;
static sqlite3_stmt *stmtDeleteGroup_;
static sqlite3_stmt *stmtDeleteGroupMembers_;
static sqlite3_stmt *stmtInsertGroupMember_;
static sqlite3_stmt *stmtDeleteGroupMember_;
static sqlite3_stmt *stmtClearGroup_;
static sqlite3_stmt *stmtClearEmptyGroup_;
static sqlite3_stmt *stmtClearGroupMember_;
static sqlite3_stmt *stmtClearGroupMemberByEmail_;
static sqlite3_stmt *stmtInsertGroupAvatar_;
static sqlite3_stmt *stmtInsertGroupAvatarHash_;

- (MCTFriendStore *)init
{
    T_BIZZ();
    if (self = [super init]) {
        if (![self initPreparedStatements]) {
            ERROR(@"Error preparing FriendStore SQL statements");
            self = nil;
        }
        self.friendCache = [[NSCache alloc] init];
        self.friendCache.name = @"FriendCache";
        self.friendCache.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    T_BIZZ();
    HERE();
    [self destroyPreparedStatements];
}

- (BOOL)initPreparedStatements
{
    T_BIZZ();
    [self dbLockedOperationWithBlock:^{
        [self prepareStatement:&stmtCountFriendsByTypeUI_
                  withQueryKey:@"sql_friend_count_by_type"];

        [self prepareStatement:&stmtCountServices_
                  withQueryKey:@"sql_services_count"];

        [self prepareStatement:&stmtCountFriendsByCategory_
                  withQueryKey:@"sql_friend_count_by_category"];

        [self prepareStatement:&stmtCountFriendsSharingLocation_
                  withQueryKey:@"sql_friend_count_friends_sharing_location"];

        [self prepareStatement:&stmtCountFriendsUI_
                  withQueryKey:@"sql_friend_count"];

        [self prepareStatement:&stmtGetFriendByEmailUI_
                  withQueryKey:@"sql_friend_get_by_email_ios"];

        [self prepareStatement:&stmtGetFriendByEmailHashUI_
                  withQueryKey:@"sql_friend_get_by_email_hash"];

        [self prepareStatement:&stmtGetFriendByIndexUI_
                  withQueryKey:@"sql_friend_get_by_index"];

        [self prepareStatement:&stmtGetFriendByTypeAndIndexUI_
                  withQueryKey:@"sql_friend_get_by_type_and_index"];

        [self prepareStatement:&stmtGetFriendAvatarByEmailUI_
                  withQueryKey:@"sql_friend_get_avatar_by_email"];

        [self prepareStatement:&stmtGetFriendTypeByEmailUI_
                  withQueryKey:@"sql_friend_get_type_by_email"];

        [self prepareStatement:&stmtGetFriendNamesUI_
                  withQueryKey:@"sql_friend_get_names"];

        [self prepareStatement:&stmtGetServicesByIndex_
                  withQueryKey:@"sql_services_get_by_index"];

        [self prepareStatement:&stmtGetFriendByCategoryAndIndex_
                  withQueryKey:@"sql_friend_get_by_category_and_index"];

        [self prepareStatement:&stmtCountServicesByOrganizationType_
                  withQueryKey:@"sql_services_count_by_organization_type"];

        [self prepareStatement:&stmtCountServicesGroupedByOrganizationType_
                  withQueryKey:@"sql_services_count_grouped_by_organization_type"];

        [self prepareStatement:&stmtGetServicesByIndexAndOrganizationType_
                  withQueryKey:@"sql_services_get_by_index_and_organization_type"];

        [self prepareStatement:&stmtGetServicesByOrganizationType_
                  withQueryKey:@"sql_services_get_organization_type"];

        [self prepareStatement:&stmtDeleteFriendCOMM_
                 withQueryKey:@"sql_friend_delete"];

        [self prepareStatement:&stmtGetFriendEmailsCOMM_
                  withQueryKey:@"sql_friend_get_emails"];

        [self prepareStatement:&stmtGetFriendEmailsByType_
                  withQueryKey:@"sql_friend_get_emails_by_type"];

        [self prepareStatement:&stmtInsertFriendCOMM_
                  withQueryKey:@"sql_friend_insert"];

        [self prepareStatement:&stmtUpdateEmailHashCOMM_
                  withQueryKey:@"sql_friend_update_email_hash"];

        [self prepareStatement:&stmtUpdateExistenceCOMM_
                  withQueryKey:@"sql_friend_update_existence"];

        [self prepareStatement:&stmtUpdateExistenceAndClearVersionCOMM_
                  withQueryKey:@"sql_friend_update_existence_and_clear_version"];

        [self prepareStatement:&stmtUpdateFriendCOMM_
                  withQueryKey:@"sql_friend_update"];

        [self prepareStatement:&stmtUpdateFriendInfo_
                  withQueryKey:@"sql_friend_update_info"];

        [self prepareStatement:&stmtUpdateFriendAvatarCOMM_
                  withQueryKey:@"sql_friend_update_avatar"];

        [self prepareStatement:&stmtUpdateShareMyLocationCOMM_
                  withQueryKey:@"sql_friend_update_share_location"];

        [self prepareStatement:&stmtCountInvitationSecrets_
                  withQueryKey:@"sql_friend_invitation_secret_count"];

        [self prepareStatement:&stmtDeleteInvitationSecret_
                  withQueryKey:@"sql_friend_invitation_secret_delete"];

        [self prepareStatement:&stmtGetInvitationSecret_
                  withQueryKey:@"sql_friend_invitation_secret_get"];

        [self prepareStatement:&stmtInsertInvitationSecret_
                  withQueryKey:@"sql_friend_invitation_secret_insert"];

        [self prepareStatement:&stmtGetPendingInvitations_
                  withQueryKey:@"sql_friend_pending_invitation_list"];

        [self prepareStatement:&stmtInsertPendingInvitation_
                  withQueryKey:@"sql_friend_pending_invitation_insert"];

        [self prepareStatement:&stmtRemovePendingInvitation_
                  withQueryKey:@"sql_friend_pending_invitation_remove"];

        [self prepareStatement:&stmtFriendisFriend_
                  withQueryKey:@"sql_friend_is_friend"];

        [self prepareStatement:&stmtGetFriendExistence_
                  withQueryKey:@"sql_friend_get_existence"];

        [self prepareStatement:&stmtGetFriendVersions_
                  withQueryKey:@"sql_friend_get_versions"];

        [self prepareStatement:&stmtFriendSetVersionGet_
                  withQueryKey:@"sql_friendset_version_get"];

        [self prepareStatement:&stmtFriendSetVersionSet_
                  withQueryKey:@"sql_friendset_version_set"];

        [self prepareStatement:&stmtFriendSetDeleteFrom_
                  withQueryKey:@"sql_friendset_delete_from"];

        [self prepareStatement:&stmtFriendSetInsertInto_
                  withQueryKey:@"sql_friendset_insert_into"];

        [self prepareStatement:&stmtFriendSetContains_
                  withQueryKey:@"sql_friendset_contains"];

        [self prepareStatement:&stmtFriendSetGet_
                  withQueryKey:@"sql_friendset_get"];

        // Service menu
        [self prepareStatement:&stmtCheckMenuIconAvailable_
                  withQueryKey:@"sql_friend_check_menu_icon_available"];

        [self prepareStatement:&stmtDeleteAllServiceMenus_
                  withQueryKey:@"sql_friend_clear_all_service_menu"];

        [self prepareStatement:&stmtDeleteMenuIcon_
                  withQueryKey:@"sql_friend_delete_menu_icon"];

        [self prepareStatement:&stmtDeleteServiceMenu_
                  withQueryKey:@"sql_friend_delete_service_menu"];

        [self prepareStatement:&stmtInsertMenuIcon_
                  withQueryKey:@"sql_friend_insert_menu_icon"];

        [self prepareStatement:&stmtInsertServiceMenu_
                  withQueryKey:@"sql_friend_insert_service_menu"];

        [self prepareStatement:&stmtGetMenu_
                  withQueryKey:@"sql_friend_get_full_menu"];

        [self prepareStatement:&stmtGetMenuDetails_
                  withQueryKey:@"sql_friend_get_menu_details"];

        [self prepareStatement:&stmtGetMenuIconUsage_
                  withQueryKey:@"sql_friend_menu_icon_usage"];

        [self prepareStatement:&stmtDataGet_
                  withQueryKey:@"sql_friend_data_get"];

        [self prepareStatement:&stmtCategoryExists_
                  withQueryKey:@"sql_friend_category_exists"];

        [self prepareStatement:&stmtCategoryInsert_
                  withQueryKey:@"sql_friend_category_insert"];

        [self prepareStatement:&stmtStaticFlowGet_
                  withQueryKey:@"sql_friend_static_flow_get"];

        [self prepareStatement:&stmtStaticFlowCheckAvailable_
                  withQueryKey:@"sql_friend_static_flow_check_available"];

        [self prepareStatement:&stmtStaticFlowInsert_
                  withQueryKey:@"sql_friend_static_flow_insert"];

        [self prepareStatement:&stmtStaticFlowGetUsage_
                  withQueryKey:@"sql_friend_static_flow_usage"];

        [self prepareStatement:&stmtStaticFlowDelete_
                  withQueryKey:@"sql_friend_static_flow_delete"];

        // rogerthat js api
        [self prepareStatement:&stmtServiceApiCallGetById_
                  withQueryKey:@"sql_service_api_call_get_by_id"];

        [self prepareStatement:&stmtServiceApiCallGetByItem_
                  withQueryKey:@"sql_service_api_call_get_results"];

        [self prepareStatement:&stmtServiceApiCallInsert_
                  withQueryKey:@"sql_service_api_call_insert"];

        [self prepareStatement:&stmtServiceApiCallRemove_
                  withQueryKey:@"sql_service_api_call_remove"];

        [self prepareStatement:&stmtServiceApiCallSetResult_
                  withQueryKey:@"sql_service_api_call_set_result"];

        [self prepareStatement:&stmtUpdateServiceUserData_
                  withQueryKey:@"sql_friend_set_user_data"];

        [self prepareStatement:&stmtUpdateServiceAppData_
                  withQueryKey:@"sql_friend_set_app_data"];

        [self prepareStatement:&stmtUpdateServiceData_
                  withQueryKey:@"sql_friend_set_data"];


        [self prepareStatement:&stmtGetFriendBroadcastInfo_
                  withQueryKey:@"sql_friend_get_broadcast_flow_for_mfr"];

        // groups
        [self prepareStatement:&stmtGetGroup_
                  withQueryKey:@"sql_get_group"];

        [self prepareStatement:&stmtGetGroups_
                  withQueryKey:@"sql_get_groups"];

        [self prepareStatement:&stmtInsertGroup_
                  withQueryKey:@"sql_insert_group"];

        [self prepareStatement:&stmtUpdateGroup_
                  withQueryKey:@"sql_update_group"];

        [self prepareStatement:&stmtDeleteGroup_
                  withQueryKey:@"sql_delete_group"];

        [self prepareStatement:&stmtDeleteGroupMembers_
                  withQueryKey:@"sql_delete_group_members"];

        [self prepareStatement:&stmtInsertGroupMember_
                  withQueryKey:@"sql_insert_group_member"];

        [self prepareStatement:&stmtDeleteGroupMember_
                  withQueryKey:@"sql_delete_group_member"];

        [self prepareStatement:&stmtClearGroup_
                  withQueryKey:@"sql_clear_group"];

        [self prepareStatement:&stmtClearEmptyGroup_
                  withQueryKey:@"sql_clear_empty_group"];

        [self prepareStatement:&stmtClearGroupMember_
                  withQueryKey:@"sql_clear_group_member"];

        [self prepareStatement:&stmtClearGroupMemberByEmail_
                  withQueryKey:@"sql_clear_group_member_by_email"];

        [self prepareStatement:&stmtInsertGroupAvatar_
                  withQueryKey:@"sql_insert_group_avatar"];

        [self prepareStatement:&stmtInsertGroupAvatarHash_
                  withQueryKey:@"sql_insert_group_avatar_hash"];

    }];

    return YES;
}

- (void)destroyPreparedStatements
{
    T_BIZZ();
    [self dbLockedOperationWithBlock:^{
        [self finalizeStatement:stmtCountFriendsByTypeUI_
                   withQueryKey:@"sql_friend_count_by_type"];

        [self finalizeStatement:stmtCountServices_
                   withQueryKey:@"sql_services_count"];

        [self finalizeStatement:stmtCountFriendsByCategory_
                   withQueryKey:@"sql_friend_count_by_category"];

        [self finalizeStatement:stmtCountFriendsSharingLocation_
                   withQueryKey:@"sql_friend_count_friends_sharing_location"];

        [self finalizeStatement:stmtCountFriendsUI_
                   withQueryKey:@"sql_friend_count"];

        [self finalizeStatement:stmtGetFriendByEmailUI_
                   withQueryKey:@"sql_friend_get_by_email_ios"];

        [self finalizeStatement:stmtGetFriendByEmailHashUI_
                   withQueryKey:@"sql_friend_get_by_email_hash"];

        [self finalizeStatement:stmtGetFriendByIndexUI_
                   withQueryKey:@"sql_friend_get_by_index"];

        [self finalizeStatement:stmtGetFriendByTypeAndIndexUI_
                   withQueryKey:@"sql_friend_get_by_type_and_index"];

        [self finalizeStatement:stmtGetFriendAvatarByEmailUI_
                   withQueryKey:@"sql_friend_get_avatar_by_email"];

        [self finalizeStatement:stmtGetFriendTypeByEmailUI_
                   withQueryKey:@"sql_friend_get_type_by_email"];

        [self finalizeStatement:stmtGetFriendNamesUI_
                   withQueryKey:@"sql_friend_get_names"];

        [self finalizeStatement:stmtGetServicesByIndex_
                   withQueryKey:@"sql_services_get_by_index"];

        [self finalizeStatement:stmtGetFriendByCategoryAndIndex_
                   withQueryKey:@"sql_friend_get_by_category_and_index"];

        [self finalizeStatement:stmtCountServicesGroupedByOrganizationType_
                   withQueryKey:@"sql_services_count_grouped_by_organization_type"];

        [self finalizeStatement:stmtCountServicesByOrganizationType_
                   withQueryKey:@"sql_services_count_by_organization_type"];

        [self finalizeStatement:stmtGetServicesByIndexAndOrganizationType_
                  withQueryKey:@"sql_services_get_by_index_and_organization_type"];

        [self finalizeStatement:stmtGetServicesByOrganizationType_
                   withQueryKey:@"sql_services_get_organization_type"];

        [self finalizeStatement:stmtDeleteFriendCOMM_
                   withQueryKey:@"sql_friend_delete"];

        [self finalizeStatement:stmtGetFriendEmailsCOMM_
                   withQueryKey:@"sql_friend_get_emails"];

        [self finalizeStatement:stmtGetFriendEmailsByType_
                   withQueryKey:@"sql_friend_get_emails_by_type"];

        [self finalizeStatement:stmtInsertFriendCOMM_
                   withQueryKey:@"sql_friend_insert"];

        [self finalizeStatement:stmtUpdateEmailHashCOMM_
                   withQueryKey:@"sql_friend_update_email_hash"];

        [self finalizeStatement:stmtUpdateExistenceCOMM_
                   withQueryKey:@"sql_friend_update_existence"];

        [self finalizeStatement:stmtUpdateExistenceAndClearVersionCOMM_
                   withQueryKey:@"sql_friend_update_existence_and_clear_version"];

        [self finalizeStatement:stmtUpdateFriendCOMM_
                   withQueryKey:@"sql_friend_update"];

        [self finalizeStatement:stmtUpdateFriendInfo_
                  withQueryKey:@"sql_friend_update_info"];

        [self finalizeStatement:stmtUpdateFriendAvatarCOMM_
                   withQueryKey:@"sql_friend_update_avatar"];

        [self finalizeStatement:stmtUpdateShareMyLocationCOMM_
                   withQueryKey:@"sql_friend_update_share_location"];

        [self finalizeStatement:stmtCountInvitationSecrets_
                   withQueryKey:@"sql_friend_invitation_secret_count"];

        [self finalizeStatement:stmtDeleteInvitationSecret_
                   withQueryKey:@"sql_friend_invitation_secret_delete"];

        [self finalizeStatement:stmtGetInvitationSecret_
                   withQueryKey:@"sql_friend_invitation_secret_get"];

        [self finalizeStatement:stmtInsertInvitationSecret_
                   withQueryKey:@"sql_friend_invitation_secret_insert"];

        [self finalizeStatement:stmtGetPendingInvitations_
                   withQueryKey:@"sql_friend_pending_invitation_list"];

        [self finalizeStatement:stmtInsertPendingInvitation_
                   withQueryKey:@"sql_friend_pending_invitation_insert"];

        [self finalizeStatement:stmtRemovePendingInvitation_
                   withQueryKey:@"sql_friend_pending_invitation_remove"];

        [self finalizeStatement:stmtFriendisFriend_
                   withQueryKey:@"sql_friend_is_friend"];

        [self finalizeStatement:stmtGetFriendExistence_
                   withQueryKey:@"sql_friend_get_existence"];

        [self finalizeStatement:stmtGetFriendVersions_
                  withQueryKey:@"sql_friend_get_versions"];

        [self finalizeStatement:stmtFriendSetVersionGet_
                   withQueryKey:@"sql_friendset_version_get"];

        [self finalizeStatement:stmtFriendSetVersionSet_
                   withQueryKey:@"sql_friendset_version_set"];

        [self finalizeStatement:stmtFriendSetDeleteFrom_
                   withQueryKey:@"sql_friendset_delete_from"];

        [self finalizeStatement:stmtFriendSetInsertInto_
                   withQueryKey:@"sql_friendset_insert"];

        [self finalizeStatement:stmtFriendSetContains_
                   withQueryKey:@"sql_friendset_contains"];

        [self finalizeStatement:stmtFriendSetGet_
                   withQueryKey:@"sql_friendset_get"];

        // Service menu
        [self finalizeStatement:stmtCheckMenuIconAvailable_
                   withQueryKey:@"sql_friend_check_menu_icon_available"];

        [self finalizeStatement:stmtDeleteAllServiceMenus_
                   withQueryKey:@"sql_friend_clear_all_service_menu"];

        [self finalizeStatement:stmtDeleteMenuIcon_
                   withQueryKey:@"sql_friend_delete_menu_icon"];

        [self finalizeStatement:stmtDeleteServiceMenu_
                   withQueryKey:@"sql_friend_delete_service_menu"];

        [self finalizeStatement:stmtInsertMenuIcon_
                   withQueryKey:@"sql_friend_insert_menu_icon"];

        [self finalizeStatement:stmtInsertServiceMenu_
                   withQueryKey:@"sql_friend_insert_service_menu"];

        [self finalizeStatement:stmtGetMenu_
                   withQueryKey:@"sql_friend_get_full_menu"];

        [self finalizeStatement:stmtGetMenuDetails_
                   withQueryKey:@"sql_friend_get_menu_details"];

        [self finalizeStatement:stmtGetMenuIconUsage_
                   withQueryKey:@"sql_friend_menu_icon_usage"];

        [self finalizeStatement:stmtDataGet_
                   withQueryKey:@"sql_friend_data_get"];

        [self finalizeStatement:stmtCategoryExists_
                   withQueryKey:@"sql_friend_category_exists"];

        [self finalizeStatement:stmtCategoryInsert_
                   withQueryKey:@"sql_friend_category_insert"];

        [self finalizeStatement:stmtStaticFlowGet_
                   withQueryKey:@"sql_friend_static_flow_get"];

        [self finalizeStatement:stmtStaticFlowCheckAvailable_
                   withQueryKey:@"sql_friend_static_flow_check_available"];

        [self finalizeStatement:stmtStaticFlowInsert_
                   withQueryKey:@"sql_friend_static_flow_insert"];

        [self finalizeStatement:stmtStaticFlowGetUsage_
                   withQueryKey:@"sql_friend_static_flow_usage"];

        [self finalizeStatement:stmtStaticFlowDelete_
                   withQueryKey:@"sql_friend_static_flow_delete"];

        // rogerthat js api
        [self finalizeStatement:stmtServiceApiCallGetById_
                   withQueryKey:@"sql_service_api_call_get_by_id"];

        [self finalizeStatement:stmtServiceApiCallGetByItem_
                   withQueryKey:@"sql_service_api_call_get_results"];

        [self finalizeStatement:stmtServiceApiCallInsert_
                   withQueryKey:@"sql_service_api_call_insert"];
        
        [self finalizeStatement:stmtServiceApiCallRemove_
                   withQueryKey:@"sql_service_api_call_remove"];
        
        [self finalizeStatement:stmtServiceApiCallSetResult_
                   withQueryKey:@"sql_service_api_call_set_result"];

        [self finalizeStatement:stmtUpdateServiceUserData_
                   withQueryKey:@"sql_friend_set_user_data"];

        [self finalizeStatement:stmtUpdateServiceAppData_
                   withQueryKey:@"sql_friend_set_app_data"];

        [self finalizeStatement:stmtUpdateServiceData_
                   withQueryKey:@"sql_friend_set_data"];


        [self finalizeStatement:stmtGetFriendBroadcastInfo_
                  withQueryKey:@"sql_friend_get_broadcast_flow_for_mfr"];
        
        // groups
        [self finalizeStatement:stmtGetGroup_
                   withQueryKey:@"sql_get_group"];

        [self finalizeStatement:stmtGetGroups_
                   withQueryKey:@"sql_get_groups"];

        [self finalizeStatement:stmtInsertGroup_
                   withQueryKey:@"sql_insert_group"];

        [self finalizeStatement:stmtUpdateGroup_
                   withQueryKey:@"sql_update_group"];

        [self finalizeStatement:stmtDeleteGroup_
                   withQueryKey:@"sql_delete_group"];

        [self finalizeStatement:stmtDeleteGroupMembers_
                   withQueryKey:@"sql_delete_group_members"];

        [self finalizeStatement:stmtInsertGroupMember_
                   withQueryKey:@"sql_insert_group_member"];

        [self finalizeStatement:stmtDeleteGroupMember_
                   withQueryKey:@"sql_delete_group_member"];

        [self finalizeStatement:stmtClearGroup_
                   withQueryKey:@"sql_clear_group"];

        [self finalizeStatement:stmtClearEmptyGroup_
                   withQueryKey:@"sql_clear_empty_group"];

        [self finalizeStatement:stmtClearGroupMember_
                   withQueryKey:@"sql_clear_group_member"];

        [self finalizeStatement:stmtClearGroupMemberByEmail_
                   withQueryKey:@"sql_clear_group_member_by_email"];

        [self finalizeStatement:stmtInsertGroupAvatar_
                   withQueryKey:@"sql_insert_group_avatar"];

        [self finalizeStatement:stmtInsertGroupAvatarHash_
                   withQueryKey:@"sql_insert_group_avatar_hash"];

    }];
}

#pragma mark - Insert Friend

- (BOOL)insertFriend:(MCT_com_mobicage_to_friends_FriendTO *)friend withExistence:(MCTFriendExistence)existence
{
    T_DONTCARE();
    NSAssert(friend, @"friend should not be nil");
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            int i = 1;
            sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.email UTF8String], -1, NULL);
            if (friend.name == nil) {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.email UTF8String], -1, NULL);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.name UTF8String], -1, NULL);
            }
            sqlite3_bind_int64(stmtInsertFriendCOMM_, i++, friend.avatarId);
            sqlite3_bind_int(stmtInsertFriendCOMM_, i++, friend.shareLocation ? 1 : 0);
            sqlite3_bind_int(stmtInsertFriendCOMM_, i++, friend.sharesLocation ? 1 : 0);
            sqlite3_bind_int(stmtInsertFriendCOMM_, i++, existence);
            sqlite3_bind_int64(stmtInsertFriendCOMM_, i++, friend.type);
            sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [[MCTEncoding emailHashForEmail:friend.email
                                                                                 withType:(MCTFriendType)friend.type] UTF8String], -1, NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.descriptionX]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.descriptionX UTF8String], -1, NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.descriptionBranding]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.descriptionBranding UTF8String], -1, NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.pokeDescription]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.pokeDescription UTF8String], -1, NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.branding]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.actionMenu.branding UTF8String], -1 , NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.phoneNumber]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.actionMenu.phoneNumber UTF8String], -1 , NULL);
            }

            BOOL hasShareImageUrl = ![MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.shareImageUrl];
            sqlite3_bind_int(stmtInsertFriendCOMM_, i++, hasShareImageUrl ? 1 : 0); // column: share
            sqlite3_bind_int64(stmtInsertFriendCOMM_, i++, friend.generation);

            if (hasShareImageUrl) {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.actionMenu.shareImageUrl UTF8String], -1 , NULL);
            } else {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.shareDescription]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.actionMenu.shareDescription UTF8String], -1 , NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.shareCaption]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.actionMenu.shareCaption UTF8String], -1 , NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.shareLinkUrl]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.actionMenu.shareLinkUrl UTF8String], -1 , NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.qualifiedIdentifier]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.qualifiedIdentifier UTF8String], -1 , NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.aboutLabel]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.actionMenu.aboutLabel UTF8String], -1 , NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.messagesLabel]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.actionMenu.messagesLabel UTF8String], -1 , NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.callLabel]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.actionMenu.callLabel UTF8String], -1 , NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.shareLabel]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.actionMenu.shareLabel UTF8String], -1 , NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.callConfirmation]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.actionMenu.callConfirmation UTF8String], -1 , NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.userData]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.userData UTF8String], -1 , NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.appData]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.appData UTF8String], -1 , NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.category_id]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.category_id UTF8String], -1 , NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.broadcastFlowHash]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.broadcastFlowHash UTF8String], -1 , NULL);
            }

            sqlite3_bind_int64(stmtInsertFriendCOMM_, i++, friend.organizationType);
            sqlite3_bind_int64(stmtInsertFriendCOMM_, i++, friend.callbacks);
            sqlite3_bind_int64(stmtInsertFriendCOMM_, i++, friend.flags);
            sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [[friend.versions componentsJoinedByString:@","] UTF8String],
                              -1 , NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.profileData]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.profileData UTF8String], -1 , NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.contentBrandingHash]) {
                sqlite3_bind_null(stmtInsertFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtInsertFriendCOMM_, i++, [friend.contentBrandingHash UTF8String], -1 , NULL);
            }

            if ((e = sqlite3_step(stmtInsertFriendCOMM_)) != SQLITE_DONE) {
                LOG(@"Failed to insert friend %@", friend);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtInsertFriendCOMM_);
        }
    }];

    [self requestFriendCategoryIfNeeded:friend];
    [self removeFriendFromCache:friend.email];

    return YES;
}

- (BOOL)addInvitedService:(MCTFriend *)service
{
    T_DONTCARE();
    BOOL added = [self insertFriend:service withExistence:MCTFriendExistenceInvitePending];

    if (added) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_FRIEND_ADDED];
        [intent setString:service.email forKey:@"email"];
        [intent setLong:MCTFriendTypeService forKey:@"friend_type"];
        [intent setLong:MCTFriendExistenceInvitePending forKey:@"existence"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    }

    return added;
}

- (BOOL)storeFriend:(MCT_com_mobicage_to_friends_FriendTO *)friend
         withAvatar:(NSData *)avatar
           andForce:(BOOL)force
{
    T_DONTCARE();
    __block BOOL updated = NO;
    [self dbLockedTransactionWithBlock:^{
        if (force || [self friendSetContainsFriend:friend.email]) {
            [self operationDeleteServiceMenuForFriendEmail:friend.email];

            [self insertFriend:friend withExistence:(MCTFriendExistence)friend.existence];
            [self operationRebuildServiceMenuWithFriend:friend cleanup:NO];
            if (avatar) {
                [self saveAvatarWithData:avatar andFriendEmail:friend.email];
            } else {
                [self downloadAvatar:friend];
            }

            updated = YES;
        }
    }];

    return updated;
}


- (void)operationDeleteServiceMenuForFriendEmail:(NSString *)friendEmail
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtDeleteServiceMenu_, 1, [friendEmail UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtDeleteServiceMenu_)) != SQLITE_DONE) {
                LOG(@"Failed to cleanup service menu for %@", friendEmail);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtDeleteServiceMenu_);
        }
    }];
}


#pragma mark - Delete Friend

- (void)deleteFriendWithEmail:(NSString *)email
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtDeleteFriendCOMM_, 1, [email UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtDeleteFriendCOMM_)) != SQLITE_DONE) {
                LOG(@"Cannot delete friend with email: %@", email);
                MCT_THROW_SQL_EXCEPTION(e);
            }
            [self operationDeleteServiceMenuForFriendEmail:email];
        }
        @finally {
            sqlite3_reset(stmtDeleteFriendCOMM_);
        }
    }];
}


#pragma mark - Update Friend

/**
 * Return values:
 NSOrderedAscending (-1) means versionsInDB < versionsFromServer
 NSOrderedDescending (1) means versionsInDB > versionsFromServer
 NSOrderedSame (0) means versionsInDB == versionsFromServer
 */
- (NSComparisonResult)compareVersionsInDB:(NSArray *)versionsInDB withVersionsFromServer:(NSArray *)versionsFromServer
{
    T_DONTCARE();
    LOG(@"Comparing [%@] with [%@]",
        [versionsInDB componentsJoinedByString:@", "], [versionsFromServer componentsJoinedByString:@", "]);

    if ([versionsInDB count] > [versionsFromServer count]) {
        @throw [NSException exceptionWithName:@"IllegalFriendVersionsComparison"
                                       reason:@"Can not compare when versionsInDB count is more than versionsFromServer"
                                     userInfo:nil];
    } else if ([versionsInDB count] == 0) {
        return NSOrderedAscending;
    }

    for (int i = 0; i < [versionsInDB count]; i++) {
        MCTlong versionInDB = [[versionsInDB objectAtIndex:i] longLongValue];
        MCTlong versionFromServer = [[versionsFromServer objectAtIndex:i] longLongValue];
        if (versionInDB > versionFromServer) {
            return NSOrderedDescending;
        }
        if (versionInDB < versionFromServer) {
            return NSOrderedAscending;
        }
    }
    return NSOrderedSame;
}

- (NSDictionary *)infoDictForVersionsOfFriend:(MCT_com_mobicage_to_friends_FriendTO *)friend
                             withVersionsInDB:(NSArray *)versionsInDB
{
    T_DONTCARE();
    return [NSDictionary dictionaryWithObjectsAndKeys:
            friend.email, @"email",
            versionsInDB, @"localVersions",
            friend.versions, @"serverVersions", nil];
}

- (MCT_com_mobicage_to_friends_UpdateFriendResponseTO *)shouldUpdateFriend:(MCT_com_mobicage_to_friends_FriendTO *)friend
{
    T_DONTCARE();
    NSAssert(friend, @"friend should not be nil");

    MCT_com_mobicage_to_friends_UpdateFriendResponseTO *response =
        [MCT_com_mobicage_to_friends_UpdateFriendResponseTO transferObject];

    if (![self friendSetContainsFriend:friend.email]) {
        response.updated = NO;
        response.reason = [NSString stringWithFormat:@"%@ is not in the local friendSet", friend.email];
    } else {
        NSArray *versionsInDB = [self friendVersionsForEmail:friend.email];

        if ([versionsInDB count] == 0) {
            response.updated = NO;
            response.reason = [NSString stringWithFormat:@"%@ is not (yet) in the friend table! Probably, a getFriend "
                               "request is pending", friend.email];
        } else if ([versionsInDB count] > [friend.versions count]) {
            response.updated = NO;
            response.reason = [NSString stringWithFormat:@"There are more versions in the local DB than versions on the "
                               "server.\n%@", [self infoDictForVersionsOfFriend:friend
                                                               withVersionsInDB:versionsInDB]];
        } else {
            // Check that versions in DB are not greater than versions from server
            NSComparisonResult comparisonResult = [self compareVersionsInDB:versionsInDB
                                                     withVersionsFromServer:friend.versions];

            if ([versionsInDB count] < [friend.versions count]) {
                if (comparisonResult == NSOrderedDescending) {
                    // versionsInDB > versionsFromServer
                    NSString *errorMsg = [NSString stringWithFormat:@"Versions length difference between local DB and server, "
                                          "AND one or more versions in local DB are greater than versions on the server.\n%@",
                                          [NSDictionary dictionaryWithObjectsAndKeys:
                                           friend.email, @"email",
                                           versionsInDB, @"localVersions",
                                           friend.versions, @"serverVersions", nil]];

                    @throw [NSException exceptionWithName:@"IllegalFriendVersionBump"
                                                   reason:errorMsg
                                                 userInfo:nil];
                } else {
                    // We can continue. A version field has been added. Eg from [1, 1] to [1, 1, 0].
                    response.updated = YES;
                    response.reason = nil;
                }
            } else {
                // [versionsInDB count] == [friend.versions count]
                if (comparisonResult == NSOrderedAscending) {
                    // versionsInDB < versionsFromServer
                    response.updated = YES;
                } else {
                    response.updated = NO;
                    response.reason = [NSString stringWithFormat:@"One or more versions in local DB are greater than "
                                       "versions on the server. %@", [self infoDictForVersionsOfFriend:friend
                                                                                      withVersionsInDB:versionsInDB]];
                }
            }
        }
    }
    return response;
}

- (void)updateFriendInfo:(MCT_com_mobicage_to_friends_GetUserInfoResponseTO *)result
               withEmail:(NSString *)email
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            int i = 1;
            sqlite3_bind_text(stmtUpdateFriendInfo_, i++, [result.name UTF8String], -1, NULL);
            sqlite3_bind_int64(stmtUpdateFriendInfo_, i++, result.avatar_id);
            NSData *data = [NSData dataFromBase64String:result.avatar];
            sqlite3_bind_blob(stmtUpdateFriendAvatarCOMM_, i++, [data bytes], (int)[data length], NULL);
            sqlite3_bind_int64(stmtUpdateFriendInfo_, i++, result.type);
            sqlite3_bind_text(stmtUpdateFriendInfo_, i++, [result.descriptionX UTF8String], -1, NULL);
            sqlite3_bind_text(stmtUpdateFriendInfo_, i++, [result.descriptionBranding UTF8String], -1, NULL);
            sqlite3_bind_text(stmtUpdateFriendInfo_, i++, [result.qualifiedIdentifier UTF8String], -1, NULL);
            sqlite3_bind_text(stmtUpdateFriendInfo_, i++, [result.profileData UTF8String], -1, NULL);

            // Where clause
            sqlite3_bind_text(stmtUpdateFriendInfo_, i++, [email UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateFriendInfo_)) != SQLITE_DONE) {
                LOG(@"Cannot update friend info %@;", result);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateFriendInfo_);
        }
    }];

    [self removeFriendFromCache:email];
}

/**
 * Returns NO if friend in DB is more recent than provided friend
 */
- (MCT_com_mobicage_to_friends_UpdateFriendResponseTO *)updateFriend:(MCT_com_mobicage_to_friends_FriendTO *)friend
{
    T_DONTCARE();
    NSAssert(friend, @"friend should not be nil");
    __block MCT_com_mobicage_to_friends_UpdateFriendResponseTO *response;

    __block BOOL userDataUpdated = NO;
    __block BOOL serviceDataUpdated = NO;

    [self dbLockedTransactionWithBlock:^{
        response = [self shouldUpdateFriend:friend];
        if (!response.updated) {
            return;
        }

        if (friend.avatarHash) {
            MCTFriend *oldFriend = [self friendByEmail:friend.email];
            if (!oldFriend || !oldFriend.avatar || ![[friend.avatarHash uppercaseString] isEqualToString:[[oldFriend.avatar sha256Hash] uppercaseString]]) {
                [self downloadAvatar:friend];
            }
        }

        [self requestFriendCategoryIfNeeded:friend];

        // Check if service data has changed
        if (friend.type == MCTFriendTypeService) {
            NSArray *data = [self friendDataStringsWithEmail:friend.email];
            if (data != nil) {
                userDataUpdated = ![MCTUtils isString:friend.userData equalToString:[data objectAtIndex:0]];
                serviceDataUpdated = ![MCTUtils isString:friend.appData equalToString:[data objectAtIndex:1]];
            }
        }

        @try {
            int e;

            int i = 1;
            sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [[friend displayName] UTF8String], -1, NULL);
            sqlite3_bind_int64(stmtUpdateFriendCOMM_, i++, friend.avatarId);
            sqlite3_bind_int(stmtUpdateFriendCOMM_, i++, friend.shareLocation ? 1 : 0);
            sqlite3_bind_int(stmtUpdateFriendCOMM_, i++, friend.sharesLocation ? 1 : 0);
            sqlite3_bind_int64(stmtUpdateFriendCOMM_, i++, friend.type);

            if (friend.descriptionX == nil)
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.descriptionX UTF8String], -1 , NULL);

            if (friend.descriptionBranding == nil)
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.descriptionBranding UTF8String], -1, NULL);

            if (friend.pokeDescription == nil)
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.pokeDescription UTF8String], -1 , NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.branding])
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.actionMenu.branding UTF8String], -1 , NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.phoneNumber])
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.actionMenu.phoneNumber UTF8String], -1 , NULL);

            BOOL hasShareImageUrl = ![MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.shareImageUrl];
            sqlite3_bind_int(stmtUpdateFriendCOMM_, i++, hasShareImageUrl ? 1 : 0);
            sqlite3_bind_int64(stmtUpdateFriendCOMM_, i++, friend.generation);

            if (hasShareImageUrl)
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.actionMenu.shareImageUrl UTF8String], -1 , NULL);
            else
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.shareDescription])
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.actionMenu.shareDescription UTF8String], -1 , NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.shareCaption])
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.actionMenu.shareCaption UTF8String], -1 , NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.shareLinkUrl])
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.actionMenu.shareLinkUrl UTF8String], -1 , NULL);

            if (friend.qualifiedIdentifier == nil)
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.qualifiedIdentifier UTF8String], -1 , NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.aboutLabel])
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.actionMenu.aboutLabel UTF8String], -1 , NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.messagesLabel])
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.actionMenu.messagesLabel UTF8String], -1 , NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.callLabel])
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.actionMenu.callLabel UTF8String], -1 , NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.shareLabel])
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.actionMenu.shareLabel UTF8String], -1 , NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.callConfirmation])
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.actionMenu.callConfirmation UTF8String], -1 , NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.userData])
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.userData UTF8String], -1 , NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.appData])
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.appData UTF8String], -1 , NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.category_id])
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.category_id UTF8String], -1 , NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.broadcastFlowHash])
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            else
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.broadcastFlowHash UTF8String], -1 , NULL);

            sqlite3_bind_int64(stmtUpdateFriendCOMM_, i++, friend.organizationType);
            sqlite3_bind_int64(stmtUpdateFriendCOMM_, i++, friend.callbacks);
            sqlite3_bind_int64(stmtUpdateFriendCOMM_, i++, friend.flags);
            sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [[friend.versions componentsJoinedByString:@","] UTF8String],
                              -1, NULL);

            if ([MCTUtils isEmptyOrWhitespaceString:friend.profileData]) {
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.profileData UTF8String], -1, NULL);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:friend.contentBrandingHash]) {
                sqlite3_bind_null(stmtUpdateFriendCOMM_, i++);
            } else {
                sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.contentBrandingHash UTF8String], -1, NULL);
            }

            // Where clause
            sqlite3_bind_text(stmtUpdateFriendCOMM_, i++, [friend.email UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateFriendCOMM_)) != SQLITE_DONE) {
                LOG(@"Cannot update friend %@;", friend);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateFriendCOMM_);
        }

        [self removeFriendFromCache:friend.email];

        [self operationRebuildServiceMenuWithFriend:friend cleanup:YES];
    }];

    if (response.updated) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_FRIEND_MODIFIED];
        [intent setString:friend.email forKey:@"email"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];

        if (userDataUpdated || serviceDataUpdated) {
            [self broadcastDataUpdatedForService:friend.email
                                 userDataUpdated:userDataUpdated
                                  appDataUpdated:serviceDataUpdated];
        }
    }
    
    return response;
}


# pragma mark - Other methods

- (BOOL)requestFriendCategoryIfNeeded:(MCT_com_mobicage_to_friends_FriendTO *)friend
{
    T_DONTCARE();
    if (friend.category_id != nil && ![self categoryExistsWithId:friend.category_id]) {
        MCTGetFriendCategoryRH *rh = [MCTGetFriendCategoryRH responseHandler];
        MCT_com_mobicage_to_friends_GetCategoryRequestTO *request = [MCT_com_mobicage_to_friends_GetCategoryRequestTO transferObject];
        request.category_id = friend.category_id;
        [MCT_com_mobicage_api_friends CS_API_getCategoryWithResponseHandler:rh
                                                                 andRequest:request];
    }
}

- (void)scrub
{
    T_DONTCARE();
    [self dbLockedTransactionWithBlock:^{
        [self operationScrubMenuIcons];
        [self operationScrubStaticFlows];
    }];
}

- (BOOL)updateShareMyLocation:(BOOL)enabled withFriendEmail:(NSString *)email
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_int(stmtUpdateShareMyLocationCOMM_, 1, enabled ? 1 : 0);
            sqlite3_bind_text(stmtUpdateShareMyLocationCOMM_, 2, [email UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateShareMyLocationCOMM_)) != SQLITE_DONE) {
                LOG(@"Cannot update share_location for friend %@;", email);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            [self removeFriendFromCache:email];
        }
        @finally {
            sqlite3_reset(stmtUpdateShareMyLocationCOMM_);
        }
    }];

    return YES;
}

- (void)saveAvatarWithData:(NSData *)data andFriendEmail:(NSString *)email
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            sqlite3_bind_blob(stmtUpdateFriendAvatarCOMM_, 1, [data bytes], (int)[data length], NULL);
            sqlite3_bind_text(stmtUpdateFriendAvatarCOMM_, 2, [email UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateFriendAvatarCOMM_)) != SQLITE_DONE) {
                LOG(@"Failed to save avatar of friend %@;", email);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateFriendAvatarCOMM_);
        }

        [self removeFriendFromCache:email];
    }];

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_FRIEND_MODIFIED];
    [intent setString:email forKey:@"email"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (void)downloadAvatar:(MCT_com_mobicage_to_friends_FriendTO *)friend
{
    T_DONTCARE();
    HERE();
    if (friend.avatarId == -1)
        return;

    [[MCTComponentFramework friendsPlugin] requestAvatarWithId:friend.avatarId andEmail:friend.email];
}

- (void)updateEmailHashForFriend:(NSString *)email withFriendType:(MCTFriendType)friendType
{
    T_DONTCARE();
    NSString *hash = [MCTEncoding emailHashForEmail:email withType:friendType];
    LOG(@"Setting email_hash '%@' for friend '%@'", hash, email);
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtUpdateEmailHashCOMM_, 1, [hash UTF8String], -1, NULL);
            sqlite3_bind_text(stmtUpdateEmailHashCOMM_, 2, [email UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateEmailHashCOMM_)) != SQLITE_DONE) {
                LOG(@"Failed to update email_hash of friend");
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateEmailHashCOMM_);
        }
    }];
}

- (void)updateEmailHashesForAllFriends
{
    T_DONTCARE();
    [self dbLockedTransactionWithBlock:^{
        for (NSString *email in [self friendEmailsWithFriendType:MCTFriendTypeUser]) {
            [self updateEmailHashForFriend:email withFriendType:MCTFriendTypeUser];
        }
        for (NSString *email in [self friendEmailsWithFriendType:MCTFriendTypeService]) {
            [self updateEmailHashForFriend:email withFriendType:MCTFriendTypeService];
        }
    }];
}

- (void)resizeAvatarsForAllFriends
{
    T_BIZZ();
    CGFloat scale = [[UIScreen mainScreen] scale];
    if (scale > 2) {
        return;
    }

    CGFloat avatarSize = 50 * scale;

    NSArray *emails = [self friendEmails];
    for (NSString *email in emails) {
        UIImage *avatar = [UIImage imageWithData:[self friendAvatarByEmail:email]];
        if (avatar.size.width > avatarSize || avatar.size.height > avatarSize) {
            avatar = [avatar resizedImage:CGSizeMake(avatarSize, avatarSize)
                     interpolationQuality:kCGInterpolationMedium];
            [self saveAvatarWithData:UIImagePNGRepresentation(avatar) andFriendEmail:email];
        }
    }
}

#pragma mark - FriendSet

- (MCTlong)friendSetVersion
{
    T_DONTCARE();
    __block int version;

    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            if ((e = sqlite3_step(stmtFriendSetVersionGet_)) != SQLITE_ROW) {
                LOG(@"Error retrieving friendSet version");
                MCT_THROW_SQL_EXCEPTION(e);
            }
            version = sqlite3_column_int(stmtFriendSetVersionGet_, 0);

            if ((e = sqlite3_step(stmtFriendSetVersionGet_)) != SQLITE_DONE) {
                LOG(@"Error stepping through friendSet version");
                MCT_THROW_SQL_EXCEPTION(e);
            }

            LOG(@"FriendSet version is %d", version);
        }
        @finally {
            sqlite3_reset(stmtFriendSetVersionGet_);
        }

    }];

    return version;
}

- (BOOL)updateFriendSetVersion:(MCTlong)version
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            sqlite3_bind_int64(stmtFriendSetVersionSet_, 1, version);

            if ((e = sqlite3_step(stmtFriendSetVersionSet_)) != SQLITE_DONE) {
                LOG(@"Error updating friendSet version");
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtFriendSetVersionSet_);
        }

    }];

    return YES;
}

- (void)deleteFriendFromFriendSetWithEmail:(NSString *)email
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtFriendSetDeleteFrom_, 1, [email UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtFriendSetDeleteFrom_)) != SQLITE_DONE) {
                LOG(@"Failed to delete '%@' from friendSet", email);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtFriendSetDeleteFrom_);
        }
    }];
}

- (void)insertFriendIntoFriendSetWithEmail:(NSString *)email
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtFriendSetInsertInto_, 1, [email UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtFriendSetInsertInto_)) != SQLITE_DONE) {
                LOG(@"Failed to insert '%@' into friendSet", email);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtFriendSetInsertInto_);
        }
    }];
}

- (NSArray *)friendSet
{
    T_DONTCARE();
    NSMutableArray *array = [NSMutableArray array];
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            while ((e = sqlite3_step(stmtFriendSetGet_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to loop over friendSet");
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                [array addObject:[NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtFriendSetGet_, 0)]];
            }
        }
        @finally {
            sqlite3_reset(stmtFriendSetGet_);
        }
    }];
    return array;
}

- (BOOL)friendSetContainsFriend:(NSString *)email
{
    T_DONTCARE();
    __block int count;
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtFriendSetContains_, 1, [email UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtFriendSetContains_)) != SQLITE_ROW) {
                LOG(@"Error counting friend %@ in friendSet", email);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            count = sqlite3_column_int(stmtFriendSetContains_, 0);
        }
        @finally {
            sqlite3_reset(stmtFriendSetContains_);
        }
    }];
    return (BOOL)count;
}

- (NSArray *)friendVersionsForEmail:(NSString *)email
{
    T_DONTCARE();
    NSMutableArray *versionNumbers = [NSMutableArray array];
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtGetFriendVersions_, 1, [email UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtGetFriendVersions_)) == SQLITE_ROW) {
                NSString *versions = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFriendVersions_, 0)];
                if (![MCTUtils isEmptyOrWhitespaceString:versions]) {
                    NSArray *versionStrings = [versions componentsSeparatedByString:@","];
                    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                    for (NSString *versionString in versionStrings) {
                        if (![f numberFromString:versionString]) {
                            HERE();
                        }
                        [versionNumbers addObject:[f numberFromString:versionString]];
                    }
                }
            } else if (e != SQLITE_DONE) {
                LOG(@"Error retrieving friend versions of %@", email);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtGetFriendVersions_);
        }
    }];
    return versionNumbers;
}


#pragma mark - Friend existence

- (void)setFriendExistenceStatus:(int)status forEmail:(NSString *)email
{
    T_DONTCARE();
    BOOL isDelete = status == MCTFriendExistenceDeletePending || status == MCTFriendExistenceDeleted;

    [self dbLockedTransactionWithBlock:^{
        sqlite3_stmt *stmt = isDelete ? stmtUpdateExistenceAndClearVersionCOMM_ : stmtUpdateExistenceCOMM_;

        @try {
            int e;

            sqlite3_bind_int(stmt, 1, status);
            sqlite3_bind_text(stmt, 2, [email UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmt)) != SQLITE_DONE)
                MCT_THROW_SQL_EXCEPTION(e);
        }
        @finally {
            sqlite3_reset(stmt);
        }

        [self removeFriendFromCache:email];
    }];

    if (isDelete) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_FRIEND_REMOVED];
        [intent setString:email forKey:@"email"];
        [intent setLong:status forKey:@"status"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    }
}

- (MCTFriendExistence)friendExistenceForEmail:(NSString *)email
{
    T_DONTCARE();
    __block int existence;

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtGetFriendExistence_, 1, [email UTF8String], -1, NULL);

            e = sqlite3_step(stmtGetFriendExistence_);
            if (e == SQLITE_ROW) {
                existence = sqlite3_column_int(stmtGetFriendExistence_, 0);
            } else if (e == SQLITE_DONE) {
                existence = MCTFriendExistenceNotFound;
            } else {
                LOG(@"Error retrieving friend existence of %@", email);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtGetFriendExistence_);
        }
    }];

    return existence;
}

- (BOOL)friendExistsWithEmail:(NSString *)email
{
    T_DONTCARE();
    __block int count;

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtFriendisFriend_, 1, [email UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtFriendisFriend_)) != SQLITE_ROW) {
                LOG(@"Error retrieving friend existence of %@", email);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            count = sqlite3_column_int(stmtFriendisFriend_, 0);
        }
        @finally {
            sqlite3_reset(stmtFriendisFriend_);
        }
    }];

    return (BOOL)count;
}

#pragma mark -
#pragma mark Invitation Secrets

- (void)saveInvitationSecrets:(NSArray *)secrets
{
    T_DONTCARE();
    [self dbLockedTransactionWithBlock:^{
        for (NSString *secret in secrets) {
            @try {
                int e;

                sqlite3_bind_text(stmtInsertInvitationSecret_, 1, [secret UTF8String], -1, NULL);

                if ((e = sqlite3_step(stmtInsertInvitationSecret_)) != SQLITE_DONE) {
                    LOG(@"Failed to store invitation secret: %@", secret);
                    MCT_THROW_SQL_EXCEPTION(e);
                }
            }
            @finally {
                sqlite3_reset(stmtInsertInvitationSecret_);
            }
        }
    }];
}

- (NSString *)popInvitationSecret
{
    T_DONTCARE();
    __block NSString *secret = nil;
    [self dbLockedTransactionWithBlock:^{
        @try {
            int e = sqlite3_step(stmtGetInvitationSecret_);

            if (e == SQLITE_DONE)
                return;

            if (e != SQLITE_ROW) {
                LOG(@"Failed to get invitation secret");
                MCT_THROW_SQL_EXCEPTION(e);
            }

            secret = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetInvitationSecret_, 0)];
        }
        @finally {
            sqlite3_reset(stmtGetInvitationSecret_);
        }

        @try {
            sqlite3_bind_text(stmtDeleteInvitationSecret_, 1, [secret UTF8String], -1, NULL);

            int e = sqlite3_step(stmtDeleteInvitationSecret_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to delete secret '%@'", secret);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtDeleteInvitationSecret_);
        }
    }];

    return secret;
}

- (int)countInvitationSecrets
{
    T_DONTCARE();
    __block int count;

    [self dbLockedOperationWithBlock:^{
        @try {
            int e = sqlite3_step(stmtCountInvitationSecrets_);

            if (e != SQLITE_ROW) {
                LOG(@"Failed to retrieve invitation secret count");
                MCT_THROW_SQL_EXCEPTION(e);
            }

            count = sqlite3_column_int(stmtCountInvitationSecrets_, 0);
        }
        @finally {
            sqlite3_reset(stmtCountInvitationSecrets_);
        }
    }];

    return count;
}

- (NSArray *)pendingInvitations
{
    T_DONTCARE();
    NSMutableArray *result = [NSMutableArray array];

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            while ((e = sqlite3_step(stmtGetPendingInvitations_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get pending invitations");
                    MCT_THROW_SQL_EXCEPTION(e);
                }
                NSString *invitation = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetPendingInvitations_, 0)];
                if (invitation == nil) {
                    ERROR(@"There is a NULL pending invitation");
                } else {
                    [result addObject:invitation];
                }
            }
        }
        @finally {
            sqlite3_reset(stmtGetPendingInvitations_);
        }
    }];

    return result;
}

- (void)addPendingInvitation:(NSString *)invitee
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtInsertPendingInvitation_, 1, [invitee UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtInsertPendingInvitation_)) != SQLITE_DONE) {
                LOG(@"Failed to store pending invitation %@", invitee);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtInsertPendingInvitation_);
        }
    }];
}

- (void)removePendingInvitation:(NSString *)invitee
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtRemovePendingInvitation_, 1, [invitee UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtRemovePendingInvitation_)) != SQLITE_DONE) {
                LOG(@"Failed to remove pending invitation %@", invitee);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtRemovePendingInvitation_);
        }
    }];
}

#pragma mark -
#pragma mark UI thread methods

- (NSArray *)friendEmails
{
    T_DONTCARE();
    NSMutableArray *array = [NSMutableArray array];
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            while ((e = sqlite3_step(stmtGetFriendEmailsCOMM_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to loop over friend emails");
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                [array addObject:[NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFriendEmailsCOMM_, 0)]];
            }
        }
        @finally {
            sqlite3_reset(stmtGetFriendEmailsCOMM_);
        }
    }];
    return array;
}

- (NSArray *)friendEmailsWithFriendType:(MCTFriendType)friendType
{
    T_DONTCARE();
    NSMutableArray *array = [NSMutableArray array];
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_int(stmtGetFriendEmailsByType_, 1, friendType);

            while ((e = sqlite3_step(stmtGetFriendEmailsByType_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to loop over friend emails with type %d", friendType);
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                [array addObject:[NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFriendEmailsByType_, 0)]];
            }
        }
        @finally {
            sqlite3_reset(stmtGetFriendEmailsByType_);
        }
    }];
    return array;
}

- (int)countFriends
{
    T_DONTCARE();
    __block int count;

    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            if ((e = sqlite3_step(stmtCountFriendsUI_)) != SQLITE_ROW) {
                LOG(@"Error retrieving friend count");
                MCT_THROW_SQL_EXCEPTION(e);
            }

            count = sqlite3_column_int(stmtCountFriendsUI_, 0);

            if ((e = sqlite3_step(stmtCountFriendsUI_)) != SQLITE_DONE) {
                LOG(@"Error retrieving friend count");
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtCountFriendsUI_);
        }

    }];

    return count;
}

- (int)countFriendsByType:(MCTFriendType)type
{
    T_DONTCARE();
    __block int count;

    [self dbLockedOperationWithBlock:^{

        sqlite3_stmt *stmt = (type == 2) ? stmtCountServices_ : stmtCountFriendsByTypeUI_;
        @try {
            int e;

            if (type != 2) {
                sqlite3_bind_int(stmt, 1, type);
            }

            if ((e = sqlite3_step(stmt)) != SQLITE_ROW) {
                LOG(@"Error retrieving friend count by type %d", type);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            count = sqlite3_column_int(stmt, 0);

            if ((e = sqlite3_step(stmt)) != SQLITE_DONE) {
                LOG(@"Error retrieving friend count by type %d", type);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmt);
        }
        
    }];
    
    return count;
}

- (int)countFriendsByCategory:(NSString *)category
{
    T_DONTCARE();
    __block int count;

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtCountFriendsByCategory_, 1, [category UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtCountFriendsByCategory_)) != SQLITE_ROW) {
                LOG(@"Error retrieving friend count by category %@", category);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            count = sqlite3_column_int(stmtCountFriendsByCategory_, 0);

            if ((e = sqlite3_step(stmtCountFriendsByCategory_)) != SQLITE_DONE) {
                LOG(@"Error retrieving friend count by category %@", category);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtCountFriendsByCategory_);
        }
    }];
    
    return count;
}

- (int)countServicesByOrganizationType:(MCTServiceOrganizationType)organizationType
{
    T_DONTCARE();
    __block int count;

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_int(stmtCountServicesByOrganizationType_, 1, organizationType);

            if ((e = sqlite3_step(stmtCountServicesByOrganizationType_)) != SQLITE_ROW) {
                LOG(@"Error retrieving friend count by organizationType %d", organizationType);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            count = sqlite3_column_int(stmtCountServicesByOrganizationType_, 0);

            if ((e = sqlite3_step(stmtCountServicesByOrganizationType_)) != SQLITE_DONE) {
                LOG(@"Error retrieving friend count by organizationType %d", organizationType);

                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtCountServicesByOrganizationType_);
        }
    }];
    
    return count;
}

- (NSDictionary *)countServicesGroupedByOrganizationType
{
    T_DONTCARE();
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            while ((e = sqlite3_step(stmtCountServicesGroupedByOrganizationType_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to count services grouped by organizationType");
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                int organizationType = sqlite3_column_int(stmtCountServicesGroupedByOrganizationType_, 0);
                int count = sqlite3_column_int(stmtCountServicesGroupedByOrganizationType_, 1);

                [results setObject:@(count)
                            forKey:@(organizationType)];
            }
        }
        @finally {
            sqlite3_reset(stmtCountServicesGroupedByOrganizationType_);
        }
    }];

    return results;
}

- (NSArray *)getServicesByOrganizationType:(MCTServiceOrganizationType)organizationType
{
    T_DONTCARE();
    __block NSMutableArray *emails = [NSMutableArray array];
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_int(stmtGetServicesByOrganizationType_, 1, organizationType);

            while ((e = sqlite3_step(stmtGetServicesByOrganizationType_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get emails of services with organizationType %d", organizationType);
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                [emails addObject:[NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetServicesByOrganizationType_, 1)]];
            }
        }
        @finally {
            sqlite3_reset(stmtGetServicesByOrganizationType_);
        }
    }];
    return emails;
}

- (int)countFriendsSharingLocation
{
    T_DONTCARE();
    __block int count;

    [self dbLockedOperationWithBlock:^{
       @try {
           int e;

           if ((e = sqlite3_step(stmtCountFriendsSharingLocation_)) != SQLITE_ROW) {
               LOG(@"Error retrieving amount of friends sharing location");
               MCT_THROW_SQL_EXCEPTION(e);
           }

           count = sqlite3_column_int(stmtCountFriendsSharingLocation_, 0);
       }
       @finally {
           sqlite3_reset(stmtCountFriendsSharingLocation_);
       }
    }];

    return count;
}

- (MCTFriend *)friendByIndex:(NSInteger)index
{
    T_DONTCARE();
    __block MCTFriend *friend;

    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            sqlite3_bind_int64(stmtGetFriendByIndexUI_, 1, index);
            if ((e = sqlite3_step(stmtGetFriendByIndexUI_)) != SQLITE_ROW) {
                LOG(@"Failed to get friend with index %d", index);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            friend = [self friendWithStatement:stmtGetFriendByIndexUI_];

            [self addFriendToCache:friend];
        }
        @finally {
            sqlite3_reset(stmtGetFriendByIndexUI_);
        }
    }];

    return friend;
}

- (MCTFriend *)friendByType:(MCTFriendType)type andIndex:(NSInteger)index
{
    T_DONTCARE();
    __block MCTFriend *friend;

    [self dbLockedOperationWithBlock:^{
        sqlite3_stmt *stmt = type == 2 ? stmtGetServicesByIndex_ : stmtGetFriendByTypeAndIndexUI_;
        @try {
            int e;

            if (type == 2) {
                sqlite3_bind_int64(stmt, 1, index);
                if ((e = sqlite3_step(stmt)) != SQLITE_ROW) {
                    LOG(@"Failed to get service with index %d", index);
                    MCT_THROW_SQL_EXCEPTION(e);
                }
            } else {
                sqlite3_bind_int(stmt, 1, type);
                sqlite3_bind_int64(stmt, 2, index);
                if ((e = sqlite3_step(stmt)) != SQLITE_ROW) {
                    LOG(@"Failed to get friend with type %d and index %d", type, index);
                    MCT_THROW_SQL_EXCEPTION(e);
                }
            }
            friend = [self friendWithStatement:stmt];
            if (friend.category == nil) {
                [self addFriendToCache:friend];
            }

        }
        @finally {
            sqlite3_reset(stmt);
        }
    }];
    
    return friend;
}

- (MCTFriend *)friendByCategory:(NSString *)category andIndex:(NSInteger)index
{
    T_DONTCARE();
    __block MCTFriend *friend;

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtGetFriendByCategoryAndIndex_, 1, [category UTF8String], -1, NULL);
            sqlite3_bind_int64(stmtGetFriendByCategoryAndIndex_, 2, index);
            if ((e = sqlite3_step(stmtGetFriendByCategoryAndIndex_)) != SQLITE_ROW) {
                LOG(@"Failed to get friend with category %@ and index %d", category, index);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            friend = [self friendWithStatement:stmtGetFriendByCategoryAndIndex_];
            [self addFriendToCache:friend];
        }
        @finally {
            sqlite3_reset(stmtGetFriendByCategoryAndIndex_);
        }
    }];

    return friend;
}

- (MCTFriend *)serviceByOrganizationType:(MCTServiceOrganizationType)organizationType andIndex:(NSInteger)index
{
    T_DONTCARE();
    if (organizationType == MCTServiceOrganizationTypeUnspecified) {
        return [self friendByType:MCTFriendTypeService andIndex:index];
    }

    __block MCTFriend *friend;

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_int(stmtGetServicesByIndexAndOrganizationType_, 1, organizationType);
            sqlite3_bind_int64(stmtGetServicesByIndexAndOrganizationType_, 2, index);
            if ((e = sqlite3_step(stmtGetServicesByIndexAndOrganizationType_)) != SQLITE_ROW) {
                LOG(@"Failed to get friend with organizationType %d and index %d", organizationType, index);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            friend = [self friendWithStatement:stmtGetServicesByIndexAndOrganizationType_];
            [self addFriendToCache:friend];
        }
        @finally {
            sqlite3_reset(stmtGetServicesByIndexAndOrganizationType_);
        }
    }];
    
    return friend;
}

- (MCTFriend *)friendWithStatement:(sqlite3_stmt *)stmt
{
    T_DONTCARE();
    __block MCTFriend *friend;
    [self dbLockedOperationWithBlock:^{
        int i = 0;
        friend = [MCTFriend aFriend];
        friend.email = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, i++)];
        friend.name = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, i++)];
        friend.shareLocation = sqlite3_column_int(stmt, i++) == 1 ? YES : NO;
        friend.sharesLocation = sqlite3_column_int(stmt, i++) == 1 ? YES : NO;
        NSData *avatar = [NSData dataWithBytes:sqlite3_column_blob(stmt, i)
                                        length:sqlite3_column_bytes(stmt, i)];
        i++;
        if (avatar != nil && [avatar length] > 0)
            friend.avatar = avatar;
        friend.existence = sqlite3_column_int(stmt, i++);
        friend.type = sqlite3_column_int(stmt, i++);
        friend.descriptionX = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, i++)];
        friend.descriptionBranding = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, i++)];
        friend.pokeDescription = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, i++)];
        friend.qualifiedIdentifier = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, i++)];
        friend.organizationType = sqlite3_column_int(stmt, i++);
        friend.callbacks = sqlite3_column_int(stmt, i++);
        friend.flags = sqlite3_column_int(stmt, i++);
        friend.profileData = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, i++)];
        friend.contentBrandingHash = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, i++)];

        if (sqlite3_column_count(stmt) > i) {
            NSString *categoryId = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, i++)];
            if (![categoryId isEqualToString:friend.email]) {
                friend.category = [[MCTFriendCategory alloc] init];
                friend.category.idX = categoryId;
                friend.category.name = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmt, i++)];
                NSData *categoryAvatar = [NSData dataWithBytes:sqlite3_column_blob(stmt, i)
                                                        length:sqlite3_column_bytes(stmt, i)];
                i++;
                if (categoryAvatar != nil && [categoryAvatar length] > 0)
                    friend.category.avatarImage = [UIImage imageWithData:categoryAvatar];

                friend.category.friendCount = sqlite3_column_int(stmt, i++);
            }
        }
    }];
    return friend;
}

- (MCTFriend *)friendByEmail:(NSString *)email
{
    T_DONTCARE();
    __block MCTFriend *friend = [self getFriendFromCache:email];
    if (friend == MCTNull)
        return nil;
    else if (friend != nil)
        return friend;

    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtGetFriendByEmailUI_, 1, [email UTF8String], -1, NULL);

            int e = sqlite3_step(stmtGetFriendByEmailUI_);

            if (e == SQLITE_DONE) {
                friend = nil;
            } else if (e == SQLITE_ROW) {
                friend = [self friendWithStatement:stmtGetFriendByEmailUI_];
            } else {
                LOG(@"Failed to get friend with email %@", email);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtGetFriendByEmailUI_);
        }
    }];

    if (friend) {
        [self addFriendToCache:friend];
    } else {
        [self addNonFriendToCacheWithEmail:email];
    }

    return friend;
}

- (MCTFriend *)friendByEmailHash:(NSString *)emailHash
{
    T_DONTCARE();
    __block MCTFriend *friend;
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtGetFriendByEmailHashUI_, 1, [emailHash UTF8String], -1, NULL);

            int e = sqlite3_step(stmtGetFriendByEmailHashUI_);

            if (e == SQLITE_DONE) {
                friend = nil;
            } else if (e == SQLITE_ROW) {
                friend = [self friendWithStatement:stmtGetFriendByEmailHashUI_];
            } else {
                LOG(@"Failed to get friend with email_hash %@", emailHash);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtGetFriendByEmailHashUI_);
        }
    }];
    return friend;
}

- (NSString *)friendNameByEmail:(NSString *)email
{
    T_DONTCARE();
    MCTFriend *friend = [self friendByEmail:email];
    return friend.displayName;
}

- (NSArray *)friendNames
{
    T_DONTCARE();
    NSMutableArray *names = [NSMutableArray array];
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            while ((e = sqlite3_step(stmtGetFriendNamesUI_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get names of friends");
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                NSString *name = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFriendNamesUI_, 0)];
                if ([MCTUtils isEmptyOrWhitespaceString:name]) {
                    name = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFriendNamesUI_, 1)]; // email
                }
                [names addObject:name];
            }
        }
        @finally {
            sqlite3_reset(stmtGetFriendNamesUI_);
        }
    }];
    return names;
}

- (MCTFriendType)friendTypeByEmail:(NSString *)email
{
    T_DONTCARE();
    MCTFriend *friend = [self friendByEmail:email];
    if (friend)
        return (MCTFriendType)friend.type;

    __block MCTFriendType type;
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtGetFriendTypeByEmailUI_, 1, [email UTF8String], -1, NULL);
            int e = sqlite3_step(stmtGetFriendTypeByEmailUI_);
            if (e == SQLITE_DONE) {
                LOG(@"Friend type of %@ unknown", email);
                type = MCTFriendTypeUnknown;
            } else if (e == SQLITE_ROW) {
                type = sqlite3_column_int(stmtGetFriendTypeByEmailUI_, 0);
            } else {
                LOG(@"Failed to get friend type of %@", email);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtGetFriendTypeByEmailUI_);
        }
    }];
    return type;
}

- (NSData *)friendAvatarByEmail:(NSString *)email
{
    T_DONTCARE();
    MCTFriend *friend = [self friendByEmail:email];
    return friend.avatar;
}

#pragma mark -
#pragma mark Service Menu

- (void)operationRebuildServiceMenuWithFriend:(MCT_com_mobicage_to_friends_FriendTO *)friend cleanup:(BOOL)cleanup
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        if (cleanup) {
            [self operationDeleteServiceMenuForFriendEmail:friend.email];
        }

        if (friend.actionMenu.items != nil) {
            for (MCT_com_mobicage_to_friends_ServiceMenuItemTO *item in friend.actionMenu.items) {
                @try {
                    int e;

                    sqlite3_bind_text(stmtInsertServiceMenu_, 1, [friend.email UTF8String], -1, NULL);
                    sqlite3_bind_int(stmtInsertServiceMenu_, 2, [[item.coords objectAtIndex:0] intValue]);
                    sqlite3_bind_int(stmtInsertServiceMenu_, 3, [[item.coords objectAtIndex:1] intValue]);
                    sqlite3_bind_int(stmtInsertServiceMenu_, 4, [[item.coords objectAtIndex:2] intValue]);
                    sqlite3_bind_text(stmtInsertServiceMenu_, 5, [item.label UTF8String], -1, NULL);
                    sqlite3_bind_text(stmtInsertServiceMenu_, 6, [item.iconHash UTF8String], -1, NULL);
                    if ([MCTUtils isEmptyOrWhitespaceString:item.screenBranding])
                        sqlite3_bind_null(stmtInsertServiceMenu_, 7);
                    else
                        sqlite3_bind_text(stmtInsertServiceMenu_, 7, [item.screenBranding UTF8String], -1, NULL);
                    if ([MCTUtils isEmptyOrWhitespaceString:item.staticFlowHash])
                        sqlite3_bind_null(stmtInsertServiceMenu_, 8);
                    else
                        sqlite3_bind_text(stmtInsertServiceMenu_, 8, [item.staticFlowHash UTF8String], -1, NULL);
                    if ([MCTUtils isEmptyOrWhitespaceString:item.hashedTag])
                        sqlite3_bind_null(stmtInsertServiceMenu_, 9);
                    else
                        sqlite3_bind_text(stmtInsertServiceMenu_, 9, [item.hashedTag UTF8String], -1, NULL);

                    sqlite3_bind_int(stmtInsertServiceMenu_, 10, item.requiresWifi ? 1 : 0);
                    sqlite3_bind_int(stmtInsertServiceMenu_, 11, item.runInBackground ? 1 : 0);

                    if ((e = sqlite3_step(stmtInsertServiceMenu_)) != SQLITE_DONE) {
                        LOG(@"Failed to insert service menu item %@", item.coords);
                        MCT_THROW_SQL_EXCEPTION(e);
                    }
                }
                @finally {
                    sqlite3_reset(stmtInsertServiceMenu_);
                }

                if (![self isMenuIconAvailableWithHash:item.iconHash]) {
                    LOG(@"Requesting service menu icon %@", item.iconHash);
                    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                        [[MCTComponentFramework friendsPlugin] requestServiceMenuIcon:item withService:friend.email];
                    }];
                }

                if (item.staticFlowHash && ![self isStaticFlowAvailableWithHash:item.staticFlowHash]) {
                    LOG(@"Requesting service static flow %@", item.staticFlowHash);
                    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                        [[MCTComponentFramework friendsPlugin] requestStaticFlowWithItem:item andService:friend.email];
                    }];
                }

            }
            if (cleanup) {
                [self operationScrubMenuIcons];
                [self operationScrubStaticFlows];
            }
        }
    }];
}

- (BOOL)isMenuIconAvailableWithHash:(NSString *)hash
{
    T_DONTCARE();
    __block BOOL result;
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtCheckMenuIconAvailable_, 1, [hash UTF8String], -1, NULL);

            int e = sqlite3_step(stmtCheckMenuIconAvailable_);

            if (e != SQLITE_ROW) {
                LOG(@"Failed to get availability of menu icon %@", hash);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            result = sqlite3_column_int(stmtCheckMenuIconAvailable_, 0) > 0;
        }
        @finally {
            sqlite3_reset(stmtCheckMenuIconAvailable_);
        }
    }];
    return result;
}

- (void)operationScrubMenuIcons
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            while ((e = sqlite3_step(stmtGetMenuIconUsage_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    const char *errmsg = sqlite3_errmsg([MCTComponentFramework writeableDB]);
                    LOG(@"Failed to get service menu icon usage");
                    if (errmsg != NULL)
                        LOG(@"Details: %@", [NSString stringWithUTF8String:errmsg]);
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                NSString *iconHash = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenuIconUsage_, 0)];
                int used = sqlite3_column_int(stmtGetMenuIconUsage_, 1);
                if (used == 0) {
                    [self operationDeleteMenuIconWithHash:iconHash];
                } else {
                    LOG(@"Icon %@ is used %d times", iconHash, used);
                }
            }
        }
        @finally {
            sqlite3_reset(stmtGetMenuIconUsage_);
        }
    }];
}

- (void)operationDeleteMenuIconWithHash:(NSString *)iconHash
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        LOG(@"Deleting icons with hash %@", iconHash);
        @try {
            int e;

            sqlite3_bind_text(stmtDeleteMenuIcon_, 1, [iconHash UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtDeleteMenuIcon_)) != SQLITE_DONE) {
                LOG(@"Failed to delete menu icons with hash %@", iconHash);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtDeleteMenuIcon_);
        }
    }];
}

- (void)operationDeleteAllServiceMenus
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            if ((e = sqlite3_step(stmtDeleteAllServiceMenus_)) != SQLITE_DONE) {
                LOG(@"Failed to delete all service menus");
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtDeleteAllServiceMenus_);
        }
    }];
}

- (void)saveMenuIcon:(NSData *)icon withHash:(NSString *)iconHash
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtInsertMenuIcon_, 1, [iconHash UTF8String], -1, NULL);
            sqlite3_bind_blob(stmtInsertMenuIcon_, 2, [icon bytes], (int)[icon length], NULL);

            if ((e = sqlite3_step(stmtInsertMenuIcon_)) != SQLITE_DONE) {
                LOG(@"Failed to insert service menu icon %@", iconHash);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtInsertMenuIcon_);
        }
    }];
}

- (void)addMenuDetailsToService:(MCTFriend *)service
{
    T_DONTCARE();
    if (service.actionMenu == nil)
        service.actionMenu = [MCT_com_mobicage_to_friends_ServiceMenuTO transferObject];

    [self dbLockedOperationWithBlock:^{
        @try {

            int e;

            sqlite3_bind_text(stmtGetMenuDetails_, 1, [service.email UTF8String], -1, NULL);
            if ((e = sqlite3_step(stmtGetMenuDetails_)) == SQLITE_ROW) {
                service.actionMenu.phoneNumber = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenuDetails_, 0)];
                service.actionMenu.branding = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenuDetails_, 1)];
                service.name = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenuDetails_, 2)];

                service.actionMenu.share = (BOOL) sqlite3_column_int(stmtGetMenuDetails_, 3);
                service.actionMenuPageCount = 1 + sqlite3_column_int(stmtGetMenuDetails_, 4);

                service.generation = sqlite3_column_int(stmtGetMenuDetails_, 5);

                service.actionMenu.shareImageUrl = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenuDetails_, 6)];
                service.actionMenu.shareDescription = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenuDetails_, 7)];
                service.actionMenu.shareCaption = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenuDetails_, 8)];
                service.actionMenu.shareLinkUrl = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenuDetails_, 9)];
                service.actionMenu.aboutLabel = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenuDetails_, 10)];
                service.actionMenu.messagesLabel = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenuDetails_, 11)];
                service.actionMenu.callLabel = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenuDetails_, 12)];
                service.actionMenu.shareLabel = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenuDetails_, 13)];
                service.actionMenu.callConfirmation = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenuDetails_, 14)];

            } else if (e != SQLITE_DONE) {
                LOG(@"Failed to get menu details for service %@", service.email);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            NSMutableArray *items = [NSMutableArray array];
            sqlite3_bind_text(stmtGetMenu_, 1, [service.email UTF8String], -1, NULL);
            while ((e = sqlite3_step(stmtGetMenu_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get service menu of %@", service.email);
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                MCTServiceMenuItem *smi = [[MCTServiceMenuItem alloc] init];
                NSMutableArray *coords = [NSMutableArray arrayWithCapacity:3];
                [coords addObject:[NSNumber numberWithInt:sqlite3_column_int(stmtGetMenu_, 0)]];
                [coords addObject:[NSNumber numberWithInt:sqlite3_column_int(stmtGetMenu_, 1)]];
                [coords addObject:[NSNumber numberWithInt:sqlite3_column_int(stmtGetMenu_, 2)]];
                smi.coords = coords;
                smi.label = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenu_, 3)];
                NSData *icon = [NSData dataWithBytes:sqlite3_column_blob(stmtGetMenu_, 4)
                                              length:sqlite3_column_bytes(stmtGetMenu_, 4)];
                if (icon != nil && [icon length] > 0)
                    smi.icon = icon;

                smi.screenBranding = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenu_, 5)];
                smi.staticFlowHash = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenu_, 6)];
                smi.hashedTag = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetMenu_, 7)];
                smi.requiresWifi = sqlite3_column_int(stmtGetMenu_, 8) == 1;
                smi.runInBackground = sqlite3_column_int(stmtGetMenu_, 9) == 1;

                [items addObject:smi];
            }
            service.actionMenu.items = items;
        }
        @finally {
            sqlite3_reset(stmtGetMenuDetails_);
            sqlite3_reset(stmtGetMenu_);
        }

    }];
}

- (void)saveCategory:(MCT_com_mobicage_to_friends_FriendCategoryTO *)category
{
    T_DONTCARE();
    NSData *avatar = [NSData dataFromBase64String:category.avatar];

    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtCategoryInsert_, 1, [category.guid UTF8String], -1, NULL);
            sqlite3_bind_text(stmtCategoryInsert_, 2, [category.name UTF8String], -1, NULL);
            sqlite3_bind_blob(stmtCategoryInsert_, 3, [avatar bytes], (int)[avatar length], NULL);

            int e = sqlite3_step(stmtCategoryInsert_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to insert service_category %@", category);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtCategoryInsert_);
        }
    }];
}

- (BOOL)categoryExistsWithId:(NSString *)categoryId
{
    T_DONTCARE();
    __block BOOL categoryExists = NO;
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtCategoryExists_, 1, [categoryId UTF8String], -1, NULL);

            int e = sqlite3_step(stmtCategoryExists_);

            if (e != SQLITE_ROW) {
                LOG(@"Failed to count service_category %@", categoryId);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            categoryExists = sqlite3_column_int(stmtCategoryExists_, 0) > 0;
        }
        @finally {
            sqlite3_reset(stmtCategoryExists_);
        }
    }];
    return categoryExists;
}

- (void)saveStaticFlow:(NSString *)b64StaticFlow withHash:(NSString *)staticFlowHash
{
    T_DONTCARE();
    NSData *staticFlow = [NSData dataFromBase64String:b64StaticFlow];

    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtStaticFlowInsert_, 1, [staticFlowHash UTF8String], -1, NULL);
            sqlite3_bind_blob(stmtStaticFlowInsert_, 2, [staticFlow bytes], (int)[staticFlow length], NULL);

            int e = sqlite3_step(stmtStaticFlowInsert_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to insert service_static_flow %@", staticFlowHash);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtStaticFlowInsert_);
        }
    }];
}

- (NSString *)staticFlowWithHash:(NSString *)staticFlowHash
{
    T_DONTCARE();
    __block NSString *staticFlowHTML = nil;

    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtStaticFlowGet_, 1, [staticFlowHash UTF8String], -1, NULL);

            int e = sqlite3_step(stmtStaticFlowGet_);

            if (e == SQLITE_DONE) {
                LOG(@"No static flow found with hash %@", staticFlowHash);
            } else if (e != SQLITE_ROW) {
                LOG(@"Failed to get static flow with hash %@", staticFlowHash);
                MCT_THROW_SQL_EXCEPTION(e);
            } else {
                NSData *flow = [NSData dataWithBytes:sqlite3_column_blob(stmtStaticFlowGet_, 0)
                                              length:sqlite3_column_bytes(stmtStaticFlowGet_, 0)];
                if (flow && [flow length] > 0) {
                    NSData *unzippedFlow = [NSData gtm_dataByInflatingData:flow];
                    if (unzippedFlow && [unzippedFlow length] > 0) {
                        staticFlowHTML = [NSString stringWithData:unzippedFlow encoding:NSUTF8StringEncoding];
                    } else {
                        NSString *zippedFlowString = [NSString stringWithData:flow encoding:NSUTF8StringEncoding];
                        ERROR(@"Failed to inflate zippedFlowString: %@", zippedFlowString);
                    }
                }
            }
        }
        @finally {
            sqlite3_reset(stmtStaticFlowGet_);
        }
    }];

    return staticFlowHTML;
}

- (BOOL)isStaticFlowAvailableWithHash:(NSString *)hash
{
    T_DONTCARE();
    __block BOOL result;
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtStaticFlowCheckAvailable_, 1, [hash UTF8String], -1, NULL);

            int e = sqlite3_step(stmtStaticFlowCheckAvailable_);

            if (e != SQLITE_ROW) {
                LOG(@"Failed to get availability of menu icon %@", hash);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            result = sqlite3_column_int(stmtStaticFlowCheckAvailable_, 0) > 0;
        }
        @finally {
            sqlite3_reset(stmtStaticFlowCheckAvailable_);
        }
    }];
    return result;
}

- (void)operationScrubStaticFlows
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            while ((e = sqlite3_step(stmtStaticFlowGetUsage_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get service menu icon usage");
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                NSString *hash = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtStaticFlowGetUsage_, 0)];
                int usedInSmi = sqlite3_column_int(stmtStaticFlowGetUsage_, 1);
                int usedInMfr = sqlite3_column_int(stmtStaticFlowGetUsage_, 2);
                LOG(@"Flow %@ is used %d times", hash, usedInSmi + usedInMfr);
                if (usedInSmi == 0 && usedInMfr == 0) {
                    [self operationDeleteStaticFlowWithHash:hash];
                }
            }
        }
        @finally {
            sqlite3_reset(stmtStaticFlowGetUsage_);
        }
    }];
}

- (void)operationDeleteStaticFlowWithHash:(NSString *)hash
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        LOG(@"Deleting static flows with hash %@", hash);
        @try {
            int e;

            sqlite3_bind_text(stmtStaticFlowDelete_, 1, [hash UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtStaticFlowDelete_)) != SQLITE_DONE) {
                LOG(@"Failed to delete static flows with hash %@", hash);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtStaticFlowDelete_);
        }
    }];
}

- (NSArray *)friendDataStringsWithEmail:(NSString *)email
{
    T_DONTCARE();
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtDataGet_, 1, [email UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtDataGet_)) != SQLITE_ROW) {
                LOG(@"Failed to get data for service %@", email);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            NSString *userDataString = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtDataGet_, 0)];
            [array addObject:([MCTUtils isEmptyOrWhitespaceString:userDataString] ? MCTNull : userDataString)];

            NSString *appDataString = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtDataGet_, 1)];
            [array addObject:([MCTUtils isEmptyOrWhitespaceString:appDataString] ? MCTNull : appDataString)];
        }
        @finally {
            sqlite3_reset(stmtDataGet_);
        }
    }];

    return array;
}

- (NSArray *)friendDataWithEmail:(NSString *)email
{
    T_DONTCARE();
    NSArray *dataStrings = [self friendDataStringsWithEmail:email];
    if (dataStrings == nil) {
        return nil;
    }

    NSMutableArray *data = [NSMutableArray arrayWithCapacity:dataStrings.count];
    for (int i = 0; i < dataStrings.count; i++) {
        if ([dataStrings objectAtIndex:i] == MCTNull) {
            [data addObject:[NSDictionary dictionary]];
        } else {
            [data addObject:[[dataStrings objectAtIndex:i] MCT_JSONValue]];
        }
    }

    return data;
}

- (void)updateUserData:(NSString *)userDataJSONString withService:(NSString*)email
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            if (userDataJSONString == nil) {
                sqlite3_bind_null(stmtUpdateServiceUserData_, 1);
            } else {
                sqlite3_bind_text(stmtUpdateServiceUserData_, 1, [userDataJSONString UTF8String], -1, NULL);
            }
            sqlite3_bind_text(stmtUpdateServiceUserData_, 2, [email UTF8String], -1, NULL);

            int e = sqlite3_step(stmtUpdateServiceUserData_);
            if (e != SQLITE_DONE) {
                LOG(@"Failed to update userData for service %@ to %@", email, userDataJSONString);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateServiceUserData_);
        }
    }];
}

- (void)updateAppData:(NSString *)appDataJSONString withService:(NSString*)email
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            if (appDataJSONString == nil) {
                sqlite3_bind_null(stmtUpdateServiceAppData_, 1);
            } else {
                sqlite3_bind_text(stmtUpdateServiceAppData_, 1, [appDataJSONString UTF8String], -1, NULL);
            }
            sqlite3_bind_text(stmtUpdateServiceAppData_, 2, [email UTF8String], -1, NULL);

            int e = sqlite3_step(stmtUpdateServiceAppData_);
            if (e != SQLITE_DONE) {
                LOG(@"Failed to update userData for service %@ to %@", email, appDataJSONString);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateServiceAppData_);
        }
    }];
}

- (void)updateUserData:(NSString *)userDataJSONString
               appData:(NSString *)appDataJSONString
            forService:(NSString *)email
            withIntent:(BOOL)mustBroadcastIntent
{
    T_DONTCARE();
    BOOL userDataUpdated = userDataJSONString != nil;
    BOOL appDataUpdated = appDataJSONString != nil;

    if (userDataUpdated && appDataUpdated) {
        [self dbLockedOperationWithBlock:^{
            @try {
                sqlite3_bind_text(stmtUpdateServiceData_, 1, [userDataJSONString UTF8String], -1, NULL);
                sqlite3_bind_text(stmtUpdateServiceData_, 2, [appDataJSONString UTF8String], -1, NULL);
                sqlite3_bind_text(stmtUpdateServiceData_, 3, [email UTF8String], -1, NULL);

                int e = sqlite3_step(stmtUpdateServiceData_);
                if (e != SQLITE_DONE) {
                    LOG(@"Failed to update data for service %@", email);
                    MCT_THROW_SQL_EXCEPTION(e);
                }
            }
            @finally {
                sqlite3_reset(stmtUpdateServiceData_);
            }
        }];
    } else if (userDataUpdated) {
        [self updateUserData:userDataJSONString withService:email];
    } else if (appDataUpdated) {
        [self updateAppData:appDataJSONString withService:email];
    } else {
        return;
    }

    if (mustBroadcastIntent) {
        [self broadcastDataUpdatedForService:email
                             userDataUpdated:userDataUpdated
                              appDataUpdated:appDataUpdated];
    }
}

- (void)broadcastDataUpdatedForService:(NSString *)service
                       userDataUpdated:(BOOL)userDataUpdated
                        appDataUpdated:(BOOL)appDataUpdated
{
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_SERVICE_DATA_UPDATED];
    [intent setString:service forKey:@"email"];
    [intent setBool:userDataUpdated forKey:@"user_data"];
    [intent setBool:appDataUpdated forKey:@"service_data"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (MCTlong)insertServiceApiCallWithService:(NSString *)service
                                      item:(NSString *)item
                                    method:(NSString *)method
                                       tag:(NSString *)tag
                                    status:(MCTServiceApiCallStatus)status
{
    T_DONTCARE();
    __block MCTlong rowId;
    [self dbLockedOperationWithBlock:^{
        @try {
            int i = 1;
            sqlite3_bind_text(stmtServiceApiCallInsert_, i++, [service UTF8String], -1, NULL);
            sqlite3_bind_text(stmtServiceApiCallInsert_, i++, [item UTF8String], -1, NULL);
            sqlite3_bind_text(stmtServiceApiCallInsert_, i++, [method UTF8String], -1, NULL);
            sqlite3_bind_text(stmtServiceApiCallInsert_, i++, [tag UTF8String], -1, NULL);
            sqlite3_bind_int(stmtServiceApiCallInsert_, i++, status);

            int e = sqlite3_step(stmtServiceApiCallInsert_);
            if (e != SQLITE_DONE) {
                LOG(@"Failed to insert service api call");
                MCT_THROW_SQL_EXCEPTION(e);
            }

            rowId = sqlite3_last_insert_rowid(self.dbMgr.writeableDB);
        }
        @finally {
            sqlite3_reset(stmtServiceApiCallInsert_);
        }
    }];
    return rowId;
}

- (MCTServiceApiCallbackResult *)updateServiceApiCallWithId:(MCTlong)idX
                                                      error:(NSString *)error
                                                     result:(NSString *)result
                                                     status:(MCTServiceApiCallStatus)status
{
    T_DONTCARE();
    __block MCTServiceApiCallbackResult *r;

    [self dbLockedTransactionWithBlock:^{
        int e ;

        @try {
            sqlite3_bind_int64(stmtServiceApiCallGetById_, 1, idX);

            if ((e = sqlite3_step(stmtServiceApiCallGetById_)) == SQLITE_ROW) {
                int i = 0;
                r = [[MCTServiceApiCallbackResult alloc] init];
                r.service = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtServiceApiCallGetById_, i++)];
                r.item = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtServiceApiCallGetById_, i++)];
                r.method = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtServiceApiCallGetById_, i++)];
                r.tag = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtServiceApiCallGetById_, i++)];
            } else if (e == SQLITE_DONE) {
                r = nil;
                return;
            } else {
                LOG(@"Error retrieving service_api_call by id '%d'", idX);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtServiceApiCallGetById_);
        }

        @try {
            int i = 1;
            if (result == nil) {
                sqlite3_bind_null(stmtServiceApiCallSetResult_, i++);
            } else {
                sqlite3_bind_text(stmtServiceApiCallSetResult_, i++, [result UTF8String], -1, NULL);
            }
            if (error == nil) {
                sqlite3_bind_null(stmtServiceApiCallSetResult_, i++);
            } else {
                sqlite3_bind_text(stmtServiceApiCallSetResult_, i++, [error UTF8String], -1, NULL);
            }
            sqlite3_bind_int(stmtServiceApiCallSetResult_, i++, status);
            sqlite3_bind_int64(stmtServiceApiCallSetResult_, i++, idX);

            if ((e = sqlite3_step(stmtServiceApiCallSetResult_)) != SQLITE_DONE) {
                LOG(@"Failed to update service_api_call result with id '%@'", idX);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtServiceApiCallSetResult_);
        }
    }];

    return r;
}

- (NSArray *)serviceApiCallbackResulstWithService:(NSString *)service item:(NSString *)item
{
    T_DONTCARE();
    NSMutableArray *results = [NSMutableArray array];

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtServiceApiCallGetByItem_, 1, [service UTF8String], -1, NULL);
            sqlite3_bind_text(stmtServiceApiCallGetByItem_, 2, [item UTF8String], -1, NULL);

            while ((e = sqlite3_step(stmtServiceApiCallGetByItem_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to loop over service_api_calls for service %@ and item %@", service, item);
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                int i = 0;
                MCTServiceApiCallbackResult *r = [[MCTServiceApiCallbackResult alloc] init];
                r.idX = sqlite3_column_int64(stmtServiceApiCallGetByItem_, i++);
                r.method = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtServiceApiCallGetByItem_, i++)];
                r.result = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtServiceApiCallGetByItem_, i++)];
                r.error = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtServiceApiCallGetByItem_, i++)];
                r.tag = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtServiceApiCallGetByItem_, i++)];
                [results addObject:r];
            }
        }
        @finally {
            sqlite3_reset(stmtServiceApiCallGetByItem_);
        }
    }];

    return results;
}

- (void)removeServiceApiCallWithId:(MCTlong)idX
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_int64(stmtServiceApiCallRemove_, 1, idX);

            int e = sqlite3_step(stmtServiceApiCallRemove_);
            if (e != SQLITE_DONE) {
                LOG(@"Failed to remove service_api_call with id '%d'", idX);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtServiceApiCallRemove_);
        }
    }];
}

#pragma mark - Cache Access

- (void)addFriendToCache:(MCTFriend *)friend
{
    T_DONTCARE();
    if (friend == nil || friend.email == nil) {
        ERROR(@"Trying to add a NULL friend in the cache");
        return;
    }

    [self.friendCache setObject:friend forKey:friend.email];
}

- (void)addNonFriendToCacheWithEmail:(NSString *)email
{
    T_DONTCARE();
    if (email == nil) {
        ERROR(@"Trying to add a NULL friend in the cache");
        return;
    }

    [self.friendCache setObject:MCTNull forKey:email];
}

- (MCTFriend *)getFriendFromCache:(NSString *)email
{
    T_DONTCARE();
    MCTFriend *friend = [self.friendCache objectForKey:email];
    return friend;
}

- (void)removeFriendFromCache:(NSString *)email
{
    T_DONTCARE();
    [self.friendCache removeObjectForKey:email];
}

#pragma mark - NSCacheDelegate

- (void)cache:(NSCache *)cache willEvictObject:(MCTFriend *)friend
{
    T_DONTCARE();
    LOG(@"FriendCache willEvictObject:%@", (friend && friend != MCTNull) ? friend.email : friend);
}

#pragma mark -

- (MCTFriendBroadcastInfo *)broadcastInfoWithFriend:(NSString *)email
{
    T_DONTCARE();

    __block MCTFriendBroadcastInfo *fbi;

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;
            sqlite3_bind_text(stmtGetFriendBroadcastInfo_, 1, [email UTF8String], -1, NULL);
            if ((e = sqlite3_step(stmtGetFriendBroadcastInfo_)) == SQLITE_ROW) {
                int i = 0;

                MCTServiceMenuItem *smi = [[MCTServiceMenuItem alloc] init];
                NSMutableArray *coords = [NSMutableArray arrayWithCapacity:3];
                [coords addObject:[NSNumber numberWithInt:sqlite3_column_int(stmtGetFriendBroadcastInfo_, 0)]];
                [coords addObject:[NSNumber numberWithInt:sqlite3_column_int(stmtGetFriendBroadcastInfo_, 1)]];
                [coords addObject:[NSNumber numberWithInt:sqlite3_column_int(stmtGetFriendBroadcastInfo_, 2)]];
                smi.coords = coords;
                smi.staticFlowHash = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFriendBroadcastInfo_, 3)];
                smi.hashedTag = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFriendBroadcastInfo_, 4)];
                MCTlong generation = sqlite3_column_int(stmtGetFriendBroadcastInfo_, 5);
                smi.label = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFriendBroadcastInfo_, 6)];

                fbi = [MCTFriendBroadcastInfo friendBroadcastInfoWithGeneration:generation serviceMenuItem:smi];
            } else if (e == SQLITE_DONE) {
                fbi = nil;
                return;
            } else {
                LOG(@"Error retrieving friend broadcast info with email '%@'", email);
                MCT_THROW_SQL_EXCEPTION(e);
                fbi = nil;
                return;
            }
        }
        @finally {
            sqlite3_reset(stmtGetFriendBroadcastInfo_);
        }
    }];
    return fbi;
}

#pragma mark - Groups

- (MCTGroup *)getGroupWithGuid:(NSString *)guid
{
    T_DONTCARE();

    __block MCTGroup *group = nil;
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;
            sqlite3_bind_text(stmtGetGroup_, 1, [guid UTF8String], -1, NULL);
            while ((e = sqlite3_step(stmtGetGroup_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get group with id %@", guid);
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                NSString *email = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetGroup_, 4)];

                if (group == nil) {
                    NSString *guid = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetGroup_, 0)];
                    NSString *name = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetGroup_, 1)];
                    NSData *avatar = [NSData dataWithBytes:sqlite3_column_blob(stmtGetGroup_, 2)
                                                    length:sqlite3_column_bytes(stmtGetGroup_, 2)];
                    NSString *avatarHash = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetGroup_, 3)];

                    NSMutableArray *members = [NSMutableArray array];
                    if (email != nil) {
                        [members addObject:email];
                    }
                    group = [MCTGroup groupWithGuid:guid name:name members:members avatar:avatar avatarHash:avatarHash];
                } else {
                    if (email != nil) {
                        [group.members addObject:email];
                    }
                }
            }
        }
        @finally {
            sqlite3_reset(stmtGetGroup_);
        }
    }];

    return group;
}

- (void)clearGroups
{
    T_DONTCARE();
    [self dbLockedTransactionWithBlock:^{
        @try {
            int e = sqlite3_step(stmtClearGroup_);
            if (e != SQLITE_DONE) {
                LOG(@"Failed to clear groups");
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtClearGroup_);
        }

        @try {
            int e = sqlite3_step(stmtClearGroupMember_);
            if (e != SQLITE_DONE) {
                LOG(@"Failed to clear group members");
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtClearGroupMember_);
        }
    }];
}

- (void)clearEmptyGroups
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e = sqlite3_step(stmtClearEmptyGroup_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to clear empty groups");
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtClearEmptyGroup_);
        }
    }];
}

- (void)clearGroupMemberByEmail:(NSString *)email
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtClearGroupMemberByEmail_, 1, [email UTF8String], -1, NULL);
            int e = sqlite3_step(stmtClearGroupMemberByEmail_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to delete group member by email '%@'", email);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtClearGroupMemberByEmail_);
        }
    }];
}

- (NSDictionary *)getGroups
{
    T_DONTCARE();
    NSMutableDictionary *groups = [NSMutableDictionary dictionary];

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;
            while ((e = sqlite3_step(stmtGetGroups_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get all groups");
                    MCT_THROW_SQL_EXCEPTION(e);
                }
                NSString *guid = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetGroups_, 0)];
                NSString *name = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetGroups_, 1)];
                NSData *avatar = [NSData dataWithBytes:sqlite3_column_blob(stmtGetGroups_, 2)
                                                length:sqlite3_column_bytes(stmtGetGroups_, 2)];
                NSString *avatarHash = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetGroups_, 3)];
                NSMutableArray *members = [NSMutableArray array];
                MCTGroup *g = [MCTGroup groupWithGuid:guid name:name members:members avatar:avatar avatarHash:avatarHash];
                [groups setObject:g forKey:guid];
            }
        }
        @finally {
            sqlite3_reset(stmtGetGroups_);
        }
    }];

    return groups;
}

- (void)insertGroupAvatar:(NSData *)avatar hash:(NSString *)avatarHash
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_blob(stmtInsertGroupAvatar_, 1, [avatar bytes], (int)[avatar length], NULL);
            sqlite3_bind_text(stmtInsertGroupAvatar_, 2, [avatarHash UTF8String], -1, NULL);
            int e = sqlite3_step(stmtInsertGroupAvatar_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to update group avatar with hash '%@'", avatarHash);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtInsertGroupAvatar_);
        }
    }];
}

- (void)insertGroupAvatarHash:(NSString *)avatarHash guid:(NSString *)guid
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtInsertGroupAvatarHash_, 1, [avatarHash UTF8String], -1, NULL);
            sqlite3_bind_text(stmtInsertGroupAvatarHash_, 2, [guid UTF8String], -1, NULL);
            int e = sqlite3_step(stmtInsertGroupAvatarHash_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to update avatar_hash '%@' for group '%@'", avatarHash, guid);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtInsertGroupAvatarHash_);
        }
    }];
}

- (void)insertGroupWithGuid:(NSString *)guid
                       name:(NSString *)name
                     avatar:(NSData *)avatar
                 avatarHash:(NSString *)avatarHash
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtInsertGroup_, 1, [guid UTF8String], -1, NULL);
            sqlite3_bind_text(stmtInsertGroup_, 2, [name UTF8String], -1, NULL);
            sqlite3_bind_blob(stmtInsertGroup_, 3, [avatar bytes], (int)[avatar length], NULL);
            sqlite3_bind_text(stmtInsertGroup_, 4, [avatarHash UTF8String], -1, NULL);
            int e = sqlite3_step(stmtInsertGroup_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to insert group with name '%@'", name);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtInsertGroup_);
        }
    }];
}

- (void)updateGroupWithGuid:(NSString *)guid
                       name:(NSString *)name
                     avatar:(NSData *)avatar
                 avatarHash:(NSString *)avatarHash
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtUpdateGroup_, 1, [name UTF8String], -1, NULL);
            sqlite3_bind_blob(stmtUpdateGroup_, 2, [avatar bytes], (int)[avatar length], NULL);
            sqlite3_bind_text(stmtUpdateGroup_, 3, [avatarHash UTF8String], -1, NULL);
            sqlite3_bind_text(stmtUpdateGroup_, 4, [guid UTF8String], -1, NULL);
            int e = sqlite3_step(stmtUpdateGroup_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to update group with guid %@", guid);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateGroup_);
        }
    }];
}

- (void)deleteGroupWithGuid:(NSString *)guid
{
    T_DONTCARE();
    [self dbLockedTransactionWithBlock:^{
        @try {
            sqlite3_bind_text(stmtDeleteGroup_, 1, [guid UTF8String], -1, NULL);
            int e = sqlite3_step(stmtDeleteGroup_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to delete group with guid: %@", guid);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtDeleteGroup_);
        }

        @try {
            sqlite3_bind_text(stmtDeleteGroupMembers_, 1, [guid UTF8String], -1 , NULL);
            int e = sqlite3_step(stmtDeleteGroupMembers_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to delete group members with group_id: %@", guid);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtDeleteGroupMembers_);
        }
    }];
}

- (void)insertGroupMemberWithGroupGuid:(NSString *)guid email:(NSString *)email
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtInsertGroupMember_, 1, [guid UTF8String], -1, NULL);
            sqlite3_bind_text(stmtInsertGroupMember_, 2, [email UTF8String], -1, NULL);
            int e = sqlite3_step(stmtInsertGroupMember_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to insert group member %@ with guid %@", email, guid);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtInsertGroupMember_);
        }
    }];
}

- (void)deleteGroupMemberWithGroupGuid:(NSString *)guid email:(NSString *)email
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            sqlite3_bind_text(stmtDeleteGroupMember_, 1, [guid UTF8String], -1, NULL);
            sqlite3_bind_text(stmtDeleteGroupMember_, 2, [email UTF8String], -1, NULL);
            int e = sqlite3_step(stmtDeleteGroupMember_);

            if (e != SQLITE_DONE) {
                LOG(@"Failed to delete group member %@ with guid: %@", email, guid);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtDeleteGroupMember_);
        }
    }];
}

@end