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

#import "MCTAckMessageResponseHandler.h"
#import "MCTComponentFramework.h"
#import "MCTMessagesPlugin.h"
#import "MCTTransferObjects.h"

#define PICKLE_CLASS_VERSION 1
#define PICKLE_MSG_KEY @"messageKey"
#define PICKLE_MEMBER_EMAIL @"memberEmail"
#define PICKLE_BUTTON_ID @"buttonId"

@implementation MCTAckMessageResponseHandler


+ (MCTAckMessageResponseHandler *)responseHandlerWithMessageKey:(NSString *)message
                                                 andMemberEmail:(NSString *)member
                                                    andButtonId:(NSString *)button
{
    T_BIZZ();
    MCTAckMessageResponseHandler *responseHandler = [[MCTAckMessageResponseHandler alloc] init];
    responseHandler.messageKey = message;
    responseHandler.memberEmail = member;
    responseHandler.buttonId = button;
    return responseHandler;
}

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for AckMessage request: %@", error);
}

- (void)handleResult:(MCT_com_mobicage_to_messaging_AckMessageResponseTO *)result
{
    T_BIZZ();
    LOG(@"Result received for AckMessage request");

    if (result.result == 1) {
        MCTMessagesPlugin *plugin = (MCTMessagesPlugin *) [MCTComponentFramework pluginForClass:[MCTMessagesPlugin class]];
        [plugin.activityFactory statusUpdateWithMessage:self.messageKey andMember:self.memberEmail andButton:self.buttonId];
    } else {
        LOG(@"AckMessage failed with error code %d", result.result);
    }
}

- (MCTAckMessageResponseHandler *)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    self = [super initWithCoder:coder];
    if (self) {
        self.messageKey = [coder decodeObjectForKey:PICKLE_MSG_KEY];
        self.memberEmail = [coder decodeObjectForKey:PICKLE_MEMBER_EMAIL];
        self.buttonId = [coder decodeObjectForKey:PICKLE_BUTTON_ID];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
    [coder encodeObject:self.messageKey forKey:PICKLE_MSG_KEY];
    [coder encodeObject:self.memberEmail forKey:PICKLE_MEMBER_EMAIL];
    [coder encodeObject:self.buttonId forKey:PICKLE_BUTTON_ID];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end