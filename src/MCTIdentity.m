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

#import "MCTIdentity.h"
#import "MCTUtils.h"


@interface MCTIdentity ()

@property (nonatomic, strong) NSDictionary *cachedProfileDataDict;

@end

@implementation MCTIdentity


+ (MCTIdentity *)identity
{
    return [[MCTIdentity alloc] init];
}

+ (MCTIdentity *)identityFromIdentity:(MCTIdentity *)otherIdentity
{
    MCTIdentity *identity = [[MCTIdentity alloc] initWithDict:[otherIdentity dictRepresentation]];
    identity.avatar = otherIdentity.avatar;
    return identity;
}

- (id)initWithDict:(NSDictionary *)dict
{
    if (self = [super initWithDict:dict]) {
        self.emailHash = [dict stringForKey:@"emailHash"];
        self.shortUrl = [dict stringForKey:@"shortUrl"];
    }
    return self;
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:[super dictRepresentation]];
    [d setString:self.emailHash forKey:@"emailHash"];
    [d setString:self.shortUrl forKey:@"shortUrl"];
    return d;
}

- (NSDictionary *)getProfileDataDict
{
    if (self.cachedProfileDataDict == nil) {
        self.cachedProfileDataDict = [self.profileData MCT_JSONValue];
    }
    return self.cachedProfileDataDict;
}

@end


#pragma mark -

@implementation MCT_com_mobicage_to_system_IdentityTO (MCTIdentityAdditions)

- (NSString *)displayEmail
{
    T_DONTCARE();
    return [MCTUtils isEmptyOrWhitespaceString:self.qualifiedIdentifier] ? self.email : self.qualifiedIdentifier;
}

- (NSString *)displayName
{
    T_DONTCARE();
    return [MCTUtils isEmptyOrWhitespaceString:self.name] ? [self displayEmail] : self.name;
}

@end