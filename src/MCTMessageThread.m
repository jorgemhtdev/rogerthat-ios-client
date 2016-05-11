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

#import "MCTMessageThread.h"


@implementation MCTMessageThread


+ (MCTMessageThread *)threadWithKey:(NSString *)key
                      andReplyCount:(MCTlong)replyCount
                      andRecipients:(NSString *)recipients
                  andVisibleMessage:(NSString *)visibleMessage
                    andThreadShowInList:(BOOL)threadShowInList
                           andFlags:(MCTlong)flags
                        andPriority:(MCTlong)priority
                     andUnreadCount:(MCTlong)unreadCount
{
    MCTMessageThread *thread = [[MCTMessageThread alloc] init];
    thread.key = key;
    thread.replyCount = replyCount;
    thread.unreadcount = unreadCount;
    thread.recipients = recipients;
    thread.visibleMessage = visibleMessage;
    thread.threadShowInList = threadShowInList;
    thread.flags = flags;
    thread.priority = priority;
    return thread;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[MCTMessageThread %@] replies: %lld, unread: %lld, visible msg: %@, to: %@",
            self.key, self.replyCount, self.unreadcount, self.visibleMessage, self.recipients];
}

@end