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

#import <AudioToolbox/AudioToolbox.h>

#import "MCTBeaconProximity.h"
#import "MCTBrandingMgr.h"
#import "MCTComponentFramework.h"
#import "MCTIntent.h"
#import "MCTMessageDetailVC.h"
#import "MCTMobileInfo.h"
#import "MCTServiceApiCallbackResult.h"
#import "MCTServiceScreenBrandingVC.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

#import "GTMNSDictionary+URLArguments.h"
#import "MCTScannerVC.h"
#import "MCTZXingUtils.h"
#import "MCTZXingWidgetController.h"
#import "MCTScanResult.h"

#define MCT_FACEBOOK_URL_HOST @"facebook"
#define MCT_LOG_URL_HOST @"log"
#define MCT_BACK_URL_HOST @"back"
#define MCT_API_URL_HOST @"api"
#define MCT_USER_URL_HOST @"user"
#define MCT_UTIL_URL_HOST @"util"
#define MCT_SERVICE_URL_HOST @"service"
#define MCT_CAMERA_URL_HOST @"camera"

#define MCTCameraTypeFront @"front"
#define MCTCameraTypeBack @"back"
#define MCTCameraTypes [NSArray arrayWithObjects: MCTCameraTypeFront, MCTCameraTypeBack, nil]

@interface MCTServiceScreenBrandingVC ()

@property (nonatomic, strong) NSDictionary *fbParams;
@property (nonatomic, copy) NSString *fbRequestId;
@property (nonatomic, strong) MCTBrandingResult *brandingResult;

- (NSString *)executeJS:(NSString *)command;
- (NSString *)toJSONRepresentation:(NSObject *)anObject;

- (void)deliverAllApiCallbacksToJs;
- (void)deliverApiCallbackToJsWithResult:(MCTServiceApiCallbackResult *)r;
- (void)deliverFBCallbackToJsWithRequestId:(NSString *)requestId result:(NSDictionary *)resultDict;
- (void)deliverFBCallbackToJsWithRequestId:(NSString *)requestId error:(NSDictionary *)errorDict;
+ (NSDictionary *)errorDictFromFBErorr:(NSError *)error;
- (void)facebookLoginWithId:(NSString *)requestId permissions:(NSArray *)permissions;
- (void)facebookPostWithId:(NSString *)requestId postParams:(NSDictionary *)postParams;
- (void)facebookTickerWithId:(NSString *)requestId arguments:(NSDictionary *)arguments;
- (void)dismissViewController;

@end

@implementation MCTServiceScreenBrandingVC


+ (MCTServiceScreenBrandingVC *)viewControllerWithService:(MCTFriend *)service
                                                     item:(MCT_com_mobicage_to_friends_ServiceMenuItemTO *)item
{
    T_UI();
    MCTServiceScreenBrandingVC *vc = [[MCTServiceScreenBrandingVC alloc] initWithNibName:@"screenBranding" bundle:nil];
    vc.service = service;
    vc.item = item;
    return vc;
}

- (void)dealloc
{
    if (self.httpRequest) {
        [self.httpRequest clearDelegatesAndCancel];
    }
    [self stopScanning:self.cameraController];
    if (self.bigScanningPreviewTimer) {
        [self.bigScanningPreviewTimer invalidate];
    }
}

- (BOOL)prefersStatusBarHidden {
    return IS_CONTENT_BRANDING_APP;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    if (IS_CONTENT_BRANDING_APP) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        CGRect originalFrame = self.webView.frame;
        self.webView.height += self.webView.top;
        self.webView.top = 0;

        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes
                                                   modifiedSince:dateFrom
                                               completionHandler:^{
                                               }];

        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.selectionGranularity = WKSelectionGranularityCharacter;
        config.processPool = [[WKProcessPool alloc] init];
        self.wkWebView = [[WKWebView alloc] initWithFrame:self.webView.frame configuration:config];
        self.wkWebView.navigationDelegate = self;
        self.wkWebView.allowsBackForwardNavigationGestures = NO;
        [self.wkWebView setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

        WKWebViewConfiguration *configHttp = [[WKWebViewConfiguration alloc] init];
        configHttp.selectionGranularity = WKSelectionGranularityCharacter;
        configHttp.processPool = [[WKProcessPool alloc] init];
        self.wkWebViewHttp  = [[WKWebView alloc] initWithFrame:originalFrame configuration:configHttp];
        self.wkWebViewHttp.navigationDelegate = self;
        self.wkWebViewHttp.allowsBackForwardNavigationGestures = NO;
        [self.wkWebViewHttp setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        self.wkWebViewHttp.hidden = YES;
        [self.view addSubview:self.wkWebView];
        [self.view addSubview:self.wkWebViewHttp];
        self.webView.hidden = YES;
    } else {
        self.webView.bounces = NO;
        self.webViewHttp.bounces = NO;
        self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
        self.webViewHttp.dataDetectorTypes = UIDataDetectorTypeNone;
    }

    [self displayBranding];

    NSMutableArray *intents = [NSMutableArray arrayWithObjects:kINTENT_SERVICE_DATA_UPDATED, kINTENT_SERVICE_API_CALL_ANSWERED,
                               kINTENT_BEACON_IN_REACH, kINTENT_BEACON_OUT_OF_REACH, kINTENT_USER_INFO_RETRIEVED, nil];
    if (IS_CONTENT_BRANDING_APP) {
        [intents addObject:kINTENT_SERVICE_BRANDING_RETRIEVED];
        [intents addObject:kINTENT_FRIEND_MODIFIED];
    }
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:intents
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)displayBranding
{
    if ([self.brandingHash isEqualToString:self.item.screenBranding])
        return;
    self.brandingHash = self.item.screenBranding;
    self.brandingResult = [[MCTComponentFramework brandingMgr] prepareBrandingWithKey:self.item.screenBranding
                                                                            forFriend:self.service];
    if (self.wkWebView) {
        [self.wkWebView loadBrandingResult:self.brandingResult];
        self.wkWebView.opaque = NO;
        self.wkWebView.backgroundColor = [UIColor clearColor];
        self.wkWebViewHttp.opaque = NO;
        self.wkWebViewHttp.backgroundColor = [UIColor clearColor];
        self.view.backgroundColor = [self backGroundColorForBrandingResult:self.brandingResult];
    } else {
        [self.webView loadBrandingResult:self.brandingResult];

        if ([MSG_ATTACHMENT_CONTENT_TYPE_PDF isEqualToString:self.brandingResult.contentType]) {
            self.webView.scalesPageToFit = YES;
        }
        IF_IOS7_OR_GREATER({
            // The default white webView background affected the coloring of the navigation bar
            self.webView.opaque = NO;
            self.webView.backgroundColor = [UIColor clearColor];
            self.webViewHttp.opaque = NO;
            self.webViewHttp.backgroundColor = [UIColor clearColor];
            self.view.backgroundColor = [self backGroundColorForBrandingResult:self.brandingResult];
        });
    }

    if (!self.item.runInBackground) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onApplicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    T_UI();
    [self resetNavigationControllerAppearance];
    [self executeJS:@"rogerthat._onPause()"];

    if (self.cameraController) {
        self.wasScanningForQRCodes = YES;
        [self stopScanning:self.cameraController];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    if (![self.navigationController.viewControllers containsObject:self]) {
        // Cleanup branding directories
        [[MCTComponentFramework brandingMgr] cleanupBrandingWithBrandingKey:self.item.screenBranding];
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self];

        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    T_UI();
    [super viewWillAppear:animated];

    if (self.appearedOnce) {
        [self executeJS:@"rogerthat._onResume()"];
        if (self.wasScanningForQRCodes) {
            [self startScanning];
        }
    }
    [self changeNavigationControllerAppearanceWithBrandingResult:self.brandingResult];

    self.appearedOnce = YES;
}

#pragma mark -
#pragma mark NSNotificationCenter

- (void)onApplicationDidEnterBackground:(NSNotification *)notification
{
    T_UI();
    if (self.fbRequestId == nil && !self.item.runInBackground) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [array removeObject:self];

        [self.navigationController setViewControllers:array animated:YES];
    } else {
        [self executeJS:@"rogerthat._onPause()"];
    }
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    T_UI();
    if (self.webViewHttp == webView) {
        self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        return;
    }
    if (self.webView != webView)
        return;

    if (!self.rogerthatJSLibSet) {
        self.rogerthatJSLibSet = YES;
        [self executeJS:@"rogerthat._bridgeLogging()"];

        NSDictionary *info = [[MCTComponentFramework friendsPlugin] getRogerthatUserAndServiceInfoByService:self.service];

        [self executeJS:[NSString stringWithFormat:@"rogerthat._setInfo(%@)", [info MCT_JSONRepresentation]]];
    }
}

