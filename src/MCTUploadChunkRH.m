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

#import "MCT_CS_API.h"
#import "MCTComponentFramework.h"
#import "MCTUploadChunkRH.h"

#define PICKLE_CLASS_VERSION 1
#define PICKLE_REQUEST @"request"


@implementation MCTUploadChunkRH


+ (MCTUploadChunkRH *)responseHandlerWithUploadChunkRequest:(MCT_com_mobicage_to_messaging_UploadChunkRequestTO *)request
{
    T_BIZZ();
    MCTUploadChunkRH *responseHandler = [[MCTUploadChunkRH alloc] init];
    responseHandler.request = request;
    return responseHandler;
}

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for UploadChunk request: %@", error);
    [MCT_com_mobicage_api_messaging CS_API_uploadChunkWithResponseHandler:self andRequest:self.request];
}

- (void)handleResult:(MCT_com_mobicage_to_messaging_UploadChunkResponseTO *)result
{
    T_BIZZ();
    LOG(@"Result received for UploadChunk request");
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_CHUNK_UPLOADED];
    [intent setString:self.request.message_key forKey:@"message_key"];
    [intent setString:self.request.parent_message_key forKey:@"parent_message_key"];
    [intent setLong:self.request.number forKey:@"number"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (MCTUploadChunkRH *)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    if (self = [super initWithCoder:coder]) {
        self.request = [MCT_com_mobicage_to_messaging_UploadChunkRequestTO transferObjectWithDict:[coder decodeObjectForKey:PICKLE_REQUEST]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
    [coder encodeObject:[self.request dictRepresentation] forKey:PICKLE_REQUEST];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end