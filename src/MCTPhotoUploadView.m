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
#import "MCTFormView.h"
#import "MCTMessageDetailView.h"
#import "MCTMessageHelper.h"
#import "MCTPhotoUploadView.h"
#import "MCTUIImagePickerController.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

#import "UIImage+Resize.h"

#define MARGIN 10
#define MAX_PREVIEW_HEIGHT 125


static NSArray *SIZES;
static NSDictionary *SIZE_FORMATS;

@implementation MCTPhotoUploadView


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

- (id)initWithDict:(NSDictionary *)widgetDict
          andWidth:(CGFloat)width
    andColorScheme:(MCTColorScheme)colorScheme
  inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc
{
    T_UI();
    if (self = [super init]) {
        self.width = width;
        self.widgetDict = widgetDict;
        self.viewController = vc;

        LOG(@"%@", self.widgetDict);

        self.source = [self parseSource];
        self.maxPhotoFileSize = [self parseQuality];
        self.cropSize = [self parseRatio];

        self.selectBtn = [TTButton buttonWithStyle:MCT_STYLE_EMBOSSED_SMALL_BUTTON
                                             title:NSLocalizedString(@"Get picture", nil)];
        [self.selectBtn addTarget:self action:@selector(onSelectButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.selectBtn];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    T_UI();
    self.selectBtn.enabled = enabled;
    [super setEnabled:enabled];
}

- (MCTPhotoUploadSource)parseSource
{
    T_UI();
    BOOL fromCamera = [self.widgetDict boolForKey:@"camera"];
    BOOL fromGallery = [MCTUtils deviceIsSimulator] || [self.widgetDict boolForKey:@"gallery"];

    if (fromCamera && fromGallery) {
        return MCTPhotoUploadSourceCameraOrPhotoLibrary;
    } else if (fromGallery) {
        return MCTPhotoUploadSourcePhotoLibrary;
    } else if (fromCamera) {
        return MCTPhotoUploadSourceCamera;
    } else {
        ERROR(@"Invalid photo_upload source. Falling back to 'camera and gallery'.\n%@", self.widgetDict);
        return MCTPhotoUploadSourceCameraOrPhotoLibrary;
    }
}

- (NSInteger)parseQuality
{
    T_UI();
    NSString *quality = [self.widgetDict stringForKey:@"quality"];
    if ([MCTUtils isEmptyOrWhitespaceString:quality]) {
        return 0; // User can chose the quality
    } else if ([@"best" isEqualToString:quality]) {
        return -1;
    } else {
        return [quality intValue]; // 0 if quality is no numeric string
    }
}

- (CGSize)parseRatio
{
    T_UI();
    NSString *ratio = [self.widgetDict stringForKey:@"ratio"];
    if ([MCTUtils isEmptyOrWhitespaceString:ratio]) {
        // no cropping
        return CGSizeMake(-1, -1);
    }

    NSArray *ratioParts = [ratio componentsSeparatedByString:@"x"];
    if ([ratioParts count] != 2) {
        ERROR(@"Invalid photo_upload ratio. Falling back to '0x0'.\n%@", self.widgetDict);
        return CGSizeZero;
    }

    CGSize cropSize = CGSizeMake([[ratioParts objectAtIndex:0] floatValue],
                                 [[ratioParts objectAtIndex:1] floatValue]);
    if (cropSize.width == 0 || cropSize.height == 0) {
        return CGSizeZero;
    }
    return cropSize;
}

- (void)setImage:(UIImage *)image
{
    T_UI();
    if (_image == image)
        return;

    _image = image;
    if (image && image != MCTNull) {
        [self.selectBtn setTitle:NSLocalizedString(@"Change picture", nil) forState:UIControlStateNormal];
        self.imageSize = [UIImageJPEGRepresentation(image, 0) length];
    } else {
        [self.selectBtn setTitle:NSLocalizedString(@"Get picture", nil) forState:UIControlStateNormal];
        self.imageSize = 0;
    }
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    if (self.imageView) {
        if (self.imageView.image) {
            CGSize imageSize = self.imageView.image.size;

            CGFloat widthScale = self.width / imageSize.width;
            CGFloat heightScale = MAX_PREVIEW_HEIGHT / imageSize.height;

            CGFloat scale = MIN(widthScale, heightScale);
            CGRect imageViewFrame = CGRectMake(0, 0, scale * imageSize.width, scale * imageSize.height);
            self.imageView.frame = imageViewFrame;
            self.imageView.centerX = self.width / 2;
        } else {
            self.imageView.frame = CGRectZero;
        }
    }

    CGSize s = [MCTUIUtils sizeForTTButton:self.selectBtn constrainedToSize:CGSizeMake(self.width / 2, 40)];
    CGRect sFrame = CGRectMake(0, self.imageView ? self.imageView.bottom + MARGIN : 0, s.width + 20, MAX(40, s.height));
    self.selectBtn.frame = sFrame;
    self.selectBtn.centerX = self.width / 2;
}

#pragma mark -
#pragma mark MCTWidget

- (CGFloat)height
{
    T_UI();
    return CGRectGetMaxY(self.selectBtn.frame) + MARGIN;
}

- (UIImage *)result
{
    T_UI();
    return self.image;
}

- (NSDictionary *)widget
{
    T_UI();
    return self.widgetDict;
}

+ (NSString *)valueStringForWidget:(NSDictionary *)widgetDict
{
    T_UI();
    return @"";
}

- (id)toBeShownBeforeSubmitWithPositiveButton:(BOOL)isPositiveButton
{
    T_UI();
    if (isPositiveButton) {
        if (!self.image) {
            return [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No photo", nil)
                                               message:NSLocalizedString(@"You need a photo before you can continue.", nil)
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                     otherButtonTitles:[self.selectBtn titleForState:UIControlStateNormal], nil];
        }

        // Show actionSheet if user may chose the quality
        if (self.maxPhotoFileSize == 0) {
            NSString *actualSizeStr = [MCTUtils stringForSize:self.imageSize];
            NSString *title = [NSString stringWithFormat:NSLocalizedString(@"This message is %@. You can reduce message size by scaling the image to one of the sizes below.", nil),
                               actualSizeStr];

            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                                      delegate:nil
                                                             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                        destructiveButtonTitle:nil
                                                             otherButtonTitles:nil];

            BOOL shouldAskToResize = NO;
            for (NSNumber *size in SIZES) {
                if (self.imageSize <= KB * [size longValue]) {
                    break;
                }
                shouldAskToResize = YES;
                [actionSheet addButtonWithTitle:[NSString stringWithFormat:[SIZE_FORMATS objectForKey:size], size]];
            }

            if (shouldAskToResize) {
                [actionSheet addButtonWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Actual (%@)", nil), actualSizeStr]];
                return actionSheet;
            }

            // Image is smaller than smallest option. Don't show any option.
        }
    }

    return nil;
}

- (void)beforeSubmitAlertView:(UIAlertView *)alertView
      answeredWithButtonIndex:(NSInteger)buttonIndex
               submitCallback:(void (^)(void))submitForm
{
    T_UI();
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self onSelectButtonTapped:nil];
    }
}