- (NSDictionary *)queryParametersFromRequest:(NSURLRequest *)request
{
    NSArray *splitted = [request.URL.absoluteString componentsSeparatedByString:@"?"];
    NSDictionary *arguments = [splitted count] < 2 ? [NSDictionary dictionary] :
    [NSDictionary gtm_dictionaryWithHttpArgumentsString:[splitted objectAtIndex:1]];
    return arguments;
}

- (BOOL)shouldOverrideLoadingWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType uiWebView:(UIWebView *)uiWebView wkWebView:(WKWebView *)wkWebView
{
    T_UI();
    if ([request.URL.scheme isEqualToString:@"rogerthat"]) {
        NSString *host = request.URL.host;

        if ([MCT_LOG_URL_HOST isEqualToString:host]) {
            NSDictionary *arguments = [self queryParametersFromRequest:request];
            NSString *e = [arguments objectForKey:@"e"];
            if (e) {
                e = [e stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                LOG(@"[BRANDING] %@", e);
                NSException *exc = [[NSException alloc] initWithName:@"ScreenBrandingException"
                                                               reason:[NSString stringWithFormat:@"\n- Exception logged by screenBranding of %@\n- Service menu item name: %@\n- Service menu item coords: %@\n%@",
                                                                       self.service.email,
                                                                       self.item.label,
                                                                       self.item.coords,
                                                                       e]
                                                             userInfo:nil];
                [MCTSystemPlugin logError:exc withMessage:nil];
            } else {
                LOG(@"[BRANDING] %@", [[arguments objectForKey:@"m"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
            }
            return NO;

        } else {
            LOG(@"shouldStartLoadWithRequest: %@", request);
            if ([MCT_FACEBOOK_URL_HOST isEqualToString:host]) {
                NSDictionary *arguments = [self queryParametersFromRequest:request];
                NSString *requestId = [arguments objectForKey:@"id"];

                @try {
                    if ([@"/login" isEqualToString:request.URL.path]) {
                        [self facebookLoginWithId:requestId
                                      permissions:[[arguments stringForKey:@"properties"] componentsSeparatedByString:@","]];
                    } else if ([@"/post" isEqualToString:request.URL.path]) {
                        [self facebookPostWithId:requestId
                                      postParams:[[arguments stringForKey:@"postParams"] MCT_JSONValue]];
                    } else if ([@"/ticker" isEqualToString:request.URL.path]) {
                        [self facebookTickerWithId:requestId
                                         arguments:arguments];
                    }
                }
                @catch (NSException *e) {
                    ERROR(@"%@", e);
                }
                return NO;
            } else if ([MCT_BACK_URL_HOST isEqualToString:host]) {
                // empty stub on iOS
                return NO;
            } else if ([MCT_USER_URL_HOST isEqualToString:host]) {
                if ([@"/put" isEqualToString:request.URL.path]) {
                    NSDictionary *arguments = [self queryParametersFromRequest:request];
                    [[MCTComponentFramework friendsPlugin] putUserDataWithService:self.service.email
                                                                         userData:arguments[@"u"]];
                }
                return NO;
            } else if ([MCT_SERVICE_URL_HOST isEqualToString:host]) {
                if ([@"/getBeaconsInReach" isEqualToString:request.URL.path]) {
                    NSDictionary *arguments = [self queryParametersFromRequest:request];
                    NSString *requestId = [arguments objectForKey:@"id"];

                    NSArray *beaconProximities = [[MCTComponentFramework locationPlugin]
                                                  beaconsInReachWithFriendEmail:self.service.email];
                    NSMutableArray *beaconDicts = [NSMutableArray arrayWithCapacity:beaconProximities.count];
                    for (MCTBeaconProximity *beacon in beaconProximities) {
                        [beaconDicts addObject:[beacon dictRepresentation]];
                    }

                    [self deliverCallbackToJsWithRequestId:requestId
                                                    result:[NSDictionary dictionaryWithObject:beaconDicts
                                                                                       forKey:@"beacons"]];
                }
                return NO;
            } else if ([MCT_UTIL_URL_HOST isEqualToString:host]) {
                if ([@"/isConnectedToInternet" isEqualToString:request.URL.path]) {
                    NSDictionary *arguments = [self queryParametersFromRequest:request];
                    NSString *requestId = [arguments objectForKey:@"id"];

                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setBool:[MCTUtils connectedToInternet] forKey:@"connected"];
                    [dict setBool:[MCTUtils connectedToWifi] forKey:@"connectedToWifi"];

                    [self deliverCallbackToJsWithRequestId:requestId
                                                    result:dict];
                } else if ([@"/playAudio" isEqualToString:request.URL.path]) {
                    NSDictionary *arguments = [self queryParametersFromRequest:request];
                    NSString *requestId = [arguments objectForKey:@"id"];
                    NSString *url = [arguments objectForKey:@"url"];

                    if (!IS_CONTENT_BRANDING_APP) {
                        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"playAudio is not supported in your app" forKey:@"exception"];
                        [self deliverCallbackToJsWithRequestId:requestId result: dict];
                        return;
                    }

                    NSString *audioFile = [self.brandingResult.rootDir stringByAppendingPathComponent:url];
                    NSURL *filePath = [NSURL fileURLWithPath:audioFile isDirectory:NO];

                    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                    if ([audioSession isOtherAudioPlaying]) {
                        LOG(@"Other audio was playing");
                    }

                    NSError *audioSessionCategoryError = nil;
                    BOOL setCategoryIsSuccess = [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:&audioSessionCategoryError];
                    if (!setCategoryIsSuccess) {
                        LOG(@"audioSessionCategoryError %@", audioSessionCategoryError);
                    }

                    NSError *error = nil;

                    if (self.backgroundMusicPlayer) {
                        MCT_RELEASE(self.backgroundMusicPlayer);
                    }

                    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:&error];
                    if (error) {
                        ERROR(@"Sounds AVAudioPlayer with error %@", error);
                    } else {
                        NSError *audioSessionActivateError = nil;
                        BOOL setActiveIsSuccess = [audioSession setActive:YES error:&audioSessionActivateError];
                        if (!setActiveIsSuccess) {
                            LOG(@"audioSessionActivateError YES %@", audioSessionActivateError);
                        }
                        self.backgroundMusicPlayer.delegate = self;
                        [self.backgroundMusicPlayer prepareToPlay];
                        [self.backgroundMusicPlayer play];
                    }
                    [self deliverCallbackToJsWithRequestId:requestId result:[NSDictionary dictionary]];
                }
                return NO;

            } else if ([MCT_API_URL_HOST isEqualToString:host]) {
                if ([@"/resultHandlerConfigured" isEqualToString:request.URL.path]) {
                    self.apiResultHandlerSet = YES;
                    [self deliverAllApiCallbacksToJs];
                } else if ([@"/call" isEqualToString:request.URL.path]) {
                    NSDictionary *arguments = [self queryParametersFromRequest:request];
                    NSString *serviceEmail = self.service.email;
                    NSString *itemHashedTag = self.item.hashedTag;
                    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                        [[MCTComponentFramework friendsPlugin] sendApiCallWithService:serviceEmail
                                                                                 item:itemHashedTag
                                                                               method:[arguments stringForKey:@"method"]
                                                                               params:[arguments stringForKey:@"params"]
                                                                                  tag:[arguments stringForKey:@"tag"]];
                    }];
                }
                return NO;
            } else if ([MCT_CAMERA_URL_HOST isEqualToString:host]) {
                if ([@"/startScanningQrCode" isEqualToString:request.URL.path]) {
                    NSDictionary *arguments = [self queryParametersFromRequest:request];
                    NSString *requestId = [arguments objectForKey:@"id"];
                    NSString *cameraType = [arguments objectForKey:@"camera_type"];

                    if (!IS_CONTENT_BRANDING_APP) {
                        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"startScanningQrCode is not supported in your app" forKey:@"exception"];
                        [self deliverCallbackToJsWithRequestId:requestId result: dict];
                        return;
                    }

                    if (![MCTCameraTypes containsObject:cameraType]) {
                        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                        [dict setString:@"Unsupported camera type" forKey:@"exception"];
                        [self deliverCallbackToJsWithRequestId:requestId
                                                         error:dict];
                        return;
                    }

                    if (self.cameraController) {
                        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                        [dict setString:@"Camera was already open" forKey:@"exception"];
                        [self deliverCallbackToJsWithRequestId:requestId
                                                         error:dict];
                        return;
                    }
                    self.cameraType = cameraType;

                    if (self.wkWebView) {
                        if (self.wkWebView.hidden == NO) {
                            [self startScanning];
                        }
                    } else if (self.webView.hidden == NO) {
                        [self startScanning];
                    }

                    [self deliverCallbackToJsWithRequestId:requestId result:[NSDictionary dictionary]];
                } else if ([@"/stopScanningQrCode" isEqualToString:request.URL.path]) {
                    NSDictionary *arguments = [self queryParametersFromRequest:request];
                    NSString *requestId = [arguments objectForKey:@"id"];
                    NSString *cameraType = [arguments objectForKey:@"camera_type"];

                    if (!IS_CONTENT_BRANDING_APP) {
                        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"stopScanningQrCode is not supported in your app" forKey:@"exception"];
                        [self deliverCallbackToJsWithRequestId:requestId result: dict];
                        return;
                    }

                    if (![MCTCameraTypes containsObject:cameraType]) {
                        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                        [dict setString:@"Unsupported camera type" forKey:@"exception"];

                        [self deliverCallbackToJsWithRequestId:requestId
                                                         error:dict];
                        return;
                    }

                    [self stopScanning:self.cameraController];
                    [self deliverCallbackToJsWithRequestId:requestId result:[NSDictionary dictionary]];
                }
                return NO;
            }
        }
        return NO;
    }
    LOG(@"shouldStartLoadWithRequest: %@", request);
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([self isExternalUrl:request.URL.absoluteString]) {
            [[UIApplication sharedApplication] openURL:request.URL];
            return NO;
        } else if ([request.URL.scheme isEqualToString:@"tel"]) {
            NSString *phoneNumber = [request.URL absoluteString];
            if ([phoneNumber hasPrefix:@"tel://"]) {
                phoneNumber = [phoneNumber substringFromIndex:[@"tel://" length]];
            } else {
                phoneNumber = [phoneNumber substringFromIndex:[@"tel:" length]];
            }

            self.currentAlertView = [MCTUIUtils showAlertViewForPhoneNumber:phoneNumber withDelegate:self andTag:-1];
            self.currentURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",
                                                    [phoneNumber stringByReplacingOccurrencesOfString:@" "
                                                                                           withString:@""]]];
            return NO;
        } else if ([request.URL.scheme isEqualToString:@"poke"]) {
            [self pokeWithTag:[request.URL.absoluteString substringFromIndex:[@"poke://" length]]];
            return NO;
        } else if ([request.URL.scheme hasPrefix:@"http"]) {
            if (uiWebView) {
                if (self.webView == uiWebView) {
                    if (self.cameraController) {
                        self.wasScanningForQRCodes = YES;
                        [self stopScanning:self.cameraController];
                    } else {
                        self.wasScanningForQRCodes = NO;
                    }
                    self.webViewHttp.scalesPageToFit = YES;
                    [self.webViewHttp loadRequest:request];
                    self.webView.hidden = YES;
                    self.webViewHttp.hidden = NO;
                    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                    [self.navigationController setNavigationBarHidden:NO animated:YES];
                    self.backButtonBackup = self.navigationItem.leftBarButtonItem;
                    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                                             style:UIBarButtonItemStylePlain
                                                                                            target:self
                                                                                            action:@selector(closeHTTPWebViewClicked:)];
                    self.navigationItem.title = NSLocalizedString(@"Loading ...", nil);
                    return NO;
                } else if (self.webViewHttp == uiWebView) {
                    return YES;
                } else {
                    BUG(@"We are loading http requests in unknown uiWebView...");
                }
            } else {
                if (self.wkWebView == wkWebView) {
                    if (self.bigScanningPreviewTimer) {
                        [self.bigScanningPreviewTimer invalidate];
                        MCT_RELEASE(self.bigScanningPreviewTimer);
                    }
                    if (self.cameraController) {
                        self.wasScanningForQRCodes = YES;
                        [self stopScanning:self.cameraController];
                    } else {
                        self.wasScanningForQRCodes = NO;
                    }
                    [self.wkWebViewHttp loadRequest:request];
                    self.wkWebView.hidden = YES;
                    self.wkWebViewHttp.hidden = NO;
                    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                    [self.navigationController setNavigationBarHidden:NO animated:YES];
                    self.backButtonBackup = self.navigationItem.leftBarButtonItem;
                    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                                             style:UIBarButtonItemStylePlain
                                                                                            target:self
                                                                                            action:@selector(closeHTTPWebViewClicked:)];
                    self.navigationItem.title = NSLocalizedString(@"Loading ...", nil);
                    return NO;
                } else if (self.wkWebViewHttp == wkWebView) {
                    return YES;
                } else {
                    BUG(@"We are loading http requests in unknown wkWebView...");
                }
            }
        }
    }
    return YES;
}

