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

#import "TTStyledTextTableCell.h"

// UI
#import "TTStyledTextLabel.h"
#import "UIViewAdditions.h"
#import "UITableViewAdditions.h"

// Style
#import "TTGlobalStyle.h"
#import "TTDefaultStyleSheet.h"
#import "TTStyledText.h"

// Core
#import "TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTStyledTextTableCell

@synthesize label = _label;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
  if (self) {
    _label = [[TTStyledTextLabel alloc] init];
    _label.contentMode = UIViewContentModeLeft;
    [self.contentView addSubview:_label];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }

  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  TTStyledText* text = object;
  if (!text.font) {
    text.font = TTSTYLEVAR(font);
  }
  text.width = tableView.width - [tableView tableCellMargin]*2;
  return text.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];
  _label.frame = self.contentView.bounds;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToSuperview {
  [super didMoveToSuperview];
  if (self.superview) {
    _label.backgroundColor = self.backgroundColor;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)object {
  return _label.text;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
  if (self.object != object) {
    _label.text = object;
  }
}


@end
