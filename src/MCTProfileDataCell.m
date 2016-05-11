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

#import "MCTProfileDataCell.h"
#import "MCTUIUtils.h"

@implementation MCTProfileDataCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    T_UI();
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        UILabel *pdLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 115, 44)];
        pdLbl.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        pdLbl.textAlignment = NSTextAlignmentRight;
        pdLbl.numberOfLines = 0;

        UITextView *pdTxt = [[UITextView alloc] initWithFrame:CGRectMake(130, 0, [UIScreen mainScreen].applicationFrame.size.width - 130, 44)];
        pdTxt.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        pdTxt.textColor = [UIColor blackColor];
        pdTxt.dataDetectorTypes = UIDataDetectorTypeAll;
        pdTxt.editable = NO;
        pdTxt.scrollEnabled = NO;

        [self.contentView addSubview:pdLbl];
        
        [self.contentView addSubview:pdTxt];
    }
    return self;
}

- (void)setKeyTextColor:(UIColor *)color
{
    T_UI();
    UILabel *pdLbl = self.contentView.subviews[0];
    pdLbl.textColor = color;
}

- (void)setKey:(NSString *)key
{
    T_UI();
    UILabel *pdLbl = self.contentView.subviews[0];
    pdLbl.text = key;
}

- (void)setData:(NSString *)data
{
    T_UI();
    UITextView *pdTxt = self.contentView.subviews[1];
    pdTxt.text = data;
}

+ (CGFloat)calculateHeight:(MCTProfileDataCell *)cell
{
    T_UI();
    CGSize size1 = [MCTUIUtils sizeForLabel:cell.contentView.subviews[0] withWidth:115];
    CGSize size2 = [MCTUIUtils sizeForTextView:cell.contentView.subviews[1] withWidth:[UIScreen mainScreen].applicationFrame.size.width - 130];

    CGFloat h = fmax(44, size1.height);
    h = fmax(h, size2.height + 14);
    return h;
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    UITextView *pdTxt = self.contentView.subviews[1];
    CGRect valueFrame = pdTxt.frame;
    valueFrame.size = [MCTUIUtils sizeForTextView:pdTxt withWidth:[UIScreen mainScreen].applicationFrame.size.width - 130];
    pdTxt.frame = valueFrame;
    pdTxt.centerY = self.height / 2 - 1.5;
}

@end