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
#import "MCTLockMessageResponseHandler.h"
#import "MCTMessagesPlugin.h"
#import "MCTTransferObjects.h"

#define PICKLE_CLASS_VERSION 1
#define PICKLE_MSG_KEY @"msgKey"
#define PICKLE_PARENT_MSG_KEY @"parentMsgKey"

@implementation MCTLockMessageResponseHandler


+ (MCTLockMessageResponseHandler *)responseHandlerWithParentMsgKey:(NSString *)parentMsgKey
                                                         andMsgKey:(NSString *)key
{
    T_BIZZ();
    MCTLockMessageResponseHandler *responseHandler = [[MCTLockMessageResponseHandler alloc] init];
    responseHandler.msgKey = key;
    responseHandler.parentMsgKey = parentMsgKey;
    return responseHandler;
}

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for LockMessage request: %@", error);

    [[MCTComponentFramework messagesPlugin] messageFailed:self.msgKey];
}

- (void)handleResult:(MCT_com_mobicage_to_messaging_LockMessageResponseTO *)result
{
    T_BIZZ();
    LOG(@"Result received for LockMessage request");

    [[MCTComponentFramework messagesPlugin] messageLockedWithParentKey:self.parentMsgKey
                                                                andKey:self.msgKey
                                                            andMembers:result.members
                                                      andDirtyBehavior:MCTDirtyBehaviorNormal];
}

- (MCTLockMessageResponseHandler *)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    self = [super initWithCoder:coder];
    if (self) {
        self.msgKey = [coder decodeObjectForKey:PICKLE_MSG_KEY];
        if ([coder containsValueForKey:PICKLE_PARENT_MSG_KEY]) {
            self.parentMsgKey = [coder decodeObjectForKey:PICKLE_PARENT_MSG_KEY];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
    [coder encodeObject:self.msgKey forKey:PICKLE_MSG_KEY];
    [coder encodeObject:self.parentMsgKey forKey:PICKLE_PARENT_MSG_KEY];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end