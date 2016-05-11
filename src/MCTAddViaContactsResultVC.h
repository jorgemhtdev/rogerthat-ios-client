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
#import "MCTUIViewController.h"
#import "MCTIdentity.h"
#import "MCTIntentFramework.h"

#import <MessageUI/MFMessageComposeViewController.h>


@interface MCTAddViaContactsResultVC : MCTUITableViewController <MFMessageComposeViewControllerDelegate, IMCTIntentReceiver>

@property (nonatomic, weak) MCTUIViewController *parentVC;
@property (nonatomic, strong) NSArray *matchedContacts;
@property (nonatomic, strong) NSArray *emailContacts;
@property (nonatomic, strong) NSArray *phoneContacts;
@property (nonatomic, strong) NSMutableArray *pendingInvites;
@property (nonatomic, strong) NSMutableArray *currentInvites;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic) BOOL contactsLoaded;
@property (nonatomic, copy) NSString *invitationSecret;
@property (nonatomic, copy) NSString *invitee;
@property (nonatomic, strong) MCTIdentity *myIdentity;

+ (MCTAddViaContactsResultVC *)viewControllerWithParent:(UIViewController *)parentVC;
- (void)refresh;

@end