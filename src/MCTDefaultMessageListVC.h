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

#import "MCTUITableViewController.h"
#import "MCTFriendsPlugin.h"
#import "MCTIntentFramework.h"
#import "MCTMessageFilter.h"
#import "MCTMessagesPlugin.h"
#import "MCTMessageThread.h"


@interface MCTDefaultMessageListVC : MCTUITableViewController <IMCTIntentReceiver>

@property (nonatomic, strong) UIBarButtonItem *deleteButtonItem;
@property (nonatomic, strong) MCTMessageFilter *filter;
@property (nonatomic, strong) MCTMessagesPlugin *plugin;
@property (nonatomic, strong) MCTFriendsPlugin *friendsPlugin;
@property (nonatomic, strong) NSMutableArray *threads;
@property (nonatomic, strong) NSMutableSet *stashedIntents;

+ (MCTDefaultMessageListVC *)viewController;

- (void)reloadThreads;

- (void)registerIntents;
- (void)unregisterIntents;

- (void)swipeBackwards:(BOOL)backwards fromThread:(NSString *)threadKey;

@end