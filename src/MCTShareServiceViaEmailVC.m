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
#import "MCTShareServiceViaEmailVC.h"
#import "MCTUIUtils.h"


@implementation MCTShareServiceViaEmailVC


+ (MCTShareServiceViaEmailVC *)viewControllerWithParent:(MCTUIViewController<UIAlertViewDelegate> *)parent
                                        andServiceEmail:(NSString *)serviceEmail
                                   andAddressBookEmails:(NSMutableArray *)emails
{
    T_UI();
    MCTShareServiceViaEmailVC *vc = [[MCTShareServiceViaEmailVC alloc] initWithParent:parent];
    vc.serviceEmail = serviceEmail;
    vc.addressBookEmails = emails;
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    self.view.width = [[UIScreen mainScreen] applicationFrame].size.width;
    self.view.backgroundColor = [UIColor MCTMercuryColor];

    [(TTButton *) self.searchButton setTitle:NSLocalizedString(@"Recommend", nil) forState:UIControlStateNormal];
    self.searchDescription.text = NSLocalizedString(@"Enter the e-mail address of the person you want to recommend this service to.", nil);
}

- (void)onSearchButtonTapped:(id)sender
{
    T_UI();
    NSString *email = self.searchTextField.text;
    NSString *serviceEmail = self.serviceEmail;
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [[MCTComponentFramework friendsPlugin] shareService:serviceEmail withFriend:email];
    }];
    self.parentVC.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                            andText:NSLocalizedString(@"The recommendation has been sent", nil)];
    [self.searchTextField resignFirstResponder];
    self.searchTextField.text = nil;
    self.searchButton.enabled = NO;
}

@end