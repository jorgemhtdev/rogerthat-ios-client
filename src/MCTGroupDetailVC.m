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
#import "MCTEncoding.h"
#import "MCTFriendDetailVC.h"
#import "MCTGroupDetailVC.h"
#import "MCTIdentity.h"
#import "MCTIntent.h"
#import "MCTMessageHelper.h"
#import "MCTReflectiveFillStyle.h"
#import "MCTSendMessageRequest.h"
#import "MCTUIImagePickerController.h"
#import "MCTUIUtils.h"


#import "TTView.h"
#import "Three20Style+Additions.h"

#import "MCTFriendCell.h"

#define MARGIN 5
#define DELETE_BTN_HEIGHT 45
#define AVATAR_SIZE 150

#define TAG_DELETE_CONFIRMATION 1


@interface MCTGroupDetailVC ()

@property (nonatomic) BOOL canceled;
@property (nonatomic) BOOL isNewGroup;
@property (nonatomic) BOOL showComposeButton;
@property (nonatomic) CGFloat originalTableViewTop;

- (void)showPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType;

@end



@implementation MCTGroupDetailVC

+ (MCTGroupDetailVC *)viewControllerWithGroup:(MCTGroup *)group
                                   isNewGroup:(BOOL)isNewGroup
                            showComposeButton:(BOOL)showComposeButton
{
    T_UI();

    MCTGroupDetailVC *vc = [[MCTGroupDetailVC alloc] initWithNibName:@"groupDetail" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    vc.group = group;
    vc.friendsPlugin = [MCTComponentFramework friendsPlugin];
    vc.isNewGroup = isNewGroup;
    vc.showComposeButton = showComposeButton;
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    self.editLbl.text = NSLocalizedString(@"Edit", nil);

    [self loadGroup];
    self.backupMembers = self.group.members;

    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self.tableView reloadData];

    self.cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                           target:self
                                                                           action:@selector(onCancelClicked:)];

    [MCTUIUtils addRoundedBorderToView:self.avatarControl];

    self.deleteGroupBtn = [MCTUIUtils replaceUIButtonWithTTButton:(UIButton *)self.deleteGroupBtn
                                                            style:MCT_STYLE_NEGATIVE_BUTTON];
    [(TTButton *)self.deleteGroupBtn setTitle:NSLocalizedString(@"Delete group", nil)
                                     forState:UIControlStateNormal];

    self.sendMessageBtn = [MCTUIUtils replaceUIButtonWithTTButton:(UIButton *)self.sendMessageBtn];
    [(TTButton *)self.sendMessageBtn setTitle:NSLocalizedString(@"Compose new message", nil)
                                     forState:UIControlStateNormal];
    self.sendMessageBtn.enabled = self.group.members.count > 0;

    self.originalTableViewTop = self.tableView.top;
    [self toggleSendAndDeleteButtons];

    if (self.isNewGroup) {
        [self setEditing:YES animated:NO];
    }

    IF_IOS7_OR_GREATER({
        self.view.backgroundColor = self.tableView.backgroundColor;
    });

    IF_PRE_IOS7({
        [MCTUIUtils setBackgroundStripesToView:self.view];
        [MCTUIUtils setBackgroundStripesToView:self.tableView];
    });

    [self registerIntents];
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    if (![self.navigationController.viewControllers containsObject:self]) {
        if ([self.group.members count] == 0) {
            [self.friendsPlugin.store deleteGroupWithGuid:self.group.guid];
            if (!self.isNewGroup)
                [self.friendsPlugin deleteGroupWithGuid:self.group.guid];

            MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_RECIPIENTS_GROUP_REMOVED];
            [intent setString:self.group.guid forKey:@"guid"];
            [[MCTComponentFramework intentFramework] broadcastIntent:intent];
        }
    }
    [super viewDidDisappear:animated];
}

- (void)registerIntents
{
    T_UI();
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_RECIPIENTS_GROUPS_UPDATED
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)loadGroup
{
    T_UI();
    self.group = [self.friendsPlugin.store getGroupWithGuid:self.group.guid];

    self.avatarView.image = OR(self.editedProfileImage, [self.group avatarImage]);

    if (self.isEditing) {
        self.title = self.nameLbl.text = self.nameTextField.text;
    } else {
        self.title = self.nameLbl.text = self.nameTextField.text = self.group.name;
    }
}


