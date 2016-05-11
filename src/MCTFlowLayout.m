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

#import "MCTFlowLayout.h"

@implementation MCTFlowLayout


- (CGSize)layoutSubviews:(NSArray*)subviews forView:(UIView*)view
{
    T_UI();
    if (self.leftAlignment) {
        return [super layoutSubviews:subviews forView:view];
    } else {
        CGFloat maxWidth = view.frame.size.width - self.padding * 2;
        CGFloat x = maxWidth, y = self.padding;
        CGFloat minX = maxWidth, rowHeight = 0.0f;
        for (UIView *subview in subviews) {
            if (x < maxWidth && x - subview.frame.size.width < self.padding) {
                x = maxWidth;
                y += rowHeight + _spacing;
                rowHeight = 0;
            }
            subview.frame = CGRectMake(x - subview.frame.size.width, y, subview.frame.size.width, subview.frame.size.height);
            x -= (subview.frame.size.width + _spacing);
            minX = MIN(minX, x);
            rowHeight = MAX(subview.frame.size.height, rowHeight);
        }

        return CGSizeMake(maxWidth - minX + self.padding, y + rowHeight + self.padding);
    }
}

@end