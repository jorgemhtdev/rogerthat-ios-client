/*
 * Copyright 2016 Mobicage NV
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @@license_version:1.1@@
 */

#import "MCTStepRangeSlider.h"

@interface RangeSlider (RangeSlider)
- (float)xForValue:(float)value;
- (float)valueForX:(float)x;
- (void)updateTrackHighlight;
@end


@implementation MCTStepRangeSlider


- (id)initWithFrame:(CGRect)frame
           minValue:(float)minValue
           maxValue:(float)maxValue
          stepValue:(float)step
           minRange:(float)minRange
   selectedMinValue:(float)selectedMinValue
   selectedMaxValue:(float)selectedMaxValue
{
    T_UI();
    if (self = [super initWithFrame:frame
                           minValue:minValue
                           maxValue:maxValue
                           minRange:minRange
                   selectedMinValue:selectedMinValue
                   selectedMaxValue:selectedMaxValue]) {

        self.step = step;
    }
    return self;
}

- (float)valueForX:(float)x
{
    T_UI();
    float v = self.step * round([super valueForX:x] / self.step);
    return (v == 0) ? +0 : v;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    T_UI();
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.1];

    _minThumb.center = CGPointMake([self xForValue:self.selectedMinimumValue], _minThumb.center.y);
    _maxThumb.center = CGPointMake([self xForValue:self.selectedMaximumValue], _maxThumb.center.y);

    [self updateTrackHighlight];
    [self setNeedsDisplay];

    [UIView commitAnimations];

    [self sendActionsForControlEvents:UIControlEventValueChanged];

    [super endTrackingWithTouch:touch withEvent:event];
}

@end