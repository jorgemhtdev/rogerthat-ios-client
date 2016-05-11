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
#import "MCTMessageEnums.h"
#import "MCTMessageHelper.h"
#import "MCTNewMessageButtonsVC.h"
#import "MCTNewMessageTextVC.h"
#import "MCTNewMessageVC.h"
#import "MCTTransferObjects.h"
#import "MCTUIImagePickerController.h"
#import "MCTUINavigationController.h"
#import "MCTUIUtils.h"

#import "TTButton.h"
#import "UIImage+Resize.h"
#import "UIViewAdditions.h"

#import <MobileCoreServices/UTCoreTypes.h>

#define MCT_NEW_MSG_MAX_LENGTH 500

#define MCT_TAG_IMAGE_SOURCE 1
#define MCT_TAG_VIDEO_SOURCE 2
#define MCT_TAG_PRIORITY 3
#define MCT_TAG_STICKY 4


static NSArray *SIZES;
static NSDictionary *SIZE_FORMATS;


@interface MCTNewMessageTextVC ()

- (void)updatePriorityIcon;

@end


@implementation MCTNewMessageTextVC

+ (void)initialize
{
    if (SIZES == nil) {
        SIZES = [[NSArray alloc] initWithObjects:
                 [NSNumber numberWithInt:75],
                 [NSNumber numberWithInt:200],
                 [NSNumber numberWithInt:450], nil];
    }
    if (SIZE_FORMATS == nil) {
        SIZE_FORMATS = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                                                              NSLocalizedString(@"Small (%@KB)", nil),
                                                              NSLocalizedString(@"Medium (%@KB)", nil),
                                                              NSLocalizedString(@"Large (%@KB)", nil), nil]
                                                     forKeys:SIZES];
    }
}

+ (MCTNewMessageTextVC *)viewControllerWithRequest:(MCTSendMessageRequest *)request
{
    T_UI();
    MCTNewMessageTextVC *vc = [[MCTNewMessageTextVC alloc] initWithNibName:@"newMessageText" bundle:nil];
    vc.request = request;
    return vc;
}

