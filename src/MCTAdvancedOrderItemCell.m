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

#import "MCTAdvancedOrderItemCell.h"
#import "UIImage+FontAwesome.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

@implementation MCTAdvancedOrderItemCell


- (id)initWithReuseIdentifier:(NSString *)identifier
{
    T_UI();
    if (self = [super initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:identifier]) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];

        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.nameLabel];
        self.priceLabel = [[UILabel alloc] init];
        self.priceLabel.backgroundColor = [UIColor clearColor];
        self.priceLabel.textColor = [UIColor grayColor];
        self.priceLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.priceLabel];
        self.detailImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.detailImageView];
        self.countView = [[UIView alloc] init];
        [MCTUIUtils addRoundedBorderToView:self.countView
                           withBorderColor:[UIColor clearColor]
                           andCornerRadius:10];
        self.countView.backgroundColor = [UIColor MCTGreenColor];
        [self.contentView addSubview:self.countView];
        self.countLabel = [[UILabel alloc] init];
        self.countLabel.font = [UIFont systemFontOfSize:11];
        self.countLabel.numberOfLines = 1;
        self.countLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.countLabel.textAlignment = NSTextAlignmentCenter;
        self.countLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.countLabel];
    }

    return self;
}

- (void)setItem:(MCTAdvancedOrderCategoryItemRow *)item currency:(NSString *)currency
{
    self.item = item;
    self.currency = currency;
    self.nameLabel.text = self.item.name;

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setCurrencySymbol:self.currency];
    NSString *currencyAsString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.item.unit_price / 100.0]];

    self.priceLabel.text = [NSString stringWithFormat:@"%@ / %@", currencyAsString, self.item.unit];
    if (self.item.value > 0) {
        self.countLabel.text = [self.view getValueStringForItem:self.item];
        self.countLabel.hidden = NO;
        self.countView.hidden = NO;
        self.detailImageView.hidden = YES;
    } else {
        self.countLabel.hidden = YES;
        self.countView.hidden = YES;
        self.detailImageView.hidden = NO;
        self.detailImageView.image = [UIImage imageWithIcon:@"fa-plus-circle"
                                             backgroundColor:[UIColor clearColor]
                                                   iconColor:[UIColor grayColor]
                                                     andSize:CGSizeMake(18, 18)];
    }
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];
    CGFloat m = 5;
    CGFloat leftMargin = 15;
    CGFloat rightMargin = 18;
    CGRect bounds = self.contentView.bounds;

    CGFloat maxWidthNameAndPriceLabels;
    if (self.item.value > 0) {
        CGSize cSize = [MCTUIUtils sizeForLabel:self.countLabel withWidth:40];
        self.countLabel.width = fmin(cSize.width, 55);
        self.countLabel.height = cSize.height;

        self.countView.width = self.countLabel.width + 12;
        self.countView.height = self.countLabel.height + 6;
        self.countView.centerY = self.contentView.height / 2;
        self.countView.right = bounds.size.width - 18;

        self.countLabel.centerY = self.countView.centerY;
        self.countLabel.centerX = self.countView.centerX;

        maxWidthNameAndPriceLabels = self.countView.left - 2 * m - leftMargin;
    } else {
        self.detailImageView.frame = CGRectMake(bounds.size.width - 18 - 18, m, 18, 18);
        self.detailImageView.centerY = self.contentView.height / 2;
        maxWidthNameAndPriceLabels = self.detailImageView.left - 2 * m - leftMargin;
    }

    if (self.item.has_price) {
        CGFloat maxWidthPriceLabel = maxWidthNameAndPriceLabels / 2;
        CGSize priceSize = [MCTUIUtils sizeForLabel:self.priceLabel withWidth:maxWidthPriceLabel];
        CGFloat maxWidthNameLabel = maxWidthNameAndPriceLabels - fmin(maxWidthPriceLabel, priceSize.width) - 5;
        CGSize nameSize = [MCTUIUtils sizeForLabel:self.nameLabel withWidth:maxWidthNameLabel];

        self.nameLabel.width = fmin(maxWidthNameLabel, nameSize.width);
        self.nameLabel.height = nameSize.height;
        self.nameLabel.centerY = self.contentView.height / 2;
        self.nameLabel.left = leftMargin;

        self.priceLabel.size = priceSize;
        self.priceLabel.centerY = self.contentView.height / 2;
        self.priceLabel.left = self.nameLabel.right + 5;
    } else {
        CGSize nameSize = [MCTUIUtils sizeForLabel:self.nameLabel withWidth:maxWidthNameAndPriceLabels];
        self.nameLabel.width = fmin(maxWidthNameAndPriceLabels, nameSize.width);
        self.nameLabel.height = nameSize.height;
        self.nameLabel.centerY = self.contentView.height / 2;
        self.nameLabel.left = leftMargin;

        [self.priceLabel setHidden:YES];
    }
}

#pragma mark -

@end