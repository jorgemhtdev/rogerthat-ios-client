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

#import <QuartzCore/QuartzCore.h>

#import "MCTAutoCompleteView.h"
#import "MCTComponentFramework.h"
#import "MCTDateSelectView.h"
#import "MCTFormView.h"
#import "MCTJSONUtils.h"
#import "MCTMessage.h"
#import "MCTMessageEnums.h"
#import "MCTMessageHelper.h"
#import "MCTMyDigiPassView.h"
#import "MCTAdvancedOrderView.h"
#import "MCTMultiSelectView.h"
#import "MCTOperation.h"
#import "MCTPhotoUploadView.h"
#import "MCTRangeSliderView.h"
#import "MCTSingleSelectView.h"
#import "MCTSingleSliderView.h"
#import "MCTTextBlockView.h"
#import "MCTTextLineView.h"
#import "MCTGPSLocationView.h"
#import "MCTUIUtils.h"
#import "MCTMessageDetailVC.h"

#define MARGIN 10
#define BUTTON_HEIGHT 44
#define KEY_CLASS   @"class"
#define KEY_SUBMIT  @"submit"


static const NSDictionary *kWidgetMapping;


@interface MCTFormView ()

@property (nonatomic, copy) NSString *myAnswer;
@property(nonatomic, strong) NSTimer *javascriptValidationTimeoutTimer;


- (id)initWithMessage:(MCTMessage *)msg
             andWidth:(CGFloat)w
       andColorScheme:(MCTColorScheme)colorScheme
     inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc;

- (TTButton *)buttonWithPositive:(BOOL)positive andLocked:(BOOL)isLocked andColorScheme:(MCTColorScheme)colorScheme;
- (BOOL)submitFormWithButtonId:(NSString *)btnId
           interactionPossible:(BOOL)interactionPossible
       andShouldValidateResult:(BOOL)shouldValidateResult;

- (void)unregisterIntents;

@end


@implementation MCTFormView


- (void)dealloc
{
    T_UI();
    [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
    // Do not release self.viewController
    [self.javascriptValidationTimeoutTimer invalidate];
}

+ (void)initialize
{
    if (!kWidgetMapping) {
        NSArray *keys = @[KEY_CLASS, KEY_SUBMIT];

        NSArray *textLine      = @[[MCTTextLineView class],
                                   [NSValue valueWithPointer:@selector(submitTextLineForm:withValue:buttonId:)]];
        NSArray *textBlock     = @[[MCTTextBlockView class],
                                   [NSValue valueWithPointer:@selector(submitTextBlockForm:withValue:buttonId:)]];
        NSArray *autoComplete  = @[[MCTAutoCompleteView class],
                                   [NSValue valueWithPointer:@selector(submitAutoCompleteForm:withValue:buttonId:)]];
        NSArray *singleSelect  = @[[MCTSingleSelectView class],
                                   [NSValue valueWithPointer:@selector(submitSingleSelectForm:withValue:buttonId:)]];
        NSArray *multiSelect   = @[[MCTMultiSelectView class],
                                   [NSValue valueWithPointer:@selector(submitMultiSelectForm:withValue:buttonId:)]];
        NSArray *dateSelect    = @[[MCTDateSelectView class],
                                   [NSValue valueWithPointer:@selector(submitDateSelectForm:withValue:buttonId:)]];
        NSArray *singleSlider  = @[[MCTSingleSliderView class],
                                   [NSValue valueWithPointer:@selector(submitSingleSliderForm:withValue:buttonId:)]];
        NSArray *rangeSlider   = @[[MCTRangeSliderView class],
                                   [NSValue valueWithPointer:@selector(submitRangeSliderForm:withValue:buttonId:)]];
        NSArray *photoUpload   = @[[MCTPhotoUploadView class],
                                   [NSValue valueWithPointer:@selector(startPhotoUploadWithForm:image:buttonId:)]];
        NSArray *gpsLocation   = @[[MCTGPSLocationView class],
                                   [NSValue valueWithPointer:@selector(submitGPSLocationForm:withValue:buttonId:)]];
        NSArray *myDigiPass    = @[[MCTMyDigiPassView class],
                                   [NSValue valueWithPointer:@selector(submitMyDigiPassForm:withValue:buttonId:)]];
        NSArray *advancedOrder = @[[MCTAdvancedOrderView class],
                                   [NSValue valueWithPointer:@selector(submitAdvancedOrderForm:withValue:buttonId:)]];

        kWidgetMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSDictionary dictionaryWithObjects:textLine      forKeys:keys], MCT_WIDGET_TEXT_LINE,
                          [NSDictionary dictionaryWithObjects:textBlock     forKeys:keys], MCT_WIDGET_TEXT_BLOCK,
                          [NSDictionary dictionaryWithObjects:autoComplete  forKeys:keys], MCT_WIDGET_AUTO_COMPLETE,
                          [NSDictionary dictionaryWithObjects:singleSelect  forKeys:keys], MCT_WIDGET_SINGLE_SELECT,
                          [NSDictionary dictionaryWithObjects:multiSelect   forKeys:keys], MCT_WIDGET_MULTI_SELECT,
                          [NSDictionary dictionaryWithObjects:dateSelect    forKeys:keys], MCT_WIDGET_DATE_SELECT,
                          [NSDictionary dictionaryWithObjects:singleSlider  forKeys:keys], MCT_WIDGET_SINGLE_SLIDER,
                          [NSDictionary dictionaryWithObjects:rangeSlider   forKeys:keys], MCT_WIDGET_RANGE_SLIDER,
                          [NSDictionary dictionaryWithObjects:photoUpload   forKeys:keys], MCT_WIDGET_PHOTO_UPLOAD,
                          [NSDictionary dictionaryWithObjects:gpsLocation   forKeys:keys], MCT_WIDGET_GPS_LOCATION,
                          [NSDictionary dictionaryWithObjects:myDigiPass    forKeys:keys], MCT_WIDGET_MYDIGIPASS,
                          [NSDictionary dictionaryWithObjects:advancedOrder forKeys:keys], MCT_WIDGET_ADVANCED_ORDER,
                          nil];
    }
}

