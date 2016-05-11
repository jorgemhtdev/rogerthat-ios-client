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
#import "MCTFriend.h"
#import "MCTFriendDetailVC.h"
#import "MCTMessageDetailVC.h"
#import "MCTOperation.h"
#import "MCTScanResultVC.h"
#import "MCTServiceDetailVC.h"
#import "MCTUIUtils.h"

#import "NSData+Base64.h"

#define MARGIN 10

#define MCT_TAG_ERROR_WITH_ACTION 1


@interface MCTScanResultVC ()

- (void)loadFriendFromIntent:(MCTIntent *)intent;

- (void)invite:(id)sender;
- (void)poke:(id)sender;
- (void)setProgress;
- (void)loadMessageWithKey:(NSString *)key;

@end


@implementation MCTScanResultVC


+ (MCTScanResultVC *)viewControllerWithEmailHash:(NSString *)emailHash andMetaData:(NSString *)metaData
{
    T_UI();
    MCTScanResultVC *vc = [[MCTScanResultVC alloc] initWithNibName:@"scanResult" bundle:nil];
    vc.emailHash = emailHash;
    vc.metaData = metaData;
    vc.skipConnectionCheck = NO;
    vc.hidesBottomBarWhenPushed = YES;
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    if (!self.skipConnectionCheck && ![MCTUtils connectedToInternetAndXMPP]) {
        self.nameLabel.hidden = YES;
        self.emailLabel.hidden = YES;

        self.currentAlertView = [MCTUIUtils showNetworkErrorAlert];
        self.currentAlertView.delegate = self;
        return;
    }

    [MCTUIUtils addRoundedBorderToView:self.avatarImageView];

    self.friendsPlugin = [MCTComponentFramework friendsPlugin];

    // Show spinner while loading user info
    self.loadingView = [[UIView alloc] initWithFrame:self.view.frame];
    self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [MCTUIUtils setBackgroundPlainToView:self.loadingView];

    CGFloat x = 65;
    CGFloat w = self.view.frame.size.width - x - 20;
    CGFloat y = 20;
    IF_IOS7_OR_GREATER({
        y += 64;
    });
    self.spinnerLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, 37)];
    self.spinnerLabel.text = NSLocalizedString(@"Loading ...", nil);
    self.spinnerLabel.textColor = [UIColor blackColor];
    self.spinnerLabel.backgroundColor = [UIColor clearColor];

    self.spinner = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.spinnerLabel.center;
    CGRect f = self.spinner.frame;
    f.origin.x = 20;
    self.spinner.frame = f;
    self.spinner.backgroundColor = [UIColor clearColor];
    [self.spinner startAnimating];

    [self.view addSubview:self.loadingView];
    [self.loadingView addSubview:self.spinner];
    [self.loadingView addSubview:self.spinnerLabel];

    NSArray *actions = [NSArray arrayWithObjects:kINTENT_USER_INFO_RETRIEVED, kINTENT_SERVICE_ACTION_RETRIEVED,
                        kINTENT_SERVICE_BRANDING_RETRIEVED, kINTENT_MESSAGE_JSMFR_ERROR, nil];
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:actions
                                                            onQueue:[MCTComponentFramework mainQueue]];

    NSString *emailHash = self.emailHash;
    NSString *tag = self.metaData;
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        if (tag == nil) {
            [[MCTComponentFramework friendsPlugin] requestUserInfoWithEmailHash:emailHash];
        } else {
            [[MCTComponentFramework friendsPlugin] serviceActionInfoWithEmailHash:emailHash andAction:tag];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    T_UI();
    [super viewWillDisappear:animated];
    [self resetNavigationControllerAppearance];
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
    }
    [super viewDidDisappear:animated];
}

