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

#import "MCTComponentFramework.h"
#import "MCTMessageHelper.h"
#import "MCTServiceMessageCell.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

#define MARGIN 5
#define MCT_FONT_SIZE [UIFont systemFontSize]
#define MCT_LINE_BREAK NSLineBreakByTruncatingTail


@interface MCTServiceMessageCell ()

+ (NSString *)stripEmptyLines:(NSString *)msgText;
+ (UIFont *)textFontWithMessage:(MCTMessage *)msg;
+ (UIColor *)textColorWithMessage:(MCTMessage *)msg;

+ (CGSize)sizeOfTimeLabelWithMessage:(MCTMessage *)msg;
+ (CGSize)sizeOfMessageText:(NSString *)msgText withMaxWidth:(CGFloat)width andFont:(UIFont *)font;
+ (CGSize)sizeOfAnswerText:(NSString *)text withFont:(UIFont *)font;

@end

@implementation MCTServiceMessageCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    T_UI();
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.msgLabel = [[UILabel alloc] init];
        self.msgLabel.backgroundColor = [UIColor clearColor];
        self.msgLabel.lineBreakMode = MCT_LINE_BREAK;
        self.msgLabel.numberOfLines = 3;

        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        self.timeLabel.textColor = [UIColor grayColor];

        self.btnLabel = [[UILabel alloc] init];
        self.btnLabel.backgroundColor = [UIColor clearColor];
        self.btnLabel.font = [UIFont italicSystemFontOfSize:MCT_FONT_SIZE];
        self.btnLabel.lineBreakMode = MCT_LINE_BREAK;
        self.btnLabel.numberOfLines = 3;
        self.btnLabel.textColor = [UIColor grayColor];

        self.sepView = [[UIView alloc] init];
        self.sepView.backgroundColor = [UIColor MCTSeparatorColor];

        self.plugin = [MCTComponentFramework messagesPlugin];

        [self addSubview:self.msgLabel];
        [self addSubview:self.timeLabel];
        [self addSubview:self.btnLabel];
        [self addSubview:self.sepView];
    }
    return self;
}

- (void)setMessage:(MCTMessage *)msg
{
    T_UI();
    if (_message == msg)
        return;
    _message = msg;

    if (msg == nil)
        return;

    self.timeLabel.text = [MCTUtils timestampShortNotation:msg.timestamp andShowMinutes:NO];
    self.msgLabel.text = [MCTServiceMessageCell stripEmptyLines:msg.message];
    self.msgLabel.textColor = [MCTServiceMessageCell textColorWithMessage:msg];
    self.msgLabel.font = [MCTServiceMessageCell textFontWithMessage:msg];

    NSString *answerText = [MCTMessageHelper formValueStringForMessage:msg];
    if ([MCTUtils isEmptyOrWhitespaceString:answerText])
        answerText = [[MCTComponentFramework messagesPlugin] myAnswerTextWithMessage:msg];
    self.btnLabel.text = answerText;

    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    CGFloat w = CGRectGetMaxX(self.frame);

    // Time Label - calculate width of time label text
    CGSize tSize = [MCTServiceMessageCell sizeOfTimeLabelWithMessage:self.message];
    CGFloat tW = tSize.width;
    CGRect tFrame = CGRectMake(w - MARGIN - tW, MARGIN, tW, self.timeLabel.font.pointSize + 4);
    self.timeLabel.frame = tFrame;

    // Message Label - calculate height for vertical alignment
    CGFloat mW = CGRectGetMinX(tFrame) - 2 * MARGIN;
    CGSize mSize = [MCTServiceMessageCell sizeOfMessageText:self.msgLabel.text
                                               withMaxWidth:mW
                                                    andFont:self.msgLabel.font];
    CGRect mFrame = CGRectMake(MARGIN, MARGIN, mW, mSize.height);
    self.msgLabel.frame = mFrame;

    if (![MCTUtils isEmptyOrWhitespaceString:self.btnLabel.text]) {
        CGSize bSize = [MCTServiceMessageCell sizeOfAnswerText:self.btnLabel.text withFont:self.btnLabel.font];
        self.btnLabel.frame = CGRectMake(MARGIN, CGRectGetMaxY(mFrame), bSize.width, bSize.height);
    } else {
        self.btnLabel.frame = CGRectZero;
    }

    CGFloat sY = MAX(44, MAX(CGRectGetMaxY(self.msgLabel.frame), CGRectGetMaxY(self.btnLabel.frame)) + MARGIN) -1;
    self.sepView.frame = CGRectMake(0, sY, w, 1);
}