+ (MCTFormView *)viewWithMessage:(MCTMessage *)msg
                        andWidth:(CGFloat)w
                  andColorScheme:(MCTColorScheme)colorScheme
                inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc;
{
    T_UI();
    return [[MCTFormView alloc] initWithMessage:msg andWidth:w andColorScheme:colorScheme inViewController:vc];
}

- (id)initWithMessage:(MCTMessage *)msg
             andWidth:(CGFloat)w
       andColorScheme:(MCTColorScheme)colorScheme
     inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc
{
    T_UI();
    NSString *type = [msg.form stringForKey:@"type"];
    if (![kWidgetMapping containsKey:type]) {
        ERROR(@"Unsupported form type %@", type);
        return nil;
    }

    if (self = [super init]) {
        self.width = w;
        self.message = msg;
        self.viewController = vc;
        self.colorScheme = colorScheme;
        self.clipsToBounds = YES;

        [self refreshView];
        [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                        forIntentActions: [NSArray arrayWithObjects:kINTENT_IDENTITY_MODIFIED,
                                                                           kINTENT_MESSAGE_JS_VALIDATION_RESULT, nil]
                                                                onQueue:[MCTComponentFramework mainQueue]];
    }

    return self;
}

- (void)refreshView
{
    NSString *type = [self.message.form stringForKey:@"type"];
    BOOL isLocked = (self.message.flags & MCTMessageFlagLocked) == MCTMessageFlagLocked;

    NSDictionary *widgetDict = OR(self.widgetView.widget, [self.message.form objectForKey:@"widget"]);

    if (self.widgetView) {
        [self.widgetView removeFromSuperview];
        MCT_RELEASE(self.widgetView);
    }

    if (self.avatarView) {
        [self.avatarView removeFromSuperview];
        MCT_RELEASE(self.avatarView);
    }

    if (self.positiveBtn) {
        [self.positiveBtn removeFromSuperview];
        MCT_RELEASE(self.positiveBtn);
    }

    if (self.negativeBtn) {
        [self.negativeBtn removeFromSuperview];
        MCT_RELEASE(self.negativeBtn);
    }

    Class klass = [[kWidgetMapping objectForKey:type] objectForKey:KEY_CLASS];
    self.widgetView = [[klass alloc] initWithDict:widgetDict
                                          andWidth:self.width
                                    andColorScheme:self.colorScheme
                                  inViewController:self.viewController];
    if (isLocked) {
        self.widgetView.alpha = 0.8f;
        self.widgetView.enabled = NO;
    }
    [self addSubview:self.widgetView];

    NSString *myEmail = [[MCTComponentFramework friendsPlugin] myEmail];
    MCT_com_mobicage_to_messaging_MemberStatusTO *myMemberStatus = [self.message memberWithEmail:myEmail];
    if ((myMemberStatus.status & MCTMessageStatusAcked) == MCTMessageStatusAcked && myMemberStatus.button_id) {
        self.myAnswer = myMemberStatus.button_id;
        if (self.myAnswer != nil && ![MCT_FORM_POSITIVE isEqualToString:self.myAnswer]
            && ![MCT_FORM_NEGATIVE isEqualToString:self.myAnswer]) {
            ERROR(@"Unexpect button_id in my member_status: \n%@", self.message);
            MCT_RELEASE(self.myAnswer);
        }
        UIImage *img = [[MCTComponentFramework friendsPlugin] friendAvatarImageByEmail:myEmail];
        self.avatarView = [[UIImageView alloc] initWithImage:img];
        [MCTUIUtils addRoundedBorderToView:self.avatarView];
        [self addSubview:self.avatarView];
    }

    self.positiveBtn = [self buttonWithPositive:YES andLocked:isLocked andColorScheme:self.colorScheme];
    [self addSubview:self.positiveBtn];

    self.negativeBtn = [self buttonWithPositive:NO andLocked:isLocked andColorScheme:self.colorScheme];
    [self addSubview:self.negativeBtn];

    [self addTarget:self action:@selector(onBackgroundTapped:) forControlEvents:UIControlEventTouchUpInside];

    [self setNeedsLayout];
}

