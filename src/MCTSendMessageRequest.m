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

#import "MCTButton.h"
#import "MCTComponentFramework.h"
#import "MCTGroup.h"
#import "MCTMemberStatus.h"
#import "MCTSendMessageRequest.h"

#define PICKLE_MSG_DICT @"dict"


@implementation MCTSendMessageRequest


+ (MCTSendMessageRequest *)request
{
    return [[MCTSendMessageRequest alloc] init];
}

+ (MCTSendMessageRequest *)requestWithRequestTO:(MCTSendMessageRequest *)requestTO
{
    return [[MCTSendMessageRequest alloc] initWithDict:[requestTO dictRepresentation]];
}

#pragma mark -

- (NSString *)threadKey
{
    return OR(self.parent_key, self.tmpKey);
}


# pragma mark - IJSONable

- (id)initWithDict:(NSDictionary *)dict
{
    if (self = [super initWithDict:dict]) {
        NSMutableArray *groupIds = nil;
        if ([dict containsKey:@"groupIds"]) {
            groupIds = [NSMutableArray arrayWithArray:[dict arrayForKey:@"groupIds"]];
        }

        if (groupIds == nil || groupIds == MCTNull) {
            groupIds = [NSMutableArray array];
        }

        NSEnumerator *enumerator = [groupIds reverseObjectEnumerator];
        id obj = nil;
        while ((obj = [enumerator nextObject])) {
            if (![obj isKindOfClass:MCTStringClass]) {
                ERROR(@"Unexpected type for groupId: %@ %@", [obj class], obj);
                [groupIds removeObject:obj];
            }
        }

        self.groupIds = [NSArray arrayWithArray:groupIds];

        self.tmpKey = [dict stringForKey:@"tmpKey" withDefaultValue:nil];
        if (self.tmpKey == MCTNull)
            self.tmpKey = nil;

        self.attachmentHash = [dict stringForKey:@"attachmentHash" withDefaultValue:nil];
        if (self.attachmentHash == MCTNull)
            self.attachmentHash = nil;

        self.attachmentContentType = [dict stringForKey:@"attachmentContentType" withDefaultValue:nil];
        if (self.attachmentContentType == MCTNull)
            self.attachmentContentType = nil;

        if ([dict containsLongObjectForKey:@"attachmentSize"]) {
            self.attachmentSize = [dict longForKey:@"attachmentSize"];
        } else {
            self.attachmentSize = -1;
        }
    }
    return self;
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictRepresentation]];

    if (self.groupIds == nil) {
        self.groupIds = [NSArray array];
    } else if ([self.groupIds isKindOfClass:MCTArrayClass]) {
        [dict setArray:self.groupIds forKey:@"groupIds"];
    } else {
        ERROR(@"expecting array field MCTSendMessageRequest.groupIds");
    }

    [dict setString:self.tmpKey forKey:@"tmpKey"];
    [dict setString:self.attachmentHash forKey:@"attachmentHash"];
    [dict setString:self.attachmentContentType forKey:@"attachmentContentType"];
    [dict setLong:self.attachmentSize forKey:@"attachmentSize"];
    return dict;
}


#pragma mark - NSCoder

- (id)initWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    NSDictionary *dict = [coder decodeObjectForKey:PICKLE_MSG_DICT];
    return [self initWithDict:dict];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    [coder encodeObject:[self dictRepresentation] forKey:PICKLE_MSG_DICT];
}

@end