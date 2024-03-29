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

#import "TTSearchBar.h"

// UI
#import "TTSearchTextField.h"
#import "TTButton.h"
#import "UIViewAdditions.h"
#import "UITableViewAdditions.h"
#import "UIFontAdditions.h"

// UICommon
#import "TTGlobalUICommon.h"

// Style
#import "TTGlobalStyle.h"
#import "TTDefaultStyleSheet.h"

// Core
#import "TTCorePreprocessorMacros.h"
#import "TTGlobalCoreLocale.h"

static const CGFloat kMarginX   = 5.0f;
static const CGFloat kMarginY   = 7.0f;
static const CGFloat kPaddingX  = 10.0f;
static const CGFloat kPaddingY  = 10.0f;
static const CGFloat kSpacingX  = 4.0f;

static const CGFloat kButtonSpacing = 12.0f;
static const CGFloat kButtonHeight  = 30.0f;

static const CGFloat kIndexViewMargin = 4.0f;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTSearchBar

@synthesize boxView           = _boxView;
@synthesize tintColor         = _tintColor;
@synthesize textFieldStyle    = _textFieldStyle;
@synthesize showsCancelButton = _showsCancelButton;
@synthesize showsSearchIcon   = _showsSearchIcon;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
  if (self) {
    _boxView = [[TTView alloc] init];
    _boxView.backgroundColor = [UIColor clearColor];
    [self addSubview:_boxView];

    _searchField = [[TTSearchTextField alloc] init];
    _searchField.placeholder = TTLocalizedString(@"Search", @"");
    _searchField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [_searchField addTarget:self action:@selector(textFieldDidBeginEditing)
           forControlEvents:UIControlEventEditingDidBegin];
    [_searchField addTarget:self action:@selector(textFieldDidEndEditing)
           forControlEvents:UIControlEventEditingDidEnd];
    [self addSubview:_searchField];

    self.tintColor = TTSTYLEVAR(searchBarTintColor);
    self.style = TTSTYLE(searchBar);
    self.textFieldStyle = TTSTYLE(searchTextField);
    self.font = TTSTYLEVAR(font);
    self.showsSearchIcon = YES;
    self.showsCancelButton = NO;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)indexViewWidth {
  UITableView* tableView = (UITableView*)[self ancestorOrSelfWithClass:[UITableView class]];
  if (tableView) {
    UIView* indexView = tableView.indexView;
    if (indexView) {
      return indexView.width;
    }
  }
  return 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showIndexView:(BOOL)show {
  UITableView* tableView = (UITableView*)[self ancestorOrSelfWithClass:[UITableView class]];
  if (tableView) {
    UIView* indexView = tableView.indexView;
    if (indexView) {
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:TT_TRANSITION_DURATION];

      if (show) {
        CGRect frame = indexView.frame;
        frame.origin.x = self.width - (indexView.width + kIndexViewMargin);
        indexView.frame = frame;

      } else {
        indexView.frame = CGRectOffset(indexView.frame, indexView.width + kIndexViewMargin, 0);
      }
      indexView.alpha = show ? 1 : 0;

      CGRect searchFrame = _searchField.frame;
      searchFrame.size.width += show ? -self.indexViewWidth : self.indexViewWidth;
      _searchField.frame = searchFrame;

      CGRect boxFrame = _boxView.frame;
      boxFrame.size.width += show ? -self.indexViewWidth : self.indexViewWidth;
      _boxView.frame = boxFrame;

      [UIView commitAnimations];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollToTop {
  UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
  if (scrollView) {
    CGPoint offset = scrollView.contentOffset;
    CGPoint myOffset = [self offsetFromView:scrollView];
    if (offset.y != myOffset.y) {
      [scrollView setContentOffset:CGPointMake(offset.x, myOffset.y) animated:YES];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldDidBeginEditing {
  [self scrollToTop];
  [self showIndexView:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldDidEndEditing {
  [self showIndexView:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIResponder


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)becomeFirstResponder {
  return [_searchField becomeFirstResponder];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)resignFirstResponder {
  return [_searchField resignFirstResponder];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  CGFloat indexViewWidth = [_searchField isEditing] ? 0 : self.indexViewWidth;
  CGFloat leftPadding = _showsSearchIcon ? 0 : kSpacingX;

  CGFloat buttonWidth = 0;
  if (_showsCancelButton) {
    [_cancelButton sizeToFit];
    buttonWidth = _cancelButton.width + kButtonSpacing;
  }

  CGFloat boxHeight = self.font.ttLineHeight + 8;
  _boxView.frame = CGRectMake(kMarginX, floor(self.height/2 - boxHeight/2),
                              self.width - (kMarginX*2 + indexViewWidth + buttonWidth), boxHeight);

  _searchField.frame = CGRectMake(kMarginX+kPaddingX+leftPadding, 0,
    self.width - (kMarginX*2+kPaddingX+leftPadding+buttonWidth+indexViewWidth), self.height);

  if (_showsCancelButton) {
    _cancelButton.frame = CGRectMake(_boxView.right + kButtonSpacing,
                                     floor(self.height/2 - kButtonHeight/2),
                                     _cancelButton.width, kButtonHeight);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
  CGFloat height = self.font.ttLineHeight+kPaddingY*2;
  if (height < TT_ROW_HEIGHT) {
    height = TT_ROW_HEIGHT;
  }
  return CGSizeMake(size.width, height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITextFieldDelegate>)delegate {
  return _searchField.delegate;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
  _searchField.delegate = delegate;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTTableViewDataSource>)dataSource {
  return _searchField.dataSource;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDataSource:(id<TTTableViewDataSource>)dataSource {
  _searchField.dataSource = dataSource;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)editing {
  return _searchField.editing;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)showsDoneButton {
  return _searchField.showsDoneButton;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setShowsDoneButton:(BOOL)showsDoneButton {
  _searchField.showsDoneButton = showsDoneButton;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)showsDarkScreen {
  return _searchField.showsDarkScreen;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setShowsDarkScreen:(BOOL)showsDarkScreen {
  _searchField.showsDarkScreen = showsDarkScreen;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setShowsCancelButton:(BOOL)showsCancelButton {
  if (showsCancelButton != _showsCancelButton) {
    _showsCancelButton = showsCancelButton;

    if (_showsCancelButton) {
      _cancelButton = [TTButton buttonWithStyle:@"blackToolbarButton:"
                                 title:TTLocalizedString(@"Cancel", @"")];
      [_cancelButton addTarget:_searchField action:@selector(resignFirstResponder)
                     forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:_cancelButton];

    } else {
      [_cancelButton removeFromSuperview];
      TT_RELEASE_SAFELY(_cancelButton);
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setShowsSearchIcon:(BOOL)showsSearchIcon {
  if (showsSearchIcon != _showsSearchIcon) {
    _showsSearchIcon = showsSearchIcon;

    if (_showsSearchIcon) {
      UIImageView* iconView = [[UIImageView alloc] initWithImage:
        [UIImage imageNamed:@"Three20.bundle/images/searchIcon.png"]];
      [iconView sizeToFit];
      iconView.contentMode = UIViewContentModeLeft;
      iconView.frame = CGRectInset(iconView.frame, -floor(kMarginX/2), 0);
      _searchField.leftView = iconView;
      _searchField.leftViewMode = UITextFieldViewModeAlways;

    } else {
      _searchField.leftView = nil;
      _searchField.leftViewMode = UITextFieldViewModeNever;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)searchesAutomatically {
  return _searchField.searchesAutomatically;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSearchesAutomatically:(BOOL)searchesAutomatically {
  _searchField.searchesAutomatically = searchesAutomatically;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)text {
  return _searchField.text;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setText:(NSString*)text {
  _searchField.text = text;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)placeholder {
  return _searchField.placeholder;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPlaceholder:(NSString*)placeholder {
  _searchField.placeholder = placeholder;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableView*)tableView {
  return _searchField.tableView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTintColor:(UIColor*)tintColor {
  if (tintColor != _tintColor) {
    _tintColor = tintColor;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextFieldStyle:(TTStyle*)textFieldStyle {
  if (textFieldStyle != _textFieldStyle) {
    _textFieldStyle = textFieldStyle;
    _boxView.style = _textFieldStyle;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)textColor {
  return _searchField.textColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextColor:(UIColor*)textColor {
  _searchField.textColor = textColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)font {
  return _searchField.font;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont*)font {
  _searchField.font = font;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)rowHeight {
  return _searchField.rowHeight;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRowHeight:(CGFloat)rowHeight {
  _searchField.rowHeight = rowHeight;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIReturnKeyType)returnKeyType {
  return _searchField.returnKeyType;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
  _searchField.returnKeyType = returnKeyType;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)search {
  [_searchField search];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showSearchResults:(BOOL)show {
  [_searchField showSearchResults:show];
}


@end