- (void)removeFromSuperview
{
    T_UI();
    [self unregisterIntents];
    [super removeFromSuperview];
}

- (NSString *)positiveButtonText
{
    return [self.message.form stringForKey:@"positive_button"];
}


- (TTButton *)buttonWithPositive:(BOOL)positive andLocked:(BOOL)isLocked andColorScheme:(MCTColorScheme)colorScheme
{
    T_UI();
    TTButton *btn = [TTButton buttonWithStyle:(positive ? MCT_STYLE_POSITIVE_BUTTON : MCT_STYLE_NEGATIVE_BUTTON)
                                        title:[self.message.form stringForKey:(positive ? @"positive_button" : @"negative_button")]];

    if (isLocked) {
        btn.enabled = NO;
    } else {
        [btn addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }

    return btn;
}

- (void)layoutSubviews
{
    T_UI();
    HERE();
    [super layoutSubviews];

    [self.widgetView layoutSubviews];
    CGFloat h = [self maxWidgetHeight];
    CGRect wvFrame = CGRectMake(0, 0, self.width, h);
    self.widgetView.frame = wvFrame;

    CGFloat btnWidth = self.width;
    if (self.myAnswer) {
        btnWidth -= BUTTON_HEIGHT + MARGIN;
    }

    CGFloat pbH = [MCTUIUtils sizeForTTButton:self.positiveBtn constrainedToSize:CGSizeMake(btnWidth, 126)].height;
    CGRect pbFrame = CGRectMake(0, wvFrame.origin.y + [self.widgetView height] + MARGIN, btnWidth, MAX(BUTTON_HEIGHT, pbH));
    self.positiveBtn.frame = pbFrame;

    CGFloat nbH = [MCTUIUtils sizeForTTButton:self.negativeBtn constrainedToSize:CGSizeMake(btnWidth, 126)].height;
    CGRect nbFrame = CGRectMake(0, CGRectGetMaxY(pbFrame) + MARGIN, btnWidth, MAX(BUTTON_HEIGHT, nbH));
    self.negativeBtn.frame = nbFrame;

    if (self.myAnswer) {
        CGRect neighbourFrame = [MCT_FORM_POSITIVE isEqualToString:self.myAnswer] ? pbFrame : nbFrame;
        CGFloat avX = CGRectGetMaxX(neighbourFrame) + MARGIN;
        CGRect avFrame = CGRectMake(avX, CGRectGetMinY(neighbourFrame), BUTTON_HEIGHT, BUTTON_HEIGHT);
        self.avatarView.frame = avFrame;
    }

    CGRect f = self.frame;
    f.size.height = [self height] + MARGIN;
    self.frame = f;
}

- (CGFloat)height
{
    T_UI();
    return CGRectGetMaxY(self.negativeBtn.frame);
}

- (CGFloat)maxWidgetHeight
{
    T_UI();
    return [self.widgetView respondsToSelector:@selector(expandedHeight)] ? [self.widgetView expandedHeight] : [self.widgetView height];
}

- (void)onBackgroundTapped:(id)sender
{
    T_UI();
    SEL selector = @selector(onBackgroundTapped:);
    if ([self.widgetView respondsToSelector:selector]) {
        IMP imp = [self.widgetView methodForSelector:selector];
        void (*func)(id, SEL, id) = (void *)imp;
        func(self.widgetView, selector, sender);
    }
}

- (void)onButtonTapped:(UIControl *)sender
{
    T_UI();
    [self excecuteButtonTapped:sender andShouldValidateResult:YES];
}

- (void)excecuteButtonTapped:(UIControl *)sender andShouldValidateResult:(BOOL)shouldValidateResult
{
    T_UI();
    if ([self.widgetView respondsToSelector:@selector(onButtonTapped:)])
        [self.widgetView onButtonTapped:sender];

    NSString *btnId;
    if (sender == self.positiveBtn) {
        btnId = MCT_FORM_POSITIVE;
    } else if (sender == self.negativeBtn) {
        btnId = MCT_FORM_NEGATIVE;
    } else {
        ERROR(@"I don't know this button:\n%@", sender);
        return;
    }

    if (shouldValidateResult) {
        NSString *confirmation = nil;
        if ([btnId isEqualToString:MCT_FORM_POSITIVE]) {
            confirmation = [self.message.form objectForKey:@"positive_confirmation"];
        } else if ([btnId isEqualToString:MCT_FORM_NEGATIVE]) {
            confirmation = [self.message.form objectForKey:@"negative_confirmation"];
        } else {
            ERROR(@"I don't know this button:\n%@", btnId);
            return;
        }
        if (confirmation && confirmation != MCTNull) {
            self.viewController.currentAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please confirm", nil)
                                                                               message:confirmation
                                                                              delegate:self.viewController
                                                                     cancelButtonTitle:NSLocalizedString(@"No", nil)
                                                                     otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
            if ([MCT_FORM_POSITIVE isEqualToString:btnId]) {
                self.viewController.currentAlertView.tag = MCT_TAG_FORM_POSITIVE_BUTTON;
            } else if ([MCT_FORM_NEGATIVE isEqualToString:btnId]) {
                self.viewController.currentAlertView.tag = MCT_TAG_FORM_NEGATIVE_BUTTON;
            } else {
                ERROR(@"Unexpected button id %@ in form message %@", btnId, self.message.key);
            }
            [self.viewController.currentAlertView show];
        } else {
            [self submitFormWithButtonId:btnId interactionPossible:YES andShouldValidateResult:YES];
        }
    } else {
        [self submitFormWithButtonId:btnId interactionPossible:NO andShouldValidateResult:NO];
    }
}

- (BOOL)submitFormWithButtonId:(NSString *)btnId interactionPossible:(BOOL)interactionPossible andShouldValidateResult:(BOOL)shouldValidateResult
{
    T_UI();
    BOOL isPositiveButton = [MCT_FORM_POSITIVE isEqualToString:btnId];

    if (interactionPossible && [self.widgetView respondsToSelector:@selector(toBeShownBeforeSubmitWithPositiveButton:)]) {
        id interaction = [self.widgetView toBeShownBeforeSubmitWithPositiveButton:isPositiveButton];
        if (interaction) {
            LOG(@"Widget wants to show a %@ before proceeding with submitForm.", [interaction class]);

            if ([interaction isKindOfClass:[UIAlertView class]]) {
                UIAlertView *alertView = (UIAlertView *) interaction;
                if (alertView.delegate)
                    ERROR(@"Overriding widgets UIAlertView delegate!");
                if (alertView.tag)
                    ERROR(@"Overriding widgets UIAlertView tag!");

                alertView.delegate = self.viewController;
                alertView.tag = isPositiveButton ? MCT_TAG_FORM_POSITIVE_ALERT_BEFORE_SUBMIT : MCT_TAG_FORM_NEGATIVE_ALERT_BEFORE_SUBMIT;
                [alertView show];
                self.viewController.currentAlertView = alertView;
                return NO;
            } else if ([interaction isKindOfClass:[UIActionSheet class]]) {
                UIActionSheet *actionSheet = (UIActionSheet *) interaction;
                if (actionSheet.delegate)
                    ERROR(@"Overriding widgets UIActionSheet delegate!");
                if (actionSheet.tag)
                    ERROR(@"Overriding widgets UIActionSheet tag!");

                actionSheet.delegate = self.viewController;
                actionSheet.tag = isPositiveButton ? MCT_TAG_FORM_POSITIVE_ACTION_BEFORE_SUBMIT : MCT_TAG_FORM_NEGATIVE_ACTION_BEFORE_SUBMIT;
                [MCTUIUtils showActionSheet:actionSheet inViewController:self.viewController];
                self.viewController.currentActionSheet = actionSheet;
                return NO;
            }
        }
    }

    if (shouldValidateResult && [btnId isEqualToString:MCT_FORM_POSITIVE]) {
        id result = [self.widgetView result];
        if (result != nil && [result respondsToSelector:@selector(dictRepresentation)]) {
            BOOL success = [[MCTComponentFramework messagesPlugin] validateFormMessage:self.message
                                                                        withFormResult:[result dictRepresentation]];
            if (success) {
                MCTMessageDetailVC *vc = (MCTMessageDetailVC *) self.viewController;
                vc.currentActionSheet = [vc showActionSheetWithTitle:NSLocalizedString(@"Processing ...", nil)];
                vc.currentActionSheet.delegate = vc;
                self.javascriptValidationTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                                                         target:self
                                                                                       selector:@selector(onValidateTimeout:)
                                                                                       userInfo:nil
                                                                                        repeats:NO];
                return;
            }
        }
    }

    id formResult = MCTNull;
    if (isPositiveButton) {
        formResult = [self.widgetView result];
        if (formResult == nil)
            formResult = MCTNull;
        [self.message.form setValue:[self.widgetView widget] forKey:@"widget"];
    }

    NSString *type = [self.message.form stringForKey:@"type"];
    SEL sel = [[[kWidgetMapping objectForKey:type] objectForKey:KEY_SUBMIT] pointerValue];

    [[MCTComponentFramework workQueue]
     addOperation:[MCTInvocationOperation operationWithTarget:[MCTComponentFramework messagesPlugin]
                                                     selector:sel
                                                      objects:self.message, formResult, btnId, nil]];

    MCT_com_mobicage_to_messaging_MemberStatusTO *myMember = [self.message memberWithEmail:[[MCTComponentFramework friendsPlugin] myEmail]];
    myMember.status |= MCTMessageStatusAcked;
    myMember.button_id = btnId;
    if (IS_FLAG_SET(self.message.flags, MCTMessageFlagAutoLock))
        self.message.flags |= MCTMessageFlagLocked;

    [self.positiveBtn removeFromSuperview];
    [self.negativeBtn removeFromSuperview];
    [self.widgetView removeFromSuperview];
    [self.avatarView removeFromSuperview];
    MCT_RELEASE(self.positiveBtn);
    MCT_RELEASE(self.negativeBtn);
    MCT_RELEASE(self.widgetView);
    MCT_RELEASE(self.avatarView);
    [self refreshView];

    return YES;
}

