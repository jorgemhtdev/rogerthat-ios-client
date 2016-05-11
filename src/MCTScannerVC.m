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

#import <QuartzCore/QuartzCore.h>

#import "MCTComponentFramework.h"
#import "MCTFriend.h"
#import "MCTFriendDetailVC.h"
#import "MCTMenuVC.h"
#import "MCTOperation.h"
#import "MCTScannerVC.h"
#import "MCTScanResult.h"
#import "MCTServiceDetailVC.h"
#import "MCTSystemPlugin.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"
#import "MCTZXingUtils.h"

#import "NSData+Base64.h"

#define MARGIN 10


static NSString *kMCTScanRogerthatUrl;
static NSString *kMCTScanShortUrl;

@interface MCTScannerVC ()

@property (nonatomic, copy) NSString *url;

- (void)userScannedWithEmailHash:(NSString *)userEmailHash andMetaData:(NSString *)metaData;
- (void)showResultWithUrl:(NSString *)result;
- (void)handleScanResult:(NSString *)result;
- (void)hideZXingController;

@end


@implementation MCTScannerVC



+ (void)initialize
{
    if (!kMCTScanRogerthatUrl) {
        kMCTScanRogerthatUrl = [[NSString alloc] initWithFormat:@"%@/", MCT_HTTPS_BASE_URL];
    }

    if (!kMCTScanShortUrl) {
        kMCTScanShortUrl = [[NSString alloc] initWithFormat:@"%@S/", [kMCTScanRogerthatUrl uppercaseString]];
    }
}

- (void)loadView
{
    T_UI();
    HERE();
    CGRect f = CGRectZero;
    f.size = [MCTUIUtils availableSizeForViewWithController:self];
    self.view = [[UIView alloc] initWithFrame:f];
    [MCTUIUtils setBackgroundPlainToView:self.view];

    CGFloat w = 132;
    CGRect sbFrame = CGRectMake(MARGIN, MARGIN, w, 88);

    self.scanBtn = [TTButton buttonWithStyle:@"embossedButton:" title:NSLocalizedString(@"Tap to scan\nQR code", nil)];
    self.scanBtn.frame = sbFrame;
    self.scanBtn.center = self.view.center;
    [self.scanBtn addTarget:self action:@selector(onScanBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scanBtn];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.view.center;
    self.spinner.hidden = YES;
    [self.view addSubview:self.spinner];

    self.loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, CGRectGetMaxY(self.spinner.frame) + MARGIN, self.view.width - 2*MARGIN, 23)];
    self.loadingLabel.backgroundColor = [UIColor clearColor];
    self.loadingLabel.text = NSLocalizedString(@"Loading Scanner...", nil);
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.loadingLabel];
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Scan", nil);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil];

    self.viewLoaded = YES;
    [self onScanBtnClicked:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    T_UI();
    [super viewWillAppear:animated];
    self.scanBtn.hidden = NO;
    self.loadingLabel.hidden = YES;
    self.spinner.hidden = YES;
    [self.spinner stopAnimating];
}

#pragma mark -

