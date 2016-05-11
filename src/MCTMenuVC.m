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

#import "GTMNSDictionary+URLArguments.h"

#import "MCTActivityPlugin.h"
#import "MCTAddFriendsVC.h"
#import "MCTComponentFramework.h"
#import "MCTDefaultResponseHandler.h"
#import "MCTFriendSearchVC.h"
#import "MCTIntent.h"
#import "MCTMenuVC.h"
#import "MCTMessagesPlugin.h"
#import "MCTScannerVC.h"
#import "MCTScanResult.h"
#import "MCTTabMessagesVC.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"
#import "MCTBeaconsVC.h"
#import "MCTLocationUsageVC.h"
#import "MCTMobileInfo.h"


#define MCT_TAG_ALERT_CONGRATS 1
#define MCT_TAG_ALERT_SCAN 2


@interface MCTMenuVC ()

@property (nonatomic) BOOL rotating;

- (void)setBadgeValue:(NSString *)value onTab:(NSInteger)index;
- (void)setBadgeNumber:(NSInteger)value onTab:(NSInteger)index;

- (void)processUrlIntent:(MCTIntent *)intent;

- (void)doJSMFRWithState:(NSDictionary *)state andUserInput:(NSDictionary *)userInput andWebView:(UIWebView *)mfrWebview;

@end


@implementation MCTMenuVC


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // I could not make it work with shouldAutomaticallyForwardAppearanceMethods
    // and automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
    IF_PRE_IOS5({
        [self.tabBarController viewWillAppear:animated];
    })
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // I could not make it work with shouldAutomaticallyForwardAppearanceMethods
    // and automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
    IF_PRE_IOS5({
        [self.tabBarController viewDidAppear:animated];
    })
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // I could not make it work with shouldAutomaticallyForwardAppearanceMethods
    // and automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
    IF_PRE_IOS5({
        [self.tabBarController viewWillDisappear:animated];
    })
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // I could not make it work with shouldAutomaticallyForwardAppearanceMethods
    // and automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
    IF_PRE_IOS5({
        [self.tabBarController viewDidDisappear:animated];
    })
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    [[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil];

    if (![MCTUtils isEmptyOrWhitespaceString:self.msgLaunchOption]) {
        [self.tabBarController setSelectedIndex:MCT_MENU_TAB_MESSAGES];
        UINavigationController *navController = (UINavigationController *) self.tabBarController.selectedViewController;
        ((MCTTabMessagesVC *) navController.visibleViewController).msgLaunchOption = self.msgLaunchOption;
    }
    else if (![MCTUtils isEmptyOrWhitespaceString:self.ackLaunchOption]) {
        [self.tabBarController setSelectedIndex:MCT_MENU_TAB_MESSAGES];
        UINavigationController *navController = (UINavigationController *) self.tabBarController.selectedViewController;
        ((MCTTabMessagesVC *) navController.visibleViewController).ackLaunchOption = self.ackLaunchOption;
    }
    else {
        [self.tabBarController setSelectedIndex:0];
    }

    CGRect f = [[UIScreen mainScreen] applicationFrame];
    f.size.height += [UIApplication sharedApplication].statusBarFrame.size.height;
    self.view.frame = f;

    [self.view addSubview:self.tabBarController.view];

    [self registerIntents];

    [self setMessageBadgeValue];

    for (int i = 0; i < [self.tabBarController.tabBar.items count]; i++) {
        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:i];
        switch (i) {
            case MCT_MENU_TAB_FRIENDS:
                switch (MCT_FRIENDS_CAPTION) {
                    case MCTFriendsCaptionColleagues: {
                        item.title = NSLocalizedString(@"Colleagues", nil);
                        break;
                    }
                    case MCTFriendsCaptionContacts: {
                        item.title = NSLocalizedString(@"Contacts", nil);
                        break;
                    }
                    case MCTFriendsCaptionFriends:
                    default: {
                        item.title = NSLocalizedString(@"Friends", nil);
                        break;
                    }
                }

                if (!MCT_FRIENDS_ENABLED) {
                    NSMutableArray *vcs = [NSMutableArray arrayWithArray:self.tabBarController.viewControllers];
                    UINavigationController *nav  = vcs[i];
                    [nav setViewControllers:@[[MCTFriendSearchVC viewController]] animated:NO];
                }
                break;
            case MCT_MENU_TAB_MESSAGES:
                item.title = NSLocalizedString(@"Messages", nil);
                break;
            case MCT_MENU_TAB_SCAN:
                item.title = NSLocalizedString(@"Scan", nil);
                break;
            case MCT_MENU_TAB_SERVICES:
                item.title = NSLocalizedString(@"Services", nil);
                break;
            default:
                break;
        }
    }

    self.jsMFRs = [NSMutableDictionary dictionary];

    [self startLocationUsage];
}