#pragma mark - Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    T_UI();

    if (editing) {
        self.navigationItem.leftBarButtonItem = self.cancelButtonItem;
        self.navigationItem.rightBarButtonItem.enabled = [self.nameTextField.text length] > 0;
    } else {
        if (!self.canceled){
            BOOL nameEdited = ![self.nameTextField.text isEqualToString:self.nameLbl.text];
            NSString *newName = nameEdited ? self.nameTextField.text : self.group.name;
            UIImage *newAvatar = self.editedProfileImage;
            NSData *newAvatarData = newAvatar ? UIImagePNGRepresentation(newAvatar) : self.group.avatar;

            NSString *avatarHash = newAvatar ? nil : self.group.avatarHash;

            [self.friendsPlugin.store updateGroupWithGuid:self.group.guid
                                                     name:newName
                                                   avatar:newAvatarData
                                               avatarHash:avatarHash];

            if([self.group.members count] == 0) {
                self.currentAlertView = [MCTUIUtils showAlertWithTitle:nil
                                                               andText:NSLocalizedString(@"Members are required", nil)];
                self.currentAlertView.delegate = self;
                return;
            }

            [self.friendsPlugin putGroup:[MCTGroup groupWithGuid:self.group.guid
                                                            name:newName
                                                         members:self.group.members
                                                          avatar:newAvatarData
                                                      avatarHash:avatarHash]];

            if (self.isNewGroup) {
                MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_RECIPIENTS_GROUP_ADDED];
                [intent setString:self.group.guid forKey:@"guid"];
                [[MCTComponentFramework intentFramework] broadcastIntent:intent];
            } else {
                MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_RECIPIENTS_GROUP_MODIFIED];
                [intent setString:self.group.guid forKey:@"guid"];
                [[MCTComponentFramework intentFramework] broadcastIntent:intent];
            }
        } else {
            if (self.isNewGroup) {
                [self.friendsPlugin.store deleteGroupWithGuid:self.group.guid];

                MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_RECIPIENTS_GROUP_REMOVED];
                [intent setString:self.group.guid forKey:@"guid"];
                [[MCTComponentFramework intentFramework] broadcastIntent:intent];

                [self.navigationController popViewControllerAnimated:YES];
            } else {
                for (NSString *member in self.backupMembers) {
                    if (![self.group.members containsObject:member]) {
                        [self.friendsPlugin.store insertGroupMemberWithGroupGuid:self.group.guid email:member];
                    }
                }
                for (NSString *member in self.group.members) {
                    if (![self.backupMembers containsObject:member]) {
                        [self.friendsPlugin.store deleteGroupMemberWithGroupGuid:self.group.guid email:member];
                    }
                }
            }
        }

        self.nameLbl.text = self.nameTextField.text;
        [self.nameTextField resignFirstResponder];
        self.navigationItem.leftBarButtonItem = nil;
    }

    [super setEditing:editing animated:animated];

    [self.tableView setEditing:editing animated:animated];

    [UIView animateWithDuration:0.4 animations:^{
        self.emailLbl.alpha = (int) !editing;
        self.nameLbl.alpha = (int) !editing;

        self.nameTextField.alpha = (int) editing;
        self.editLbl.alpha = (int) editing;
        self.editView.alpha = editing ? 0.7 : 0;
    }];

    self.navigationItem.hidesBackButton = editing;

    [self toggleSendAndDeleteButtons];

    self.canceled = NO;
    [self loadGroup];
    [self.tableView reloadData];
}

- (void)toggleSendAndDeleteButtons
{
    T_UI();
    self.sendMessageBtn.hidden = self.editing || !self.showComposeButton;
    self.sendMessageBtn.enabled = self.group.members.count > 0;
    self.deleteGroupBtn.hidden = !self.editing;

    if (!self.showComposeButton) {
        CGFloat yDiff = self.originalTableViewTop - self.sendMessageBtn.top;
        if (self.editing) {
            self.tableView.top = self.originalTableViewTop;
            self.tableView.height -= yDiff;
        } else {
            self.tableView.top = self.sendMessageBtn.top;
            self.tableView.height += yDiff;
        }
    }
}

- (void)onCancelClicked:(id)sender
{
    T_UI();
    self.canceled = YES;
    [self setEditing:NO animated:YES];
}

- (void)onDeleteGroupClicked:(id)sender
{
    T_UI();
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Do you want to remove group \"%@\"?", nil),
                     self.group.name];
    self.currentAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please confirm", nil)
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"No", nil)
                                              otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    self.currentAlertView.tag = TAG_DELETE_CONFIRMATION;
    [self.currentAlertView show];
}

- (IBAction)onSendMessageClicked:(id)sender
{
    T_UI();
    MCTSendMessageRequest *request = [MCTSendMessageRequest request];
    request.groupIds = [NSArray arrayWithObject:self.group.guid];

    [self presentViewController:[MCTMessageHelper composeMessageViewControllerWithRequest:request
                                                                             andReplyOnMessage:nil]
                            animated:YES completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)s
{
    T_UI();
    // Block Done btn when name is left empty
    NSInteger newLength = [textField.text length] + [s length] - range.length;
    self.navigationItem.rightBarButtonItem.enabled = newLength > 0;
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    T_UI();
    self.navigationItem.rightBarButtonItem.enabled = NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    T_UI();
    [textField resignFirstResponder];
    [self setEditing:NO animated:YES];
    return YES;
}

- (IBAction)avatarClicked:(id)sender
{
    T_UI();
    if (self.editing) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.currentActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:
                                        NSLocalizedString(@"Take a picture", nil),
                                        NSLocalizedString(@"Select from photo library", nil), nil];
            [MCTUIUtils showActionSheet:self.currentActionSheet inViewController:self];
        } else {
            [self showPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }
}

