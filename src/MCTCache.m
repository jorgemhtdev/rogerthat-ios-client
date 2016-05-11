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

#import "MCTCache.h"

@interface MCTCache ()

@property (nonatomic, strong) NSMutableDictionary *dict;
@property (nonatomic) NSTimeInterval timeout;

@end


@implementation MCTCache


- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self.dict];
}

- (id)initWithTimeout:(NSTimeInterval)timeout
{
    T_DONTCARE();
    if (self = [super init]) {
        self.timeout = timeout;
        self.dict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)objectForKey:(id)aKey
{
    T_DONTCARE();
    @synchronized(self.dict) {
        return [self.dict objectForKey:aKey];
    }
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
    T_DONTCARE();
    HERE();
    @synchronized(self.dict) {
        [self.dict setObject:anObject forKey:aKey];
        [NSObject cancelPreviousPerformRequestsWithTarget:self.dict
                                                 selector:@selector(removeObject:)
                                                   object:aKey];
        [self.dict performSelector:@selector(removeObjectForKey:)
                        withObject:aKey
                        afterDelay:self.timeout];
    }
}

- (void)removeObjectForKey:(id)aKey
{
    T_DONTCARE();
    HERE();
    @synchronized(self.dict) {
        [self.dict removeObjectForKey:aKey];
        [NSObject cancelPreviousPerformRequestsWithTarget:self.dict
                                                 selector:@selector(removeObject:)
                                                   object:aKey];
    }
}

- (void)removeAllObjects
{
    T_DONTCARE();
    HERE();
    @synchronized(self.dict) {
        [self.dict removeAllObjects];
        [NSObject cancelPreviousPerformRequestsWithTarget:self.dict];
    }
}

- (NSString *)description
{
    return [self.dict description];
}

@end