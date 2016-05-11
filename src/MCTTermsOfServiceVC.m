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

#import "MCTTermsOfServiceVC.h"
#import "MCTUtils.h"
#import "MCTUIUtils.h"


@implementation MCTTermsOfServiceVC


+ (MCTTermsOfServiceVC *)viewController
{
    T_UI();
    return [[MCTTermsOfServiceVC alloc] initWithNibName:@"tos" bundle:nil];
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;

    NSString *url = [NSString stringWithFormat:@"%@%@", MCT_HTTPS_BASE_URL, MCT_TERMS_OF_SERVICE_URL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];

    self.title = NSLocalizedString(@"Terms and conditions", nil);
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    T_UI();
    self.currentActionSheet = [MCTUIUtils showActivityActionSheetWithTitle:NSLocalizedString(@"Loading ...", nil)
                                                          inViewController:self];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    T_UI();
    MCT_RELEASE(self.currentActionSheet);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    T_UI();
    MCT_RELEASE(self.currentActionSheet);

    NSString *reason = nil;
    if ([MCTUtils connectedToInternet]) {
        reason = NSLocalizedString(@"A connection failure occurred.", nil);
    } else {
        reason = NSLocalizedString(@"You are not connected to the internet.", nil);
    }

    NSString *remedy = NSLocalizedString(@"Please check your network configuration and try again later.", nil);
    self.currentAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                     message:[NSString stringWithFormat:@"%@\n%@", reason, remedy]
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                           otherButtonTitles:nil];
    [self.currentAlertView show];
}

@end