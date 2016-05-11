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

#import "MCTAddViaFacebookVC.h"
#import "MCTComponentFramework.h"
#import "MCTIntent.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"
#import "MCTAddFriendsVC.h"

#import <FacebookSDK/FacebookSDK.h>


@interface MCTAddViaFacebookVC ()

- (void)findRogerthatUsers;
- (void)askToPostOnWall;
- (void)postOnWall;

@end

@implementation MCTAddViaFacebookVC


+ (MCTAddViaFacebookVC *)viewControllerWithParent:(MCTUIViewController *)parent
{
    T_UI();
    MCTAddViaFacebookVC *vc = [[MCTAddViaFacebookVC alloc] initWithNibName:@"addViaFacebook" bundle:nil];
    vc.parentVC = parent;
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    self.fbDescription.text = [NSString stringWithFormat:NSLocalizedString(@"__add_via_facebook_description", nil), MCT_PRODUCT_NAME];
    self.dontWorryLabel.text = NSLocalizedString(@"Don't worry, we'll never store this data.", nil);
    [MCTUIUtils topAlignLabel:self.dontWorryLabel];

    [((UIButton *)self.fbButton) setTitle:NSLocalizedString(@"Find friends from Facebook", nil)
                                 forState:UIControlStateNormal];
    self.fbButton = [MCTUIUtils replaceUIButtonWithTTButton:(UIButton *) self.fbButton];

    self.alreadyAskedToPostOnWall = (BOOL) [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_FACEBOOK_POST_QR_ON_WALL];
}

- (IBAction)onFBButtonTapped:(id)sender
{
    T_UI();

    if (![MCTUtils connectedToInternet]) {
        self.parentVC.currentAlertView = [MCTUIUtils showNetworkErrorAlert];
        return;
    }

    self.shouldAskToPostOnWall = !self.alreadyAskedToPostOnWall && sender != nil;

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_FB_LOGIN
                                                            onQueue:[MCTComponentFramework mainQueue]];
    [[MCTComponentFramework appDelegate] ensureOpenActiveFBSessionWithReadPermissions:@[@"email", @"user_friends"]
                                                                   resultIntentAction:kINTENT_FB_LOGIN
                                                                   allowFastAppSwitch:YES
                                                                   fromViewController:self];
}

- (void)findRogerthatUsers
{
    T_UI();
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        [[MCTComponentFramework configProvider] deleteStringForKey:MCT_CONFIGKEY_FACEBOOK_FRIENDS_SCAN];
    }];
    self.fbButton.hidden = YES;
    self.dontWorryLabel.hidden = YES;
    self.fbDescription.text = NSLocalizedString(@"You will receive a notification when your Facebook friends are scanned.", nil);
    [self.spinner startAnimating];

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        [[MCTComponentFramework friendsPlugin] findRogerthatUsersViaFacebookAccessToken:FBSession.activeSession.accessTokenData.accessToken];
    }];
}

- (void)postOnWall
{
    T_UI();
    MCTIdentity *myIdentity = [[MCTComponentFramework systemPlugin] myIdentity];

    NSString *caption = [NSString stringWithFormat:NSLocalizedString(@"__fb_wall_post_caption", nil), MCT_PRODUCT_NAME];
    NSString *description = [NSString stringWithFormat:NSLocalizedString(@"__fb_wall_post_description", nil), MCT_PRODUCT_NAME];
    NSString *link = [MCTUtils stringByAppendingTargetForFacebookImageURL:myIdentity.shortUrl];
    NSString *picture = [NSString stringWithFormat:@"%@/invite?code=%@", MCT_HTTPS_BASE_URL, myIdentity.emailHash];

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   FBSession.activeSession.appID, @"app_id",
                                   picture, @"picture",
                                   link, @"link",
                                   caption, @"caption",
                                   description, @"description", nil];
    LOG(@"%@", params);

    [FBWebDialogs presentFeedDialogModallyWithSession:[FBSession activeSession]
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  // not interested in the result
                                                  [self findRogerthatUsers];
                                              }];
}

- (void)askToPostOnWall
{
    T_UI();
    self.parentVC.currentAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                                 message:[NSString stringWithFormat:NSLocalizedString(@"__fb_ask_post_on_wall", nil), MCT_PRODUCT_NAME]
                                                                delegate:self.parentVC
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                       otherButtonTitles:NSLocalizedString(@"Post", nil), nil];
    self.parentVC.currentAlertView.tag = MCT_TAG_ALERTVIEW_POST_ON_WALL;
    [self.parentVC.currentAlertView show];
    
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [[MCTComponentFramework configProvider] setString:BOOLSTR(YES)
                                                   forKey:MCT_CONFIGKEY_FACEBOOK_POST_QR_ON_WALL];
    }];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

// Called by parentVC
- (BOOL)processAlertViewClickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (self.parentVC.currentAlertView.tag != MCT_TAG_ALERTVIEW_POST_ON_WALL) {
        BUG(@"Cannot process tag %d", self.parentVC.currentAlertView.tag);
        return NO;
    }
    if (buttonIndex != self.parentVC.currentAlertView.cancelButtonIndex) {
        [self performSelectorOnMainThread:@selector(postOnWall) withObject:nil waitUntilDone:NO];
    } else {
        [self findRogerthatUsers];
    }
    MCT_RELEASE(self.parentVC.currentAlertView);
    return YES;
}

#pragma mark -
#pragma mark MCTIntent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_FB_LOGIN) {
        if ([intent boolForKey:@"canceled"]) {
            // Do nothing
        } else if ([intent boolForKey:@"error"]) {
            [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                              forIntentAction:intent.action];
            [MCTUIUtils showAlertWithFacebookErrorIntent:intent];
        } else {
            FBSession *activeSession = [FBSession activeSession];
            if (activeSession.isOpen) {
                [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                                  forIntentAction:intent.action];

                if ([activeSession.permissions containsObject:@"email"]) {
                    if (self.shouldAskToPostOnWall) {
                        [self askToPostOnWall];
                    } else {
                        [self findRogerthatUsers];
                    }
                }
            }
        }
    }
}

@end