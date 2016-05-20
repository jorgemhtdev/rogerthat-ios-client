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
#import "MCTFormView.h"
#import "MCTAdvancedOrderView.h"
#import "MCTIntent.h"
#import "MCTMessage.h"
#import "MCTMessageDetailView.h"
#import "MCTMessageScrollView.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

#import "NSData+Base64.h"
#import "TTButtonContent.h"
#import "UIImage+FontAwesome.h"
#import "KLCPopup.h"
#import "MCTAdvancedOrderBasketView.h"
#import "MCTAdvancedOrderItemDetailView.h"
#import "TTImageView.h"

#define MARGIN 10
#define MCT_TAG_ADVANCED_ORDER_VALUE 123

@implementation MCTAdvancedOrderCategoryRow



+ (instancetype)instanceWithCategoryId:(NSString *)categoryId name:(NSString *)name
{
    MCTAdvancedOrderCategoryRow *row = [[MCTAdvancedOrderCategoryRow alloc] init];
    row.idX = categoryId;
    row.name = name;
    return row;
}

@end

@implementation MCTAdvancedOrderCategoryItemRow

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
{
    MCTAdvancedOrderCategoryItemRow *row = [[MCTAdvancedOrderCategoryItemRow alloc] init];
    row.categoryId = categoryId;
    row.idX = itemId;
    row.image_url = imageUrl;
    row.name = name;
    row.descriptionX = descriptionX;
    row.step = step;
    row.step_unit = stepUnit;
    row.step_unit_conversion = stepUnitConversion;
    row.unit = unit;
    row.unit_price = unitPrice;
    row.has_price = hasPrice;
    row.value = value;
    return row;
}

@end

@interface MCTAdvancedOrderView ()

@property (nonatomic, strong) MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO *advancedOrder;
@property (nonatomic, strong) NSMutableDictionary *advancedOrderDictonary;
@property (nonatomic, strong) NSMutableDictionary *resultDictonary;
@property (nonatomic, strong) NSMutableArray *tableViewData;
@property (nonatomic, copy) NSString *activeCategoryId;
@property (nonatomic, strong) KLCPopup *detailPopup;

@end

@implementation MCTAdvancedOrderView


