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

#import "MCTAddressBook.h"
#import "MCTAddViaEmailVC.h"
#import "MCTComponentFramework.h"
#import "MCTUIUtils.h"

@interface MCTAddViaEmailVC ()

- (void)contactsLoaded:(NSArray *)emails;
- (void)loadContacts;
- (BOOL)isValidEmail;
- (BOOL)shouldShowAutoCompletionTable;
- (void)textDidChange:(NSNotification *)notif;

@end

@implementation MCTAddViaEmailVC


+ (MCTAddViaEmailVC *)viewControllerWithParent:(MCTUIViewController<UIAlertViewDelegate> *)parent
{
    T_UI();
    return [[MCTAddViaEmailVC alloc] initWithParent:parent];
}


- (id)initWithParent:(MCTUIViewController<UIAlertViewDelegate> *)parent
{
    if (self = [super initWithNibName:@"addViaEmail" bundle:nil]) {
        self.parentVC = parent;
    }
    return self;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    [MCTUIUtils addRoundedBorderToView:self.autoCompletionTable withBorderColor:[UIColor grayColor] andCornerRadius:5];
    [self.view addSubview:self.autoCompletionTable];
    self.autoCompletionTable.hidden = YES;
    self.validationLabel.hidden = YES;

    self.searchDescription.text = NSLocalizedString(@"Enter the e-mail address of the person you want to invite.", nil);
    self.searchTextField.placeholder = NSLocalizedString(@"E-mail address", nil);

    NSString *inviteText;
    switch (MCT_FRIENDS_CAPTION) {
        case MCTFriendsCaptionColleagues: {
            inviteText = NSLocalizedString(@"Invite colleague", nil);
            break;
        }
        case MCTFriendsCaptionContacts:{
            inviteText = NSLocalizedString(@"Invite contact", nil);
            break;
        }
        case MCTFriendsCaptionFriends:
        default:{
            inviteText = NSLocalizedString(@"Invite friend", nil);
            break;
        }
    }
    [((UIButton *)self.searchButton) setTitle:inviteText
                                     forState:UIControlStateNormal];
    self.searchButton = [MCTUIUtils replaceUIButtonWithTTButton:(UIButton *) self.searchButton];
    self.validationLabel.text = NSLocalizedString(@"* Invalid e-mail address", nil);
}

- (void)contactsLoaded:(NSArray *)emails
{
    self.addressBookEmails = emails;
    if (![MCTUtils isEmptyOrWhitespaceString:self.searchTextField.text]) {
        [self textDidChange:nil];
    }
}

- (void)loadContacts
{
    T_UI();
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        MCTIdentity *myIdentity = [[MCTComponentFramework systemPlugin] myIdentity];

        NSMutableArray *emails = [NSMutableArray array];
        for (MCTContactEntry *contact in [MCTAddressBook loadPhoneContactsWithEmail:YES andPhone:NO andSorted:YES]) {
            for (MCTContactField *emailField in contact.emails) {
                if ([emailField.value localizedCaseInsensitiveCompare:myIdentity.email] == NSOrderedSame)
                    continue;

                [emails addObject:emailField.value];
            }
        }

        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_CONTACTS_LOADED_FOR_ADD_VIA_EMAIL];
        [intent setString:[emails MCT_JSONRepresentation] forKey:@"emails"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    T_UI();
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.searchTextField];

    if (self.addressBookEmails == nil) {
        self.addressBookEmails = [NSMutableArray array];

        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_CONTACTS_LOADED_FOR_ADD_VIA_EMAIL];
        [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                        forIntentAction:kINTENT_CONTACTS_LOADED_FOR_ADD_VIA_EMAIL
                                                                onQueue:[MCTComponentFramework mainQueue]];
        [self loadContacts];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    T_UI();
    [super viewWillDisappear:animated];
    [self.searchTextField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // TODO: Unregistering intentListener happens by the owning viewController: MCTAddFriendsVC ??
}

