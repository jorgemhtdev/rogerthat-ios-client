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

@implementation MCTComponentFramework

+ (MCTAppDelegate *)appDelegate
{
    T_DONTCARE();
    return (MCTAppDelegate *) [[UIApplication sharedApplication] delegate];
}

+ (MCTMenuVC *)menuViewController
{
    T_UI();
    return [[MCTComponentFramework appDelegate] menuViewController];
}

+ (MCTOperationQueue *)mainQueue
{
    T_DONTCARE();
    return [[MCTComponentFramework appDelegate] fakeMainQueue];
}

+ (MCTOperationQueue *)workQueue
{
    T_DONTCARE();
    return [[MCTComponentFramework appDelegate] workQueue];
}

+ (MCTOperationQueue *)commQueue
{
    T_DONTCARE();
    return [[MCTComponentFramework appDelegate] commQueue];
}

+ (MCTOperationQueue *)downloadQueue
{
    T_DONTCARE();
    return [[MCTComponentFramework appDelegate] downloadQueue];
}

+ (MCTDatabaseManager *)dbManager
{
    T_DONTCARE();
    return [[MCTComponentFramework appDelegate] dbManager];
}

+ (sqlite3 *)writeableDB
{
    T_DONTCARE();
    return [[MCTComponentFramework dbManager] writeableDB];
}

+ (MCTBacklogDbManager *)backlogDbManager
{
    T_DONTCARE();
    return [[MCTComponentFramework appDelegate] backlogDbManager];
}

+ (sqlite3 *)backlogDB
{
    T_DONTCARE();
    return [[MCTComponentFramework backlogDbManager] writeableDB];
}

+ (MCTCommunicationManager *)commManager
{
    T_DONTCARE();
    return [[MCTComponentFramework appDelegate] commManager];
}

+ (MCTRPCProtocol *)protocol
{
    T_BACKLOG();
    return [[MCTComponentFramework commManager] protocol];
}

+ (MCTCallReceiver *)callReceiver
{
    T_DONTCARE();
    return [[MCTComponentFramework commManager] callReceiver];
}

+ (MCTBacklog *)backlog
{
    T_BACKLOG();
    return [[MCTComponentFramework commManager] backlog];
}

+ (MCTConfigProvider *)configProvider
{
    T_DONTCARE();
    return [[MCTComponentFramework appDelegate] configProvider];
}

+ (MCTIntentFramework *)intentFramework
{
    T_DONTCARE();
    return [[MCTComponentFramework appDelegate] intentFramework];
}

+ (MCTBrandingMgr *)brandingMgr
{
    T_DONTCARE();
    return [[MCTComponentFramework appDelegate] brandingMgr];
}

+ (MCTRegistrationMgr *)registrationMgr
{
    T_DONTCARE();
    return [[MCTComponentFramework appDelegate] registrationMgr];
}

+ (MCTPlugin *)pluginForClass:(Class)klazz
{
    T_DONTCARE();
    return [[MCTComponentFramework appDelegate] pluginForClass:klazz];
}

+ (MCTActivityPlugin *)activityPlugin
{
    T_DONTCARE();
    return (MCTActivityPlugin *) [MCTComponentFramework pluginForClass:[MCTActivityPlugin class]];
}

+ (MCTFriendsPlugin *)friendsPlugin
{
    T_DONTCARE();
    return (MCTFriendsPlugin *) [MCTComponentFramework pluginForClass:[MCTFriendsPlugin class]];
}

+ (MCTLocationPlugin *)locationPlugin
{
    T_DONTCARE();
    return (MCTLocationPlugin *) [MCTComponentFramework pluginForClass:[MCTLocationPlugin class]];
}

+ (MCTMessagesPlugin *)messagesPlugin
{
    T_DONTCARE();
    return (MCTMessagesPlugin *) [MCTComponentFramework pluginForClass:[MCTMessagesPlugin class]];
}

+ (MCTSystemPlugin *)systemPlugin
{
    T_DONTCARE();
    return (MCTSystemPlugin *) [MCTComponentFramework pluginForClass:[MCTSystemPlugin class]];
}

@end