- (void)reloadFriendDetails
{
    T_UI();
    if (self.friend == nil) {
        ERROR(@"Expecting that self.friend is not nil");
        return;
    }

    // HEADER VIEW
    self.avatarImageView.image = [self.friend avatarImage];
    self.nameLabel.text = [self.friend displayName];
    self.emailLabel.text = [self.friend displayEmail];

    // CONNECT/POKE BUTTON
    if (self.ttBtn) {
        [self.ttBtn removeFromSuperview];
        MCT_RELEASE(self.ttBtn);
    }

    self.ttBtn = [TTButton buttonWithStyle:@"magicButton:" title:self.friend.pokeDescription];

    NSString *btnTitle;
    SEL btnActionSelector;
    if (![MCTUtils isEmptyOrWhitespaceString:self.friend.pokeDescription]) {
        btnTitle = self.friend.pokeDescription;
        btnActionSelector = @selector(poke:);
    } else if (self.friend.type == MCTFriendTypeUser && !IS_ENTERPRISE_APP) {
        btnTitle = NSLocalizedString(@"Become friends", nil);
        btnActionSelector = @selector(invite:);
    } else {
        btnTitle = NSLocalizedString(@"Connect", nil);
        btnActionSelector = @selector(invite:);
    }
    [self.ttBtn setTitle:btnTitle forState:UIControlStateNormal];
    [self.ttBtn addTarget:self action:btnActionSelector forControlEvents:UIControlEventTouchUpInside];

    CGFloat ttBtnY = CGRectGetMaxY(self.headerView.frame);
    CGFloat ttBtnW = self.view.frame.size.width - 2 * MARGIN;
    CGFloat ttBtnH = [MCTUIUtils sizeForTTButton:self.ttBtn constrainedToSize:CGSizeMake(ttBtnW, 126)].height;
    self.ttBtn.frame = CGRectMake(MARGIN, ttBtnY, ttBtnW, MAX(44, ttBtnH));

    [self.scrollView addSubview:self.ttBtn];

    // SERVICE DESCRIPTION
    if (self.webView) {
        [self.webView removeFromSuperview];
        MCT_RELEASE(self.webView);
    }
    MCT_RELEASE(self.brandingResult);

    if ([self.friend branded]) {
        if (self.textView) {
            [self.textView removeFromSuperview];
            MCT_RELEASE(self.textView);
        }

        CGRect f = CGRectMake(0, CGRectGetMaxY(self.ttBtn.frame) + MARGIN, self.scrollView.frame.size.width, 1);
        self.webView = [[UIWebView alloc] initWithFrame:f];
        self.webView.bounces = NO;
        self.webView.delegate = self;
        [self.scrollView addSubview:self.webView];

        if ([[MCTComponentFramework brandingMgr] isBrandingAvailable:self.friend.descriptionBranding]) {
            self.brandingResult = [[MCTComponentFramework brandingMgr] prepareBrandingWithFriend:self.friend];
            [self.webView loadBrandingResult:self.brandingResult];
        } else {
            MCTFriend *bFriend = self.friend;
            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                T_BIZZ();
                [[MCTComponentFramework brandingMgr] queueFriend:bFriend];
            }];
        }

        // self.scrollView.contentSize is set in resizeWebView
    } else if (![MCTUtils isEmptyOrWhitespaceString:self.friend.descriptionX]) {
        if (!self.textView) {
            self.textView = [[UITextView alloc] init];
            self.textView.backgroundColor = [UIColor clearColor];
            self.textView.editable = NO;
            self.textView.font = [UIFont systemFontOfSize:15];
            self.textView.scrollEnabled = NO;
            self.textView.textColor = [UIColor blackColor];
        }

        self.textView.text = self.friend.descriptionX;

        CGFloat w = self.scrollView.frame.size.width;
        CGSize s = [MCTUIUtils sizeForTextView:self.textView withWidth:w];
        CGRect f = CGRectMake(0, CGRectGetMaxY(self.ttBtn.frame) + MARGIN, w, s.height);
        self.textView.frame = f;

        [self.scrollView addSubview:self.textView];

        self.scrollView.contentSize = CGSizeMake(w, CGRectGetMaxY(f));
    } else {
        if (self.textView) {
            [self.textView removeFromSuperview];
            MCT_RELEASE(self.textView);
        }
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, CGRectGetMaxY(self.ttBtn.frame));
    }

    UIColor *backgroundColor = [self backGroundColorForBrandingResult:self.brandingResult];
    MCTColorScheme scheme = [self colorSchemeForBrandingResult:self.brandingResult];

    UIColor *textColor = (scheme == MCTColorSchemeLight) ? [UIColor blackColor] : [UIColor whiteColor];
    self.emailLabel.textColor = self.nameLabel.textColor = textColor;
    self.view.backgroundColor = backgroundColor;

    [self changeNavigationControllerAppearanceWithColorScheme:scheme
                                           andBackGroundColor:backgroundColor];
}

 #pragma mark -
 #pragma mark Poke

