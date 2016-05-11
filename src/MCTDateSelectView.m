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

#import "MCTDateSelectView.h"
#import "MCTMessageDetailView.h"
#import "MCTMessageEnums.h"
#import "MCTReflectiveFillStyle.h"
#import "MCTUtils.h"
#import "MCTUIUtils.h"
#import "MCTComponentFramework.h"

#import "Three20Style+Additions.h"

#define MCT_MIN_HEIGHT 44
#define MCT_LBL_FONT [UIFont systemFontOfSize:17]
#define BUBBLE_POINT_W 10

@interface MCTDateSelectCell : UITableViewCell

@property (nonatomic, strong) TTButton *ttBtn;

@end


@implementation MCTDateSelectCell

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    int M = 5;

    self.ttBtn.top = (self.ttBtn.superview.height - self.ttBtn.height + M) / 2;
    self.ttBtn.right = self.ttBtn.superview.width - M;

    self.textLabel.width = self.ttBtn.left - M - self.textLabel.left;
}

@end


#pragma mark -

@interface MCTDateSelectView ()

- (void)initDatePickerSpeechBubble;
+ (NSTimeZone *)timeZone;
+ (NSDateFormatter *)createDateFormatterWithWidgetDict:(NSDictionary *)widgetDict;
+ (NSDate *)nowWithMinuteInterval:(NSInteger)minuteInterval;
- (void)onDateChanged:(id)sender;
- (void)toggleDatePicker:(BOOL)visible;

@end


@implementation MCTDateSelectView



- (id)initWithDict:(NSDictionary *)widgetDict
          andWidth:(CGFloat)width
    andColorScheme:(MCTColorScheme)colorScheme
  inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc
{
    T_UI();
    if (self = [super init]) {
        self.width = width;
        self.widgetDict = widgetDict;

        NSString *unit = [widgetDict objectForKey:@"unit"];
        if ([MCTUtils isEmptyOrWhitespaceString:unit]) {
            self.format = @"%@";
        } else {
            self.format = [unit stringByReplacingOccurrencesOfString:MCT_UNIT_VALUE withString:@"%@"];
        }

        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.bounces = NO;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [MCTUIUtils addRoundedBorderToView:self.tableView withBorderColor:[UIColor blackColor] andCornerRadius:8];
        [self addSubview:self.tableView];

        [self initDatePickerSpeechBubble];

        self.dateFormatter = [MCTDateSelectView createDateFormatterWithWidgetDict:widgetDict];

        [self onDateChanged:nil];
    }
    return self;
}