+ (BOOL)checkScanningSupportedInVC:(MCTUIViewController<UIAlertViewDelegate> *)vc
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (vc) {
            vc.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:NSLocalizedString(@"Scanning is not supported on your device", nil)];
            vc.currentAlertView.delegate = vc;
        }
        return NO;
    }

    IF_PRE_IOS8({
        return YES;
    });

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            return YES;

        case AVAuthorizationStatusDenied:
            if (vc) {
                NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Let %@ access camera?", nil), MCT_PRODUCT_NAME];
                NSString *msg = [NSString stringWithFormat:@"%@ %@",
                                 [NSString stringWithFormat:NSLocalizedString(@"To be able to scan QR codes you need to give %@ access to the camera.", nil), MCT_PRODUCT_NAME],
                                 NSLocalizedString(@"Would you like to jump to the Settings app to enable access to the camera?", nil)];
                vc.currentAlertView = [[UIAlertView alloc] initWithTitle:title
                                                                  message:msg
                                                                 delegate:vc
                                                        cancelButtonTitle:NSLocalizedString(@"No", nil)
                                                        otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
                vc.currentAlertView.tag = MCT_TAG_GO_TO_CAMERA_SETTINGS;
                [vc.currentAlertView show];
            }
            return NO;

        case AVAuthorizationStatusNotDetermined:
            if (vc) {
                NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Let %@ access camera?", nil), MCT_PRODUCT_NAME];
                NSString *msg =[NSString stringWithFormat:NSLocalizedString(@"To be able to scan QR codes you need to give %@ access to the camera.", nil), MCT_PRODUCT_NAME];
                vc.currentAlertView = [[UIAlertView alloc] initWithTitle:title
                                                                  message:msg
                                                                 delegate:vc
                                                        cancelButtonTitle:NSLocalizedString(@"Not now", nil)
                                                        otherButtonTitles:NSLocalizedString(@"Give access", nil), nil];
                vc.currentAlertView.tag = MCT_TAG_ASK_CAMERA_PERMISSION;
                [vc.currentAlertView show];
            }
            return NO;

        case AVAuthorizationStatusRestricted:
        default:
            if (vc) {
                vc.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:NSLocalizedString(@"Scanning is not supported on your device", nil)];
                vc.currentAlertView.delegate = vc;
            }
            return NO;
    }
}

- (IBAction)onScanBtnClicked:(id)sender
{
    T_UI();

    if (!self.viewLoaded) {
        LOG(@"View not loaded yet");
        return;
    }

    // This method is sometimes called programmatically - in that case sender is nil
    if (sender) {
        // Someone tapped the scan button
        // Show popup if we do not have a camera
        if (![MCTScannerVC checkScanningSupportedInVC:self])
            return;
    } else {
        // Invoked programmatically (e.g. someone opened menu tab)
        // Do not automatically show popup
        if (![MCTScannerVC checkScanningSupportedInVC:nil])
            return;
    }

    [self.spinner startAnimating];
    self.scanBtn.hidden = YES;
    self.loadingLabel.hidden = NO;
    self.spinner.hidden = NO;

    [MCTZXingUtils presentZXingWidgetWithDelegate:self handleOrientation:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideZXingController)
                                                 name:MCT_NOTIFICATION_BACKGROUND
                                               object:nil];
}

+ (UIViewController *)viewControllerForScanResultWithEmailHash:(NSString *)emailHash
                                                   andMetaData:(NSString *)metaData
                                       andNavigationController:(UINavigationController *)navigationController
                                           andSkipNetworkCheck:(BOOL)skipNetworkCheck
{
    T_UI();
    if (emailHash == nil || [emailHash isEqualToString:[[[MCTComponentFramework systemPlugin] myIdentity] emailHash]])
        return nil;

    // If no poke, check if we are already friends
    if (metaData == nil) {
        MCTFriend *friend = [[[MCTComponentFramework friendsPlugin] store] friendByEmailHash:emailHash];
        if (friend && friend.existence == MCTFriendExistenceActive) {
            NSString *format;
            if (IS_ENTERPRISE_APP || friend.type == MCTFriendTypeService) {
                format = NSLocalizedString(@"You are already connected with\n%@", nil);
            } else {
                format = NSLocalizedString(@"You are already friends with\n%@", nil);
            }

            if (friend.type == MCTFriendTypeService) {
                MCTServiceDetailVC *vc = [MCTServiceDetailVC viewControllerWithService:friend];
                vc.firstShowAlertText = [NSString stringWithFormat:format, [friend displayName]];
                return vc;
            } else {
                MCTFriendDetailVC *vc = [MCTFriendDetailVC viewControllerWithFriend:friend];
                vc.firstShowAlertText = [NSString stringWithFormat:format, [friend displayName]];
                return vc;
            }
        }
    }

    // We are no friends --> Show scanResultVC
    MCTScanResultVC *vc = [MCTScanResultVC viewControllerWithEmailHash:emailHash andMetaData:metaData];
    vc.title = NSLocalizedString(@"Scan result", nil);
    vc.skipConnectionCheck = skipNetworkCheck;
    return vc;
}

