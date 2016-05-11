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
#import "MCTAddViaContactsResultVC.h"
#import "MCTComponentFramework.h"
#import "MCTContactCell.h"
#import "MCTMenuVC.h"
#import "MCTScanAddressBookResult.h"
#import "MCTUIUtils.h"

#import "NSData+Base64.h"

#define SECTION_MATCHED 0
#define SECTION_BY_EMAIL 1
#define SECTION_BY_SMS 2


@interface MCTAddViaContactsResultVC ()

- (void)loadContacts;
- (void)contactsDidLoadWithMatches:(NSArray *)matches andEmails:(NSArray *)emails andNumbers:(NSArray *)numbers;
- (void)inviteContactViaEmail:(MCTContactEntry *)contact;

@end

@implementation MCTAddViaContactsResultVC


+ (MCTAddViaContactsResultVC *)viewControllerWithParent:(MCTUIViewController *)parentVC;
{
    T_UI();
    MCTAddViaContactsResultVC *vc = [[MCTAddViaContactsResultVC alloc] initWithNibName:@"addViaContactsResult"
                                                                                 bundle:nil];
    vc.parentVC = parentVC;
    return vc;
}


- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    [MCTUIUtils setBackgroundStripesToView:self.view];

    [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_CONTACTS_LOADED_FOR_ADD_VIA_CONTACTS];
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_CONTACTS_LOADED_FOR_ADD_VIA_CONTACTS
                                                            onQueue:[MCTComponentFramework mainQueue]];

    self.pendingInvites = [NSMutableArray arrayWithArray:[[[MCTComponentFramework friendsPlugin] store] pendingInvitations]];
    self.currentInvites = [NSMutableArray array];

    self.myIdentity = [[MCTComponentFramework systemPlugin] myIdentity];

    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    T_UI();
    [super viewWillAppear:animated];
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        // Cancel LN
        NSString *serialized = [[MCTComponentFramework configProvider] stringForKey:MCT_GOTO_ADD_FRIENDS_VIA_ADDRESSBOOK];
        if (serialized) {
            UILocalNotification *ln = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataFromBase64String:serialized]];
            [[UIApplication sharedApplication] cancelLocalNotification:ln];
        }
    }];
}

- (void)loadContacts
{
    T_UI();
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        NSString *b64 = [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_ADDRESSBOOK_SCAN];
        MCTScanAddressBookResult *result = (MCTScanAddressBookResult *) [MCTPickler objectFromPickle:[NSData dataFromBase64String:b64]];

        NSMutableArray *matchedContacts = [NSMutableArray array];
        NSMutableArray *emailContacts = [NSMutableArray array];
        NSMutableArray *phoneContacts = [NSMutableArray array];

        for (MCTContactEntry *contact in [MCTAddressBook loadPhoneContactsWithEmail:YES
                                                                           andPhone:[MFMessageComposeViewController canSendText]
                                                                          andSorted:YES]) {
            if ([[MCTComponentFramework friendsPlugin] isRogerthatFriend:contact]) {
                LOG(@"Filtering out existing friend '%@'", contact.name);
                continue;
            }

            for (MCTContactField *emailField in contact.emails) {
                // TODO: if one of the emails matched then dont add them to |self.emailContacts|
                MCTContactEntry *c = [[MCTContactEntry alloc] init];
                c.image = contact.image;
                c.name = contact.name;
                c.emails = [NSArray arrayWithObject:emailField];
                if ([result.matches containsObject:[emailField.value lowercaseString]]) {
                    [matchedContacts addObject:[c dictRepresentation]];
                } else {
                    [emailContacts addObject:[c dictRepresentation]];
                }
            }

            for (MCTContactField *numberField in contact.numbers) {
                MCTContactEntry *c = [[MCTContactEntry alloc] init];
                c.image = contact.image;
                c.name = contact.name;
                c.numbers = [NSArray arrayWithObject:numberField];
                [phoneContacts addObject:[c dictRepresentation]];
            }
        }

        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
                           matchedContacts, @"matches",
                           emailContacts, @"emails",
                           phoneContacts, @"numbers", nil];

        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_CONTACTS_LOADED_FOR_ADD_VIA_CONTACTS];
        [intent setString:[d MCT_JSONRepresentation] forKey:@"data"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    }];
}

