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

#import "TTTableHeaderView.h"

// UI
#import "UIViewAdditions.h"

// Style
#import "TTGlobalStyle.h"
#import "TTDefaultStyleSheet.h"

// Core
#import "TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableHeaderView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTitle:(NSString*)title {
	self = [super init];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    self.style = TTSTYLE(tableHeader);

    _label = [[UILabel alloc] init];
    _label.text = title;
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = TTSTYLEVAR(tableHeaderTextColor)
                       ? TTSTYLEVAR(tableHeaderTextColor)
                       : TTSTYLEVAR(linkTextColor);
    _label.shadowColor = TTSTYLEVAR(tableHeaderShadowColor)
                         ? TTSTYLEVAR(tableHeaderShadowColor)
                         : [UIColor clearColor];
    _label.shadowOffset = TTSTYLEVAR(tableHeaderShadowOffset);
    _label.font = TTSTYLEVAR(tableHeaderPlainFont);
    [self addSubview:_label];
  }

  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  _label.size = [_label sizeThatFits:CGSizeMake(self.bounds.size.width - 12,
                                                self.bounds.size.height)];
  _label.origin = CGPointMake(12, floorf((self.bounds.size.height - _label.size.height)/2.f));
}


@end
