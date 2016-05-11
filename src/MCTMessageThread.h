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

@interface MCTMessageThread : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic) MCTlong replyCount;
@property (nonatomic) MCTlong unreadcount;
@property (nonatomic, copy) NSString *recipients;
@property (nonatomic, copy) NSString *visibleMessage;
@property (nonatomic) BOOL threadShowInList;
@property (nonatomic) MCTlong flags;
@property (nonatomic) MCTlong priority;

+ (MCTMessageThread *)threadWithKey:(NSString *)key
                      andReplyCount:(MCTlong)replyCount
                      andRecipients:(NSString *)recipients
                  andVisibleMessage:(NSString *)visibleMessage
                andThreadShowInList:(BOOL)threadShowInList
                           andFlags:(MCTlong)flags
                        andPriority:(MCTlong)priority
                     andUnreadCount:(MCTlong)unreadCount;

@end