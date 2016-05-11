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

#import "MCTRPCItem.h"

@interface MCTRPCCall : MCTRPCItem

@property (nonatomic, copy) NSString *function;
@property (nonatomic, strong) NSDictionary *arguments;

- (MCTRPCCall *)initWithDict:(NSDictionary *)dict;

+ (MCTRPCCall *)call;

+ (MCTRPCCall *)callWithDict:(NSDictionary *)dict;

+ (BOOL)isSingleCallFunction:(NSString *)func;
- (BOOL)isSingleCall;

+ (BOOL)isSpecialSingleCallFunction:(NSString *)func;
- (BOOL)isSpecialSingleCall;

+ (BOOL)isWifiOnlyCallFunction:(NSString *)func;
- (BOOL)isWifiOnlyCall;

- (BOOL)isEqualToSpecialSingleCallWithBody:(NSString *)callBody;

@end