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

#import "TTStyleContext.h"

// Style
#import "TTRectangleShape.h"

// Core
#import "TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTStyleContext

@synthesize frame           = _frame;
@synthesize contentFrame    = _contentFrame;
@synthesize shape           = _shape;
@synthesize font            = _font;
@synthesize didDrawContent  = _didDrawContent;
@synthesize delegate        = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
	self = [super init];
  if (self) {
    _frame = CGRectZero;
    _contentFrame = CGRectZero;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTShape*)shape {
  if (!_shape) {
    _shape = [TTRectangleShape shape];
  }

  return _shape;
}


@end
