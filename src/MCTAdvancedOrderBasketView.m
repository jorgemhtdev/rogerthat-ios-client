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

#import "MCTAdvancedOrderBasketView.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"
#import "KLCPopup.h"
#import "UIImage+FontAwesome.h"
#import "MCTFormView.h"

@implementation MCTAdvancedOrderCategoryBasketRow

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
                             collapsed:(BOOL)collapsed
{
    MCTAdvancedOrderCategoryBasketRow *row = [[MCTAdvancedOrderCategoryBasketRow alloc] init];
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
    row.collapsed = collapsed;
    return row;
}

@end

@interface MCTAdvancedOrderBasketView ()

@property (nonatomic, strong) NSMutableArray *basketTableViewData;
@property (nonatomic) NSInteger activeBasketIndex;

@end

@implementation MCTAdvancedOrderBasketView




- (id)init
{
    if (self = [super init]) {
        self.activeBasketIndex = -1;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8.0;

        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
        self.titleLabel.text = NSLocalizedString(@"Shopping basket", nil);
        [self addSubview:self.titleLabel];

        self.itemsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.itemsTableView.dataSource = self;
        self.itemsTableView.delegate = self;
        self.itemsTableView.bounces = NO;
        self.itemsTableView.separatorInset = UIEdgeInsetsZero;
        self.itemsTableView.estimatedRowHeight = 44;
        [self addSubview:self.itemsTableView];

        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
        [self addSubview:self.lineView];

        self.submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.submitButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.submitButton.titleLabel.numberOfLines = 0;
        self.submitButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.submitButton setTitleColor:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.submitButton setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
        self.submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [self.submitButton addTarget:self action:@selector(submitBasketButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.submitButton];

        self.splitLinelineView = [[UIView alloc] init];
        self.splitLinelineView.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
        [self addSubview:self.splitLinelineView];

        self.continueShoppingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.continueShoppingButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.continueShoppingButton.titleLabel.numberOfLines = 0;
        self.continueShoppingButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.continueShoppingButton setTitleColor:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.continueShoppingButton setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
        self.continueShoppingButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [self.continueShoppingButton setTitle:NSLocalizedString(@"Continue shopping", nil) forState:UIControlStateNormal];
        [self.continueShoppingButton addTarget:self action:@selector(dismissPopupButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.continueShoppingButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat maxPopupHeight = [[UIScreen mainScreen] applicationFrame].size.height - 50;

    CGFloat contentMargin = 10;
    CGFloat maxWidthContent = self.view.width - 2 * contentMargin;

    CGFloat titleHeight = [MCTUIUtils sizeForLabel:self.titleLabel withWidth:maxWidthContent].height;
    self.titleLabel.frame = CGRectMake(contentMargin, contentMargin, maxWidthContent - 20, titleHeight);

    CGFloat buttonWidth = self.view.width / 2 - 1;
    CGFloat submitButtonHeight = [MCTUIUtils sizeForLabel:self.submitButton.titleLabel withWidth:buttonWidth].height;
    CGFloat continueShoppingButtonHeight = [MCTUIUtils sizeForLabel:self.continueShoppingButton.titleLabel withWidth:buttonWidth].height;

    CGFloat minRequiredButtonsHeight = fmax(submitButtonHeight, continueShoppingButtonHeight);
    if (minRequiredButtonsHeight < 44) {
        minRequiredButtonsHeight = 44;
    } else {
        minRequiredButtonsHeight = minRequiredButtonsHeight + 10;
    }

    MCTFormView *formView = (MCTFormView *) [MCTUIUtils superViewWithClass:[MCTFormView class]
                                                                   forView:self.view];
    [self.submitButton setTitle:[formView positiveButtonText] forState:UIControlStateNormal];

    CGFloat maxTableViewHeight = maxPopupHeight - self.titleLabel.bottom + contentMargin - minRequiredButtonsHeight - contentMargin - 1;

    CGFloat h = 0;
    for (NSInteger i = 0; i < [self tableView:self.itemsTableView numberOfRowsInSection:0]; i++) {
        h += [self tableView:self.itemsTableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    h = fmin(h, maxTableViewHeight);
    self.itemsTableView.frame = CGRectMake(contentMargin, self.titleLabel.bottom + contentMargin, maxWidthContent, h);

    self.lineView.frame = CGRectMake(0, self.itemsTableView.bottom + contentMargin, self.view.width, 0.7);

    self.submitButton.frame = CGRectMake(0, self.lineView.bottom, buttonWidth, minRequiredButtonsHeight);
    self.splitLinelineView.frame = CGRectMake(self.submitButton.right, self.lineView.bottom, 0.7, minRequiredButtonsHeight);
    self.continueShoppingButton.frame = CGRectMake(self.splitLinelineView.right, self.lineView.bottom, buttonWidth, minRequiredButtonsHeight);
    self.frame = CGRectMake(0, 0, self.view.width, self.continueShoppingButton.bottom);
}

#pragma mark - UITableViewDataSource / UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    return [self.basketTableViewData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTAdvancedOrderCategoryBasketRow *row = [self.basketTableViewData objectAtIndex:indexPath.row];
    NSString *identifier = @"b";
    MCTAdvancedOrderBasketCell *cell = (MCTAdvancedOrderBasketCell *) [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MCTAdvancedOrderBasketCell alloc] initWithReuseIdentifier:identifier];
    }
    [cell setItem:row currency:[self.view advancedOrderTO].currency view:self];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MCTAdvancedOrderCategoryBasketRow *row = [self.basketTableViewData objectAtIndex:indexPath.row];
    if (self.activeBasketIndex == indexPath.row) {
        self.activeBasketIndex = -1;
        row.collapsed = YES;
    } else {
        if (self.activeBasketIndex != -1) {
            MCTAdvancedOrderCategoryBasketRow *oldRow = [self.basketTableViewData objectAtIndex:self.activeBasketIndex];
            oldRow.collapsed = YES;
        }
        self.activeBasketIndex = indexPath.row;
        row.collapsed = NO;
    }
    [tableView reloadData];
    [self layoutSubviews];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTAdvancedOrderCategoryBasketRow *row = [self.basketTableViewData objectAtIndex:indexPath.row];
    if(row.collapsed) {
        return 44;
    } else {
        return 100;
    }
}

- (void)createBasketTableViewData
{
    self.basketTableViewData = [NSMutableArray array];

    NSInteger index = 0;
    for (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *category in [self.view advancedOrderTO].categories) {
        if([[self.view currentResultDict] containsKey:category.idX]) {
            for (MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *item in category.items) {
                if ([[[self.view currentResultDict] objectForKey:category.idX] containsKey:item.idX]) {
                    MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *tmpItem = [[[self.view currentResultDict] objectForKey:category.idX] objectForKey:item.idX];
                    if (tmpItem.value > 0) {
                        BOOL collapsed = index != self.activeBasketIndex;
                        [self.basketTableViewData addObject:[MCTAdvancedOrderCategoryBasketRow instanceWithCategoryId:category.idX
                                                                                                               itemId:item.idX
                                                                                                             imageUrl:item.image_url
                                                                                                                 name:item.name
                                                                                                          description:item.descriptionX
                                                                                                                 step:item.step
                                                                                                             stepUnit:item.step_unit
                                                                                                  stepUnitConversion:item.step_unit_conversion
                                                                                                                 unit:item.unit
                                                                                                            unitPrice:item.unit_price
                                                                                                             hasPrice:item.has_price
                                                                                                                value:tmpItem.value
                                                                                                            collapsed:collapsed]];
                        index += 1;
                    }
                }
            }
        }
    }
}

- (NSInteger)countCurrentBasketTableViewData
{
    NSInteger count = 0;
    for (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *category in [self.view advancedOrderTO].categories) {
        if([[self.view currentResultDict] containsKey:category.idX]) {
            for (MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *item in category.items) {
                if ([[[self.view currentResultDict] objectForKey:category.idX] containsKey:item.idX]) {
                    MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *tmpItem = [[[self.view currentResultDict] objectForKey:category.idX] objectForKey:item.idX];
                    if (tmpItem.value > 0) {
                        count += 1;
                    }
                }
            }
        }
    }
    return count;
}

- (void)resetBasketItems
{
    self.activeBasketIndex = -1;
    [self createBasketTableViewData];
    if ([self.basketTableViewData count] > 0) {
        [self.itemsTableView reloadData];
        [self layoutSubviews];
    } else {
        [self dismissPresentingPopup];
        self.view.viewController.rightBarButtonItem.enabled = [self.basketTableViewData count] > 0;
    }
}

- (void)onMinItemButtonTappedForCell:(MCTAdvancedOrderBasketCell *)cell row:(MCTAdvancedOrderCategoryBasketRow *)row
{
    T_UI();
    HERE();
    MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *tmpItem = [[[self.view currentResultDict] objectForKey:row.categoryId] objectForKey:row.idX];
    tmpItem.value = tmpItem.value - tmpItem.step;
    if (tmpItem.value <= 0) {
        tmpItem.value = 0;
        self.view.viewController.rightBarButtonItem.enabled = [self countCurrentBasketTableViewData] > 0;
    }
    row.value = tmpItem.value;
    [cell setItem:row  currency:[self.view advancedOrderTO].currency view:self];
    [cell layoutSubviews];

    if (tmpItem.value == 0) {
        [self.view createTableViewData];
        [self.view.tableView reloadData];
        [self.view refreshView];
    }
}

- (void)onPlusItemButtonTappedForCell:(MCTAdvancedOrderBasketCell *)cell row:(MCTAdvancedOrderCategoryBasketRow *)row
{
    T_UI();
    HERE();
    MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *tmpItem = [[[self.view currentResultDict] objectForKey:row.categoryId] objectForKey:row.idX];
    BOOL shouldRefreshCategoriesTableView = tmpItem.value == 0;
    tmpItem.value = tmpItem.value + tmpItem.step;
    row.value = tmpItem.value;
    self.view.viewController.rightBarButtonItem.enabled = YES;
    [cell setItem:row  currency:[self.view advancedOrderTO].currency view:self];
    [cell layoutSubviews];

    if (shouldRefreshCategoriesTableView) {
        [self.view createTableViewData];
        [self.view.tableView reloadData];
        [self.view refreshView];
    }
}

- (void)dismissPopupButtonPressed:(id)sender
{
    T_UI();
    HERE();
    [self dismissPresentingPopup];
}

- (void)submitBasketButtonPressed:(id)sender
{
    T_UI();
    HERE();
    [self dismissPresentingPopup];
    MCTFormView *formView = (MCTFormView *) [MCTUIUtils superViewWithClass:[MCTFormView class]
                                                                   forView:self.view];

    [formView excecuteButtonTapped:formView.positiveBtn andShouldValidateResult:YES];
}

@end