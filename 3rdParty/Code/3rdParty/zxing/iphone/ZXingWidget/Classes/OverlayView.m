/**
 * Copyright 2009 Jeff Verkoeyen
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "OverlayView.h"

static const CGFloat kPadding = 10;

@interface OverlayView()
@property (nonatomic,assign) UIButton *cancelButton;
@end


@implementation OverlayView

@synthesize delegate, oneDMode;
@synthesize points = _points;
@synthesize cancelButton;
@synthesize cropRect;
@synthesize userTextLine1 = userTextLine1_;
@synthesize userTextLine2 = userTextLine2_;
@synthesize justScan = justScan_;

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id) initWithFrame:(CGRect)theFrame cancelEnabled:(BOOL)isCancelEnabled oneDMode:(BOOL)isOneDModeEnabled {
    if( self = [super initWithFrame:theFrame] ) {
        CGFloat rectSize;
        if (self.frame.size.width > self.frame.size.height) {
            rectSize = self.frame.size.height - kPadding * 2;
        } else {
            rectSize = self.frame.size.width - kPadding * 2;
        }

        if (!oneDMode) {
            if (self.frame.size.width > self.frame.size.height) {
                cropRect = CGRectMake((self.frame.size.width - rectSize) / 2, kPadding, rectSize, rectSize);
            } else {
                cropRect = CGRectMake(kPadding, (self.frame.size.height - rectSize) / 2, rectSize, rectSize);
            }
        } else {
            CGFloat rectSize2 = self.frame.size.height - kPadding * 2;
            cropRect = CGRectMake(kPadding, kPadding, rectSize, rectSize2);
        }

        self.backgroundColor = [UIColor clearColor];
        self.oneDMode = isOneDModeEnabled;
        self.justScan = NO;
        if (isCancelEnabled) {
            UIButton *butt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            self.cancelButton = butt;
            [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
            if (oneDMode) {
                [cancelButton setTransform:CGAffineTransformMakeRotation(M_PI/2)];
                [cancelButton setFrame:CGRectMake(20, 175, 45, 130)];
            }
            else {
                CGSize screenSize = [UIScreen mainScreen].applicationFrame.size;
                [cancelButton setFrame:CGRectMake(95, screenSize.height - 60, screenSize.width - 190, 45)];
            }

            [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:cancelButton];
            [self addSubview:imageView];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)theFrame
{
    if( self = [super initWithFrame:theFrame] ) {
        CGFloat rectSize;
        if (self.frame.size.width > self.frame.size.height) {
            rectSize = self.frame.size.height;
            cropRect = CGRectMake((self.frame.size.width - rectSize) / 2, 0, rectSize, rectSize);
        } else {
            rectSize = self.frame.size.width;
            cropRect = CGRectMake(0, (self.frame.size.height - rectSize) / 2, rectSize, rectSize);
        }
        self.backgroundColor = [UIColor clearColor];
        self.oneDMode = NO;
        self.justScan = YES;
    }
    return self;
}

- (void)cancel:(id)sender {
    // call delegate to cancel this scanner
    if (delegate != nil) {
        [delegate cancelled];
    }
}

- (void)setCancelButtonText:(NSString *)cancelButtonText
{
    [self.cancelButton setTitle:cancelButtonText forState:UIControlStateNormal];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
    [imageView release];
    [_points release];
    self.userTextLine1 = nil;
    self.userTextLine2 = nil;
}


- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context {
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
    CGContextStrokePath(context);
}

- (CGPoint)map:(CGPoint)point {
    CGPoint center;
    center.x = cropRect.size.width/2;
    center.y = cropRect.size.height/2;
    float x = point.x - center.x;
    float y = point.y - center.y;
    int rotation = 90;
    switch(rotation) {
        case 0:
            point.x = x;
            point.y = y;
            break;
        case 90:
            point.x = -y;
            point.y = x;
            break;
        case 180:
            point.x = -x;
            point.y = -y;
            break;
        case 270:
            point.x = y;
            point.y = -x;
            break;
    }
    point.x = point.x + center.x;
    point.y = point.y + center.y;
    return point;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.justScan) {
        return;
    }
    CGContextRef c = UIGraphicsGetCurrentContext();

    if (nil != _points) {
        //		[imageView.image drawAtPoint:cropRect.origin];
    }

    // Set text glow color
    float glowWidth = 5.0;
    float colorValues[] = { 0, 0, 1.0, 1.0 };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef glowColor = CGColorCreate( colorSpace, colorValues );
    CGContextSetShadowWithColor( c, CGSizeMake( 0.0, 0.0 ), glowWidth, glowColor );

    CGFloat white[4] = {1.0f, 1.0f, 1.0f, 1.0f};
    CGContextSetStrokeColor(c, white);
    CGContextSetFillColor(c, white);
    [self drawRect:cropRect inContext:c];

    //	CGContextSetStrokeColor(c, white);
    //	CGContextSetStrokeColor(c, white);
    CGContextSaveGState(c);
    if (oneDMode) {
        char *text = "Place a red line over the bar code to be scanned.";
        CGContextSelectFont(c, "Helvetica", 15, kCGEncodingMacRoman);
        CGContextScaleCTM(c, -1.0, 1.0);
        CGContextRotateCTM(c, M_PI/2);
        CGContextShowTextAtPoint(c, 74.0, 285.0, text, 49);
    }
    else {
        const char *text1;
        if (self.userTextLine1)
            text1 = [self.userTextLine1 UTF8String];
        else
            text1 = "Place a QR code inside the";

        const char *text2;
        if (self.userTextLine2)
            text2 = [self.userTextLine2 UTF8String];
        else
            text2 = "viewfinder rectangle to scan it.";

        CGContextSelectFont(c, "Helvetica", 18, kCGEncodingMacRoman);
        CGContextScaleCTM(c, -1.0, 1.0);
        CGContextRotateCTM(c, M_PI);

        // Measure text1 width
        CGContextSetTextDrawingMode(c, kCGTextInvisible);
        CGContextShowTextAtPoint(c, 0.0, 0.0, text1, strlen(text1));
        CGPoint pt1 = CGContextGetTextPosition(c);

        // Draw text1
        CGContextSetTextDrawingMode(c, kCGTextFill);
        CGContextShowTextAtPoint(c, CGRectGetMidX([UIScreen mainScreen].applicationFrame) - pt1.x/2, -45.0, text1, strlen(text1));

        // Measure text2 width
        CGContextSetTextDrawingMode(c, kCGTextInvisible);
        CGContextShowTextAtPoint(c, 0.0, 0.0, text2, strlen(text2));
        CGPoint pt2 = CGContextGetTextPosition(c);

        // Draw text2
        CGContextSetTextDrawingMode(c, kCGTextFill);
        CGContextShowTextAtPoint(c, CGRectGetMidX([UIScreen mainScreen].applicationFrame) - pt2.x/2, -70.0, text2, strlen(text2));
    }
    CGContextRestoreGState(c);
    int offset = rect.size.width / 2;
    if (oneDMode) {
        CGFloat red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
        CGContextSetStrokeColor(c, red);
        CGContextSetFillColor(c, red);
        CGContextBeginPath(c);
        //		CGContextMoveToPoint(c, rect.origin.x + kPadding, rect.origin.y + offset);
        //		CGContextAddLineToPoint(c, rect.origin.x + rect.size.width - kPadding, rect.origin.y + offset);
        CGContextMoveToPoint(c, rect.origin.x + offset, rect.origin.y + kPadding);
        CGContextAddLineToPoint(c, rect.origin.x + offset, rect.origin.y + rect.size.height - kPadding);
        CGContextStrokePath(c);
    }
    if( nil != _points ) {
        CGFloat blue[4] = {0.0f, 1.0f, 0.0f, 1.0f};
        CGContextSetStrokeColor(c, blue);
        CGContextSetFillColor(c, blue);
        if (oneDMode) {
            CGPoint val1 = [self map:[[_points objectAtIndex:0] CGPointValue]];
            CGPoint val2 = [self map:[[_points objectAtIndex:1] CGPointValue]];
            CGContextMoveToPoint(c, offset, val1.x);
            CGContextAddLineToPoint(c, offset, val2.x);
            CGContextStrokePath(c);
        }
        else {
            CGRect smallSquare = CGRectMake(0, 0, 10, 10);
            for( NSValue* value in _points ) {
                CGPoint point = [self map:[value CGPointValue]];
                smallSquare.origin = CGPointMake(
                                                 cropRect.origin.x + point.x - smallSquare.size.width / 2,
                                                 cropRect.origin.y + point.y - smallSquare.size.height / 2);
                [self drawRect:smallSquare inContext:c];
            }
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 - (void) setImage:(UIImage*)image {
 //if( nil == imageView ) {
 // imageView = [[UIImageView alloc] initWithImage:image];
 // imageView.alpha = 0.5;
 // } else {
 imageView.image = image;
 //}

 //CGRect frame = imageView.frame;
 //frame.origin.x = self.cropRect.origin.x;
 //frame.origin.y = self.cropRect.origin.y;
 //imageView.frame = CGRectMake(0,0, 30, 50);

 //[_points release];
 //_points = nil;
 //self.backgroundColor = [UIColor clearColor];

 //[self setNeedsDisplay];
 }
 */

////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*) image {
    return imageView.image;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setPoints:(NSMutableArray*)pnts {
    [pnts retain];
    [_points release];
    _points = pnts;
    
    if (pnts != nil) {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    }
    [self setNeedsDisplay];
}

- (void) setPoint:(CGPoint)point {
    if (!_points) {
        _points = [[NSMutableArray alloc] init];
    }
    if (_points.count > 3) {
        [_points removeObjectAtIndex:0];
    }
    [_points addObject:[NSValue valueWithCGPoint:point]];
    [self setNeedsDisplay];
}


@end
