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

#import "MCTBrandingMgr.h"
#import "MCTComponentFramework.h"
#import "MCTConfigProvider.h"
#import "MCTEncoding.h"
#import "MCTHTTPRequest.h"
#import "MCTMemberStatusUpdate.h"
#import "MCTMessage.h"
#import "MCTMessagesPlugin.h"
#import "MCTPickler.h"
#import "MCTRPCCall.h"
#import "MCTTransferObjects.h"
#import "MCTUtils.h"
#import "MCTUIUtils.h"
#import "MCTZipUtils.h"
#import "MCTJSEmbedding.h"

#import "GTMNSString+HTML.h"
#import "NSData+Base64.h"

#define MCT_BRANDING_CONFIG_KEY @"BRANDING_MGR"
#define MCT_BRANDING_QUEUE @"BRANDING_QUEUE"
#define MCT_BRANDING_LEGACY_FRIEND_QUEUE @"FRIEND_QUEUE"
#define MCT_BRANDING_LEGACY_MSG_QUEUE @"QUEUE"
#define MCT_BRANDING_STATUS_QUEUE @"STATUS_QUEUE"

#define MCT_BRANDING_PICKLE_CLASS_VERSION 3

#define MCT_BRANDING_URL_FORMAT @"%@/unauthenticated/mobi/branding/%@"
#define MCT_JS_EMBEDDING_URL_FORMAT @"%@/mobi/js_embedding/%@"

#define MCT_BRANDED_ITEM_TYPE @"type"
#define MCT_BRANDED_ITEM_OBJECT @"object"
#define MCT_BRANDED_ITEM_BRANDING @"branding"
#define MCT_BRANDED_ITEM_CALLS @"calls"
#define MCT_BRANDED_ITEM_MSG @"mgs"
#define MCT_BRANDED_ITEM_TIME @"time"
#define MCT_BRANDED_ITEM_ATTEMPTS_LEFT @"attempts_left"

#pragma mark - FriendTO

@interface MCT_com_mobicage_to_friends_FriendTO (MCTBrandedItem)

- (BOOL)isEqual:(id)object;

@end

@implementation MCT_com_mobicage_to_friends_FriendTO (MCTBrandedItem)

- (BOOL)isEqual:(id)obj
{
    T_DONTCARE();
    if ([super isEqual:obj]) {
        return YES;
    }
    if ([obj isKindOfClass:[MCT_com_mobicage_to_friends_FriendTO class]]) {
        MCT_com_mobicage_to_friends_FriendTO *friend = obj;
        if ([self.email isEqualToString:friend.email]) {
            return YES;
        }
    }
    return NO;
}

@end


#pragma mark - MCTBrandedItem

typedef enum {
    MCTBrandedItemTypeMessage = 0,
    MCTBrandedItemTypeFriend = 1,
    MCTBrandedItemTypeGeneric = 2,
    MCTBrandedItemTypeJSEmbeddingPacket = 3,
    MCTBrandedItemTypeLocalFlowAttachment = 4,
    MCTBrandedItemTypeLocalFlowBranding = 5,
    MCTBrandedItemTypeAttachment = 6,
} MCTBrandedItemType;

@interface MCTBrandedItem : NSObject <NSCoding>

@property (nonatomic) MCTBrandedItemType type;
@property (nonatomic, strong) NSObject *object;
@property (nonatomic, copy) NSString *branding;
@property (nonatomic, strong) NSMutableArray *calls;
@property (nonatomic) int attemptsLeft;

+ (MCTBrandedItem *)itemWithMessage:(MCTMessage *)msg;
+ (MCTBrandedItem *)itemWithFriend:(MCTFriend *)friend;
+ (MCTBrandedItem *)itemWithFriend:(MCTFriend *)friend branding:(NSString *)branding;
+ (MCTBrandedItem *)itemWithGenericBranding:(NSString *)branding;
+ (MCTBrandedItem *)itemWithType:(MCTBrandedItemType)type object:(NSObject *)object branding:(NSString *)brandingKey;
+ (MCTBrandedItem *)itemWithJSEmbeddingName:(NSString *)name embeddingHash:(NSString *)embeddingHash;
+ (MCTBrandedItem *)itemWithLocalFlowAttachment:(NSString *)downloadURL
                                        context:(NSDictionary *)context;
+ (MCTBrandedItem *)itemWithLocalFlowBranding:(NSString *)branding
                                      context:(NSDictionary *)context;
+ (MCTBrandedItem *)itemWithAttachment:(NSString *)downloadURL
                             threadKey:(NSString *)treadKey
                            messageKey:(NSString *)messageKey
                           contentType:(NSString *)contentType;


@end

@implementation MCTBrandedItem


- (id)init
{
    if (self = [super init]) {
        self.calls = [NSMutableArray array];
        self.attemptsLeft = 1;
    }
    return self;
}

+ (MCTBrandedItem *)itemWithType:(MCTBrandedItemType)type object:(NSObject *)object branding:(NSString *)brandingKey
{
    MCTBrandedItem *item = [[MCTBrandedItem alloc] init];
    item.type = type;
    item.object = object;
    item.branding = brandingKey;
    return item;
}

+ (MCTBrandedItem *)itemWithMessage:(MCTMessage *)msg
{
    return [MCTBrandedItem itemWithType:MCTBrandedItemTypeMessage object:msg branding:msg.branding];
}

+ (MCTBrandedItem *)itemWithFriend:(MCTFriend *)friend
{
    return [MCTBrandedItem itemWithType:MCTBrandedItemTypeFriend object:friend branding:friend.descriptionBranding];
}

+ (MCTBrandedItem *)itemWithFriend:(MCTFriend *)friend branding:(NSString *)branding
{
    return [MCTBrandedItem itemWithType:MCTBrandedItemTypeFriend object:friend branding:branding];
}

+ (MCTBrandedItem *)itemWithGenericBranding:(NSString *)branding
{
    return [MCTBrandedItem itemWithType:MCTBrandedItemTypeGeneric object:nil branding:branding];
}

+ (MCTBrandedItem *)itemWithJSEmbeddingName:(NSString *)name embeddingHash:(NSString *)embeddingHash
{
    return [MCTBrandedItem itemWithType:MCTBrandedItemTypeJSEmbeddingPacket object:name branding:embeddingHash];
}

+ (MCTBrandedItem *)itemWithLocalFlowAttachment:(NSString *)downloadURL
                                        context:(NSDictionary *)context
{
    MCTBrandedItem *item = [MCTBrandedItem itemWithType:MCTBrandedItemTypeLocalFlowAttachment
                                                 object:context
                                               branding:downloadURL];
    item.attemptsLeft = 3;
    return item;
}

+ (MCTBrandedItem *)itemWithLocalFlowBranding:(NSString *)branding
                                      context:(NSDictionary *)context
{
    MCTBrandedItem *item = [MCTBrandedItem itemWithType:MCTBrandedItemTypeLocalFlowBranding
                                                 object:context
                                               branding:branding];
    item.attemptsLeft = 3;
    return item;
};

