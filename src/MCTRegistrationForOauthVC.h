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
#import "MCTBaseRegistrationVC.h"
#import "MCTFinishRegistration.h"
#import "MCTPreRegistrationInfo.h"
#import "MCTHTTPRequest.h"
#import "MCTIntentFramework.h"

@interface MCTRegistrationForOauthVC : MCTBaseRegistrationVC <UIAlertViewDelegate, IMCTIntentReceiver, MCTFinishRegistrationCallback>

+ (MCTRegistrationForOauthVC *)viewController;

@property (nonatomic, retain) IBOutlet UILabel *txtLbl;
@property (nonatomic, strong) IBOutlet UIImageView *lockImg;
@property (nonatomic, retain) IBOutlet UIButton *authenticateBtn;
@property (nonatomic, strong) MCTPreRegistrationInfo *preRegistrationInfo;
@property (nonatomic, retain) MCTFormDataRequest *httpRequest;

- (IBAction)onAuthenticateTapped:(id)sender;

@end
