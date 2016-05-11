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

#import <ZXingWidgetController.h>

#import "TTButton.h"

#import "MCTHTTPRequest.h"
#import "MCTFriendsPlugin.h"
#import "MCTScanResultVC.h"
#import "MCTUIViewController.h"

#define MCT_TAG_OPEN_URL 10
#define MCT_TAG_ASK_CAMERA_PERMISSION 20
#define MCT_TAG_GO_TO_CAMERA_SETTINGS 30

@interface MCTScannerVC : MCTUIViewController <ZXingDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet UILabel *loadingLabel;
@property (nonatomic, strong) TTButton *scanBtn;
@property (nonatomic, strong) MCTHTTPRequest *httpRequest;
@property (nonatomic) BOOL viewLoaded;

+ (UIViewController *)viewControllerForScanResultWithEmailHash:(NSString *)emailHash
                                                   andMetaData:(NSString *)metaData
                                       andNavigationController:(UINavigationController *)navigationController
                                           andSkipNetworkCheck:(BOOL)skipNetworkCheck;
- (IBAction)onScanBtnClicked:(id)sender;
+ (BOOL)checkScanningSupportedInVC:(MCTUIViewController<UIAlertViewDelegate> *)vc;

@end