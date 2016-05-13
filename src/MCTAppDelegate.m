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

#import "MCTAppDelegate.h"
#import "MCTApplePush.h"
#import "MCTComponentFramework.h"
#import "MCTConfigProvider.h"
#import "MCTCredentials.h"
#import "MCTHTTPRequest.h"
#import "MCTIntent.h"
#import "MCTIntentFramework.h"
#import "MCTLogForwarding.h"
#import "MCTMainViewController.h"
#import "MCTMenuVC.h"
#import "MCTOperation.h"
#import "MCTSecurity.h"
#import "MCTSettingsVC.h"

#import "MCTActivityPlugin.h"
#import "MCTFriendsPlugin.h"
#import "MCTLocationPlugin.h"
#import "MCTMessagesPlugin.h"
#import "MCTSystemPlugin.h"
#import "MCTUIUtils.h"

#import "GTMNSDictionary+URLArguments.h"
#import "MDPMobile.h"
#import "MCTCachedDownloader.h"


#define MCT_KEEPALIVE_TIMEOUT 600


@interface MCTAppDelegate ()

- (MCTMainViewController *)mainViewController;

- (void)broadcastFBIntentWithAction:(NSString *)action
                            session:(FBSession *)session
                              state:(FBSessionState)state
                              error:(NSError *)error;

@property (nonatomic, strong) NSMutableArray *fetchCompletionHandlers;
@property (nonatomic, strong) NSMutableDictionary *sessionCompletionHandlers;

@end


@implementation MCTAppDelegate


- (void)settingsChange:(NSNotification *)notification
{
    T_UI();
    HERE();
}

#pragma mark -
#pragma mark plugins and registration

- (MCTMainViewController *)mainViewController
{
    return (MCTMainViewController *)self.window.rootViewController;
}

- (MCTMenuVC *)menuViewController
{
    UIViewController *vc = [self mainViewController].presentedViewController;
    if ([vc isKindOfClass:[UINavigationController class]])
        vc = [((UINavigationController *) vc).viewControllers firstObject];
    if ([vc isKindOfClass:[MCTMenuVC class]])
        return (MCTMenuVC *) vc;
    return nil;
}


- (BOOL)isRegistered
{
    T_UI();
    return ( ([self.configProvider stringForKey:MCT_CONFIGKEY_USERNAME] != nil)
            && ([self.configProvider stringForKey:MCT_CONFIGKEY_PASSWORD] != nil) );
}

- (void)initializePlugins
{
    T_BIZZ();
    @synchronized(self.pluginLock) {
        self.brandingMgr = [MCTBrandingMgr brandingMgr];

        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        MCTActivityPlugin *activityPlugin = [[MCTActivityPlugin alloc] init];
        [dict setObject:activityPlugin forKey:NSStringFromClass([activityPlugin class])];

        MCTMessagesPlugin *magicMessagesPlugin = [[MCTMessagesPlugin alloc] init];
        [dict setObject:magicMessagesPlugin forKey:NSStringFromClass([magicMessagesPlugin class])];

        MCTSystemPlugin *systemPlugin = [[MCTSystemPlugin alloc] init];
        [dict setObject:systemPlugin forKey:NSStringFromClass([systemPlugin class])];

        MCTFriendsPlugin *friendsPlugin = [[MCTFriendsPlugin alloc] init];
        [dict setObject:friendsPlugin forKey:NSStringFromClass([friendsPlugin class])];

        MCTLocationPlugin *locationPlugin = [[MCTLocationPlugin alloc] init];
        [dict setObject:locationPlugin forKey:NSStringFromClass([locationPlugin class])];

        self.plugins = [NSDictionary dictionaryWithDictionary:dict];

        if (self.forceMyEmail) {
            MCTIdentity *myIdentity = [[MCTIdentity alloc] init];
            myIdentity.email = self.forceMyEmail;
            myIdentity.name = self.forceMyEmail;
            myIdentity.avatarId = -1;
            [systemPlugin.identityStore updateMyIdentity:myIdentity withShortUrl:nil];
            MCT_RELEASE(self.forceMyEmail);
        }

        [self.brandingMgr initialize];
    }
}

- (MCTPlugin *)pluginForClass:(Class)klazz
{
    T_DONTCARE();
    @synchronized(self.pluginLock) {
        id plugin = [self.plugins objectForKey:NSStringFromClass(klazz)];
        if (plugin != nil) {
            return (MCTPlugin *)plugin;
        }
    }
    ERROR(@"Cannot find plugin for class %@", klazz);
    return nil;
}

