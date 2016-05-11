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

#import "MCTDefaultFriendListVC.h"
#import "MCTTransferObjects.h"
#import "MCTSendMessageRequest.h"


@interface MCTNewMessageRecipientsVC : MCTUIViewController <IMCTIntentReceiver, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property BOOL isReply;
@property (nonatomic, strong) MCTSendMessageRequest *request;
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIView *separatorView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *toBccSwitch;
@property (nonatomic, strong) IBOutlet UIScrollView *recipientsView;
@property (nonatomic, strong) NSMutableArray *selectedRecipients;
@property (nonatomic, weak) UIViewController *sendMessageViewController;
@property (nonatomic, strong) IBOutlet UILabel *toLabel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) MCTFriendsPlugin *friendsPlugin;

+ (MCTNewMessageRecipientsVC *)viewControllerWithRequest:(MCTSendMessageRequest *)request;
- (void)loadRecipients;
- (void)saveRecipients;
- (void)loadGroups;
- (void)registerIntents;

@end