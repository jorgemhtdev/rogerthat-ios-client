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

#import <UIKit/UIKit.h>

@protocol CancelDelegate;

@interface OverlayView : UIView {
	UIImageView *imageView;
	NSMutableArray *_points;
	UIButton *cancelButton;
	id<CancelDelegate> delegate;
	BOOL oneDMode;
    CGRect cropRect;
    NSString *userTextLine1_;
    NSString *userTextLine2_;
    BOOL justScan_;
}

@property (nonatomic, strong) NSMutableArray*  points;
@property (nonatomic, weak) id<CancelDelegate> delegate;
@property (nonatomic) BOOL oneDMode;
@property (nonatomic) CGRect cropRect;
@property (nonatomic, copy) NSString *userTextLine1;
@property (nonatomic, copy) NSString *userTextLine2;
@property (nonatomic, assign) BOOL justScan;

- (id)initWithFrame:(CGRect)theFrame cancelEnabled:(BOOL)isCancelEnabled oneDMode:(BOOL)isOneDModeEnabled;
- (id)initWithFrame:(CGRect)theFrame;

- (void)setPoint:(CGPoint)point;

- (void)setCancelButtonText:(NSString *)cancelButtonText;

@end

@protocol CancelDelegate
- (void)cancelled;
@end