- (void)contactsDidLoadWithMatches:(NSArray *)matches andEmails:(NSArray *)emails andNumbers:(NSArray *)numbers
{
    T_UI();
    self.matchedContacts = matches;
    self.emailContacts = emails;
    self.phoneContacts = numbers;

    self.contactsLoaded = YES;
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    MCT_RELEASE(self.spinner);

    [self.tableView reloadData];
}

- (void)refresh
{
    T_UI();
    self.matchedContacts = [NSArray array];
    self.emailContacts = [NSArray array];
    self.phoneContacts = [NSArray array];
    self.contactsLoaded = NO;
    [self.tableView reloadData];

    if (self.spinner == nil) {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.spinner.left = (self.view.width - self.spinner.width) / 2;
        self.spinner.top = 20;
        [self.view addSubview:self.spinner];
    }
    [self.spinner startAnimating];

    [self loadContacts];
}

#pragma mark -

- (void)inviteContactViaEmail:(MCTContactEntry *)contact
{
    T_UI();
    MCTContactField *emailField = [contact.emails objectAtIndex:0];
    NSString *email = [emailField.value lowercaseString];
    NSString *name = contact.name;
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [[MCTComponentFramework friendsPlugin] inviteFriendWithEmail:email andName:name andMessage:nil];
    }];
    [self.pendingInvites addObject:email];
    [self.currentInvites addObject:email];
    [self.tableView reloadData];
}

- (void)onAddMatchTapped:(TTButton *)sender
{
    T_UI();
    MCTContactEntry *contact = [self.matchedContacts objectAtIndex:sender.tag];
    [self inviteContactViaEmail:contact];
}

- (void)onInviteViaEmailTapped:(TTButton *)sender
{
    T_UI();
    MCTContactEntry *contact = [self.emailContacts objectAtIndex:sender.tag];
    [self inviteContactViaEmail:contact];
}

- (void)onInviteViaSmsTapped:(TTButton *)sender
{
    T_UI();
    if (![MFMessageComposeViewController canSendText]) {
        self.parentVC.currentAlertView = [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"Your device is not capable of sending text messages", nil)];
        return;
    }

    MCTContactEntry *contact = [self.phoneContacts objectAtIndex:sender.tag];
    MCTContactField *numberField = [contact.numbers objectAtIndex:0];

    MCTIdentity *me = [[MCTComponentFramework systemPlugin] myIdentity];
    NSString *installUrl = [NSString stringWithFormat:@"%@%@?a=%@", MCT_HTTPS_BASE_URL, MCT_INSTALLATION_URL, MCT_PRODUCT_ID];
    NSString *body;
    if (![MCTUtils isEmptyOrWhitespaceString:me.shortUrl]) {
        // converting HTTPS://ROGERTH.AT/S/... to https://rogerth.at/S/...
        NSMutableArray *split = [NSMutableArray arrayWithArray:[me.shortUrl componentsSeparatedByString:@"/"]];
        [split replaceObjectAtIndex:0 withObject:[[split objectAtIndex:0] lowercaseString]];
        if ([[split objectAtIndex:0] hasPrefix:@"http"]) {
            [split replaceObjectAtIndex:2 withObject:[[split objectAtIndex:2] lowercaseString]];
        }
        NSString *shortUrl = [split componentsJoinedByString:@"/"];

        self.invitationSecret = [[MCTComponentFramework friendsPlugin] popInvitationSecret];
        if (![MCTUtils isEmptyOrWhitespaceString:self.invitationSecret]) {
            shortUrl = [NSString stringWithFormat:@"%@?s=%@", shortUrl, self.invitationSecret];
        }

        body = [NSString stringWithFormat:NSLocalizedString(@"__friend_sms_invitation", nil),
                contact.name, installUrl, shortUrl, MCT_PRODUCT_NAME];
    } else {
        body = [NSString stringWithFormat:NSLocalizedString(@"__friend_sms_invitation_no_url", nil),
                contact.name, installUrl, MCT_PRODUCT_NAME];
    }

    self.invitee = contact.name;

    MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
    vc.body = body;
    vc.recipients = [NSArray arrayWithObject:numberField.value];
    vc.messageComposeDelegate = self;
    [self.parentVC presentViewController:vc animated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:MCT_NOTIFICATION_BACKGROUND
                                               object:nil];
}

#pragma mark -

