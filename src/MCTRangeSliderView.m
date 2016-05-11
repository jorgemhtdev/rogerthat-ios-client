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

#import "MCTJSONUtils.h"
#import "MCTMessageEnums.h"
#import "MCTRangeSliderView.h"
#import "MCTStepRangeSlider.h"
#import "MCTUtils.h"
#import "MCTComponentFramework.h"

#define MARGIN 12
#define MCT_LABEL_HEIGHT 21
#define MCT_SLIDER_HEIGHT 44


@interface MCTRangeSliderView ()

- (CGFloat)lowValue;
- (CGFloat)highValue;
- (void)onValueChanged:(id)sender;

@end


@implementation MCTRangeSliderView

- (id)initWithDict:(NSDictionary *)widgetDict
          andWidth:(CGFloat)width
    andColorScheme:(MCTColorScheme)colorScheme
  inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc
{
    T_UI();
    if (self = [super init]) {
        self.width = width;
        self.widgetDict = widgetDict;
        self.min = [widgetDict floatForKey:@"min"];
        self.max = [widgetDict floatForKey:@"max"];
        self.step = [widgetDict floatForKey:@"step"];
        self.precision = [widgetDict longForKey:@"precision"];

        NSString *valueFormat = @"%%%d$.%df";

        self.unit = [widgetDict stringForKey:@"unit"];
        if ([MCTUtils isEmptyOrWhitespaceString:self.unit])
            self.unit = @"<low_value/> - <high_value/>";

        self.unit = [self.unit stringByReplacingOccurrencesOfString:MCT_UNIT_LOW_VALUE
                                                         withString:[NSString stringWithFormat:valueFormat, 1, self.precision]];
        self.unit = [self.unit stringByReplacingOccurrencesOfString:MCT_UNIT_HIGH_VALUE
                                                         withString:[NSString stringWithFormat:valueFormat, 2, self.precision]];

        // RangeSlider needs its frame upfront

        CGRect lblFrame = CGRectMake(0, 0, self.width, MCT_LABEL_HEIGHT);
        CGFloat sX = 32;
        CGRect sFrame = CGRectMake(sX, CGRectGetMaxY(lblFrame), self.width - 2 * sX, MCT_SLIDER_HEIGHT);

        self.slider = [[MCTStepRangeSlider alloc] initWithFrame:sFrame
                                                        minValue:self.min
                                                        maxValue:self.max
                                                       stepValue:self.step
                                                        minRange:0
                                                selectedMinValue:[widgetDict floatForKey:@"low_value"]
                                                selectedMaxValue:[widgetDict floatForKey:@"high_value"]];
        [self.slider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.slider addTarget:self action:@selector(onTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.slider];

        self.label = [[UILabel alloc] init];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.frame = lblFrame;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = (colorScheme == MCTColorSchemeLight) ? [UIColor blackColor] : [UIColor whiteColor];
        [self addSubview:self.label];

        [self onValueChanged:nil]; // set text in label
    }

    return self;
}

- (CGFloat)lowValue
{
    T_UI();
    CGFloat v = self.slider.selectedMinimumValue;
    return MAX(self.slider.minimumValue, MIN(self.slider.maximumValue, v)); // min <= v <= max
}

- (CGFloat)highValue
{
    T_UI();
    CGFloat v = self.slider.selectedMaximumValue;
    return MAX(self.slider.minimumValue, MIN(self.slider.maximumValue, v)); // min <= v <= max
}

- (void)onValueChanged:(id)sender
{
    T_UI();
    self.label.text = [NSString localizedStringWithFormat:self.unit, [self lowValue], [self highValue]];
}

- (void)onTouchUp:(id)sender
{
    T_UI();
    [self.slider setSelectedMaximumValue:[self highValue]];
    [self.slider setSelectedMinimumValue:[self lowValue]];
    [self.slider setNeedsLayout];
}

#pragma mark -
#pragma mark MCTWidget

- (CGFloat)height
{
    T_UI();
    return CGRectGetMaxY(self.slider.frame) + MARGIN;
}

- (MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *)result
{
    T_UI();
    MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *result =
        [MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO transferObject];
    result.values = @[[NSNumber numberWithFloat:[self lowValue]],
                      [NSNumber numberWithFloat:[self highValue]]];
    return result;
}

- (NSDictionary *)widget
{
    T_UI();
    NSArray *val = [self result].values;
    [self.widgetDict setValue:[val objectAtIndex:0] forKey:@"low_value"];
    [self.widgetDict setValue:[val objectAtIndex:1] forKey:@"high_value"];
    return self.widgetDict;
}

#pragma mark -

+ (NSString *)valueStringForWidget:(NSDictionary *)widgetDict
{
    T_UI();
    NSString *valueFormat = @"%%%d$.*03$f";

    NSString *unit = [widgetDict stringForKey:@"unit"];
    if ([MCTUtils isEmptyOrWhitespaceString:unit]) {
        unit = [NSString stringWithFormat:@"%@ - %@", [NSString stringWithFormat:valueFormat, 1], [NSString stringWithFormat:valueFormat, 2]];
    } else {
        unit = [unit stringByReplacingOccurrencesOfString:MCT_UNIT_LOW_VALUE
                                               withString:[NSString stringWithFormat:valueFormat, 1]];
        unit = [unit stringByReplacingOccurrencesOfString:MCT_UNIT_HIGH_VALUE
                                               withString:[NSString stringWithFormat:valueFormat, 2]];
    }

    MCTlong precision = [widgetDict longForKey:@"precision"];
    float lowValue = [widgetDict floatForKey:@"low_value"];
    float highValue = [widgetDict floatForKey:@"high_value"];

    return [NSString stringWithFormat:unit, lowValue, highValue, precision];
}

@end