+ (MCTBrandedItem *)itemWithAttachment:(NSString *)downloadURL
                             threadKey:(NSString *)treadKey
                            messageKey:(NSString *)messageKey
                           contentType:(NSString *)contentType
{
    MCTBrandedItem *item = [MCTBrandedItem itemWithType:MCTBrandedItemTypeAttachment
                                                 object:@{@"thread_key": treadKey,
                                                          @"message_key": messageKey,
                                                          @"content_type": contentType,
                                                          }
                                               branding:downloadURL];
    return item;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [self init]) {
        self.type = [[coder decodeObjectForKey:MCT_BRANDED_ITEM_TYPE] intValue];
        self.object = [coder decodeObjectForKey:MCT_BRANDED_ITEM_OBJECT];
        self.branding = [coder decodeObjectForKey:MCT_BRANDED_ITEM_BRANDING];
        if ([coder containsValueForKey:MCT_BRANDED_ITEM_CALLS]) {
            [self.calls addObjectsFromArray:(NSArray *)[coder decodeObjectForKey:MCT_BRANDED_ITEM_CALLS]];
        }
        if ([coder containsValueForKey:MCT_BRANDED_ITEM_ATTEMPTS_LEFT]) {
            self.attemptsLeft = [coder decodeIntForKey:MCT_BRANDED_ITEM_ATTEMPTS_LEFT];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[NSNumber numberWithInt:self.type] forKey:MCT_BRANDED_ITEM_TYPE];
    [coder encodeObject:self.object forKey:MCT_BRANDED_ITEM_OBJECT];
    [coder encodeObject:self.branding forKey:MCT_BRANDED_ITEM_BRANDING];
    [coder encodeObject:self.calls forKey:MCT_BRANDED_ITEM_CALLS];
    [coder encodeInt:self.attemptsLeft forKey:MCT_BRANDED_ITEM_ATTEMPTS_LEFT];
}

- (BOOL)isEqual:(id)obj
{
    if (self == obj)
        return YES;

    if (obj == nil)
        return NO;

    if (![obj isKindOfClass:[MCTBrandedItem class]])
        return NO;

    MCTBrandedItem *item = obj;
    if (self.type != item.type)
        return NO;

    if (![self.branding isEqualToString:item.branding])
        return NO;

    if (self.type == MCTBrandedItemTypeMessage && ![self.object isEqual:item.object])
        return NO;

    if (self.type == MCTBrandedItemTypeLocalFlowAttachment) {
        NSDictionary *thisContext = (NSDictionary *)self.object;
        NSDictionary *otherContext = (NSDictionary *)item.object;
        if (![thisContext[@"threadKey"] isEqualToString:otherContext[@"threadKey"]]) {
            return NO;
        }
    } else if (self.type == MCTBrandedItemTypeAttachment) {
        NSDictionary *thisContext = (NSDictionary *)self.object;
        NSDictionary *otherContext = (NSDictionary *)item.object;
        if (![thisContext[@"thread_key"] isEqualToString:otherContext[@"thread_key"]]) {
            return NO;
        }
        if (![thisContext[@"message_key"] isEqualToString:otherContext[@"message_key"]]) {
            return NO;
        }
    }

    return YES;
}

@end


#pragma mark -
#pragma mark MCTBrandingResult

@implementation MCTBrandingResult


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
                                      rootDir:(NSString *)rootDir
{
    T_DONTCARE();
    MCTBrandingResult *r = [[MCTBrandingResult alloc] init];
    r.file = file;
    r.color = color;
    r.menuItemColor = menuItemColor;
    r.scheme = scheme;
    r.showHeader = showHeader;
    r.dimension1 = dimension1;
    r.dimension2 = dimension2;
    r.watermarkFilePath = watermarkFilePath;
    r.contentType = contentType;
    r.externalUrlPatterns = externalUrlPatterns;
    r.rootDir = rootDir;
    return r;
}

@end


#pragma mark -
#pragma mark MCTBrandingMgr

static NSRegularExpression *COLOR_REGEX;
static NSRegularExpression *MENU_ITEM_COLOR_REGEX;
static NSRegularExpression *SCHEME_REGEX;
static NSRegularExpression *HEADER_REGEX;
static NSRegularExpression *CONTENT_TYPE_REGEX;
static NSRegularExpression *DIMENSIONS_REGEX;
static NSRegularExpression *EXTERNAL_URLS_REGEX;

@interface MCTBrandingMgr ()

@property (nonatomic, copy) NSString *localFlowAttachmentsDir;
@property (nonatomic, strong) NSObject *lock;
@property (nonatomic, strong) NSObject *fileLock;
@property (nonatomic, strong) NSFileManager *fileMgr;
@property (nonatomic, strong) NSMutableDictionary *downloading;
@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, strong) MCTConfigProvider *cfgProvider;
@property (nonatomic, copy) NSString *dwnlDir;
@property (nonatomic, copy) NSString *jsDir;
@property (nonatomic, strong) NSMutableDictionary *downloadTasks; // mapping between taskIdentifier and MCTBrandedItem

- (void)save;
- (MCTBrandedItem *)messageFromQueueWithKey:(NSString *)key;
- (void)dequeue:(MCTBrandedItem *)item withSuccess:(BOOL)success;
- (void)broadcastBrandingAvailableWithBrandedItem:(MCTBrandedItem *)item withSuccess:(BOOL)success;
- (BOOL)createDwnlDir;
- (NSString *)brandingFileWithBrandingKey:(NSString *)brandingKey;
- (NSString *)brandingDirWithBrandingKey:(NSString *)brandingKey;
- (NSString *)jsEmbeddingFileWithName:(NSString *)name;
- (NSString *)jsEmbeddingDirWithName:(NSString *)name;
- (MCTBrandingResult *)prepareBrandingWithBrandedItem:(MCTBrandedItem *)item;
- (void)downloadBrandedItem:(MCTBrandedItem *)item;
- (void)scheduleDownloadWithBrandedItem:(MCTBrandedItem *)item;

@end

#pragma mark -

@implementation MCTBrandingMgr


+ (void)initialize
{
    T_DONTCARE();
    COLOR_REGEX = [[NSRegularExpression alloc] initWithPattern:@"<\\s*meta\\s+property\\s*=\\s*\"rt:style:background-color\"\\s+content\\s*=\\s*\"(#[a-f0-9]{3}([a-f0-9]{3})?)\"\\s*/>"
                                                       options:NSRegularExpressionCaseInsensitive
                                                         error:nil];
    MENU_ITEM_COLOR_REGEX = [[NSRegularExpression alloc] initWithPattern:@"<\\s*meta\\s+property\\s*=\\s*\"rt:style:menu-item-color\"\\s+content\\s*=\\s*\"(#[a-f0-9]{3}([a-f0-9]{3})?)\"\\s*/>"
                                                                 options:NSRegularExpressionCaseInsensitive
                                                                   error:nil];
    SCHEME_REGEX = [[NSRegularExpression alloc] initWithPattern:@"<\\s*meta\\s+property\\s*=\\s*\"rt:style:color-scheme\"\\s+content\\s*=\\s*\"(dark|light)\"\\s*/>"
                                                        options:NSRegularExpressionCaseInsensitive
                                                          error:nil];
    HEADER_REGEX = [[NSRegularExpression alloc] initWithPattern:@"<\\s*meta\\s+property\\s*=\\s*\"rt:style:show-header\"\\s+content\\s*=\\s*\"(true|false)\"\\s*/>"
                                                        options:NSRegularExpressionCaseInsensitive
                                                          error:nil];
    CONTENT_TYPE_REGEX = [[NSRegularExpression alloc] initWithPattern:@"<\\s*meta\\s+property\\s*=\\s*\"rt:style:content-type\"\\s+content\\s*=\\s*\"([a-zA-Z0-9_/-]*)\"\\s*/>"
                                                        options:NSRegularExpressionCaseInsensitive
                                                                error:nil];
    DIMENSIONS_REGEX = [[NSRegularExpression alloc] initWithPattern:@"<\\s*meta\\s+property\\s*=\\s*\"rt:dimensions\"\\s+content\\s*=\\s*\"\\[((\\d+,){3}\\d+)\\]\"\\s*/>"
                                                            options:NSRegularExpressionCaseInsensitive
                                                              error:nil];
    EXTERNAL_URLS_REGEX = [[NSRegularExpression alloc] initWithPattern:@"<\\s*meta\\s+property\\s*=\\s*\"rt:external-url\"\\s+content\\s*=\\s*\"(.*)\"\\s*/>"
                                                               options:NSRegularExpressionCaseInsensitive
                                                                 error:nil];
}

