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

#import "MCTPreRegistrationInfo.h"


@interface MCTPendingRegistrationInfo : NSObject

+ (MCTPendingRegistrationInfo *)infoWithPreRegistrationInfo:(MCTPreRegistrationInfo *)info
                                                 andPinCode:(NSString *)pin;

- (id)initWithPreRegistrationInfo:(MCTPreRegistrationInfo *)info
                       andPinCode:(NSString *)pin;

@property (nonatomic, strong) MCTPreRegistrationInfo *preRegistrationInfo;
@property (weak, nonatomic, readonly) NSNumber *version;
@property (weak, nonatomic, readonly) NSString *email;
@property (weak, nonatomic, readonly) NSNumber *registrationTime;
@property (weak, nonatomic, readonly) NSString *deviceId;
@property (weak, nonatomic, readonly) NSString *registrationId;
@property (nonatomic, copy) NSString *pinCode;
@property (weak, nonatomic, readonly) NSString *pinSignature;

@end