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
#import "MCTConfigProvider.h"
#import "MCTLocationUsageVC.h"
#import "MCTStartScreenVC.h"
#import "MCTTermsOfServiceVC.h"
#import "MCTUtils.h"
#import "MCTUIUtils.h"

#import "TTGlobalStyle.h"


@interface MCTStartScreenVC ()

@end


@implementation MCTStartScreenVC


+ (MCTStartScreenVC *)viewController
{
    T_UI();
    return [[MCTStartScreenVC alloc] initWithNibName:@"startScreen" bundle:nil];
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    if (MCT_FULL_WIDTH_HEADERS)
    {
        CGRect appFrame = [UIScreen mainScreen].applicationFrame;
        self.imageView.frame = CGRectMake(0,
                                          self.navigationController.navigationBar.height + appFrame.origin.y - 3,
                                          appFrame.size.width,
                                          115 * appFrame.size.width / 320);
        self.imageView.autoresizingMask = UIViewAutoresizingNone;
    }

    self.view.backgroundColor = [UIColor MCTHomeScreenBackgroundColor];
    self.welcomeLbl.textColor = [UIColor MCTHomeScreenTextColor];
    [self changeNavigationControllerAppearanceWithColorScheme:MCTColorSchemeLight
                                               andBackGroundColor:[UIColor MCTHomeScreenBackgroundColor]];

    if (IS_ENTERPRISE_APP) {
        self.welcomeLbl.text = [NSString stringWithFormat:NSLocalizedString(@"__welcome_message_enterprise", nil), MCT_PRODUCT_NAME];
        self.tosBtn.hidden = YES;
        [self.agreeBtn setTitle:NSLocalizedString(@"Start registration", nil) forState:UIControlStateNormal];

    } else {
        self.welcomeLbl.text = [NSString stringWithFormat:NSLocalizedString(@"__welcome_message", nil), MCT_PRODUCT_NAME];
        [self.agreeBtn setTitle:NSLocalizedString(@"Agree and continue", nil) forState:UIControlStateNormal];
        [self.tosBtn setTitle:NSLocalizedString(@"Terms and conditions", nil) forState:UIControlStateNormal];
    }

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Welcome", nil)
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil];

    [MCTRegistrationMgr sendInstallationId];

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MCTUIUtils addGradientToView:self.agreeBtn];
}

#pragma mark -

- (IBAction)onTOSTapped:(id)sender
{
    T_UI();
    [self.navigationController pushViewController:[MCTTermsOfServiceVC viewController] animated:YES];
}

- (IBAction)onAgreeTapped:(id)sender
{
    T_UI();
    
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [[MCTComponentFramework configProvider] setString:@"YES" forKey:MCT_CONFIGKEY_TOS_ACCEPTED];
    }];

    [MCTRegistrationMgr sendRegistrationStep:@"1"];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:[MCTLocationUsageVC viewController]]
                                         animated:YES];
}

@end