- (void)dealloc
{
    [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
}

- (id)initWithDict:(NSDictionary *)widgetDict
          andWidth:(CGFloat)width
    andColorScheme:(MCTColorScheme)colorScheme
  inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc
{
    T_UI();
    if (self = [super init]) {
        self.width = width;
        self.widgetDict = widgetDict;
        self.viewController = (MCTMessageDetailVC *)vc;

        [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                        forIntentAction:kINTENT_CACHED_FILE_RETRIEVED
                                                                onQueue:[MCTComponentFramework mainQueue]];

        self.advancedOrder = [MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO transferObjectWithDict:widgetDict];
        self.advancedOrderDictonary = [NSMutableDictionary dictionary];
        for (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *category in self.advancedOrder.categories) {
            NSMutableDictionary *items = [NSMutableDictionary dictionary];
            for (MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *item in category.items) {
                [items setObject:item forKey:item.idX];
            }
            [self.advancedOrderDictonary setDict:items forKey:category.idX];
        }
        self.activeCategoryId = nil;

        id result = self.widgetDict[@"value"];
        self.resultDictonary = [NSMutableDictionary dictionary];
        NSArray *categories;
        if (result) {
            categories = [MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO transferObjectWithDict:result].categories;
        } else {
            NSMutableArray *tmpCategories = [NSMutableArray array];
            for (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *category in self.advancedOrder.categories) {
                NSMutableArray *itemsToAdd = [NSMutableArray array];
                for (MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *item in category.items) {
                    if (item.value > 0) {
                        [itemsToAdd addObject:item];
                    }
                }
                if ([itemsToAdd count] > 0) {
                    MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *tmpCategory =
                        [MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory transferObjectWithDict:[category dictRepresentation]];
                    tmpCategory.items = itemsToAdd;
                    [tmpCategories addObject:tmpCategory];
                }
            }
            categories = tmpCategories;
        }

        for (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *category in categories) {
            NSMutableDictionary *items = [NSMutableDictionary dictionary];
            for (MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *item in category.items) {
                [items setObject:item forKey:item.idX];
            }
            [self.resultDictonary setDict:items forKey:category.idX];
        }

        UIImage *shoppingBasketImage = [UIImage imageWithIcon:@"fa-shopping-cart"
                                              backgroundColor:[UIColor clearColor]
                                                    iconColor:self.tintColor
                                                      andSize:CGSizeMake(24, 24)];


        UIBarButtonItem *basketButton = [[UIBarButtonItem alloc] initWithImage:shoppingBasketImage
                                                            landscapeImagePhone:shoppingBasketImage
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(onBasketButtonClicked:)];

        basketButton.enabled = [self numberOfitemsInBasket] > 0;
        self.viewController.rightBarButtonItem = basketButton;
        [self createTableView];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    T_UI();
    [super setEnabled:enabled];
    self.tableView.hidden = !enabled;
}

- (NSMutableDictionary *)currentResultDict
{
    return self.resultDictonary;
}

- (MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO *)advancedOrderTO
{
    return self.advancedOrder;
}

- (void)createTableViewData
{
    self.tableViewData = [NSMutableArray array];

    for (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *category in self.advancedOrder.categories) {
        [self.tableViewData addObject:[MCTAdvancedOrderCategoryRow instanceWithCategoryId:category.idX name:category.name]];
        if (self.activeCategoryId == category.idX) {
            for (MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *item in category.items) {
                if([self.resultDictonary containsKey:category.idX]) {
                    if ([[self.resultDictonary objectForKey:category.idX] containsKey:item.idX]) {
                        MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *tmpItem = [[self.resultDictonary objectForKey:category.idX] objectForKey:item.idX];
                        item.value = tmpItem.value;
                    }
                }

                [self.tableViewData addObject:[MCTAdvancedOrderCategoryItemRow instanceWithCategoryId:category.idX
                                                                                               itemId:item.idX
                                                                                             imageUrl:item.image_url
                                                                                                 name:item.name
                                                                                          description:item.descriptionX
                                                                                                 step:item.step
                                                                                             stepUnit:item.step_unit
                                                                                  stepUnitConversion:item.step_unit_conversion
                                                                                                 unit:item.unit
                                                                                            unitPrice:item.unit_price
                                                                                             hasPrice:item.has_price                                                                                              value:item.value]];
            }
        }
    }
}

- (void)createTableView
{
    T_UI();
    [self createTableViewData];
    if (self.tableView == nil) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.separatorInset = UIEdgeInsetsZero;
        self.tableView.estimatedRowHeight = 44;
        IF_IOS8_OR_GREATER({
            self.tableView.layoutMargins = UIEdgeInsetsZero;
        });
        [MCTUIUtils addRoundedBorderToView:self.tableView
                           withBorderColor:self.tableView.separatorColor
                           andCornerRadius:5];
        [self addSubview:self.tableView];
    }
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    if (self.enabled) {
        CGFloat h = 0;
        for (NSInteger i = 0; i < [self tableView:self.tableView numberOfRowsInSection:0]; i++) {
            h += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        }

        self.tableView.frame = CGRectMake(0, 0, self.width, h);
        self.tableView.centerX = self.width / 2;
    }
}


- (void)refreshView
{
    T_UI();
    MCTFormView *formView = (MCTFormView *) [MCTUIUtils superViewWithClass:[MCTFormView class]
                                                                   forView:self];
    MCTMessageDetailView *msgDetailView = (MCTMessageDetailView *) [MCTUIUtils superViewWithClass:[MCTMessageDetailView class]
                                                                                          forView:self];
    if (!formView || !msgDetailView) {
        @throw [NSException exceptionWithName:@"Did not find MCTFormView/MCTMessageDetailView in view hierarchy!"
                                       reason:nil
                                     userInfo:nil];
    }
    [formView layoutSubviews];
    [msgDetailView setNeedsLayout];
}

#pragma mark - MCTWidget

- (CGFloat)height
{
    T_UI();
    if (self.enabled) {
        return self.tableView.bottom + MARGIN;
    } else {
        return MARGIN;
    }
}

- (MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *)result
{
    MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *result =
        [MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO transferObject];
    result.currency = self.advancedOrder.currency;

    NSMutableArray *categories = [NSMutableArray array];
    for (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *category in self.advancedOrder.categories) {
        NSDictionary *categoryDict = self.resultDictonary[category.idX];
        if (categoryDict) {
            NSMutableArray *itemsToAdd = [NSMutableArray array];
            for (MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *item in category.items) {
                if (categoryDict[item.idX] != nil && item.value > 0) {
                    [itemsToAdd addObject:item];
                }
            }
            if ([itemsToAdd count] > 0) {
                // Copy obj
                MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *tmpCategory =
                    [MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory transferObjectWithDict:[category dictRepresentation]];
                tmpCategory.items = itemsToAdd;
                [categories addObject:tmpCategory];
            }
        }
    }

    result.categories = categories;
    return result;
}

- (NSDictionary *)widget
{
    MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *result = [self result];
    [self.widgetDict setValue:[result dictRepresentation] forKey:@"value"];
    return self.widgetDict;
}

+ (NSString *)valueStringForWidget:(NSDictionary *)widgetDict
{
    T_UI();
    NSMutableArray *stringBuilder = [NSMutableArray array];
    MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *result = [MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO transferObjectWithDict:widgetDict[@"value"]];
    for (NSInteger i = 0; i < [result.categories count]; i++) {
        MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *category = [result.categories objectAtIndex:i];
        if (i != 0) {
            [stringBuilder addObject:@""];
        }
        [stringBuilder addObject:[NSString stringWithFormat:@"%@: ", category.name]];
        for (MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *item in category.items) {
            NSString *unit = item.unit;
            if (![MCTUtils isEmptyOrWhitespaceString:item.step_unit]) {
                unit = item.step_unit;
            }
            [stringBuilder addObject:[NSString stringWithFormat:@"\t* %@, %lld %@", item.name, item.value, unit]];
        }
    }
    return [stringBuilder componentsJoinedByString:@"\n"];
}

#pragma mark - UITableViewDataSource / UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    return [self.tableViewData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    id tableViewRow = [self.tableViewData objectAtIndex:indexPath.row];
    if ([tableViewRow isKindOfClass:[MCTAdvancedOrderCategoryRow class]]) {
        MCTAdvancedOrderCategoryRow *row = (MCTAdvancedOrderCategoryRow *)tableViewRow;
        NSString *identifier = @"c";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.numberOfLines = 0;
        }

        UIColor *accessoryColor = [UIColor blackColor];
        if([self.resultDictonary containsKey:row.idX]) {
            for (NSString *itemId in [self.resultDictonary objectForKey:row.idX]) {
                MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *item = [[self.resultDictonary objectForKey:row.idX] objectForKey:itemId];
                if (item.value > 0) {
                    accessoryColor = [UIColor MCTGreenColor];
                    break;
                }
            }
        }
        if (self.activeCategoryId == row.idX) {
            cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageWithIcon:@"fa-angle-up"
                                                                              backgroundColor:[UIColor clearColor]
                                                                                    iconColor:accessoryColor
                                                                                      andSize:CGSizeMake(24, 24)]];
        } else {
            cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageWithIcon:@"fa-angle-down"
                                                                              backgroundColor:[UIColor clearColor]
                                                                                    iconColor:accessoryColor
                                                                                      andSize:CGSizeMake(24, 24)]];
        }

        [cell.accessoryView setFrame:CGRectMake(0, 0, 24, 24)];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", row.name];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.detailTextLabel.text = @"";
        return cell;
    } else {
        MCTAdvancedOrderCategoryItemRow *row = (MCTAdvancedOrderCategoryItemRow *)tableViewRow;
        NSString *identifier = @"i";
        MCTAdvancedOrderItemCell *cell = (MCTAdvancedOrderItemCell *) [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[MCTAdvancedOrderItemCell alloc] initWithReuseIdentifier:identifier];
        }
        [cell setView:self];
        [cell setItem:row currency:self.advancedOrder.currency];
        return cell;
    }
}