- (void)startLocationUsage
{
    T_UI();
    if ([MCTRegistrationMgr isLocationUsageShown]) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_LOCATION_START_AUTOMATIC_DETECTION];
        [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
    } else {
        MCTLocationUsageVC *vc = [MCTLocationUsageVC viewController];
        [vc setEditing:NO];
        UINavigationController *nvc = [[self.tabBarController viewControllers] objectAtIndex:0];
        [nvc pushViewController:vc animated:NO];
        [[MCTComponentFramework configProvider] setString:@"YES" forKey:MCT_CONFIGKEY_LOCATION_USAGE_SHOWN];
    }
}

- (void)registerIntents
{
    T_UI();
    [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_APPLICATION_OPEN_URL];
    [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_CHANGE_TAB];
    [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_PUSH_NOTIFICATION];
    [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_REGISTRATION_COMPLETED];

    NSArray *actions = [NSArray arrayWithObjects:kINTENT_APPLICATION_OPEN_URL, kINTENT_CHANGE_TAB,
                        kINTENT_PUSH_NOTIFICATION, kINTENT_MESSAGE_RECEIVED, kINTENT_MESSAGE_MODIFIED,
                        kINTENT_REGISTRATION_COMPLETED, kINTENT_THREAD_ACKED, kINTENT_THREAD_DELETED,
                        kINTENT_THREAD_RESTORED, kINTENT_FORWARDING_LOGS, nil];
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:actions
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)switchToTab:(NSInteger)tabIndex popToRootViewController:(BOOL)popToRoot animated:(BOOL)animated
{
    T_UI();
    [self.tabBarController setSelectedIndex:tabIndex];
    if (popToRoot) {
        if ([self.tabBarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *) self.tabBarController.selectedViewController;
            [nav popToRootViewControllerAnimated:animated];
        }
    }
}

- (void)setMessageBadgeValue
{
    T_UI();
    self.updatedMessageCount = [[[MCTComponentFramework messagesPlugin] store] countDirtyThreads];

    NSInteger number = self.updatedMessageCount;

    [UIApplication sharedApplication].applicationIconBadgeNumber = number ? 1 : 0;
    [self setBadgeNumber:number onTab:MCT_MENU_TAB_MESSAGES];
}

- (void)setBadgeValue:(NSString *)value onTab:(NSInteger)index
{
    T_UI();
    [[self.tabBarController.tabBar.items objectAtIndex:index] setBadgeValue:value];
}

- (void)setBadgeNumber:(NSInteger)value onTab:(NSInteger)index
{
    T_UI();
    NSString *str = (value) ? [NSString stringWithFormat:@"%ld", (long)value] : nil;
    [self setBadgeValue:str onTab:index];
}

#pragma mark -
#pragma mark MCTIntent

