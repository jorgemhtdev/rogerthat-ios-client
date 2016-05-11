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
#import "MCTComponentFramework.h"
#import "MCTContactCell.h"
#import "MCTContactEntry.h"
#import "MCTShareServiceVC.h"
#import "MCTUIUtils.h"

#define TAB_W() ([[UIScreen mainScreen] applicationFrame].size.width / (MCT_FACEBOOK_APP_ID ? 4 : 3))


#define PAGE_EMAIL 2
#define TAG_FACEBOOK_VIEW 4


@interface MCTShareServiceVC ()

- (void)contactsDidLoadWithContacts:(NSArray *)contacts andEmails:(NSArray *)emails;

- (void)moveIndicatorToPage:(int)page;

- (void)postOnWall;

@end


@implementation MCTShareServiceVC

+ (MCTShareServiceVC *)viewControllerWithService:(MCTFriend *)service
{
    T_UI();
    MCTShareServiceVC *vc = [[MCTShareServiceVC alloc] initWithNibName:@"shareService" bundle:nil];
    vc.service = service;
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] applicationFrame];

    IF_IOS7_OR_GREATER({
        self.automaticallyAdjustsScrollViewInsets = NO;
    });

    self.title = NSLocalizedString(@"Recommend", nil);
    self.friendsPlugin = [MCTComponentFramework friendsPlugin];
    self.currentShares = [NSMutableArray array];
    self.friendEmails = [NSMutableDictionary dictionary];
    self.pageControlBeingUsed = NO;
    self.headerView.clipsToBounds = NO;
    self.currentPage = 0;
    [MCTUIUtils addShadowToView:self.headerView];

    [MCTUIUtils addRoundedBorderToView:self.recommendViaRogerthatImageView
                       withBorderColor:[UIColor MCTMercuryColor]
                       andCornerRadius:5];

    // Init share via email page
    self.shareViaEmailVC = [MCTShareServiceViaEmailVC viewControllerWithParent:self
                                                               andServiceEmail:self.service.email
                                                          andAddressBookEmails:[NSMutableArray array]];
    self.addressBookTableView.left = self.scrollView.width;
    self.shareViaEmailVC.view.left = 2 * self.scrollView.width;
    self.facebookView.left = 3 * self.scrollView.width;

    [self.scrollView addSubview:self.shareViaEmailVC.view];

    self.selectionView.width = TAB_W();
    self.recommendViaRogerthat.width = TAB_W();
    self.recommendViaContacts.width = TAB_W();
    self.recommendViaEmail.width = TAB_W();

    self.recommendViaRogerthatImageView.centerX = self.recommendViaRogerthat.centerX;
    self.recommendViaContactsImageView.centerX = self.recommendViaRogerthat.centerX;
    self.recommendViaEmailImageView.centerX = self.recommendViaRogerthat.centerX;

    self.recommendViaContacts.left = self.recommendViaRogerthat.right;
    self.recommendViaEmail.left = self.recommendViaContacts.right;

    if (MCT_FACEBOOK_APP_ID == nil) {
        for (UIView *subview in [self.scrollView subviews]) {
            if (subview.tag == TAG_FACEBOOK_VIEW) {
                [subview removeFromSuperview];
            }
        }

        self.recommendViaFacebook.width = 0;
        self.recommendViaFacebook.hidden = YES;

        self.scrollView.contentSize = CGSizeMake(3 * self.scrollView.width, self.scrollView.height);
    } else {

        self.recommendViaFacebook.width = TAB_W();
        self.recommendViaFacebookImageView.centerX = self.recommendViaRogerthat.centerX;
        self.recommendViaFacebook.left = self.recommendViaEmail.right;

        // Init share via facebook page
        self.facebookLabel.text = NSLocalizedString(@"Let your Facebook friends know how awesome this service is.", nil);
        UIButton *uiBtn = (UIButton *) self.facebookBtn;
        [uiBtn setTitle:NSLocalizedString(@"Recommend on your Facebook Wall", nil) forState:UIControlStateNormal];
        TTButton *ttBtn = [MCTUIUtils replaceUIButtonWithTTButton:uiBtn];
        CGSize ttSize = [MCTUIUtils sizeForTTButton:ttBtn constrainedToSize:CGSizeMake(ttBtn.width, 100)];
        ttBtn.height = MAX(ttSize.height, ttBtn.height);
        self.facebookBtn = ttBtn;

        self.scrollView.contentSize = CGSizeMake(4 * self.scrollView.width, self.scrollView.height);
    }

    // Init share via contacts page
    self.addressBookTableView.hidden = YES;
    [self.addressBookSpinner startAnimating];

    self.contacts = [NSArray array];

    [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_CONTACTS_LOADED_FOR_SHARE_SERVICE];
    NSArray *intents = [NSArray arrayWithObjects:kINTENT_FRIEND_ADDED, kINTENT_FRIEND_MODIFIED, kINTENT_FRIEND_REMOVED,
                        kINTENT_CONTACTS_LOADED_FOR_SHARE_SERVICE, nil];
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:intents
                                                            onQueue:[MCTComponentFramework mainQueue]];

    // Load contacts on COMM queue
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        MCTIdentity *myIdentity = [[MCTComponentFramework systemPlugin] myIdentity];

        NSMutableArray *contacts = [NSMutableArray array];
        NSMutableArray *emails = [NSMutableArray array];
        for (MCTContactEntry *contact in [MCTAddressBook loadPhoneContactsWithEmail:YES andPhone:NO andSorted:YES]) {
            for (MCTContactField *emailField in contact.emails) {
                if ([myIdentity.email localizedCaseInsensitiveCompare:emailField.value] == NSOrderedSame)
                    continue;

                MCTContactEntry *c = [[MCTContactEntry alloc] init];
                c.image = contact.image;
                c.name = contact.name;
                c.emails = [NSArray arrayWithObject:emailField];
                [contacts addObject:[c dictRepresentation]];
                [emails addObject:emailField.value];
            }
        }
        [emails sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_CONTACTS_LOADED_FOR_SHARE_SERVICE];
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:contacts, @"contacts", emails, @"emails", nil];
        [intent setString:[d MCT_JSONRepresentation] forKey:@"data"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    }];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    // ios 6
    return NO;
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    // ios 5
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self currentPage] == PAGE_EMAIL)
        [self.shareViaEmailVC viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self currentPage] == PAGE_EMAIL)
        [self.shareViaEmailVC viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self currentPage] == PAGE_EMAIL)
        [self.shareViaEmailVC viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([self currentPage] == PAGE_EMAIL)
        [self.shareViaEmailVC viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
    }
}

