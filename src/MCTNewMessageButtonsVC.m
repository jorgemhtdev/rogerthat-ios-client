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

#import "MCTButton.h"
#import "MCTCannedButtons.h"
#import "MCTComponentFramework.h"
#import "MCTMessagesPlugin.h"
#import "MCTNewCannedButtonVC.h"
#import "MCTNewMessageButtonsVC.h"
#import "MCTOperation.h"
#import "MCTTransferObjects.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

#import "Three20Style.h"
#import "TTButton.h"
#import "UIViewAdditions.h"

#define MCT_DEFAULT_BTN_TOUCH_DELAY 0.3

@interface MCTButtonCell : UITableViewCell

@property (nonatomic, strong) MCTButton *button;
@property (nonatomic, strong) UIView *separatorView;
@end

@implementation MCTButtonCell


- (void)commonInit
{
    T_UI();
    self.separatorView = [[UIView alloc] init];
    self.separatorView.backgroundColor = [UIColor MCTSeparatorColor];
    [self.contentView addSubview:self.separatorView];
}

- (id)init
{
    T_UI();
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    T_UI();
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    T_UI();
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    T_UI();
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];
    self.separatorView.frame = CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1);
    self.separatorView.backgroundColor = [UIColor MCTSeparatorColor];
}

@end

#pragma mark -

@interface MCTNewMessageButtonsVC ()

- (void)toggleButton:(MCTButton *)button withIndex:(NSIndexPath *)indexPath;
- (void)onButtonTouchDown:(id)sender;
- (void)onButtonTouchUp:(id)sender;

@end


@implementation MCTNewMessageButtonsVC


+ (MCTNewMessageButtonsVC *)viewControllerWithRequest:(MCTSendMessageRequest *)request
{
    T_UI();
    MCTNewMessageButtonsVC *vc = [[MCTNewMessageButtonsVC alloc] initWithNibName:@"newMessageButtons"
                                                                           bundle:nil];
    vc.request = request;
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    [MCTUIUtils addShadowToView:self.headerView];

    self.cannedButtons = [MCTCannedButtons buttons];
    [self loadButtons];
}

- (void)loadButtons
{
    NSInteger count = [self.selectedButtons count];
    if (count) {
        for (NSInteger i = count - 1; i >= 0; i--) {
            MCTButton *btn = [self.selectedButtons objectAtIndex:i];
            NSIndexPath *indexPath = [self.selectedIndexPaths objectAtIndex:i];

            [self toggleButton:btn withIndex:indexPath];
        }

        [self.tableView reloadData];
    }

    self.selectedIndexPaths = [NSMutableArray array];
    self.selectedButtons = [NSMutableArray array];

    for (MCT_com_mobicage_to_messaging_ButtonTO *btnTO in self.request.buttons) {
        MCTButton *btn = [self.cannedButtons buttonWithId:btnTO.idX];
        if (btn) {
            [self toggleButton:btn
                     withIndex:[NSIndexPath indexPathForRow:[self.cannedButtons.buttons indexOfObject:btn]
                                                  inSection:0]];
        }
    }
    [self.tableView reloadData];
}

- (void)saveButtons
{
    T_UI();
    self.request.buttons = self.selectedButtons;
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    [super viewDidDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self saveButtons];
}

- (IBAction)onAddButtonClicked:(id)sender
{
    T_UI();
    MCTNewCannedButtonVC *vc = [MCTNewCannedButtonVC viewControllerWithCannedButtons:self.cannedButtons];
    [self.sendMessageViewController.navigationController pushViewController:vc animated:YES];
}

- (void)buttonAddedAtIndex:(int)index;
{
    T_UI();
    for (int i = index; i < [self.selectedIndexPaths count]; i++) {
        NSIndexPath *indexPath = [self.selectedIndexPaths objectAtIndex:i];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        [self.selectedIndexPaths replaceObjectAtIndex:i withObject:newIndexPath];
    }

    [self toggleButton:[self.cannedButtons.buttons objectAtIndex:index]
             withIndex:[NSIndexPath indexPathForRow:index inSection:0]];

    [self.tableView reloadData];
}