- (void)closeHTTPWebViewClicked:(id)sender
{
    LOG(@"closeHTTPWebViewClicked");
    self.navigationItem.leftBarButtonItem = self.backButtonBackup;
    if (IS_CONTENT_BRANDING_APP) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    if (self.wkWebView) {
        self.wkWebViewHttp.hidden = YES;
        self.wkWebView.hidden = NO;
        [self.wkWebViewHttp loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    } else {
        self.webViewHttp.hidden = YES;
        self.webView.hidden = NO;
        [self.webViewHttp loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    }
    if (self.wasScanningForQRCodes) {
        self.wasScanningForQRCodes = NO;
        [self startScanning];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    T_UI();
    return [self shouldOverrideLoadingWithRequest:request navigationType:navigationType uiWebView:webView wkWebView:nil];
}

#pragma mark -
#pragma mark Help functions

- (BOOL)isExternalUrl:(NSString *)url
{
    T_UI();
    NSRange r = [url range];
    for (NSString *pattern in self.brandingResult.externalUrlPatterns) {
        if ([[NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil] firstMatchInString:url
                                                                                                       options:0
                                                                                                         range:r]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)executeJS:(NSString *)command
{
    T_UI();
    if (!self.rogerthatJSLibSet)
        return;
    LOG(@"Executing js command: %@", command);
    if (self.wkWebView) {
        [self.wkWebView evaluateJavaScript:command completionHandler:^(id result, NSError *error) {
            if (error) {
                ERROR(@"js command failed: %@\n%@", command, error);
            } else {
                LOG(@"js command success: %@", result);
            }
        }];
        return nil;
    } else {
        NSString *result = [self.webView stringByEvaluatingJavaScriptFromString:command];
        if (result == nil) {
            ERROR(@"js command failed: %@", command);
        }
        return result;
    }
}

- (NSString *)toJSONRepresentation:(NSObject *)anObject
{
    if (anObject == nil) {
        return @"null";
    }

    return [anObject MCT_JSONRepresentation];
}

- (void)deliverAllApiCallbacksToJs
{
    T_UI();
    if (!self.apiResultHandlerSet) {
        LOG(@"apiCallResultHandler not set, thus not delivering any api call responses.");
        return;
    }

    MCTFriendStore *store = [[MCTComponentFramework friendsPlugin] store];

    for (MCTServiceApiCallbackResult *r in [store serviceApiCallbackResulstWithService:self.service.email
                                                                                  item:self.item.hashedTag]) {
        [self deliverApiCallbackToJsWithResult:r];
        [store removeServiceApiCallWithId:r.idX];
    }
}

- (void)deliverApiCallbackToJsWithResult:(MCTServiceApiCallbackResult *)r
{
    T_UI();
    [self executeJS:[NSString stringWithFormat:@"rogerthat.api._setResult(%@, %@, %@, %@)",
                     [self toJSONRepresentation:r.method], [self toJSONRepresentation:r.result],
                     [self toJSONRepresentation:r.error], [self toJSONRepresentation:r.tag]]];
}

- (void)deliverFBCallbackToJsWithRequestId:(NSString *)requestId result:(NSDictionary *)resultDict
{
    T_UI();
    [self executeJS:[NSString stringWithFormat:@"rogerthat.facebook._setResult('%@', %@, null)",
                     requestId, [self toJSONRepresentation:resultDict]]];
}

- (void)deliverFBCallbackToJsWithRequestId:(NSString *)requestId error:(NSDictionary *)errorDict
{
    T_UI();
    [self executeJS:[NSString stringWithFormat:@"rogerthat.facebook._setResult('%@', null, %@)",
                     requestId, [self toJSONRepresentation:errorDict]]];
}

- (void)deliverCallbackToJsWithRequestId:(NSString *)requestId result:(NSDictionary *)resultDict
{
    T_UI();
    [self executeJS:[NSString stringWithFormat:@"rogerthat._setResult('%@', %@, null)",
                     requestId, [self toJSONRepresentation:resultDict]]];
}

- (void)deliverCallbackToJsWithRequestId:(NSString *)requestId error:(NSDictionary *)errorDict
{
    T_UI();
    [self executeJS:[NSString stringWithFormat:@"rogerthat._setResult('%@', null, %@)",
                     requestId, [self toJSONRepresentation:errorDict]]];
}

+ (NSDictionary *)errorDictFromFBErorr:(NSError *)error
{
    T_UI();
    NSString *errorType = (error == nil || error.fberrorCategory == FBErrorCategoryUserCancelled) ? @"CANCEL" : @"ERROR";
    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               errorType, @"type",
                               error.fberrorUserMessage, @"exception", nil];
    return errorDict;
}


#pragma mark -
#pragma mark Javascript interface

- (void)facebookLoginWithId:(NSString *)requestId permissions:(NSArray *)permissions
{
    T_UI();
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_FB_LOGIN
                                                            onQueue:[MCTComponentFramework mainQueue]];
    self.fbRequestId = requestId;
    self.fbParams = nil;
    [[MCTComponentFramework appDelegate] ensureOpenActiveFBSessionWithReadPermissions:permissions
                                                                   resultIntentAction:kINTENT_FB_LOGIN
                                                                   allowFastAppSwitch:NO
                                                                   fromViewController:self];
}

- (void)facebookPostWithId:(NSString *)requestId postParams:(NSDictionary *)postParams
{
    T_UI();
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_FB_POST
                                                            onQueue:[MCTComponentFramework mainQueue]];
    self.fbRequestId = requestId;
    self.fbParams = postParams;
    LOG(@"%@", self.fbParams);
    [[MCTComponentFramework appDelegate] ensureOpenActiveFBSessionWithReadPermissions:@[@"email", @"user_friends"]
                                                                   resultIntentAction:kINTENT_FB_POST
                                                                   allowFastAppSwitch:NO
                                                                   fromViewController:self];
}

- (void)facebookTickerWithId:(NSString *)requestId arguments:(NSDictionary *)arguments
{
    T_UI();
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_FB_TICKER
                                                            onQueue:[MCTComponentFramework mainQueue]];
    NSDictionary *params = [[arguments stringForKey:@"postParams"] MCT_JSONValue];
    NSString *graphPath = [arguments stringForKey:@"type"];
    self.fbRequestId = requestId;
    self.fbParams = [NSDictionary dictionaryWithObjectsAndKeys:params, @"postParams", graphPath, @"graphPath", nil];
    LOG(@"%@", self.fbParams);

    [[MCTComponentFramework appDelegate] ensureOpenActiveFBSessionWithPublishPermissions:@[@"publish_actions"]
                                                                      resultIntentAction:kINTENT_FB_TICKER
                                                                      allowFastAppSwitch:NO
                                                                      fromViewController:self];
}

#pragma mark -
#pragma mark FBFriendPickerDelegate

- (void)dismissViewController
{
    T_UI();
    IF_IOS5_OR_GREATER({
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    IF_PRE_IOS5({
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)facebookViewControllerCancelWasPressed:(FBFriendPickerViewController *)friendPickerVC
{
    T_UI();
    [self dismissViewController];

    NSString *requestId = [NSString stringWithString:self.fbRequestId];

    self.fbRequestId = nil;
    self.fbParams = nil;

    [self deliverFBCallbackToJsWithRequestId:requestId error:[MCTServiceScreenBrandingVC errorDictFromFBErorr:nil]];

    LOG(@"Friend selection cancelled.");
}

- (void)facebookViewControllerDoneWasPressed:(FBFriendPickerViewController *)friendPickerVC
{
    T_UI();
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.fbParams];
    NSString *requestId = [self.fbRequestId copy];

    self.fbRequestId = nil;
    self.fbParams = nil;

    if ([friendPickerVC.selection count]) {
        NSMutableString *tags = [NSMutableString stringWithString:((id<FBGraphUser>)[friendPickerVC.selection firstObject]).objectID];
        for (int i = 1; i < [friendPickerVC.selection count]; i++) {
            [tags appendString:@","];
            [tags appendString:((id<FBGraphUser>)[friendPickerVC.selection objectAtIndex:i]).objectID];
        }

        [params setObject:tags forKey:@"tags"];
    }

    LOG(@"me/feed --> %@", params);
    FBRequest *request = [FBRequest requestWithGraphPath:@"me/feed"
                                              parameters:params
                                              HTTPMethod:@"POST"];

    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            [self deliverFBCallbackToJsWithRequestId:requestId error:[MCTServiceScreenBrandingVC errorDictFromFBErorr:error]];
        } else {
            NSString *postId = [(NSDictionary *) result stringForKey:@"id"];
            [self deliverFBCallbackToJsWithRequestId:requestId
                                              result:[NSDictionary dictionaryWithObject:postId forKey:@"postId"]];
        }
    }];

    [self dismissViewController];
}

#pragma mark -
#pragma mark Pokes

- (void)loadMessageWithKey:(NSString *)key
{
    T_UI();
    MCT_RELEASE(self.currentActionSheet);
    [self.navigationController pushViewController:[MCTMessageDetailVC viewControllerWithMessageKey:key] animated:YES];
}

- (void)pokeWithTag:(NSString *)tag
{
    T_UI();
    NSString *context = [NSString stringWithFormat:@"SP_%@", [MCTUtils guid]];
    NSString *email = self.service.email;
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [[MCTComponentFramework friendsPlugin] pokeService:email
                                             withHashedTag:tag
                                                   context:context];
    }];

    if ([MCTUtils connectedToInternetAndXMPP]) {
        [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                        forIntentAction:kINTENT_MESSAGE_RECEIVED_HIGH_PRIO
                                                                onQueue:[MCTComponentFramework mainQueue]];
        self.context = context;
        self.pokePressTime = [MCTUtils currentTimeMillis];

        self.currentActionSheet = [MCTUIUtils showProgressActionSheetWithTitle:NSLocalizedString(@"Processing ...", nil)
                                                              inViewController:self];
        [self performSelector:@selector(setProgress) withObject:nil afterDelay:0.08];
    } else {
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:NSLocalizedString(@"Action will start when you have network connectivity.", nil)];
    }
}

