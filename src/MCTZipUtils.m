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

#import "MCTEncoding.h"
#import "MCTZipUtils.h"
#import "ZipArchive.h"

#define MCT_ZIP_BUFFER_SIZE 16384


@implementation MCTZipUtils

+ (BOOL)unzipFile:(NSString *)fromPath to:(NSString *)toPath withSha256Hash:(NSString *)sha256Hash
{
    T_DONTCARE();

    NSData *zipData = [[NSData alloc] initWithContentsOfFile:fromPath];
    NSString *zipHash = [[zipData sha256Hash] uppercaseString];
    if (![sha256Hash isEqualToString:zipHash]) {
        ERROR(@"SHA256 digest '%@' could not be validated against branding key '%@'", zipHash, sha256Hash);
        return NO;
    }

    ZipArchive *za = [[ZipArchive alloc] init];

    if (![za UnzipOpenFile:fromPath]) {
        ERROR(@"Failed to open zip file '%@'", fromPath);
        return NO;
    }

    if (![za UnzipFileTo:toPath overWrite:YES]) {
        ERROR(@"Failed to unzip file '%@' to '%@'", fromPath, toPath);
        return NO;
    }

    [za UnzipCloseFile];
    return YES;
}

@end