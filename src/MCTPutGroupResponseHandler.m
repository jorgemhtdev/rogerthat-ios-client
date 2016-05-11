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

#import "MCTPutGroupResponseHandler.h"
#import "MCTComponentFramework.h"
#import "MCTTransferObjects.h"

#import "NSData+Base64.h"

#define PICKLE_CLASS_VERSION 1
#define PICKLE_GUID_KEY @"guid"


@implementation MCTPutGroupResponseHandler


+ (MCTPutGroupResponseHandler *)responseHandlerWithGuid:(NSString *)guid {
    MCTPutGroupResponseHandler *rh = [[MCTPutGroupResponseHandler alloc] init];
    rh.guid = guid;
    return rh;
}

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for PutGroup request: %@", error);
}

- (void)handleResult:(MCT_com_mobicage_to_friends_PutGroupResponseTO *)result
{
    T_BIZZ();
    LOG(@"Result received for PutGroup request");
    if (result.avatar_hash != nil) {
        MCTFriendsPlugin *plugin = [MCTComponentFramework friendsPlugin];
        [plugin.store insertGroupAvatarHash:result.avatar_hash guid:self.guid];
    }
}


- (MCTPutGroupResponseHandler *)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    if (self = [super initWithCoder:coder]) {
        self.guid = [coder decodeObjectForKey:PICKLE_GUID_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
    [coder encodeObject:self.guid forKey:PICKLE_GUID_KEY];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end