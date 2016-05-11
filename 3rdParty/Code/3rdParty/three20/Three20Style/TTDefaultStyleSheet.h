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

// Style
#import "TTStyleSheet.h"

@class TTShape;

@interface TTDefaultStyleSheet : TTStyleSheet

// Common styles
@property (weak, nonatomic, readonly) UIColor*  textColor;
@property (weak, nonatomic, readonly) UIColor*  highlightedTextColor;
@property (weak, nonatomic, readonly) UIColor*  backgroundTextColor;
@property (weak, nonatomic, readonly) UIFont*   font;
@property (weak, nonatomic, readonly) UIColor*  backgroundColor;
@property (weak, nonatomic, readonly) UIColor*  navigationBarTintColor;
@property (weak, nonatomic, readonly) UIColor*  toolbarTintColor;
@property (weak, nonatomic, readonly) UIColor*  searchBarTintColor;

// Tables
@property (weak, nonatomic, readonly) UIColor*  tablePlainBackgroundColor;
@property (weak, nonatomic, readonly) UIColor*  tablePlainCellSeparatorColor;
@property (nonatomic, readonly) UITableViewCellSeparatorStyle tablePlainCellSeparatorStyle;
@property (weak, nonatomic, readonly) UIColor*  tableGroupedBackgroundColor;
@property (weak, nonatomic, readonly) UIColor*  tableGroupedCellSeparatorColor;
@property (nonatomic, readonly) UITableViewCellSeparatorStyle tableGroupedCellSeparatorStyle;
@property (weak, nonatomic, readonly) UIColor*  searchTableBackgroundColor;
@property (weak, nonatomic, readonly) UIColor*  searchTableSeparatorColor;

// Table Headers
@property (weak, nonatomic, readonly) UIColor*  tableHeaderTextColor;
@property (weak, nonatomic, readonly) UIColor*  tableHeaderShadowColor;
@property (nonatomic, readonly) CGSize    tableHeaderShadowOffset;
@property (weak, nonatomic, readonly) UIColor*  tableHeaderTintColor;

// Photo Captions
@property (weak, nonatomic, readonly) UIColor*  photoCaptionTextColor;
@property (weak, nonatomic, readonly) UIColor*  photoCaptionTextShadowColor;
@property (nonatomic, readonly) CGSize    photoCaptionTextShadowOffset;

@property (weak, nonatomic, readonly) UIColor*  timestampTextColor;
@property (weak, nonatomic, readonly) UIColor*  linkTextColor;
@property (weak, nonatomic, readonly) UIColor*  moreLinkTextColor;

@property (weak, nonatomic, readonly) UIColor* screenBackgroundColor;

@property (weak, nonatomic, readonly) UIColor* tableActivityTextColor;
@property (weak, nonatomic, readonly) UIColor* tableErrorTextColor;
@property (weak, nonatomic, readonly) UIColor* tableSubTextColor;
@property (weak, nonatomic, readonly) UIColor* tableTitleTextColor;

@property (weak, nonatomic, readonly) UIColor* tabTintColor;
@property (weak, nonatomic, readonly) UIColor* tabBarTintColor;

@property (weak, nonatomic, readonly) UIColor* messageFieldTextColor;
@property (weak, nonatomic, readonly) UIColor* messageFieldSeparatorColor;

@property (weak, nonatomic, readonly) UIColor* thumbnailBackgroundColor;

@property (weak, nonatomic, readonly) UIColor* postButtonColor;

@property (weak, nonatomic, readonly) UIFont* buttonFont;
@property (weak, nonatomic, readonly) UIFont* tableFont;
@property (weak, nonatomic, readonly) UIFont* tableSmallFont;
@property (weak, nonatomic, readonly) UIFont* tableTitleFont;
@property (weak, nonatomic, readonly) UIFont* tableTimestampFont;
@property (weak, nonatomic, readonly) UIFont* tableButtonFont;
@property (weak, nonatomic, readonly) UIFont* tableSummaryFont;
@property (weak, nonatomic, readonly) UIFont* tableHeaderPlainFont;
@property (weak, nonatomic, readonly) UIFont* tableHeaderGroupedFont;
@property (nonatomic, readonly) CGFloat tableBannerViewHeight;
@property (weak, nonatomic, readonly) UIFont* photoCaptionFont;
@property (weak, nonatomic, readonly) UIFont* messageFont;
@property (weak, nonatomic, readonly) UIFont* errorTitleFont;
@property (weak, nonatomic, readonly) UIFont* errorSubtitleFont;
@property (weak, nonatomic, readonly) UIFont* activityLabelFont;
@property (weak, nonatomic, readonly) UIFont* activityBannerFont;

@property (nonatomic, readonly) UITableViewCellSelectionStyle tableSelectionStyle;

- (TTStyle*)selectionFillStyle:(TTStyle*)next;

- (TTStyle*)toolbarButtonForState:(UIControlState)state shape:(TTShape*)shape
            tintColor:(UIColor*)tintColor font:(UIFont*)font;

- (TTStyle*)pageDotWithColor:(UIColor*)color;

@end