- (void)setProgress
{
    T_UI();
    UIProgressView *progressView = (UIProgressView *) [self.currentActionSheet viewWithTag:1];
    float progress = [MCTUtils currentTimeMillis] - self.pokePressTime;
    if (self.pokePressTime && progress < 10000) {
        progressView.progress = progress / 10000.0f;

        [self performSelector:@selector(setProgress) withObject:nil afterDelay:0.08];
    } else {
        progressView.progress = 1;
        MCT_RELEASE(self.currentActionSheet);
        MCT_RELEASE(self.context);
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:NSLocalizedString(@"Action scheduled successfully", nil)];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    // MCT_TAG_ASK_CAMERA_PERMISSION and MCT_TAG_GO_TO_CAMERA_SETTINGS alertViews are shown by MCTScannerVC checkScanningSupportedInVC:

    if (alertView.tag == MCT_TAG_ASK_CAMERA_PERMISSION) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self startScanning];
                    });
                }
            }];
        }
    } else if (alertView.tag == MCT_TAG_GO_TO_CAMERA_SETTINGS) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    } else if (buttonIndex != alertView.cancelButtonIndex) {
        [[UIApplication sharedApplication] openURL:self.currentURL];
        MCT_RELEASE(self.currentURL);
    }
    MCT_RELEASE(self.currentAlertView);
}

