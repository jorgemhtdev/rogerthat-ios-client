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
#import "MCTGetIdentityQRCodeResponseHandler.h"
#import "MCTSystemPlugin.h"
#import "MCTTransferObjects.h"

#import "NSData+Base64.h"

#define PICKLE_CLASS_VERSION 1

@implementation MCTGetIdentityQRCodeResponseHandler

+ (MCTGetIdentityQRCodeResponseHandler *)responseHandler
{
    return [[MCTGetIdentityQRCodeResponseHandler alloc] init];
}

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for GetIdentityQRCode request: %@", error);
}

- (void)handleResult:(MCT_com_mobicage_to_system_GetIdentityQRCodeResponseTO *)result
{
    T_BIZZ();
    LOG(@"Result received for GetIdentityQRCode request");

    [[[MCTComponentFramework systemPlugin] identityStore] saveQRCodeWithData:[NSData dataFromBase64String:result.qrcode] 
                                                                 andShortUrl:result.shortUrl];
}

- (id)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    return [super initWithCoder:coder];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end