- (void)beforeSubmitActionSheet:(UIActionSheet *)actionSheet
        answeredWithButtonIndex:(NSInteger)buttonIndex
                 submitCallback:(void (^)(void))submitForm
{
    T_UI();
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (actionSheet.cancelButtonIndex < buttonIndex) {
            buttonIndex--;
        }
        NSMutableArray *sizes  = [NSMutableArray arrayWithArray:SIZES];
        while ([sizes count] && self.imageSize < [[sizes lastObject] intValue] * KB) {
            [sizes removeLastObject];
        }

        if (buttonIndex == [sizes count]) {
            // Actual size
            submitForm();
        } else {
            // Compress image
            int maxBytes = [[sizes objectAtIndex:buttonIndex] intValue] * KB;
            [self compressImageWithMaxSize:maxBytes completion:^(UIImage *compressedImage) {
                T_UI();
                self.imageView.image = self.image = compressedImage;
                submitForm();
            }];
        }
    }
}

#pragma mark -

- (void)compressImageWithMaxSize:(NSInteger)maxSizeInBytes completion:(void (^)(UIImage *resizedImage))completionBlock
{
    T_UI();
    UIImage *bImage = self.image;
    NSInteger bImageSize = self.imageSize;

    self.image = nil;
    self.imageSize = 0;

    [MCTUIUtils compressImage:bImage
                     withSize:bImageSize
                    toMaxSize:maxSizeInBytes
             inViewController:self.viewController
                   completion:completionBlock];
}

- (void)onSelectButtonTapped:(id)sender
{
    T_UI();
    switch (self.source) {
        case MCTPhotoUploadSourceCamera:
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                self.viewController.currentAlertView = [MCTUIUtils showAlertWithTitle:NSLocalizedString(@"No camera available", nil)
                                                                              andText:NSLocalizedString(@"You need to have a camera to do this.", nil)];
                self.viewController.currentAlertView.tag = MCT_TAG_WIDGET_ACTION;
                self.viewController.currentAlertView.delegate = self.viewController;
            } else {
                [self showPickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
            }
            break;

        case MCTPhotoUploadSourcePhotoLibrary:
            [self showPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;

        default:
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [self showPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            } else {
                self.viewController.currentActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                                      delegate:self.viewController
                                                                             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                                        destructiveButtonTitle:nil
                                                                             otherButtonTitles:NSLocalizedString(@"Take a picture", nil),
                                                                                               NSLocalizedString(@"Select from photo library", nil), nil];
                self.viewController.currentActionSheet.tag = MCT_TAG_WIDGET_ACTION;
                [MCTUIUtils showActionSheet:self.viewController.currentActionSheet inViewController:self.viewController];
            }
            break;
    }
}

