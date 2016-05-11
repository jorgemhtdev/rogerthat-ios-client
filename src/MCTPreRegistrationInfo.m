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
#import "MCTJSONUtils.h"
#import "MCTPreRegistrationInfo.h"
#import "MCTUtils.h"

#import "NSData+Base64.h"

#define MCT_REGISTRATION_VERSION 2
#define MCT_SIGNATURE_FORMAT_INIT @"%@%@ %@ %@ %@ %@"

#define MCT_PRE_REG_INFO_PICKLE_CLASS_VERSION 1
#define MCT_PICKLE_KEY_EMAIL @"email"
#define MCT_PICKLE_KEY_REGISTRATION_TIME @"registrationTime"
#define MCT_PICKLE_KEY_REGISTRATION_ID @"registrationId"


@implementation MCTPreRegistrationInfo


+ (MCTPreRegistrationInfo *)infoWithEmail:(NSString *)mail
{
    return [[MCTPreRegistrationInfo alloc] initWithEmail:mail];
}

- (id)initWithEmail:(NSString *)mail
{
    if (self = [super init]) {
        self.email = mail;
        self.registrationTime = [NSNumber numberWithLongLong:[MCTUtils serverTimeFromClientTime:[MCTUtils currentTimeMillis]]];
        self.registrationId = [MCTUtils guid];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    if (classVersion != MCT_PRE_REG_INFO_PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    if (self = [super init]) {
        self.email = [coder decodeObjectForKey:MCT_PICKLE_KEY_EMAIL];
        self.registrationTime = [coder decodeObjectForKey:MCT_PICKLE_KEY_REGISTRATION_TIME];
        self.registrationId = [coder decodeObjectForKey:MCT_PICKLE_KEY_REGISTRATION_ID];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.email forKey:MCT_PICKLE_KEY_EMAIL];
    [coder encodeObject:self.registrationTime forKey:MCT_PICKLE_KEY_REGISTRATION_TIME];
    [coder encodeObject:self.registrationId forKey:MCT_PICKLE_KEY_REGISTRATION_ID];
}

- (int)classVersion
{
    return MCT_PRE_REG_INFO_PICKLE_CLASS_VERSION;
}

- (NSNumber *)version
{
    return [NSNumber numberWithInt:MCT_REGISTRATION_VERSION];
}

- (NSString *)deviceId
{
    return [MCTUtils deviceId];
}

- (NSString *)requestSignature
{
    NSString *s = [NSString stringWithFormat:MCT_SIGNATURE_FORMAT_INIT, self.version, self.email, self.registrationTime,
                   self.deviceId, self.registrationId, MCT_REGISTRATION_EMAIL_SIGNATURE];
    return [s sha256Hash];
}

- (NSString *)description
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.version forKey:@"version"];
    [dict setObject:self.email forKey:@"email"];
    [dict setObject:self.registrationTime forKey:@"registrationTime"];
    [dict setObject:self.deviceId forKey:@"deviceId"];
    [dict setObject:self.registrationId forKey:@"registrationId"];
    [dict setObject:self.requestSignature forKey:@"requestSignature"];
    return [NSString stringWithFormat:@"%@: %@", [self class], [dict description]];
}

@end