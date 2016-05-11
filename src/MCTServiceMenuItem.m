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

#import "MCTServiceMenuItem.h"

@implementation MCTServiceMenuItem



+ (MCTServiceMenuItem *)menuItemWithLabel:(NSString *)label x:(int)x y:(int)y z:(int)z
{
    T_UI();
    MCTServiceMenuItem *item = [[MCTServiceMenuItem alloc] init];
    item.label = label;
    [item setCoordsWithX:x y:y z:z];
    return item;
}

@end


#pragma mark -

@implementation MCT_com_mobicage_to_friends_ServiceMenuItemTO (MCTServiceMenuItemAdditions)

- (void)setCoordsWithX:(int)x y:(int)y z:(int)z
{
    T_UI();
    self.coords = [NSArray arrayWithObjects:[NSNumber numberWithInt:x], [NSNumber numberWithInt:y],
                   [NSNumber numberWithInt:z], nil];
}

- (int)x
{
    return [[self.coords objectAtIndex:0] intValue];
}

- (int)y
{
    return [[self.coords objectAtIndex:1] intValue];
}

- (int)z
{
    return [[self.coords objectAtIndex:2] intValue];
}

@end