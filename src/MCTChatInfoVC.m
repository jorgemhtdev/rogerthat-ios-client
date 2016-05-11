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

#import "MCTChatInfoVC.h"
#import "MCTComponentFramework.h"
#import "MCTMessageHelper.h"
#import "MCTServiceOwningVC.h"
#import "MCTUIUtils.h"

#define MCT_CHATINFO_TAG_THREAD_DELETED 1

@interface MCTChatInfoVC ()

@property (nonatomic, strong) MCTMessage *parentMessage;
@property (nonatomic, strong) NSDictionary *chatData;
@property (nonatomic, strong) MCTFriend *sender;
@property (nonatomic) BOOL threadDeletePopupShown;

@end

@implementation MCTChatInfoVC


+ (instancetype)viewControllerWithParentMessage:(MCTMessage *)parentMessage
{
    MCTChatInfoVC *vc = [[MCTChatInfoVC alloc] initWithNibName:@"chatInfo" bundle:nil];
    vc.parentMessage = parentMessage;
    vc.chatData = [parentMessage.message MCT_JSONValue];
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.friendNameLabel.text = [[MCTComponentFramework friendsPlugin] friendDisplayNameByEmail:self.parentMessage.sender];
    self.title = NSLocalizedString(@"Info", nil);

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:@[kINTENT_FRIEND_MODIFIED,
                                                                      kINTENT_FRIEND_REMOVED,
                                                                      kINTENT_MESSAGE_MODIFIED,
                                                                      kINTENT_THREAD_DELETED,
                                                                      ]
                                                            onQueue:[MCTComponentFramework mainQueue]];
    [MCTUIUtils addRoundedBorderToView:self.imageView];
    [self showFriend];
}



- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
    }
}

- (void)showFriend
{
    T_UI();
    self.sender = [[[MCTComponentFramework friendsPlugin] store] friendByEmail:self.parentMessage.sender];

    self.friendNameLabel.text = self.sender.displayName;
    self.imageView.image = self.sender.avatarImage;
    [self.tableView reloadData];
}

- (void)alertThreadDeleted
{
    T_UI();
    LOG(@"alertThreadDeleted - %@", self.parentMessage.key);
    if (self.threadDeletePopupShown)
        return;

    self.threadDeletePopupShown = YES;

    if (self.view.window == nil) {
        // View is not being shown
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [viewControllers removeObject:self];
        [self.navigationController setViewControllers:viewControllers];
        return;
    }

    self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                   andText:NSLocalizedString(@"Conversation has been removed", nil)
                                                    andTag:MCT_CHATINFO_TAG_THREAD_DELETED];
    self.currentAlertView.delegate = self;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (alertView.tag == MCT_CHATINFO_TAG_THREAD_DELETED) {
        [self.navigationController popViewControllerAnimated:YES];
    }

    if (alertView == self.currentAlertView) {
        MCT_RELEASE(self.currentAlertView);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    T_UI();
    NSInteger c = 1;
    if (self.chatData[@"i"] != nil) {
        c++;
    }
    return c;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return [((NSArray *)self.chatData[@"i"]) count];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    T_UI();
    return [self tableView:tableView viewForHeaderInSection:section].height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    T_UI();
    if (section == 0 && self.sender) {
        return self.senderDetailsView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    NSString *identifier = [NSString stringWithFormat:@"%ld:%ld", (long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        cell.textLabel.font = [UIFont systemFontOfSize:cell.detailTextLabel.font.pointSize + 2];
        cell.textLabel.textColor = self.view.tintColor;
    }

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Topic", nil);
            cell.detailTextLabel.text = self.chatData[@"t"];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Description", nil);
            cell.detailTextLabel.text = self.chatData[@"d"];
        }
    } else if (indexPath.section == 1) {
        NSArray *chatInfo = self.chatData[@"i"];
        NSDictionary *pair = chatInfo[indexPath.row];
        cell.textLabel.text = pair[@"k"];
        cell.detailTextLabel.text = pair[@"v"];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return fmaxf(30, [MCTUIUtils heightForCell:[self tableView:tableView cellForRowAtIndexPath:indexPath]]);
}

#pragma mark - Intent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();

    if (intent.action == kINTENT_FRIEND_MODIFIED) {
        if ([[intent stringForKey:@"email"] isEqualToString:self.parentMessage.sender]) {
            [self showFriend];
        }
    }

    else if (intent.action == kINTENT_FRIEND_REMOVED) {
        if ([[intent stringForKey:@"email"] isEqualToString:self.parentMessage.sender]
            && [self.navigationController.viewControllers containsObject:self]) {

            NSArray *vcs = self.navigationController.viewControllers;
            UIViewController *keepVC = nil;
            for (UIViewController *vc in vcs) {
                if ([vc conformsToProtocol:@protocol(MCTServiceOwningVC)]) {
                    id<MCTServiceOwningVC> myVC = (id<MCTServiceOwningVC>) vc;
                    if ([[myVC getOwnedServiceEmail] isEqualToString:self.parentMessage.sender]) {
                        if (keepVC) {
                            [self.navigationController popToViewController:keepVC animated:YES];
                        }
                        break;
                    }
                }
                keepVC = vc;
            }

            // TODO: alert should be owned by parent
            [MCTUIUtils showAlertWithTitle:nil andText:NSLocalizedString(@"Disconnected service", nil)];
        }
    }

    else if (intent.action == kINTENT_MESSAGE_MODIFIED || intent.action == kINTENT_THREAD_MODIFIED) {
        if ([[intent stringForKey:@"message_key"] isEqualToString:self.parentMessage.key]
            || [[intent stringForKey:@"thread_key"] isEqualToString:self.parentMessage.key]) {

            self.parentMessage = [[[MCTComponentFramework messagesPlugin] store] messageInfoByKey:self.parentMessage.key];
            self.chatData = [self.parentMessage.message MCT_JSONValue];
            [self.tableView reloadData];
        }
    }

    else if (intent.action == kINTENT_THREAD_DELETED) {
        if ([[intent stringForKey:@"thread_key"] isEqualToString:self.parentMessage.key]) {
            [self alertThreadDeleted];
        }
    }
}

@end