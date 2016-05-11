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
#import "MCTGetStaticFlowRH.h"
#import "MCTTransferObjects.h"

#import "GTMNSData+zlib.h"
#import "NSData+Base64.h"

#define PICKLE_CLASS_VERSION 1
#define PICKLE_HASH_KEY @"staticFlowHash"

@implementation MCTGetStaticFlowRH

+ (MCTGetStaticFlowRH *)responseHandlerWithHash:(NSString *)staticFlowHash
{
    T_BIZZ();
    MCTGetStaticFlowRH *rh = [[MCTGetStaticFlowRH alloc] init];
    rh.staticFlowHash = staticFlowHash;
    return rh;
}

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for GetStaticFlow request: %@", error);
}

- (void)handleResult:(MCT_com_mobicage_to_service_GetStaticFlowResponseTO *)result
{
    T_BIZZ();
    LOG(@"Result received for GetStaticFlow request");

    if (result) {
        NSData *zippedFlowData = [NSData dataFromBase64String:result.staticFlow];
        NSData *unzippedFlowData = [NSData gtm_dataByInflatingData:zippedFlowData];
        if (unzippedFlowData && [unzippedFlowData length]) {
            LOG(@"unzipped HTML for flow: %@", self.staticFlowHash);
        } else {
            ERROR(@"Received unzippable flow! %@", self.staticFlowHash);
            NSException *exception = [NSException exceptionWithName:@"UnzippableStaticFlow"
                                                             reason:self.staticFlowHash
                                                           userInfo:nil];
            [MCTSystemPlugin logError:exception
                          withMessage:nil];
            return;
        }

        [[[MCTComponentFramework friendsPlugin] store] saveStaticFlow:result.staticFlow withHash:self.staticFlowHash];
    }
}

- (id)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    if (self = [super initWithCoder:coder]) {
        self.staticFlowHash = [coder decodeObjectForKey:PICKLE_HASH_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
    [coder encodeObject:self.staticFlowHash forKey:PICKLE_HASH_KEY];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end