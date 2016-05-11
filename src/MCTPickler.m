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


#import "MCTPickler.h"


#define PICKLE_VERSION_KEY @"__pickleVersion"
#define PICKLE_VERSION 1

#define PICKLE_CLASS_NAME_KEY @"__pickleClassName"

#define PICKLE_CLASS_VERSION_KEY @"__pickleClassVersion"

@implementation MCTPickler

+ (NSObject<MCTPickleable> *)objectFromPickle:(NSData *)pickle
{
    if (!pickle) {
        ERROR(@"pickle is nil");
        return nil;
    }

    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:pickle];

    int pickleVersion = [unarchiver decodeIntForKey:PICKLE_VERSION_KEY];
    if (pickleVersion != PICKLE_VERSION) {
        ERROR(@"Wrong pickle version. Expected %d got %d", PICKLE_VERSION, pickleVersion);
        return nil;
    }

    NSString *className = [unarchiver decodeObjectForKey:PICKLE_CLASS_NAME_KEY];
    if (className == nil) {
        ERROR(@"Wrong pickle. Class name not found");
        return nil;
    }

    int classVersion = [unarchiver decodeIntForKey:PICKLE_CLASS_VERSION_KEY];
    id obj = [[NSClassFromString(className) alloc] initWithCoder:unarchiver forClassVersion:classVersion];
    if (obj == nil) {
        ERROR(@"Cannot decode pickle for class %@ version %d", className, classVersion);
        return nil;
    }

    return obj;
}

+ (NSData *)pickleFromObject:(NSObject<MCTPickleable> *)obj
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];

    [archiver encodeInt:PICKLE_VERSION forKey:PICKLE_VERSION_KEY];
    [archiver encodeObject:NSStringFromClass([obj class])  forKey:PICKLE_CLASS_NAME_KEY];
    [archiver encodeInt:[obj classVersion] forKey:PICKLE_CLASS_VERSION_KEY];

    [obj encodeWithCoder:archiver];

    [archiver finishEncoding];

    return data;
}

@end