- (void)initDatePickerSpeechBubble
{
    T_UI();
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.datePicker.timeZone = [MCTDateSelectView timeZone];

    [self.datePicker addTarget:self action:@selector(onDateChanged:) forControlEvents:UIControlEventValueChanged];
    IF_PRE_IOS7({
        [MCTUIUtils addRoundedBorderToView:self.datePicker];
    });

    NSString *mode = [self.widgetDict stringForKey:@"mode"];
    if ([MCT_DATE_SELECT_MODE_TIME isEqualToString:mode]) {
        self.datePicker.datePickerMode = UIDatePickerModeTime;
    } else if ([MCT_DATE_SELECT_MODE_DATE isEqualToString:mode]) {
        self.datePicker.datePickerMode = UIDatePickerModeDate;
    } else if ([MCT_DATE_SELECT_MODE_DATE_TIME isEqualToString:mode]) {
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    } else {
        ERROR(@"I don't know date_select mode '%@'. Falling back to UIDatePickerModeDateAndTime!", mode);
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }

    self.datePicker.minuteInterval = self.datePicker.datePickerMode == UIDatePickerModeDate ? 24 * 60
                                                                                            : [self.widgetDict longForKey:@"minute_interval"];
    if ([self.widgetDict boolForKey:@"has_min_date"]) {
        self.datePicker.minimumDate = [NSDate dateWithTimeIntervalSince1970:[self.widgetDict longForKey:@"min_date"]];
    }
    if ([self.widgetDict boolForKey:@"has_max_date"]) {
        self.datePicker.maximumDate = [NSDate dateWithTimeIntervalSince1970:[self.widgetDict longForKey:@"max_date"]];
    }

    if ([self.widgetDict boolForKey:@"has_date"]) {
        self.datePicker.date = [NSDate dateWithTimeIntervalSince1970:[self.widgetDict longForKey:@"date"]];
    } else {
        if (self.datePicker.datePickerMode == UIDatePickerModeTime) {
            MCTlong epoch = [NSDate timeIntervalSinceReferenceDate] + NSTimeIntervalSince1970 + [[NSTimeZone localTimeZone] secondsFromGMT];
            epoch = [MCTUtils floor:epoch % 86400
                       withInterval:60 * self.datePicker.minuteInterval];
            self.datePicker.date = [NSDate dateWithTimeIntervalSince1970:epoch];
        } else {
            self.datePicker.date = [MCTDateSelectView nowWithMinuteInterval:self.datePicker.minuteInterval];
        }
    }

    self.speechBubble = [[TTView alloc] init];
    self.speechBubble.backgroundColor = [UIColor clearColor];
    self.speechBubble.alpha = 0;
    self.speechBubble.exclusiveTouch = YES;
    [self.speechBubble addSubview:self.datePicker];

    NSString *todayStr = self.datePicker.datePickerMode == UIDatePickerModeDate ? NSLocalizedString(@"Today", nil)
                                                                                : NSLocalizedString(@"Now", nil);
    self.todayBtn = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:todayStr]];
    self.todayBtn.momentary = YES;
    self.todayBtn.tintColor = [UIColor darkGrayColor];
    [self.todayBtn addTarget:self action:@selector(onTodayClicked:) forControlEvents:UIControlEventValueChanged];
    [self.speechBubble addSubview:self.todayBtn];

    self.doneBtn = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:NSLocalizedString(@"Done", nil)]];
    self.doneBtn.momentary = YES;
    self.doneBtn.tintColor = OR(MCT_APP_TINT_COLOR, RGBCOLOR(109, 132, 255));
    [self.doneBtn addTarget:self action:@selector(onDoneClicked:) forControlEvents:UIControlEventValueChanged];
    [self.speechBubble addSubview:self.doneBtn];
}

+ (NSTimeZone *)timeZone
{
    T_UI();
    return [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
}

+ (NSDateFormatter *)createDateFormatterWithWidgetDict:(NSDictionary *)widgetDict
{
    T_UI();
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.timeZone = [MCTDateSelectView timeZone];

    NSString *mode = [widgetDict stringForKey:@"mode"];
    if ([MCT_DATE_SELECT_MODE_TIME isEqualToString:mode]) {
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
    } else if ([MCT_DATE_SELECT_MODE_DATE isEqualToString:mode]) {
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }

    return dateFormatter;
}

+ (NSDate *)nowWithMinuteInterval:(NSInteger)minuteInterval
{
    T_UI();
    return [NSDate dateWithTimeIntervalSinceReferenceDate:[MCTUtils floor:[NSDate timeIntervalSinceReferenceDate]
                                                             withInterval:60 * minuteInterval] + [[NSTimeZone localTimeZone] secondsFromGMT]];
}

- (void)removeFromSuperview
{
    T_UI();
    if (self.speechBubble.superview) {
        [self.speechBubble removeFromSuperview];
    }
    [super removeFromSuperview];
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    CGRect tFrame = CGRectMake(0, 0, self.width, [self height]);
    self.tableView.frame = tFrame;

    CGFloat w = [[UIScreen mainScreen] applicationFrame].size.width;
    CGFloat m = 5;
    CGFloat btnW = 60;
    CGFloat btnH = 34;

    [self.todayBtn sizeToFit];
    self.todayBtn.left = m;
    self.todayBtn.top = BUBBLE_POINT_W + m;
    self.todayBtn.width = MAX(btnW, self.todayBtn.width);
    self.todayBtn.height = btnH;

    [self.doneBtn sizeToFit];
    self.doneBtn.top = BUBBLE_POINT_W + m;
    self.doneBtn.width = MAX(btnW, self.doneBtn.width);
    self.doneBtn.height = btnH;
    self.doneBtn.right = w - m;

    CGRect dFrame = self.datePicker.frame;
    CGFloat dX = 1;
    dFrame.origin = CGPointMake(dX, CGRectGetMaxY(self.todayBtn.frame) + m);
    dFrame.size.width = w - 2 * dX;
    self.datePicker.frame = dFrame;

    CGRect bFrame = CGRectMake(0, 0, w, CGRectGetMaxY(self.datePicker.frame) + m);
    self.speechBubble.frame = bFrame;

    if (!self.speechBubble.style) {
        UIColor *color = nil;
        IF_IOS7_OR_GREATER({
            color = RGBCOLOR(230, 230, 230);
        });
        IF_PRE_IOS7({
            color = RGBCOLOR(16, 16, 16);
        });
        CGSize pointSize = CGSizeMake(2 * BUBBLE_POINT_W, BUBBLE_POINT_W);
        self.speechBubble.style = [TTShapeStyle styleWithShape:[TTSpeechBubbleShape shapeWithRadius:5
                                                                                      pointLocation:90
                                                                                         pointAngle:90
                                                                                          pointSize:pointSize]
                                                          next:
                                   [MCTReflectiveFillStyle styleWithColor:color
                                                  topEndHighlightLocation:(2 + BUBBLE_POINT_W + m + btnH / 2) / bFrame.size.height
                                                                     next:
                                    [TTBevelBorderStyle styleWithHighlight:[color shadow]
                                                                    shadow:[color multiplyHue:1 saturation:0.5 value:0.5]
                                                                     width:1
                                                               lightSource:0
                                                                      next:
                                     [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1)
                                                             next:
                                      [TTBevelBorderStyle styleWithHighlight:nil
                                                                      shadow:RGBACOLOR(0,0,0,0.15)
                                                                       width:1
                                                                 lightSource:0
                                                                        next:nil]]]]];
    }
}