- (void)invite:(id)sender
{
    T_UI();
    NSString *emailHash = self.emailHash;
    NSString *name = [self.friend displayName];
    NSString *tag = self.metaData;
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [[MCTComponentFramework friendsPlugin] inviteFriendWithEmail:emailHash andName:name andMessage:tag];
    }];

    self.currentAlertView = [MCTUIUtils showAlertWithTitle:[self.friend displayName]
                                                   andText:NSLocalizedString(@"Successfully sent request", nil)];
    self.currentAlertView.delegate = self;
}

- (void)poke:(id)sender
{
    T_UI();
    NSString *context = [NSString stringWithFormat:@"QRSCAN_%@", [MCTUtils guid]];
    NSString *email = self.friend.email;
    NSString *tag = self.metaData ? self.metaData : MCTNull;

    BOOL willLaunchStaticFlow = self.staticFlow && self.staticFlowHash;

    if (!willLaunchStaticFlow) {
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            T_BIZZ();
            [[MCTComponentFramework friendsPlugin] pokeService:email withAction:tag context:context];
        }];
    }

    if (willLaunchStaticFlow || [MCTUtils connectedToInternetAndXMPP]) {
        [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                        forIntentAction:kINTENT_MESSAGE_RECEIVED_HIGH_PRIO
                                                                onQueue:[MCTComponentFramework mainQueue]];
        self.context = context;
        self.pokePressTime = [MCTUtils currentTimeMillis];

        self.currentActionSheet = [MCTUIUtils showProgressActionSheetWithTitle:NSLocalizedString(@"Processing ...", nil)
                                                       inViewController:self];
        [self performSelector:@selector(setProgress) withObject:nil afterDelay:0.08];

        if (willLaunchStaticFlow) {
            NSString *bStaticFlow = self.staticFlow;
            NSString *bStaticFlowHash = self.staticFlowHash;
            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                [[[MCTComponentFramework friendsPlugin] store] saveStaticFlow:bStaticFlow withHash:bStaticFlowHash];

                MCTMessageFlowRun *mfr = [MCTMessageFlowRun messageFlowRun];
                mfr.staticFlowHash = bStaticFlowHash;

                MCT_com_mobicage_to_service_StartServiceActionRequestTO *request = [MCT_com_mobicage_to_service_StartServiceActionRequestTO transferObject];
                request.email = email;
                request.action = tag == MCTNull ? nil : tag;
                request.context = context;
                request.static_flow_hash = bStaticFlowHash;
                request.timestamp = [MCTUtils currentServerTime];

                NSDictionary *userInput = [NSDictionary dictionaryWithObjectsAndKeys:[request dictRepresentation], @"request",
                                           @"com.mobicage.api.services.startAction", @"func", nil];

                dispatch_async(dispatch_get_main_queue(), ^{
                    T_UI();
                    [[MCTComponentFramework menuViewController] executeMFR:mfr withUserInput:userInput throwIfNotReady:NO];
                });

            }];
        }
    } else {
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:NSLocalizedString(@"Action will start when you have network connectivity.", nil)];
        self.currentAlertView.delegate = self;
    }
}

- (void)setProgress
{
    T_UI();
    UIProgressView *progressView = (UIProgressView *) [self.currentActionSheet viewWithTag:1];
    float progress = [MCTUtils currentTimeMillis] - self.pokePressTime;
    if (self.pokePressTime && progress < 10000) {
        progressView.progress = progress / 10000.0f;

        [self performSelector:@selector(setProgress) withObject:nil afterDelay:0.08];
    } else {
        progressView.progress = 1;
        MCT_RELEASE(self.currentActionSheet);
        MCT_RELEASE(self.context);
        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:NSLocalizedString(@"Action scheduled successfully", nil)];
        self.currentAlertView.delegate = self;
    }
}

