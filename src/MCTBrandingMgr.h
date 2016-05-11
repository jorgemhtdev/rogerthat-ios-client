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

#import "MCTConfigProvider.h"
#import "MCTFriend.h"
#import "MCTJSONUtils.h"
#import "MCTMessage.h"
#import "MCTPickler.h"
#import "MCTTransferObjects.h"

typedef enum {
    MCTColorSchemeDark,
    MCTColorSchemeLight
} MCTColorScheme;

#define MCT_DEFAULT_COLOR_SCHEME MCTColorSchemeLight;

@interface MCTBrandingResult : NSObject

@property (nonatomic, copy) NSString *file;
@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSString *menuItemColor;
@property (nonatomic) MCTColorScheme scheme;
@property (nonatomic) BOOL showHeader;
@property (nonatomic) CGSize dimension1;
@property (nonatomic) CGSize dimension2;
@property (nonatomic, copy) NSString *watermarkFilePath;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, strong) NSArray *externalUrlPatterns;
@property (nonatomic, copy) NSString *rootDir;

+ (MCTBrandingResult *)brandingResultWithFile:(NSString *)file
                                        color:(NSString *)color
                                menuItemColor:(NSString *)menuItemColor
                                       scheme:(MCTColorScheme)scheme
                                   showHeader:(BOOL)showHeader
                                   dimension1:(CGSize)dimension1
                                   dimension2:(CGSize)dimension2
                            watermarkFilePath:(NSString *)watermarkFilePath
                                  contentType:(NSString *)contentType
                          externalUrlPatterns:(NSArray *)externalUrlPatterns
                                      rootDir:(NSString *)rootDir;

@end


@interface MCTBrandingMgr : NSObject <MCTPickleable, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;

+ (MCTBrandingMgr *)brandingMgr;

- (void)initialize;
+ (NSString *)URLSessionIdentifier;
- (NSURLSession *)initializeURLSession;
- (void)terminate;

- (BOOL)isMessageInQueue:(NSString *)key;
- (void)queueFriend:(MCTFriend *)friend;
- (void)queueMessage:(MCTMessage *)msg;
- (void)queueGenericBranding:(NSString *)brandingKey;
- (void)queueJSEmbeddedPacketWithName:(NSString *)name embeddingHash:(NSString *)embeddingHash;
- (BOOL)queueLocalFlowWithContext:(NSDictionary *)context
                     brandingKeys:(NSArray *)brandingKeys
           attachmentDownloadURLs:(NSArray *)attachmentDownloadURLs;
- (void)queueAttachment:(NSString *)downloadURL
             forMessage:(NSString *)messageKey
          withThreadKey:(NSString *)threadKey
            contentType:(NSString *)contentType;

- (BOOL)queueIfNeededWithFunction:(NSString *)function
                       andRequest:(NSObject<IJSONable> *)request
                    andMessageKey:(NSString *)messageKey;
- (void)deleteConversationWithKey:(NSString *)threadKey;

- (BOOL)isBrandingAvailable:(NSString *)brandingKey;
- (MCTBrandingResult *)prepareBrandingWithFriend:(MCTFriend *)friend;
- (MCTBrandingResult *)prepareBrandingWithMessage:(MCTMessage *)msg;
- (MCTBrandingResult *)prepareBrandingWithKey:(NSString *)brandingKey forFriend:(MCTFriend *)friend;
+ (CGFloat)calculateHeightWithBrandingResult:(MCTBrandingResult *)br andWidth:(int)width;

- (void)cleanupBrandingWithBrandingKey:(NSString *)brandingKey;
- (BOOL)cleanupJSEmbeddingDirWithName:(NSString *)name;
- (void)cleanupLocalFlowCacheDirWithThreadKey:(NSString *)threadKey;

- (NSString *)localFlowCacheDirWithThreadKey:(NSString *)threadKey;
- (NSString *)localFlowAttachmentFileWithThreadKey:(NSString *)threadKey
                                       downloadURL:(NSString *)downloadURL;

@end