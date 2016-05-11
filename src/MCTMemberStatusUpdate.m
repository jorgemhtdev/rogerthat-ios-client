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

#import "MCTMemberStatusUpdate.h"
#import "MCTTransferObjects.h"

#define PICKLE_MSU_ACKED_TIMESTAMP @"acked_timestamp"
#define PICKLE_MSU_BUTTON_ID @"button_id"
#define PICKLE_MSU_CUSTOM_REPLY @"custom_reply"
#define PICKLE_MSU_MEMBER @"member"
#define PICKLE_MSU_MESSAGE @"message"
#define PICKLE_MSU_RECEIVED_TIMESTAMP @"received_timestamp"
#define PICKLE_MSU_STATUS @"status"
#define PICKLE_MSU_FLAGS @"flags"

@implementation MCTMemberStatusUpdate

+ (MCTMemberStatusUpdate *)memberStatusUpdateWithRequest:(MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *)to
{
    MCTMemberStatusUpdate *update = [[MCTMemberStatusUpdate alloc] init];
    update.acked_timestamp = to.acked_timestamp;
    update.button_id = to.button_id;
    update.custom_reply = to.custom_reply;
    update.member = to.member;
    update.message = to.message;
    update.received_timestamp = to.received_timestamp;
    update.status = to.status;
    update.flags = to.flags;
    return update;
}

- (id)initWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    if (self = [super init]) {
        self.acked_timestamp = [coder decodeIntegerForKey:PICKLE_MSU_ACKED_TIMESTAMP];
        self.button_id = [coder decodeObjectForKey:PICKLE_MSU_BUTTON_ID];
        self.custom_reply = [coder decodeObjectForKey:PICKLE_MSU_CUSTOM_REPLY];
        self.member = [coder decodeObjectForKey:PICKLE_MSU_MEMBER];
        self.received_timestamp = [coder decodeIntegerForKey:PICKLE_MSU_RECEIVED_TIMESTAMP];
        self.status = [coder decodeIntegerForKey:PICKLE_MSU_STATUS];
        self.flags = [coder decodeIntegerForKey:PICKLE_MSU_FLAGS];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    [coder encodeInteger:self.acked_timestamp forKey:PICKLE_MSU_ACKED_TIMESTAMP];
    [coder encodeObject:self.button_id forKey:PICKLE_MSU_BUTTON_ID];
    [coder encodeObject:self.custom_reply forKey:PICKLE_MSU_CUSTOM_REPLY];
    [coder encodeObject:self.member forKey:PICKLE_MSU_MEMBER];
    [coder encodeInteger:self.received_timestamp forKey:PICKLE_MSU_RECEIVED_TIMESTAMP];
    [coder encodeInteger:self.status forKey:PICKLE_MSU_STATUS];
    [coder encodeInteger:self.flags forKey:PICKLE_MSU_FLAGS];
}

@end