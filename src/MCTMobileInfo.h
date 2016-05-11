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

@interface MCTCarrierInfo : NSObject

@property (nonatomic, copy) NSString *isoCountryCode;
@property (nonatomic, copy) NSString *mobileCountryCode;
@property (nonatomic, copy) NSString *mobileNetworkCode;
@property (nonatomic, copy) NSString *carrierName;

+ (MCTCarrierInfo *)info;

- (NSString *)fingerPrint;

@end

#pragma mark -

@interface MCTLocaleInfo : NSObject

@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *country;

+ (MCTLocaleInfo *)info;

- (NSString *)fingerPrint;

@end

#pragma mark -

@interface MCTTimeZoneInfo : NSObject

@property (nonatomic, copy) NSString *abbrevation;
@property (nonatomic) NSInteger secondsFromGMT;

+ (MCTTimeZoneInfo *)info;

- (NSString *)fingerPrint;

@end

#pragma mark -

@interface MCTDeviceInfo : NSObject

@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *osVersion;

+ (MCTDeviceInfo *)info;

- (NSString *)fingerPrint;

@end

#pragma mark -

@interface MCTApplicationInfo : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger type;
@property (nonatomic) NSInteger minorVersion;
@property (nonatomic) NSInteger majorVersion;

+ (MCTApplicationInfo *)info;
+ (NSInteger)type;

- (NSString *)fingerPrint;

@end

#pragma mark -

@interface MCTMobileInfo : NSObject

@property (nonatomic, strong) MCTCarrierInfo *carrier;
@property (nonatomic, strong) MCTLocaleInfo *locale;
@property (nonatomic, strong) MCTTimeZoneInfo *timeZone;
@property (nonatomic, strong) MCTDeviceInfo *device;
@property (nonatomic, strong) MCTApplicationInfo *app;

+ (MCTMobileInfo *)info;

- (NSString *)fingerPrint;

@end