- (void)updateStickyIcon
{
    T_UI();
    UIImage *stickyIcon;
    if (IS_FLAG_SET(self.request.flags, MCTMessageFlagChatSticky)) {
        stickyIcon = [UIImage imageNamed:@"add_sticky_1.png"];
    } else {
        stickyIcon = [UIImage imageNamed:@"add_sticky_0.png"];
    }

    [self.addSticky setImage:[stickyIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

- (void)updatePriorityIcon
{
    T_UI();
    UIImage *priorityIcon;
    if (self.request.priority == MCTMessagePriorityHigh) {
        priorityIcon = [UIImage imageNamed:@"add_priority_2.png"];
    } else if (self.request.priority == MCTMessagePriorityUrgent) {
        priorityIcon = [UIImage imageNamed:@"add_priority_3.png"];
    } else if (self.request.priority == MCTMessagePriorityUrgentWithAlarm){
        priorityIcon = [UIImage imageNamed:@"add_priority_4.png"];
    } else {
        priorityIcon = [UIImage imageNamed:@"add_priority_1.png"];
    }

    [self.addPriority setImage:[priorityIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];
    [self loadMessage];
    [self.textView becomeFirstResponder];

    for (UIButton *btn in @[self.addButton, self.addSticky, self.addPriority, self.addImage, self.addVideo]) {
        [btn setImage:[btn.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
             forState:UIControlStateNormal];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }

    [self updatePriorityIcon];
    [self updateStickyIcon];

    NSMutableArray *buttons = [NSMutableArray array]; // buttons from right to left

    BOOL addImage = YES;
    BOOL addVideo = YES;
    BOOL addPriority = NO;
    BOOL addSticky = NO;
    BOOL addButtons = YES;

    if (IS_FLAG_SET(self.request.flags, MCTMessageFlagDynamicChat)) {
        if (!IS_FLAG_SET(self.request.flags, MCTMessageFlagAllowChatPicture)) {
            addImage = NO;
        }
        if (!IS_FLAG_SET(self.request.flags, MCTMessageFlagAllowChatVideo)) {
            addVideo = NO;
        }
        if (IS_FLAG_SET(self.request.flags, MCTMessageFlagAllowChatPriority)) {
            addPriority = YES;
        }
        if (IS_FLAG_SET(self.request.flags, MCTMessageFlagAllowChatSticky)) {
            addSticky = YES;
        }
        if (!IS_FLAG_SET(self.request.flags, MCTMessageFlagAllowChatButtons)) {
            addButtons = NO;
        }
    }

    if (addImage) {
        [buttons addObject:self.addImage];
    } else {
        [self.addImage removeFromSuperview];
        MCT_RELEASE(self.addImage);
    }
    if (addVideo) {
        [buttons addObject:self.addVideo];
    } else {
        [self.addVideo removeFromSuperview];
        MCT_RELEASE(self.addVideo);
    }
    if (addPriority) {
        [buttons addObject:self.addPriority];
    } else {
        [self.addPriority removeFromSuperview];
        MCT_RELEASE(self.addPriority);
    }
    if (addSticky) {
        [buttons addObject:self.addSticky];
    } else {
        [self.addSticky removeFromSuperview];
        MCT_RELEASE(self.addSticky);
    }
    if (addButtons) {
        [buttons addObject:self.addButton];
    } else {
        [self.addButton removeFromSuperview];
        MCT_RELEASE(self.addButton);
    }

    [buttons enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIControl *btn, NSUInteger idx, BOOL *stop) {
        if (idx == [buttons count] - 1) {
            btn.right = self.view.right - 10;
        } else {
            btn.right = ((UIControl *)buttons[idx + 1]).left - 10;
        }
    }];

    self.dummyTextField.frame = self.textView.frame;
    self.enterTextLabel.text = NSLocalizedString(@"Enter message:", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    T_UI();
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder];
}

- (IBAction)onAddButtonTapped:(id)sender
{
    T_UI();
    [(MCTNewMessageVC *) self.sendMessageViewController onNextClicked:nil];
}

- (IBAction)onAddStickyTapped:(id)sender
{
    T_UI();
    self.currentActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Sticky", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"Disabled", nil),
                                NSLocalizedString(@"Enabled", nil),
                                nil];
    self.currentActionSheet.tag = MCT_TAG_STICKY;
    [MCTUIUtils showActionSheet:self.currentActionSheet inViewController:self];
    [self.textView resignFirstResponder];
}

- (IBAction)onAddPriorityTapped:(id)sender
{
    T_UI();
    self.currentActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Priority", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"Normal", nil),
                                                                    NSLocalizedString(@"High", nil),
                                                                    NSLocalizedString(@"Urgent", nil),
                                                                    NSLocalizedString(@"Urgent with alarm", nil),
                                                                    nil];
    self.currentActionSheet.tag = MCT_TAG_PRIORITY;
    [MCTUIUtils showActionSheet:self.currentActionSheet inViewController:self];
    [self.textView resignFirstResponder];
}

- (IBAction)onAddImageTapped:(id)sender
{
    T_UI();
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.currentActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"Take a picture", nil),
                                                                        NSLocalizedString(@"Select from photo library", nil),
                                                                        nil];
        self.currentActionSheet.tag = MCT_TAG_IMAGE_SOURCE;
        [MCTUIUtils showActionSheet:self.currentActionSheet inViewController:self];
    } else {
        [self showPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary
                             mediaType:(NSString *)kUTTypeImage];
    }
    [self.textView resignFirstResponder];
}

- (IBAction)onAddVideoTapped:(id)sender
{
    T_UI();
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.currentActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"Record a video", nil),
                                                                        NSLocalizedString(@"Select from photo library", nil),
                                                                        nil];
        self.currentActionSheet.tag = MCT_TAG_VIDEO_SOURCE;
        [MCTUIUtils showActionSheet:self.currentActionSheet inViewController:self];
    } else {
        [self showPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary
                             mediaType:(NSString *)kUTTypeMovie];
    }
    [self.textView resignFirstResponder];
}

- (void)onRmAttachmentTapped:(id)sender
{
    T_UI();
    HERE();
    self.addVideo.hidden = NO;
    self.addImage.hidden = NO;

    [UIView animateWithDuration:0.2
                     animations:^{
                         self.textView.width += self.imageView.right;
                         self.textView.left -= self.imageView.right;
                         self.dummyTextField.frame = self.textView.frame;

                         self.rmAttachment.left -= self.imageView.width;
                         self.rmAttachment.width = self.rmAttachment.height = 0;
                         self.imageView.width -= self.imageView.width;
                         self.overlayImageView.width -= self.overlayImageView.width;
                     }
                     completion:^(BOOL finished) {
                         [self.imageView removeFromSuperview];
                         MCT_RELEASE(self.imageView);

                         [self.overlayImageView removeFromSuperview];
                         MCT_RELEASE(self.overlayImageView);

                         [self.rmAttachment removeFromSuperview];
                         MCT_RELEASE(self.rmAttachment);
                     }];

    self.request.attachmentHash = nil;
    self.request.attachmentSize = -1;
    self.request.attachmentContentType = nil;
}

