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
#import "MCTIdentity.h"
#import "MCTIntentFramework.h"


@interface MCTAddViaEmailVC : MCTUIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, IMCTIntentReceiver>

@property (nonatomic, weak) MCTUIViewController<UIAlertViewDelegate> *parentVC;
@property (nonatomic, strong) IBOutlet UILabel *searchDescription;
@property (nonatomic, strong) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) IBOutlet UILabel *validationLabel;
@property (nonatomic, strong) IBOutlet UIControl *searchButton;
@property (nonatomic, strong) IBOutlet UITableView *autoCompletionTable;
@property (nonatomic, strong) NSMutableArray *autoCompletionEmails;
@property (nonatomic, strong) NSArray *addressBookEmails;

+ (MCTAddViaEmailVC *)viewControllerWithParent:(MCTUIViewController<UIAlertViewDelegate> *)parent;

- (id)initWithParent:(MCTUIViewController<UIAlertViewDelegate> *)parent;

- (IBAction)onSearchButtonTapped:(id)sender;
- (IBAction)onBackgroundTapped:(id)sender;

@end