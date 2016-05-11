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
#import "MCTAdvancedOrderBasketCell.h"

@class MCTAdvancedOrderView;
@class MCTAdvancedOrderBasketCell;

@interface MCTAdvancedOrderCategoryBasketRow : MCT_com_mobicage_models_properties_forms_AdvancedOrderItem

@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic) BOOL      collapsed;

+ (instancetype)instanceWithCategoryId:(NSString *)categoryId
                                itemId:(NSString *)itemId
                              imageUrl:(NSString *)imageUrl
                                  name:(NSString *)name
                           description:(NSString *)descriptionX
                                  step:(MCTlong)step
                              stepUnit:(NSString *)stepUnit
                   stepUnitConversion:(MCTlong)stepUnitConversion
                                  unit:(NSString *)unit
                             unitPrice:(MCTlong)unitPrice
                              hasPrice:(BOOL)hasPrice
                                 value:(MCTlong)value
                             collapsed:(BOOL)collapsed;

@end

@interface MCTAdvancedOrderBasketView : UIView<UITableViewDataSource, UITableViewDelegate> {
    MCTAdvancedOrderView *__weak view_;

    UILabel *titleLabel_;
    UITableView *itemsTableView_;
    UIView *lineView_;
    UIButton *continueShoppingButton_;
    UIView *splitLineView_;
    UIButton *submitButton_;
}

@property (nonatomic, weak) MCTAdvancedOrderView *view;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *itemsTableView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *continueShoppingButton;
@property (nonatomic, strong) UIView *splitLinelineView;
@property (nonatomic, strong) UIButton *submitButton;

- (void)createBasketTableViewData;

- (void)onMinItemButtonTappedForCell:(MCTAdvancedOrderBasketCell *)cell row:(MCTAdvancedOrderCategoryBasketRow *)row;
- (void)onPlusItemButtonTappedForCell:(MCTAdvancedOrderBasketCell *)cell row:(MCTAdvancedOrderCategoryBasketRow *)row;

@end