- (void)launchPlugins
{
    T_UI();
    LOG(@"Launching plugins");
    [self.workQueue addOperationWithBlock:^{
        [self initializePlugins];
    }];

    [self.commQueue addOperationWithBlock:^{
        self.commManager = [[MCTCommunicationManager alloc] init];

        if (self.commManager.xmppConnection) {
            UIApplication *app = [UIApplication sharedApplication];
            [app setKeepAliveTimeout:MCT_KEEPALIVE_TIMEOUT handler:^{
                XMPPLOG(@"**************************************************************************");
                XMPPLOG(@"Running KeepAliveHandler");
                [self.commManager.xmppConnection keepAlive];
            }];
        }
    }];

    // FIXME: this blocks the UI thread!
    [self.workQueue waitUntilAllOperationsAreFinished];
    [self.commQueue waitUntilAllOperationsAreFinished];


    self.commManager.callReceiver.com_mobicage_capi_messaging_IClientRPC_instance = (MCTMessagesPlugin *) [self pluginForClass:[MCTMessagesPlugin class]];
    self.commManager.callReceiver.com_mobicage_capi_system_IClientRPC_instance = (MCTSystemPlugin *) [self pluginForClass:[MCTSystemPlugin class]];
    self.commManager.callReceiver.com_mobicage_capi_friends_IClientRPC_instance = (MCTFriendsPlugin *) [self pluginForClass:[MCTFriendsPlugin class]];
    self.commManager.callReceiver.com_mobicage_capi_services_IClientRPC_instance = (MCTFriendsPlugin *) [self pluginForClass:[MCTFriendsPlugin class]];
    self.commManager.callReceiver.com_mobicage_capi_location_IClientRPC_instance = (MCTLocationPlugin *) [self pluginForClass:[MCTLocationPlugin class]];

    if (MCT_USE_XMPP_KICK_CHANNEL) {
        if (self.commManager.xmppConnection)
            [self ping];
    } else {
        [self.commManager kick];
    }
}

- (void)processPushInfo:(NSDictionary *)pushInfo
{
    T_UI();
    if (pushInfo != nil) {
        NSString *messageKey = nil;
        NSString *type = nil;

        if ((messageKey = [pushInfo objectForKey:@"r"]) != nil) {
            type = @"r";
            self.msgLaunchOption = messageKey;
        } else if ((messageKey = [pushInfo objectForKey:@"n"]) != nil) {
            type = @"n";
            self.msgLaunchOption = messageKey;
        } else if ((messageKey = [pushInfo objectForKey:@"a"]) != nil) {
            type = @"a";
            self.ackLaunchOption = messageKey;
        }

        if (messageKey && type) {
            MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_PUSH_NOTIFICATION];
            [intent setString:messageKey forKey:@"messageKey"];
            [intent setString:type forKey:@"type"];
            [self.intentFramework broadcastStickyIntent:intent];
        } else if ([pushInfo containsKey:MCT_GOTO]) {
            [self handleOpenURL:[NSURL URLWithString:[pushInfo objectForKey:MCT_GOTO]]];
        }
    }
    [self.commManager kick];
}

- (void)registerDefaultSettings
{
    T_UI();
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults setBool:NO forKey:MCT_SETTINGS_INVISIBLE];
    [defaults setObject:@"" forKey:MCT_SETTINGS_CUSTOM_ALARM];
    [defaults setBool:NO forKey:MCT_SETTINGS_TRANSFER_WIFI_ONLY];

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    T_UI();
    LOG(@"\n------------------------------------------------------------------------------------------------------\n");
    LOG(@"Process %d", [[NSProcessInfo processInfo] processIdentifier]);
    LOG(@"Launch options: %@", launchOptions);
    XMPPHERE();
    HTTPHERE();

    self.fetchCompletionHandlers = [NSMutableArray array];

    if (MCT_USE_TRUSTSTORE) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        [MCTSecurity setTrustedCertificate:[NSData dataWithContentsOfFile:[bundle pathForResource:@"root"
                                                                                           ofType:@"crt"]]];
    }

    self.registerRemoteNotificationsFailed = NO;
    [self registerDefaultSettings];

    self.fakeMainQueue = [MCTFakeOperationQueue queueWithName:@"UI"];

    self.workQueue = [MCTOperationQueue queueWithName:@"BIZZ"];
    [self.workQueue setMaxConcurrentOperationCount:1];

    self.commQueue = [MCTOperationQueue queueWithName:@"BACKLOG"];
    [self.commQueue setMaxConcurrentOperationCount:1];

#if !(TARGET_IPHONE_SIMULATOR)
    NSSetUncaughtExceptionHandler(&mctExceptionHandler);
