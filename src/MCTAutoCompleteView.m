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

#import "MCTAutoCompleteView.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"
#import "MCTComponentFramework.h"

#define MARGIN 10


@interface MCTAutoCompleteView ()

- (void)toggleTableView:(BOOL)visible;
- (BOOL)shouldShowChoicesTable;

@end



@implementation MCTAutoCompleteView



- (id)initWithDict:(NSDictionary *)widgetDict
          andWidth:(CGFloat)width
    andColorScheme:(MCTColorScheme)colorScheme
  inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc
{
    T_UI();
    if (self = [super initWithDict:widgetDict andWidth:width andColorScheme:colorScheme inViewController:vc]) {
        self.choices = [widgetDict objectForKey:@"choices"];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.hidden = YES;
        IF_IOS7_OR_GREATER({
            self.tableView.separatorInset = UIEdgeInsetsZero;
        });
        [self addSubview:self.tableView];
        [MCTUIUtils addRoundedBorderToView:self.tableView withBorderColor:[UIColor lightGrayColor] andCornerRadius:5];

        // Note: removeObserver happens in MCTMessageDetailView
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:self.textField];
        [self setNeedsLayout];
    }
    return self;
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    CGRect tvFrame = self.textField.frame;
    tvFrame.origin.y = CGRectGetMaxY(tvFrame) - 6;
    tvFrame.size.height = 123;
    self.tableView.frame = tvFrame;
}

- (void)onBackgroundTapped:(id)sender
{
    T_UI();
    [super onBackgroundTapped:sender];
    [self toggleTableView:NO];
}

#pragma mark -
#pragma mark MCTWidget

- (CGFloat)expandedHeight
{
    T_UI();
    return CGRectGetMaxY(self.tableView.frame);
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
    return [self.currentChoices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    static NSString *ident = @"";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];

        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        // TODO: cell properties
    }

    cell.textLabel.text = [self.currentChoices objectAtIndex:indexPath.row];

    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    self.textField.text = [self.currentChoices objectAtIndex:indexPath.row];
    [self.textField resignFirstResponder];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Auto-Completion

- (BOOL)shouldShowChoicesTable
{
    if (self.currentChoices == nil || [self.currentChoices count] == 0)
        return NO;

    if ([self.currentChoices count] == 1 &&
        [self.textField.text isEqualToString:[self.currentChoices objectAtIndex:0]])
        return NO;

    return YES;
}

- (void)toggleTableView:(BOOL)visible
{
    T_UI();
    self.tableView.hidden = !visible;

    if (visible) {
        [self.superview bringSubviewToFront:self];
    } else {
        [self.superview sendSubviewToBack:self];
    }
}

- (void)textDidChange:(NSNotification *)notif
{
    T_UI();
    self.currentChoices = [NSMutableArray array];
    if (![MCTUtils isEmptyOrWhitespaceString:self.textField.text]) {
        for (NSString *s in self.choices) {
            NSRange r = [s rangeOfString:self.textField.text options:NSCaseInsensitiveSearch];
            if (r.location == 0) {
                [self.currentChoices addObject:s];
            }
        }
    } else {
        self.currentChoices = [NSMutableArray arrayWithArray:self.choices];
    }

    [self toggleTableView:[self shouldShowChoicesTable]];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)txtField
{
    T_UI();
    BOOL b = [super textFieldShouldReturn:txtField];
    if (b) {
        [self toggleTableView:NO];
    }
    return b;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)txtField
{
    T_UI();
    BOOL b = [super textFieldShouldEndEditing:txtField];
    if (b) {
        [self toggleTableView:NO];
    }
    return b;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)txtField
{
    T_UI();
    [self textDidChange:nil];
    return YES;
}

#pragma mark -

+ (NSString *)valueStringForWidget:(NSDictionary *)widgetDict
{
    T_UI();
    return [widgetDict stringForKey:@"value"];
}

@end