+ (MCTBrandingMgr *)brandingMgr
{
    T_BIZZ();
    
    MCTConfigProvider *cfg = [MCTComponentFramework configProvider];
    NSString *base64String = [cfg stringForKey:MCT_BRANDING_CONFIG_KEY];

    if (base64String != nil) {
        @try {
            return (MCTBrandingMgr *) [MCTPickler objectFromPickle:[NSData dataFromBase64String:base64String]];
        }
        @catch (NSException *exception) {
            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                [MCTSystemPlugin logError:exception
                              withMessage:@"Failed to deserialize brandingMgr"];
            }];
        }
    }

    return [[MCTBrandingMgr alloc] init];
}

- (id)init
{
    T_BIZZ();
    if (self = [super init]) {
        self.cfgProvider = [MCTComponentFramework configProvider];

        self.queue = [NSMutableArray array];
        self.downloading = [NSMutableDictionary dictionary];
        self.downloadTasks = [NSMutableDictionary dictionary];
        self.lock = [[NSObject alloc] init];
        self.fileMgr = [NSFileManager defaultManager];

        NSString *documentsDir = [MCTUtils documentsFolder];
        self.dwnlDir = [documentsDir stringByAppendingPathComponent:@"branding"];
        self.jsDir = [documentsDir stringByAppendingPathComponent:@"javascript"];

        NSString *cachesDir = [MCTUtils cachesFolder];
        self.localFlowAttachmentsDir = [cachesDir stringByAppendingPathComponent:@"flow_attachments"];

        // Exclude the download files from being backed up to iCloud
        for (NSString *dir in @[self.dwnlDir, self.jsDir, self.localFlowAttachmentsDir]) {
            [self createDir:dir];
            [MCTUtils addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:dir]];
        }
    }
    return self;
}

- (void)initialize
{
    T_BIZZ();
    [self initializeURLSession];

    if ([self.queue count] > 0) {
        @synchronized(self.lock) {
            for (MCTBrandedItem *item in self.queue) {
                [self scheduleDownloadWithBrandedItem:item];
            }
        }
    }
}

- (NSURLSessionConfiguration *)createURLSessionConfigurationWithIdentifier:(NSString *)identifier
{
    NSURLSessionConfiguration *sessionConfiguration = nil;
    IF_PRE_IOS8({
        sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
    });
    IF_IOS8_OR_GREATER({
        sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    });
    sessionConfiguration.networkServiceType = NSURLNetworkServiceTypeDefault;
    sessionConfiguration.timeoutIntervalForRequest = 300.0;
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 3;

    return sessionConfiguration;
}

+ (NSString *)URLSessionIdentifier
{
    return @"brandingMgr";
}

- (NSURLSession *)initializeURLSession
{
    NSString *identifier = [MCTBrandingMgr URLSessionIdentifier];
    NSURLSessionConfiguration *sessionConfiguration = [self createURLSessionConfigurationWithIdentifier:identifier];
    self.urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                    delegate:self
                                               delegateQueue:[MCTComponentFramework workQueue]];
    return self.urlSession;
}


#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BIZZ();
    if (self = [self init]) {
        if (classVersion < 2) {
            self.queue = [NSMutableArray array];
            if ([coder containsValueForKey:MCT_BRANDING_LEGACY_FRIEND_QUEUE]) {
                NSArray *friends = (NSArray *) [coder decodeObjectForKey:MCT_BRANDING_LEGACY_FRIEND_QUEUE];
                for (MCTFriend *friend in friends) {
                    [self.queue addObject:[MCTBrandedItem itemWithFriend:friend]];
                }
            }
            if ([coder containsValueForKey:MCT_BRANDING_LEGACY_MSG_QUEUE]) {
                NSArray *messages = (NSArray *) [coder decodeObjectForKey:MCT_BRANDING_LEGACY_MSG_QUEUE];
                for (MCTMessage *message in messages) {
                    [self.queue addObject:[MCTBrandedItem itemWithMessage:message]];
                }
            }
        } else {
            self.queue = (NSMutableArray *) [coder decodeObjectForKey:MCT_BRANDING_QUEUE];
        }

        if (classVersion < 3) {
            NSMutableDictionary *statusQueue = (NSMutableDictionary *) [coder decodeObjectForKey:MCT_BRANDING_STATUS_QUEUE];
            for (NSString *messageKey in [statusQueue allKeys]) {
                MCTBrandedItem *item = [self messageFromQueueWithKey:messageKey];
                NSArray *updates = [statusQueue objectForKey:messageKey];
                for (MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *update in updates) {
                    [item.calls addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"com.mobicage.capi.messaging.updateMemberStatus", @"function",
                                           [update dictRepresentation], @"request", nil]];
                }
            }
        }

        self.downloading = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    T_DONTCARE();
    @synchronized(self.lock) {
        [coder encodeObject:self.queue forKey:MCT_BRANDING_QUEUE];
    }
}

- (int)classVersion
{
    T_DONTCARE();
    return MCT_BRANDING_PICKLE_CLASS_VERSION;
}

- (void)save
{
    T_DONTCARE();
    NSData *pickle = [MCTPickler pickleFromObject:self];
    NSString *base64String = [pickle base64EncodedString];
    [self.cfgProvider setString:base64String forKey:MCT_BRANDING_CONFIG_KEY];
}

#pragma mark -
#pragma mark Queueing

- (BOOL)isMessageInQueue:(NSString *)key
{
    T_DONTCARE();
    @synchronized(self.lock) {
        return [self messageFromQueueWithKey:key] != nil;
    }
}

- (MCTBrandedItem *)messageFromQueueWithKey:(NSString *)key
{
    T_DONTCARE();
    @synchronized(self.lock) {
        for (MCTBrandedItem *item in self.queue) {
            if (item.type == MCTBrandedItemTypeMessage && [((MCTMessage *) item.object).key isEqualToString:key]) {
                return item;
            }
        }
    }
    return nil;
}

- (BOOL)queueIfNeededWithFunction:(NSString *)function
                       andRequest:(NSObject<IJSONable> *)request
                    andMessageKey:(NSString *)messageKey
{
    T_DONTCARE();
    @synchronized(self.lock) {
        MCTBrandedItem *item = [self messageFromQueueWithKey:messageKey];
        if (item == nil)
            return NO;

        LOG(@"Queueing %@ call for message with branding %@", function, item.branding);
        [item.calls addObject:[NSDictionary dictionaryWithObjectsAndKeys:function, @"function",
                               [request dictRepresentation], @"request", nil]];
        [self save];
        return YES;
    }
}

- (void)deleteConversationWithKey:(NSString *)threadKey
{
    T_DONTCARE();
    @synchronized(self.lock) {
        BOOL deleted = NO;
        NSArray *copy = [NSArray arrayWithArray:self.queue];
        for (MCTBrandedItem *item in copy) {
            if (item.type == MCTBrandedItemTypeMessage) {
                MCTMessage *message = (MCTMessage *) item.object;
                if ([threadKey isEqualToString:[message threadKey]]) {
                    LOG(@"Removing message with key %@ from queue because thread %@ is deleted", message.key, threadKey);
                    [self.queue removeObject:item];
                    deleted = YES;
                }
            } else if (item.type == MCTBrandedItemTypeLocalFlowAttachment || item.type == MCTBrandedItemTypeLocalFlowBranding) {
                NSDictionary *context = (NSDictionary *)item.object;
                if ([threadKey isEqualToString:context[@"threadKey"]]) {
                    LOG(@"Removing item with branding '%@' from queue because thread %@ is deleted", item.branding, threadKey);
                    [self.queue removeObject:item];
                    deleted = YES;
                }
            }
        }
        if (deleted)
            [self save];
    }
}

