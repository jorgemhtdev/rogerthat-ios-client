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
#import "MCTGetConversationRH.h"
#import "MCTMessagesPlugin.h"
#import "MCTTransferObjects.h"

#define PICKLE_CLASS_VERSION 1
#define PICKLE_KEY @"threadKey"

@implementation MCTGetConversationRH


+ (MCTGetConversationRH *)responseHandlerWithThreadKey:(NSString *)threadKey
{
    T_BACKLOG();
    MCTGetConversationRH *responseHandler = [[MCTGetConversationRH alloc] init];
    responseHandler.threadKey = threadKey;
    return responseHandler;
}

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for GetConversation request: %@", error);
    [[[MCTComponentFramework messagesPlugin] store] deleteRequestedConversationWithKey:self.threadKey];
}

- (void)handleResult:(MCT_com_mobicage_to_messaging_GetConversationResponseTO *)result
{
    T_BIZZ();
    LOG(@"Result received for GetConversation request");
    [[[MCTComponentFramework messagesPlugin] store] deleteRequestedConversationWithKey:self.threadKey];
}

- (MCTGetConversationRH *)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    if (self = [super initWithCoder:coder]) {
        self.threadKey = [coder decodeObjectForKey:PICKLE_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
    [coder encodeObject:self.threadKey forKey:PICKLE_KEY];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end