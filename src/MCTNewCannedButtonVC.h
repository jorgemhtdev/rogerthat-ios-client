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

#import "MCTUIViewController.h"
#import "MCTCannedButtons.h"


@interface MCTNewCannedButtonVC : MCTUIViewController

@property (nonatomic, strong) MCTCannedButtons *cannedButtons;
@property (nonatomic, strong) IBOutlet UITextField *captionField;
@property (nonatomic, strong) IBOutlet UITextField *actionField;
@property (nonatomic, strong) IBOutlet UISegmentedControl *actionSegment;
@property (nonatomic, strong) IBOutlet UIControl *moreButton;
@property (nonatomic, strong) IBOutlet UILabel *enterTextLabel;
@property (nonatomic, strong) IBOutlet UILabel *actionLabel;


+ (MCTNewCannedButtonVC *)viewControllerWithCannedButtons:(MCTCannedButtons *)cannedBtns;

- (IBAction)onTextFieldChanged:(id)sender;
- (IBAction)onActionSegmentClicked:(id)sender;
- (IBAction)onMoreButtonClicked:(id)sender;
- (IBAction)onBackgroundTapped:(id)sender;

@end