- (void)showViewController:(UIViewController *)vc
{
    T_UI();
    UINavigationController *nvc = [[self.tabBarController viewControllers] objectAtIndex:0];
    [nvc pushViewController:vc animated:NO];
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_MESSAGE_RECEIVED || intent.action == kINTENT_THREAD_ACKED
        || intent.action == kINTENT_THREAD_DELETED || intent.action == kINTENT_THREAD_RESTORED) {
        [self setMessageBadgeValue];
    }

    else if (intent.action == kINTENT_MESSAGE_MODIFIED) {
        if ([intent hasBoolKey:@"needsMyAnswer_changed"] || [intent hasBoolKey:@"dirty_changed"]) {
            [self setMessageBadgeValue];
        }
    }

    else if (intent.action == kINTENT_APPLICATION_OPEN_URL) {
        MCT_RELEASE(self.currentAlertView);
        [self processUrlIntent:intent];
    }

    else if (intent.action == kINTENT_CHANGE_TAB && [intent hasLongKey:@"tab"]) {
        NSInteger tab = [intent longForKey:@"tab"];
        [self switchToTab:tab popToRootViewController:YES animated:NO];

        if ([intent hasStringKey:MCT_CHANGE_TAB_WITH_ALERT_MESSAGE]) {
            NSString *text = [intent stringForKey:MCT_CHANGE_TAB_WITH_ALERT_MESSAGE];
            NSString *title = nil;
            if ([intent hasStringKey:MCT_CHANGE_TAB_WITH_ALERT_TITLE])
                title = [intent stringForKey:MCT_CHANGE_TAB_WITH_ALERT_TITLE];

            UINavigationController *nav = (UINavigationController *) self.tabBarController.selectedViewController;
            MCTUIViewController *vc = (MCTUIViewController *) nav.visibleViewController;
            vc.currentAlertView = [MCTUIUtils showAlertWithTitle:title andText:text];
        }
    }

    else if (intent.action == kINTENT_PUSH_NOTIFICATION) {
        [[MCTComponentFramework intentFramework] removeStickyIntent:intent];
        [self switchToTab:MCT_MENU_TAB_MESSAGES popToRootViewController:NO animated:NO];
    }

    else if (intent.action == kINTENT_REGISTRATION_COMPLETED) {
        NSArray *discoveredBeacons = [intent hasStringKey:@"discovered_beacons"] ? [[intent stringForKey:@"discovered_beacons"] MCT_JSONValue] : nil;
        BOOL hasDiscoveredBeacons = [intent hasBoolKey:@"discovered_beacons"] ? [intent boolForKey:@"discovered_beacons"] : NO;
        if ([discoveredBeacons count] > 0) {
            MCTBeaconsVC *vc = [MCTBeaconsVC viewControllerWithDiscoveredBeacons:discoveredBeacons
                                                                     showProfile:![intent boolForKey:@"age_and_gender_set"]];
            [vc setEditing:NO animated:NO];
            [self showViewController:vc];
        }
        else if (MCT_PROFILE_SHOW_GENDER_AND_BIRTHDATE && ![intent boolForKey:@"age_and_gender_set"]) {
            LOG(@"Age and gender where not set");
            MCTProfileVC *vc = [MCTProfileVC viewController];
            vc.completeProfileAfterRegistration = YES;
            vc.hasDiscoveredBeacons = hasDiscoveredBeacons;
            [vc setEditing:YES animated:NO];
            [self showViewController:vc];
        } else {
            if ([intent boolForKey:@"invitation_acked"]) {
                if (IS_ROGERTHAT_APP) {
                    self.currentAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Congratulations", nil)
                                                                       message:[NSString stringWithFormat:NSLocalizedString(@"__registration_success_without_invitation", nil), MCT_PRODUCT_NAME]
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"Roger that", nil)
                                                             otherButtonTitles:nil];
                    self.currentAlertView.tag = MCT_TAG_ALERT_CONGRATS;
                }
            } else if ([intent boolForKey:@"invitation_to_be_acked"]) {
                // Do nothing
                // MCTTabMessages will pop a ScanResultVC instance
            }
            [self.currentAlertView show];
        }
    }

    else if (intent.action == kINTENT_FORWARDING_LOGS) {
        for (UIViewController *vc in self.tabBarController.viewControllers) {
            if ([vc isKindOfClass:[UINavigationController class]]) {
                UINavigationController *nc = (UINavigationController *)vc;
                for (UIViewController *vc2 in nc.viewControllers) {
                    vc2.title = vc2.title;
                }
            } else {
                vc.title = vc.title;
            }
        }
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (alertView.tag == MCT_TAG_ALERT_SCAN && buttonIndex == alertView.cancelButtonIndex) {
        [self switchToTab:MCT_MENU_TAB_SCAN popToRootViewController:YES animated:NO];
    }
    MCT_RELEASE(self.currentAlertView);
}