- (BOOL)queueItem:(MCTBrandedItem *)item
{
    T_DONTCARE();
    // Check if the item is already in the queue
    if (item.type != MCTBrandedItemTypeMessage && item.type != MCTBrandedItemTypeLocalFlowAttachment) {
        if ([MCTUtils isEmptyOrWhitespaceString:item.branding]) {
            return NO;
        }
        @synchronized(self.lock) {
            if ([self.queue containsObject:item]) {
                return NO;
            }
        }
        if (item.type == MCTBrandedItemTypeAttachment) {
            MCTMessageAttachmentPreviewItem *previewItem = [self previewItemWithBrandedItem:item];
            [self.fileMgr createDirectoryAtPath:previewItem.itemDir
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:nil];

            if ([self isAttachmentAvailable:item]) {
                return NO;
            }
        } else if (item.type != MCTBrandedItemTypeJSEmbeddingPacket
            && [self isBrandingAvailable:item.branding]) {

            [self broadcastBrandingAvailableWithBrandedItem:item withSuccess:YES];
            return NO;
        }
    }

    @synchronized(self.lock) {
        [self.queue addObject:item];
        [self save];
    }

    [self scheduleDownloadWithBrandedItem:item];
    return YES;
}

- (void)queueFriend:(MCTFriend *)friend
{
    T_BIZZ();
    if (![MCTUtils isEmptyOrWhitespaceString:friend.descriptionBranding])
        [self queueItem:[MCTBrandedItem itemWithFriend:friend]];

    if (![MCTUtils isEmptyOrWhitespaceString:friend.actionMenu.branding])
          [self queueItem:[MCTBrandedItem itemWithFriend:friend branding:friend.actionMenu.branding]];

    if (friend.actionMenu) {
        for (MCT_com_mobicage_to_friends_ServiceMenuItemTO *item in friend.actionMenu.items) {
            if (![MCTUtils isEmptyOrWhitespaceString:item.screenBranding]) {
                [self queueItem:[MCTBrandedItem itemWithGenericBranding:item.screenBranding]];
            }
        }
        for (NSString *staticFlowBranding in friend.actionMenu.staticFlowBrandings) {
            [self queueItem:[MCTBrandedItem itemWithGenericBranding:staticFlowBranding]];
        }
    }

    if (![MCTUtils isEmptyOrWhitespaceString:friend.contentBrandingHash])
        [self queueItem:[MCTBrandedItem itemWithFriend:friend branding:friend.contentBrandingHash]];
}

- (void)queueMessage:(MCTMessage *)msg
{
    T_DONTCARE();
    [self queueItem:[MCTBrandedItem itemWithMessage:msg]];
}

- (void)queueGenericBranding:(NSString *)brandingKey
{
    T_DONTCARE();
    [self queueItem:[MCTBrandedItem itemWithGenericBranding:brandingKey]];
}

- (void)queueJSEmbeddedPacketWithName:(NSString *)name embeddingHash:(NSString *)embeddingHash
{
    T_DONTCARE();
    [self queueItem:[MCTBrandedItem itemWithJSEmbeddingName:name embeddingHash:embeddingHash]];
}

- (BOOL)queueLocalFlowWithContext:(NSDictionary *)context
                     brandingKeys:(NSArray *)brandingKeys
           attachmentDownloadURLs:(NSArray *)attachmentDownloadURLs
{
    T_DONTCARE();
    NSMutableArray *items = [NSMutableArray array];

    for (NSString *brandingKey in brandingKeys) {
        MCTBrandedItem *item = [MCTBrandedItem itemWithLocalFlowBranding:brandingKey
                                                                 context:context];
        if ([self queueItem:item]) {
            [items addObject:item.branding];
        }
    }

    for (NSString *attachmentDownloadURL in attachmentDownloadURLs) {
        MCTBrandedItem *item = [MCTBrandedItem itemWithLocalFlowAttachment:attachmentDownloadURL
                                                                   context:context];
        if ([self queueItem:item]) {
            [items addObject:item.branding];
        }
    }

    if (items.count > 0) {
        @synchronized (self.fileLock) {
            [self createLocalFlowAttachmentsDirWithThreadKey:context[@"threadKey"]];
            NSString *dest = [self localFlowContentFileWithThreadKey:context[@"threadKey"]];
            LOG(@"Writing %@ to %@", items, dest);
            [items writeToFile:dest atomically:YES];
        }
    }
    return items.count > 0;
}

- (void)queueAttachment:(NSString *)downloadURL
             forMessage:(NSString *)messageKey
          withThreadKey:(NSString *)threadKey
            contentType:(NSString *)contentType
{
    T_DONTCARE();
    [self queueItem:[MCTBrandedItem itemWithAttachment:downloadURL
                                             threadKey:threadKey
                                            messageKey:messageKey
                                           contentType:contentType]];
}

- (void)dequeue:(MCTBrandedItem *)item withSuccess:(BOOL)success
{
    T_BIZZ();
    @synchronized(self.lock) {
        if (![self.queue containsObject:item]) {
            LOG(@"Item '%@' was removed from queue. Ignoring it in dequeue.", item.branding);
            return;
        }

        [self.queue removeObject:item];
        [self save];
    }

    [self broadcastBrandingAvailableWithBrandedItem:item withSuccess:success];
}

- (void)broadcastBrandingAvailableWithBrandedItem:(MCTBrandedItem *)item
                                      withSuccess:(BOOL)success
{
    T_DONTCARE();
    switch (item.type) {
        case MCTBrandedItemTypeMessage:
        {
            MCTMessage *msg = (MCTMessage *) item.object;
            [[MCTComponentFramework commQueue] addOperationWithBlock:^{
                [[MCTComponentFramework messagesPlugin] newMessage:msg withBrandingOK:YES];

                for (NSDictionary *callDict in item.calls) {
                    MCTRPCCall *call = [[MCTRPCCall alloc] init];
                    call.function = [callDict stringForKey:@"function"];
                    call.arguments = [NSDictionary dictionaryWithObject:[callDict dictForKey:@"request"]
                                                                 forKey:@"request"];
                    @try {
                        [[MCTComponentFramework callReceiver] processIncomingCall:call];
                    }
                    @catch (NSException *exception) {
                        [MCTSystemPlugin logError:exception
                                      withMessage:[NSString stringWithFormat:@"Exception while processing stashed RPC call from brandingMgr:\n%@", [call dictRepresentation]]];
                    }
                }
            }];
            break;
        }
        case MCTBrandedItemTypeFriend:
        {
            if ([self isBrandingAvailable:item.branding]) {
                MCTFriend *friend = (MCTFriend *) item.object;
                MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_SERVICE_BRANDING_RETRIEVED];
                [intent setString:friend.email forKey:@"email"];
                [intent setString:item.branding forKey:@"branding_key"];
                [[MCTComponentFramework intentFramework] broadcastIntent:intent];
            }
            break;
        }
        case MCTBrandedItemTypeGeneric:
        {
            if ([self isBrandingAvailable:item.branding]) {
                MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_GENERIC_BRANDING_RETRIEVED];
                [intent setString:item.branding forKey:@"branding_key"];
                [[MCTComponentFramework intentFramework] broadcastIntent:intent];
            }
            break;
        }
        case MCTBrandedItemTypeLocalFlowAttachment:
        case MCTBrandedItemTypeLocalFlowBranding:
        {
            [self localFlowItemDownloaded:item];
            break;
        }
        case MCTBrandedItemTypeAttachment:
        {
            if ([self isAttachmentAvailable:item]) {
                MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_ATTACHMENT_RETRIEVED];
                NSDictionary *context = (NSDictionary *)item.object;
                [intent setString:context[@"thread_key"] forKey:@"thread_key"];
                [intent setString:context[@"message_key"] forKey:@"message_key"];
                [[MCTComponentFramework intentFramework] broadcastIntent:intent];
            }
            break;

        }
        case MCTBrandedItemTypeJSEmbeddingPacket:
        {
            MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_JS_EMBEDDING_RETRIEVED];
            [intent setString:(NSString *)item.object forKey:@"js_embedding_name"];
            [[MCTComponentFramework intentFramework] broadcastIntent:intent];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark I/O Methods

