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

#import "MCTTabMessagesVC.h"
#import "MCTComponentFramework.h"
#import "MCTIntent.h"
#import "MCTLoadMessageVC.h"
#import "MCTMessageCell.h"
#import "MCTMessageEnums.h"
#import "MCTMessageHelper.h"
#import "MCTOperation.h"
#import "MCTScanResult.h"
#import "MCTSendMessageRequest.h"
#import "MCTTransferObjects.h"
#import "MCTUIUtils.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"


#define MCT_MSG_SEGMENT_INDEX_UNREAD    0
#define MCT_MSG_SEGMENT_INDEX_UPDATED   1


@interface MCTTabMessagesVC ()

- (void)onComposeButtonClicked:(id)sender;

@end


@implementation MCTTabMessagesVC


+ (void)gotoMessageDetail:(NSString *)messageKey
   inNavigationController:(UINavigationController *)navigationController
{
    UIViewController *vc;
    MCTMessage *msg = [[MCTComponentFramework messagesPlugin].store messageDetailsByKey:messageKey];
    if (msg) {
        vc = [MCTMessageHelper viewControllerForMessage:msg];
    } else {
        vc = [MCTLoadMessageVC viewControllerWithMessageKey:messageKey];
    }

    if (vc) {
        if ([navigationController.viewControllers count] > 1 && [navigationController.viewControllers[1] isKindOfClass:[MCTTabMessagesVC class]]) {
            [navigationController setViewControllers:[navigationController.viewControllers subarrayWithRange:NSMakeRange(0, 2)]
                                            animated:NO];
        } else {
            [navigationController popToRootViewControllerAnimated:NO];
        }
        [navigationController pushViewController:vc animated:YES];
    }
}

- (void)viewDidLoad
{
    T_UI();
    self.composeButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                       target:self
                                                       action:@selector(onComposeButtonClicked:)];
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Messages", nil);

    // Maybe user clicked step-2 poke link during registration
    NSString *url = [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_REGISTRATION_OPENED_URL];
    if ([url hasPrefix:MCT_ROGERTHAT_PREFIX]) {
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            T_BIZZ();
            [[MCTComponentFramework configProvider] deleteStringForKey:MCT_CONFIGKEY_REGISTRATION_OPENED_URL];
        }];

        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_APPLICATION_OPEN_URL];
        [intent setString:url forKey:@"url"];
        [intent setBool:YES forKey:@"skipNetworkCheck"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    T_UI();
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    T_UI();
    HERE();
    [super setEditing:editing animated:animated];
    if (!editing) {
        self.navigationItem.leftBarButtonItem = nil;
        [self bindEditButton];
    } else {
        self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
        self.navigationItem.leftBarButtonItem = self.deleteButtonItem;
    }
}

#pragma mark -

- (void)bindEditButton
{
    T_UI();
    if (MCT_FRIENDS_ENABLED) {
        if (self == [self.navigationController.viewControllers firstObject]) {
            self.navigationItem.rightBarButtonItems = @[self.composeButtonItem];
            self.navigationItem.leftBarButtonItem = self.editButtonItem;
        } else {
            self.navigationItem.rightBarButtonItems = @[self.composeButtonItem, self.editButtonItem];
        }
    } else {
        self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
    }
}

- (void)bindDeleteButton
{
    T_UI();
    if (self.tableView.allowsMultipleSelectionDuringEditing) {
        self.navigationItem.rightBarButtonItems = @[self.deleteButtonItem];
    } else if (self.editing) {
        self.navigationItem.rightBarButtonItems = @[];
    } else {
        self.navigationItem.rightBarButtonItems = @[self.composeButtonItem];
    }
}

- (void)onComposeButtonClicked:(id)sender
{
    T_UI();
    [self presentViewController:[MCTMessageHelper composeMessageViewControllerWithRequest:nil
                                                                             andReplyOnMessage:nil]
                            animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTMessageThread *thread = [self.threads objectAtIndex:indexPath.row];
    if (!thread.threadShowInList) {
        [self.plugin.store updateMessageThread:thread.key withVisibility:YES];
        thread.threadShowInList = YES;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark MCTIntent

- (void)registerIntents
{
    T_UI();
    [super registerIntents];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_PUSH_NOTIFICATION
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (self.editing) {
        [self.stashedIntents addObject:intent];
        return;
    }

    [super onIntent:intent];

    if (intent.action == kINTENT_PUSH_NOTIFICATION) {
        if ([MCTComponentFramework menuViewController].tabBarController) {
            [[MCTComponentFramework intentFramework] removeStickyIntent:intent];
            [MCTTabMessagesVC gotoMessageDetail:[intent stringForKey:@"messageKey"]
                         inNavigationController:self.navigationController];
        }
    }
}

@end