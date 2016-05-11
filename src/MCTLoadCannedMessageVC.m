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

#import "MCTLoadCannedMessageVC.h"
#import "MCTMessageHelper.h"
#import "MCTNewMessageVC.h"
#import "MCTSendMessageRequest.h"
#import "MCTUIUtils.h"


@interface MCTLoadCannedMessageVC ()

@property (nonatomic, strong) MCTCannedMessages *cannedMessagesMgr;
@property (nonatomic, strong) NSMutableArray *cannedMessageNames;

@end


@implementation MCTLoadCannedMessageVC

+ (MCTLoadCannedMessageVC *)viewControllerWithCannedMessagesMgr:(MCTCannedMessages *)cannedMessages
{
    T_UI();
    MCTLoadCannedMessageVC *vc = [[MCTLoadCannedMessageVC alloc] initWithNibName:@"loadCannedMessage" bundle:nil];
    vc.cannedMessagesMgr = cannedMessages;
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Send canned message", nil);

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(onCancelClicked:)];
    [self loadData];
}

- (void)loadData
{
    T_UI();
    self.cannedMessageNames = [NSMutableArray arrayWithArray:[self.cannedMessagesMgr.messages.allKeys
                                                              sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    [self.cannedMessageNames removeObject:MCT_NEW_MSG_DRAFT];
}

- (void)onCancelClicked:(id)sender
{
    if ([self.delegate respondsToSelector:(@selector(loadCannedMessageDidCancel))]) {
        [self.delegate loadCannedMessageDidCancel];
    }
}


# pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    return [self.cannedMessageNames count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    T_UI();
    return [self.cannedMessageNames count] ? NSLocalizedString(@"Select saved message", nil) : NSLocalizedString(@"There are no saved messages", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:identifier];
    }
    cell.textLabel.text = [self.cannedMessageNames objectAtIndex:indexPath.row];
    return cell;
}

# pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *selectedName = [self.cannedMessageNames objectAtIndex:indexPath.row];
    MCTSendMessageRequest *request = [self.cannedMessagesMgr.messages objectForKey:selectedName];

    if ([self.delegate respondsToSelector:(@selector(loadCannedMessageDidFinishWithRequest:))]) {
        [self.delegate loadCannedMessageDidFinishWithRequest:request];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return YES;
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    NSString *cannedMessageName = [self.cannedMessageNames objectAtIndex:indexPath.row];
    [self.cannedMessageNames removeObject:cannedMessageName];
    [self.cannedMessagesMgr removeMessageForName:cannedMessageName];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationRight];
}


@end