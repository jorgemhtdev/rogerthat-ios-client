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
#import "MCTTextLineView.h"
#import "MCTUIUtils.h"
#import "MCTComponentFramework.h"

@implementation MCTTextLineView

- (id)initWithDict:(NSDictionary *)widgetDict
          andWidth:(CGFloat)width
    andColorScheme:(MCTColorScheme)colorScheme
  inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc
{
    T_UI();
    if (self = [super init]) {
        self.width = width;
        self.widgetDict = widgetDict;

        self.maxChars = [widgetDict longForKey:@"max_chars"];

        self.textField = [[UITextField alloc] init];
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.borderStyle = UITextBorderStyleRoundedRect;
        self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField.delegate = self;
        self.textField.returnKeyType = UIReturnKeyDone;
        NSString *placeHolder = [widgetDict stringForKey:@"place_holder"];
        if (placeHolder && placeHolder != MCTNull)
            self.textField.placeholder = placeHolder;
        NSString *val = [widgetDict containsKey:@"value"] ? [widgetDict stringForKey:@"value"] : nil;
        if (val && val != MCTNull)
            self.textField.text = val;

        [self addSubview:self.textField];

        [self addTarget:self action:@selector(onBackgroundTapped:) forControlEvents:UIControlEventTouchUpInside];

        [self setNeedsLayout];
    }

    return self;
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    CGRect tfFrame = CGRectMake(0, 0, self.width, 31);
    self.textField.frame = tfFrame;
}

- (void)onBackgroundTapped:(id)sender
{
    T_UI();
    [self.textField resignFirstResponder];
}

- (void)onButtonTapped:(id)sender
{
    T_UI();
    [self.textField resignFirstResponder];
}

#pragma mark -
#pragma mark MCTWidget

- (CGFloat)height
{
    T_UI();
    return CGRectGetMaxY(self.textField.frame) + 10;
}

- (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)result
{
    T_UI();
    MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *result =
        [MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO transferObject];
    result.value = self.textField.text;
    return result;
}

- (NSDictionary *)widget
{
    T_UI();
    [self.widgetDict setValue:self.result.value forKey:@"value"];
    return self.widgetDict;
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)txtField
{
    T_UI();
    [txtField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)txtField
{
    T_UI();
    [txtField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)txtField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)s
{
    T_UI();
    NSInteger newLength = [txtField.text length] + [s length] - range.length;
    return (newLength > self.maxChars) ? NO : YES;
}

#pragma mark -

+ (NSString *)valueStringForWidget:(NSDictionary *)widgetDict
{
    T_UI();
    return [widgetDict objectForKey:@"value"];
}

@end