- (void)loadMessage
{
    T_UI();
    self.textView.text = self.request.message;
}

- (void)saveMessage
{
    T_UI();
    self.request.message = self.textView.text;
}

- (void)viewDidDisappear:(BOOL)animated
{
    T_UI();
    [super viewDidDisappear:animated];
    [self saveMessage];
}

#pragma mark - Images

- (void)showPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
                       mediaType:(NSString *)mediaType
{
    T_UI();
    MCTUIImagePickerController *vc = [[MCTUIImagePickerController alloc] init];
    vc.sourceType = sourceType;
    vc.mediaTypes = @[mediaType];
    vc.delegate = self;
    vc.allowsEditing = NO;
    [self.sendMessageViewController presentViewController:vc animated:YES completion:nil];
}

- (void)compressImage:(UIImage *)bImage
             withSize:(NSInteger)bImageSize
            toMaxSize:(NSInteger)maxSizeInBytes
           completion:(void (^)(UIImage *resizedImage, NSInteger imageSize))completionBlock
{
    T_UI();

    MCTUIViewController *vc = self;
    UIView *view = vc.navigationController ? vc.navigationController.view : vc.view;
    vc.currentProgressHUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:vc.currentProgressHUD];
    vc.currentProgressHUD.labelText = NSLocalizedString(@"Compressing, please wait…", nil);
    vc.currentProgressHUD.mode = MBProgressHUDModeIndeterminate;
    vc.currentProgressHUD.dimBackground = YES;
    [vc.currentProgressHUD show:YES];

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        UIImage *resizedImage = bImage;
        NSInteger imageSize = bImageSize;
        NSInteger previousImageSize;

        while (imageSize > maxSizeInBytes) {
            LOG(@"image size %d > max size %d", imageSize, maxSizeInBytes);
            resizedImage = [resizedImage resizedImage:CGSizeMake(resizedImage.size.width * 0.8,
                                                                 resizedImage.size.height * 0.8)
                                 interpolationQuality:kCGInterpolationMedium];

            previousImageSize = imageSize;
            imageSize = [UIImageJPEGRepresentation(resizedImage, 0) length];

            if (imageSize >= previousImageSize) {
                LOG(@"Could not reduce the image size any further");
                break;
            }
        }
        LOG(@"image size %d <= max size %d", imageSize, maxSizeInBytes);

        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(resizedImage, imageSize);
            [vc.currentProgressHUD hide:YES];
            MCT_RELEASE(vc.currentProgressHUD);
        });
    }];
}

- (void)addNewVideo:(NSURL *)tmpVideoURL
{
    T_UI();

    MCTUIViewController *vc = self;
    UIView *view = vc.navigationController ? vc.navigationController.view : vc.view;
    vc.currentProgressHUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:vc.currentProgressHUD];
    vc.currentProgressHUD.labelText = NSLocalizedString(@"Compressing, please wait…", nil);
    vc.currentProgressHUD.mode = MBProgressHUDModeIndeterminate;
    vc.currentProgressHUD.dimBackground = YES;
    [vc.currentProgressHUD show:YES];

    dispatch_block_t onError = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            T_UI();
            [vc.currentProgressHUD hide:YES];
            MCT_RELEASE(vc.currentProgressHUD);

            vc.currentAlertView = [MCTUIUtils showErrorPleaseRetryAlert];
            vc.currentAlertView.delegate = vc;
        });
    };

    NSURL *videoURL = [NSURL fileURLWithPath:[[tmpVideoURL path] stringByAppendingPathExtension:@"mp4"]];
    [MCTUIUtils createMP4VideoForVideoWithURL:tmpVideoURL
                                        toURL:videoURL
                            completionHandler:^(BOOL success, NSError *exportError) {
                                if (exportError) {
                                    onError();
                                    ERROR(@"Failed to convert video to mp4: %@\nError: %@", tmpVideoURL, exportError);
                                    return;
                                }

                                [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                                    T_BIZZ();
                                    NSError *error = nil;
                                    NSString *sha256 = [MCTUtils fileSHA256:videoURL error:&error];
                                    if (error) {
                                        onError();
                                        ERROR(@"Failed to calculate SHA256 of video: %@\nError: %@", videoURL, error);
                                        return;
                                    }

                                    self.request.attachmentContentType = MSG_ATTACHMENT_CONTENT_TYPE_VIDEO_MP4;
                                    self.request.attachmentHash = sha256;
                                    self.request.attachmentSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[videoURL path]
                                                                                                                    error:&error] fileSize];

                                    UIImage *thumbnail = [MCTUIUtils createThumbnailForVideoWithURL:videoURL
                                                                                        contentType:self.request.attachmentContentType];

                                    // Create attachment dir if it does not exist
                                    NSString *attachmentDir = [[MCTComponentFramework messagesPlugin] attachmentsDirWithSendMessageRequest:self.request];

                                    [[NSFileManager defaultManager] createDirectoryAtPath:attachmentDir
                                                              withIntermediateDirectories:YES
                                                                               attributes:nil
                                                                                    error:&error];
                                    if (error) {
                                        onError();
                                        ERROR(@"Failed to create directory: %@\n%@", attachmentDir, error);
                                        return;
                                    }

                                    NSString *file = [[MCTComponentFramework messagesPlugin] attachmentsFileWithSendMessageRequest:self.request];
                                    LOG(@"Moving attachment to %@", file);
                                    [[NSFileManager defaultManager] moveItemAtPath:[videoURL path]
                                                                            toPath:file
                                                                             error:&error];
                                    if (error) {
                                        onError();
                                        ERROR(@"Failed to move attachment to %@\n%@", file, error);
                                        return;
                                    }
                                    
                                    NSString *thumbnailFile = [file stringByAppendingString:@".thumb"];
                                    [UIImageJPEGRepresentation(thumbnail, 0) writeToFile:thumbnailFile
                                                                                 options:NSDataWritingAtomic
                                                                                   error:&error];
                                    if (error) {
                                        ERROR(@"Failed to write thumbnail to %@\n%@", file, error);
                                        error = nil;
                                    }
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [vc.currentProgressHUD hide:YES];
                                        MCT_RELEASE(vc.currentProgressHUD);
                                        [self addImageAttachmentToScreen:thumbnail
                                                             withOverlay:@"video-overlay"];
                                    });
                                }];
    }];
}