- (void)loadMessageWithKey:(NSString *)key
{
    T_UI();
    MCT_RELEASE(self.currentActionSheet);

    NSMutableArray *vcs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    if ([vcs count])
        [vcs removeLastObject];
    [vcs addObject:[MCTMessageDetailVC viewControllerWithMessageKey:key]];
    [self.navigationController setViewControllers:vcs animated:YES];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    T_UI();
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        LOG(@"Opening URL of request: %@", request);
        [[UIApplication sharedApplication] openURL:[request URL]];
    }
    return navigationType != UIWebViewNavigationTypeLinkClicked;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    T_UI();
    [self performSelector:@selector(resizeWebView) withObject:nil afterDelay:0.1];
}

- (void)resizeWebView
{
    T_UI();
    HERE();
    CGSize s = [self.webView sizeThatFits:CGSizeMake(self.scrollView.frame.size.width, 0)];
    CGRect f = self.webView.frame;
    f.size.height = MAX(s.height, self.scrollView.frame.size.height - f.origin.y);
    self.webView.frame = f;

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(f));
    LOG(@"Reset scrollView.contentSize to %@", NSStringFromCGSize(self.scrollView.contentSize));
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    T_UI();
    if (alertView.tag == MCT_TAG_ERROR_WITH_ACTION) {
        if (buttonIndex != alertView.cancelButtonIndex && self.currentErrorAction) {
            LOG(@"Opening %@", self.currentErrorAction);
            [[UIApplication sharedApplication] openURL:self.currentErrorAction];
        }
    }

    [self.navigationController popViewControllerAnimated:YES];
    MCT_RELEASE(self.currentAlertView);
    MCT_RELEASE(self.currentErrorAction);
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == MCT_TAG_ERROR_WITH_ACTION) {
        if (buttonIndex != actionSheet.cancelButtonIndex && self.currentErrorAction) {
            LOG(@"Opening %@", self.currentErrorAction);
            [[UIApplication sharedApplication] openURL:self.currentErrorAction];
        }
    }

    [self.navigationController popViewControllerAnimated:YES];
    MCT_RELEASE(self.currentAlertView);
    MCT_RELEASE(self.currentErrorAction);
}

#pragma mark - MCTIntent

