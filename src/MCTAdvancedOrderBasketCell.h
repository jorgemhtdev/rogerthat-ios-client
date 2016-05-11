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

#import "MCTAdvancedOrderView.h"
#import "MCTAdvancedOrderBasketView.h"


@class MCTAdvancedOrderCategoryBasketRow;
@class MCTAdvancedOrderBasketView;

@interface MCTAdvancedOrderBasketCell : UITableViewCell 

@property (nonatomic, strong) MCTAdvancedOrderCategoryBasketRow *item;
@property (nonatomic, copy)   NSString *currency;
@property (nonatomic, weak) MCTAdvancedOrderBasketView *view;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UIView *countView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIControl *minItemImageViewControl;
@property (nonatomic, strong) UIImageView *minItemImageView;
@property (nonatomic, strong) UIControl *plusItemImageViewControl;
@property (nonatomic, strong) UIImageView *plusItemImageView;

- (id)initWithReuseIdentifier:(NSString *)identifier;
- (void)setItem:(MCTAdvancedOrderCategoryBasketRow *)item currency:(NSString *)currency view:(MCTAdvancedOrderBasketView *)view;

@end