#endif

    self.downloadQueue = [MCTOperationQueue queueWithName:@"DOWNLOAD"];
    [self.downloadQueue setMaxConcurrentOperationCount:3];

    IF_IOS8_OR_GREATER({
        self.workQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        self.commQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        self.downloadQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    });

    self.intentFramework = [[MCTIntentFramework alloc] init];
    [self.intentFramework registerIntentListener:self
                                forIntentActions:[NSArray arrayWithObjects:kINTENT_MOBILE_UNREGISTERED, kINTENT_BACKLOG_FINISHED, nil]
                                         onQueue:self.fakeMainQueue];

    [self.intentFramework addHighPriorityIntent:kINTENT_FB_LOGIN];
    [self.intentFramework addHighPriorityIntent:kINTENT_FB_POST];
    [self.intentFramework addHighPriorityIntent:kINTENT_FB_TICKER];
    [self.intentFramework addHighPriorityIntent:kINTENT_PUSH_NOTIFICATION_SETTINGS_UPDATED];
    [self.intentFramework addHighPriorityIntent:kINTENT_OAUTH_RESULT];
    [self.intentFramework addHighPriorityIntent:kINTENT_MDP_LOGIN];

    self.dbManager = [[MCTDatabaseManager alloc] initFromSQLScripts];
    self.backlogDbManager = [[MCTBacklogDbManager alloc] initFromSQLScripts];

    self.configProvider = [[MCTConfigProvider alloc] init];
    self.lastCleanupEpoch = 0;

    BOOL isRegistered = [self isRegistered];
    self.pluginLock = [[NSObject alloc] init];
    if (isRegistered) {
        // Start of app that was already registered
        // 1. launch plugins
        // 2. process launch options
        // 3. register for push notifications
        // 4. kick HTTP backlog -- TODO: avoid duplicate kick (here + publish devtoken)

        [self launchPlugins]; // will also create XMPP connection and connectWithDelegate and install keepAliveHandler

        [MCTApplePush registerForPushNotifications];
        [self cleanupCachedDownloads];
    }
    else {
        self.registrationMgr = [[MCTRegistrationMgr alloc] init];
    }

    [self.downloadQueue addOperationWithBlock:^{
        [MCTSystemPlugin processUncaughtExceptionFilesWithIsRegistered:isRegistered];
    }];

    // First set up self.window, then let mainViewController show modal subviewcontrollers
    // Otherwise problems on ios 4
    self.window.rootViewController = [[MCTMainViewController alloc] initWithNibName:nil bundle:nil];
    [self.window makeKeyAndVisible];
    IF_IOS7_OR_GREATER({
        if (MCT_APP_TINT_COLOR) {
            self.window.tintColor = MCT_APP_TINT_COLOR;
        }
    });

    dispatch_async(dispatch_get_main_queue(), ^{
        if (isRegistered)
            [[self mainViewController] showMenuWithMsgLaunchOption:self.msgLaunchOption
                                                andAckLaunchOption:self.ackLaunchOption];
        else
            [[self mainViewController] showRegistrationVCWithYouHaveBeenUnregisteredPopup:NO];
    });

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:[UIApplication sharedApplication]];
    return YES;
}

- (void)onRegistrationSuccess
{
    T_UI();
    HERE();
    [[self mainViewController] showMenuWithMsgLaunchOption:self.msgLaunchOption andAckLaunchOption:self.ackLaunchOption];
    // Fresh registration:
    // 1. launch plugins
    // 2. register for new push notifications
    // 3. retrieve friends list (which will kick HTTP)
    [self.intentFramework unregisterIntentListener:self.registrationMgr];
    MCT_RELEASE(self.registrationMgr)
    [self launchPlugins];
    [MCTApplePush registerForPushNotifications];
    MCTInvocationOperation *op = [[MCTInvocationOperation alloc] initWithTarget:self
                                                                        selector:@selector(postRegistrationOperation)
                                                                          object:nil];
    [self.workQueue addOperation:op];
}

- (void)postRegistrationOperation
{
    T_BIZZ();
    HERE();
    MCTActivityPlugin *activityPlugin = (MCTActivityPlugin *) [self pluginForClass:[MCTActivityPlugin class]];
    [activityPlugin logActivityWithText:NSLocalizedString(@"Successfully registered", nil)
                            andLogLevel:MCTActivityLogInfo];

    MCTFriendsPlugin *friendsPlugin = (MCTFriendsPlugin *) [self pluginForClass:[MCTFriendsPlugin class]];
    [friendsPlugin requestFriendSetWithForce:YES recalculateMessagesShowInList:YES];
    [friendsPlugin requestInvitationSecrets];
    [friendsPlugin requestGroups];

    MCTSystemPlugin *systemPlugin = (MCTSystemPlugin *) [self pluginForClass:[MCTSystemPlugin class]];
    [systemPlugin requestIdentity];
    [systemPlugin requestIdentityQRCode];
    [systemPlugin getJSEmbedding];

    MCTLocationPlugin *locationPlugin = (MCTLocationPlugin *) [self pluginForClass:[MCTLocationPlugin class]];
    [locationPlugin requestBeaconRegions];
}