- (void)scrollToCategory:(MCTAdvancedOrderCategoryRow *)row
           withIndexPath:(NSIndexPath *)indexPath
               tableView:(UITableView *)tableView
{
    T_UI();
    CGFloat offset = -10;

    CGFloat tableViewHeightBeforeRendering = tableView.height;
    CGFloat tableViewHeightAfterRendering = 44 * self.advancedOrder.categories.count;
    for (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *category in self.advancedOrder.categories) {
        if (category.idX == self.activeCategoryId) {
            tableViewHeightAfterRendering += 44 * category.items.count;
            break;
        } else {
            offset += 44;
        }
    }

    UIView *v = [tableView cellForRowAtIndexPath:indexPath];
    while (v && ![v isKindOfClass:[MCTMessageScrollView class]]) {
        v = v.superview;
        offset += v.top;
    }
    UIScrollView *scrollView = (UIScrollView *) v;
    offset -= scrollView.contentInset.top;

    CGFloat availableHeight = [MCTUIUtils availableSizeForViewWithController:self.viewController].height;
    CGFloat visibleContentHeight = scrollView.contentSize.height - (scrollView.height - availableHeight) - offset + tableViewHeightAfterRendering - tableViewHeightBeforeRendering;

    if (visibleContentHeight < availableHeight) {
        [[MCTComponentFramework intentFramework]
         broadcastIntent:[MCTIntent intentWithAction:kINTENT_MESSAGE_DETAIL_SCROLL_DOWN]];
    } else {
        [scrollView setContentOffset:CGPointMake(0, offset)
                            animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id tableViewRow = [self.tableViewData objectAtIndex:indexPath.row];
    if ([tableViewRow isKindOfClass:[MCTAdvancedOrderCategoryRow class]]) {
        MCTAdvancedOrderCategoryRow *row = (MCTAdvancedOrderCategoryRow *)tableViewRow;
        if (self.activeCategoryId == row.idX) {
            self.activeCategoryId = nil;
        } else {
            self.activeCategoryId = row.idX;
        }

        if (self.activeCategoryId) {
            // Scroll up, such that there is at most as possible visible for the section.
            [self scrollToCategory:row withIndexPath:indexPath tableView:tableView];
        }

        [self createTableViewData];
        [tableView reloadData];
        [self refreshView];
    } else {
        id tableViewRow = [self.tableViewData objectAtIndex:indexPath.row];
        MCTAdvancedOrderCategoryItemRow *row = (MCTAdvancedOrderCategoryItemRow *)tableViewRow;
        if (![self.currentOrderItemDetail isEqual:indexPath]) {
            self.currentOrderItemDetail = indexPath;
            [self showOrderItemDetailForRow:row indexPath:indexPath];
        }
    }
}

-(void)showOrderItemDetailForRow:(MCTAdvancedOrderCategoryItemRow *)row indexPath:(NSIndexPath *)indexPath
{
    MCTAdvancedOrderItemCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSIndexPath *categoryIndexPath = nil;
    for (int i = 0; i < [self.tableViewData count]; i++) {
        id r = [self.tableViewData objectAtIndex:i];
        if ([r isKindOfClass:[MCTAdvancedOrderCategoryRow class]]) {
            MCTAdvancedOrderCategoryRow *tmpRow = (MCTAdvancedOrderCategoryRow *)r;
            if (row.categoryId == tmpRow.idX) {
                categoryIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                break;
            }
        }
    }
    if (!categoryIndexPath) {
        return;
    }

    if([self.resultDictonary containsKey:row.categoryId]) {
        if ([[self.resultDictonary objectForKey:row.categoryId] containsKey:row.idX]) {
            MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *tmpItem = [[self.resultDictonary objectForKey:row.categoryId] objectForKey:row.idX];
            row.value = tmpItem.value;
        }

    }
    if (row.value == 0) {
        row.value = row.step;

        [self setDefaultValueInResultDictForCategoryId:row.categoryId itemId:row.idX];
        MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *tmpItem = [[self.resultDictonary objectForKey:row.categoryId] objectForKey:row.idX];
        tmpItem.value = row.value;
        self.viewController.rightBarButtonItem.enabled = [self numberOfitemsInBasket] > 0;


        [cell setItem:row  currency:[self advancedOrderTO].currency];
        [cell layoutSubviews];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:categoryIndexPath] withRowAnimation:NO];
    }

    MCTAdvancedOrderItemDetailView *advancedItemDetailView = [[MCTAdvancedOrderItemDetailView alloc] init];
    [advancedItemDetailView setView:self];
    [advancedItemDetailView setItem:row];
    [advancedItemDetailView setCell:cell];
    [advancedItemDetailView setCategoryIndexPath:categoryIndexPath];


    self.detailPopup = [KLCPopup popupWithContentView:advancedItemDetailView
                                             showType:KLCPopupShowTypeFadeIn
                                          dismissType:KLCPopupDismissTypeFadeOut
                                             maskType:KLCPopupMaskTypeDimmed
                             dismissOnBackgroundTouch:YES
                                dismissOnContentTouch:NO];

    [self.detailPopup show];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return 44;
}

