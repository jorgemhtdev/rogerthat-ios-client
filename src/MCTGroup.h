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

#import "MCTJSONUtils.h"
#import "MCTTransferObjects.h"

@interface MCTGroup : MCTTransferObject <IJSONable>

@property(nonatomic, copy) NSString *guid;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong) NSMutableArray *members;
@property(nonatomic, strong) NSData *avatar;
@property(nonatomic, copy) NSString *avatarHash;

+ (MCTGroup *)groupWithGuid:(NSString *)guid
                       name:(NSString *)name
                    members:(NSMutableArray *)members
                     avatar:(NSData *)avatar
                 avatarHash:(NSString *)avatarHash;
- (UIImage *)avatarImage;

@end