- (void)addNewImage:(UIImage *)newImage withSize:(NSInteger)imageSize
{
    T_UI();
    // TODO: modal spinner?

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        HERE();
        NSData *data = UIImageJPEGRepresentation(newImage, 0);
        self.request.attachmentHash = [data sha256Hash];
        self.request.attachmentSize = imageSize;
        self.request.attachmentContentType = MSG_ATTACHMENT_CONTENT_TYPE_IMG_JPG;

        // Create attachment dir if it does not exist
        NSString *attachmentDir = [[MCTComponentFramework messagesPlugin] attachmentsDirWithSendMessageRequest:self.request];

        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:attachmentDir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) {
            // TODO: show error
            ERROR(@"Failed to create directory: %@\n%@", attachmentDir, error);
            return;
        }

        NSString *file = [[MCTComponentFramework messagesPlugin] attachmentsFileWithSendMessageRequest:self.request];
        LOG(@"Writing attachment to %@", file);
        [data writeToFile:file options:NSDataWritingAtomic error:&error];
        if (error) {
            // TODO: show error
            ERROR(@"Failed to write attachment to %@\n%@", file, error);
            return;
        }

        UIScreen *mainScreen = [UIScreen mainScreen];
        CGFloat destinationWidth = mainScreen.applicationFrame.size.width * 2/3 * mainScreen.scale;
        if (destinationWidth < newImage.size.width || destinationWidth < newImage.size.height) {
            UIImage *thumbnail = [MCTUIUtils createThumbnailWithSize:CGSizeMake(destinationWidth, destinationWidth)
                                                            forImage:newImage];
            if (thumbnail) {
                NSString *thumbnailFile = [file stringByAppendingString:@".thumb"];
                [UIImageJPEGRepresentation(thumbnail, 0) writeToFile:thumbnailFile
                                                             options:NSDataWritingAtomic
                                                               error:&error];
                if (error) {
                    ERROR(@"Failed to write thumbnail to %@\n%@", file, error);
                    error = nil;
                }
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            T_UI();
            [self addImageAttachmentToScreen:newImage
                                 withOverlay:nil];
        });
    }];
}

