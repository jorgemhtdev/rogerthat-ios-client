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

#import "MCTAddFriendsVC.h"
#import "MCTComponentFramework.h"
#import "MCTIntent.h"
#import "MCTUIUtils.h"

#import "NSString+MCT_SBJSON.h"

static CGFloat TAB_W;

@interface MCTAddFriendsVC ()

@property (nonatomic, strong) MCTAddViaContactsVC *phoneVC;
@property (nonatomic, strong) MCTAddViaContactsResultVC *phoneResultVC;
@property (nonatomic, strong) MCTAddViaFacebookVC *fbVC;
@property (nonatomic, strong) MCTAddViaFacebookResultVC *fbResultVC;
@property (nonatomic, strong) MCTAddViaQRScanVC *qrVC;
@property (nonatomic, strong) MCTAddViaEmailVC *searchVC;
@property (nonatomic) MCTlong phoneIntentTimestamp;
@property (nonatomic) MCTlong fbIntentTimestamp;
@property (nonatomic) BOOL pageControlBeingUsed;
@property (nonatomic) MCTAddFriendsTab showTab;

- (void)moveIndicatorToPage:(int)page;
- (UIViewController *)viewControllerWithTag:(int)tag;
- (UIViewController *)selectedViewController;

@end


@implementation MCTAddFriendsVC






+ (void)initialize
{
    TAB_W = [[UIScreen mainScreen] applicationFrame].size.width / (MCT_FACEBOOK_APP_ID ? 4 : 3);
}

+ (MCTAddFriendsVC *)viewController
{
    T_UI();
    MCTAddFriendsVC *vc = [[MCTAddFriendsVC alloc] initWithNibName:@"addFriends" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    return vc;
}


- (void)showTab:(MCTAddFriendsTab)tab
{
    self.showTab = tab;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] applicationFrame];


    IF_IOS7_OR_GREATER({
        self.automaticallyAdjustsScrollViewInsets = NO;
    });

    [MCTUIUtils addRoundedBorderToView:[self.qrControl.subviews objectAtIndex:0]
                       withBorderColor:[UIColor clearColor]
                       andCornerRadius:5];

    switch (MCT_FRIENDS_CAPTION) {
        case MCTFriendsCaptionColleagues: {
            self.title = NSLocalizedString(@"Add colleagues", nil);
            break;
        }
        case MCTFriendsCaptionContacts: {
            self.title = NSLocalizedString(@"Add contacts", nil);
            break;
        }
        case MCTFriendsCaptionFriends:
        default: {
            self.title = NSLocalizedString(@"Add friends", nil);
            break;
        }
    }

    self.pageControlBeingUsed = NO;
    self.headerView.clipsToBounds = NO;
    [MCTUIUtils addShadowToView:self.headerView];

    self.qrVC = [MCTAddViaQRScanVC viewController];
    self.searchVC = [MCTAddViaEmailVC viewControllerWithParent:self];
    NSMutableArray *views = [NSMutableArray arrayWithObjects:self.qrVC.view, self.searchVC.view, nil];

    if ([[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_ADDRESSBOOK_SCAN]) {
        self.phoneResultVC = [MCTAddViaContactsResultVC viewControllerWithParent:self];
        [views insertObject:self.phoneResultVC.view atIndex:0];
    } else {
        self.phoneVC = [MCTAddViaContactsVC viewControllerWithParent:self];
        [views insertObject:self.phoneVC.view atIndex:0];
    }

    self.selectionView.width = TAB_W;
    self.phoneControl.width = TAB_W;
    self.qrControl.width = TAB_W;
    self.searchControl.width = TAB_W;

    self.phoneControlImageView.centerX = self.phoneControl.centerX;
    self.fbControlImageView.centerX = self.phoneControl.centerX;
    self.qrControlImageView.centerX = self.phoneControl.centerX;
    self.searchControlImageView.centerX = self.phoneControl.centerX;

    if (MCT_FACEBOOK_APP_ID == nil) {
        self.fbControl.hidden = YES;
        self.fbControl.width = 0;

        self.qrControl.left = self.phoneControl.right;
        self.searchControl.left = self.qrControl.right;
    } else {
        self.fbControl.width = TAB_W;

        self.fbControl.left =self.phoneControl.right;
        self.qrControl.left = self.fbControl.right;
        self.searchControl.left = self.qrControl.right;

        if ([[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_FACEBOOK_FRIENDS_SCAN]) {
            self.fbResultVC = [MCTAddViaFacebookResultVC viewController];
            [views insertObject:self.fbResultVC.view atIndex:1];
        } else {
            self.fbVC = [MCTAddViaFacebookVC viewControllerWithParent:self];
            [views insertObject:self.fbVC.view atIndex:1];
        }
    }

    int i = 0;
    for (UIView *v in views) {
        v.backgroundColor = [UIColor MCTMercuryColor];
        CGRect f;
        f.origin = CGPointMake(i++ * [[UIScreen mainScreen] applicationFrame].size.width, 0);
        f.size = self.scrollView.frame.size;
        v.frame = f;
        [self.scrollView addSubview:v];
    }
    self.scrollView.contentSize = CGSizeMake(((UIView *)[views lastObject]).right, self.scrollView.contentSize.height);

    NSArray *intents = [NSArray arrayWithObjects:kINTENT_ADDRESSBOOK_SCANNED, kINTENT_FB_FRIENDS_SCANNED, nil];
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:intents
                                                            onQueue:[MCTComponentFramework mainQueue]];

    switch (self.showTab) {
        case MCTAddFriendsTabPhone:
            [self onControlTapped:self.phoneControl];
            break;
        case MCTAddFriendsTabFacebook:
            [self onControlTapped:self.fbControl];
            break;
        case MCTAddFriendsTabQR:
            [self onControlTapped:self.qrControl];
            break;
        case MCTAddFriendsTabSearch:
            [self onControlTapped:self.searchControl];
            break;
        default:
            break;
    }
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    // ios 5
    return NO;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    // ios 6
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self selectedViewController] viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self selectedViewController] viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self selectedViewController] viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[self selectedViewController] viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self.qrVC];
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self.searchVC];
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self.phoneResultVC];
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self.fbResultVC];
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self.fbVC];
        self.phoneResultVC.parentVC = nil;

        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            [[MCTComponentFramework configProvider] deleteStringForKey:MCT_CONFIGKEY_ADDRESSBOOK_SCAN];
            [[MCTComponentFramework configProvider] deleteStringForKey:MCT_CONFIGKEY_FACEBOOK_FRIENDS_SCAN];
        }];
    }
}

