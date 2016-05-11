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
#import "MCTMessageDetailView.h"
#import "MCTTextBlockView.h"
#import "MCTUIUtils.h"
#import "MCTComponentFramework.h"

@interface MCTTextBlockView ()

- (void)textDidBeginEditing:(NSNotification *)notif;
- (void)textDidChange:(NSNotification *)notif;
- (void)textDidEndEditing:(NSNotification *)notif;

@end


@implementation MCTTextBlockView


- (id)initWithDict:(NSDictionary *)widgetDict
          andWidth:(CGFloat)width
    andColorScheme:(MCTColorScheme)colorScheme
  inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc
{
    T_UI();
    if (self = [super init]) {
        self.width = width;
        self.widgetDict = widgetDict;
        self.maxChars = [[widgetDict objectForKey:@"max_chars"] longLongValue];

        self.dummyField = [[UITextField alloc] init];
        self.dummyField.borderStyle = UITextBorderStyleRoundedRect;
        self.dummyField.userInteractionEnabled = NO;
        [self addSubview:self.dummyField];

        NSString *placeHolder = [widgetDict objectForKey:@"place_holder"];
        if (placeHolder && placeHolder != MCTNull) {
            self.placeHolderLbl = [[UILabel alloc] init];
            self.placeHolderLbl.backgroundColor = [UIColor clearColor];
            self.placeHolderLbl.text = placeHolder;
            self.placeHolderLbl.textColor = [UIColor lightGrayColor];
            self.placeHolderLbl.numberOfLines = 3;
            self.placeHolderLbl.lineBreakMode = NSLineBreakByTruncatingTail;
            [self addSubview:self.placeHolderLbl];
        }

        self.textView = [[PSPDFTextView alloc] init];
        self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.delegate = self;
        self.textView.font = [UIFont systemFontOfSize:17];
        NSString *val = [widgetDict containsKey:@"value"] ? [widgetDict stringForKey:@"value"] : nil;
        if (val && val != MCTNull)
            self.textView.text = val;
        [self addSubview:self.textView];

        [self textDidChange:nil];


        // Note: removeObserver happens in MCTMessageDetailView
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidBeginEditing:)
                                                     name:UITextViewTextDidBeginEditingNotification
                                                   object:self.textView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChange:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self.textView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidEndEditing:)
                                                     name:UITextViewTextDidEndEditingNotification
                                                   object:self.textView];
    }
    return self;
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    CGFloat tvH = 75;
    self.textView.frame = self.dummyField.frame = CGRectMake(0, 0, self.width, tvH);

    if (self.placeHolderLbl && !self.placeHolderLbl.hidden) {
        CGFloat phX = 7, phY = 8;
        CGSize phSize = [MCTUIUtils sizeForLabel:self.placeHolderLbl withWidth:self.width - 2 * phX];
        self.placeHolderLbl.frame = CGRectMake(phX, phY, phSize.width, MIN(phSize.height, tvH - 2 * phY));
    }
}

- (void)onBackgroundTapped:(id)sender
{
    T_UI();
    [self.textView resignFirstResponder];
}

- (void)onButtonTapped:(id)sender
{
    T_UI();
    [self.textView resignFirstResponder];
}

- (UINavigationItem *)navigationItem
{
    T_UI();
    UIView *v = [self superview];
    while (v) {
        if ([v isKindOfClass:[MCTMessageDetailView class]]) {
            return ((MCTMessageDetailView *)v).viewController.navigationController.navigationBar.topItem;
        }
        v = [v superview];
    }
    return nil;
}

- (void)textDidBeginEditing:(NSNotification *)notif
{
    T_UI();
    UINavigationItem *navItem = [self navigationItem];
    if (navItem) {
        self.rightBarButtonItem = navItem.rightBarButtonItem;

        navItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                       target:self
                                       action:@selector(onBackgroundTapped:)];
    }
}

- (void)textDidChange:(NSNotification *)notif
{
    T_UI();
    self.placeHolderLbl.hidden = (BOOL) [self.textView.text length];
}

- (void)textDidEndEditing:(NSNotification *)notif
{
    T_UI();
    CGFloat current = self.textView.contentOffset.y;
    if (current >= 28) {
        self.textView.contentOffset = CGPointMake(0, MAX(0, current - 28));
    }
    UINavigationItem *navItem = [self navigationItem];
    if (navItem) {
        navItem.rightBarButtonItem = self.rightBarButtonItem;
        MCT_RELEASE(self.rightBarButtonItem);
    }
}

#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    T_UI();
    NSInteger newLength = [txtView.text length] + [text length] - range.length;
    return (self.maxChars - newLength >= 0);
}

#pragma mark -
#pragma mark MCTWidget

- (CGFloat)height
{
    T_UI();
    return CGRectGetMaxY(self.textView.frame) + 10;
}

- (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)result
{
    T_UI();
    MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *result =
        [MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO transferObject];
    result.value = self.textView.text;
    return result;
}

- (NSDictionary *)widget
{
    T_UI();
    [self.widgetDict setValue:self.result.value forKey:@"value"];
    return self.widgetDict;
}


#pragma mark -

+ (NSString *)valueStringForWidget:(NSDictionary *)widgetDict
{
    T_UI();
    return [widgetDict stringForKey:@"value"];
}

@end