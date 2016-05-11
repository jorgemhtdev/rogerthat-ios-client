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

#import "MCTFriendInviteLocationSharingVC.h"
#import "MCTComponentFramework.h"
#import "MCTFriendsPlugin.h"
#import "MCTTransferObjects.h"
#import "MCTUIUtils.h"

@interface MCTFriendInviteLocationSharingVC ()

@property (nonatomic, strong) UIBarButtonItem *doneButton;

- (void)keyboardDidShow:(NSNotification *)aNotification;
- (void)keyboardDidHide:(NSNotification *)aNotification;
- (void)toggleDoneButton:(BOOL)shown;
- (void)onDoneButtonClicked:(id)button;

@end


@implementation MCTFriendInviteLocationSharingVC


+ (MCTFriendInviteLocationSharingVC *)viewControllerWithFriend:(MCTFriend *)friend
{
    MCTFriendInviteLocationSharingVC *vc = [[MCTFriendInviteLocationSharingVC alloc]
                                             initWithNibName:@"friendInviteLocationSharing"
                                             bundle:nil];
    vc.friend = friend;
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Request location", nil);
    self.avatarImageView.image = [self.friend avatarImage];
    [MCTUIUtils addRoundedBorderToView:self.avatarImageView];
    [MCTUIUtils setBackgroundStripesToView:self.view];

    self.dummyTextField.frame = self.inviteText.frame;
    self.explanationLabel.text = [NSString stringWithFormat:
                                  NSLocalizedString(@"Invite %@ to share his/her location with you.", nil),
                                  [self.friend displayName]];
    self.inviteLabel.text = NSLocalizedString(@"Optional invitation message:", nil);

    // Replace UIButton with TTButton
    [(UIButton *)self.sendButton setTitle:NSLocalizedString(@"Send invitation", nil)
                                 forState:UIControlStateNormal];
    self.sendButton = [MCTUIUtils replaceUIButtonWithTTButton:(UIButton *)self.sendButton];

    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                     target:self
                                                                     action:@selector(onDoneButtonClicked:)];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (keyboardDidShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (keyboardDidHide:)
                                                 name: UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark -
#pragma mark Keyboard Scrolling Magic

- (void)keyboardDidShow:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];

    CGRect frame = self.view.frame;
    frame.origin.y = -self.inviteLabel.frame.origin.y;
    IF_IOS7_OR_GREATER({
        frame.origin.y += 64;
    });
    self.view.frame = frame;

    [UIView commitAnimations];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];

    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    self.view.frame = frame;

    [UIView commitAnimations];
}

#pragma mark -

- (void)toggleDoneButton:(BOOL)shown
{
    T_UI();
    self.navigationItem.rightBarButtonItem = shown ? self.doneButton : nil;
}

- (IBAction)onInviteButtonClicked:(id)sender
{
    T_UI();
    MCTInvocationOperation *op = [MCTInvocationOperation operationWithTarget:[MCTComponentFramework friendsPlugin]
                                                                    selector:@selector(requestLocationSharingWithFriend:andMessage:)
                                                                     objects:self.friend.email, self.inviteText.text, nil];
    [[MCTComponentFramework workQueue] addOperation:op];

    NSString *msg = [NSString stringWithFormat:
                     NSLocalizedString(@"An invitation has been successfully sent to %@", nil),
                     [self.friend displayName]];

    self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil andText:msg];
    self.currentAlertView.delegate = self;
}

- (void)onDoneButtonClicked:(id)button
{
    T_UI();
    [self.inviteText resignFirstResponder];
    [self toggleDoneButton:NO];
}

- (IBAction)onBackgroundTapped:(id)sender
{
    T_UI();
    [self onDoneButtonClicked:nil];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    T_UI();
    [self toggleDoneButton:YES];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    MCT_RELEASE(self.currentAlertView);
    [self.navigationController popViewControllerAnimated:YES];
}

@end