- (void)onBasketButtonClicked:(id)button
{
    T_UI();
    HERE();
    if (self.activeCategoryId != nil) {
        self.activeCategoryId = nil;
        [self createTableViewData];
        [self.tableView reloadData];
        [self refreshView];
    }

    MCTAdvancedOrderBasketView *advancedBasketView = [[MCTAdvancedOrderBasketView alloc] init];
    [advancedBasketView setView:self];
    [advancedBasketView createBasketTableViewData];
    self.detailPopup = [KLCPopup popupWithContentView:advancedBasketView
                                             showType:KLCPopupShowTypeFadeIn
                                          dismissType:KLCPopupDismissTypeFadeOut
                                             maskType:KLCPopupMaskTypeDimmed
                             dismissOnBackgroundTouch:YES
                                dismissOnContentTouch:NO];

    [self.detailPopup show];
}

- (NSInteger)numberOfitemsInBasket
{
    NSInteger count = 0;
    if ([self.resultDictonary count] > 0) {
        for (NSString *categoryKey in [self.resultDictonary allKeys]) {
            for (NSString *itemKey in [[self.resultDictonary objectForKey:categoryKey] allKeys]) {
                MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *tmpItem = [[self.resultDictonary objectForKey:categoryKey] objectForKey:itemKey];
                if (tmpItem.value > 0) {
                    count = count + 1;
                }
            }
        }
    }
    return count;
}

