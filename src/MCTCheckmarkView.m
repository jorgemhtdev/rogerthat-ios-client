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

#import "MCTCheckmarkView.h"

@implementation MCTCheckmarkView


+ (MCTCheckmarkView *)viewWithColor:(UIColor *)rgbColor
{
    MCTCheckmarkView *view = [[MCTCheckmarkView alloc] init];
    view.color = rgbColor;
    return view;
}


- (void)commonInit
{
    self.frame = CGRectMake(0, 0, 20, 20);
    self.backgroundColor = [UIColor clearColor];
}

- (id)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // (x,y) is the bottom of the checkmark
    CGFloat x = CGRectGetMaxX(self.bounds) - 7;
    CGFloat y = CGRectGetMidY(self.bounds) + 3;
    CGContextRef ctxt = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctxt, x-3, y-4);
    CGContextAddLineToPoint(ctxt, x, y);
    CGContextAddLineToPoint(ctxt, x+6, y-10);
    CGContextSetLineCap(ctxt, kCGLineCapSquare);
    CGContextSetLineJoin(ctxt, kCGLineJoinMiter);
    CGContextSetLineWidth(ctxt, 2);

    const CGFloat *c = CGColorGetComponents([self.color CGColor]);

    int32_t model = CGColorSpaceGetModel(CGColorGetColorSpace([self.color CGColor]));
    switch (model) {
        case kCGColorSpaceModelMonochrome: {
            CGContextSetRGBStrokeColor(ctxt, c[0], c[0], c[0], c[1]);
            break;
        }
        case kCGColorSpaceModelRGB: {
            CGContextSetRGBStrokeColor(ctxt, c[0], c[1], c[2], c[3]);
            break;
        }
        case kCGColorSpaceModelCMYK: {
            CGContextSetCMYKStrokeColor(ctxt, c[0], c[1], c[2], c[3], c[4]);
            break;
        }
        default:
            LOG(@"%@ not supported, using white");
            CGContextSetRGBStrokeColor(ctxt, 0, 0, 0, 1);
            break;
    }

    CGContextStrokePath(ctxt);
}

@end