//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "TTStyledBoxFrame.h"

// Style
#import "TTStyleContext.h"
#import "TTTextStyle.h"

// Core
#import "TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTStyledBoxFrame

@synthesize parentFrame     = _parentFrame;
@synthesize firstChildFrame = _firstChildFrame;
@synthesize style           = _style;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawSubframes {
  TTStyledFrame* frame = _firstChildFrame;
  while (frame) {
    [frame drawInRect:frame.bounds];
    frame = frame.nextFrame;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyleDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawLayer:(TTStyleContext*)context withStyle:(TTStyle*)style {
  if ([style isKindOfClass:[TTTextStyle class]]) {
    TTTextStyle* textStyle = (TTTextStyle*)style;
    UIFont* font = context.font;
    context.font = textStyle.font;

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

    if (textStyle.color) {
      [textStyle.color setFill];
    }

    if (textStyle.shadowColor) {
      CGSize offset = CGSizeMake(textStyle.shadowOffset.width, -textStyle.shadowOffset.height);
      CGContextSetShadowWithColor(ctx, offset, 0, textStyle.shadowColor.CGColor);
    }

    [self drawSubframes];

    CGContextRestoreGState(ctx);

    context.font = font;

  } else {
    [self drawSubframes];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyledFrame


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)font {
  return _firstChildFrame.font;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawInRect:(CGRect)rect {
  if (_style && !CGRectIsEmpty(_bounds)) {
    TTStyleContext* context = [[TTStyleContext alloc] init];
    context.delegate = self;
    context.frame = rect;
    context.contentFrame = rect;

    [_style draw:context];
    if (context.didDrawContent) {
      return;
    }
  }

  [self drawSubframes];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyledBoxFrame*)hitTest:(CGPoint)point {
  if (CGRectContainsPoint(_bounds, point)) {
    TTStyledBoxFrame* frame = [_firstChildFrame hitTest:point];
    return frame ? frame : self;

  } else if (_nextFrame) {
    return [_nextFrame hitTest:point];

  } else {
    return nil;
  }
}


@end
