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

#import "MCTBaseRegistrationVC.h"
#import "MCTFacebookRegistration.h"


@interface MCTRegistrationPage0VC : MCTBaseRegistrationVC <UIAlertViewDelegate, UIActionSheetDelegate, IMCTIntentReceiver>

+ (MCTRegistrationPage0VC *)viewController;

@property (nonatomic, strong) IBOutlet UILabel *fbLbl;
@property (nonatomic, strong) IBOutlet UILabel *fbNoteLbl;
@property (nonatomic, strong) IBOutlet UIControl *fbControl;
@property (nonatomic, strong) IBOutlet UIImageView *fbLogo;
@property (nonatomic, strong) IBOutlet UIButton *fbBtn;
@property (nonatomic, strong) IBOutlet UILabel *mailLbl;
@property (nonatomic, strong) IBOutlet UIControl *mailControl;
@property (nonatomic, strong) IBOutlet UIImageView *mailLogo;
@property (nonatomic, strong) IBOutlet UIButton *mailBtn;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) MCTFacebookRegistration *fbRegistration;

- (IBAction)onFacebookTapped:(id)sender;
- (IBAction)onEmailTapped:(id)sender;

@end