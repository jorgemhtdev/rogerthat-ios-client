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
#import "MCTRegistrationMgr.h"


@interface MCTStartScreenVC : MCTBaseRegistrationVC

@property (nonatomic, strong) IBOutlet UILabel *welcomeLbl;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton *tosBtn;
@property (nonatomic, strong) IBOutlet UIButton *agreeBtn;

+ (MCTStartScreenVC *)viewController;

- (IBAction)onTOSTapped:(id)sender;
- (IBAction)onAgreeTapped:(id)sender;

@end