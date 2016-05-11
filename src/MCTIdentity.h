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


typedef enum  {
    MCTIdentityGenderUnknown = 0,
    MCTIdentityGenderMale = 1,
    MCTIdentityGenderFemale = 2,
    MCTIdentityGenderCustomFacebook = 3,
} MCTIdentityGender;

@interface MCTIdentity : MCT_com_mobicage_to_system_IdentityTO

@property(nonatomic, strong) NSData *avatar;
@property(nonatomic, copy) NSString *emailHash;
@property(nonatomic, copy) NSString *shortUrl;

+ (MCTIdentity *)identity;
+ (MCTIdentity *)identityFromIdentity:(MCTIdentity *)otherIdentity;

- (NSDictionary *)getProfileDataDict;

@end


#pragma mark -

@interface MCT_com_mobicage_to_system_IdentityTO (MCTIdentityAdditions)

- (NSString *)displayEmail;
- (NSString *)displayName;

@end