#pragma mark -

- (void)contactsDidLoadWithContacts:(NSArray *)contacts andEmails:(NSArray *)emails
{
    T_UI();
    self.contacts = contacts;
    self.addressBookTableView.hidden = NO;
    [self.addressBookTableView reloadData];
    [self.rogerthatTableView reloadData];
    [self.addressBookSpinner stopAnimating];
    self.shareViaEmailVC.addressBookEmails = emails;
}

- (IBAction)onControlTapped:(id)sender
{
    T_UI();
    UIControl *ctrl = sender;
    int page = floor(ctrl.left / TAB_W());
    self.pageControlBeingUsed = YES;
    [self moveIndicatorToPage:page];
}

- (IBAction)onFacebookBtnTapped:(id)sender
{
    T_UI();
    HERE();

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_FB_POST
                                                            onQueue:[MCTComponentFramework mainQueue]];
    [[MCTComponentFramework appDelegate] ensureOpenActiveFBSessionWithReadPermissions:@[@"email", @"user_friends"]
                                                                   resultIntentAction:kINTENT_FB_POST
                                                                   allowFastAppSwitch:YES
                                                                   fromViewController:self];
}

- (void)onShareButtonTapped:(id)sender
{
    T_UI();
    TTButton *ttBtn = sender;
    ttBtn.enabled = NO;
    BOOL ab;
    NSString *email;
    if (ttBtn.tag < [self.contacts count]) {
        ab = YES;
        MCTContactEntry *contact = [self.contacts objectAtIndex:ttBtn.tag];
        MCTContactField *contactField = [contact.emails objectAtIndex:0];
        email = [contactField.value lowercaseString];
    } else {
        ab = NO;
        email = [self.friendEmails objectForKey:[NSNumber numberWithInteger:ttBtn.tag - [self.contacts count]]];
    }
    NSString *serviceEmail = self.service.email;
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [[MCTComponentFramework friendsPlugin] shareService:serviceEmail withFriend:email];
    }];
    [self.currentShares addObject:[NSString stringWithFormat:(ab ? @"ab %@" : @"rt %@"), email]];
}

#pragma mark -

- (void)moveIndicatorToPage:(int)page
{
    T_UI();
    if (self.currentPage == page)
        return;

    if (self.currentPage == PAGE_EMAIL)
        [self.shareViaEmailVC viewWillDisappear:YES];
    if (self.currentPage == PAGE_EMAIL)
        [self.shareViaEmailVC viewWillAppear:YES];

    self.currentPage = page;
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.selectionView.left = page * TAB_W();
                         if (self.pageControlBeingUsed)
                             self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width * page, 0);
                     } completion:^(BOOL finished) {
                         if (self.currentPage == PAGE_EMAIL)
                             [self.shareViaEmailVC viewDidDisappear:YES];
                         if (self.currentPage == PAGE_EMAIL)
                             [self.shareViaEmailVC viewDidAppear:YES];
                     }];
}

