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

#import <CommonCrypto/CommonDigest.h>

#import "MCTEncoding.h"

#import "NSData+Base64.h"
#import "NSData+XMPP.h"


@implementation MCTEncoding

+ (NSString *)emailHashForEmail:(NSString *)email withType:(MCTFriendType)friendType
{
    T_DONTCARE();
    if (friendType == MCTFriendTypeUser && ![MCT_PRODUCT_ID isEqualToString:@"rogerthat"]) {
        email = [NSString stringWithFormat:@"%@:%@", email, MCT_PRODUCT_ID];
    }
    return [[email MCSha256EncodedData] MCEncodedString];
}

@end


@implementation NSString (MCTMCEncoding)

- (NSData *)MCSha256EncodedData
{
    
    return [[[NSString stringWithFormat:MCT_EMAIL_HASH_ENCRYPTION_KEY, self] dataUsingEncoding:NSUTF8StringEncoding] sha256Digest];
}

- (NSString *)MCDecodedString
{
    NSMutableString *value = [NSMutableString stringWithString:self];
    NSRange r = NSMakeRange(0, [value length]);
    [value replaceOccurrencesOfString:@"." withString:@"+" options:0 range:r];
    [value replaceOccurrencesOfString:@"-" withString:@"=" options:0 range:r];
    [value replaceOccurrencesOfString:@"_" withString:@"/" options:0 range:r];

    return [[NSString alloc] initWithData:[NSData dataFromBase64String:value] encoding:NSUTF8StringEncoding];
}

- (NSString *)sha256Hash
{
    const char *s = [self UTF8String];
    NSData *data = [NSData dataWithBytes:s length:strlen(s)];
    return [data sha256Hash];
}

@end


@implementation NSData (MCTMCEncoding)

- (NSString *)MCEncodedString
{
    NSMutableString *result = [NSMutableString stringWithString:[self xmpp_base64Encoded]];
    NSRange r = NSMakeRange(0, [result length]);
    [result replaceOccurrencesOfString:@"+" withString:@"." options:0 range:r];
    [result replaceOccurrencesOfString:@"=" withString:@"-" options:0 range:r];
    [result replaceOccurrencesOfString:@"/" withString:@"_" options:0 range:r];

    return [NSString stringWithString:result];
}

@end

@implementation NSData (MCTSha256)

- (NSData *)sha256Digest
{
    unsigned char result[CC_SHA256_DIGEST_LENGTH];

    CC_SHA256([self bytes], (CC_LONG)[self length], result);

    return [NSData dataWithBytes:result length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *)sha256Hash
{
    return [[self sha256Digest] xmpp_hexStringValue];
}

@end