- (void)userScannedWithEmailHash:(NSString *)emailHash andMetaData:(NSString *)metaData
{
    T_UI();
    if (emailHash && [emailHash isEqualToString:[[[MCTComponentFramework systemPlugin] myIdentity] emailHash]]) {
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:[NSString stringWithFormat:NSLocalizedString(@"You scanned your own Rogerthat passport", nil), MCT_PRODUCT_NAME]];
        return;
    }
    UIViewController *vc = [MCTScannerVC viewControllerForScanResultWithEmailHash:emailHash
                                                                      andMetaData:metaData
                                                          andNavigationController:self.navigationController
                                                              andSkipNetworkCheck:NO];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)showResultWithUrl:(NSString *)result
{
    T_UI();
    LOG(@"%@",result);
    MCTScanResult *scanResult = [MCTScanResult scanResultWithUrl:result];

    if (scanResult) {
        switch (scanResult.action) {
            case MCTScanResultActionInviteFriend:
            {
                [self userScannedWithEmailHash:[scanResult.parameters stringForKey:@"userCode"]
                                   andMetaData:nil];
                break;
            }
            case MCTScanResultActionService:
            {
                [self userScannedWithEmailHash:[scanResult.parameters stringForKey:@"userCode"]
                                   andMetaData:[scanResult.parameters stringForKey:@"metaData"]];
                break;
            }
            case MCTScanResultActionInvitationWithSecret:
            {
                NSString *userCode = [scanResult.parameters stringForKey:@"userCode"];
                NSString *secret = [scanResult.parameters stringForKey:@"s"];

                if ([[[[MCTComponentFramework systemPlugin] myIdentity] emailHash] isEqualToString:userCode]) {
                    self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:[NSString stringWithFormat:NSLocalizedString(@"You scanned your own Rogerthat passport", nil), MCT_PRODUCT_NAME]];
                    break;
                }

                [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                    T_BIZZ();
                    [[MCTComponentFramework friendsPlugin] ackInvitationWithSecret:secret andInvitorCode:userCode];
                }];

                NSString *userName = [scanResult.parameters stringForKey:@"u"];

                MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_CHANGE_TAB];
                [intent setLong:MCT_MENU_TAB_MESSAGES forKey:@"tab"];
                [intent setString:userName forKey:MCT_CHANGE_TAB_WITH_ALERT_TITLE];
                [intent setString:NSLocalizedString(@"You will receive a confirmation message when you are connected.", nil)
                           forKey:MCT_CHANGE_TAB_WITH_ALERT_MESSAGE];
                [[MCTComponentFramework intentFramework] broadcastIntent:intent];

                break;
            }
            case MCTScanResultActionURL:
            {
                self.url = result;
                NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"The QR code you scanned\nis not a Rogerthat QR code.\n\nDo you wish to open the following web page:\n\n%@", nil), result, MCT_PRODUCT_NAME];
                self.currentAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil)
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"No", nil)
                                                      otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
                self.currentAlertView.tag = MCT_TAG_OPEN_URL;
                [self.currentAlertView show];
                break;
            }
            default:
                break;
        }
    } else {
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:[NSString stringWithFormat:NSLocalizedString(@"The QR code you scanned\nis not a Rogerthat QR code.", nil), MCT_PRODUCT_NAME]];
    }
}

- (void)onResolveShortUrlFailed:(MCTHTTPRequest *)request
{
    T_UI();
    MCT_RELEASE(self.currentActionSheet);
    LOG(@"Failed to resolve '%@' with status code %d and message '%@'", request.url, request.responseStatusCode,
        request.responseStatusMessage);

    [request clearDelegatesAndCancel];
    if (request == self.httpRequest) {
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                       andText:[NSString stringWithFormat:NSLocalizedString(@"Failed to resolve the Rogerthat QR code", nil), MCT_PRODUCT_NAME]];
        MCT_RELEASE(self.httpRequest);
    }
}

