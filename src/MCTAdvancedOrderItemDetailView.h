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

@interface MCTAdvancedOrderItemDetailView : UIView

@property (nonatomic, weak) MCTAdvancedOrderView *view;
@property (nonatomic, strong) MCTAdvancedOrderCategoryItemRow *item;
@property (nonatomic, strong) MCTAdvancedOrderItemCell *cell;
@property (nonatomic, strong) NSIndexPath *categoryIndexPath;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIControl *minValueImageViewControl;
@property (nonatomic, strong) UIImageView *minValueImageView;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UIControl *plusValueImageViewControl;
@property (nonatomic, strong) UIImageView *plusValueImageView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *dismissButton;

@end