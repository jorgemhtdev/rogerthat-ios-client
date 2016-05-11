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

#import "MCTAdvancedOrderItemDetailView.h"
#import "UIImage+FontAwesome.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"
#import "KLCPopup.h"
#import "MCTCachedDownloader.h"

@implementation MCTAdvancedOrderItemDetailView

- (id)init
{
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8.0;

        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:self.nameLabel];

        self.priceLabel = [[UILabel alloc] init];
        self.priceLabel.backgroundColor = [UIColor clearColor];
        self.priceLabel.textColor = [UIColor grayColor];
        self.priceLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.priceLabel];

        self.descriptionLabel = [[UILabel alloc] init];
        self.descriptionLabel.numberOfLines = 0;
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        self.descriptionLabel.textColor = [UIColor blackColor];
        self.descriptionLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.descriptionLabel];

        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];

        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = 5.0;
        self.imageView.layer.borderWidth = 0;

        self.spinner = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self insertSubview:self.spinner aboveSubview:self.imageView];

        self.minValueImageViewControl = [[UIControl alloc] init];
        self.minValueImageView = [[UIImageView alloc] init];
        self.minValueImageView.image = [UIImage imageWithIcon:@"fa-minus-circle"
                                           backgroundColor:[UIColor clearColor]
                                                 iconColor:[UIColor MCTRedColor]
                                                   andSize:CGSizeMake(30, 30)];
        self.minValueImageView.size = CGSizeMake(30,30);
        [self.minValueImageViewControl addSubview:self.minValueImageView];
        [self.minValueImageViewControl addTarget:self action:@selector(onMinValueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.minValueImageViewControl];

        self.valueLabel = [[UILabel alloc] init];
        self.valueLabel.backgroundColor = [UIColor clearColor];
        self.valueLabel.textColor = [UIColor blackColor];
        self.valueLabel.font = [UIFont systemFontOfSize:14];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.valueLabel];

        self.plusValueImageViewControl = [[UIControl alloc] init];
        self.plusValueImageView = [[UIImageView alloc] init];
        self.plusValueImageView.image = [UIImage imageWithIcon:@"fa-plus-circle"
                                              backgroundColor:[UIColor clearColor]
                                                    iconColor:[UIColor MCTGreenColor]
                                                      andSize:CGSizeMake(30, 30)];
        self.plusValueImageView.size = CGSizeMake(30,30);
        [self.plusValueImageViewControl addSubview:self.plusValueImageView];
        [self.plusValueImageViewControl addTarget:self action:@selector(onPlusValueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.plusValueImageViewControl];

        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
        [self addSubview:self.lineView];

        self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.dismissButton setTitleColor:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.dismissButton setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
        [self.dismissButton setTitleColor:[[self.dismissButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [self.dismissButton setTitle:NSLocalizedString(@"Ok", nil) forState:UIControlStateNormal];
        [self.dismissButton addTarget:self action:@selector(dismissPopupButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.dismissButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat contentMargin = 10;
    CGFloat maxWidthContent = self.view.width - 2 * contentMargin;

    self.nameLabel.text = self.item.name;
    CGFloat nameHeight = [MCTUIUtils sizeForLabel:self.nameLabel withWidth:maxWidthContent].height;
    self.nameLabel.frame = CGRectMake(contentMargin, contentMargin, maxWidthContent - 20, nameHeight);

    CGFloat nextHeight = self.nameLabel.bottom + contentMargin;
    if (self.item.has_price) {
        self.priceLabel.text = [self.view getPriceStringForItemWithUnitPrice:self.item.unit_price unit:self.item.unit];
        CGFloat priceHeight = [MCTUIUtils sizeForLabel:self.priceLabel withWidth:maxWidthContent].height;
        self.priceLabel.frame = CGRectMake(contentMargin, self.nameLabel.bottom + 2, maxWidthContent - 20, priceHeight);
        nextHeight = self.priceLabel.bottom + contentMargin;
    }

    self.descriptionLabel.text = self.item.descriptionX;
    CGFloat descriptionHeight = [MCTUIUtils sizeForLabel:self.descriptionLabel withWidth:maxWidthContent].height;
    self.descriptionLabel.frame = CGRectMake(contentMargin, nextHeight, maxWidthContent - 20, descriptionHeight);

    if (![MCTUtils isEmptyOrWhitespaceString:self.item.descriptionX]) {
        nextHeight = self.descriptionLabel.bottom + contentMargin;
    }

    [self.imageView setHidden:YES];
    [self.spinner setHidden:YES];
    if (![MCTUtils isEmptyOrWhitespaceString:self.item.image_url]) {
        self.imageView.left = contentMargin;
        self.imageView.top = nextHeight;
        self.imageView.height = maxWidthContent / 16 * 9;
        self.imageView.width = maxWidthContent;
        self.spinner.frame = self.imageView.frame;
        [self.spinner setHidden:NO];
        [self.spinner startAnimating];

        NSString *filePath = [[MCTCachedDownloader sharedInstance] getCachedFilePathWithUrl:self.item.image_url];
        if (filePath != nil) {
            nextHeight = self.imageView.bottom + contentMargin;
            self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
            [self.imageView setHidden:NO];
            [self.spinner setHidden:YES];
            [self.spinner stopAnimating];
        } else {
            nextHeight = self.spinner.bottom + contentMargin;
        }
    }

    self.minValueImageViewControl.frame = CGRectMake(contentMargin, nextHeight, 44, 44);
    self.minValueImageView.centerY = self.minValueImageViewControl.height / 2;
    self.minValueImageView.centerX = self.minValueImageViewControl.width / 2;

    CGFloat valueWidth = maxWidthContent - 2 * 44 - 10;
    self.valueLabel.frame = CGRectMake(self.minValueImageViewControl.right + 5, nextHeight, valueWidth, 44);
    self.valueLabel.text = [self.view getValueStringForItem:self.item];

    self.plusValueImageViewControl.frame = CGRectMake(self.valueLabel.right + 5, nextHeight, 44, 44);
    self.plusValueImageView.centerY = self.plusValueImageViewControl.height / 2;
    self.plusValueImageView.centerX = self.plusValueImageViewControl.width / 2;

    self.lineView.frame = CGRectMake(0, self.valueLabel.bottom + contentMargin, self.view.width, 0.7);
    self.dismissButton.frame = CGRectMake(contentMargin, self.lineView.bottom, maxWidthContent, 44);

    self.frame = CGRectMake(0, 0, self.view.width, self.dismissButton.bottom);
}

- (void)dismissPopupButtonPressed:(id)sender
{
    T_UI();
    HERE();
    self.view.currentOrderItemDetail = nil;
    [self dismissPresentingPopup];
}

- (void)onMinValueButtonTapped:(id)sender
{
    T_UI();
    HERE();

    [self.view setDefaultValueInResultDictForCategoryId:self.item.categoryId itemId:self.item.idX];
    MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *tmpItem = [[[self.view currentResultDict] objectForKey:self.item.categoryId] objectForKey:self.item.idX];
    tmpItem.value = tmpItem.value - tmpItem.step;
    if (tmpItem.value < 0) {
        tmpItem.value = 0;
    }
    self.item.value = tmpItem.value;

    self.valueLabel.text = [self.view getValueStringForItem:self.item];

    [self.cell setItem:self.item  currency:[self.view advancedOrderTO].currency];
    [self.cell layoutSubviews];
    [self.view.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.categoryIndexPath] withRowAnimation:NO];
    self.view.viewController.rightBarButtonItem.enabled = [self.view numberOfitemsInBasket] > 0;
}

- (void)onPlusValueButtonTapped:(id)sender
{
    T_UI();
    HERE();
    [self.view setDefaultValueInResultDictForCategoryId:self.item.categoryId itemId:self.item.idX];

    MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *tmpItem = [[[self.view currentResultDict] objectForKey:self.item.categoryId] objectForKey:self.item.idX];
    tmpItem.value = tmpItem.value + tmpItem.step;
    self.item.value = tmpItem.value;

    self.valueLabel.text = [self.view getValueStringForItem:self.item];

    [self.cell setItem:self.item currency:[self.view advancedOrderTO].currency];
    [self.cell layoutSubviews];
    [self.view.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.categoryIndexPath] withRowAnimation:NO];
    self.view.viewController.rightBarButtonItem.enabled = [self.view numberOfitemsInBasket] > 0;
}

@end