#pragma mark -

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    T_UI();
    if (viewController == self.tabBarController.selectedViewController) {
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)viewController;
            [nav popToRootViewControllerAnimated:YES];
        }
        return NO;
    } else {
        switch ([self.tabBarController.viewControllers indexOfObject:viewController]) {
            case MCT_MENU_TAB_MORE:
            case MCT_MENU_TAB_SCAN:
                if ([viewController isKindOfClass:[UINavigationController class]]) {
                    UINavigationController *nav = (UINavigationController *)viewController;
                    [nav popToRootViewControllerAnimated:YES];
                }
                break;
            default:
                break;
        }
        return YES;
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    T_UI();

    switch ([self.tabBarController.viewControllers indexOfObject:viewController]) {
        case MCT_MENU_TAB_SCAN: {
            UINavigationController *nav = (UINavigationController *) viewController;
            [(MCTScannerVC *) nav.visibleViewController onScanBtnClicked:nil];
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark Process URL

- (void)processUrlIntent:(MCTIntent *)intent
{
    T_UI();
    NSString *url = [intent stringForKey:@"url"];
    NSString *suffix = [url substringFromIndex:[MCT_PREFIX_ROGERTHAT_URL length]];

    if ([MCTUtils isEmptyOrWhitespaceString:suffix]) {
        // Do nothing
    } else if ([suffix hasPrefix:MCT_GOTO]) {
        if ([suffix hasPrefix:MCT_GOTO_ADD_FRIENDS]) {
            [self switchToTab:MCT_MENU_TAB_FRIENDS popToRootViewController:YES animated:NO];

            UINavigationController *nav = (UINavigationController *) self.tabBarController.selectedViewController;
            MCTAddFriendsVC *addFriendsVC = [MCTAddFriendsVC viewController];

            if ([MCT_GOTO_ADD_FRIENDS_VIA_ADDRESSBOOK isEqualToString:suffix]) {
                [addFriendsVC showTab:MCTAddFriendsTabPhone];
            } else if ([MCT_GOTO_ADD_FRIENDS_VIA_FACEBOOK isEqualToString:suffix]) {
                [addFriendsVC showTab:MCTAddFriendsTabFacebook];
            }

            [nav pushViewController:addFriendsVC animated:NO];
        } else if ([suffix hasPrefix:MCT_GOTO_QR_SCAN]) {
            [self switchToTab:MCT_MENU_TAB_SCAN popToRootViewController:YES animated:NO];
            MCTScannerVC *scannerVC = (MCTScannerVC *) ((UINavigationController *)self.tabBarController.selectedViewController).visibleViewController;
            [scannerVC onScanBtnClicked:nil];
        } else {
            ERROR(@"Unexpected URL: %@", url);
        }
    } else {
        MCTScanResult *scanResult = [MCTScanResult scanResultWithUrl:url];
        if (scanResult) {
            switch (scanResult.action) {
                case MCTScanResultActionInvitationWithSecret:
                {
                    NSString *userCode = [scanResult.parameters stringForKey:@"userCode"];
                    NSString *secret = [scanResult.parameters stringForKey:@"s"];

                    if ([[[[MCTComponentFramework systemPlugin] myIdentity] emailHash] isEqualToString:userCode]) {
                        self.currentAlertView = [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"You opened your own invitation link", nil)];
                        return;
                    }

                    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                        T_BIZZ();
                        [[MCTComponentFramework friendsPlugin] ackInvitationWithSecret:secret andInvitorCode:userCode];
                    }];
                    break;
                }
                case MCTScanResultActionInviteFriend:
                case MCTScanResultActionService:
                {
                    [self switchToTab:MCT_MENU_TAB_MESSAGES popToRootViewController:YES animated:NO];
                    UINavigationController *nav = (UINavigationController *) [self.tabBarController.viewControllers objectAtIndex:MCT_MENU_TAB_MESSAGES];

                    BOOL skipNetworkCheck = [intent hasBoolKey:@"skipNetworkCheck"] ? [intent boolForKey:@"skipNetworkCheck"] : NO;
                    NSString *emailHash = [scanResult.parameters objectForKey:@"userCode"];
                    if ([emailHash isEqualToString:[[[MCTComponentFramework systemPlugin] myIdentity] emailHash]]) {
                        self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:[NSString stringWithFormat:NSLocalizedString(@"You scanned your own Rogerthat passport", nil), MCT_PRODUCT_NAME]];
                    }

                    UIViewController *vc = [MCTScannerVC viewControllerForScanResultWithEmailHash:emailHash
                                                                                      andMetaData:[scanResult.parameters objectForKey:@"metaData"]
                                                                          andNavigationController:nav
                                                                              andSkipNetworkCheck:skipNetworkCheck];
                    vc.title = NSLocalizedString(@"Invitation", nil);

                    [nav pushViewController:vc animated:YES];
                    break;
                }
                default:
                    ERROR(@"Unexpected URL: %@", url);
                    break;
            }
        } else {
            ERROR(@"Unknown URL: %@", url);
        }
    }
}


