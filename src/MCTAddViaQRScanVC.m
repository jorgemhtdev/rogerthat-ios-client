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

#import "MCTAddViaQRScanVC.h"
#import "MCTComponentFramework.h"
#import "MCTIntent.h"
#import "MCTMenuVC.h"
#import "MCTScannerVC.h"
#import "MCTUIUtils.h"

@interface MCTAddViaQRScanVC ()

- (void)loadQR;

@end

@implementation MCTAddViaQRScanVC


+ (MCTAddViaQRScanVC *)viewController
{
    T_UI();
    MCTAddViaQRScanVC *vc = [[MCTAddViaQRScanVC alloc] initWithNibName:@"addViaQRScan" bundle:nil];
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    [((UIButton *)self.qrButton) setTitle:[NSString stringWithFormat:NSLocalizedString(@"__scan_passport", nil), MCT_PRODUCT_NAME]
                                 forState:UIControlStateNormal];
    self.qrButton = [MCTUIUtils replaceUIButtonWithTTButton:(UIButton *) self.qrButton];
    self.myQrDescription.text = NSLocalizedString(@"Or let someone scan yours.", nil);

    [self loadQR];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGPoint qrImageViewCenter = self.myQrImageView.center;
    CGFloat qrImageViewWidth = MIN(self.myQrImageView.frame.size.height, self.myQrImageView.frame.size.width);
    self.myQrImageView.frame = CGRectMake(self.myQrImageView.frame.origin.x, self.myQrImageView.frame.origin.y, qrImageViewWidth, qrImageViewWidth);
    self.myQrImageView.center = qrImageViewCenter;

    [MCTUIUtils addRoundedBorderToView:self.myQrImageView withBorderColor:[UIColor lightGrayColor] andCornerRadius:5];
}

- (IBAction)onQRButtonTapped:(id)sender
{
    T_UI();

    if (![MCTScannerVC checkScanningSupportedInVC:self])
        return;

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_APPLICATION_OPEN_URL];
    NSString *url = [NSString stringWithFormat:@"%@%@", MCT_PREFIX_ROGERTHAT_URL, MCT_GOTO_QR_SCAN];
    [intent setString:url forKey:@"url"];

    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (void)loadQR
{
    T_UI();
    NSData *qr = [[[MCTComponentFramework systemPlugin] identityStore] qrCode];
    if (qr == nil) {
        [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                        forIntentAction:kINTENT_IDENTITY_QR_RETREIVED
                                                                onQueue:[MCTComponentFramework mainQueue]];
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            [[MCTComponentFramework systemPlugin] requestIdentityQRCode];
        }];
    } else {
        self.myQrImageView.image = [UIImage imageWithData:qr];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    T_UI();
    // MCT_TAG_ASK_CAMERA_PERMISSION and MCT_TAG_GO_TO_CAMERA_SETTINGS alertViews are shown by MCTScannerVC checkScanningSupportedInVC:

    if (alertView.tag == MCT_TAG_ASK_CAMERA_PERMISSION) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_APPLICATION_OPEN_URL];
                        NSString *url = [NSString stringWithFormat:@"%@%@", MCT_PREFIX_ROGERTHAT_URL, MCT_GOTO_QR_SCAN];
                        [intent setString:url forKey:@"url"];

                        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
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
#pragma mark MCTIntent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_IDENTITY_QR_RETREIVED) {
        [self loadQR];
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                          forIntentAction:kINTENT_IDENTITY_QR_RETREIVED];
    }
}

@end