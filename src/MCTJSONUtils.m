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

#import "MCTUtils.h"
#import "MCTJSONUtils.h"

#define LONG_ERROR_VALUE -1LL
#define FLOAT_ERROR_VALUE -1.0f
#define BOOL_ERROR_VALUE NO

@implementation NSDictionary (MCTTools1)

// return nil for error (e.g. missing key, wrong format, ...)
// return MCTNull for explicit null value
- (NSArray *)arrayForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if (obj == nil) {
        ERROR(@"Dict does not contain key: %@", key);
        return nil;
    }
    return [self checkedArray:obj withKey:key];
}

- (NSArray *)arrayForKey:(NSString *)key withDefaultValue:(NSArray *)defaultValue
{
    id obj = [self objectForKey:key];
    if (obj == nil) {
        return defaultValue;
    }
    return [self checkedArray:obj withKey:key];
}

- (NSArray *)checkedArray:(id)obj withKey:(NSString *)key
{
    if (obj == MCTNull) {
        ERROR(@"null array value not supported for key: %@", key);
        return nil;
    }
    if (![obj isKindOfClass:MCTArrayClass]) {
        ERROR(@"Expect array value for key: %@", key);
        return nil;
    }
    return obj;
}

// return nil for error (e.g. missing key, wrong format, ...)
// return MCTNull for explicit null value
- (NSDictionary *)dictForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if (obj == nil) {
        ERROR(@"Dict does not contain key %@", key);
        return nil;
    }
    return [self checkedDictionay:obj withKey:key];
}

- (NSDictionary *)dictForKey:(NSString *)key withDefaultValue:(NSDictionary *)defaultValue
{
    id obj = [self objectForKey:key];
    if (obj == nil) {
        return defaultValue;
    }
    return [self checkedDictionay:obj withKey:key];
}

- (NSDictionary *)checkedDictionay:(id)obj withKey:(NSString *)key
{
    if (obj == MCTNull) {
        return obj;
    }
    if (![obj isKindOfClass:MCTDictClass]) {
        ERROR(@"Expect dict value for key: %@", key);
        return nil;
    }
    return obj;

}

// return nil for error (e.g. missing key, wrong format, ...)
// return MCTNull for explicit null value
- (NSString *)stringForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if (obj == nil) {
        ERROR(@"Dict does not contain key %@", key);
        return nil;
    }
    return [self checkedString:obj withKey:key];
}

- (NSString *)stringForKey:(NSString *)key withDefaultValue:(NSString *)defaultValue
{
    id obj = [self objectForKey:key];
    if (obj == nil) {
        return defaultValue;
    }
    return [self checkedString:obj withKey:key];
}

- (NSString *)checkedString:(id)obj withKey:(NSString *)key
{
    if (obj == MCTNull) {
        return obj;
    }
    if (![obj isKindOfClass:MCTStringClass]) {
        ERROR(@"Expect string value for key: %@", key);
        return nil;
    }
    return obj;
}

- (BOOL)containsKey:(NSString *)key
{
    return ([self objectForKey:key] != nil);
}

- (BOOL)containsBoolObjectForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if (obj == nil)
        return NO;
    if (![obj isKindOfClass:MCTBooleanClass])
        return NO;
    return YES;
}

- (BOOL)boolForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if (obj == nil) {
        ERROR(@"Key for bool not in dict: %@", key);
        return BOOL_ERROR_VALUE;
    }
    return [self checkedBool:obj withKey:key];
}

- (BOOL)boolForKey:(NSString *)key withDefaultValue:(BOOL)defaultValue
{
    id obj = [self objectForKey:key];
    if (obj == nil) {
        return defaultValue;
    }
    return [self checkedBool:obj withKey:key];
}

- (BOOL)checkedBool:(id)obj withKey:(NSString *)key
{
    if (![obj isKindOfClass:MCTBooleanClass]) {
        ERROR(@"No bool value for key: %@", key);
        return BOOL_ERROR_VALUE;
    }
    return [obj boolValue];
}

- (BOOL)containsLongObjectForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if (obj == nil)
        return NO;
    // XXX: should check for very large longs; do they pass as NSNumber or NSDecimalNumber?
    if (![obj isKindOfClass:MCTLongClass])
        return NO;
    MCTlong l = [obj longLongValue];
    if (l < MCT_MIN_LONG || l > MCT_MAX_LONG)
        return NO;
    return YES;
}