#pragma mark -
#pragma mark MFR

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    T_UI();
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)mfrWebView
{
    T_UI();
    HERE();
    NSDictionary *context = [self.jsMFRs objectForKey:@(mfrWebView.tag)];
    @try {
        NSString *type = [context objectForKey:@"type"];
        if ([@"js_validation" isEqualToString:type]) {
            NSString *messageKey = [context objectForKey:@"messageKey"];
            NSDictionary *value = [context objectForKey:@"value"];
            NSString *javascriptCode = [context objectForKey:@"javascriptCode"];
            NSString *email = [context objectForKey:@"email"];
            [self doJavascriptValidationForKey:messageKey andValue:value andJSCode:javascriptCode andEmail:email andWebView:mfrWebView];

        } else {
            MCTMessageFlowRun *mfr = [context objectForKey:@"mfr"];
            NSDictionary *userInput = [context objectForKey:@"userInput"];
            [self doJSMFRWithState:[mfr.state MCT_JSONValue] andUserInput:userInput andWebView:mfrWebView];
        }
    }
    @finally {
        [self.jsMFRs removeObjectForKey:@(mfrWebView.tag)];
        mfrWebView.delegate = nil;
        [mfrWebView removeFromSuperview];
        mfrWebView = nil;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    T_UI();
    LOG(@"Webview error: %@", error);
    [MCTSystemPlugin logError:[NSException exceptionWithName:@"WebViewDidFailLoadWithError" reason:nil userInfo:nil]
                  withMessage:[NSString stringWithFormat:@"webView: didFailLoadWithError:\n%@", error]];
    [self.jsMFRs removeObjectForKey:@(webView.tag)];
}

- (void)executeMFR:(MCTMessageFlowRun *)mfr withUserInput:(NSDictionary *)userInput throwIfNotReady:(BOOL)throwIfNotReady
{
    T_UI();
    NSString *htmlString = [[[MCTComponentFramework friendsPlugin] store] staticFlowWithHash:mfr.staticFlowHash];
    if ([MCTUtils isEmptyOrWhitespaceString:htmlString]) {
        if (throwIfNotReady) {
            @throw [MCTBizzException exceptionWithName:@""
                                                reason:NSLocalizedString(@"This screen is not yet downloaded. Check your network.", nil)
                                              userInfo:nil];
        } else {
            NSString *errMsg = [NSString stringWithFormat:@"HTML string for flow %@ is empty!", mfr.staticFlowHash];
            ERROR(@"%@", errMsg);

            NSException *err = [NSException exceptionWithName:@"EmptyStaticFlowHTML" reason:nil userInfo:nil];
            [MCTSystemPlugin logError:err withMessage:errMsg];
        }
        return;
    }

    int tag = 0;
    for (NSNumber *currentTag in [self.jsMFRs allKeys])
        tag = MAX(tag, [currentTag intValue]);
    tag++;

    UIWebView *mfrWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    mfrWebView.delegate = self;
    mfrWebView.tag = tag;
    [self.view addSubview:mfrWebView];

    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:@"jsmfr", @"type", mfr, @"mfr", userInput, @"userInput", nil];
    [self.jsMFRs setObject:context forKey:@(mfrWebView.tag)];

    [mfrWebView loadHTMLString:htmlString baseURL:nil];
}