- (BOOL)createDir:(NSString *)dir
{
    T_DONTCARE();
    if (![self.fileMgr fileExistsAtPath:dir] && ![self.fileMgr createDirectoryAtPath:dir
                                                         withIntermediateDirectories:YES
                                                                          attributes:nil
                                                                               error:nil]) {
        ERROR(@"Failed to create directory: %@", dir);
        return NO;
    }
    return YES;

}

- (BOOL)createDwnlDir
{
    T_DONTCARE();
    return [self createDir:self.dwnlDir];
}

- (BOOL)createJSDir
{
    T_DONTCARE();
    return [self createDir:self.jsDir];
}

- (BOOL)createLocalFlowAttachmentsDirWithThreadKey:(NSString *)threadKey
{
    T_DONTCARE();
    return [self createDir:[self.localFlowAttachmentsDir stringByAppendingPathComponent:threadKey]];
}

- (NSString *)brandingFileWithBrandingKey:(NSString *)brandingKey
{
    T_DONTCARE();
    if (![self createDwnlDir])
        return nil;

    return [self.dwnlDir stringByAppendingPathComponent:[brandingKey stringByAppendingPathExtension:@"zip"]];
}

- (NSString *)brandingDirWithBrandingKey:(NSString *)brandingKey
{
    T_DONTCARE();
    if (![self createDwnlDir])
        return nil;
    return [self.dwnlDir stringByAppendingPathComponent:brandingKey];
}

- (NSString *)jsEmbeddingFileWithName:(NSString *)name
{
    T_DONTCARE();
    if (![self createJSDir])
        return nil;
    return [self.jsDir stringByAppendingPathComponent:[name stringByAppendingPathExtension:@"zip"]];
}

- (NSString *)jsEmbeddingDirWithName:(NSString *)name
{
    T_DONTCARE();
    if (![self createJSDir])
        return nil;
    return [self.jsDir stringByAppendingPathComponent:name];
}

- (BOOL)cleanupJSEmbeddingDirWithName:(NSString *)name
{
    NSString *zipDest = [self jsEmbeddingDirWithName:name];
    if ([self.fileMgr fileExistsAtPath:zipDest]) {
        if (![self.fileMgr removeItemAtPath:zipDest error:nil]) {
            ERROR(@"Failed to delete existing javascript destination '%@' for name '%@'", zipDest, name);
            return NO;
        }
    }
    return YES;
}

- (void)cleanupBrandingWithBrandingKey:(NSString *)brandingKey
{
    T_DONTCARE();
    if (![MCTUtils isEmptyOrWhitespaceString:brandingKey]) {
        NSString *d = [self brandingDirWithBrandingKey:brandingKey];
        if (!MCT_DEBUG || ![self.fileMgr fileExistsAtPath:[d stringByAppendingPathComponent:@".hacked"]
                                              isDirectory:NO]) {
            [self.fileMgr removeItemAtPath:d error:nil];
        }
    }
}

- (void)cleanupLocalFlowCacheDirWithThreadKey:(NSString *)threadKey
{
    T_DONTCARE();
    @synchronized(self.fileLock) {
        NSString *localFlowCacheDir = [self localFlowCacheDirWithThreadKey:threadKey];
        NSError *error = nil;
        if ([self.fileMgr fileExistsAtPath:localFlowCacheDir] &&
            ![self.fileMgr removeItemAtPath:localFlowCacheDir error:&error]) {

            ERROR(@"Failed to remove localFlowCacheDir %@", localFlowCacheDir);
        }
    }
}

- (NSString *)localFlowCacheDirWithThreadKey:(NSString *)threadKey
{
    T_DONTCARE();
    return [self.localFlowAttachmentsDir stringByAppendingPathComponent:threadKey];
}

- (NSString *)localFlowAttachmentFileWithThreadKey:(NSString *)threadKey
                                       downloadURL:(NSString *)downloadURL
{
    T_DONTCARE();
    NSString *fileExtension = [[NSURL URLWithString:downloadURL] pathExtension];
    if ([MCTUtils isEmptyOrWhitespaceString:fileExtension]) {
        fileExtension = @"mp4"; // TODO: [MCTUtils fileExtensionWithMimeType:attachment.content_type];
    }

    return [[[self localFlowCacheDirWithThreadKey:threadKey]
             stringByAppendingPathComponent:[downloadURL sha256Hash]]
            stringByAppendingPathExtension:fileExtension];
}

- (NSString *)localFlowContentFileWithThreadKey:(NSString *)threadKey
{
    T_DONTCARE();
    return [[self localFlowCacheDirWithThreadKey:threadKey] stringByAppendingPathComponent:@".content"];
}


#pragma mark -

- (BOOL)isBrandingAvailable:(NSString *)brandingKey
{
    T_DONTCARE();
    if (brandingKey == nil)
        return YES;

    NSString *path = [self brandingFileWithBrandingKey:brandingKey];
    return [self.fileMgr fileExistsAtPath:path];
}

- (MCTMessageAttachmentPreviewItem *)previewItemWithBrandedItem:(MCTBrandedItem *)item
{
    NSDictionary *context = (NSDictionary *) item.object;
    return [[MCTComponentFramework messagesPlugin] previewItemForAttachmentWithName:@""
                                                                        downloadURL:item.branding
                                                                        contentType:context[@"content_type"]
                                                                          threadKey:context[@"thread_key"]
                                                                         messageKey:context[@"message_key"]];
}

- (BOOL)isAttachmentAvailable:(MCTBrandedItem *)item
{
    MCTMessageAttachmentPreviewItem *previewItem = [self previewItemWithBrandedItem:item];
    return [self.fileMgr fileExistsAtPath:previewItem.itemPath];
}

