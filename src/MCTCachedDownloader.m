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
#import "MCTCachedDownloader.h"
#import "MCTEncoding.h"

@implementation MCTCachedDownloader


+ (MCTCachedDownloader *)sharedInstance
{
    T_DONTCARE();
    static MCTCachedDownloader *sharedInstance_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance_ = [[MCTCachedDownloader alloc] init];
        sharedInstance_.fileMgr = [NSFileManager defaultManager];
        NSString *cachesDir = [MCTUtils cachesFolder];
        sharedInstance_.dwnlDir = [cachesDir stringByAppendingPathComponent:@"downloads"];
        sharedInstance_.queue = [NSMutableArray array];

        // Exclude the download files from being backed up to iCloud
        [sharedInstance_ createDir:sharedInstance_.dwnlDir];
        [MCTUtils addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:sharedInstance_.dwnlDir]];
    });
    return sharedInstance_;
}

- (NSString *)getHash:(NSString *)urlString
{
    T_DONTCARE();
    return [urlString sha256Hash];
}

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

- (NSString *)getCachedFilePathForHash:(NSString *)urlHash
{
    T_DONTCARE();
    if (![self createDwnlDir])
        return nil;
    return [self.dwnlDir stringByAppendingPathComponent:urlHash];
}

- (NSString *)getCachedFilePathWithUrl:(NSString *)urlString;
{
    T_UI();
    NSString *urlHash = [self getHash:urlString];
    NSString *cachedFilePath = [self getCachedFilePathForHash:urlHash];
    if (cachedFilePath == nil)
        return nil;

    if ([self.fileMgr fileExistsAtPath:cachedFilePath]) {
        [self updateModificationDate:cachedFilePath];
        return cachedFilePath;
    }

    if ([self.queue containsObject:urlHash])
        return nil;

    [self.queue addObject:urlHash];

    if (self.httpRequest) {
        [self.httpRequest clearDelegatesAndCancel];
        MCT_RELEASE(self.httpRequest);
    }
    self.httpRequest = [MCTHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    self.httpRequest.timeOutSeconds = 30;
    self.httpRequest.delegate = self;
    self.httpRequest.didFailSelector = @selector(resolveAddressFailed:);
    self.httpRequest.didFinishSelector = @selector(resolveAddressFinished:);
    self.httpRequest.validatesSecureCertificate = YES;
    [self.httpRequest setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:urlHash , @"urlHash", urlString, @"urlString", nil]];
    [[MCTComponentFramework downloadQueue] addOperation:self.httpRequest];
    return nil;
}

- (void)resolveAddressFailed:(MCTHTTPRequest *)request
{
    T_UI();
    NSString *urlHash = [[request userInfo] valueForKey:@"urlHash"];
    NSString *urlString = [[request userInfo] valueForKey:@"urlString"];
    LOG(@"Failed resolving '%@'", urlString);
    [self.queue removeObject:urlHash];
}

- (void)resolveAddressFinished:(MCTHTTPRequest *)request
{
    T_UI();
    NSString *urlHash = [[request userInfo] valueForKey:@"urlHash"];
    NSString *urlString = [[request userInfo] valueForKey:@"urlString"];
    NSString *cachedFilePath = [self getCachedFilePathForHash:urlHash];

    LOG(@"Got status '%d' when resolving '%@'", request.responseStatusCode, urlString);
    if (request.responseStatusCode == 200) {
        if (![request.responseData writeToFile:cachedFilePath atomically:YES]) {
            ERROR(@"Failed to save attachment file to '%@'", cachedFilePath);
        } else {
            MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_CACHED_FILE_RETRIEVED];
            [intent setString:urlHash forKey:@"hash"];
            [intent setString:urlString forKey:@"url"];
            [[MCTComponentFramework intentFramework] broadcastIntent:intent];
        }
    }
    [self.queue removeObject:urlHash];
}

- (void)updateModificationDate:(NSString *)filePath
{
    T_UI();
    NSError *error;
    if (![self.fileMgr setAttributes:@{NSFileModificationDate:[NSDate date]}
                         ofItemAtPath:filePath error:&error]) {
        ERROR(@"Couldn't update modification date: %@", error);
    }
}

- (void)cleanupOldCachedFiles
{
    T_BIZZ();
    NSDate *lastMonth = [[NSDate date] dateByAddingTimeInterval:(-30*24*60*60)];
    for (NSString *urlHash in [self.fileMgr enumeratorAtPath:self.dwnlDir]) {
        NSString *filePath = [self getCachedFilePathForHash:urlHash];
        NSDate *modificationDate = [[self.fileMgr attributesOfItemAtPath:filePath error:nil] fileModificationDate];
        if ([modificationDate compare:lastMonth] == NSOrderedAscending) {
            if (![self.fileMgr removeItemAtPath:filePath error:nil]) {
                ERROR(@"Failed to delete old cached file with urlHash '%@'", urlHash);
            }
        }
    }

    MCTlong epoch = [MCTUtils currentTimeSeconds];
    [[MCTComponentFramework configProvider] setString:[NSString stringWithFormat:@"%lld", epoch] forKey:MCT_CONFIGKEY_CACHED_DOWNLOADS_CLEANUP];
}

- (void)dealloc
{
    T_UI();
    [self.httpRequest clearDelegatesAndCancel];
}

@end