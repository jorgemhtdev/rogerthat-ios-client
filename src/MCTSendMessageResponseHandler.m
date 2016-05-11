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
#import "MCTMessagesPlugin.h"
#import "MCTSendMessageResponseHandler.h"
#import "MCTTransferObjects.h"

#define PICKLE_CLASS_VERSION 1
#define PICKLE_TMP_KEY @"tmpKey"
#define PICKLE_PARENT_KEY @"parentKey"
#define PICKLE_ATTACHMENTS_UPLOADED @"attachmentsUploaded"

@implementation MCTSendMessageResponseHandler


+ (MCTSendMessageResponseHandler *)responseHandlerWithTmpKey:(NSString *)tmpKey
                                                   parentKey:(NSString *)parentKey
                                         attachmentsUploaded:(BOOL)attachmentsUploaded
{
    T_BIZZ();
    MCTSendMessageResponseHandler *responseHandler = [[MCTSendMessageResponseHandler alloc] init];
    responseHandler.tmpKey = tmpKey;
    responseHandler.parentKey = parentKey;
    responseHandler.attachmentsUploaded = attachmentsUploaded;
    return responseHandler;
}

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for SendMessage request: %@", error);
    [[MCTComponentFramework messagesPlugin] messageFailed:self.tmpKey];
}

- (void)handleResult:(MCT_com_mobicage_to_messaging_SendMessageResponseTO *)result
{
    T_BIZZ();
    LOG(@"Result received for SendMessage request");

    MCTMessagesPlugin *plugin = [MCTComponentFramework messagesPlugin];

    if (self.attachmentsUploaded) {
        @try {
            NSString *tmpDir = [[plugin attachmentsDirWithThreadKey:OR(self.parentKey, self.tmpKey)] stringByAppendingPathComponent:self.tmpKey];
            NSString *newDir = [[plugin attachmentsDirWithThreadKey:OR(self.parentKey, result.key)] stringByAppendingPathComponent:result.key];
            if ([[NSFileManager defaultManager] fileExistsAtPath:tmpDir]) {
                if (self.parentKey == nil) {
                    // Create newAttachmentsDir's parent dir it does not exist
                    [[NSFileManager defaultManager] createDirectoryAtPath:[newDir stringByDeletingLastPathComponent]
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:nil];
                }

                NSError *error = nil;
                [[NSFileManager defaultManager] moveItemAtPath:tmpDir
                                                        toPath:newDir
                                                         error:&error];
                if (error) {
                    ERROR(@"Failed to mv %@ to %@", tmpDir, newDir);
                }
            }
        }
        @catch (NSException *exception) {
            [MCTSystemPlugin logError:exception
                          withMessage:@"Failed to move the sent attachment to the attachments cache directory."];
        }
    }

    [plugin replaceTmpKey:self.tmpKey
                  withKey:result.key
             andParentKey:self.parentKey
             andTimestamp:result.timestamp];

    [plugin.activityFactory newMessageWithKey:result.key];
}

- (MCTSendMessageResponseHandler *)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    self = [super initWithCoder:coder];
    if (self) {
        self.tmpKey = [coder decodeObjectForKey:PICKLE_TMP_KEY];
        self.parentKey = [coder containsValueForKey:PICKLE_PARENT_KEY] ? [coder decodeObjectForKey:PICKLE_PARENT_KEY] : MCTNull;
        self.attachmentsUploaded = [coder containsValueForKey:PICKLE_ATTACHMENTS_UPLOADED] ? [coder decodeBoolForKey:PICKLE_ATTACHMENTS_UPLOADED] : NO;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_BACKLOG();
    [super encodeWithCoder:coder];
    [coder encodeObject:self.tmpKey forKey:PICKLE_TMP_KEY];
    [coder encodeObject:self.parentKey forKey:PICKLE_PARENT_KEY];
    [coder encodeBool:self.attachmentsUploaded forKey:PICKLE_ATTACHMENTS_UPLOADED];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end