- (IBAction)onBackgroundTapped:(id)sender
{
    T_UI();
    [self.nameTextField resignFirstResponder];
}

- (void)showPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    T_UI();
    MCTUIImagePickerController *vc = [[MCTUIImagePickerController alloc] init];
    vc.sourceType = sourceType;
    vc.delegate = self;
    vc.allowsEditing = YES;

    IF_PRE_IOS5({
        [self presentViewController:vc animated:YES completion:nil];
    });
    IF_IOS5_OR_GREATER({
        [self presentViewController:vc animated:YES completion:nil];
    });
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    switch (buttonIndex) {
        case 0: // Camera
            [self showPickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
        case 1: // Library
            [self showPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        default: // Cancel
            break;
    }
    MCT_RELEASE(self.currentActionSheet);
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    IF_PRE_IOS5({
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    IF_IOS5_OR_GREATER({
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    T_UI();
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.editedProfileImage = self.avatarView.image = [image imageByScalingAndCroppingForSize:CGSizeMake(AVATAR_SIZE, AVATAR_SIZE)];

    IF_PRE_IOS5({
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    IF_IOS5_OR_GREATER({
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return self.editing ? nil : NSLocalizedString(@"Remove", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    return self.editing ? [self.friendsPlugin.store countFriendsByType:MCTFriendTypeUser] : [self.group.members count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTFriend *friend;
    if (self.editing) {
        friend = [self.friendsPlugin.store friendByType:MCTFriendTypeUser andIndex:indexPath.row];
    } else {
        friend = [self.friendsPlugin.store friendByEmail:[self.group.members objectAtIndex:indexPath.row]];
    }

    NSString *ident = [NSString stringWithFormat:@"%d", MCTFriendTypeUser];
    MCTFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        cell = [[MCTFriendCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:ident];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor whiteColor];
        [MCTUIUtils addRoundedBorderToView:cell.imageView];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
    }

    if (self.editing && [self.group.members containsObject:friend.email]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [UIColor MCTSelectedCellTextColor];
    } else {
        cell.accessoryType = self.showComposeButton && !self.editing ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        cell.textLabel.textColor = nil;
    }

    cell.friend = friend;
    cell.textLabel.text = [friend displayName];
    cell.imageView.image = [friend avatarImage];

    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return !self.editing;
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTFriendCell *cell = (MCTFriendCell *) [tableView cellForRowAtIndexPath:indexPath];
    [self.friendsPlugin.store deleteGroupMemberWithGroupGuid:self.group.guid email:cell.friend.email];

    [self loadGroup];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationRight];

    [self.tableView reloadData];
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    T_UI();
    if (self.editing) {
        switch (MCT_FRIENDS_CAPTION) {
            case MCTFriendsCaptionColleagues:
                return NSLocalizedString(@"All colleagues", nil);
            case MCTFriendsCaptionContacts:
                return NSLocalizedString(@"All contacts", nil);
            case MCTFriendsCaptionFriends:
            default:
                return NSLocalizedString(@"All friends", nil);
        }
    } else {
        return NSLocalizedString(@"Members", nil);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTFriendCell *cell = (MCTFriendCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (self.editing) {
        BOOL isSelected = NO;
        if ([self.group.members containsObject:cell.friend.email]) {
            [self.friendsPlugin.store deleteGroupMemberWithGroupGuid:self.group.guid email:cell.friend.email];
        } else {
            isSelected = YES;
            [self.friendsPlugin.store insertGroupMemberWithGroupGuid:self.group.guid email:cell.friend.email];
        }
        [self loadGroup];
        [self.tableView reloadData];

        cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        cell.textLabel.textColor = isSelected ? [UIColor MCTSelectedCellTextColor] : [UIColor blackColor];
    } else if (self.showComposeButton) {
        MCTFriendDetailVC *friendDetailVC = [MCTFriendDetailVC viewControllerWithFriend:cell.friend];
        friendDetailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:friendDetailVC animated:YES];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    T_UI();
    MCT_RELEASE(self.currentAlertView);

    if (alertView.tag == TAG_DELETE_CONFIRMATION && buttonIndex != alertView.cancelButtonIndex) {
        [self.friendsPlugin.store deleteGroupWithGuid:self.group.guid];
        [self.friendsPlugin deleteGroupWithGuid:self.group.guid];

        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_RECIPIENTS_GROUP_REMOVED];
        [intent setString:self.group.guid forKey:@"guid"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];

        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_RECIPIENTS_GROUPS_UPDATED) {
        [self loadGroup];
        if (self.group == nil) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.tableView reloadData];
        }
    }
}

@end