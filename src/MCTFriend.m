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

#import "MCTFriend.h"
#import "MCTUtils.h"

#define MCT_PICKLE_FRIEND_DICT @"dict"
#define MCT_FRIEND_AVATAR @"avatar"
#define MCT_FRIEND_MENU_PAGES @"actionMenuPageCount"


@implementation MCTFriend


+ (MCTFriend *)friendWithFriendTO:(MCT_com_mobicage_to_friends_FriendTO *)friendTO
{
    return [[MCTFriend alloc] initWithDict:[friendTO dictRepresentation]];
}

+ (MCTFriend *)aFriend
{
    MCTFriend *friend = [[MCTFriend alloc] init];
    friend.organizationType = 0;
    friend.callbacks = 0;
    friend.flags = 0;
    friend.versions = @[];
    return friend;
}

- (MCTFriend *)initWithDict:(NSDictionary *)dict
{
    if (self = [super initWithDict:dict]) {
        self.avatar = [dict objectForKey:MCT_FRIEND_AVATAR];
        if ([dict containsKey:MCT_FRIEND_MENU_PAGES]) {
            self.actionMenuPageCount = [dict longForKey:MCT_FRIEND_MENU_PAGES];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    NSDictionary *dict = [coder decodeObjectForKey:MCT_PICKLE_FRIEND_DICT];
    return [self initWithDict:dict];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    [coder encodeObject:[self dictRepresentation] forKey:MCT_PICKLE_FRIEND_DICT];
}

- (NSDictionary *)dictRepresentation
{
    T_DONTCARE()
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictRepresentation]];
    [dict setObject:self.avatar ? self.avatar : MCTNull forKey:MCT_FRIEND_AVATAR];
    [dict setLong:self.actionMenuPageCount forKey:MCT_FRIEND_MENU_PAGES];
    return dict;
}

- (UIImage *)avatarImage
{
    T_UI();
    if (self.category.friendCount > 1)
        return self.category.avatarImage;

    if (self.avatar != nil)
        return [UIImage imageWithData:self.avatar];

    return [UIImage imageNamed:MCT_UNKNOWN_AVATAR];
}

- (BOOL)isEqual:(id)object
{
    T_DONTCARE();
    if ([super isEqual:object]) {
        return YES;
    }
    if ([object isKindOfClass:[MCTFriend class]]) {
        MCTFriend *friend = object;
        if ([self.email isEqualToString:friend.email]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)displayName
{
    T_DONTCARE();
    return (self.category.friendCount > 1) ? self.category.name : [super displayName];
}

- (NSString *)displayEmail
{
    T_DONTCARE();
    if (self.category.friendCount > 1)
        ERROR(@"Trying to display the email of a friend in a category!");
    return [super displayEmail];
}

@end


#pragma mark -

@implementation MCT_com_mobicage_to_friends_FriendTO (MCTFriendAdditions)

- (NSString *)displayName
{
    T_DONTCARE();
    return [MCTUtils isEmptyOrWhitespaceString:self.name] ? [self displayEmail] : self.name;
}

- (NSString *)displayEmail
{
    T_DONTCARE();
    return [MCTUtils isEmptyOrWhitespaceString:self.qualifiedIdentifier] ? self.email : self.qualifiedIdentifier;
}

- (BOOL)branded
{
    T_DONTCARE();
    return ![MCTUtils isEmptyOrWhitespaceString:self.descriptionBranding];
}

- (NSDictionary *)getProfileDataDict
{
    return [self.profileData MCT_JSONValue];
}

@end