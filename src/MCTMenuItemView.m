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

#import "Three20UI+Additions.h"
#import "Three20Style.h"

#import "MCTBrandingMgr.h"
#import "MCTMenuItemView.h"
#import "MCTUIUtils.h"

static const CGFloat kMargin = 2;
static const CGFloat kImageWidth = 50;
static const CGFloat kLabelFontSize = 12;
static const CGFloat kMenuItemWidth = 76;
static const CGFloat kMenuItemHeight = kImageWidth + kMargin + kLabelFontSize + 4;

@implementation MCTMenuItemView

- (id)initWithFrame:(CGRect)frame
           menuItem:(MCTServiceMenuItem *)menuItem
        colorScheme:(MCTColorScheme)colorScheme
        badgeString:(NSString *)badgeString
{
    T_UI();
    return [self initWithFrame:frame
                      menuItem:menuItem
                         image:[UIImage imageWithData:menuItem.icon]
                   colorScheme:colorScheme
                   badgeString:badgeString];
}

- (id)initWithFrame:(CGRect)frame
           menuItem:(MCTServiceMenuItem *)menuItem
              image:(UIImage *)image
        colorScheme:(MCTColorScheme)colorScheme
        badgeString:(NSString *)badgeString
{
    T_UI();

    return [self initWithFrame:frame
                      menuItem:menuItem
                         image:image
                   colorScheme:colorScheme
                   badgeString:badgeString
                    imageFrame:CGRectMake(MAX(0, (kMenuItemWidth - kImageWidth) / 2), 0, kImageWidth, kImageWidth)
                          font:[UIFont systemFontOfSize:kLabelFontSize]];
}

- (id)initWithFrame:(CGRect)frame
           menuItem:(MCTServiceMenuItem *)menuItem
              image:(UIImage *)image
        colorScheme:(MCTColorScheme)colorScheme
        badgeString:(NSString *)badgeString
         imageFrame:(CGRect)imageFrame
               font:(UIFont *)font
{
    T_UI();
    frame.size = CGSizeMake(kMenuItemWidth, kMenuItemHeight);
    if (self = [super initWithFrame:frame]) {
        self.item = menuItem;

        self.imageView = [[UIImageView alloc] initWithImage:image];
        self.imageView.frame = imageFrame;
        [self addSubview:self.imageView];

        self.badgeView = [[TTLabel alloc] init];
        self.badgeView.style = TTSTYLE(largeBadge);
        self.badgeView.backgroundColor = [UIColor clearColor];
        self.badgeView.userInteractionEnabled = NO;
        [self updateBadgeWithString:badgeString];
        [self addSubview:self.badgeView];

        self.label = [[UILabel alloc] init];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.font = font;
        self.label.lineBreakMode = NSLineBreakByTruncatingTail;
        self.label.numberOfLines = 2;
        self.label.shadowOffset = CGSizeMake(1, 1);
        self.label.text = self.item.label;
        self.label.textAlignment = NSTextAlignmentCenter;
        [self setColorScheme:colorScheme];

        CGSize size = [MCTUIUtils sizeForLabel:self.label withWidth:kMenuItemWidth];
        CGFloat h = 4 + MIN(size.height, self.label.numberOfLines * (kLabelFontSize + 3));
        self.label.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame) + kMargin, kMenuItemWidth, h);
        [self addSubview:self.label];

        CGRect f = self.frame;
        f.origin.y = -4;
        f.size.height = CGRectGetMaxY(self.label.frame) - f.origin.y;
        self.highlightOverlay = [[UIView alloc] initWithFrame:f];
        self.highlightOverlay.backgroundColor = [UIColor blackColor];
        [MCTUIUtils addRoundedBorderToView:self.highlightOverlay withBorderColor:[UIColor clearColor] andCornerRadius:8];

        [self addTarget:self action:@selector(onTouchDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchCancel];
    }
    return self;
}

- (void)setColorScheme:(MCTColorScheme)colorScheme
{
    self.label.textColor = colorScheme == MCTColorSchemeDark ? [UIColor whiteColor] : [UIColor blackColor];
    self.label.shadowColor = colorScheme == MCTColorSchemeDark ? [UIColor blackColor] : [UIColor colorWithWhite:1.0 alpha:0.3];
}

- (void)updateBadgeWithString:(NSString *)badgeString
{
    if (badgeString) {
        self.badgeView.hidden = NO;
        self.badgeView.text = badgeString;
        [self.badgeView sizeToFit];
        self.badgeView.frame = CGRectMake(self.width - self.badgeView.width - 1, -5, self.badgeView.width, self.badgeView.height);
    } else {
        self.badgeView.hidden = YES;
    }
}

- (void)onTouchDown
{
    T_UI();
    self.highlightOverlay.alpha = 0.5;
    [self addSubview:self.highlightOverlay];
}

- (void)onTouchUp
{
    T_UI();
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.highlightOverlay.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [self.highlightOverlay removeFromSuperview];
                     }];
}

@end