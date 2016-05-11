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
#import "MCTSingleSliderView.h"
#import "MCTUtils.h"
#import "MCTComponentFramework.h"

#define MARGIN 10
#define MCT_LABEL_HEIGHT 21
#define MCT_SLIDER_HEIGHT 23


@interface MCTSingleSliderView ()

- (CGFloat)roundedSelectedValue;
- (void)onValueChanged:(id)sender;

@end


@implementation MCTSingleSliderView

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

        NSString *valueFormat = @"%%1$.%df";

        self.unit = [widgetDict stringForKey:@"unit"];
        if ([MCTUtils isEmptyOrWhitespaceString:self.unit])
            self.unit = MCT_UNIT_VALUE;

        self.unit = [self.unit stringByReplacingOccurrencesOfString:MCT_UNIT_VALUE
                                                         withString:[NSString localizedStringWithFormat:valueFormat, self.precision]];

        self.slider = [[UISlider alloc] init];
        self.slider.minimumValue = self.min;
        self.slider.maximumValue = self.max;
        [self.slider setValue:[widgetDict floatForKey:@"value"] animated:NO];
        [self.slider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.slider addTarget:self action:@selector(onTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.slider];
        [self.slider layoutIfNeeded];

        self.label = [[UILabel alloc] init];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = (colorScheme == MCTColorSchemeLight) ? [UIColor blackColor] : [UIColor whiteColor];
        [self addSubview:self.label];

        [self onValueChanged:nil]; // set text in label
    }

    return self;
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    CGRect lblFrame = CGRectMake(0, 0, self.width, MCT_LABEL_HEIGHT);
    self.label.frame = lblFrame;
    CGFloat sX = 32;
    CGRect sFrame = CGRectMake(sX, CGRectGetMaxY(lblFrame), self.width - 2 * sX, MCT_SLIDER_HEIGHT);
    self.slider.frame = sFrame;
}

- (CGFloat)roundedSelectedValue
{
    T_UI();
    CGFloat v = round(self.slider.value / self.step) * self.step;
    if (v == 0)
        v = +0;
    return MAX(self.slider.minimumValue, MIN(self.slider.maximumValue, v)); // min <= v <= max
}

- (void)onValueChanged:(id)sender
{
    T_UI();
    self.label.text = [NSString stringWithFormat:self.unit, [self roundedSelectedValue], self.precision];
}

- (void)onTouchUp:(id)sender
{
    T_UI();
    [self.slider setValue:[self roundedSelectedValue] animated:YES];
}

#pragma mark -
#pragma mark MCTWidget

- (CGFloat)height
{
    T_UI();
    return CGRectGetMaxY(self.slider.frame) + MARGIN;
}

- (MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *)result
{
    T_UI();
    MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *result =
        [MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO transferObject];
    result.value = [self roundedSelectedValue];
    return result;
}

- (NSDictionary *)widget
{
    T_UI();
    [self.widgetDict setValue:[NSNumber numberWithFloat:self.result.value] forKey:@"value"];
    return self.widgetDict;
}


#pragma mark -

+ (NSString *)valueStringForWidget:(NSDictionary *)widgetDict
{
    T_UI();
    NSString *valueFormat = @"%1$.*02$f";

    NSString *unit = [widgetDict stringForKey:@"unit"];
    if ([MCTUtils isEmptyOrWhitespaceString:unit])
        unit = MCT_UNIT_VALUE;

    unit = [unit stringByReplacingOccurrencesOfString:MCT_UNIT_VALUE withString:valueFormat];

    MCTlong precision = [widgetDict longForKey:@"precision"];
    float value = [widgetDict floatForKey:@"value"];

    return [NSString stringWithFormat:unit, value, precision];
}

@end