#pragma mark - Background Fetch

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    T_DONTCARE();
    HERE();
    if (completionHandler) {
        [self.fetchCompletionHandlers addObject:[completionHandler copy]];
        LOG(@"New fetchCompletionHandler added: %@", self.fetchCompletionHandlers);
    }

    MCTSystemPlugin *systemPlugin = (MCTSystemPlugin *) [self pluginForClass:[MCTSystemPlugin class]];
    [systemPlugin calculateNextBackgroundFetchInterval];

    if (self.commManager.xmppConnection) {
        self.commManager.xmppConnection.kickOnNextAnalyse = YES;
        [self.commManager.xmppConnection keepAlive];
    } else {
        [self.commManager kick];
    }
}


# pragma mark - NSURLSession

- (void)                application:(UIApplication *)application
handleEventsForBackgroundURLSession:(NSString *)identifier
                  completionHandler:(void (^)())completionHandler
{
    T_UI();
    HERE();
    if ([identifier isEqualToString:[MCTCommunicationManager URLSessionIdentifier]]) {
        LOG(@"Rejoining NSURLSession '%@'", identifier);
        NSURLSession *session = [self.commManager initializeURLSession];
        assert([identifier isEqualToString:session.configuration.identifier]);
    }

    else if ([identifier isEqualToString:[MCTCommunicationManager logForwardingURLSessionIdentifier]]) {
        LOG(@"Rejoining NSURLSession '%@'", identifier);
        NSURLSession *session = [self.commManager initializeLogForwardingURLSession];
        assert([identifier isEqualToString:session.configuration.identifier]);
    }

    else if ([identifier isEqualToString:[MCTBrandingMgr URLSessionIdentifier]]) {
        LOG(@"Rejoining NSURLSession '%@'", identifier);
        NSURLSession *session = [self.brandingMgr initializeURLSession];
        assert([identifier isEqualToString:session.configuration.identifier]);
    }

    else {
        ERROR(@"Unknown URLSession '%@'", identifier);
        completionHandler();
        return;
    }

    if ([self.sessionCompletionHandlers objectForKey:identifier]) {
        ERROR(@"Got multiple handlers for NSURLSession '%@'. This should not happen.", identifier);
    }
    [self.sessionCompletionHandlers setObject:completionHandler forKey:identifier];
}

- (void)callCompletionHandlerForSession:(NSString *)identifier
{
    T_DONTCARE();
    dispatch_block_t handler = [self.sessionCompletionHandlers objectForKey:identifier];
    if (handler) {
        [self.sessionCompletionHandlers removeObjectForKey:identifier];
        if ([NSThread isMainThread]) {
            LOG(@"Calling completion handler for session '%@'", identifier);
            handler();
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                LOG(@"Calling completion handler for session '%@'", identifier);
                handler();
            }];
        }
    }
}

#pragma mark - Apple Push notifications

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
// Only called on iOS 8
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    T_UI();
    IF_IOS8_OR_GREATER({
        [application registerForRemoteNotifications];
    });
}
#endif

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    T_UI();
    LOG(@"Successfully registered with Apple Push service");
    self.registerRemoteNotificationsFailed = NO;
    [MCTApplePush sendToken:deviceToken];

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_PUSH_NOTIFICATION_SETTINGS_UPDATED];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    T_UI();
    LOG(@"Error registering for device token. Error: %@", err);
    // App is started but registration for apple push failed (e.g. in simulator, in jailbroken iphone 1, ...)
    self.registerRemoteNotificationsFailed = YES;

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_PUSH_NOTIFICATION_SETTINGS_UPDATED];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    HERE();
    [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {
    }];
}

- (void)         application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
      fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    T_UI();
    HERE();
    LOG(@"Received Apple push notification: %@", userInfo);

    switch ([[UIApplication sharedApplication] applicationState]) {
        case UIApplicationStateActive:
            LOG(@"UIApplicationStateActive");
            break;
        case UIApplicationStateBackground:
            LOG(@"UIApplicationStateBackground");
            break;
        case UIApplicationStateInactive:
            LOG(@"UIApplicationStateInactive");
            break;
        default:
            break;
    }

    if (completionHandler) {
        [self.fetchCompletionHandlers addObject:[completionHandler copy]];
        LOG(@"New fetchCompletionHandler added: %@", self.fetchCompletionHandlers);
    }

    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
        [self processPushInfo:userInfo];
    } else {
        [self.commManager kick];
    }
}

- (BOOL)failedToRegisterForRemoteNotifications
{
    T_DONTCARE();
    return self.registerRemoteNotificationsFailed;
}

#pragma mark -
#pragma mark Local Notifications

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    T_UI();
    HERE();

    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive || [notification.userInfo objectForKey:@"f"]) {
        [self processPushInfo:notification.userInfo];
    }
}


#pragma mark -
#pragma mark application lifecycle