- (BOOL)processAlertViewClickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    NSInteger tag = self.viewController.currentAlertView.tag;
    if (tag == MCT_TAG_FORM_NEGATIVE_BUTTON || tag == MCT_TAG_FORM_POSITIVE_BUTTON) {
        if (buttonIndex != self.viewController.currentAlertView.cancelButtonIndex) {
            [self submitFormWithButtonId:tag == MCT_TAG_FORM_POSITIVE_BUTTON ? MCT_FORM_POSITIVE : MCT_FORM_NEGATIVE
                     interactionPossible:NO
                 andShouldValidateResult:YES];
        }

        MCT_RELEASE(self.viewController.currentAlertView);
        return YES;

    } else if (tag == MCT_TAG_FORM_POSITIVE_ALERT_BEFORE_SUBMIT || tag == MCT_TAG_FORM_NEGATIVE_ALERT_BEFORE_SUBMIT) {
        if ([self.widgetView respondsToSelector:@selector(beforeSubmitAlertView:answeredWithButtonIndex:submitCallback:)]) {

            NSString *buttonId = tag == MCT_TAG_FORM_POSITIVE_ALERT_BEFORE_SUBMIT ? MCT_FORM_POSITIVE : MCT_FORM_NEGATIVE;
            [self.widgetView beforeSubmitAlertView:self.viewController.currentAlertView
                           answeredWithButtonIndex:buttonIndex
                                    submitCallback:^{
                                        [self submitFormWithButtonId:buttonId
                                                 interactionPossible:NO
                                             andShouldValidateResult:YES];
                                    }];
        }
        MCT_RELEASE(self.viewController.currentAlertView);
        return YES;
    } else if (tag == MCT_TAG_WIDGET_ACTION) {
        if ([self.widgetView respondsToSelector:@selector(processAlertViewClickedButtonAtIndex:)]) {
            [self.widgetView processAlertViewClickedButtonAtIndex:buttonIndex];
        }
        MCT_RELEASE(self.viewController.currentAlertView);
        return YES;
    }
    return NO;
}

