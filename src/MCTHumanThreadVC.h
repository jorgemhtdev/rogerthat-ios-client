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

#import "MCTUIViewController.h"
#import "MCTIntentFramework.h"
#import "MCTMessageThread.h"

#import "TTTableView.h"

#import <QuickLook/QuickLook.h>


@interface MCTHumanThreadVC : MCTUIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate,
IMCTIntentReceiver, MBProgressHUDDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate,
NSURLSessionDelegate, NSURLSessionTaskDelegate> 

@property (nonatomic, strong) IBOutlet TTTableView *tableView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) MCTMessagesPlugin *messagesPlugin;
@property (nonatomic, strong) MCTMessageThread *thread;
@property (nonatomic, strong) MCTMessage *parentMessage;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *renderedMessages;
@property (nonatomic, strong) NSArray *threadMembers;
@property (nonatomic) BOOL threadNeedsMyAnswer;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, copy) NSString *myEmail;
@property (nonatomic) BOOL isDynamicChat;
@property (nonatomic, strong) NSDictionary *chatData;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic) BOOL threadDeletePopupShown;

+ (MCTHumanThreadVC *)viewControllerWithThread:(MCTMessageThread *)thread andSelectedIndex:(NSInteger)index;

- (IBAction)onSwipe:(UISwipeGestureRecognizer *)gestureRecognizer;
- (IBAction)onDoubleTap:(UITapGestureRecognizer *)gestureRecognizer;

@end