- (NSString *)escapeForHTML:(NSString *)msg
{
    T_UI();
    if ([MCTUtils isEmptyOrWhitespaceString:msg])
        return @"";

    return [[[[msg gtm_stringByEscapingForHTML]
            stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"]
            stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"]
            stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];

}

- (MCTBrandingResult *)prepareBrandingWithBrandedItem:(MCTBrandedItem *)item
{
    T_UI();
    NSString *zip = [self brandingFileWithBrandingKey:item.branding];
    if (![self.fileMgr fileExistsAtPath:zip]) {
        ERROR(@"Branding file '%@' not found for object '%@' ", zip, item.object);
        return nil;
    }

    NSString *zipDest = [self brandingDirWithBrandingKey:item.branding];
    BOOL hacked = NO;
    if ([self.fileMgr fileExistsAtPath:zipDest]) {
        hacked = MCT_DEBUG && [self.fileMgr fileExistsAtPath:[zipDest stringByAppendingPathComponent:@".hacked"] isDirectory:NO];
        if (!hacked && ![self.fileMgr removeItemAtPath:zipDest error:nil]) {
            ERROR(@"Failed to delete existing branding destination '%@' for object '%@'", zipDest, item.object);
            return nil;
        }
    }

    if (!hacked && ![MCTZipUtils unzipFile:zip to:zipDest withSha256Hash:item.branding]) {
        [self.fileMgr removeItemAtPath:zipDest error:nil];
        return nil;
    }

    NSDictionary *packets = [[MCTComponentFramework systemPlugin] jsEmbeddedPackets];
    for (MCTJSEmbedding *packet in [packets allValues]) {
        if (packet.status == MCTJSEmbeddingStatusAvailable) {
            NSString *sourceDir = [self jsEmbeddingDirWithName:packet.name];
            NSError *error;
            BOOL success = [self.fileMgr copyItemAtPath:sourceDir
                                                 toPath:[zipDest stringByAppendingPathComponent:packet.name]
                                                  error:&error];
            if (!success) {
                ERROR(@"%@", error);
            }
        }
        else {
            ERROR(@"JSEmbedding packet '%@' not downloaded yet. ", packet.name);
            [self queueJSEmbeddedPacketWithName:packet.name embeddingHash:packet.embeddingHash];
        }
    }


    NSString *htmlFile = [zipDest stringByAppendingPathComponent:@"branding.html"];
    NSString *html = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];

    NSString *watermarkFile = [zipDest stringByAppendingPathComponent:@"__watermark__"];
    if (![self.fileMgr fileExistsAtPath:watermarkFile]) {
        watermarkFile = nil;
    }

    switch (item.type) {
        case MCTBrandedItemTypeMessage:
        {
            MCTMessage *message = (MCTMessage *)item.object;
            html = [html stringByReplacingOccurrencesOfString:@"<nuntiuz_message/>"
                                                   withString:[self escapeForHTML:message.message]];
            html = [html stringByReplacingOccurrencesOfString:@"<nuntiuz_timestamp/>"
                                                   withString:[MCTUtils timestampNotation:message.timestamp]];
            html = [html stringByReplacingOccurrencesOfString:@"<nuntiuz_identity_name/>"
                                                   withString:[self escapeForHTML:[[MCTComponentFramework friendsPlugin] friendDisplayNameByEmail:message.sender]]];
            break;
        }
        case MCTBrandedItemTypeFriend:
        {
            MCTFriend *friend = (MCTFriend *) item.object;
            html = [html stringByReplacingOccurrencesOfString:@"<nuntiuz_message/>"
                                                   withString:[self escapeForHTML:friend.descriptionX]];
            html = [html stringByReplacingOccurrencesOfString:@"<nuntiuz_identity_name/>"
                                                   withString:[self escapeForHTML:friend.displayName]];
            break;
        }
        case MCTBrandedItemTypeGeneric:
        {
            if ([item.object isKindOfClass:[MCTFriend class]]) {
                MCTFriend *friend = (MCTFriend *) item.object;
                html = [html stringByReplacingOccurrencesOfString:@"<nuntiuz_identity_name/>"
                                                       withString:friend.displayName];
            }
            break;
        }
        default:
            break;
    }

    if (!hacked && ![[html dataUsingEncoding:NSUTF8StringEncoding] writeToFile:htmlFile atomically:YES]) {
        ERROR(@"Failed to substitute data into branding.html for object %@", item.object);
        return nil;
    }

    NSString *color = nil;
    NSString *menuItemColor = nil;
    MCTColorScheme scheme = MCT_DEFAULT_COLOR_SCHEME;
    BOOL showHeader = YES;
    CGSize dimension1 = CGSizeZero;
    CGSize dimension2 = CGSizeZero;
    NSTextCheckingResult *match;
    NSRange r = [html range];
    NSString *contentType = nil;

    if ((match = [COLOR_REGEX firstMatchInString:html options:COLOR_REGEX.options range:r])) {
        color = [html substringWithRange:[match rangeAtIndex:1]];
    }

    if ((match = [MENU_ITEM_COLOR_REGEX firstMatchInString:html options:MENU_ITEM_COLOR_REGEX.options range:r])) {
        menuItemColor = [html substringWithRange:[match rangeAtIndex:1]];
    }

    if ((match = [SCHEME_REGEX firstMatchInString:html options:SCHEME_REGEX.options range:r])) {
        NSString *schemeStr = [html substringWithRange:[match rangeAtIndex:1]];
        scheme = [@"dark" isEqualToString:[schemeStr lowercaseString]] ? MCTColorSchemeDark : MCTColorSchemeLight;
    }

    if ((match = [HEADER_REGEX firstMatchInString:html options:HEADER_REGEX.options range:r])) {
        NSString *showHeaderStr = [html substringWithRange:[match rangeAtIndex:1]];
        showHeader = [@"true" isEqualToString:[showHeaderStr lowercaseString]];
    }

    if ((match = [CONTENT_TYPE_REGEX firstMatchInString:html options:CONTENT_TYPE_REGEX.options range:r])) {
        contentType = [html substringWithRange:[match rangeAtIndex:1]];
    }

    if ((match = [DIMENSIONS_REGEX firstMatchInString:html options:DIMENSIONS_REGEX.options range:r])) {
        NSString *dimensionsStr = [html substringWithRange:[match rangeAtIndex:1]];
        NSArray *dimensions = [dimensionsStr componentsSeparatedByString:@","];
        @try {
            dimension1 = CGSizeMake([[dimensions objectAtIndex:0] floatValue], [[dimensions objectAtIndex:1] floatValue]);
            dimension2 = CGSizeMake([[dimensions objectAtIndex:2] floatValue], [[dimensions objectAtIndex:3] floatValue]);
        }
        @catch (NSException *e) {
            NSString *dimensionsLine = [html substringWithRange:[match rangeAtIndex:0]];
            [MCTSystemPlugin logError:e
                          withMessage:[NSString stringWithFormat:@"Invalid branding dimension: %@", dimensionsLine]];
        }
    }

    NSMutableArray *externalUrlPatterns = [NSMutableArray array];
    for (NSTextCheckingResult *m in [EXTERNAL_URLS_REGEX matchesInString:html
                                                                 options:EXTERNAL_URLS_REGEX.options
                                                                   range:r]) {
        [externalUrlPatterns addObject:[html substringWithRange:[m rangeAtIndex:1]]];
    }

    return [MCTBrandingResult brandingResultWithFile:htmlFile
                                               color:color
                                       menuItemColor:menuItemColor
                                              scheme:scheme
                                          showHeader:showHeader
                                          dimension1:dimension1
                                          dimension2:dimension2
                                   watermarkFilePath:watermarkFile
                                         contentType:contentType
                                 externalUrlPatterns:externalUrlPatterns
                                             rootDir:zipDest];
}

/**
 * Prepares branding for service description
 */
- (MCTBrandingResult *)prepareBrandingWithFriend:(MCTFriend *)friend
{
    T_UI();
    return [self prepareBrandingWithBrandedItem:[MCTBrandedItem itemWithFriend:friend]];
}

- (MCTBrandingResult *)prepareBrandingWithMessage:(MCTMessage *)msg
{
    T_UI();
    return [self prepareBrandingWithBrandedItem:[MCTBrandedItem itemWithMessage:msg]];
}

- (MCTBrandingResult *)prepareBrandingWithKey:(NSString *)brandingKey forFriend:(MCTFriend *)friend
{
    T_UI();
    MCTBrandedItem *item = [MCTBrandedItem itemWithType:MCTBrandedItemTypeGeneric object:friend branding:brandingKey];
    return [self prepareBrandingWithBrandedItem:item];
}

+ (CGFloat)calculateHeightWithBrandingResult:(MCTBrandingResult *)br andWidth:(int)width
{
    T_UI();
    if (CGSizeEqualToSize(CGSizeZero, br.dimension1) || CGSizeEqualToSize(CGSizeZero, br.dimension2)) {
        return 0;
    }

    int w0 = br.dimension1.width;
    int h0 = br.dimension1.height;
    int w1 = br.dimension2.width;
    int h1 = br.dimension2.height;

    if (w1 == w0) {
        // prevent division by zero
        return 0;
    }

    CGFloat height = h0 + (h1 - h0) * (width - w0) / (w1 - w0);
    LOG(@"Calculated branding size: %@", NSStringFromCGSize(CGSizeMake(width, height)));
    return height;
}

#pragma mark -
#pragma mark Downloading

- (void)       URLSession:(NSURLSession *)session
             downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    T_BIZZ();

    if (((NSHTTPURLResponse *)downloadTask.response).statusCode != 200) {
        // Will be handled by URLSession:task:didCompleteWithError:
        return;
    }

    HERE();
    MCTBrandedItem *item;
    @synchronized(self.downloadTasks) {
        LOG(@"1 self.downloadTasks: %@", self.downloadTasks);
        item = [self.downloadTasks objectForKey:[self identifierForTask:downloadTask]];
    }

    @synchronized(self.lock) {
        if (item == nil) {
            item = [MCTBrandedItem itemWithGenericBranding:downloadTask.originalRequest.URL.pathComponents.lastObject];
            if (![self.queue containsObject:item]) {
                // Need to retain because dequeueing will release |item|
                //[item retain];
            }
        }

        NSMutableArray *items = [self.downloading objectForKey:item.branding];
        if (items != nil) {
            [items removeObject:item];
        }
    }

    BOOL success = YES;
    if (item.type == MCTBrandedItemTypeJSEmbeddingPacket) {
        success = [self extractDownloadedJSEmbeddingItem:item withDownloadLocation:location];
    } else if (item.type == MCTBrandedItemTypeLocalFlowAttachment || item.type == MCTBrandedItemTypeAttachment) {
        success = [self storeDownloadedAttachment:item withDownloadLocation:location];
    } else {
        NSString *sha256String = [[[NSData dataWithContentsOfURL:location] sha256Hash] uppercaseString];
        if ([item.branding isEqualToString:sha256String]) {
            success = [self storeDownloadedBranding:item withDownloadLocation:location];
        } else {
            ERROR(@"SHA256 digest '%@' could not be validated against branding key '%@'\nObject: %@",
                  sha256String, item.branding, item.object);
            success = NO;
        }
    }

    [self dequeue:item withSuccess:success];

    @synchronized(self.lock) {
        if ([self.downloading containsKey:item.branding]) {
            NSArray *items = [self.downloading objectForKey:item.branding];
            if (items && [items count]) {
                for (MCTBrandedItem *item in items) {
                    [self dequeue:item withSuccess:success];
                }
            }
            [self.downloading removeObjectForKey:item.branding];
        }
    }

    @synchronized(self.downloadTasks) {
        [self.downloadTasks removeObjectForKey:[self identifierForTask:downloadTask]];
        LOG(@"2 self.downloadTasks: %@", self.downloadTasks);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    T_BIZZ();
    [[MCTComponentFramework appDelegate] callCompletionHandlerForSession:session.configuration.identifier];
    if (error == nil && ((NSHTTPURLResponse *)task.response).statusCode == 200) {
        return; // URLSession:downloadTask:didFinishDownloadingToURL: will handle the happy path
    }

    HERE();
    MCTBrandedItem *item;
    @synchronized(self.downloadTasks) {
        LOG(@"3 self.downloadTasks: %@", self.downloadTasks);
        item = [self.downloadTasks objectForKey:[self identifierForTask:task]];
    }

    @synchronized(self.lock) {
        if (item == nil) {
            item = [MCTBrandedItem itemWithGenericBranding:task.originalRequest.URL.pathComponents.lastObject];
            if (![self.queue containsObject:item]) {
                // Need to retain because dequeueing will release |item|
                //[item retain];
            }
        }
        NSMutableArray *items = [self.downloading objectForKey:item.branding];
        if (items != nil) {
            [items removeObject:item];
        }
    }
    ERROR(@"Error downloading branding for object %@:\n\n%@", item.object, error);

    @synchronized(self.downloadTasks) {
        [self.downloadTasks removeObjectForKey:[self identifierForTask:task]];
        LOG(@"4 self.downloadTasks: %@", self.downloadTasks);
    }

    item.attemptsLeft--;

    if (item.attemptsLeft) {
        // should retry
        @synchronized(self.lock) {
            [self save];
        }

        NSArray *items = [self.downloading objectForKey:item.branding];
        if (items && [items count]) {
            [self.downloading removeObjectForKey:item.branding];
            for (MCTBrandedItem *item in items) {
                [self scheduleDownloadWithBrandedItem:item];
            }
        } else {
            [self scheduleDownloadWithBrandedItem:item];
        }
        return;
    } else {
        @synchronized(self.lock) {
            [self.downloading removeObjectForKey:item.branding];
        }
    }

    [self dequeue:item withSuccess:NO];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    T_BIZZ();
    if (MCT_DEBUG_LOGGING) {
        MCTBrandedItem *item = [self.downloadTasks objectForKey:[self identifierForTask:downloadTask]];
        LOG(@"Branding %@ resuming at %lld/%lld (%d%%)", item.branding, fileOffset, expectedTotalBytes,
            expectedTotalBytes ? (100 * fileOffset / expectedTotalBytes) : 100);
    }
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    T_BIZZ();
    HTTPHERE();
    if (!error) {
        return; // session has been explicitly invalidated
    }

    HTTPLOG(@"URL session did become invalid with error: %@", error);
    if ([[MCTBrandingMgr URLSessionIdentifier] isEqualToString:session.configuration.identifier]) {
        [self initializeURLSession];
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    T_BIZZ();
    HERE();
    [[MCTComponentFramework appDelegate] callCompletionHandlerForSession:session.configuration.identifier];
}

- (void)downloadBrandedItem:(MCTBrandedItem *)item
{
    T_DWNL();
    @synchronized(self.lock) {
        if ((item.type == MCTBrandedItemTypeAttachment && [self isAttachmentAvailable:item])
            || [self isBrandingAvailable:item.branding]) {

            LOG(@"Branding %@ is already available. Dequeueing item.", item.branding);
            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                T_BIZZ();
                [self dequeue:item withSuccess:YES];
            }];
            return;
        }
        // Don't check if we're already downloading localFlowAttachments
        // (the location on disk is variable, so we wouldn't know under which threadKey it is stored)
        // We could achieve this with hard links, but that would be too much effort at this time.
        if (item.type != MCTBrandedItemTypeLocalFlowAttachment) {
            if ([self.downloading containsKey:item.branding]) {
                LOG(@"Already downloading branding %@", item.branding);
                NSMutableArray *items = [self.downloading objectForKey:item.branding];
                if (![items containsObject:item]) {
                    [items addObject:item];
                }
                return;
            } else {
                [self.downloading setObject:[NSMutableArray arrayWithObject:item] forKey:item.branding];
            }
        }
    }

    NSString *url;
    if (item.type == MCTBrandedItemTypeJSEmbeddingPacket) {
        url = [NSString stringWithFormat:MCT_JS_EMBEDDING_URL_FORMAT, MCT_HTTPS_BASE_URL, item.object];
    } else if (item.type == MCTBrandedItemTypeLocalFlowAttachment || item.type == MCTBrandedItemTypeAttachment) {
        url = (NSString *)item.branding;
    } else {
        url = [NSString stringWithFormat:MCT_BRANDING_URL_FORMAT, MCT_HTTPS_BASE_URL, item.branding];
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    request.HTTPShouldHandleCookies = NO;
    request.timeoutInterval = 300.0;
    request.allowsCellularAccess = ![[MCTComponentFramework systemPlugin] wifiOnlyDownloads]
        || (item.type != MCTBrandedItemTypeLocalFlowAttachment);

    if (item.type == MCTBrandedItemTypeJSEmbeddingPacket) {
        [request addValue:[[self.cfgProvider stringForKey:MCT_CONFIGKEY_USERNAME] MCTBase64Encode] forHTTPHeaderField:@"X-MCTracker-User"];
        [request addValue:[[self.cfgProvider stringForKey:MCT_CONFIGKEY_PASSWORD] MCTBase64Encode] forHTTPHeaderField:@"X-MCTracker-Pass"];
    }

    @synchronized(self.downloadTasks) {
        NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:request];
        LOG(@"Downloading %@", request.URL);
        [task resume];

        [self.downloadTasks setObject:item forKey:[self identifierForTask:task]];
        LOG(@"0 self.downloadTasks: %@", self.downloadTasks);
    }
}

