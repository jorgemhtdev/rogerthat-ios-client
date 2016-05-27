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

#import "MCTBacklogDbManager.h"
#import "MCTCommunicationManager.h"
#import "MCTConfigProvider.h"
#import "MCTDatabaseManager.h"
#import "MCTIntentFramework.h"
#import "MCTBrandingMgr.h"
#import "MCTMainViewController.h"
#import "MCTMenuVC.h"
#import "MCTOperation.h"
#import "MCTPlugin.h"
#import "MCTRegistrationMgr.h"
#import "SWRevealViewController.h"

#import <FacebookSDK/FacebookSDK.h>

@class SWRevealViewController;

@interface MCTAppDelegate : NSObject <UIApplicationDelegate, IMCTIntentReceiver, SWRevealViewControllerDelegate>

@property MCTlong lastCleanupEpoch;
@property BOOL registerRemoteNotificationsFailed;
@property(nonatomic, strong) IBOutlet UIWindow *window;
@property(nonatomic, strong) MCTBacklogDbManager *backlogDbManager;
@property(nonatomic, strong) MCTDatabaseManager *dbManager;
@property(nonatomic, strong) MCTConfigProvider *configProvider;
@property(nonatomic, strong) MCTCommunicationManager *commManager;
@property(nonatomic, strong) MCTFakeOperationQueue *fakeMainQueue;
@property(nonatomic, strong) MCTOperationQueue *workQueue;
@property(nonatomic, strong) MCTOperationQueue *commQueue;
@property(nonatomic, strong) MCTOperationQueue *downloadQueue;
@property(nonatomic, strong) MCTIntentFramework *intentFramework;
@property(nonatomic, strong) MCTBrandingMgr *brandingMgr;
@property(nonatomic, strong) MCTRegistrationMgr *registrationMgr;
@property(nonatomic, strong) SWRevealViewController *viewController;
@property(nonatomic, strong) NSDictionary *plugins;
@property(nonatomic, strong) NSObject *pluginLock;
@property(nonatomic, copy) NSString *forceMyEmail;
@property(nonatomic, copy) NSString *msgLaunchOption;
@property(nonatomic, copy) NSString *ackLaunchOption;

- (MCTMenuVC *)menuViewController;

- (BOOL)isRegistered;
- (BOOL)failedToRegisterForRemoteNotifications;

- (void)settingsChange:(NSNotification *)notification;

- (MCTPlugin *)pluginForClass:(Class)class;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)onRegistrationSuccess;

- (void)callCompletionHandlerForSession:(NSString *)identifier;

- (void)ensureOpenActiveFBSessionWithPublishPermissions:(NSArray *)publishPermissions
                                     resultIntentAction:(NSString *)intentAction
                                     allowFastAppSwitch:(BOOL)allowFastAppSwitch
                                     fromViewController:fromViewController;
- (void)ensureOpenActiveFBSessionWithReadPermissions:(NSArray *)readPermissions
                                  resultIntentAction:(NSString *)intentAction
                                  allowFastAppSwitch:(BOOL)allowFastAppSwitch
                                  fromViewController:fromViewController;

@end