- (NSInteger)sectionConstForTableSection:(NSInteger)section
{
    T_UI();

    if (section < SECTION_BY_EMAIL) {
        return section;
    }

    if ([self.emailContacts count] == 0)
        section++;

    if (section < SECTION_BY_SMS) {
        return section;
    }

    if (!(MCT_DEBUG || [MFMessageComposeViewController canSendText]) || [self.phoneContacts count] == 0)
        section++;

    return section;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    T_UI();
    if (!self.contactsLoaded)
        return 0;

    int sections = 3;
    if (!(MCT_DEBUG || [MFMessageComposeViewController canSendText]) || [self.phoneContacts count] == 0)
        sections--;

    if ([self.emailContacts count] == 0)
        sections--;

    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    switch ([self sectionConstForTableSection:section]) {
        case SECTION_MATCHED:
            return [self.matchedContacts count];
        case SECTION_BY_EMAIL:
            return [self.emailContacts count];
        case SECTION_BY_SMS:
            return [self.phoneContacts count];
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    static NSString *ident = @"i";
    MCTContactCell *cell = (MCTContactCell *) [tableView dequeueReusableCellWithIdentifier:ident];

    if (!cell) {
        cell = [[MCTContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
    }

    MCTContactEntry *contact = nil;
    MCTContactField *contactField = nil;
    NSString *title = nil;
    SEL sel = nil;

    switch ([self sectionConstForTableSection:indexPath.section]) {
        case SECTION_MATCHED:
            contact = [self.matchedContacts objectAtIndex:indexPath.row];
            contactField = [contact.emails objectAtIndex:0];
            sel = @selector(onAddMatchTapped:);
            if ([self.pendingInvites containsObject:[contactField.value lowercaseString]])
                title = NSLocalizedString(@"Sent", nil);
            else
                title = NSLocalizedString(@"Add", nil);
            break;

        case SECTION_BY_EMAIL:
            contact = [self.emailContacts objectAtIndex:indexPath.row];
            contactField = [contact.emails objectAtIndex:0];
            sel = @selector(onInviteViaEmailTapped:);
            if ([self.pendingInvites containsObject:[contactField.value lowercaseString]])
                title = NSLocalizedString(@"Invited", nil);
            else
                title = NSLocalizedString(@"Invite", nil);
            break;

        case SECTION_BY_SMS:
            contact = [self.phoneContacts objectAtIndex:indexPath.row];
            contactField = [contact.numbers objectAtIndex:0];
            sel = @selector(onInviteViaSmsTapped:);
            if ([self.pendingInvites containsObject:[contactField.value lowercaseString]])
                title = NSLocalizedString(@"Invited", nil);
            else
                title = NSLocalizedString(@"Invite", nil);
            break;

        default:
            ERROR(@"There should be no section %d", indexPath.section);
            break;
    }

    TTButton *ttBtn = [TTButton buttonWithStyle:MCT_STYLE_EMBOSSED_SMALL_BUTTON
                                          title:title];
    ttBtn.enabled = ![self.currentInvites containsObject:[contactField.value lowercaseString]];
    ttBtn.frame = CGRectMake(0, 0, 80, 40);
    ttBtn.tag = indexPath.row;
    [ttBtn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];

    cell.accessoryView = ttBtn;
    cell.detailTextLabel.text = contactField.value;
    cell.imageView.image = contact.image ? [UIImage imageWithData:contact.image] : [UIImage imageNamed:MCT_UNKNOWN_AVATAR];
    cell.textLabel.text = contact.name;

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    T_UI();
    switch ([self sectionConstForTableSection:section]) {
        case SECTION_MATCHED:
        {
            NSInteger c = [self.matchedContacts count];
            if (c == 0) {
                return [NSString stringWithFormat:NSLocalizedString(@"__contacts_found_none", nil), MCT_PRODUCT_NAME];
            } else if (c == 1) {
                return [NSString stringWithFormat:NSLocalizedString(@"__contacts_found_1", nil), MCT_PRODUCT_NAME];
            } else {
                return [NSString stringWithFormat:NSLocalizedString(@"__contacts_found_more", nil), c, MCT_PRODUCT_NAME];
            }
        }
        case SECTION_BY_EMAIL:
            switch (MCT_FRIENDS_CAPTION) {
                case MCTFriendsCaptionColleagues:
                    return NSLocalizedString(@"Invite colleagues via e-mail", nil);
                case MCTFriendsCaptionContacts:
                    return NSLocalizedString(@"Invite contacts via e-mail", nil);
                case MCTFriendsCaptionFriends:
                default:
                    return NSLocalizedString(@"Invite friends via e-mail", nil);
            }
        case SECTION_BY_SMS:
            switch (MCT_FRIENDS_CAPTION) {
                case MCTFriendsCaptionColleagues:
                    return NSLocalizedString(@"Invite colleagues via text message", nil);
                case MCTFriendsCaptionContacts:
                    return NSLocalizedString(@"Invite contacts via text message", nil);
                case MCTFriendsCaptionFriends:
                default:
                    return NSLocalizedString(@"Invite friends via text message", nil);
            }
        default:
            return nil;
    }
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return 50;
}

#pragma mark -
#pragma mark MFMessageComposeViewControllerDelegate

- (void)hideMessageComposeViewControllerAnimated:(BOOL)animated
{
    T_UI();
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MCT_NOTIFICATION_BACKGROUND object:nil];
    [self.parentVC dismissViewControllerAnimated:animated completion:nil];
}

- (void)didEnterBackground
{
    T_UI();
    [self recoverInvitationSecret];
    [self hideMessageComposeViewControllerAnimated:NO];
}

- (void)recoverInvitationSecret
{
    T_UI();
    if (![MCTUtils isEmptyOrWhitespaceString:self.invitationSecret]) {
        NSString *secret = self.invitationSecret;
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            T_BIZZ();
            [[MCTComponentFramework friendsPlugin].store saveInvitationSecrets:[NSArray arrayWithObject:secret]];
        }];
    }

}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result;
{
    T_UI();
    switch (result) {
        case MessageComposeResultCancelled:
            LOG(@"Sending SMS canceled");
            [self recoverInvitationSecret];
            break;

        case MessageComposeResultFailed:
            LOG(@"Sending SMS failed");
            [self recoverInvitationSecret];
            self.parentVC.currentAlertView = [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"Failed to send invitation.", nil)];
            break;

        case MessageComposeResultSent:{
            LOG(@"Sending SMS succeeded");
            self.parentVC.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:NSLocalizedString(@"Invitation sent successfully.", nil)];
            NSString *number = [controller.recipients objectAtIndex:0];
            if (![MCTUtils isEmptyOrWhitespaceString:self.invitationSecret]) {
                NSString *secret = self.invitationSecret;
                [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                    T_BIZZ();
                    [[MCTComponentFramework friendsPlugin] logInvitationSecretSent:secret toPhoneNumber:number];
                }];
            }

            NSString *contact = [NSString stringWithFormat:@"%@ (%@)", self.invitee, number];
            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                NSString *activity = [NSString stringWithFormat:NSLocalizedString(@"Invited %@", nil), contact];
                [[MCTComponentFramework activityPlugin] logActivityWithText:activity andLogLevel:MCTActivityLogInfo];

                [[[MCTComponentFramework friendsPlugin] store] addPendingInvitation:number];
            }];

            [self.pendingInvites addObject:number];
            [self.currentInvites addObject:number];
            [self.tableView reloadData];
            break;
        }
        default:
            break;
    }

    MCT_RELEASE(self.invitationSecret);
    MCT_RELEASE(self.invitee);
    [self hideMessageComposeViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark IMCTIntentReceiver

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_CONTACTS_LOADED_FOR_ADD_VIA_CONTACTS) {
        NSDictionary *data = [[intent stringForKey:@"data"] MCT_JSONValue];

        NSMutableArray *matches = [NSMutableArray array];
        for (NSDictionary *d in [data arrayForKey:@"matches"]) {
            [matches addObject:[[MCTContactEntry alloc] initWithDict:d]];
        }

        NSMutableArray *numbers = [NSMutableArray array];
        for (NSDictionary *d in [data arrayForKey:@"numbers"]) {
            [numbers addObject:[[MCTContactEntry alloc] initWithDict:d]];
        }

        NSMutableArray *emails = [NSMutableArray array];
        for (NSDictionary *d in [data arrayForKey:@"emails"]) {
            [emails addObject:[[MCTContactEntry alloc] initWithDict:d]];
        }

        [self contactsDidLoadWithMatches:matches andEmails:emails andNumbers:numbers];
    }
}

@end