- (BOOL)processActionSheetClickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    NSInteger tag = self.viewController.currentActionSheet.tag;
    if (tag == MCT_TAG_FORM_POSITIVE_ACTION_BEFORE_SUBMIT || tag == MCT_TAG_FORM_NEGATIVE_ACTION_BEFORE_SUBMIT) {
        if ([self.widgetView respondsToSelector:@selector(beforeSubmitActionSheet:answeredWithButtonIndex:submitCallback:)]) {

            NSString *buttonId = tag == MCT_TAG_FORM_POSITIVE_ACTION_BEFORE_SUBMIT ? MCT_FORM_POSITIVE : MCT_FORM_NEGATIVE;
            [self.widgetView beforeSubmitActionSheet:self.viewController.currentActionSheet
                             answeredWithButtonIndex:buttonIndex
                                      submitCallback:^{
                                          [self submitFormWithButtonId:buttonId
                                                   interactionPossible:NO
                                               andShouldValidateResult:YES];
                                      }];

        } else {
            ERROR(@"%@ should implement beforeSubmitActionSheet:answeredWithButtonIndex:submitCallback: !!", [self.widgetView class]);
        }
        MCT_RELEASE(self.viewController.currentActionSheet);
        return YES;
    } else if (tag == MCT_TAG_WIDGET_ACTION) {
        if ([self.widgetView respondsToSelector:@selector(processActionSheetClickedButtonAtIndex:)]) {
            [self.widgetView processActionSheetClickedButtonAtIndex:buttonIndex];
        }
        MCT_RELEASE(self.viewController.currentActionSheet);
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark IMCTIntentReceiver

- (void)unregisterIntents
{
    T_UI();
    [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
    if ([self.widgetView conformsToProtocol:@protocol(IMCTIntentReceiver)]) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:((NSObject<IMCTIntentReceiver> *)self.widgetView)];
    }
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_IDENTITY_MODIFIED) {
        NSString *myEmail = [[MCTComponentFramework friendsPlugin] myEmail];
        UIImage *img = [[MCTComponentFramework friendsPlugin] friendAvatarImageByEmail:myEmail];
        self.avatarView = [[UIImageView alloc] initWithImage:img];
    } else if (intent.action == kINTENT_MESSAGE_JS_VALIDATION_RESULT) {
        if (![self.message.key isEqualToString:[intent stringForKey:@"message_key"]]) {
            return;
        }
        [self processJavascriptValidationResult:[intent stringForKey:@"result"]];
    }
}

