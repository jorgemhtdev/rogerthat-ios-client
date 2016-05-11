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
#import "MCTPendingRegistrationInfo.h"


#define MCT_SIGNATURE_FORMAT_PIN @"%@ %@ %@ %@ %@ %@%@"

@implementation MCTPendingRegistrationInfo



+ (MCTPendingRegistrationInfo *)infoWithPreRegistrationInfo:(MCTPreRegistrationInfo *)info
                                                 andPinCode:(NSString *)pin
{
    return [[MCTPendingRegistrationInfo alloc] initWithPreRegistrationInfo:info andPinCode:pin];
}

- (id)initWithPreRegistrationInfo:(MCTPreRegistrationInfo *)info
                       andPinCode:(NSString *)pin
{
    if (self = [super init]) {
        self.preRegistrationInfo = info;
        self.pinCode = pin;
    }
    return self;
}

- (NSNumber *)version
{
    return self.preRegistrationInfo.version;
}

- (NSString *)email
{
    return self.preRegistrationInfo.email;
}

- (NSNumber *)registrationTime
{
    return self.preRegistrationInfo.registrationTime;
}

- (NSString *)deviceId
{
    return self.preRegistrationInfo.deviceId;
}

- (NSString *)registrationId
{
    return self.preRegistrationInfo.registrationId;
}

- (NSString *)pinSignature
{
    NSString *s = [NSString stringWithFormat:MCT_SIGNATURE_FORMAT_PIN, self.version, self.email, self.registrationTime,
                   self.deviceId, self.registrationId, self.pinCode, MCT_REGISTRATION_PIN_SIGNATURE];
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
    [dict setObject:self.pinCode forKey:@"pinCode"];
    [dict setObject:self.pinSignature forKey:@"pinSignature"];
    return [NSString stringWithFormat:@"%@: %@", [self class], [dict description]];
}

@end