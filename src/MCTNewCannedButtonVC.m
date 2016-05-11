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

#import "MCTGeoActionVC.h"
#import "MCTNewCannedButtonVC.h"
#import "MCTNewMessageVC.h"
#import "MCTTelActionVC.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

#define MARGIN 5

@interface MCTNewCannedButtonVC ()

- (void)onAddButtonClicked:(id)sender;
- (void)toggleAddButton;

@end


@implementation MCTNewCannedButtonVC


+ (MCTNewCannedButtonVC *)viewControllerWithCannedButtons:(MCTCannedButtons *)cannedBtns
{
    T_UI();
    MCTNewCannedButtonVC *vc = [[MCTNewCannedButtonVC alloc] initWithNibName:@"newCannedButton" bundle:nil];
    vc.cannedButtons = cannedBtns;
    vc.title = NSLocalizedString(@"New Button", nil);
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    [MCTUIUtils setBackgroundPlainToView:self.view];

    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil)
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(onAddButtonClicked:)];
    addBtn.enabled = NO;
    self.navigationItem.rightBarButtonItem = addBtn;
    self.enterTextLabel.text = NSLocalizedString(@"Button Text:", nil);
    self.actionLabel.text = NSLocalizedString(@"Button Action:", nil);
    [self.actionSegment setTitle:@"-" forSegmentAtIndex:0];
    [self.actionSegment setTitle:NSLocalizedString(@"tel", nil) forSegmentAtIndex:1];
    [self.actionSegment setTitle:NSLocalizedString(@"geo", nil) forSegmentAtIndex:2];
    [self.actionSegment setTitle:NSLocalizedString(@"www", nil) forSegmentAtIndex:3];

    [(UIButton *)self.moreButton setTitle:@"…" forState:UIControlStateNormal];
    self.moreButton = [MCTUIUtils replaceUIButtonWithTTButton:(UIButton *)self.moreButton];

    [self.captionField becomeFirstResponder];

    self.moreButton.hidden = YES;
    self.actionField.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    T_UI();
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    T_UI();
    [super viewDidAppear:animated];
    [self toggleAddButton];
}

- (void)onAddButtonClicked:(id)sender
{
    T_UI();
    NSString *format = @"%@";
    switch (self.actionSegment.selectedSegmentIndex) {
        case 1:
            format = @"tel://%@";
            break;
        case 2:
            format = @"geo://%@";
            break;
        case 3:
            if (![self.actionField.text hasPrefix:@"http://"] && ![self.actionField.text hasPrefix:@"https://"])
                format = @"http://%@";
        default:
            break;
    }

    LOG(@"self.actionField.text: %@", self.actionField.text);

    NSString *action = [NSString stringWithFormat:format, OR(self.actionField.text, @"")];
    [self.cannedButtons addButtonWithCaption:self.captionField.text andAction:action];

    NSArray *vcs = self.navigationController.viewControllers;
    MCTNewMessageVC *nmVC = (MCTNewMessageVC *) [vcs objectAtIndex:[vcs count] - 2];
    [nmVC.vc3 buttonAddedAtIndex:0];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)toggleAddButton
{
    T_UI();
    BOOL captionOk = ![MCTUtils isEmptyOrWhitespaceString:self.captionField.text];
    BOOL actionOk = self.actionField.hidden || ![MCTUtils isEmptyOrWhitespaceString:self.actionField.text];
    self.navigationItem.rightBarButtonItem.enabled = captionOk && actionOk;
    LOG(@"self.actionField.text: %@", self.actionField.text);
}

- (IBAction)onTextFieldChanged:(id)sender
{
    T_UI();
    [self toggleAddButton];
}

- (IBAction)onActionSegmentClicked:(id)sender
{
    T_UI();
    UISegmentedControl *segment = sender;
    self.actionField.text = nil;
    switch (segment.selectedSegmentIndex) {
        case 0: {
            self.actionField.hidden = YES;
            self.moreButton.hidden = YES;
            [self.captionField becomeFirstResponder];
            break;
        }
        case 1: {
            self.actionField.placeholder = NSLocalizedString(@"Phone Number", nil);
            [self.actionField resignFirstResponder];
            self.actionField.keyboardType = UIKeyboardTypePhonePad;
            [self.actionField becomeFirstResponder];
            self.actionField.hidden = NO;
            self.moreButton.hidden = NO;
            self.actionField.width = self.moreButton.left - MARGIN - self.actionField.left;
            break;
        }
        case 2: {
            self.actionField.placeholder = NSLocalizedString(@"Coordinates", nil);
            [self.actionField resignFirstResponder];
            self.actionField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            [self.actionField becomeFirstResponder];
            self.actionField.hidden = NO;
            self.moreButton.hidden = NO;
            self.actionField.width = self.moreButton.left - MARGIN - self.actionField.left;
            break;
        }
        case 3: {
            self.actionField.placeholder = nil;
            self.actionField.text = @"http://";
            [self.actionField resignFirstResponder];
            self.actionField.keyboardType = UIKeyboardTypeURL;
            [self.actionField becomeFirstResponder];
            self.actionField.hidden = NO;
            self.moreButton.hidden = YES;
            self.actionField.width = self.moreButton.left + self.moreButton.width - self.actionField.left;
            break;
        }
        default:
            break;
    }
    [self toggleAddButton];
}

- (IBAction)onMoreButtonClicked:(id)sender
{
    T_UI();
    UIViewController *vc = nil;
    switch (self.actionSegment.selectedSegmentIndex) {
        case 1: {
            MCTTelActionVC *telActionVC = [MCTTelActionVC viewController];
            telActionVC.actionTextField = self.actionField;
            vc = telActionVC;
            break;
        }
        case 2: {
            MCTGeoActionVC *geoActionVC = [MCTGeoActionVC viewController];
            geoActionVC.actionTextField = self.actionField;
            vc = geoActionVC;
            break;
        }
        default:
            break;
    }
    if (vc)
        [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onBackgroundTapped:(id)sender
{
    T_UI();
    [self.captionField resignFirstResponder];
    [self.actionField resignFirstResponder];
}

@end