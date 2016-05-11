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

#import "MCTGroup.h"
#import "NSData+Base64.h"


#define LONG_ERROR_VALUE -1LL

@implementation MCTGroup


+ (MCTGroup *)groupWithGuid:(NSString *)guid
                       name:(NSString *)name
                    members:(NSMutableArray *)members
                     avatar:(NSData *)avatar
                 avatarHash:(NSString *)avatarHash
{
    MCTGroup *group = [[MCTGroup alloc] init];
    group.guid = guid;
    group.name = name;
    group.members = members;
    group.avatar = avatar;
    group.avatarHash = avatarHash;
    return group;
}

- (UIImage *)avatarImage
{
    if (self.avatar != nil && [self.avatar length] > 0) {
        return [UIImage imageWithData:self.avatar];
    } else {
        return [UIImage imageNamed:@"group.png"];
    }
}

# pragma mark - IJSONable

- (id)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        NSString *guid = [dict stringForKey:@"guid"];
        if (guid == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"guid"];
        self.guid = guid;

        NSString *name = [dict stringForKey:@"name"];
        if (name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        self.name = name;

        NSMutableArray *members = [NSMutableArray arrayWithArray:[dict arrayForKey:@"members"]];
        if (members == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"members"];
        for (id obj in members) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"members"];
        }
        self.members = members;

        NSString *avatar = [dict stringForKey:@"avatar"];
        if (avatar == nil) {
            self.avatar = nil;
        } else {
            self.avatar = [NSData dataFromBase64String:avatar];
        }

        self.avatarHash = [dict stringForKey:@"avatarHash"];
    }
    return self;
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.guid == nil) {
        ERROR(@"nil value not supported for string field MCTGroup.guid");
    } else {
        [dict setString:self.guid forKey:@"guid"];
    }

    if (self.name == nil) {
        ERROR(@"nil value not supported for string field MCTGroup.name");
    } else {
        [dict setString:self.name forKey:@"name"];
    }

    if (self.members == nil) {
        ERROR(@"nil value not supported for array field MCTGroup.members");
    } else if ([self.members isKindOfClass:MCTArrayClass]) {
        [dict setArray:self.members forKey:@"members"];
    } else {
        ERROR(@"expecting array field MCTGroup.members");
    }

    if (self.avatar == nil) {
        [dict setString:nil forKey:@"avatar"];
    } else {
        [dict setString:[self.avatar base64EncodedString] forKey:@"avatar"];
    }

    [dict setString:self.avatarHash forKey:@"avatarHash"];

    return dict;
}

@end