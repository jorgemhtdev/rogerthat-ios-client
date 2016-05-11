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

@interface MCTMessageActivityFactory : NSObject

- (void)newMessageWithKey:(NSString *)key;
- (void)newMessage:(MCT_com_mobicage_to_messaging_MessageTO *)message;

- (void)lockedMessageWithKey:(NSString *)key;
- (void)quickReplyUndoneDuringLockMessage:(MCTMessage *)message
                withNewMemberStatusUpdate:(MCT_com_mobicage_to_messaging_MemberStatusTO *)newMember;

- (void)statusUpdateWithMessage:(NSString *)msgKey andMember:(NSString *)memberEmail andButton:(NSString *)btnId;

@end