- (void)onResolveShortUrlFinished:(MCTHTTPRequest *)request
{
    T_UI();
    MCT_RELEASE(self.currentActionSheet);
    if (request.responseStatusCode == HTTP_MOVED_PERMANENTLY || request.responseStatusCode == HTTP_MOVED_TEMPORARILY) {
        [self showResultWithUrl:[request.responseHeaders stringForKey:@"Location"]];
    } else {
        LOG(@"Failed to resolve '%@' with status code %d and message '%@'", request.url, request.responseStatusCode,
            request.responseStatusMessage);
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                       andText:[NSString stringWithFormat:NSLocalizedString(@"Failed to resolve the Rogerthat QR code", nil), MCT_PRODUCT_NAME]];
    }
}

- (void)requestFullUrlWithShortUrl:(NSString *)shortUrl
{
    T_UI();

    NSMutableString *url = [NSMutableString stringWithCapacity:[shortUrl length]];
    [url appendString:[[kMCTScanShortUrl substringToIndex:[kMCTScanShortUrl length] - 3] lowercaseString]];
    [url appendString:[shortUrl substringFromIndex:[kMCTScanShortUrl length] - 3]];

    if (self.httpRequest) {
        [self.httpRequest clearDelegatesAndCancel];
        MCT_RELEASE(self.httpRequest);
    }
    self.httpRequest = [MCTHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    self.httpRequest.delegate = self;
    self.httpRequest.didFailSelector = @selector(onResolveShortUrlFailed:);
    self.httpRequest.didFinishSelector = @selector(onResolveShortUrlFinished:);
    self.httpRequest.timeOutSeconds = 60.0;
    self.httpRequest.shouldRedirect = NO;
    self.httpRequest.validatesSecureCertificate = YES;
    [self.httpRequest addRequestHeader:@"User-Agent" value:@"Rogerthat"];
    [self.httpRequest setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [[MCTComponentFramework downloadQueue] addOperation:self.httpRequest];

    self.currentActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Resolving QR code", nil)
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                             destructiveButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:nil];

    [MCTUIUtils addProgressViewToActionSheet:self.currentActionSheet];
    [MCTUIUtils showActionSheet:self.currentActionSheet inViewController:self];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (self.httpRequest) {
        [self.httpRequest clearDelegatesAndCancel];
        MCT_RELEASE(self.httpRequest);
    }
    MCT_RELEASE(self.currentAlertView);
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (alertView.tag == MCT_TAG_OPEN_URL) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
        }
        MCT_RELEASE(self.url);
    } else if (alertView.tag == MCT_TAG_ASK_CAMERA_PERMISSION) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self onScanBtnClicked:self];
                    });
                }
            }];
        }
    } else if (alertView.tag == MCT_TAG_GO_TO_CAMERA_SETTINGS) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    MCT_RELEASE(self.currentAlertView);
}

#pragma mark -
#pragma mark ZXingDelegate

- (void)handleScanResult:(NSString *)result
{
    T_UI();
    if ([result hasPrefix:MCT_ROGERTHAT_PREFIX]) {
        result = [result stringByReplacingOccurrencesOfString:MCT_ROGERTHAT_PREFIX
                                                   withString:kMCTScanRogerthatUrl];
    }

    if ([[result uppercaseString] hasPrefix:kMCTScanShortUrl]) {
        if ([MCTUtils connectedToInternet]) {
            [self requestFullUrlWithShortUrl:result];
        } else {
            self.currentAlertView = [MCTUIUtils showNetworkErrorAlert];
        }
    } else {
        [self showResultWithUrl:result];
    }
}

- (void)hideZXingController
{
    T_UI();
    // Fix for device in landscape mode
    if (!UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        [MCTUIUtils forcePortrait];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MCT_NOTIFICATION_BACKGROUND object:nil];
}

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result
{
    T_UI();
    [self hideZXingController];
    LOG(@"Scanned %@", result);
    [self handleScanResult:result];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller
{
    T_UI();
    [self hideZXingController];
}

@end