- (void)ping
{
    T_UI();
    HERE();
    [self.commManager.xmppConnection keepAlive];
    [self performSelector:@selector(ping) withObject:nil afterDelay:30];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */

    /* MC Note: this can also happen when user double clicks iphone menu button. Yet he can still
       push interact with app UI. Hence should probably never use this hook point */

    T_UI();
    XMPPHERE();
    HTTPHERE();

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ping) object:nil];

    [[self menuViewController] setMessageBadgeValue];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */

    T_UI();
    XMPPHERE();
    HTTPHERE();

    [[NSNotificationCenter defaultCenter] postNotificationName:MCT_NOTIFICATION_BACKGROUND object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of transition from the background to the inactive state:
     here you can undo many of the changes made on entering the background.
     */
    T_UI();
    XMPPHERE();
    HTTPHERE();

    [[self menuViewController] setMessageBadgeValue];

    // When we enter foreground, the app is active
    // We force analyze XMPP, which, in case of an XMPP reconnect, will kick HTTP
    if (MCT_USE_XMPP_KICK_CHANNEL) {
        if (self.commManager.xmppConnection) {
            [self ping];
        }
    } else {
        [self.commManager kick];
    }
    [self cleanupCachedDownloads];
}

- (void)cleanupCachedDownloads
{
    T_UI();
    MCTlong epoch = [MCTUtils currentTimeSeconds];
    MCTlong lastWeekEpoch = epoch - 7 * 86400;
    NSString *lastCleanupEpochString = nil;
    if (self.lastCleanupEpoch == 0) {
        lastCleanupEpochString = [self.configProvider stringForKey:MCT_CONFIGKEY_CACHED_DOWNLOADS_CLEANUP];
    } else {
        lastCleanupEpochString = [NSString stringWithFormat:@"%lld", self.lastCleanupEpoch];
    }
    if (lastCleanupEpochString != nil && self.lastCleanupEpoch == 0) {
        self.lastCleanupEpoch = [lastCleanupEpochString longLongValue];
    }
    if(lastCleanupEpochString == nil || self.lastCleanupEpoch <= lastWeekEpoch) {
        self.lastCleanupEpoch = epoch;
        [self.workQueue addOperationWithBlock:^{
            [[MCTCachedDownloader sharedInstance] cleanupOldCachedFiles];
        }];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     If the application was previously in the background, optionally refresh the user interface.
     */
    T_UI();
    XMPPHERE();
    HTTPHERE();
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    if (MCT_FACEBOOK_APP_ID)
        [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    T_UI();
    XMPPHERE();
    HTTPHERE();

    if (MCT_FACEBOOK_APP_ID) {
        [FBSession.activeSession close];
    }

    [self.intentFramework unregisterIntentListener:self];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUserDefaultsDidChangeNotification
                                                  object:[UIApplication sharedApplication]];

    [self.downloadQueue cancelAllOperations];
    [self.workQueue cancelAllOperations];
    [self.commQueue cancelAllOperations];
    [[MCTLogForwarder logForwarder] stop];
    // TODO: cleanup and destructors

    // terminate communication and stop all plugins
    [self.workQueue addOperationWithBlock:^{
        [self stopPlugins];
    }];
    [self.workQueue waitUntilAllOperationsAreFinished];
}

- (void)terminateCommunication
{
    T_BACKLOG();
    XMPPHERE();
    HTTPHERE();
    [self.commManager terminate];
    [self.brandingMgr terminate];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    T_UI();

    NSString *urlStr = [url absoluteString];
    LOG(@"App opened with url: %@", urlStr);

    // @"oauth-rogerthat://x-callback-url?code=QIRL7z3peeOSwigH8pfjIEj1ooZD&state=36b09b28-3f60-461f-97a7-3da3633a0005"

    if ([[urlStr lowercaseString] hasPrefix:MCT_PREFIX_ROGERTHAT_URL]) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_APPLICATION_OPEN_URL];
        [intent setString:urlStr forKey:@"url"];
        [self.intentFramework broadcastStickyIntent:intent];
        return YES;
    }

    if ([[MDPMobile sharedSession] canHandleURL:url]) {
        NSDictionary *queryDictionary = [NSDictionary gtm_dictionaryWithHttpArgumentsString:[url query]];
        LOG(@"MDP login result: %@", queryDictionary);

        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_MDP_LOGIN];
        [queryDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            [intent setString:obj forKey:key];
        }];
        [self.intentFramework broadcastIntent:intent];
        return YES;
    }

    NSURL *redirectURL = [NSURL URLWithString:[NSString stringWithFormat:@"oauth-%@://x-callback-url", MCT_PRODUCT_ID]];
    if (([[url host] isEqualToString:[redirectURL host]] && [[url path] isEqualToString:[redirectURL path]])) {
        NSDictionary *queryDictionary = [NSDictionary gtm_dictionaryWithHttpArgumentsString:[url query]];
        LOG(@"Oauth authorize result: %@", queryDictionary);

        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_OAUTH_RESULT];
        if ([queryDictionary objectForKey:@"code"]) {
            [intent setBool:YES forKey:@"success"];
            [intent setString:[queryDictionary objectForKey:@"code"] forKey:@"result"];
        } else {
            [intent setBool:NO forKey:@"success"];
            [intent setString:[queryDictionary objectForKey:@"error_description"] forKey:@"result"];
        }

        [self.intentFramework broadcastIntent:intent];
        return YES;

    }

    return NO;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    T_UI();
    return [self handleOpenURL:url] || [FBAppCall handleOpenURL:url
                                              sourceApplication:sourceApplication];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
    Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
    */
    T_UI();
    XMPPHERE();
    HTTPHERE();
}