- (void)postOnWall
{
    T_UI();
    HERE();
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   FBSession.activeSession.appID, @"app_id",
                                   OR(self.service.actionMenu.shareCaption, @""), @"caption",
                                   OR(self.service.actionMenu.shareDescription, @""), @"description",
                                   [MCTUtils stringByAppendingTargetForFacebookImageURL:self.service.actionMenu.shareLinkUrl], @"link",
                                   self.service.actionMenu.shareImageUrl, @"picture", nil];

    LOG(@"%@", params);

    [FBWebDialogs presentFeedDialogModallyWithSession:[FBSession activeSession]
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  // not interested in the result
                                                  if (error) {
                                                      [MCTUIUtils showAlertWithFacebookError:error
                                                                             andSessionState:-1];
                                                  }
                                              }];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    T_UI();
    if (self.pageControlBeingUsed)
        return;

    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

    [self moveIndicatorToPage:page];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    T_UI();
    self.pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    T_UI();
    self.pageControlBeingUsed = NO;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    if (tableView == self.addressBookTableView) {
        return [self.contacts count];
    } else {
        return [self.friendsPlugin.store countFriendsByType:MCTFriendTypeUser];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    T_UI();
    if (tableView == self.addressBookTableView) {
        if ([self.contacts count] < 1) {
            return NSLocalizedString(@"No phone contacts with an e-mail address found", nil);
        }
        return NSLocalizedString(@"Recommend via e-mail", nil);
    } else {
        if ([self.friendsPlugin.store countFriendsByType:MCTFriendTypeUser] < 1) {
            return [NSString stringWithFormat:NSLocalizedString(@"__no_friends_found", nil), MCT_PRODUCT_NAME];
        }
        return [NSString stringWithFormat:NSLocalizedString(@"__recommend_to_contacts", nil), MCT_PRODUCT_NAME];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    static NSString *ident = @"share";
    TTButton *ttBtn;
    MCTContactCell *cell = (MCTContactCell *) [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        cell = [[MCTContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
        ttBtn = [TTButton buttonWithStyle:MCT_STYLE_EMBOSSED_SMALL_BUTTON
                                    title:NSLocalizedString(@"Recommend", nil)];
        [ttBtn setTitle:NSLocalizedString(@"Recommended", nil) forState:UIControlStateDisabled];
        [ttBtn addTarget:self action:@selector(onShareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        ttBtn.frame = CGRectMake(0, 0, 80, 40);
    } else {
        ttBtn = (TTButton *) cell.accessoryView;
    }

    BOOL ab;
    NSString *name;
    NSString *email;
    UIImage *image;

    if (tableView == self.addressBookTableView) {
        ab = YES;
        MCTContactEntry *contact = [self.contacts objectAtIndex:indexPath.row];
        email = ((MCTContactField *)[contact.emails objectAtIndex:0]).value;
        image = contact.image ? [UIImage imageWithData:contact.image] : [UIImage imageNamed:MCT_UNKNOWN_AVATAR];
        name = contact.name;
    } else {
        ab = NO;
        MCTFriend *friend = [self.friendsPlugin.store friendByType:MCTFriendTypeUser andIndex:indexPath.row];
        name = friend.displayName;
        email = friend.email;
        image = friend.avatarImage;

        [self.friendEmails setObject:friend.email forKey:@(indexPath.row)];
    }

    NSString *test = [NSString stringWithFormat:(ab ? @"ab %@" : @"rt %@"), email];
    BOOL alreadyShared = [self.currentShares containsObject:test];
    ttBtn.enabled = !alreadyShared;
    ttBtn.tag = indexPath.row + (ab ? 0 : [self.contacts count]);

    cell.accessoryView = ttBtn;
    cell.detailTextLabel.text = ab ? email : nil;
    cell.imageView.image = image;
    cell.textLabel.text = name;

    return cell;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (alertView == self.currentAlertView) {
        MCT_RELEASE(self.currentAlertView);
    }
}

#pragma mark - MCTIntent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_FRIEND_REMOVED || intent.action == kINTENT_FRIEND_MODIFIED ||
        intent.action == kINTENT_FRIEND_ADDED) {

        self.friendEmails = [NSMutableDictionary dictionary];
        [self.rogerthatTableView reloadData];
    }

    else if (intent.action == kINTENT_CONTACTS_LOADED_FOR_SHARE_SERVICE) {
        NSDictionary *d = [[intent stringForKey:@"data"] MCT_JSONValue];
        NSMutableArray *contacts = [NSMutableArray array];
        for (NSDictionary *contactDict in [d arrayForKey:@"contacts"]) {
            [contacts addObject:[[MCTContactEntry alloc] initWithDict:contactDict]];
        }
        [self contactsDidLoadWithContacts:contacts andEmails:[d arrayForKey:@"emails"]];
    }

    else if (intent.action == kINTENT_FB_POST) {
        if ([intent boolForKey:@"canceled"]) {
            // Do nothing
        } else if ([intent boolForKey:@"error"]) {
            [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                              forIntentAction:intent.action];
            [MCTUIUtils showAlertWithFacebookErrorIntent:intent];
        } else if (FBSession.activeSession.isOpen) {
            [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                              forIntentAction:intent.action];
            [self postOnWall];
        }
    }
}

@end