- (NSString *)identifierForTask:(NSURLSessionTask *)task
{
    T_DONTCARE();
    return [NSString stringWithFormat:@"%lu", (unsigned long)task.taskIdentifier];
}

- (void)scheduleDownloadWithBrandedItem:(MCTBrandedItem *)item
{
    T_DONTCARE();
    MCTInvocationOperation *op = [MCTInvocationOperation operationWithTarget:self
                                                                    selector:@selector(downloadBrandedItem:)
                                                                      object:item];
    NSOperationQueuePriority priority;
    switch (item.type) {
        case MCTBrandedItemTypeLocalFlowAttachment:
        case MCTBrandedItemTypeLocalFlowBranding:
        case MCTBrandedItemTypeAttachment:
        case MCTBrandedItemTypeMessage: {
            priority = NSOperationQueuePriorityVeryHigh;
            break;
        }
        case MCTBrandedItemTypeJSEmbeddingPacket: {
            priority = NSOperationQueuePriorityHigh;
            break;
        }
        case MCTBrandedItemTypeGeneric: {
            priority = NSOperationQueuePriorityNormal;
            break;
        }
        case MCTBrandedItemTypeFriend:
        default: {
            priority = NSOperationQueuePriorityLow;
            break;
        }
    }
    [op setQueuePriority:priority];
    LOG(@"Scheduling download of %@ with priority %d", item.branding, priority);
    [[MCTComponentFramework downloadQueue] addOperation:op];
}


