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

extern int const kMemberStatusSummaryError;
extern int const kMemberStatusSummaryNone;


@interface MCTMemberStatusSummaryEncoding : NSObject

+ (MCTlong)encodeMessageMemberSummaryWithRecipients:(MCTlong)numNonSenderMembers
                                        andReceived:(MCTlong)numNonSenderMembersReceived
                                    andQuickReplied:(MCTlong)numNonSenderMembersQuickReplied
                                       andDismissed:(MCTlong)numNonSenderMembersDismissed;

+ (MCTlong)decodeNumNonSenderMembers:(MCTlong)memberStatusSummary;

+ (MCTlong)decodeNumNonSenderMembersReceived:(MCTlong)memberStatusSummary;

+ (MCTlong)decodeNumNonSenderMembersQuickReplied:(MCTlong)memberStatusSummary;

+ (MCTlong)decodeNumNonSenderMembersDismissed:(MCTlong)memberStatusSummary;

@end