- (void)toggleButton:(MCTButton *)button withIndex:(NSIndexPath *)indexPath
{
    T_UI();
    CGFloat MARGIN = 5;

    NSInteger count = [self.selectedIndexPaths count];

    NSInteger i = [self.selectedIndexPaths indexOfObject:indexPath];
    if (i == NSNotFound) {
        CGFloat x = 0;
        if (count > 0) {
            UIView *prevBtn = [self.buttonsView.subviews objectAtIndex:count - 1];
            x = prevBtn.frame.origin.x + prevBtn.frame.size.width + MARGIN;
        }

        TTButton *ttBtn = [TTButton buttonWithStyle:MCT_STYLE_MAGIC_SMALL_BUTTON title:button.caption];
        ttBtn.frame = CGRectMake(x, 0, 0, 0);
        [ttBtn addTarget:self action:@selector(onButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [ttBtn addTarget:self action:@selector(onButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        ttBtn.width = MAX(50, [MCTUIUtils sizeForTTButton:ttBtn constrainedToSize:CGSizeMake(200, 37)].width);
        ttBtn.height = 37;

        [self.buttonsView insertSubview:ttBtn atIndex:count];
        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedButtons addObject:button];
    } else {
        NSString *btnId = ((MCTButton *) [self.selectedButtons objectAtIndex:i]).idX;
        if (self.request.sender_reply && [self.request.sender_reply isEqualToString:btnId])
            self.request.sender_reply = nil;

        [self.selectedIndexPaths removeObjectAtIndex:i];
        [self.selectedButtons removeObjectAtIndex:i];
        [[self.buttonsView.subviews objectAtIndex:i] removeFromSuperview];

        // reposition buttons
        [UIView animateWithDuration:0.2 animations:^{
            for (NSInteger j = i; j < count - 1; j++) {
                CGFloat x = 0;
                if (j > 0) {
                    UIView *prevBtn = [self.buttonsView.subviews objectAtIndex:j - 1];
                    x = prevBtn.right + MARGIN;
                }
                UIView *uiBtn = [self.buttonsView.subviews objectAtIndex:j];
                uiBtn.left = x;
            }
        }];
    }

    CGFloat contentWidth = 0;
    count = [self.selectedIndexPaths count];
    if (count > 0) {
        UIView *lastBtn = [self.buttonsView.subviews objectAtIndex:count - 1];
        contentWidth = lastBtn.right;
    }

    CGSize contentSize = CGSizeMake(contentWidth, self.buttonsView.bounds.size.height);
    [UIView animateWithDuration:0.2 animations:^{
        self.buttonsView.contentSize = contentSize;
        if (contentWidth > self.buttonsView.width) {
            self.buttonsView.contentOffset = CGPointMake(self.buttonsView.contentSize.width - self.buttonsView.width, 0);
        } else {
            self.buttonsView.contentOffset = CGPointZero;
        }
    }];
}

- (void)styleCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    BOOL isSelected = [self.selectedIndexPaths containsObject:indexPath];
    cell.textLabel.textColor = isSelected ? [UIColor MCTSelectedCellTextColor] : [UIColor blackColor];
    cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
}

- (void)onButtonTouchDown:(id)sender
{
    T_UI();
    _touchDownTime = [MCTUtils currentTimeMillis];
    [self performSelector:@selector(onButtonTouchUp:) withObject:sender afterDelay:MCT_DEFAULT_BTN_TOUCH_DELAY];
}

- (void)onButtonTouchUp:(id)sender
{
    T_UI();
    if (_touchDownTime < 0) {
        // Button already touched up, or method already triggered by performSelector:withObject:afterDelay:
        return;
    }

    TTButton *button = sender;
    NSInteger i = [self.buttonsView.subviews indexOfObject:button];

    if (i != NSNotFound) {
        if ([MCTUtils currentTimeMillis] - _touchDownTime < 1000 * MCT_DEFAULT_BTN_TOUCH_DELAY) {

            // Remove button
            MCTButton *buttonTO = [self.selectedButtons objectAtIndex:i];
            NSIndexPath *indexPath = [self.selectedIndexPaths objectAtIndex:i];
            [self toggleButton:buttonTO withIndex:indexPath];
            [self.tableView reloadData];

        } else {

            // Toggle default |button|, and reset every |otherButton| to its original color
            NSString *idX = ((MCTButton *) [self.selectedButtons objectAtIndex:i]).idX;
            BOOL switchOn = self.request.sender_reply == nil || ![idX isEqualToString:self.request.sender_reply];

            self.request.sender_reply = switchOn ? idX : nil;
        }
    }
    _touchDownTime = -1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark -
#pragma mark UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    T_UI();
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    return [self.cannedButtons.buttons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    static NSString *ident = @"ButtonCell";
    MCTButtonCell *cell = (MCTButtonCell *) [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        cell = [[MCTButtonCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
    }

    MCTButton *btn = [self.cannedButtons.buttons objectAtIndex:indexPath.row];
    cell.button = btn;
    cell.textLabel.text = btn.caption;
    cell.detailTextLabel.text = btn.action;

    [self styleCell:cell forRowAtIndexPath:indexPath];

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    T_UI();
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    T_UI();
    return self.headerView.bounds.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTButtonCell *cell = (MCTButtonCell *) [tableView cellForRowAtIndexPath:indexPath];

    [self toggleButton:cell.button withIndex:indexPath];
    [self styleCell:cell forRowAtIndexPath:indexPath];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    NSInteger i = [self.selectedIndexPaths indexOfObject:indexPath];
    if (i != NSNotFound) {
        [self toggleButton:[self.selectedButtons objectAtIndex:i] withIndex:indexPath];
    }

    for (int i = 0; i < [self.selectedIndexPaths count]; i++) {
        NSIndexPath *selectedIndexPath = [self.selectedIndexPaths objectAtIndex:i];
        if (selectedIndexPath.row > indexPath.row) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row-1 inSection:0];
            [self.selectedIndexPaths replaceObjectAtIndex:i withObject:newIndexPath];
        }
    }

    [self.cannedButtons.buttons removeObjectAtIndex:indexPath.row];
    [self.cannedButtons save];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end