- (MCTlong)longForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if (obj == nil) {
        ERROR(@"Key for long not in dict: %@", key);
        return LONG_ERROR_VALUE;
    }
    return [self checkedLong:obj withKey:key];
}

- (MCTlong)longForKey:(NSString *)key withDefaultValue:(MCTlong)defaultValue
{
    id obj = [self objectForKey:key];
    if (obj == nil) {
        return defaultValue;
    }
    return [self checkedLong:obj withKey:key];
}

- (MCTlong)checkedLong:(id)obj withKey:(NSString *)key
{
    // XXX: should check for very large longs; do they pass as NSNumber or NSDecimalNumber?
    if (![obj isKindOfClass:MCTLongClass]) {
        ERROR(@"No long value for key: %@", key);
        return LONG_ERROR_VALUE;
    }
    MCTlong l = [obj longLongValue];
    if (l < MCT_MIN_LONG || l > MCT_MAX_LONG) {
        ERROR(@"Value for key [%@] is not within acceptable integer boundaries", key);
        return LONG_ERROR_VALUE;
    }
    return l;
}

- (BOOL)containsFloatObjectForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if (obj == nil)
        return NO;
    if (!([obj isKindOfClass:MCTFloatClass] || [obj isKindOfClass:MCTLongClass]))
        return NO;
    return YES;
}

- (MCTFloat)floatForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if (obj == nil) {
        ERROR(@"Key for float not in dict: %@", key);
        return FLOAT_ERROR_VALUE;
    }
    return [self checkedFloat:obj withKey:key];
}

- (MCTFloat)floatForKey:(NSString *)key withDefaultValue:(MCTFloat)defaultValue
{
    id obj = [self objectForKey:key];
    if (obj == nil) {
        return defaultValue;
    }
    return [self checkedFloat:obj withKey:key];
}

- (MCTFloat)checkedFloat:(id)obj withKey:(NSString *)key
{
    if (!([obj isKindOfClass:MCTFloatClass] || [obj isKindOfClass:MCTLongClass])) {
        ERROR(@"No float value for key: %@", key);
        return FLOAT_ERROR_VALUE;
    }
    MCTFloat f = [obj floatValue];
    return f;
}

@end



@implementation NSMutableDictionary (MCTTools2)

- (void)setLong:(MCTlong)l forKey:(NSString *)key
{
    if (l < MCT_MIN_LONG || l > MCT_MAX_LONG)
        ERROR(@"Setting long value outside acceptable integer boundaries for key %@", key);
    [self setObject:[NSNumber numberWithLongLong:l] forKey:key];
}

- (void)setFloat:(MCTFloat)f forKey:(NSString *)key
{
    [self setObject:[NSNumber numberWithFloat:f] forKey:key];
}

- (void)setBool:(BOOL)b forKey:(NSString *)key
{
    [self setObject:[NSNumber numberWithBool:b] forKey:key];
}

- (void)setString:(NSString *)s forKey:(NSString *)key
{
    if (s == nil)
        [self setObject:MCTNull forKey:key];
    else if ([s isKindOfClass:MCTStringClass])
        [self setObject:s forKey:key];
    else
        ERROR(@"Setting string with invalid type for key [%@]: %@", key, s);
}

- (void)setArray:(NSArray *)a forKey:(NSString *)key
{
    if (a == nil)
        ERROR(@"nil array not supported for key [%@]", key);
    else if ([a isKindOfClass:MCTArrayClass])
        [self setObject:a forKey:key];
    else
        ERROR(@"Setting array with invalid type for key [%@]: %@", key, a);
}

- (void)setDict:(NSDictionary *)d forKey:(NSString *)key
{
    if (d == nil)
        [self setObject:MCTNull forKey:key];
    else if ([d isKindOfClass:MCTDictClass])
        [self setObject:d forKey:key];
    else
    {
        LOG(@"type of d is %@", [d class]);
        LOG(@"type of MCTDictClass is %@", MCTDictClass);
        LOG(@"d is dict: %d / d is MCTDictClass: %d", [d isKindOfClass:[NSDictionary class]], [d isKindOfClass:MCTDictClass]);
        ERROR(@"Setting dict with invalid type for key [%@]: %@", key, d);
    }
}

@end