- (BOOL)executeJavascriptValidationForKey:(NSString *)messageKey
                                andJSCode:(NSString *)javascriptCode
                                 andValue:(NSDictionary *)value
                                 andEmail:(NSString *)email
{
    T_UI();

    NSString *appHome = [[NSBundle mainBundle] bundlePath];

    NSString *path = [appHome stringByAppendingPathComponent:@"validation.js"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        BUG(@"Cannot find file at path %@", path);
        return NO;
    }

    LOG(@"Validate input using %@", [path lastPathComponent]);

    NSError *err;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    if (content == nil) {
        ERROR(@"Error while reading file [%@]", path);
        if (err) {
            ERROR(@"Error details: %@", err);
        }
        return NO;
    }

    int tag = 0;
    for (NSNumber *currentTag in [self.jsMFRs allKeys])
        tag = MAX(tag, [currentTag intValue]);
    tag++;

    UIWebView *mfrWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    mfrWebView.delegate = self;
    mfrWebView.tag = tag;
    [self.view addSubview:mfrWebView];
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:@"js_validation", @"type",
                             messageKey, @"messageKey", value, @"value", javascriptCode, @"javascriptCode", email, @"email", nil];
    [self.jsMFRs setObject:context forKey:@(mfrWebView.tag)];

    [mfrWebView loadHTMLString:content baseURL:nil];

    return YES;
}

- (NSArray *)rpcCallsFromActions:(NSArray *)actions
{
    T_DONTCARE();
    NSMutableArray *rpcCalls = [NSMutableArray arrayWithCapacity:[actions count]];

    if (actions && actions != MCTNull) {
        for (NSDictionary *action in actions) {
            MCTRPCCall *call = [MCTRPCCall callWithDict:action];
            if (call == nil) {
                ERROR(@"Received unparseable call from JSMFR %@", action);
            } else {
                [rpcCalls addObject:call];
            }
        }
    }

    return rpcCalls;
}

