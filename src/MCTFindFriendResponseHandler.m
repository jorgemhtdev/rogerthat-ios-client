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

#import "MCTComponentFramework.h"
#import "MCTFindFriendResponseHandler.h"
#import "MCTIntent.h"
#import "MCTTransferObjects.h"


#define PICKLE_CLASS_VERSION 1

#define PICKLE_SEARCH_STRING_KEY @"ss"

@implementation MCTFindFriendResponseHandler


+ (MCTFindFriendResponseHandler *)responseHandlerWithSearchIdentifier:(NSString *)identifier
{
    MCTFindFriendResponseHandler *rh = [[MCTFindFriendResponseHandler alloc] init];
    rh.identifier = identifier;
    return rh;
}

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for findService request: %@", error);

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_SEARCH_FRIEND_FAILURE];
    [intent setString:self.identifier forKey:@"search_id"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (void)handleResult:(MCT_com_mobicage_to_service_FindServiceResponseTO *)result
{
    T_BIZZ();

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_SEARCH_FRIEND_RESULT];
    [intent setString:self.identifier forKey:@"search_id"];
    [intent setString:result.error_string forKey:@"error_string"];

    NSString *resultJSON = [[result dictRepresentation] MCT_JSONRepresentation];
    [intent setString:resultJSON forKey:@"result"];

    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (id)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    if (self = [super initWithCoder:coder]) {
        self.identifier = [coder decodeObjectForKey:PICKLE_SEARCH_STRING_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
    [coder encodeObject:self.identifier forKey:PICKLE_SEARCH_STRING_KEY];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end