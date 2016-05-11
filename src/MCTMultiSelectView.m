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

#import "MCTMultiSelectView.h"
#import "MCTUIUtils.h"
#import "MCTComponentFramework.h"

#define MCT_ROW_HEIGHT 44
#define MCT_LBL_FONT [UIFont systemFontOfSize:17]


@interface MCTMultiSelectView ()

- (CGFloat)heightForCellWithLabel:(NSString *)label;

@end


@implementation MCTMultiSelectView


- (id)initWithDict:(NSDictionary *)widgetDict
          andWidth:(CGFloat)width
    andColorScheme:(MCTColorScheme)colorScheme
  inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc
{
    T_UI();
    if (self = [super init]) {
        self.showsAccessoryView = YES;
        self.width = width;
        self.widgetDict = widgetDict;
        self.choices = [widgetDict objectForKey:@"choices"];
        NSArray *defaults = [widgetDict objectForKey:@"values"];
        if (defaults && defaults != MCTNull) {
            self.answers = [NSMutableArray arrayWithArray:defaults];
        } else {
            self.answers = [NSMutableArray arrayWithCapacity:[self.choices count]];
        }

        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        IF_IOS7_OR_GREATER({
            self.tableView.separatorInset = UIEdgeInsetsZero;
        });
        [self addSubview:self.tableView];
        [MCTUIUtils addRoundedBorderToView:self.tableView];
    }
    return self;
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    self.tableView.frame = CGRectMake(0, 0, self.width, [self height]);
}

#pragma mark -
#pragma mark MCTWidget

- (CGFloat)height
{
    T_UI();
    CGFloat h = 0;
    for (NSDictionary *choice in self.choices)
        h += [self heightForCellWithLabel:[choice stringForKey:@"label"]];

    return h;
}

- (MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *)result
{
    T_UI();
    MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *result = \
        [MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO transferObject];
    result.values = self.answers;
    return result;
}

- (NSDictionary *)widget
{
    T_UI();
    [self.widgetDict setValue:self.result.values forKey:@"values"];
    return self.widgetDict;
}


#pragma mark -

- (CGFloat)heightForCellWithLabel:(NSString *)label
{
    T_UI();
    CGFloat w = [[UIScreen mainScreen] applicationFrame].size.width - 40 - (self.showsAccessoryView ? 30 : 0);

    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = MCT_LBL_FONT;
    gettingSizeLabel.text = label;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByClipping;

    CGSize size = [gettingSizeLabel sizeThatFits:CGSizeMake(w, CGFLOAT_MAX)];

    return MAX(MCT_ROW_HEIGHT, size.height + 8);
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    T_UI();
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    return [self.choices count];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return [self heightForCellWithLabel:[[self.choices objectAtIndex:indexPath.row] stringForKey:@"label"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    static NSString *ident = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = MCT_LBL_FONT;
        cell.textLabel.numberOfLines = 0;
    }

    cell.textLabel.text = [[self.choices objectAtIndex:indexPath.row] stringForKey:@"label"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    NSString *value = [[self.choices objectAtIndex:indexPath.row] stringForKey:@"value"];
    if ([self.answers containsObject:value]) {
        [self.answers removeObject:value];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        [self.answers addObject:value];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    NSString *value = [[self.choices objectAtIndex:indexPath.row] stringForKey:@"value"];
    if (self.showsAccessoryView && [self.answers containsObject:value]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.alpha = self.alpha;
}

#pragma mark -

+ (NSString *)valueStringForWidget:(NSDictionary *)widgetDict
{
    T_UI();
    NSArray *selectedValues = [widgetDict objectForKey:@"values"];
    if (selectedValues == nil || selectedValues == MCTNull || [selectedValues count] == 0)
        return nil;

    NSArray *choices = [widgetDict objectForKey:@"choices"];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[choices count]];
    NSMutableArray *labels = [NSMutableArray arrayWithCapacity:[choices count]];
    for (NSDictionary *choice in choices) {
        [values addObject:[choice stringForKey:@"value"]];
        [labels addObject:[choice stringForKey:@"label"]];
    }

    NSMutableString *valueString = [NSMutableString string];
    for (NSString *value in selectedValues) {
        NSInteger i = [values indexOfObject:value];
        if (i == NSNotFound) {
            ERROR(@"Should not come here");
            continue;
        }

        if ([valueString length])
            [valueString appendString:@"\n"];

        [valueString appendString:[labels objectAtIndex:i]];
    }

    return valueString;
}

@end