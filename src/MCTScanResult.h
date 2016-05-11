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

#define MCT_ROGERTHAT_PREFIX @"rogerthat://"
#define MCT_URL_PREFIX_SHORT_LINK @"S/"
#define MCT_URL_PREFIX_INVITATION_LINK @"M/"
#define MCT_URL_PREFIX_INVITE_USER @"q/i"
#define MCT_URL_PREFIX_INVITE_SERVICE @"q/s/"

typedef enum {
    MCTScanResultActionInviteFriend = 1,
    MCTScanResultActionService = 2,
    MCTScanResultActionInvitationWithSecret = 3,
    MCTScanResultActionURL = 4,
} MCTScanResultAction;


@interface MCTScanResult : NSObject

@property (nonatomic) MCTScanResultAction action;
@property (nonatomic, strong) NSDictionary *parameters;

+ (MCTScanResult *)scanResultWithUrl:(NSString *)url;
+ (MCTScanResult *)scanResultWithAction:(MCTScanResultAction)action andParameters:(NSDictionary *)params;

- (MCTScanResult *)initWithAction:(MCTScanResultAction)action andParameters:(NSDictionary *)params;

@end