#pragma mark -
#pragma mark intents

- (void)stopPlugins
{
    T_BIZZ();
    [self.commQueue addOperationWithBlock:^{
        [self terminateCommunication];
        MCT_RELEASE(self.commManager);
        MCT_RELEASE(self.brandingMgr);
    }];

    for (MCTPlugin *plugin in [self.plugins allValues]) {
        LOG(@"Stopping %@", plugin);
        [plugin stop];
    }
    MCT_RELEASE(self.plugins);

    [self.commQueue waitUntilAllOperationsAreFinished];
}

- (void)unregister
{
    T_UI();
    LOG(@"Unregistering mobile");
    
    LOG(@"- Terminating communicationMgr and plugins");
    MCTInvocationOperation *op = [[MCTInvocationOperation alloc] initWithTarget:self
                                                                        selector:@selector(stopPlugins)
                                                                          object:nil];
    [self.workQueue addOperation:op];
    [self.workQueue waitUntilAllOperationsAreFinished];

    // intentFrameWork -- unregister all listeners
    LOG(@"- Unregistering intent listeners");
    [self.intentFramework reset];
    LOG(@"%@", self.intentFramework);

    LOG(@"- Wiping databases");
    MCT_RELEASE(self.configProvider);
    BOOL wipedCleanly1 = [self.dbManager wipe];
    MCT_RELEASE(self.dbManager);
    BOOL wipedCleanly2 = [self.backlogDbManager wipe];
    MCT_RELEASE(self.backlogDbManager);
    if (!wipedCleanly1 || !wipedCleanly2) {
        // stop the app
        [(MCTAppDelegate *)MCTNull unregister];
    }

    self.dbManager = [[MCTDatabaseManager alloc] initFromSQLScripts];
    self.backlogDbManager = [[MCTBacklogDbManager alloc] initFromSQLScripts];
    self.configProvider = [[MCTConfigProvider alloc] init];

    [self.intentFramework registerIntentListener:self
                                 forIntentAction:kINTENT_MOBILE_UNREGISTERED
                                         onQueue:self.fakeMainQueue];

    [[self mainViewController] showRegistrationVCWithYouHaveBeenUnregisteredPopup:YES];
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_MOBILE_UNREGISTERED) {
        [self unregister];
    } else if (intent.action == kINTENT_BACKLOG_FINISHED) {
        if ([self.fetchCompletionHandlers count]) {
            MCTlong status = [intent longForKey:@"status"];
            if (status != MCTCommunicationResultConnecting) {
                UIBackgroundFetchResult result;
                NSString *resultString;
                if (status != MCTCommunicationResultSuccess) {
                    result = UIBackgroundFetchResultFailed;
                    resultString = @"UIBackgroundFetchResultFailed";
                } else {
                    result = UIBackgroundFetchResultNewData;
                    resultString = @"UIBackgroundFetchResultNewData";
                }

                NSEnumerator *enumerator = [self.fetchCompletionHandlers objectEnumerator];
                for (void (^fetchCompletionHandler)(UIBackgroundFetchResult) in [enumerator allObjects]) {
                    HTTPLOG(@"Background fetch completed. Calling fetchCompletionHandler<0x%x>(%@)",
                            fetchCompletionHandler, resultString);
                    fetchCompletionHandler(result);
                    [self.fetchCompletionHandlers removeObject:fetchCompletionHandler];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark Facebook

- (void)broadcastFBIntentWithAction:(NSString *)action
                            session:(FBSession *)session
                              state:(FBSessionState)state
                              error:(NSError *)error
{
    T_UI();
    // Broadcast intent on error or on success

    MCTIntent *intent = [MCTIntent intentWithAction:action];
    [intent setBool:NO forKey:@"canceled"];
    [intent setBool:(BOOL)error forKey:@"error"];
    if (error) {
        [intent setBool:([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) forKey:@"canceled"];
        [intent setLong:[FBErrorUtility errorCategoryForError:error] forKey:@"fberrorCategory"];
        [intent setBool:[FBErrorUtility shouldNotifyUserForError:error]forKey:@"fberrorShouldNotifyUser"];
        [intent setString:[FBErrorUtility userMessageForError:error] forKey:@"fberrorUserMessage"];
        [self.intentFramework broadcastIntent:intent];
    } else if (session.isOpen) {
        [self.intentFramework broadcastIntent:intent];
    } else if (state == FBSessionStateClosedLoginFailed) {
        [intent setBool:YES forKey:@"error"];
        [self.intentFramework broadcastIntent:intent];
    } else {
        LOG(@"Session state is %d", state);
    }

    if (!error && [self menuViewController]) {
        // We are registered & there is an open FB session
        MCTSystemPlugin *systemPlugin = [MCTComponentFramework systemPlugin];
        BOOL shouldUpdateProfile = NO;
        if ([systemPlugin.identityStore.myIdentity.name containsString:@" at "])
            shouldUpdateProfile = YES;

        if (MCT_PROFILE_SHOW_GENDER_AND_BIRTHDATE) {
            if (!systemPlugin.identityStore.myIdentity.hasBirthdate || !systemPlugin.identityStore.myIdentity.hasGender)
                shouldUpdateProfile = YES;
        }

        if (shouldUpdateProfile) {
            HERE();
            [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    ERROR(@"Failed to get my avatar and name: %@", error);
                } else if (result) {
                    FBGraphObject *graphObject = result;

                    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",
                                     [graphObject stringForKey:@"id"]];
                    MCTHTTPRequest *httpRequest = [MCTHTTPRequest requestWithURL:[NSURL URLWithString:url]];
                    __weak typeof(httpRequest) weakHttpRequest = httpRequest;
                    httpRequest.shouldRedirect = YES;
                    [httpRequest setFailedBlock:^{
                        T_UI();
                        ERROR(@"Failed to fb profile picture: %@", url);
                    }];
                    [httpRequest setCompletionBlock:^{
                        T_UI();
                        if (httpRequest.responseStatusCode == 200) {
                            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                                BOOL hasGender = NO;
                                MCTlong gender = 0;
                                if (!systemPlugin.identityStore.myIdentity.hasGender) {
                                    NSString *genderString = [graphObject stringForKey:@"gender"];
                                    if (genderString != nil){
                                        hasGender = YES;
                                        if ([@"female" isEqualToString:genderString])
                                            gender = MCTIdentityGenderFemale;
                                        else
                                            gender = MCTIdentityGenderMale;
                                    }
                                }

                                BOOL hasBirthdate = NO;
                                MCTlong birthdate = 0;
                                if (!systemPlugin.identityStore.myIdentity.hasBirthdate) {
                                    NSString *birthdateString = [graphObject stringForKey:@"birthday"];
                                    if (birthdateString != nil){
                                        hasBirthdate = YES;
                                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                        dateFormatter.dateFormat = @"MM/dd/yyyy";
                                        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                                        NSDate *date = [dateFormatter dateFromString:birthdateString];

                                        birthdate = [date timeIntervalSince1970];
                                    }
                                }

                                [systemPlugin editProfileWithNewName:[graphObject stringForKey:@"name"]
                                                       newAvatarData:weakHttpRequest.responseData
                                                        accesssToken:FBSession.activeSession.accessTokenData.accessToken
                                                        newBirthdate:birthdate
                                                           newGender:gender
                                                        hasBirthdate:hasBirthdate
                                                           hasGender:hasGender];
                            }];
                        } else {
                            ERROR(@"Failed to get fb profile picture %@\nCode: %d", url, weakHttpRequest.responseStatusCode);
                        }
                    }];
                    [[MCTComponentFramework workQueue] addOperation:httpRequest];
                }
            }];
        }
    }
}