#pragma mark -

+ (NSString *)valueStringForForm:(NSDictionary *)form
{
    T_UI();
    NSString *type = [form stringForKey:@"type"];

    if (![kWidgetMapping containsKey:type]) {
        ERROR(@"Unsupported form type %@", type);
        return nil;
    }

    Class klass = [[kWidgetMapping objectForKey:type] objectForKey:KEY_CLASS];
    return [klass valueStringForWidget:[form objectForKey:@"widget"]];
}

- (void)onValidateTimeout:(NSTimer *)timer;
{
    T_UI();
    if (timer == self.javascriptValidationTimeoutTimer && self.viewController.currentActionSheet) {
        [self processJavascriptValidationResult:nil];
    }
}

- (void)processJavascriptValidationResult:(NSString *)result
{
    [self.javascriptValidationTimeoutTimer invalidate];
    MCT_RELEASE(self.javascriptValidationTimeoutTimer);
    
    if ([MCTUtils isEmptyOrWhitespaceString:result]) {
        MCTMessageDetailVC *vc = (MCTMessageDetailVC *) self.viewController;
        MCTlong expectNextWait = [vc expectNextWithFlags:[self.message buttonWithId:MCT_FORM_POSITIVE].ui_flags];

        if (expectNextWait && (self.message.isSentByJSMFR || [MCTUtils connectedToInternetAndXMPP])) {
            // Don't hide spinner
        } else {
            MCT_RELEASE(self.viewController.currentActionSheet);
        }

        [self excecuteButtonTapped:self.positiveBtn andShouldValidateResult:NO];
    } else {
        MCT_RELEASE(self.viewController.currentActionSheet);
        self.viewController.currentAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"validation_failed", nil)
                                                            message:result
                                                           delegate:self.viewController
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                                  otherButtonTitles:nil];
        [self.viewController.currentAlertView show];
    }
}

@end