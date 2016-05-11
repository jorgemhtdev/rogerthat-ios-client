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

#import "3rdParty/json/MCT_JSON.h"

@protocol IJSONable
@required
- (id)initWithDict:(NSDictionary *)dict;
- (NSDictionary *)dictRepresentation;
@end


@interface NSDictionary (MCTTools1)

- (BOOL)containsKey:(NSString *)key;
- (BOOL)containsBoolObjectForKey:(NSString *)key;
- (BOOL)containsLongObjectForKey:(NSString *)key;
- (BOOL)containsFloatObjectForKey:(NSString *)key;

- (NSArray *)arrayForKey:(NSString *)key;
- (NSArray *)arrayForKey:(NSString *)key withDefaultValue:(NSArray *)defaultValue;

- (NSDictionary *)dictForKey:(NSString *)key;
- (NSDictionary *)dictForKey:(NSString *)key withDefaultValue:(NSDictionary *)defaultValue;

- (NSString *)stringForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key withDefaultValue:(NSString *)defaultValue;

- (BOOL)boolForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key withDefaultValue:(BOOL)defaultValue;

- (MCTlong)longForKey:(NSString *)key;
- (MCTlong)longForKey:(NSString *)key withDefaultValue:(MCTlong)defaultValue;

- (MCTFloat)floatForKey:(NSString *)key;
- (MCTFloat)floatForKey:(NSString *)key withDefaultValue:(MCTFloat)defaultValue;

@end


@interface NSMutableDictionary (MCTTools2)

- (void)setLong:(MCTlong)l forKey:(NSString *)key;

- (void)setFloat:(MCTFloat)f forKey:(NSString *)key;

- (void)setBool:(BOOL)b forKey:(NSString *)key;

- (void)setString:(NSString *)s forKey:(NSString *)key;

- (void)setArray:(NSArray *)a forKey:(NSString *)key;

- (void)setDict:(NSDictionary *)d forKey:(NSString *)key;

@end