- (void)ensureOpenActiveFBSessionWithPublishPermissions:(NSArray *)publishPermissions
                                     resultIntentAction:(NSString *)intentAction
                                     allowFastAppSwitch:(BOOL)allowFastAppSwitch
                                     fromViewController:(UIViewController *)fromViewController
{
    T_UI();
    FBSession *activeSession = [FBSession activeSession];

    if (activeSession.isOpen) {
        LOG(@"Facebook session is already open with all required publish permissions");
        if ([activeSession.permissions containsAll:publishPermissions]) {
            [self broadcastFBIntentWithAction:intentAction
                                      session:activeSession
                                        state:activeSession.state
                                        error:nil];
        } else {
            LOG(@"Requesting additional publish permissions: %@", publishPermissions);
            [activeSession requestNewPublishPermissions:publishPermissions
                                        defaultAudience:FBSessionDefaultAudienceEveryone
                                      completionHandler:^(FBSession *session, NSError *error) {
                                          [self broadcastFBIntentWithAction:intentAction
                                                                    session:session
                                                                      state:session.state
                                                                      error:error];
                                      }];
        }
    } else {
        // No safari auth, so let's see if fb app is installed, or fb native account is set
        dispatch_block_t openDefaultActiveSession = ^{
            LOG(@"Opening new Facebook session with publish permissions: %@", publishPermissions);
            [FBSession openActiveSessionWithPublishPermissions:publishPermissions
                                               defaultAudience:FBSessionDefaultAudienceEveryone
                                                  allowLoginUI:YES
                                            fromViewController:fromViewController
                                             completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                                 [self broadcastFBIntentWithAction:intentAction
                                                                           session:session
                                                                             state:state
                                                                             error:error];
                                             }];
        };

        if (allowFastAppSwitch) {
            openDefaultActiveSession();
        } else {
            [self openFBSessionWithoutFastAppSwitchWithPermissions:publishPermissions
                                                      intentAction:intentAction
                                                      defaultBlock:openDefaultActiveSession
                                                fromViewController:fromViewController];
        }
    }
}

