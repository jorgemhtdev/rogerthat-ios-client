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

#import "MCTActivityPlugin.h"
#import "MCTAppDelegate.h"
#import "MCTBacklog.h"
#import "MCTBacklogDbManager.h"
#import "MCTBrandingMgr.h"
#import "MCTCallReceiver.h"
#import "MCTCommunicationManager.h"
#import "MCTConfigProvider.h"
#import "MCTDatabaseManager.h"
#import "MCTFriendsPlugin.h"
#import "MCTIntentFramework.h"
#import "MCTLocationPlugin.h"
#import "MCTMessagesPlugin.h"
#import "MCTPlugin.h"
#import "MCTRPCProtocol.h"
#import "MCTSystemPlugin.h"

#import "sqlite3.h"


@interface MCTComponentFramework : NSObject

+ (MCTAppDelegate *)appDelegate;
+ (MCTMenuVC *)menuViewController;

+ (MCTOperationQueue *)mainQueue;
+ (MCTOperationQueue *)workQueue;
+ (MCTOperationQueue *)commQueue;
+ (MCTOperationQueue *)downloadQueue;

+ (sqlite3 *)writeableDB;
+ (MCTDatabaseManager *)dbManager;
+ (sqlite3 *)backlogDB;
+ (MCTBacklogDbManager *)backlogDbManager;
+ (MCTConfigProvider *)configProvider;

+ (MCTCommunicationManager *)commManager;
+ (MCTRPCProtocol *)protocol;
+ (MCTCallReceiver *)callReceiver;
+ (MCTBacklog *)backlog;

+ (MCTIntentFramework *)intentFramework;
+ (MCTBrandingMgr *)brandingMgr;
+ (MCTRegistrationMgr *)registrationMgr;

+ (MCTPlugin *)pluginForClass:(Class)klazz;
+ (MCTActivityPlugin *)activityPlugin;
+ (MCTFriendsPlugin *)friendsPlugin;
+ (MCTLocationPlugin *)locationPlugin;
+ (MCTMessagesPlugin *)messagesPlugin;
+ (MCTSystemPlugin *)systemPlugin;

@end