#pragma mark -
#pragma mark MCTIntent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_MESSAGE_RECEIVED_HIGH_PRIO) {
        if (self.context && [self.context isEqualToString:[intent stringForKey:@"context"]]) {
            [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                              forIntentAction:kINTENT_MESSAGE_RECEIVED_HIGH_PRIO];
            MCT_RELEASE(self.context);

            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setProgress) object:nil];
            ((UIProgressView *)[self.currentActionSheet viewWithTag:1]).progress = 1;

            [self performSelector:@selector(loadMessageWithKey:)
                       withObject:[intent stringForKey:@"message_key"]
                       afterDelay:0.2];
        }
    }

    else if (intent.action == kINTENT_FB_LOGIN
             || intent.action == kINTENT_FB_POST
             || intent.action == kINTENT_FB_TICKER) {

        if (self.fbRequestId == nil)
            return;

        [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                          forIntentAction:intent.action];

        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.fbParams];
        NSString *requestId = [NSString stringWithString:self.fbRequestId];

        self.fbRequestId = nil;
        self.fbParams = nil;

        if ([intent boolForKey:@"error"]) {
            NSString *errorType = [intent boolForKey:@"canceled"] ? @"CANCEL" : @"ERROR";
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       errorType, @"type",
                                       [intent stringForKey:@"fberrorUserMessage"], @"exception", nil];

            [self deliverFBCallbackToJsWithRequestId:requestId error:errorDict];

        } else if ([FBSession activeSession].isOpen) {
            if (intent.action == kINTENT_FB_LOGIN) {
                [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if (error) {
                        [self deliverFBCallbackToJsWithRequestId:requestId error:[MCTServiceScreenBrandingVC errorDictFromFBErorr:error]];
                    } else if (result) {
                        [self deliverFBCallbackToJsWithRequestId:requestId result:(FBGraphObject *)result];
                    }
                }];
            }

            else if (intent.action == kINTENT_FB_POST) {
                [FBWebDialogs presentFeedDialogModallyWithSession:[FBSession activeSession]
                                                       parameters:params
                                                          handler:
                 ^(FBWebDialogResult result, NSURL *resultURL, NSError *error2) {
                     if (error2) {
                         [self deliverFBCallbackToJsWithRequestId:requestId error:[MCTServiceScreenBrandingVC errorDictFromFBErorr:error2]];
                     } else if (result == FBWebDialogResultDialogCompleted) {
                         NSArray *splitted = [[resultURL absoluteString] componentsSeparatedByString:@"?"];
                         if ([splitted count] == 2) {
                             NSDictionary *post = [NSDictionary gtm_dictionaryWithHttpArgumentsString:[splitted lastObject]];
                             NSDictionary *r = [NSDictionary dictionaryWithObject:[post objectForKey:@"post_id"]
                                                                           forKey:@"postId"];
                             [self deliverFBCallbackToJsWithRequestId:requestId result:r];
                         } else {
                             LOG(@"User clicked cancel button");
                             [self deliverFBCallbackToJsWithRequestId:requestId error:[MCTServiceScreenBrandingVC errorDictFromFBErorr:nil]];
                         }
                     } else {
                         LOG(@"User clicked close button");
                         [self deliverFBCallbackToJsWithRequestId:requestId error:[MCTServiceScreenBrandingVC errorDictFromFBErorr:nil]];
                     }
                 }];
            }

            else if (intent.action == kINTENT_FB_TICKER) {
                if ([[FBSession activeSession].permissions containsObject:@"publish_actions"]) {
                    NSDictionary *postParams = [params objectForKey:@"postParams"];
                    NSString *graphPath = [params stringForKey:@"graphPath"];

                    FBRequest *request = [FBRequest requestWithGraphPath:graphPath
                                                              parameters:postParams
                                                              HTTPMethod:@"POST"];
                    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if (error) {
                            [self deliverFBCallbackToJsWithRequestId:requestId error:[MCTServiceScreenBrandingVC errorDictFromFBErorr:error]];
                        } else {
                            NSString *postId = [(NSDictionary *) result stringForKey:@"id"];
                            NSDictionary *r = [NSDictionary dictionaryWithObject:postId forKey:@"postId"];
                            [self deliverFBCallbackToJsWithRequestId:requestId result:r];
                        }
                    }];
                } else {
                    [self deliverFBCallbackToJsWithRequestId:requestId error:[MCTServiceScreenBrandingVC errorDictFromFBErorr:nil]];
                }
            }
        }
    }

    else if (intent.action == kINTENT_SERVICE_API_CALL_ANSWERED) {
        if ([self.service.email isEqualToString:[intent stringForKey:@"service"]]
            && [self.item.hashedTag isEqualToString:[intent stringForKey:@"item"]]) {
            [self deliverAllApiCallbacksToJs];
        }
    }

    else if (intent.action == kINTENT_SERVICE_DATA_UPDATED) {
        if ([self.service.email isEqualToString:[intent stringForKey:@"email"]]) {
            NSArray *data = [[[MCTComponentFramework friendsPlugin] store] friendDataWithEmail:self.service.email];
            if ([intent boolForKey:@"user_data"]) {
                [self executeJS:[NSString stringWithFormat:@"rogerthat._userDataUpdated(%@)", [[data objectAtIndex:0] MCT_JSONRepresentation]]];
            }
            if ([intent boolForKey:@"service_data"]) {
                [self executeJS:[NSString stringWithFormat:@"rogerthat._serviceDataUpdated(%@)", [[data objectAtIndex:1] MCT_JSONRepresentation]]];
            }
        }
    }

    else if (intent.action == kINTENT_BEACON_IN_REACH) {
        if ([self.service.email isEqualToString:[intent stringForKey:@"email"]]) {
            [self executeJS:[NSString stringWithFormat:@"rogerthat._onBeaconInReach(%@)", [intent stringForKey:@"beacon_json"]]];
        }
    }

    else if (intent.action == kINTENT_BEACON_OUT_OF_REACH) {
        if ([self.service.email isEqualToString:[intent stringForKey:@"email"]]) {
            [self executeJS:[NSString stringWithFormat:@"rogerthat._onBeaconOutOfReach(%@)", [intent stringForKey:@"beacon_json"]]];
        }
    } else if (intent.action == kINTENT_USER_INFO_RETRIEVED) {
        if ([intent boolForKey:@"success"]) {
            NSString *rawUrl = [intent stringForKey:@"hash"];

            NSMutableDictionary *userDetails = [NSMutableDictionary dictionary];
            [userDetails setString:[intent stringForKey:@"email"] forKey:@"email"];
            [userDetails setString:[intent stringForKey:@"name"] forKey:@"name"];
            [userDetails setString:[intent stringForKey:@"app_id"] forKey:@"appId"];

            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setString:@"resolved" forKey:@"status"];
            [dict setString:rawUrl forKey:@"content"];
            [dict setObject:userDetails forKey:@"userDetails"];
            [self executeJS:[NSString stringWithFormat:@"rogerthat._qrCodeScanned(%@)", [self toJSONRepresentation:dict]]];

        } else {
            NSString *errorMessage = [intent hasStringKey:@"errorMessage"] ? [intent stringForKey:@"errorMessage"] : nil;
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setString:@"error" forKey:@"status"];
            [dict setString:errorMessage forKey:@"content"];
            [self executeJS:[NSString stringWithFormat:@"rogerthat._qrCodeScanned(%@)", [self toJSONRepresentation:dict]]];
        }
    }

    if (IS_CONTENT_BRANDING_APP) {
        if (intent.action == kINTENT_SERVICE_BRANDING_RETRIEVED || intent.action == kINTENT_FRIEND_MODIFIED) {
            if ([self.service.email isEqualToString:[intent stringForKey:@"email"]]) {
                MCTFriend *f = [[[MCTComponentFramework friendsPlugin] store] friendByEmail:self.service.email];
                if (intent.action == kINTENT_SERVICE_BRANDING_RETRIEVED) {
                    if (![self.service.contentBrandingHash isEqualToString:f.contentBrandingHash]) {
                        if ([f.contentBrandingHash isEqualToString:[intent stringForKey: @"branding_key"]]) {
                            self.service = f;
                            self.item.screenBranding = f.contentBrandingHash;
                            if (self.wkWebView) {
                                if (self.wkWebView.hidden == NO) {
                                    [self stopScanning:self.cameraController];
                                }
                            } else if (self.webView.hidden == NO) {
                                [self stopScanning:self.cameraController];
                            }
                            self.rogerthatJSLibSet = NO;
                            [self displayBranding];
                        }
                    }
                } else if (intent.action == kINTENT_FRIEND_MODIFIED) {
                    if (![self.service.contentBrandingHash isEqualToString:f.contentBrandingHash]) {
                        MCTBrandingMgr *brandingMgr = [MCTComponentFramework brandingMgr];
                        if ([brandingMgr isBrandingAvailable:f.contentBrandingHash]) {
                            self.service = f;
                            self.item.screenBranding = f.contentBrandingHash;
                            if (self.wkWebView) {
                                if (self.wkWebView.hidden == NO) {
                                    [self stopScanning:self.cameraController];
                                }
                            } else if (self.webView.hidden == NO) {
                                [self stopScanning:self.cameraController];
                            }
                            self.rogerthatJSLibSet = NO;
                            [self displayBranding];
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - WKWebView Delegate Methods

/*
 * Called on iOS devices that have WKWebView when the web view wants to start navigation.
 * Note that it calls shouldStartDecidePolicy, which is a shared delegate method,
 * but it's essentially passing the result of that method into decisionHandler, which is a block.
 */
- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction *) navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler
{
    if (self.wkWebView == webView) {
        NSURLRequest *request = navigationAction.request;
        BOOL shouldAllow = [self shouldOverrideLoadingWithRequest:request navigationType:UIWebViewNavigationTypeLinkClicked uiWebView:nil wkWebView:webView];
        LOG(shouldAllow ? @"decidePolicyForNavigationAction Allowed" : @"decidePolicyForNavigationAction Canceled");
        decisionHandler(shouldAllow ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

/*
 * Called on iOS devices that have WKWebView when the web view starts loading a URL request.
 * Note that it just calls didStartNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didStartProvisionalNavigation: (WKNavigation *) navigation
{
    LOG(@"didStartProvisionalNavigation");
}

/*
 * Called on iOS devices that have WKWebView when the web view fails to load a URL request.
 * Note that it just calls failLoadOrNavigation, which is a shared delegate method,
 * but it has to retrieve the active request from the web view as WKNavigation doesn't contain a reference to it.
 */
- (void) webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    LOG(@"didFailProvisionalNavigation %@", error);
}

/*
 * Called on iOS devices that have WKWebView when the web view begins loading a URL request.
 * This could call some sort of shared delegate method, but is unused currently.
 */
- (void) webView: (WKWebView *) webView didCommitNavigation: (WKNavigation *) navigation
{
    LOG(@"didCommitNavigation");
}

/*
 * Called on iOS devices that have WKWebView when the web view fails to load a URL request.
 * Note that it just calls failLoadOrNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didFailNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    LOG(@"didFailNavigation %@", error);
}

/*
 * Called on iOS devices that have WKWebView when the web view finishes loading a URL request.
 * Note that it just calls finishLoadOrNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didFinishNavigation: (WKNavigation *) navigation
{
    if (self.wkWebViewHttp == webView) {
        self.navigationItem.title = webView.title;
        return;
    }
    if (self.wkWebView != webView)
        return;

    LOG(@"didFinishNavigation");
    if (!self.rogerthatJSLibSet) {
        self.rogerthatJSLibSet = YES;
        [self executeJS:@"rogerthat._bridgeLogging()"];

        NSDictionary *info = [[MCTComponentFramework friendsPlugin] getRogerthatUserAndServiceInfoByService:self.service];

        [self executeJS:[NSString stringWithFormat:@"rogerthat._setInfo(%@)", [info MCT_JSONRepresentation]]];
    }
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    LOG(@"webViewWebContentProcessDidTerminate");
}

#pragma mark - ZXingDelegate

- (void)startScanning
{
    if (![MCTScannerVC checkScanningSupportedInVC:self])
        return;

    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGFloat w = appFrame.size.width;
    CGFloat h = appFrame.size.height;

    LOG(@"displayWidth: %f", w);
    LOG(@"displayHeight: %f", h);
    CGFloat previewSizeSmallW = w / 5;
    CGFloat previewSizeSmallH = h / 5;
    LOG(@"previewSizeSmallW: %f", previewSizeSmallW);
    LOG(@"previewSizeSmallH: %f", previewSizeSmallH);

    CGRect frame = CGRectMake(0, 0, previewSizeSmallW, previewSizeSmallH);

    BOOL isBackCamera = [MCTCameraTypeBack isEqualToString:self.cameraType];
    self.cameraController = [MCTZXingUtils ZXingWidgetWithDelegate:self frame:frame isBackCamera:isBackCamera];
    [self addChildViewController:self.cameraController];
    self.cameraController.view.frame = frame;
    self.cameraController.view.alpha = 0.4;
    [self.view addSubview:self.cameraController.view];
    [self.cameraController didMoveToParentViewController:self];

    UITapGestureRecognizer *cameraTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleCameraViewTap)];
    [self.cameraController.view addGestureRecognizer:cameraTap];
}

- (void)onUpdateBigScanningPreviewTimeout:(NSTimer *)timer
{
    T_UI();
    if (timer == self.bigScanningPreviewTimer) {
        [self.bigScanningPreviewTimer invalidate];
        MCT_RELEASE(self.bigScanningPreviewTimer);
        if (self.cameraController)
            [self.cameraController updatePreviewSize];
    }
}

- (void)handleCameraViewTap
{
    BOOL isSmallPreview = [self.cameraController updatePreviewSize];
    if (isSmallPreview) {
        if (self.bigScanningPreviewTimer) {
            [self.bigScanningPreviewTimer invalidate];
            MCT_RELEASE(self.bigScanningPreviewTimer);
        }
    } else {
        self.bigScanningPreviewTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                                        target:self
                                                                      selector:@selector(onUpdateBigScanningPreviewTimeout:)
                                                                      userInfo:nil
                                                                       repeats:NO];
    }
}

- (void)stopScanning:(ZXingWidgetController*)controller
{
    if (controller == nil) {
        return;
    }
    [controller willMoveToParentViewController:self];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
    if (self.cameraController == controller) {
        MCT_RELEASE(self.cameraController);
    }
}

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result
{
    T_UI();
    LOG(@"Scanned %@", result);

    if ([MCTUtils isEmptyOrWhitespaceString:result]) {
        [self stopScanning:controller];
        return;
    }

    result = [result uppercaseString];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([result hasPrefix:@"HTTP://"] || [result hasPrefix:@"HTTPS://"]) {
        if ([MCTUtils connectedToInternet]) {
            [dict setString:@"resolving" forKey:@"status"];
            [self requestFullUrlWithShortUrl:result];
        } else {
            [dict setString:@"resolved" forKey:@"status"];
        }
    } else {
        [dict setString:@"resolved" forKey:@"status"];
    }

    [dict setString:result forKey:@"content"];

    [self executeJS:[NSString stringWithFormat:@"rogerthat._qrCodeScanned(%@)", [self toJSONRepresentation:dict]]];
    [self stopScanning:controller];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller
{
    T_UI();
    [self stopScanning:controller];
}

- (void)requestFullUrlWithShortUrl:(NSString *)shortUrl
{
    T_UI();
    if (self.httpRequest) {
        [self.httpRequest clearDelegatesAndCancel];
        MCT_RELEASE(self.httpRequest);
    }
    self.httpRequest = [MCTHTTPRequest requestWithURL:[NSURL URLWithString:shortUrl]];
    self.httpRequest.delegate = self;
    self.httpRequest.didFailSelector = @selector(onResolveShortUrlFailed:);
    self.httpRequest.didFinishSelector = @selector(onResolveShortUrlFinished:);
    self.httpRequest.timeOutSeconds = 60.0;
    self.httpRequest.shouldRedirect = NO;
    self.httpRequest.validatesSecureCertificate = YES;
    [self.httpRequest addRequestHeader:@"User-Agent" value:@"Rogerthat"];
    [self.httpRequest setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [[MCTComponentFramework downloadQueue] addOperation:self.httpRequest];
}

- (void)onResolveShortUrlFailed:(MCTHTTPRequest *)request
{
    T_UI();
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setString:@"resolved" forKey:@"status"];
    [dict setString:[request.url absoluteString] forKey:@"content"];
    [self executeJS:[NSString stringWithFormat:@"rogerthat._qrCodeScanned(%@)", [self toJSONRepresentation:dict]]];

    [request clearDelegatesAndCancel];
    if (request == self.httpRequest) {
        MCT_RELEASE(self.httpRequest);
    }
}

- (void)onResolveShortUrlFinished:(MCTHTTPRequest *)request
{
    T_UI();
    if (request.responseStatusCode == HTTP_MOVED_PERMANENTLY || request.responseStatusCode == HTTP_MOVED_TEMPORARILY) {
        NSString *fullUrl = [request.responseHeaders stringForKey:@"Location"];

        MCTScanResult *scanResult = [MCTScanResult scanResultWithUrl:fullUrl];
        if (scanResult && scanResult.action == MCTScanResultActionInviteFriend) {
            NSString *emailHash = [scanResult.parameters stringForKey:@"userCode"];
            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                T_BIZZ();
                [[MCTComponentFramework friendsPlugin] requestUserInfoWithEmailHash:emailHash andStoreAvatar:NO allowCrossApp:YES];
            }];
            return;
        }
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setString:@"resolved" forKey:@"status"];
    [dict setString:[request.url absoluteString] forKey:@"content"];
    [self executeJS:[NSString stringWithFormat:@"rogerthat._qrCodeScanned(%@)", [self toJSONRepresentation:dict]]];
}

#pragma mark - AVAudioPlayerDelegate

- (void)stopAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *audioSessionActivateError = nil;
    BOOL setActiveIsSuccess = [audioSession setActive:NO error:&audioSessionActivateError];
    if (!setActiveIsSuccess) {
        LOG(@"audioSessionActivateError NO %@", audioSessionActivateError);
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    T_UI();
    [self stopAudioSession];
    if (player == self.backgroundMusicPlayer) {
        MCT_RELEASE(self.backgroundMusicPlayer);
    } else {
        MCT_RELEASE(player);
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    T_UI();
    [self stopAudioSession];
    if (player == self.backgroundMusicPlayer) {
        MCT_RELEASE(self.backgroundMusicPlayer);
    } else {
        MCT_RELEASE(player);
    }
}

@end