- (void)onDateChanged:(id)sender
{
    T_UI();
    self.labelString = [NSString stringWithFormat:self.format, [self.dateFormatter stringFromDate:self.datePicker.date]];

    if (sender) {
        NSIndexPath *i = [NSIndexPath indexPathForRow:0 inSection:0];
        BOOL selected = [self.tableView cellForRowAtIndexPath:i].selected;

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];

        if (selected)
            [self.tableView selectRowAtIndexPath:i animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)onTodayClicked:(id)sender
{
    T_UI();
    NSInteger i = self.datePicker.datePickerMode == UIDatePickerModeDate ? 24 * 60 : self.datePicker.minuteInterval;
    NSDate *date;

    if (self.datePicker.datePickerMode == UIDatePickerModeTime) {
        MCTlong epoch = [NSDate timeIntervalSinceReferenceDate] + NSTimeIntervalSince1970 + [[NSTimeZone localTimeZone] secondsFromGMT];
        epoch = [MCTUtils floor:epoch % 86400
                   withInterval:60 * i];
        date = [NSDate dateWithTimeIntervalSince1970:epoch];
    } else {
        date = [MCTDateSelectView nowWithMinuteInterval:i];
    }

    if (self.datePicker.maximumDate && [self.datePicker.maximumDate timeIntervalSinceDate:date] < 0) {
        self.datePicker.date = self.datePicker.maximumDate;
    } else if (self.datePicker.minimumDate && [self.datePicker.minimumDate timeIntervalSinceDate:date] > 0) {
        self.datePicker.date = self.datePicker.minimumDate;
    } else {
        self.datePicker.date = date;
    }
    [self onDateChanged:MCTYES];
}

- (void)onDoneClicked:(id)sender
{
    T_UI();
    [self toggleDatePicker:NO];
}

- (void)toggleDatePicker:(BOOL)visible
{
    T_UI();
    if ((BOOL)self.speechBubble.alpha != visible) {
        // We need to add bubble to messageDetailView.scrollView, else scrollView will fuck up the touches on the
        // datePicker (because datePicker is shown outside the bounds of formView)

        // Get y coordinate in relation to messageDetailView.scrollView
        CGFloat y = CGRectGetMaxY(self.frame);
        UIView *v = self.superview;
        while (![v isKindOfClass:[MCTMessageDetailView class]]) {
            y += v.frame.origin.y;

            if (!v.superview) {
                ERROR(@"Did not find MCTMessageScrollView in view hierarchy!");
                return;
            }
            v = v.superview;
        }

        MCTMessageDetailView *msgDetailView = (MCTMessageDetailView *) v;

        if (visible) {
            CGRect bFrame = self.speechBubble.frame;
            bFrame.origin.y = y;
            self.speechBubble.frame = bFrame;
            [msgDetailView.scrollView addSubview:self.speechBubble];
        } else {
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
        }

        [UIView animateWithDuration:0.3
                         animations:^{
                             self.speechBubble.alpha = visible ? 1 : 0;
                             if (visible) {
                                 [msgDetailView scrollUpForBottomViewWithHeight:self.speechBubble.frame.size.height];
                             } else  {
                                 [msgDetailView scrollBack];
                             }
                         } completion:^(BOOL finished) {
                             if (!visible) {
                                 [self.speechBubble removeFromSuperview];
                             }
                         }];
    }
}

#pragma mark -
#pragma mark UITableviewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    static NSString *ident = @"";
    MCTDateSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        cell = [[MCTDateSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        cell.backgroundColor = [UIColor clearColor]; // Looks better when msg locked
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = MCT_LBL_FONT;
        cell.textLabel.numberOfLines = 0;

        cell.ttBtn = [TTButton buttonWithStyle:MCT_STYLE_EMBOSSED_SMALL_BUTTON];
        [cell.contentView addSubview:cell.ttBtn];
        [cell.ttBtn setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
        [cell.ttBtn addTarget:self action:@selector(onChangeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.ttBtn.width = 80;
        cell.ttBtn.height = 40;
    }

    cell.textLabel.text = self.labelString;
    return cell;
}

#pragma mark -
#pragma mark UITableviewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return [self height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    [self toggleDatePicker:!self.datePicker.superview.alpha];
}

- (void)onChangeButtonTapped:(TTButton *)sender
{
    T_UI();
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

#pragma mark -
#pragma mark MCTWidget

- (CGFloat)height
{
    T_UI();
    CGFloat w = [[UIScreen mainScreen] applicationFrame].size.width - 70; // margins: 40px, accessoryview: 30px

    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = MCT_LBL_FONT;
    gettingSizeLabel.text = self.labelString;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    CGSize size = [gettingSizeLabel sizeThatFits:CGSizeMake(w, CGFLOAT_MAX)];
    return MAX(44, size.height + 8);
}

- (MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *)result;
{
    T_UI();
    MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *result = \
        [MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO transferObject];
    result.value = [self.datePicker.date timeIntervalSince1970];
    if (self.datePicker.datePickerMode == UIDatePickerModeDate) {
        result.value = result.value - result.value % 86400;
    }
    return result;
}

- (NSDictionary *)widget
{
    T_UI();
    [self.widgetDict setValue:[NSNumber numberWithLong:self.result.value] forKey:@"date"];
    [self.widgetDict setValue:[NSNumber numberWithBool:YES] forKey:@"has_date"];
    return self.widgetDict;
}

- (void)onBackgroundTapped:(id)sender
{
    T_UI();
    [self toggleDatePicker:NO];
}

- (void)onButtonTapped:(id)sender
{
    T_UI();
    [self toggleDatePicker:NO];
}

#pragma mark -

+ (NSString *)valueStringForWidget:(NSDictionary *)widgetDict
{
    T_UI();
    NSDateFormatter *dateFormatter = [MCTDateSelectView createDateFormatterWithWidgetDict:widgetDict];

    NSDate *date;
    if ([widgetDict boolForKey:@"has_date"]) {
        date = [NSDate dateWithTimeIntervalSince1970:[widgetDict longForKey:@"date"]];
    } else {
        // no need to floor the date here if mode is "date"
        date = [MCTDateSelectView nowWithMinuteInterval:[widgetDict longForKey:@"minute_interval"]];
    }

    NSString *format;
    NSString *unit = [widgetDict stringForKey:@"unit"];
    if ([MCTUtils isEmptyOrWhitespaceString:unit]) {
        format = @"%@";
    } else {
        format = [unit stringByReplacingOccurrencesOfString:MCT_UNIT_VALUE withString:@"%@"];
    }

    return [NSString stringWithFormat:format, [dateFormatter stringFromDate:date]];
}

@end