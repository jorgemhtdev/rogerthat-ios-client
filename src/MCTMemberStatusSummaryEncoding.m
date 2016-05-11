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

#import "MCTMemberStatusSummaryEncoding.h"

#define MCT_MAX_VALUE 0x7fff

int const kMemberStatusSummaryError = -2;
int const kMemberStatusSummaryNone = -1;


@implementation MCTMemberStatusSummaryEncoding

+ (MCTlong)encodeMessageMemberSummaryWithRecipients:(MCTlong)numNonSenderMembers
                                        andReceived:(MCTlong)numNonSenderMembersReceived
                                    andQuickReplied:(MCTlong)numNonSenderMembersQuickReplied
                                       andDismissed:(MCTlong)numNonSenderMembersDismissed
{
    MCTlong newStatus = (numNonSenderMembers & MCT_MAX_VALUE)
                            | ((numNonSenderMembersReceived & MCT_MAX_VALUE) << 16)
                            | ((numNonSenderMembersQuickReplied & MCT_MAX_VALUE) << 32)
                            | ((numNonSenderMembersDismissed & MCT_MAX_VALUE) << 48);
    return newStatus;
}

+ (MCTlong)decodeNumNonSenderMembers:(MCTlong)memberStatusSummary
{
    return (memberStatusSummary & MCT_MAX_VALUE);
}

+ (MCTlong)decodeNumNonSenderMembersReceived:(MCTlong)memberStatusSummary
{
    return ((memberStatusSummary >> 16) & MCT_MAX_VALUE);
}

+ (MCTlong)decodeNumNonSenderMembersQuickReplied:(MCTlong)memberStatusSummary
{
    return ((memberStatusSummary >> 32) & MCT_MAX_VALUE);
}

+ (MCTlong)decodeNumNonSenderMembersDismissed:(MCTlong)memberStatusSummary
{
    return ((memberStatusSummary >> 48) & MCT_MAX_VALUE);
}

@end