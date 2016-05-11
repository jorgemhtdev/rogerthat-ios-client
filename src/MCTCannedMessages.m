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

#import "MCTCannedMessages.h"
#import "MCTComponentFramework.h"
#import "MCTConfigProvider.h"
#import "MCTSendMessageRequest.h"

#import "NSData+Base64.h"

#define MCT_CANNED_MESSAGES_PICKLE_CLASS_VERSION 1
#define MCT_CANNED_MESSAGES_PICKLE_KEY @"messages"
#define MCT_CANNED_MESSAGES_CONFIG_KEY @"CANNED_MESSAGES"


@implementation MCTCannedMessages


+ (MCTCannedMessages *)cannedMessages
{
    T_DONTCARE();
    MCTConfigProvider *cfg = [MCTComponentFramework configProvider];
    NSString *base64String = [cfg stringForKey:MCT_CANNED_MESSAGES_CONFIG_KEY];

    MCTCannedMessages *msgs;
    if (base64String == nil) {
        msgs = [[MCTCannedMessages alloc] init];
        msgs.messages = [NSMutableDictionary dictionary];
    } else {
        msgs = (MCTCannedMessages *) [MCTPickler objectFromPickle:[NSData dataFromBase64String:base64String]];
    }

    return msgs;
}

- (id)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_DONTCARE();
    if (classVersion != MCT_CANNED_MESSAGES_PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    if (self = [super init]) {
        @try {
            self.messages = (NSMutableDictionary *) [coder decodeObjectForKey:MCT_CANNED_MESSAGES_PICKLE_KEY];
        }
        @catch (NSException *exception) {
            [MCTSystemPlugin logError:exception
                          withMessage:@"Caught exception in loading canned messages."];

            self.messages = [NSMutableDictionary dictionary];
            [self save];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    [coder encodeObject:self.messages forKey:MCT_CANNED_MESSAGES_PICKLE_KEY];
}

- (int)classVersion
{
    T_DONTCARE();
    return MCT_CANNED_MESSAGES_PICKLE_CLASS_VERSION;
}

- (void)save
{
    T_DONTCARE();
    NSData *pickle = [MCTPickler pickleFromObject:self];
    NSString *base64String = [pickle base64EncodedString];

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        [[MCTComponentFramework configProvider] setString:base64String forKey:MCT_CANNED_MESSAGES_CONFIG_KEY];
    }];
}

- (void)saveMessage:(MCTSendMessageRequest *)requestTO withName:(NSString *)name
{
    T_DONTCARE();
    if (name == nil || name == MCTNull) {
        ERROR(@"Can not save canned message with name 'null'");
    } else if (requestTO == nil || requestTO == MCTNull) {
        ERROR(@"Can not save canned message with requestTO 'null'");
    } else {
        MCTSendMessageRequest *request = [MCTSendMessageRequest request];
        if (requestTO.members)
            request.members = [NSArray arrayWithArray:requestTO.members];
        if (requestTO.groupIds)
            request.groupIds = [NSArray arrayWithArray:requestTO.groupIds];
        if (requestTO.message)
            request.message = [NSString stringWithString:requestTO.message];
        if (requestTO.buttons)
            request.buttons = [NSArray arrayWithArray:requestTO.buttons];
        [self.messages setObject:request forKey:name];
        [self save];
    }
}

- (void)removeMessageForName:(NSString *)name
{
    T_DONTCARE();
    if ([self.messages containsKey:name]) {
        [self.messages removeObjectForKey:name];
        [self save];
    } else {
        ERROR(@"Trying to remove a canned message which is not already saved: %@", name);
    }
}

- (NSString *)description
{
    return [self.messages description];
}

@end