- (void)doJSMFRWithState:(NSDictionary *)state andUserInput:(NSDictionary *)userInput andWebView:(UIWebView *)mfrWebView
{
    T_UI();
    NSMutableDictionary *mutableState = nil;
    if (state) {
        mutableState = [NSMutableDictionary dictionaryWithDictionary:state];
        if (![mutableState objectForKey:@"member"]) {
            mutableState[@"member"] = [[MCTComponentFramework friendsPlugin] myEmail];
        }
    } else {
        mutableState = [NSMutableDictionary dictionaryWithObject:[[MCTComponentFramework friendsPlugin] myEmail] forKey:@"member"];
    }

    NSDictionary *request = [userInput objectForKey:@"request"];
    NSString *serviceEmail = [request stringForKey:@"service" withDefaultValue:nil];
    if (serviceEmail == nil) {
        serviceEmail = [request stringForKey:@"email" withDefaultValue:nil];
    }
    MCTFriend *service = nil;
    if (serviceEmail && ![mutableState objectForKey:@"user"]) {
        service = [[[MCTComponentFramework friendsPlugin] store] friendByEmail:serviceEmail];
    }
    if (service) {
        NSDictionary *info = [[MCTComponentFramework friendsPlugin] getRogerthatUserAndServiceInfoByService:service];
        mutableState[@"user"] = [info objectForKey:@"user"];
        mutableState[@"service"] = [info objectForKey:@"service"];
        mutableState[@"system"] = [info objectForKey:@"system"];
    } else if (![mutableState objectForKey:@"user"]){
        mutableState[@"user"] = nil;
        mutableState[@"service"] = nil;
        mutableState[@"system"] = nil;
    }

    NSString *jsCommand = [NSString stringWithFormat:@"mc_run_ext(transition, '%@', %@, %@);",
                           MCT_PRODUCT_VERSION, [mutableState MCT_JSONRepresentation], [userInput MCT_JSONRepresentation]];

    //LOG([jsCommand stringByReplacingOccurrencesOfString:@"%" withString:@"%%"]);

    NSString *jsResult = [mfrWebView stringByEvaluatingJavaScriptFromString:jsCommand];

    @try {
        LOG(@"Got JSMFR result: %@", jsResult);
        if ([MCTUtils isEmptyOrWhitespaceString:jsResult])
            @throw [NSException exceptionWithName:@"JSONDecodeError"
                                           reason:@"Cannot decode empty JSON"
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   jsCommand, @"js_command", nil]];

        NSObject *result = [jsResult MCT_JSONValue];
        if (!result)
            @throw [NSException exceptionWithName:@"JSONDecodeError"
                                           reason:[NSString stringWithFormat:@"Cannot decode JSON: %@", jsResult]
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   jsCommand, @"js_command", nil]];

        NSDictionary *resultDict = (NSDictionary *)result;
        if ([resultDict boolForKey:@"success"]) {
            NSDictionary *realResult = [resultDict dictForKey:@"result"];
            NSDictionary *newState = [realResult dictForKey:@"newstate"];
            NSArray *serverActions = [realResult arrayForKey:@"server_actions"];
            NSArray *localActions = [realResult arrayForKey:@"local_actions"];

            MCTMessageFlowRun *mfr = [MCTMessageFlowRun messageFlowRun];
            mfr.parentKey = [[newState dictForKey:@"run"] stringForKey:@"parent_message_key"];
            mfr.state = [newState MCT_JSONRepresentation];
            mfr.staticFlowHash = [newState stringForKey:@"static_flow_hash"];

            NSOperation *processIncomingCalls = [NSBlockOperation blockOperationWithBlock:^{
                T_BACKLOG();
                [[[MCTComponentFramework messagesPlugin] store] saveMessageFlowRun:mfr];

                for (MCTRPCCall *call in [self rpcCallsFromActions:localActions]) {
                    @try {
                        id<IJSONable> result = [[MCTComponentFramework callReceiver] processIncomingCall:call];
                        if (result == nil) {
                            [MCTSystemPlugin logErrorWithMessage:[NSString stringWithFormat:@"Failure happened while processing incoming JSMFR call: %@",
                                                                  [[call dictRepresentation] MCT_JSONRepresentation]]
                                                     description:nil];
                        }
                    } @catch (NSException *exception) {
                        [MCTSystemPlugin logError:exception
                                      withMessage:[NSString stringWithFormat:@"Failure happened while processing incoming JSMFR call: %@",
                                                   [call dictRepresentation]]];
                    }
                }
            }];
            [processIncomingCalls setQueuePriority:NSOperationQueuePriorityVeryHigh];
            [[MCTComponentFramework commQueue] addOperation:processIncomingCalls];

            [[MCTComponentFramework commQueue] addOperationWithBlock:^{
                T_BACKLOG();
                for (MCTRPCCall *call in [self rpcCallsFromActions:serverActions]) {
                    MCTAbstractResponseHandler *responseHandler = [MCTDefaultResponseHandler defaultResponseHandler];
                    [[MCTComponentFramework protocol] callToServerWithFunction:call.function
                                                                  andArguments:call.arguments
                                                            andResponseHandler:responseHandler];
                }
            }];

        } else {
            NSString *errMessage = [resultDict stringForKey:@"errmessage"];
            NSString *errName = [resultDict stringForKey:@"errname"];
            NSString *errStack = [resultDict stringForKey:@"errstack"];

            @throw [NSException exceptionWithName:errName
                                           reason:errMessage
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   jsCommand, @"js_command", errStack, @"err_stack", nil]];
        }
    }
    @catch (NSException *exception) {
        ERROR(@"%@", exception);

        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_MESSAGE_JSMFR_ERROR];

        NSString *parentMessageKey = [[mutableState objectForKey:@"run"] objectForKey:@"parent_message_key"];
        if (![MCTUtils isEmptyOrWhitespaceString:parentMessageKey]) {
            [intent setString:parentMessageKey forKey:@"parent_message_key"];
        }

        NSString *context = [[userInput objectForKey:@"request"] objectForKey:@"context"];
        if (![MCTUtils isEmptyOrWhitespaceString:context]) {
            [intent setString:context forKey:@"context"];
        }

        [[MCTComponentFramework intentFramework] broadcastIntent:intent];

        self.currentAlertView = [MCTUIUtils showErrorPleaseRetryAlert];

        [[MCTComponentFramework messagesPlugin] logJSMFRError:exception];
    }
}