- (void)loadFriendFromIntent:(MCTIntent *)intent
{
    T_UI();
    self.friend = [MCTFriend aFriend];
    self.friend.name = [intent stringForKey:@"name"];
    NSString *b64avatar = [intent stringForKey:@"avatar"];
    if (![MCTUtils isEmptyOrWhitespaceString:b64avatar])
        self.friend.avatar = [NSData dataFromBase64String:b64avatar];
    self.friend.existence = -1;

    if ([intent hasStringKey:@"email"]) {
        NSString *email = [intent stringForKey:@"email"];
        if (![MCTUtils isEmptyOrWhitespaceString:email]) {
            self.friend.email = email;
            if ([self.friendsPlugin.store friendByEmail:self.friend.email]) {
                self.friend.existence = MCTFriendExistenceActive;
            }
        }
    }

    if ([intent hasLongKey:@"type"])
        self.friend.type = [intent longForKey:@"type"];

    if ([intent hasStringKey:@"description"])
        self.friend.descriptionX = [intent stringForKey:@"description"];

    if ([intent hasStringKey:@"descriptionBranding"])
        self.friend.descriptionBranding = [intent stringForKey:@"descriptionBranding"];

    if ([intent hasStringKey:@"actionDescription"])
        self.friend.pokeDescription = [intent stringForKey:@"actionDescription"];

    if ([intent hasStringKey:@"qualifiedIdentifier"])
        self.friend.qualifiedIdentifier = [intent stringForKey:@"qualifiedIdentifier"];

    if ([intent hasStringKey:@"staticFlow"] && [intent hasStringKey:@"staticFlowHash"]) {
        self.staticFlowHash = [intent stringForKey:@"staticFlowHash"];
        self.staticFlow = [intent stringForKey:@"staticFlow"];
    }
    [self reloadFriendDetails];
    [self.loadingView removeFromSuperview];
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_USER_INFO_RETRIEVED || intent.action == kINTENT_SERVICE_ACTION_RETRIEVED) {
        if ([self.emailHash isEqualToString:[intent stringForKey:@"hash"]]) {
            [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                              forIntentAction:intent.action];
            if ([intent boolForKey:@"success"]) {
                [self loadFriendFromIntent:intent];
            } else {
                NSString *errorMessage = [intent hasStringKey:@"errorMessage"] ? [intent stringForKey:@"errorMessage"] : nil;
                if ([MCTUtils isEmptyOrWhitespaceString:errorMessage]) {
                    self.currentAlertView = [MCTUIUtils showErrorPleaseRetryAlert];
                    self.currentAlertView.delegate = self;
                } else {
                    NSString *errorCaption = [intent stringForKey:@"errorCaption"];
                    NSString *errorAction = [intent stringForKey:@"errorAction"];
                    NSString *errorTitle = [intent stringForKey:@"errorTitle"];

                    self.currentErrorAction = nil;

                    if (![MCTUtils isEmptyOrWhitespaceString:errorCaption] &&
                        ![MCTUtils isEmptyOrWhitespaceString:errorAction]) {
                        NSURL *errorActionURL = [NSURL URLWithString:errorAction];
                        if ([[UIApplication sharedApplication] canOpenURL:errorActionURL]) {
                            self.currentErrorAction = errorActionURL;
                        } else {
                            LOG(@"Can not open %@ !", errorActionURL);
                        }
                    }

                    if (self.currentErrorAction) {
                        NSString *actionSheetTitle;
                        if ([MCTUtils isEmptyOrWhitespaceString:errorTitle]) {
                            actionSheetTitle = errorMessage;
                        } else {
                            actionSheetTitle = [NSString stringWithFormat:@"%@\n\n%@", errorTitle, errorMessage];
                        }

                        self.currentActionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                                               delegate:self
                                                                      cancelButtonTitle:NSLocalizedString(@"Roger that", nil)
                                                                 destructiveButtonTitle:nil
                                                                      otherButtonTitles:errorCaption, nil];
                        self.currentActionSheet.tag = MCT_TAG_ERROR_WITH_ACTION;
                        [MCTUIUtils showActionSheet:self.currentActionSheet inViewController:self];
                    } else {
                        self.currentAlertView = [MCTUIUtils showAlertWithTitle:[intent stringForKey:@"errorTitle"]
                                                                       andText:[intent stringForKey:@"errorMessage"]];
                        self.currentAlertView.delegate = self;
                    }
                }
            }
        }
    }
    else if (intent.action == kINTENT_SERVICE_BRANDING_RETRIEVED) {
        if (self.friend.email && [self.friend.email isEqualToString:[intent stringForKey:@"email"]])
            [self reloadFriendDetails];
    }
    else if (intent.action == kINTENT_MESSAGE_RECEIVED_HIGH_PRIO) {
        if (self.context && [self.context isEqualToString:[intent stringForKey:@"context"]]) {
            [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                              forIntentAction:kINTENT_MESSAGE_RECEIVED_HIGH_PRIO];
            MCT_RELEASE(self.context);
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setProgress) object:nil];
            ((UIProgressView *)[self.currentActionSheet viewWithTag:1]).progress = 1;
            [self performSelector:@selector(loadMessageWithKey:)
                       withObject:[intent stringForKey:@"message_key"]
                       afterDelay:0.1];
        }
    }
    else if (intent.action == kINTENT_MESSAGE_JSMFR_ERROR) {
        if (self.context && [intent hasStringKey:@"context"] && [self.context isEqualToString:[intent stringForKey:@"context"]]) {
            MCT_RELEASE(self.context);
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setProgress) object:nil];
            MCT_RELEASE(self.currentActionSheet);
        }
    }
}

#pragma mark -

@end