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

#import "Three20UI+Additions.h"

@interface MCTMenuItemView : UIControl

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) UIView *highlightOverlay;
@property (nonatomic, strong) MCTServiceMenuItem *item;
@property (nonatomic, strong) TTLabel *badgeView;

- (id)initWithFrame:(CGRect)frame menuItem:(MCTServiceMenuItem *)menuItem colorScheme:(MCTColorScheme)colorScheme badgeString:(NSString *)badgeString;
- (id)initWithFrame:(CGRect)frame
           menuItem:(MCTServiceMenuItem *)menuItem
              image:(UIImage *)image
        colorScheme:(MCTColorScheme)colorScheme
        badgeString:(NSString *)badgeString;
- (id)initWithFrame:(CGRect)frame
           menuItem:(MCTServiceMenuItem *)menuItem
              image:(UIImage *)image
        colorScheme:(MCTColorScheme)colorScheme
        badgeString:(NSString *)badgeString
         imageFrame:(CGRect)imageFrame
               font:(UIFont *)font;
- (void)setColorScheme:(MCTColorScheme)colorScheme;
- (void)updateBadgeWithString:(NSString *)badgeString;

@end