- (void)doJavascriptValidationForKey:(NSString *)messageKey
                            andValue:(NSDictionary *)value
                           andJSCode:(NSString *)javascriptcode
                            andEmail:(NSString *)email
                          andWebView:(UIWebView *)mfrWebView
{
    T_UI();
    NSMutableDictionary *rt = [NSMutableDictionary dictionary];
    MCTFriend *service = [[[MCTComponentFramework friendsPlugin] store] friendByEmail:email];
    if (service) {
        NSDictionary *info = [[MCTComponentFramework friendsPlugin] getRogerthatUserAndServiceInfoByService:service];
        rt[@"user"] = [info objectForKey:@"user"];
        rt[@"service"] = [info objectForKey:@"service"];
        rt[@"system"] = [info objectForKey:@"system"];
    } else {
        rt[@"user"] = nil;
        rt[@"service"] = nil;
        rt[@"system"] = nil;
    }

    NSDictionary *validationParams = [NSDictionary dictionaryWithObjectsAndKeys:value, @"result", javascriptcode, @"javascriptcode",  rt, @"rogerthat", nil];
    NSString *jsCommand = [NSString stringWithFormat:@"mc_run_ext(validation, %@);",
                           [validationParams MCT_JSONRepresentation]];

    NSString *jsResult = [mfrWebView stringByEvaluatingJavaScriptFromString:jsCommand];
    LOG(@"Got Javascript Validation result: %@", jsResult);

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_MESSAGE_JS_VALIDATION_RESULT];
    [intent setString:messageKey forKey:@"message_key"];
    [intent setString:@"" forKey:@"result"];
    @try {
        if (![MCTUtils isEmptyOrWhitespaceString:jsResult]) {
            NSObject *result = [jsResult MCT_JSONValue];
            if (result) {
                NSDictionary *resultDict = (NSDictionary *)result;
                if ([resultDict boolForKey:@"success"]) {
                    NSDictionary *realResult = [resultDict dictForKey:@"result"];
                    NSString *returnValue = [realResult stringForKey:@"return_value"];
                    NSArray *serverActions = [realResult arrayForKey:@"server_actions"];
                    if (![MCTUtils isEmptyOrWhitespaceString:returnValue]) {
                        [intent setString:returnValue forKey:@"result"];
                    }
                    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
                        T_BACKLOG();
                        for (MCTRPCCall *call in [self rpcCallsFromActions:serverActions]) {
                            MCTAbstractResponseHandler *responseHandler = [MCTDefaultResponseHandler defaultResponseHandler];
                            [[MCTComponentFramework protocol] callToServerWithFunction:call.function
                                                                          andArguments:call.arguments
                                                                    andResponseHandler:responseHandler];
                        }
                    }];
                }
            }
        }
    }
    @catch (NSException *exception) {
        ERROR(@"%@", exception);
    }

    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (UINavigationController *)currentNavigationController
{
    UINavigationController *navigationController;
    if (MCT_HOME_SCREEN_STYLE == MCT_HOME_SCREEN_STYLE_TABS) {
        return (UINavigationController *) self.tabBarController.selectedViewController;
    } else {
        return self.navigationController;
    }
}

- (BOOL)shouldAutorotate
{
    T_UI();
    HERE();
    if (self.rotating) {
        return NO;
    }

    self.rotating = YES;
    @try {
        UINavigationController *currentNavigationController = [self currentNavigationController];
        if (currentNavigationController == nil || currentNavigationController.topViewController == self) {
            BOOL shouldAutoRotate = !UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)
                && UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation);
            LOG(@"%@, %@", [self class], BOOLSTR(shouldAutoRotate));
            return shouldAutoRotate;
        }
        return [currentNavigationController.topViewController shouldAutorotate];
    }
    @finally {
        self.rotating = NO;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    T_UI();
    HERE();
    UINavigationController *currentNavigationController = [self currentNavigationController];
    if (currentNavigationController == nil || currentNavigationController.topViewController == self) {
        LOG(@"supportedInterfaceOrientations: UIInterfaceOrientationMaskPortrait");
        return UIInterfaceOrientationMaskPortrait;
    }
    return [currentNavigationController.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    T_UI();
    HERE();
    UINavigationController *currentNavigationController = [self currentNavigationController];
    if (currentNavigationController == nil || currentNavigationController.topViewController == self) {
        LOG(@"preferredInterfaceOrientationForPresentation: UIInterfaceOrientationPortrait");
        return UIInterfaceOrientationPortrait;
    }
    return [currentNavigationController.topViewController preferredInterfaceOrientationForPresentation];
}

@end