#pragma mark -

+ (NSString *)stripEmptyLines:(NSString *)msgText
{
    T_UI();
    while ([msgText rangeOfString:@"\n\n"].location != NSNotFound)
        msgText = [msgText stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];

    return msgText;
}

+ (UIFont *)textFontWithMessage:(MCTMessage *)msg
{
    T_UI();
    if (msg.dirty)
        return [UIFont italicSystemFontOfSize:MCT_FONT_SIZE];

    if (msg.needsMyAnswer)
        return [UIFont boldSystemFontOfSize:MCT_FONT_SIZE];

    return [UIFont systemFontOfSize:MCT_FONT_SIZE];
}

+ (UIColor *)textColorWithMessage:(MCTMessage *)msg
{
    T_UI();
    return [UIColor blackColor];
}

#pragma mark -
#pragma mark Size Calculation

+ (CGSize)sizeOfTimeLabelWithMessage:(MCTMessage *)msg
{
    T_UI();
    UIFont *font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = font;
    gettingSizeLabel.text = [MCTUtils timestampShortNotation:msg.timestamp andShowMinutes:NO];
    gettingSizeLabel.numberOfLines = 1;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;

    CGSize tSize = [gettingSizeLabel sizeThatFits:CGSizeMake(100, font.pointSize + 4)];
    return tSize;
}

+ (CGSize)sizeOfMessageText:(NSString *)msgText withMaxWidth:(CGFloat)width andFont:(UIFont *)font
{
    T_UI();
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = font;
    gettingSizeLabel.text = msgText;
    gettingSizeLabel.numberOfLines = 2;
    gettingSizeLabel.lineBreakMode = MCT_LINE_BREAK;

    CGSize mSize = [gettingSizeLabel sizeThatFits:CGSizeMake(width, 3 * (font.pointSize + 4))];
    return mSize;
}

+ (CGSize)sizeOfAnswerText:(NSString *)text withFont:(UIFont *)font
{
    T_UI();
    CGSize bSize = CGSizeZero;

    if (![MCTUtils isEmptyOrWhitespaceString:text]) {
        CGFloat w = [[UIScreen mainScreen] applicationFrame].size.width;

        UILabel *gettingSizeLabel = [[UILabel alloc] init];
        gettingSizeLabel.font = font;
        gettingSizeLabel.text = text;
        gettingSizeLabel.numberOfLines = 2;
        gettingSizeLabel.lineBreakMode = MCT_LINE_BREAK;

        bSize = [gettingSizeLabel sizeThatFits:CGSizeMake(w - 2 * MARGIN, 3 * (MCT_FONT_SIZE + 4))];
    }
    return bSize;
}

+ (CGFloat)heightWithMessage:(MCTMessage *)msg
{
    T_UI();
    CGFloat w = [[UIScreen mainScreen] applicationFrame].size.width;

    CGSize tSize = [MCTServiceMessageCell sizeOfTimeLabelWithMessage:msg];
    CGSize mSize = [MCTServiceMessageCell sizeOfMessageText:[MCTServiceMessageCell stripEmptyLines:msg.message]
                                                withMaxWidth:w - tSize.width - 3 * MARGIN
                                                    andFont:[MCTServiceMessageCell textFontWithMessage:msg]];

    NSString *answerText = [MCTMessageHelper formValueStringForMessage:msg];
    if ([MCTUtils isEmptyOrWhitespaceString:answerText])
        answerText = [[MCTComponentFramework messagesPlugin] myAnswerTextWithMessage:msg];

    CGSize bSize = [MCTServiceMessageCell sizeOfAnswerText:answerText
                                                  withFont:[UIFont italicSystemFontOfSize:MCT_FONT_SIZE]];

    CGFloat h = MARGIN + MAX(tSize.height, mSize.height) + MARGIN + (bSize.height ? bSize.height : 0);
    return MAX(44, h);
}

@end