- (void)addImageAttachmentToScreen:(UIImage *)newImage
                       withOverlay:(NSString *)overlay
{
    T_UI();
    if (self.imageView == nil) {
        CGRect f = self.textView.frame;
        f.size.width = f.size.height = fmin(f.size.height, 100);
        self.imageView = [[UIImageView alloc] initWithFrame:f];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.imageView.image = newImage;
        [MCTUIUtils resizeImageView:self.imageView withAllowShrinking:NO];
        [MCTUIUtils addRoundedBorderToView:self.imageView
                           withBorderColor:[UIColor lightGrayColor]
                           andCornerRadius:5];

        [self.view addSubview:self.imageView];

        self.textView.left += self.imageView.right;
        self.textView.width -= self.imageView.right;

        self.dummyTextField.frame = self.textView.frame;
    } else {
        self.imageView.image = newImage;
    }

    if (overlay != nil) {
        if (self.overlayImageView == nil) {
            self.overlayImageView = [[UIImageView alloc] initWithFrame:self.imageView.frame];
            self.overlayImageView.contentMode = UIViewContentModeScaleAspectFill;
            [MCTUIUtils addRoundedBorderToView:self.overlayImageView
                               withBorderColor:[UIColor clearColor]
                               andCornerRadius:5];
            [self.view addSubview:self.overlayImageView];
        } else {
            self.overlayImageView.frame = self.imageView.frame;
        }
        self.overlayImageView.image = [UIImage imageNamed:overlay];
    }

    if (self.rmAttachment == nil) {
        self.rmAttachment = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self.rmAttachment setImage:[UIImage imageNamed:@"rm_attachment.png"]
                           forState:UIControlStateNormal];
        self.rmAttachment.center = CGPointMake(self.imageView.right, self.imageView.top);
        [self.imageView.superview addSubview:self.rmAttachment];
        [self.rmAttachment addTarget:self
                              action:@selector(onRmAttachmentTapped:)
                    forControlEvents:UIControlEventTouchUpInside];
    }

    self.addImage.hidden = YES;
    self.addVideo.hidden = YES;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.textView becomeFirstResponder];
    }

    if (actionSheet.tag == MCT_TAG_IMAGE_SOURCE) {
        switch (buttonIndex) {
            case 0: // Camera
                [self showPickerWithSourceType:UIImagePickerControllerSourceTypeCamera
                                     mediaType:(NSString *)kUTTypeImage];
                break;
            case 1: // Library
                [self showPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary
                                     mediaType:(NSString *)kUTTypeImage];
                break;
            default: // Cancel
                break;
        }
    } else if (actionSheet.tag == MCT_TAG_VIDEO_SOURCE) {
        switch (buttonIndex) {
            case 0: // Camera
                [self showPickerWithSourceType:UIImagePickerControllerSourceTypeCamera
                                     mediaType:(NSString *)kUTTypeMovie];
                break;
            case 1: // Library
                [self showPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary
                                     mediaType:(NSString *)kUTTypeMovie];
                break;
            default: // Cancel
                break;
        }
    } else if (actionSheet.tag == MCT_TAG_PRIORITY) {
        switch (buttonIndex) {
            case 0: // Normal
                self.request.priority = MCTMessagePriorityNormal;
                [self updatePriorityIcon];
                break;
            case 1: // High
                self.request.priority = MCTMessagePriorityHigh;
                [self updatePriorityIcon];
                break;
            case 2: // Urgent
                self.request.priority = MCTMessagePriorityUrgent;
                [self updatePriorityIcon];
                break;
            case 3: // Urgent with alarm
                self.request.priority = MCTMessagePriorityUrgentWithAlarm;
                [self updatePriorityIcon];
                break;
            default: // Cancel
                break;
        }
    } else if (actionSheet.tag == MCT_TAG_STICKY) {
        switch (buttonIndex) {
            case 0: // Disabled
                self.request.flags &= ~MCTMessageFlagChatSticky;
                [self updateStickyIcon];
                break;
            case 1: // Enabled
                self.request.flags |= MCTMessageFlagChatSticky;
                [self updateStickyIcon];
                break;
            default: // Cancel
                break;
        }
    }

    MCT_RELEASE(self.currentActionSheet);
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    T_UI();
    [self.sendMessageViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    T_UI();
    [self.sendMessageViewController dismissViewControllerAnimated:YES completion:nil];

    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        [self addNewVideo:videoURL];
    } else {
        UIImage *image = [MCTUIUtils imageByRotatingImage:info[UIImagePickerControllerOriginalImage]];

        NSInteger imageSize = [UIImageJPEGRepresentation(image, 0) length];
        if (imageSize > 600 * KB) {
            [self compressImage:image
                       withSize:imageSize
                      toMaxSize:600 * KB
                     completion:^(UIImage *compressedImage, NSInteger imageSize) {
                         T_UI();
                         [self addNewImage:compressedImage withSize:imageSize];
                     }];
        } else {
            [self addNewImage:image withSize:imageSize];
        }
    }
}


#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    T_UI();
    NSInteger newLength = [textView.text length] + [text length] - range.length;
    return (MCT_NEW_MSG_MAX_LENGTH - newLength >= 0);
}

@end