- (void)showPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    T_UI();
    MCTUIImagePickerController *vc = [[MCTUIImagePickerController alloc] init];
    vc.sourceType = sourceType;
    vc.delegate = self;
    vc.allowsEditing = NO;

    IF_PRE_IOS5({
        [self.viewController presentViewController:vc animated:YES completion:nil];
    });
    IF_IOS5_OR_GREATER({
        [self.viewController presentViewController:vc animated:YES completion:nil];
    });
}

#pragma mark -
#pragma mark UIActionSheet

- (BOOL)processActionSheetClickedButtonAtIndex:(NSInteger)buttonIndex
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
    return YES;
}

#pragma mark -
#pragma mark UIImagePickerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    T_UI();
    UIImage *image = [MCTUIUtils imageByRotatingImage:info[UIImagePickerControllerOriginalImage]];

    if (self.cropSize.width < 0 || self.cropSize.height < 0) {
        // no cropping
        [self imageCropController:nil didFinishWithCroppedImage:image];
        return;
    }

    GKImageCropViewController *cropController = [[GKImageCropViewController alloc] init]; // released by delegate
    cropController.preferredContentSize = picker.preferredContentSize;
    cropController.sourceImage = image;
    cropController.resizeableCropArea = !self.cropSize.width;
    cropController.delegate = self;
    IF_IOS7_OR_GREATER({
        cropController.automaticallyAdjustsScrollViewInsets = NO;
    });

    // Scale cropsize to MAX: 280 width, 371 height

    CGSize appSize = [UIScreen mainScreen].applicationFrame.size;
    int maxWidth = appSize.width - 40; // 40 margin
    int maxHeight = appSize.height - 89; // 40 margin + 49 tabbar

    CGSize cropSize = (self.cropSize.width && self.cropSize.height) ? self.cropSize : cropController.sourceImage.size;
    CGFloat widthScale = maxWidth / cropSize.width;
    CGFloat heightScale = maxHeight / cropSize.height;
    CGFloat scale = MIN(widthScale, heightScale);

    cropController.cropSize = CGSizeMake(scale * cropSize.width, scale * cropSize.height);
    [picker pushViewController:cropController animated:YES];
}

#pragma mark -
#pragma GKImagePickerDelegate

- (void)imageCropController:(GKImageCropViewController *)imageCropController
  didFinishWithCroppedImage:(UIImage *)croppedImage
{
    T_UI();
    IF_PRE_IOS5({
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    });
    IF_IOS5_OR_GREATER({
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    });

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

    dispatch_block_t block = ^{
        if (self.imageView == nil) {
            self.imageView = [[UIImageView alloc] initWithImage:self.image];
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:self.imageView];
            [MCTUIUtils addRoundedBorderToView:self.imageView withBorderColor:[UIColor blackColor] andCornerRadius:0];
        } else {
            self.imageView.image = self.image;
        }

        // first layout MCTFormView, then layout MCTMessageDetailView
        UIView *superview = self.superview;
        while (superview) {
            if ([superview isKindOfClass:[MCTFormView class]]) {
                [superview layoutSubviews];
            } else if ([superview isKindOfClass:[MCTMessageDetailView class]]) {
                [superview setNeedsLayout];
                break;
            }
            superview = superview.superview;
        }

        // Delaying intent because MessageDetailView's layoutSubviews needs to run first
        [[MCTComponentFramework intentFramework] performSelector:@selector(broadcastIntent:)
                                                      withObject:[MCTIntent intentWithAction:kINTENT_MESSAGE_DETAIL_SCROLL_DOWN]
                                                      afterDelay:0.01];
    };

    self.image = croppedImage;

    if (self.maxPhotoFileSize > 0) {
        [self compressImageWithMaxSize:self.maxPhotoFileSize completion:^(UIImage *compressedImage) {
            T_UI();
            self.image = compressedImage;
            block();
        }];
    } else if (self.imageSize > 600 * KB) {
        [self compressImageWithMaxSize:600 * KB completion:^(UIImage *compressedImage) {
            T_UI();
            self.image = compressedImage;
            block();
        }];
    } else {
        block();
    }
}

@end