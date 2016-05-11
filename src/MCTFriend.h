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

#import "MCTTransferObjects.h"
#import "MCTFriendCategory.h"

typedef enum {
    MCTFriendExistenceActive = 0,
    MCTFriendExistenceDeletePending = 1,
    MCTFriendExistenceDeleted = 2,
    MCTFriendExistenceNotFound = 3,
    MCTFriendExistenceInvitePending = 4
} MCTFriendExistence;

typedef enum  {
    MCTFriendTypeUnknown = 0,
    MCTFriendTypeUser = 1,
    MCTFriendTypeService = 2,
} MCTFriendType;

typedef enum {
    MCTServiceApiCallStatusSent = 0,
    MCTServiceApiCallStatusAnswered = 1
} MCTServiceApiCallStatus;

typedef enum {
    MCTServiceOrganizationTypeUnspecified = -1,
    MCTServiceOrganizationTypeNonProfit = 1,
    MCTServiceOrganizationTypeProfit = 2,
    MCTServiceOrganizationTypeCity = 3,
    MCTServiceOrganizationTypeEmergency = 4,
} MCTServiceOrganizationType;

typedef enum {
    MCTServiceCallbackFriendInviteResult = 1,
    MCTServiceCallbackFriendInvited = 2,
    MCTServiceCallbackFriendBrokeUp = 4,
    MCTServiceCallbackFriendInReach = 512,
    MCTServiceCallbackFriendOutOfReach = 1024,
    MCTServiceCallbackMessagingReceived = 8,
    MCTServiceCallbackMessagingPoke = 16,
    MCTServiceCallbackMessagingAcknowledged = 128,
    MCTServiceCallbackMessagingFlowMemberResult = 64,
    MCTServiceCallbackMessagingFormAcknowledged = 32,
    MCTServiceCallbackSystemApiCall = 256,
} MCTServiceCallback;

typedef enum {
    MCTFriendFlagNotRemovable = 1
} MCTFriendFlag;

#pragma mark -

@interface MCTFriend : MCT_com_mobicage_to_friends_FriendTO <NSCoding>

@property(nonatomic, strong) NSData *avatar;
@property(nonatomic, assign) NSInteger actionMenuPageCount;
@property(nonatomic, strong) MCTFriendCategory *category;

+ (MCTFriend *)friendWithFriendTO:(MCT_com_mobicage_to_friends_FriendTO *)friendTO;
+ (MCTFriend *)aFriend;
- (UIImage *)avatarImage;

@end


#pragma mark -

@interface MCT_com_mobicage_to_friends_FriendTO (MCTFriendAdditions)

- (NSString *)displayName;
- (NSString *)displayEmail;
- (BOOL)branded;

- (NSDictionary *)getProfileDataDict;

@end