#pragma mark -

- (void)replaceViewController:(UIViewController *)oldVC withViewController:(UIViewController *)newVC
{
    T_UI();

    CGRect f = oldVC.view.frame;

    [oldVC viewWillDisappear:NO];
    [oldVC.view removeFromSuperview];
    [oldVC viewDidDisappear:NO];

    [newVC viewWillAppear:NO];
    newVC.view.backgroundColor = oldVC.view.backgroundColor;
    newVC.view.frame = f;
    [self.scrollView addSubview:newVC.view];
    [newVC viewDidAppear:NO];
}

- (void)onRefreshTapped:(id)sender
{
    T_UI();
    int tag = 1 + round(self.selectionView.left / TAB_W);
    switch (tag) {
        case MCTAddFriendsTabPhone:
        {
            self.phoneVC = [MCTAddViaContactsVC viewControllerWithParent:self];
            [self replaceViewController:self.phoneResultVC withViewController:self.phoneVC];
            MCT_RELEASE(self.phoneResultVC);
            [self.phoneVC onPhoneButtonTapped:nil];
            break;
        }
        case MCTAddFriendsTabFacebook:
        {
            self.fbVC = [MCTAddViaFacebookVC viewControllerWithParent:self];
            [self replaceViewController:self.fbResultVC withViewController:self.fbVC];
            MCT_RELEASE(self.fbResultVC);
            [self.fbVC onFBButtonTapped:nil];
            break;
        }
        default:
            break;
    }
}

