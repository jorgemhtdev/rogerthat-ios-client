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

#import "MCTAdvancedOrderBasketCell.h"
#import "UIImage+FontAwesome.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

@implementation MCTAdvancedOrderBasketCell


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

        self.valueLabel = [[UILabel alloc] init];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        self.valueLabel.backgroundColor = [UIColor clearColor];
        self.valueLabel.textColor = [UIColor blackColor];
        self.valueLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.valueLabel];

        self.countView = [[UIView alloc] init];
        [MCTUIUtils addRoundedBorderToView:self.countView
                           withBorderColor:[UIColor clearColor]
                           andCornerRadius:10];
        self.countView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:self.countView];
        self.countLabel = [[UILabel alloc] init];
        self.countLabel.font = [UIFont systemFontOfSize:11];
        self.countLabel.numberOfLines = 1;
        self.countLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.countLabel.textAlignment = NSTextAlignmentCenter;
        self.countLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.countLabel];

        self.minItemImageViewControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 54, 44, 44)];
        [self.minItemImageViewControl addTarget:self action:@selector(onMinItemButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.minItemImageView = [[UIImageView alloc] init];
        self.minItemImageView.image = [UIImage imageWithIcon:@"fa-minus-circle"
                                             backgroundColor:[UIColor clearColor]
                                                   iconColor:[UIColor MCTRedColor]
                                                     andSize:CGSizeMake(30, 30)];
        self.minItemImageView.size = CGSizeMake(30,30);
        self.minItemImageView.centerY = self.minItemImageViewControl.height / 2;
        self.minItemImageView.centerX = self.minItemImageViewControl.width / 2;
        [self.minItemImageViewControl addSubview:self.minItemImageView];
        [self.contentView addSubview:self.minItemImageViewControl];


        self.plusItemImageViewControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 54, 44, 44)];
        [self.plusItemImageViewControl addTarget:self action:@selector(onPlusItemButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.plusItemImageView = [[UIImageView alloc] init];
        self.plusItemImageView.image = [UIImage imageWithIcon:@"fa-plus-circle"
                                              backgroundColor:[UIColor clearColor]
                                                    iconColor:[UIColor MCTGreenColor]
                                                      andSize:CGSizeMake(30, 30)];
        self.plusItemImageView.size = CGSizeMake(30,30);
        self.plusItemImageView.centerY = self.plusItemImageViewControl.height / 2;
        self.plusItemImageView.centerX = self.plusItemImageViewControl.width / 2;
        [self.plusItemImageViewControl addSubview:self.plusItemImageView];
        [self.contentView addSubview:self.plusItemImageViewControl];
    }

    return self;
}

- (NSString *)getValueStringForItem:(MCTAdvancedOrderCategoryBasketRow *)item
{
    if ([MCTUtils isEmptyOrWhitespaceString:item.step_unit]) {
        return [NSString stringWithFormat:@"%lld %@", item.value, item.unit];
    } else {
        return [NSString stringWithFormat:@"%lld %@", item.value, item.step_unit];
    }
}

- (void)setItem:(MCTAdvancedOrderCategoryBasketRow *)item currency:(NSString *)currency view:(MCTAdvancedOrderBasketView *)view
{
    self.item = item;
    self.currency = currency;
    self.view = view;

    self.nameLabel.text = self.item.name;

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setCurrencySymbol:self.currency];
    NSString *currencyAsString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.item.unit_price / 100.0]];

    self.priceLabel.text = [NSString stringWithFormat:@"%@ / %@", currencyAsString, self.item.unit];
    self.valueLabel.text = [self getValueStringForItem:item];
    self.countLabel.text = self.valueLabel.text;
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
    if (self.item.collapsed) {
        self.countView.hidden = NO;
        self.countLabel.hidden = NO;
        CGSize cSize = [MCTUIUtils sizeForLabel:self.countLabel withWidth:40];
        self.countLabel.width = fmin(cSize.width, 55);
        self.countLabel.height = cSize.height;
        self.countView.width = self.countLabel.width + 12;
        self.countView.height = self.countLabel.height + 6;
        self.countView.centerY = self.contentView.height / 2;
        self.countView.right = bounds.size.width - m;

        self.countLabel.centerY = self.countView.centerY;
        self.countLabel.centerX = self.countView.centerX;

        maxWidthNameAndPriceLabels = self.countView.left - 2 * m - leftMargin;
    } else {
        self.countView.hidden = YES;
        self.countLabel.hidden = YES;
        maxWidthNameAndPriceLabels = bounds.size.width - 2 * m;
    }
    self.minItemImageViewControl.frame = CGRectMake(0, 54, 44, 44);
    self.plusItemImageViewControl.frame = CGRectMake(bounds.size.width - 44, 54, 44, 44);


    if (self.item.has_price) {
        CGFloat maxWidthPriceLabel = maxWidthNameAndPriceLabels / 2;
        CGSize priceSize = [MCTUIUtils sizeForLabel:self.priceLabel withWidth:maxWidthPriceLabel];
        CGFloat maxWidthNameLabel = maxWidthNameAndPriceLabels - fmin(maxWidthPriceLabel, priceSize.width) - 5;
        CGSize nameSize = [MCTUIUtils sizeForLabel:self.nameLabel withWidth:maxWidthNameLabel];

        self.nameLabel.width = fmin(maxWidthNameLabel, nameSize.width);
        self.nameLabel.height = nameSize.height;
        self.nameLabel.centerY = 22;
        self.nameLabel.left = 0;

        self.priceLabel.size = priceSize;
        self.priceLabel.centerY = 22;
        self.priceLabel.left = self.nameLabel.right + 5;
    } else {
        CGSize nameSize = [MCTUIUtils sizeForLabel:self.nameLabel withWidth:maxWidthNameAndPriceLabels];
        self.nameLabel.width = fmin(maxWidthNameAndPriceLabels, nameSize.width);
        self.nameLabel.height = nameSize.height;
        self.nameLabel.centerY = 22;
        self.nameLabel.left = 0;

        [self.priceLabel setHidden:YES];
    }

    if (self.item.collapsed) {
        [self.valueLabel setHidden:YES];
        [self.minItemImageViewControl setHidden:YES];
        [self.plusItemImageViewControl setHidden:YES];
    } else {
        [self.valueLabel setHidden:NO];
        [self.minItemImageViewControl setHidden:NO];
        [self.plusItemImageViewControl setHidden:NO];

        CGFloat valueWidth = self.plusItemImageViewControl.left - self.minItemImageViewControl.right - 20;
        self.valueLabel.frame = CGRectMake(self.minItemImageViewControl.right + 10, 54, valueWidth, 44);
    }
}

- (void)onMinItemButtonTapped:(id)sender
{
    T_UI();
    [self.view onMinItemButtonTappedForCell:self row:self.item];
}

- (void)onPlusItemButtonTapped:(id)sender
{
    T_UI();
    [self.view onPlusItemButtonTappedForCell:self row:self.item];
}

#pragma mark -

@end