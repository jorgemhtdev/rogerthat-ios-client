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
#import "MCTFriend.h"
#import "MCTIntentFramework.h"
#import "MCTMessageDetailView.h"
#import <ZXingWidgetController.h>
#import "MCTHTTPRequest.h"
#import <WebKit/WebKit.h>

@interface MCTServiceScreenBrandingVC : MCTUIViewController <UIWebViewDelegate, UIAlertViewDelegate, ZXingDelegate,
FBFriendPickerDelegate, AVAudioPlayerDelegate, IMCTIntentReceiver, WKNavigationDelegate>

@property (nonatomic, strong) MCTFriend *service;
@property (nonatomic, strong) MCT_com_mobicage_to_friends_ServiceMenuItemTO *item;
@property (nonatomic, copy) NSString *context;
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIWebView *webViewHttp;
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) WKWebView *wkWebViewHttp;
@property (nonatomic, strong) MCTMessageDetailView *detailView;
@property (nonatomic) MCTlong pokePressTime;
@property (nonatomic, strong) NSURL *currentURL;
@property (nonatomic) BOOL appearedOnce;
@property (nonatomic) BOOL apiResultHandlerSet;
@property (nonatomic, strong) MCTHTTPRequest *httpRequest;
@property (nonatomic, strong) AVAudioPlayer *backgroundMusicPlayer;
@property (nonatomic, strong) ZXingWidgetController *cameraController;
@property (nonatomic, copy) NSString *cameraType;
@property (nonatomic, copy) NSString *brandingHash;
@property (nonatomic) BOOL rogerthatJSLibSet;
@property (nonatomic) BOOL wasScanningForQRCodes;
@property(nonatomic, strong) NSTimer *bigScanningPreviewTimer;
@property (nonatomic, strong) UIBarButtonItem *backButtonBackup;

+ (MCTServiceScreenBrandingVC *)viewControllerWithService:(MCTFriend *)service
                                                     item:(MCT_com_mobicage_to_friends_ServiceMenuItemTO *)item;
@end