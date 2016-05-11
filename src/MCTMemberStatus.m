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

#import "MCTMemberStatus.h"

#define PICKLE_MEMBER_ACKED_TIMESTAMP @"acked_timestamp"
#define PICKLE_MEMBER_BUTTON_ID @"button_id"
#define PICKLE_MEMBER_CUSTOM_REPLY @"custom_reply"
#define PICKLE_MEMBER_MEMBER @"member"
#define PICKLE_MEMBER_RECEIVED_TIMESTAMP @"received_timestamp"
#define PICKLE_MEMBER_STATUS @"status"

@implementation MCTMemberStatus

+ (MCTMemberStatus *)memberWithMemberTO:(MCT_com_mobicage_to_messaging_MemberStatusTO *)memberTO
{
    MCTMemberStatus *member = [[MCTMemberStatus alloc] initWithDict:[memberTO dictRepresentation]];
    return member;
}

- (id)initWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    if (self = [super init]) {
        self.acked_timestamp = [coder decodeIntegerForKey:PICKLE_MEMBER_ACKED_TIMESTAMP];
        self.button_id = [coder decodeObjectForKey:PICKLE_MEMBER_BUTTON_ID];
        self.custom_reply = [coder decodeObjectForKey:PICKLE_MEMBER_CUSTOM_REPLY];
        self.member = [coder decodeObjectForKey:PICKLE_MEMBER_MEMBER];
        self.received_timestamp = [coder decodeIntegerForKey:PICKLE_MEMBER_RECEIVED_TIMESTAMP];
        self.status = [coder decodeIntegerForKey:PICKLE_MEMBER_STATUS];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    [coder encodeInteger:self.acked_timestamp forKey:PICKLE_MEMBER_ACKED_TIMESTAMP];
    [coder encodeObject:self.button_id forKey:PICKLE_MEMBER_BUTTON_ID];
    [coder encodeObject:self.custom_reply forKey:PICKLE_MEMBER_CUSTOM_REPLY];
    [coder encodeObject:self.member forKey:PICKLE_MEMBER_MEMBER];
    [coder encodeInteger:self.received_timestamp forKey:PICKLE_MEMBER_RECEIVED_TIMESTAMP];
    [coder encodeInteger:self.status forKey:PICKLE_MEMBER_STATUS];
}

@end