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

#import "MCTDisclosureIndicatorView.h"


@implementation MCTDisclosureIndicatorView


+ (MCTDisclosureIndicatorView *)viewWithColor:(UIColor *)rgbColor
{
    MCTDisclosureIndicatorView *view = [[MCTDisclosureIndicatorView alloc] init];
    view.color = rgbColor;
    return view;
}


- (void)commonInit
{
    self.frame = CGRectMake(0, 0, 10, 20);
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
    // (x,y) is the tip of the arrow
    const CGFloat RIGHT_MARGIN = 1;
    const CGFloat R = 4;

    CGFloat x = CGRectGetMaxX(self.bounds) - RIGHT_MARGIN;
    CGFloat y = CGRectGetMidY(self.bounds);
    CGContextRef ctxt = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctxt, x-R, y-R);
    CGContextAddLineToPoint(ctxt, x, y);
    CGContextAddLineToPoint(ctxt, x-R, y+R);
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
            LOG(@"%@ not supported, using lightGray");
            CGContextSetRGBStrokeColor(ctxt, .6, .6, .6, 1);
            break;
    }

    CGContextStrokePath(ctxt);
}

@end