- (void)setDefaultValueInResultDictForCategoryId:(NSString *)categoryId itemId:(NSString *)itemId
{
    if(![self.resultDictonary containsKey:categoryId]) {
        [self.resultDictonary setDict:[NSDictionary dictionary] forKey:categoryId];
    }

    if (![[self.resultDictonary objectForKey:categoryId] containsKey:itemId]) {
        MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *item = [[self.advancedOrderDictonary objectForKey:categoryId] objectForKey:itemId];
        NSMutableDictionary *items = [NSMutableDictionary dictionaryWithDictionary:[self.resultDictonary objectForKey:categoryId]];
        [items setObject:item forKey:itemId];
        [self.resultDictonary setDict:items forKey:categoryId];
    }
}

- (NSString *)getValueStringForItem:(MCTAdvancedOrderCategoryItemRow *)item
{
    if ([MCTUtils isEmptyOrWhitespaceString:item.step_unit]) {
        return [NSString stringWithFormat:@"%lld %@", item.value, item.unit];
    } else {
        return [NSString stringWithFormat:@"%lld %@", item.value, item.step_unit];
    }
}

- (NSString *)getPriceStringForItemWithUnitPrice:(MCTlong)unitPrice unit:(NSString *)unit
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setCurrencySymbol:self.advancedOrder.currency];
    NSString *currencyAsString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:unitPrice / 100.0]];
    return [NSString stringWithFormat:@"%@ / %@", currencyAsString, unit];
}

# pragma mark - MCTIntent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_CACHED_FILE_RETRIEVED) {
        if (self.currentOrderItemDetail != nil) {
            id tableViewRow = [self.tableViewData objectAtIndex:self.currentOrderItemDetail.row];
            MCTAdvancedOrderCategoryItemRow *row = (MCTAdvancedOrderCategoryItemRow *)tableViewRow;

            if (![MCTUtils isEmptyOrWhitespaceString:row.image_url]) {
                NSString *urlString = [intent stringForKey:@"url"];
                if ([row.image_url isEqualToString:urlString])  {
                    [self.detailPopup.contentView layoutSubviews];
                }
            }
        }
    }
}

@end