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

#import "MCTWidget.h"
#import "MCTIntentFramework.h"
#import "MCTAdvancedOrderItemCell.h"
#import "MCTMessageDetailVC.h"

@class MCTAdvancedOrderItemCell;

@interface MCTAdvancedOrderCategoryRow : NSObject

@property (nonatomic, copy) NSString *idX;
@property (nonatomic, copy) NSString *name;

+ (instancetype)instanceWithCategoryId:(NSString *)categoryId name:(NSString *)name;

@end

@interface MCTAdvancedOrderCategoryItemRow : MCT_com_mobicage_models_properties_forms_AdvancedOrderItem {
    NSString *categoryId_;
}

@property (nonatomic, copy) NSString *categoryId;

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
                                 value:(MCTlong)value;

@end

@interface MCTAdvancedOrderView : UIControl <MCTWidget, UIAlertViewDelegate, IMCTIntentReceiver, UITableViewDataSource, UITableViewDelegate> {
    CGFloat width_; 
    NSDictionary *widgetDict_;
    MCTMessageDetailVC<UIAlertViewDelegate, UIActionSheetDelegate> __weak* viewController_;
    UITableView *tableView_;
    NSIndexPath *currentOrderItemDetail_;
}

@property (nonatomic) CGFloat width;
@property (nonatomic, strong) NSDictionary *widgetDict;
@property (nonatomic, weak) MCTMessageDetailVC<UIAlertViewDelegate, UIActionSheetDelegate> *viewController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *currentOrderItemDetail;

- (id)initWithDict:(NSDictionary *)widgetDict
          andWidth:(CGFloat)width
    andColorScheme:(MCTColorScheme)colorScheme
  inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc;

- (CGFloat)height;
- (MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *)result;
- (NSDictionary *)widget;
- (NSMutableDictionary *)currentResultDict;
- (void)createTableViewData;
- (MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO *)advancedOrderTO;
- (NSInteger)numberOfitemsInBasket;
- (void)refreshView;
- (void)setDefaultValueInResultDictForCategoryId:(NSString *)categoryId itemId:(NSString *)itemId;
- (NSString *)getValueStringForItem:(MCTAdvancedOrderCategoryItemRow *)item;
- (NSString *)getPriceStringForItemWithUnitPrice:(MCTlong)unitPrice unit:(NSString *)unit;

@end