- (void)ensureOpenActiveFBSessionWithReadPermissions:(NSArray *)readPermissions
                                  resultIntentAction:(NSString *)intentAction
                                  allowFastAppSwitch:(BOOL)allowFastAppSwitch
                                  fromViewController:(UIViewController *)fromViewController
{
    T_UI();
    FBSession *activeSession = [FBSession activeSession];

    if (activeSession.isOpen) {
        if ([activeSession.permissions containsAll:readPermissions]) {
            LOG(@"Facebook session is already open with all required read permissions");
            [self broadcastFBIntentWithAction:intentAction
                                      session:activeSession
                                        state:activeSession.state
                                        error:nil];
        } else {
            LOG(@"Requesting additional Facebook read permissions: %@", readPermissions);
            [activeSession requestNewReadPermissions:readPermissions
                                   completionHandler:^(FBSession *session, NSError *error) {
                                       [self broadcastFBIntentWithAction:intentAction
                                                                 session:session
                                                                   state:session.state
                                                                   error:error];
                                   }];
        }
    } else {
        dispatch_block_t openDefaultActiveSession = ^{
            LOG(@"Opening new Facebook session with read permissions: %@", readPermissions);
            [FBSession openActiveSessionWithReadPermissions:readPermissions
                                               allowLoginUI:YES
                                         fromViewController:fromViewController
                                          completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                              LOG(@"Current FBSession permissions %@", session.permissions);
                                              [self broadcastFBIntentWithAction:intentAction
                                                                        session:session
                                                                          state:state
                                                                          error:error];
                                          }];
        };

        if (allowFastAppSwitch) {
            openDefaultActiveSession();
        } else {
            [self openFBSessionWithoutFastAppSwitchWithPermissions:readPermissions
                                                      intentAction:intentAction
                                                      defaultBlock:openDefaultActiveSession
                                                fromViewController:fromViewController];
        }
    }
}

- (void)openFBSessionWithoutFastAppSwitchWithPermissions:(NSArray *)permissions
                                            intentAction:(NSString *)intentAction
                                            defaultBlock:(dispatch_block_t)openDefaultActiveSessionBlock
                                      fromViewController:(UIViewController *)fromViewController
{
    [self isFBAccountSetInSettingsWithCompletion:^(BOOL accountIsSet) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (accountIsSet) {
                openDefaultActiveSessionBlock();
            } else {
                FBSession *newActiveSession = [[FBSession alloc] initWithPermissions:permissions];
                [newActiveSession openWithBehavior:FBSessionLoginBehaviorForcingWebView
                                fromViewController:fromViewController
                                 completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                     [self broadcastFBIntentWithAction:intentAction
                                                               session:session
                                                                 state:state
                                                                 error:error];
                                 }];
                FBSession.activeSession = newActiveSession;
            }
        });
    }];
}

- (void)isFBAccountSetInSettingsWithCompletion:(void(^)(BOOL accountIsSet))completionHandler
{
    IF_PRE_IOS6({
        completionHandler(NO);
        return;
    });

    IF_IOS6_OR_GREATER({
        ACAccountStore *as = [[ACAccountStore alloc] init];
        ACAccountType *at = [as accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        [as requestAccessToAccountsWithType:at
                                    options:@{ ACFacebookAppIdKey : MCT_FACEBOOK_APP_ID }
                                 completion:^(BOOL granted, NSError *error) {
                                     // error with code 6 ==> no native FB account
                                     if (error && error.code != ACErrorAccountNotFound) {
                                         LOG(@"%@", error);
                                     }
                                     LOG(@"Access to FB account granted? %@", BOOLSTR(granted));
                                     completionHandler(granted && !error && [[as accountsWithAccountType:at] count] > 0);
                                 }];
    });
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc
{
    T_UI();
    HERE();
    [self.intentFramework unregisterIntentListener:self];
}

@end