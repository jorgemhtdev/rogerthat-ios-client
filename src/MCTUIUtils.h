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

#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>

#import "MCTBrandingMgr.h"
#import "MCTIntent.h"
#import "MCTUIViewController.h"
#import <WebKit/WebKit.h>

#define MCT_IPHONE_6_HEIGHT 667

#define MCT_STYLE_EMBOSSED_BUTTON @"embossedButton:"
#define MCT_STYLE_EMBOSSED_SMALL_BUTTON @"embossedButtonWithSmallFontSize:"
#define MCT_STYLE_EMBOSSED_SMALL_MULTILINE_BUTTON @"multilineEmbossedButtonWithSmallFontSize:"

#define MCT_STYLE_DISMISS_BUTTON @"dismissButton:"
#define MCT_STYLE_DISMISS_SMALL_BUTTON @"dismissButtonWithSmallFontSize:"

#define MCT_STYLE_MAGIC_BUTTON @"magicButton:"
#define MCT_STYLE_MAGIC_SMALL_BUTTON @"magicButtonWithSmallFontSize:"

#define MCT_STYLE_POSITIVE_BUTTON @"positiveButton:"
#define MCT_STYLE_NEGATIVE_BUTTON @"negativeButton:"


@interface UIColor (MCTCategory)

+ (UIColor *)MCTDarkBlueColor;
+ (UIColor *)MCTBeigeColor;
+ (UIColor *)MCTNavigationBarColor;
+ (UIColor *)MCTSectionBackgroundColor;
+ (UIColor *)MCTSelectedCellTextColor;
+ (UIColor *)MCTSeparatorColor;
+ (UIColor *)MCTMercuryColor;
+ (UIColor *)MCTGreenColor;
+ (UIColor *)MCTRedColor;
+ (UIColor *)MCTBlackColor;
+ (UIColor *)MCTBlueColor;
+ (UIColor *)MCTHomeScreenBackgroundColor;
+ (UIColor *)MCTHomeScreenTextColor;
+ (UIColor *)MCPriorityHighBackgroundColor;
+ (UIColor *)MCPriorityHighTextColor;
+ (UIColor *)MCPriorityUrgentBackgroundColor;
+ (UIColor *)MCPriorityUrgentTextColor;
+ (UIColor *)colorWithString:(NSString *)colorString;
+ (UIColor *)colorWithString:(NSString *)colorString alpha:(CGFloat)alpha;

@end


@interface UIWebView (MCTCategory)

- (void)setBounces:(BOOL)bounces;
- (void)loadBrandingResult:(MCTBrandingResult *)br;

@end

@interface WKWebView (Branding)

- (void)loadBrandingResult:(MCTBrandingResult *)br;

@end

@interface UIImage (MCTResizing)

- (UIImage *)imageByScalingForSize:(CGSize)targetSize;
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end


@interface MCTUIUtils : NSObject

+ (void)addRoundedBorderToView:(UIView *)view;
+ (void)addRoundedBorderToView:(UIView *)view withBorderColor:(UIColor *)color andCornerRadius:(CGFloat)radius;
+ (void)addShadowToView:(UIView *)view;
+ (void)addShadowToView:(UIView *)view withOffset:(CGSize)offset;
+ (void)addShadowToView:(UIView *)view withColor:(UIColor *)color andOffset:(CGSize)offset;

+ (void)addGradientToView:(UIView *)view withColors:(NSArray *)colors;
+ (void)removeGradientFromView:(UIView *)view;
+ (void)setBackgroundPlainToView:(UIView *)view;
+ (void)setBackgroundStripesToView:(UIView *)view;


+ (CGSize)keyboardSizeWithNotification:(NSNotification *)notification;
+ (CGSize)sizeForLabel:(UILabel *)label withWidth:(CGFloat)width;
+ (CGSize)sizeForLabel:(UILabel *)label;
+ (CGSize)sizeForTextView:(UITextView *)textView withWidth:(CGFloat)width;
+ (CGSize)sizeForTTButton:(TTButton *)ttBtn constrainedToSize:(CGSize)size;
+ (CGSize)availableSizeForViewWithController:(UIViewController *)vc;
+ (CGFloat)heightForCell:(UITableViewCell *)cell;
+ (BOOL)bottomAlignLabel:(UILabel *)label;
+ (BOOL)topAlignLabel:(UILabel *)label;

+ (TTButton *)replaceUIButtonWithTTButton:(UIButton *)uiBtn;
+ (TTButton *)replaceUIButtonWithTTButton:(UIButton *)uiBtn
                                    style:(NSString *)styleName;

+ (UIActionSheet *)showActivityActionSheetWithTitle:(NSString *)title inViewController:(UIViewController *)vc;
+ (UIActionSheet *)showProgressActionSheetWithTitle:(NSString *)title inViewController:(UIViewController *)vc;
+ (UIProgressView *)addProgressViewToActionSheet:(UIActionSheet *)actionSheet;
+ (void)showActionSheet:(UIActionSheet *)actionSheet inViewController:(UIViewController *)vc;

+ (UIAlertView *)showAlertWithTitle:(NSString *)title
                            andText:(NSString *)text
               andCancelButtonTitle:(NSString *)cancel
                             andTag:(NSInteger)tag;
+ (UIAlertView *)showAlertWithTitle:(NSString *)title andText:(NSString *)text andTag:(int)tag;
+ (UIAlertView *)showAlertWithTitle:(NSString *)title andText:(NSString *)text;
+ (UIAlertView *)showErrorAlertWithText:(NSString *)text;
+ (UIAlertView *)showErrorPleaseRetryAlert;
+ (UIAlertView *)showNetworkErrorAlert;
+ (UIAlertView *)showAlertWithFacebookError:(NSError *)error andSessionState:(FBSessionState)state;
+ (UIAlertView *)showAlertWithFacebookErrorIntent:(MCTIntent *)intent;
+ (UIAlertView *)showAlertViewForPhoneNumber:(NSString *)phoneNumber
                                withDelegate:(NSObject<UIAlertViewDelegate> *)delegate
                                      andTag:(NSInteger)tag;
+ (UIAlertView *)showAlertViewForPhoneNumber:(NSString *)phoneNumber
                                withDelegate:(NSObject<UIAlertViewDelegate> *)delegate
                                  andMessage:(NSString *)message
                                      andTag:(NSInteger)tag;

+ (void)compressImage:(UIImage *)image
             withSize:(NSInteger)imageSize
            toMaxSize:(NSInteger)maxSizeInBytes
     inViewController:(MCTUIViewController *)vc
           completion:(void (^)(UIImage *resizedImage))completionBlock;

+ (UIImage *)imageByRotatingImage:(UIImage*)initImage;

+ (void)createMP4VideoForVideoWithURL:(NSURL *)videoURL
                                toURL:(NSURL *)outputURL
                    completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;
+ (UIImage *)createThumbnailForVideoWithURL:(NSURL *)videoURL
                                contentType:(NSString *)contentType;
+ (UIImage *)createThumbnailWithSize:(CGSize)destinationSize
                            forImage:(UIImage *)originalImage;

// Resize a UIImageView and keep the image ratio
+ (void)resizeImageView:(UIImageView *)imageView withAllowShrinking:(BOOL)allowShrinking;

+ (void)forcePortrait;

+ (UIView *)superViewWithClass:(Class)cls forView:(UIView *)view;

@end