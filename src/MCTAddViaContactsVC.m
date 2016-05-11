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

#import "MCTAddViaContactsVC.h"
#import "MCTComponentFramework.h"
#import "MCTUIUtils.h"

@implementation MCTAddViaContactsVC


+ (MCTAddViaContactsVC *)viewControllerWithParent:(MCTUIViewController *)parent
{
    T_UI();
    MCTAddViaContactsVC *vc = [[MCTAddViaContactsVC alloc] initWithNibName:@"addViaContacts" bundle:nil];
    vc.parentVC = parent;
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    self.phoneDescription.text = [NSString stringWithFormat:NSLocalizedString(@"__add_via_contacts_description", nil), MCT_PRODUCT_NAME];
    [((UIButton *)self.phoneButton) setTitle:NSLocalizedString(@"Scan my address book", nil)
                                    forState:UIControlStateNormal];
    self.phoneButton = [MCTUIUtils replaceUIButtonWithTTButton:(UIButton *) self.phoneButton];
    self.dontWorryLabel.text = NSLocalizedString(@"Don't worry, we'll never store this data.", nil);
    [MCTUIUtils topAlignLabel:self.dontWorryLabel];
}

- (IBAction)onPhoneButtonTapped:(id)sender
{
    T_UI();
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        [[MCTComponentFramework configProvider] deleteStringForKey:MCT_CONFIGKEY_ADDRESSBOOK_SCAN];
        [[MCTComponentFramework friendsPlugin] findRogerthatUsersFromAddressBook];
    }];

    self.dontWorryLabel.hidden = YES;
    self.phoneDescription.text = NSLocalizedString(@"You will get a notification when your address book is scanned.", nil);
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.phoneButton.hidden = YES;
                         [self.spinner startAnimating];
                     }];
}

@end