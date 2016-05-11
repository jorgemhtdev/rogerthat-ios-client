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

#import "MCTAboutVC.h"
#import "MCTUIUtils.h"


@implementation MCTAboutVC

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;

    self.title = NSLocalizedString(@"About", nil);

    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    CGFloat center = appFrame.size.width / 2;
    CGFloat maxWidth = appFrame.size.width - 40;

    [self.webBtn setTitle:MCT_ABOUT_WEBSITE forState:UIControlStateNormal];

    self.emailLbl.text = MCT_ABOUT_EMAIL;
    self.twitterLbl.text = MCT_ABOUT_TWITTER;
    self.facebookLbl.text = MCT_ABOUT_FACEBOOK;

    self.webBtn.width = fminf(maxWidth, 20 + [MCTUIUtils sizeForLabel:[self.webBtn titleLabel] withWidth:maxWidth].width);
    self.webBtn.centerX = center;
    self.webBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.emailControl.width = fminf(maxWidth, 20 + [MCTUIUtils sizeForLabel:self.emailLbl withWidth:maxWidth].width);
    self.emailControl.centerX = center;
    self.emailControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.twitterControl.width = fminf(maxWidth, 20 + [MCTUIUtils sizeForLabel:self.twitterLbl withWidth:maxWidth].width);
    self.twitterControl.centerX = center;
    self.twitterControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.facebookControl.width = fminf(maxWidth, 20 + [MCTUIUtils sizeForLabel:self.facebookLbl withWidth:maxWidth].width);
    self.facebookControl.centerX = center;
    self.facebookControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    if (MCT_FULL_WIDTH_HEADERS) {
        self.imageView.frame = CGRectMake(0,
                                          self.navigationController.navigationBar.height + appFrame.origin.y - 3,
                                          appFrame.size.width,
                                          115 * appFrame.size.width / 320);
        self.imageView.autoresizingMask = UIViewAutoresizingNone;
    }

    if (IS_ENTERPRISE_APP) {
        self.pleaseVisitLbl.text = [NSString stringWithFormat:NSLocalizedString(@"__about_more_info_enterprise", nil), MCT_PRODUCT_NAME];
        self.proudlyPresentedLbl.text = [NSString stringWithFormat:NSLocalizedString(@"__about_provided_by_enterprise", nil), MCT_PRODUCT_NAME];
    } else {
        self.pleaseVisitLbl.text = [NSString stringWithFormat:NSLocalizedString(@"For more information about Rogerthat and other Rogerthat based products, please visit:", nil), MCT_PRODUCT_NAME];
        self.proudlyPresentedLbl.text = NSLocalizedString(@"Rogerthat is proudly presented by", nil);
    }


    IF_IOS7_OR_GREATER({
        [MCTUIUtils addRoundedBorderToView:self.webBtn withBorderColor:[UIColor clearColor] andCornerRadius:5];
        self.webBtn.backgroundColor = self.pleaseVisitLbl.textColor;
        [self.webBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    });

    IF_PRE_IOS7({
        self.webBtn.height = 37;
    });
}

- (IBAction)onWebBtnClicked:(UIButton *)sender
{
    T_UI();
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MCT_ABOUT_WEBSITE_URL]];
}

- (IBAction)onEmailControlClicked:(UIControl *)sender
{
    T_UI();
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", MCT_ABOUT_EMAIL]]];
}

- (IBAction)onTwitterControlClicked:(UIControl *)sender
{
    T_UI();
    NSURL *twitterAppUrl = [NSURL URLWithString:MCT_ABOUT_TWITTER_APP_URL];
    if ([[UIApplication sharedApplication] canOpenURL:twitterAppUrl]) {
        [[UIApplication sharedApplication] openURL:twitterAppUrl];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MCT_ABOUT_TWITTER_URL]];
    }
}

- (IBAction)onFacebookControlClicked:(UIControl *)sender
{
    T_UI();
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MCT_ABOUT_FACEBOOK_URL]];
}

@end