- (IBAction)onBackgroundTapped:(id)sender
{
    T_UI();
    [self.searchTextField resignFirstResponder];
}

- (IBAction)onSearchButtonTapped:(id)sender
{
    T_UI();
    NSString *email = self.searchTextField.text;
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [[MCTComponentFramework friendsPlugin] inviteFriendWithEmail:email andMessage:nil];
    }];
    self.parentVC.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                            andText:NSLocalizedString(@"The invitation has been sent", nil)];
    self.parentVC.currentAlertView.delegate = self.parentVC;
    [self.searchTextField resignFirstResponder];
    self.searchTextField.text = nil;
    self.searchButton.enabled = NO;
}

- (BOOL)isValidEmail
{
    T_UI();
    NSPredicate *mailRegex = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", MCT_REGEX_EMAIL];
    BOOL valid = [mailRegex evaluateWithObject:self.searchTextField.text];
    return valid;
}

- (BOOL)shouldShowAutoCompletionTable
{
    T_UI();
    if (self.autoCompletionEmails == nil || [self.autoCompletionEmails count] == 0)
        return NO;

    if ([self.autoCompletionEmails count] == 1 &&
        [self.searchTextField.text isEqualToString:[self.autoCompletionEmails objectAtIndex:0]])
        return NO;

    return YES;
}

- (void)keyboardDidShow:(NSNotification *)aNotification
{
    T_UI();
    [UIView animateWithDuration:0.3 animations:^{
        self.view.top = -self.searchDescription.bottom;
    }];
}

- (void)keyboardDidHide:(NSNotification *)aNotification
{
    T_UI();
    [UIView animateWithDuration:0.3 animations:^{
        self.view.top = 0;
    }];
}

- (void)textDidChange:(NSNotification *)aNotification
{
    T_UI();
    if ([aNotification object] == self.searchTextField || aNotification == nil) {
        self.autoCompletionEmails = [NSMutableArray array];
        for (NSString *email in self.addressBookEmails) {
            NSRange r = [email rangeOfString:self.searchTextField.text options:NSCaseInsensitiveSearch];
            if (r.location == 0) {
                [self.autoCompletionEmails addObject:email];
            }
        }

        if ([self shouldShowAutoCompletionTable]) {
            if (self.autoCompletionTable.hidden) {
                CGRect acFrame = self.searchTextField.frame;
                acFrame.origin.y = CGRectGetMaxY(self.searchTextField.frame) - 6;
                acFrame.size.height = 123;
                self.autoCompletionTable.frame = acFrame;
                self.autoCompletionTable.hidden = NO;
            }
        } else {
            self.autoCompletionTable.hidden = YES;
        }
        [self.autoCompletionTable reloadData];

        self.searchButton.enabled = [self isValidEmail];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    T_UI();
    self.validationLabel.hidden = YES;
    if (![MCTUtils isEmptyOrWhitespaceString:textField.text] && [self shouldShowAutoCompletionTable]) {
        self.autoCompletionTable.hidden = NO;
    }

    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    T_UI();
    BOOL valid = [self isValidEmail];

    self.searchButton.enabled = valid;
    self.validationLabel.hidden = valid;
    if (valid) {
        [textField resignFirstResponder];
    }
    self.autoCompletionTable.hidden = YES;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    T_UI();
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    T_UI();
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    return [self.autoCompletionEmails count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    static NSString *ident = @"email";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = self.searchTextField.font;
    }
    cell.textLabel.text = [self.autoCompletionEmails objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.searchTextField.text = [self.autoCompletionEmails objectAtIndex:indexPath.row];
    [self.searchTextField resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return 30;
}

#pragma mark -
#pragma mark IMCTIntentReceiver

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_CONTACTS_LOADED_FOR_ADD_VIA_EMAIL) {
        [self contactsLoaded:[[intent stringForKey:@"emails"] MCT_JSONValue]];
    }
}

@end