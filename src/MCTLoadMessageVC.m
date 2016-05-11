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

#import "MCTCommunicationManager.h"
#import "MCTComponentFramework.h"
#import "MCTIntent.h"
#import "MCTLoadMessageVC.h"
#import "MCTMessageHelper.h"
#import "MCTUIUtils.h"

#define MARGIN 10


@interface MCTLoadMessageVC ()

- (void)showMessage:(MCTMessage *)msg;
- (void)showError;

- (void)registerIntents;
- (void)unregisterIntents;

@end


@implementation MCTLoadMessageVC


+ (MCTLoadMessageVC *)viewControllerWithMessageKey:(NSString *)msgKey
{
    T_UI();
    MCTLoadMessageVC *vc = [[MCTLoadMessageVC alloc] init];
    vc.messageKey = msgKey;
    return vc;
}

- (void)loadView
{
    T_UI();
    CGRect frame = CGRectZero;
    frame.size = [MCTUIUtils availableSizeForViewWithController:self];
    self.view = [[UIView alloc] initWithFrame:frame];
    [MCTUIUtils setBackgroundPlainToView:self.view];

    self.spinner = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    int sW = 40;
    int sY = sW;
    IF_IOS7_OR_GREATER({
        sY += 64;
    });
    CGRect sFrame = CGRectMake((frame.size.width - sW) / 2, sY, sW, sW);
    self.spinner.frame = sFrame;
    [self.view addSubview:self.spinner];

    self.loadingLabel = [[UILabel alloc] init];
    self.loadingLabel.backgroundColor = [UIColor clearColor];
    self.loadingLabel.numberOfLines = 0;
    self.loadingLabel.text = NSLocalizedString(@"Loading message ...", nil);
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    self.loadingLabel.textColor = [UIColor darkGrayColor];

    CGFloat lW = frame.size.width - 2 * MARGIN;
    int lX = MARGIN;
    int lY = sFrame.origin.y + sFrame.size.height + MARGIN;
    CGSize lSize = [MCTUIUtils sizeForLabel:self.loadingLabel withWidth:lW];
    CGRect lFrame = CGRectMake(lX, lY, lW, lSize.height);
    self.loadingLabel.frame = lFrame;

    [self.view addSubview:self.loadingLabel];

    [self.spinner startAnimating];
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Loading ...", nil);
}

- (void)viewDidAppear:(BOOL)animated
{
    T_UI();
    [super viewDidAppear:animated];
    MCTMessage *msg = [[[MCTComponentFramework messagesPlugin] store] messageDetailsByKey:self.messageKey];
    if (msg) {
        [self showMessage:msg];
    } else {
        [self registerIntents];
        [[MCTComponentFramework commManager] kick];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[MCTComponentFramework intentFramework] unregisterIntentListener:self];

        if (self.retryTimer)
            [self.retryTimer invalidate];
    }
}

- (void)showMessage:(MCTMessage *)msg
{
    T_UI();
    if (self.loaded)
        return;

    UIViewController *vc = [MCTMessageHelper viewControllerForMessage:msg];
    if (vc) {
        NSMutableArray *vcs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        NSUInteger count = [vcs count];
        if (count > 0) {
            [vcs replaceObjectAtIndex:count - 1
                           withObject:vc];
        } else {
            [vcs addObject:vc];
        }
        [self.navigationController setViewControllers:vcs animated:YES];
        self.loaded = YES;
    } else {
        [self showError];
    }
}

- (void)showError
{
    T_UI();
    ERROR(@"Message %@ not received after communicating", self.messageKey);
    self.currentAlertView = [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"Failed to retrieve the message", nil)];
    self.currentAlertView.delegate = self;
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    T_UI();
    [self.navigationController popViewControllerAnimated:YES];
    MCT_RELEASE(self.currentAlertView);
}

#pragma mark -
#pragma mark MCTIntent

- (void)registerIntents
{
    T_UI();
    NSArray *intents = [NSArray arrayWithObjects:kINTENT_MESSAGE_RECEIVED_HIGH_PRIO, kINTENT_MESSAGE_MODIFIED,
                        kINTENT_BACKLOG_FINISHED, kINTENT_BACKLOG_STARTED, nil];
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:intents
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)unregisterIntents
{
    T_UI();
    [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (((intent.action == kINTENT_MESSAGE_MODIFIED || intent.action == kINTENT_MESSAGE_RECEIVED_HIGH_PRIO)
            && [self.messageKey isEqualToString:[intent stringForKey:@"message_key"]])
        || (intent.action == kINTENT_BACKLOG_FINISHED && [intent longForKey:@"status"] == MCTCommunicationResultSuccess)) {

        MCTMessage *msg = [[[MCTComponentFramework messagesPlugin] store] messageDetailsByKey:self.messageKey];
        if (msg) {
            [self showMessage:msg];
        } else {
            [self showError];
        }
    }
    else if (intent.action == kINTENT_BACKLOG_FINISHED) {
        self.retryTimer = [NSTimer scheduledTimerWithTimeInterval:15
                                                           target:self
                                                         selector:@selector(onRetryTimeout:)
                                                         userInfo:nil
                                                          repeats:NO];
    }
    else if (intent.action == kINTENT_BACKLOG_STARTED && self.retryTimer) {
        [self.retryTimer invalidate];
        MCT_RELEASE(self.retryTimer);
    }
}

- (void)onRetryTimeout:(NSTimer *)timer
{
    T_UI();
    [timer invalidate];
    MCT_RELEASE(self.retryTimer);
}

@end