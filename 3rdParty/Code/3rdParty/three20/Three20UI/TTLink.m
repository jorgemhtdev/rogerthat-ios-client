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

#import "TTLink.h"

// UI
#import "TTNavigator.h"
#import "TTView.h"

// UINavigator
#import "TTURLAction.h"

// Style
#import "TTGlobalStyle.h"
#import "TTStyleSheet.h"
#import "TTShape.h"

// Core
#import "TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTLink

@synthesize URLAction = _URLAction;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
  if (self) {
    self.userInteractionEnabled = NO;
    [self addTarget: self
             action: @selector(linkTouched) forControlEvents:UIControlEventTouchUpInside];
  }

  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)linkTouched {
  [[TTBaseNavigator navigatorForView:self] openURLAction:_URLAction];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIControl


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  if (highlighted) {
    if (!_screenView) {
      _screenView = [[TTView alloc] initWithFrame:self.bounds];
      _screenView.style = TTSTYLE(linkHighlighted);
      _screenView.backgroundColor = [UIColor clearColor];
      _screenView.userInteractionEnabled = NO;
      [self addSubview:_screenView];
    }

    _screenView.frame = self.bounds;
    _screenView.hidden = NO;

  } else {
    _screenView.hidden = YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  if ([self pointInside:[touch locationInView:self] withEvent:event]) {
    return YES;

  } else {
    self.highlighted = NO;
    return NO;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setURLAction:(TTURLAction*)URLAction {
  _URLAction = URLAction;

  self.userInteractionEnabled = !!URLAction;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)URL {
  return _URLAction.urlPath;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setURL:(id)URL {
  self.URLAction = [[TTURLAction actionWithURLPath:URL] applyAnimated:YES];
}


@end
