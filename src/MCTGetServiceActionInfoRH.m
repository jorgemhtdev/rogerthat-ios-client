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

#import "MCTComponentFramework.h"
#import "MCTGetServiceActionInfoRH.h"
#import "MCTIntent.h"

#define PICKLE_ACTION_KEY @"action"

@implementation MCTGetServiceActionInfoRH

+ (MCTGetServiceActionInfoRH *)responseHandlerWithHash:(NSString *)emailHash andAction:(NSString *)action
{
    MCTGetServiceActionInfoRH *rh = [[MCTGetServiceActionInfoRH alloc] init];
    rh.hashOrEmail = emailHash;
    rh.action = action;
    return rh;
}

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for GetServiceActionInfo request: %@", error);
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_SERVICE_ACTION_RETRIEVED];
    [intent setBool:NO forKey:@"success"];
    [intent setString:self.hashOrEmail forKey:@"hash"];
    [intent setString:self.action forKey:@"action"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (void)handleResult:(MCT_com_mobicage_to_service_GetServiceActionInfoResponseTO *)result
{
    T_BIZZ();
    LOG(@"Result received for GetServiceActionInfo request");
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_SERVICE_ACTION_RETRIEVED];
    [intent setString:self.hashOrEmail forKey:@"hash"];
    [intent setString:self.action forKey:@"action"];
    [intent setLong:MCTFriendTypeService forKey:@"type"];

    [intent setString:result.avatar forKey:@"avatar"];
    [intent setString:result.name forKey:@"name"];
    [intent setString:result.email forKey:@"email"];
    if (![MCTUtils isEmptyOrWhitespaceString:result.descriptionX])
        [intent setString:result.descriptionX forKey:@"description"];
    if (![MCTUtils isEmptyOrWhitespaceString:result.descriptionBranding])
        [intent setString:result.descriptionBranding forKey:@"descriptionBranding"];
    if (![MCTUtils isEmptyOrWhitespaceString:result.actionDescription])
        [intent setString:result.actionDescription forKey:@"actionDescription"];
    if (![MCTUtils isEmptyOrWhitespaceString:result.qualifiedIdentifier])
        [intent setString:result.qualifiedIdentifier forKey:@"qualifiedIdentifier"];
    if (![MCTUtils isEmptyOrWhitespaceString:result.staticFlow])
        [intent setString:result.staticFlow forKey:@"staticFlow"];
    if (![MCTUtils isEmptyOrWhitespaceString:result.staticFlowHash])
        [intent setString:result.staticFlowHash forKey:@"staticFlowHash"];

    if (result.error) {
        [intent setBool:NO forKey:@"success"];
        [intent setString:result.error.message forKey:@"errorMessage"];
        [intent setString:result.error.title forKey:@"errorTitle"];
        [intent setString:result.error.action forKey:@"errorAction"];
        [intent setString:result.error.caption forKey:@"errorCaption"];
    } else {
        [intent setBool:YES forKey:@"success"];
    }

    [[MCTComponentFramework intentFramework] broadcastIntent:intent];


    for (NSString *staticFlowBranding in result.staticFlowBrandings) {
        [[MCTComponentFramework brandingMgr] queueGenericBranding:staticFlowBranding];
    }
}

- (id)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (self = [super initWithCoder:coder forClassVersion:classVersion]) {
        self.action = [coder decodeObjectForKey:PICKLE_ACTION_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
    [coder encodeObject:self.action forKey:PICKLE_ACTION_KEY];
}

@end