- (IBAction)onControlTapped:(id)sender
{
    T_UI();
    UIControl *ctrl = sender;
    int page = round(ctrl.left / TAB_W);
    self.pageControlBeingUsed = YES;
    [self moveIndicatorToPage:page];
}

#pragma mark -

- (UIViewController *)selectedViewController
{
    T_UI();
    return [self viewControllerWithTag:(1 + self.selectionView.left/ TAB_W)];
}

- (UIViewController *)viewControllerWithTag:(int)tag
{
    T_UI();
    switch (tag) {
        case MCTAddFriendsTabPhone:
            return self.phoneVC ? self.phoneVC : self.phoneResultVC;
        case MCTAddFriendsTabFacebook:
            return self.fbVC ? self.fbVC : self.fbResultVC;
        case MCTAddFriendsTabQR:
            return self.qrVC;
        case MCTAddFriendsTabSearch:
            return self.searchVC;
        default:
            return nil;
    }
    return nil;
}

- (void)moveIndicatorToPage:(int)page
{
    T_UI();
    int oldPage = round(self.selectionView.left / TAB_W);
    if (oldPage == page)
        return;

    UIViewController *oldVC = [self viewControllerWithTag:oldPage + 1];
    UIViewController *newVC = [self viewControllerWithTag:page + 1];

    [newVC viewWillAppear:NO];
    [oldVC viewWillDisappear:NO];

    [UIView animateWithDuration:0.2
                     animations:^{
                         self.selectionView.left = page * TAB_W;
                         if (self.pageControlBeingUsed) {
                             UIView *subview = [self.scrollView.subviews firstObject];
                             self.scrollView.contentOffset = CGPointMake(self.scrollView.width * page, subview.top);
                         }
                     } completion:^(BOOL finished) {
                         [newVC viewDidAppear:NO];
                         [oldVC viewDidDisappear:NO];
                     }];
}

#pragma mark -

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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag > 0) {
        BOOL processed;
        processed = [self.fbVC processAlertViewClickedButtonAtIndex:buttonIndex];
        if (!processed)
            ERROR(@"Unexpected alertview with tag %d", alertView.tag);
    }

    if (alertView == self.currentAlertView) {
        MCT_RELEASE(self.currentAlertView);
    }
}

#pragma mark -
#pragma mark MCTIntent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_ADDRESSBOOK_SCANNED) {
        if (intent.creationTimestamp > self.phoneIntentTimestamp) {
            if (self.phoneVC) {
                self.phoneResultVC = [MCTAddViaContactsResultVC viewControllerWithParent:self];
                [self replaceViewController:self.phoneVC withViewController:self.phoneResultVC];
                MCT_RELEASE(self.phoneVC);
            } else {
                [self.phoneResultVC refresh];
            }
            self.phoneIntentTimestamp = intent.creationTimestamp;
        }
    }
    else if (intent.action == kINTENT_ADDRESSBOOK_SCAN_FAILED) {
        if (self.phoneResultVC) {
            self.phoneVC = [MCTAddViaContactsVC viewControllerWithParent:self];
            [self replaceViewController:self.phoneResultVC withViewController:self.phoneVC];
            MCT_RELEASE(self.phoneResultVC);
        }
    }
    else if (intent.action == kINTENT_FB_FRIENDS_SCANNED) {
        if (intent.creationTimestamp > self.fbIntentTimestamp) {
            if (self.fbVC) {
                self.fbResultVC = [MCTAddViaFacebookResultVC viewController];
                [self replaceViewController:self.fbVC withViewController:self.fbResultVC];
                MCT_RELEASE(self.fbVC);
            } else {
                [self.fbResultVC refresh];
            }
            self.fbIntentTimestamp = intent.creationTimestamp;
        }
    }
    else if (intent.action == kINTENT_FB_FRIENDS_SCAN_FAILED) {
        if (self.fbResultVC) {
            self.fbVC = [MCTAddViaFacebookVC viewControllerWithParent:self];
            [self replaceViewController:self.fbResultVC withViewController:self.fbVC];
            MCT_RELEASE(self.fbResultVC);
        }
    }
}

@end