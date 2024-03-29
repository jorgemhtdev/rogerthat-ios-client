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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TTSearchlightLabel : UIView {
  NSString*       _text;

  UIFont*         _font;
  UIColor*        _textColor;
  UIColor*        _spotlightColor;
  UITextAlignment _textAlignment;

  NSTimer*        _timer;
  CGFloat         _spotlightPoint;

  CGContextRef    _maskContext;
  void*           _maskData;
}

@property (nonatomic, copy)   NSString*       text;

@property (nonatomic, strong) UIFont*         font;
@property (nonatomic, strong) UIColor*        textColor;
@property (nonatomic, strong) UIColor*        spotlightColor;
@property (nonatomic)         UITextAlignment textAlignment;

- (void)startAnimating;
- (void)stopAnimating;

@end
