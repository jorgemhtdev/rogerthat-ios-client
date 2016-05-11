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

#import "MCTSingleSelectView.h"
#import "MCTJSONUtils.h"
#import "MCTUtils.h"
#import "MCTComponentFramework.h"

@implementation MCTSingleSelectView

- (id)initWithDict:(NSDictionary *)widgetDict
          andWidth:(CGFloat)width
    andColorScheme:(MCTColorScheme)colorScheme
  inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc
{
    if (self = [super initWithDict:widgetDict andWidth:width andColorScheme:colorScheme inViewController:vc]) {
        self.showsAccessoryView = NO;
        NSString *defaultValue = [widgetDict containsKey:@"value"] ? [widgetDict stringForKey:@"value"] : MCTNull;
        if (![MCTUtils isEmptyOrWhitespaceString:defaultValue]) {
            [self.answers addObject:defaultValue];
        }
    }
    return self;
}

#pragma mark -
#pragma mark MCTWidget

- (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)result
{
    T_UI();
    MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *result = [MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO transferObject];
    result.value = [self.answers count] ? [self.answers objectAtIndex:0] : nil;
    return result;
}

- (NSDictionary *)widget
{
    T_UI();
    [self.widgetDict setValue:self.result.value forKey:@"value"];
    return self.widgetDict;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    // First deselect other answers
    for (NSString *otherAnswer in [NSArray arrayWithArray:self.answers]) {
        for (int i = 0; i < [self.choices count]; i++) {
            if ([otherAnswer isEqualToString:[[self.choices objectAtIndex:i] stringForKey:@"value"]]) {
                [self.answers removeObject:otherAnswer];

                NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                UITableViewCell *otherCell = [tableView cellForRowAtIndexPath:otherIndexPath];
                if (otherCell) {
                    otherCell.selected = NO;
                }
                break;
            }
        }
    }

    NSString *value = [[self.choices objectAtIndex:indexPath.row] stringForKey:@"value"];
    if ([self.answers containsObject:value]) {
        [self.answers removeObject:value];
    } else {
        [self.answers addObject:value];
    }

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = [self.answers containsObject:value];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    NSString *value = [[self.choices objectAtIndex:indexPath.row] stringForKey:@"value"];
    cell.selected = [self.answers containsObject:value];
    cell.textLabel.alpha = self.alpha;
}

#pragma mark -

+ (NSString *)valueStringForWidget:(NSDictionary *)widgetDict
{
    T_UI();
    NSString *value = [widgetDict objectForKey:@"value"];
    if ([MCTUtils isEmptyOrWhitespaceString:value])
        return nil;

    NSArray *choices = [widgetDict objectForKey:@"choices"];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[choices count]];
    NSMutableArray *labels = [NSMutableArray arrayWithCapacity:[choices count]];
    for (NSDictionary *choice in choices) {
        [values addObject:[choice stringForKey:@"value"]];
        [labels addObject:[choice stringForKey:@"label"]];
    }

    NSInteger i = [values indexOfObject:value];
    if (i == NSNotFound) {
        ERROR(@"Should not come here");
        return nil;
    }

    return [labels objectAtIndex:i];
}

@end