#pragma mark - Saving

- (BOOL)storeDownloadedBranding:(MCTBrandedItem *)item withDownloadLocation:(NSURL *)location
{
    T_BIZZ();
    assert(item.type != MCTBrandedItemTypeJSEmbeddingPacket);
    assert(item.type != MCTBrandedItemTypeLocalFlowAttachment);
    assert(item.type != MCTBrandedItemTypeAttachment);

    NSString *destination = [self brandingFileWithBrandingKey:item.branding];

    if ([self.fileMgr fileExistsAtPath:destination]) {
        LOG(@"Branding %@ zip already exists", item.branding);
        return YES;
    }

    LOG(@"Storing branding file at '%@'", destination);
    if (![self.fileMgr moveItemAtPath:location.path toPath:destination error:nil]) {
        ERROR(@"Failed to move downloaded branding file from '%@' to '%@'.\nObject: %@",
              location.path, destination, item.object);
        return NO;
    }

    return YES;
}

- (BOOL)extractDownloadedJSEmbeddingItem:(MCTBrandedItem *)item withDownloadLocation:(NSURL *)location
{
    T_BIZZ();
    assert(item.type == MCTBrandedItemTypeJSEmbeddingPacket);
    NSString *name = (NSString *)item.object;

    [self cleanupJSEmbeddingDirWithName:name];

    NSString *dest = [self jsEmbeddingDirWithName:name];
    if (![MCTZipUtils unzipFile:[location path] to:dest withSha256Hash:item.branding]) {
        [self.fileMgr removeItemAtPath:dest error:nil];
        return NO;
    }

    [self.fileMgr removeItemAtURL:location error:nil];

    [[MCTComponentFramework systemPlugin] updateJSEmbeddedWithName:name
                                                              hash:item.branding
                                                            status:MCTJSEmbeddingStatusAvailable];
    return YES;
}

- (BOOL)storeDownloadedAttachment:(MCTBrandedItem *)item withDownloadLocation:(NSURL *)location
{
    T_BIZZ();
    assert(item.type == MCTBrandedItemTypeLocalFlowAttachment || item.type == MCTBrandedItemTypeAttachment);

    NSString *destination;
    NSDictionary *context = (NSDictionary *)item.object;

    if (item.type == MCTBrandedItemTypeAttachment) {
        MCTMessageAttachmentPreviewItem *previewItem = [self previewItemWithBrandedItem:item];

        if (![self.fileMgr fileExistsAtPath:[previewItem.itemDir stringByDeletingLastPathComponent]]) {
            LOG(@"Attachment dir for thread %@ does not exist anymore. Thread must have been deleted.",
                context[@"thread_key"]);
            return NO;
        }

        destination = previewItem.itemPath;
    }

    else if (item.type == MCTBrandedItemTypeLocalFlowAttachment) {
        NSString *threadKey = context[@"threadKey"];
        if (![self.fileMgr fileExistsAtPath:[self localFlowCacheDirWithThreadKey:threadKey]]) {
            LOG(@"LocalFlowCacheDir for thread %@ does not exist anymore. Thread must have been deleted, or flow is already ended.", threadKey);
            return NO;
        }

        destination = [self localFlowAttachmentFileWithThreadKey:threadKey
                                                     downloadURL:item.branding];
    }

    NSError *error = nil;
    if (![self.fileMgr moveItemAtPath:[location path]
                               toPath:destination
                                error:&error]) {
        ERROR(@"Failed to move downloaded attachment file \nfrom '%@' \nto '%@'.\nObject: %@\n\nError: %@",
              location.path, destination, item.object, error);
    }

    if (item.type == MCTBrandedItemTypeAttachment) {
        // try to generate a thumbnail image
        UIImage *thumbnail = nil;
        if ([context[@"content_type"] hasPrefix:@"image/"]) {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:destination]];

            UIScreen *mainScreen = [UIScreen mainScreen];
            CGFloat destinationWidth = mainScreen.applicationFrame.size.width * 2/3 * mainScreen.scale;

            if (destinationWidth < image.size.width || destinationWidth < image.size.height) {
                thumbnail = [MCTUIUtils createThumbnailWithSize:CGSizeMake(destinationWidth, destinationWidth)
                                                       forImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:destination]]];
            }
        } else if ([context[@"content_type"] hasPrefix:@"video/"]) {
            thumbnail = [MCTUIUtils createThumbnailForVideoWithURL:[NSURL fileURLWithPath:destination]
                                                       contentType:context[@"content_type"]];
        }

        if (thumbnail) {
            [UIImageJPEGRepresentation(thumbnail, 0) writeToFile:[destination stringByAppendingString:@".thumb"]
                                                      atomically:YES];
        }
    }

    return YES;
}

- (void)localFlowItemDownloaded:(MCTBrandedItem *)item
{
    T_DONTCARE();
    @synchronized(self.fileLock) {
        NSDictionary *context = (NSDictionary *)item.object;
        NSString *contentFile = [self localFlowContentFileWithThreadKey:context[@"threadKey"]];

        // This method is executed for brandings which are already available while queueing,
        // so the .content file might not yet exist since we are still queueing brandings/attachments
        if ([self.fileMgr fileExistsAtPath:contentFile]) {
            NSMutableArray *items = [NSMutableArray arrayWithContentsOfFile:contentFile];
            [items removeObject:item.branding];

            if (items.count == 0) {
                [self.fileMgr removeItemAtPath:contentFile error:nil];
                [[MCTComponentFramework messagesPlugin] startLocalFlowWithContext:context];
            } else {
                LOG(@"Writing %@ to %@", items, contentFile);
                [items writeToFile:contentFile atomically:YES];
            }
        }
    }
}

#pragma mark -

- (void)terminate
{
    [self.urlSession invalidateAndCancel];
}

- (void)dealloc
{
    T_BIZZ();
    @synchronized(self.lock) {
        [self save];
    }
    
}

@end