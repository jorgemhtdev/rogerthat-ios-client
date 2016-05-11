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

#import "MCTTransferObjects.h"

@interface MCTServiceMenuItem : MCT_com_mobicage_to_friends_ServiceMenuItemTO

@property (nonatomic, strong) NSData *icon;

+ (MCTServiceMenuItem *)menuItemWithLabel:(NSString *)label x:(int)x y:(int)y z:(int)z;

@end


#pragma mark -

@interface MCT_com_mobicage_to_friends_ServiceMenuItemTO (MCTServiceMenuItemAdditions)

- (void)setCoordsWithX:(int)x y:(int)y z:(int)z;

- (int)x;
- (int)y;
- (int)z;

@end