//
//  RangeSlider.h
//  RangeSlider
//
//  Created by Mal Curtis on 5/08/11.

#import <UIKit/UIKit.h>

@interface RangeSlider : UIControl {
    float minimumValue;
    float maximumValue;
    float minimumRange;
    float selectedMinimumValue;
    float selectedMaximumValue;

    float _padding;

    CGFloat _beginTouchX;
    BOOL _maxThumbOn;
    BOOL _minThumbOn;

    UIImageView * _minThumb;
    UIImageView * _maxThumb;
    UIImageView * _track;
    UIImageView * _trackBackground;
}

@property(nonatomic) float minimumValue;
@property(nonatomic) float maximumValue;
@property(nonatomic) float minimumRange;
@property(nonatomic) float selectedMinimumValue;
@property(nonatomic) float selectedMaximumValue;

- (id)initWithFrame:(CGRect)frame
           minValue:(float)minValue
           maxValue:(float)maxValue
           minRange:(float)minRange
   selectedMinValue:(float)selectedMinValue
   selectedMaxValue:(float)selectedMaxValue;

@end
