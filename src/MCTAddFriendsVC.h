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
#import "MCTAddViaContactsVC.h"
#import "MCTAddViaContactsResultVC.h"
#import "MCTAddViaEmailVC.h"
#import "MCTAddViaFacebookVC.h"
#import "MCTAddViaFacebookResultVC.h"
#import "MCTAddViaQRScanVC.h"
#import "MCTIntentFramework.h"
#import "MCTFriendsPlugin.h"

typedef enum {
    MCTAddFriendsTabPhone = 1,
    MCTAddFriendsTabFacebook = 2,
    MCTAddFriendsTabQR = 3,
    MCTAddFriendsTabSearch = 4
} MCTAddFriendsTab;

#define MCT_TAG_ALERTVIEW_POST_ON_WALL 1

@interface MCTAddFriendsVC : MCTUIViewController <UIAlertViewDelegate, UIScrollViewDelegate, IMCTIntentReceiver> 

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIView *selectionView;

@property (nonatomic, strong) IBOutlet UIControl *phoneControl;
@property (nonatomic, strong) IBOutlet UIControl *fbControl;
@property (nonatomic, strong) IBOutlet UIControl *qrControl;
@property (nonatomic, strong) IBOutlet UIControl *searchControl;

@property (nonatomic, strong) IBOutlet UIImageView *phoneControlImageView;
@property (nonatomic, strong) IBOutlet UIImageView *fbControlImageView;
@property (nonatomic, strong) IBOutlet UIImageView *qrControlImageView;
@property (nonatomic, strong) IBOutlet UIImageView *searchControlImageView;

+ (MCTAddFriendsVC *)viewController;

- (void)showTab:(MCTAddFriendsTab)tab;
- (IBAction)onControlTapped:(id)sender;

@end