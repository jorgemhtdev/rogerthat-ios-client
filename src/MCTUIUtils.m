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
#import "MCTUIUtils.h"

#import "NSStringAdditions.h"
#import "Three20Style.h"
#import "UIImage+Resize.h"

#import <AVFoundation/AVFoundation.h>


@implementation UIColor (MCTCategory)

+ (UIColor *)MCTDarkBlueColor
{
    return [UIColor colorWithString:@"#003058"];
}

+ (UIColor *)MCTBeigeColor
{
    return [UIColor colorWithRed:1 green:1 blue:0.8 alpha:1];
}

+ (UIColor *)MCTNavigationBarColor
{
    return nil; // Default
}

+ (UIColor *)MCTSectionBackgroundColor
{
    return [UIColor colorWithString:@"#116895"];
}

+ (UIColor *)MCTSelectedCellTextColor
{
    return [UIColor colorWithString:@"#116895"];
}

+ (UIColor *)MCTSeparatorColor
{
    return [UIColor colorWithString:@"#cccccc"];
}

+ (UIColor *)MCTMercuryColor
{
    return [UIColor colorWithString:@"#e6e6e6"];
}

+ (UIColor *)MCTGreenColor
{
    return [UIColor colorWithString:@"#a4c14d"];
}

+ (UIColor *)MCTRedColor
{
    return [UIColor colorWithString:@"#d11e19"];
}

+ (UIColor *)MCTBlackColor
{
    return [UIColor colorWithString:@"#3e3e3d"];
}

+ (UIColor *)MCTBlueColor
{
    return [UIColor colorWithString:@"#263552"];
}

+ (UIColor *)MCTHomeScreenBackgroundColor
{
    return [UIColor colorWithString:MCT_APP_HOMESCREEN_BACKGROUND_COLOR];
}

+ (UIColor *)MCTHomeScreenTextColor
{
    return [UIColor colorWithString:MCT_APP_HOMESCREEN_TEXT_COLOR];
}

+ (UIColor *)MCTAppPrimaryColor
{
    return [UIColor colorWithString:MCT_APP_PRIMARY_COLOR];
}

+ (UIColor *)MCTAppSecondaryColor
{
    return [UIColor colorWithString:MCT_APP_SECONDARY_COLOR];
}

+ (UIColor *)MCPriorityHighBackgroundColor
{
    return [UIColor colorWithString:@"#77CEDE"];
}

+ (UIColor *)MCPriorityHighTextColor
{
    return [UIColor colorWithString:@"#FFFFFF"];
}

+ (UIColor *)MCPriorityUrgentBackgroundColor
{
    return [UIColor colorWithString:@"#FF8481"];
}

+ (UIColor *)MCPriorityUrgentTextColor
{
    return [UIColor colorWithString:@"#FFFFFF"];
}

+ (UIColor *)colorWithString:(NSString *)colorString
{
    return [UIColor colorWithString:colorString alpha:1.0];
}

+ (UIColor *)colorWithString:(NSString *)colorString alpha:(CGFloat)alpha
{
    unsigned int c;
    if ([colorString characterAtIndex:0] == '#')
        colorString = [colorString substringFromIndex:1];

    if ([colorString length] == 3) {
        colorString = [NSString stringWithFormat:@"%1$c%1$c%2$c%2$c%3$c%3$c", [colorString characterAtIndex:0],
                       [colorString characterAtIndex:1], [colorString characterAtIndex:2]];
    }

    [[NSScanner scannerWithString:colorString] scanHexInt:&c];
    return [UIColor colorWithRed:((c & 0xff0000) >> 16)/255.0
                           green:((c & 0x00ff00) >> 8)/255.0
                            blue:(c & 0x0000ff)/255.0
                           alpha:alpha];
}

@end


#pragma mark -

@implementation UIWebView (MCTCategory)

- (void)setBounces:(BOOL)bounces
{
    T_UI();
    for (UIView *subview in self.subviews)
        if ([subview isKindOfClass:[UIScrollView class]])
            ((UIScrollView *) subview).bounces = bounces;
}

- (void)loadBrandingResult:(MCTBrandingResult *)br
{
    T_UI();
    NSString *urlString = [NSString stringWithFormat:@"file://%@", br.file];
    NSURL *baseURL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSString *html = [NSString stringWithContentsOfFile:br.file encoding:NSUTF8StringEncoding error:nil];
    [self loadHTMLString:html baseURL:baseURL];
}

@end

#pragma mark -

@implementation WKWebView (Branding)

- (void)loadBrandingResult:(MCTBrandingResult *)br
{
    T_UI();
    NSString *urlString = [NSString stringWithFormat:@"file://%@", br.file];
    NSString *rootUrlString = [NSString stringWithFormat:@"file://%@", br.rootDir];
    NSURL *baseURL = [NSURL URLWithString:[[rootUrlString stringByDeletingLastPathComponent] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    [self loadFileURL:[NSURL URLWithString:urlString] allowingReadAccessToURL:baseURL];
}

@end


#pragma mark -

@implementation UIImage (MCTResizing)

- (UIImage *)imageByScalingForSize:(CGSize)targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    // code snippet from http://stackoverflow.com/questions/603907/uiimage-resize-then-crop
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }

        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;

        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }

    UIGraphicsBeginImageContext(targetSize); // this will crop

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;

    [sourceImage drawInRect:thumbnailRect];

    newImage = UIGraphicsGetImageFromCurrentImageContext();

    if(newImage == nil)
    {
        LOG(@"could not scale image");
    }

    //pop the context to get back to the default
    UIGraphicsEndImageContext();

    return newImage;
}

@end


#pragma mark -

@interface MCTStyleSheet : TTDefaultStyleSheet
- (TTStyle *)baseButtonStyle;
- (TTStyle *)nextButtonStyle;
- (TTStyle *)updateStyle:(TTStyle *)style withFontSize:(int)fontSize;
- (TTStyle *)updateStyle:(TTStyle *)style withTextColor:(UIColor *)textColor;
- (TTStyle *)updateStyle:(TTStyle *)style withPadding:(UIEdgeInsets)padding;
- (TTStyle *)updateStyle:(TTStyle *)style withBorderColor:(UIColor *)borderColor;
@end

@implementation MCTStyleSheet

- (TTStyle *)baseButtonStyle
{
    return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:nil];
}

- (TTStyle *)nextButtonStyle
{
    return [TTSolidBorderStyle styleWithColor:RGBACOLOR(0, 0, 0, 0.8) width:1 next:
            [TTShadowStyle styleWithColor:RGBACOLOR(255, 255, 255, 0) blur:1 offset:CGSizeMake(0, 1) next:
             [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(2, 8, 2, 8) next:
              [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]+1]
                                   color:[UIColor whiteColor]
                         minimumFontSize:[UIFont systemFontSize]
                             shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
                            shadowOffset:CGSizeZero
                           textAlignment:NSTextAlignmentCenter
                       verticalAlignment:UIControlContentVerticalAlignmentCenter
                           lineBreakMode:NSLineBreakByWordWrapping
                           numberOfLines:6
                                    next:nil]]]];
}

- (TTStyle *)updateStyle:(TTStyle *)style withFontSize:(int)fontSize
{
    TTTextStyle *textStyle = [style firstStyleOfClass:[TTTextStyle class]];
    textStyle.font = [UIFont boldSystemFontOfSize:fontSize];
    textStyle.minimumFontSize = MIN(textStyle.minimumFontSize, fontSize);
    return style;
}

- (TTStyle *)updateStyle:(TTStyle *)style withTextColor:(UIColor *)textColor
{
    TTTextStyle *textStyle = [style firstStyleOfClass:[TTTextStyle class]];
    textStyle.color = textColor;
    return style;
}

- (TTStyle *)updateStyle:(TTStyle *)style withPadding:(UIEdgeInsets)padding
{
    TTBoxStyle *boxStyle = [style firstStyleOfClass:[TTBoxStyle class]];
    boxStyle.padding = padding;
    return style;
}

- (TTStyle *)updateStyle:(TTStyle *)style withBorderColor:(UIColor *)borderColor
{
    TTSolidBorderStyle *borderStyle = [style firstStyleOfClass:[TTSolidBorderStyle class]];
    borderStyle.color = borderColor;
    return style;
}

- (TTStyle *)embossedButtonWithSmallFontSize:(UIControlState)state
{
    TTStyle *style = [self updateStyle:[self embossedButton:state] withFontSize:12];
    TTTextStyle *textStyle = (TTTextStyle *) [style firstStyleOfClass:[TTTextStyle class]];
    textStyle.minimumFontSize = 10;
    textStyle.numberOfLines = 1;
    textStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    return [self updateStyle:style withPadding:UIEdgeInsetsMake(2, 4, 2, 4)];
}

- (TTStyle *)multilineEmbossedButtonWithSmallFontSize:(UIControlState)state
{
    TTStyle *style = [self updateStyle:[self embossedButton:state] withFontSize:12];
    return [self updateStyle:style withPadding:UIEdgeInsetsMake(2, 4, 2, 4)];
}

- (TTStyle *)dismissButtonWithSmallFontSize:(UIControlState)state
{
    TTStyle *style = [self updateStyle:[self dismissButton:state] withFontSize:13];
    return [self updateStyle:style withPadding:UIEdgeInsetsMake(2, 4, 0, 4)];
}

- (TTStyle *)magicButtonWithSmallFontSize:(UIControlState)state
{
    TTStyle *style = [self updateStyle:[self magicButton:state] withFontSize:13];
    if (state == UIControlStateSelected) {
        [self updateStyle:style withTextColor:[UIColor yellowColor]];
    }
    return [self updateStyle:style withPadding:UIEdgeInsetsMake(2, 4, 0, 4)];
}

- (TTStyle *)dismissButton:(UIControlState)state
{
    TTStyle *style = [self baseButtonStyle];
    if (state == UIControlStateNormal) {
        style.next = [TTLinearGradientFillStyle styleWithColor1:[UIColor colorWithString:@"00BF60"]
                                                         color2:[UIColor colorWithString:@"006633"]
                                                           next:[self nextButtonStyle]];
    } else if (state == UIControlStateHighlighted) {
        style.next = [TTLinearGradientFillStyle styleWithColor1:[UIColor colorWithString:@"009933"]
                                                         color2:[UIColor colorWithString:@"004411"]
                                                           next:[self nextButtonStyle]];
    } else if (state == UIControlStateDisabled) {
        style.next = [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(255, 255, 255)
                                                         color2:RGBCOLOR(231, 231, 231)
                                                           next:[self nextButtonStyle]];
        [self updateStyle:style withTextColor:[UIColor lightGrayColor]];
        [self updateStyle:style withBorderColor:RGBCOLOR(161, 167, 178)];
    } else {
        return nil;
    }
    return style;
}

- (TTStyle *)magicButton:(UIControlState)state
{
    TTStyle *style = [self baseButtonStyle];
    if (state == UIControlStateNormal) {
        style.next = [TTLinearGradientFillStyle styleWithColor1:[UIColor colorWithString:@"6DB6F2"]
                                                         color2:[UIColor colorWithString:@"336699"]
                                                           next:[self nextButtonStyle]];
    } else if (state == UIControlStateHighlighted) {
        style.next = [TTLinearGradientFillStyle styleWithColor1:[UIColor colorWithString:@"4477AA"]
                                                         color2:[UIColor colorWithString:@"225588"]
                                                           next:[self nextButtonStyle]];
    } else if (state == UIControlStateDisabled) {
        style.next = [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(255, 255, 255)
                                                         color2:RGBCOLOR(231, 231, 231)
                                                           next:[self nextButtonStyle]];
        [self updateStyle:style withTextColor:[UIColor lightGrayColor]];
        [self updateStyle:style withBorderColor:RGBCOLOR(161, 167, 178)];

    } else {
        return nil;
    }
    return style;
}

- (TTStyle *)positiveButton:(UIControlState)state
{
    return [self dismissButton:state];
}

- (TTStyle *)negativeButton:(UIControlState)state
{
    TTStyle *style = [self baseButtonStyle];
    if (state == UIControlStateNormal) {
        style.next = [TTLinearGradientFillStyle styleWithColor1:[UIColor colorWithString:@"EE3300"]
                                                         color2:[UIColor colorWithString:@"993300"]
                                                           next:[self nextButtonStyle]];
    } else if (state == UIControlStateHighlighted) {
        style.next = [TTLinearGradientFillStyle styleWithColor1:[UIColor colorWithString:@"993300"]
                                                         color2:[UIColor colorWithString:@"663300"]
                                                           next:[self nextButtonStyle]];
    } else if (state == UIControlStateDisabled) {
        style.next = [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(255, 255, 255)
                                                         color2:RGBCOLOR(231, 231, 231)
                                                           next:[self nextButtonStyle]];
        [self updateStyle:style withTextColor:[UIColor lightGrayColor]];
        [self updateStyle:style withBorderColor:RGBCOLOR(161, 167, 178)];

    } else {
        return nil;
    }
    return style;
}

- (TTStyle *)embossedButton:(UIControlState)state
{
    UIColor *shadowColor;
    UIColor *color1;
    UIColor *color2;
    UIColor *textColor;
    switch (state) {
        case UIControlStateHighlighted:
        {
            shadowColor = RGBACOLOR(255,255,255,0.9);
            color1 = RGBCOLOR(225, 225, 225);
            color2 = RGBCOLOR(196, 201, 221);
            textColor = [UIColor whiteColor];
            break;
        }
        case UIControlStateDisabled:
        {
            shadowColor = RGBACOLOR(255,255,255,0);
            color1 = RGBCOLOR(255, 255, 255);
            color2 = RGBCOLOR(231, 231, 231);
            textColor = [UIColor lightGrayColor];
            break;
        }
        case UIControlStateNormal:
        default:
        {
            shadowColor = RGBACOLOR(255,255,255,0);
            color1 = RGBCOLOR(255, 255, 255);
            color2 = RGBCOLOR(216, 221, 231);
            textColor = TTSTYLEVAR(linkTextColor);
            break;
        }
    }
    return
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
     [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
      [TTShadowStyle styleWithColor:shadowColor blur:1 offset:CGSizeMake(0, 1) next:
       [TTLinearGradientFillStyle styleWithColor1:color1
                                           color2:color2
                                             next:
        [TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
         [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(6, 8, 8, 8) next:
          [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]+1]
                               color:textColor
                     minimumFontSize:[UIFont systemFontSize]
                         shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
                        shadowOffset:CGSizeMake(0, -1)
                       textAlignment:NSTextAlignmentCenter
                   verticalAlignment:UIControlContentVerticalAlignmentCenter
                       lineBreakMode:NSLineBreakByWordWrapping
                       numberOfLines:6
                                next:nil]]]]]]];
}

- (TTStyle *)darkGrayToolbarButton:(UIControlState)state
{
    TTShape *shape = [TTRoundedRectangleShape shapeWithRadius:4.5];
    UIColor *tintColor = RGBCOLOR(33, 33, 33);
    return [TTSTYLESHEET toolbarButtonForState:state shape:shape tintColor:tintColor font:nil];
}

- (TTStyle *)pageControlWithDarkColorScheme:(UIControlState)state
{
    if (state == UIControlStateSelected) {
        return [self pageDotWithColor:[UIColor whiteColor]];
    } else {
        return [self pageDotWithColor:RGBCOLOR(77, 77, 77)];
    }
}

- (TTStyle *)pageControlWithLightColorScheme:(UIControlState)state
{
    if (state != UIControlStateSelected) {
        return [self pageDotWithColor:[UIColor lightGrayColor]];
    } else {
        return [self pageDotWithColor:RGBCOLOR(51, 51, 51)];
    }
}

- (TTStyle *)pageDotWithColor:(UIColor*)color {
    return
    [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(0,0,0,10) padding:UIEdgeInsetsMake(6,6,0,0) next:
     [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:2.5] next:
      [TTSolidFillStyle styleWithColor:color next:nil]]];
}

@end


#pragma mark -

@implementation MCTUIUtils

+ (void)initialize
{
    T_UI();
    [TTStyleSheet setGlobalStyleSheet:[[MCTStyleSheet alloc] init]];
}

+ (void)addRoundedBorderToView:(UIView *)view
{
    T_UI();
    [MCTUIUtils addRoundedBorderToView:view withBorderColor:[UIColor blackColor] andCornerRadius:5];
}

+ (void)addRoundedBorderToView:(UIView *)view withBorderColor:(UIColor *)color andCornerRadius:(CGFloat)radius
{
    T_UI();
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = radius;
    view.layer.borderColor = [color CGColor];
    view.layer.borderWidth = 1;
}

+ (void)addShadowToView:(UIView *)view
{
    T_UI();
    [MCTUIUtils addShadowToView:view withOffset:CGSizeMake(1.0f, 1.0f)];
}

+ (void)addShadowToView:(UIView *)view withOffset:(CGSize)offset
{
    T_UI();
    [MCTUIUtils addShadowToView:view withColor:[UIColor blackColor] andOffset:offset];
}

+ (void)addShadowToView:(UIView *)view withColor:(UIColor *)color andOffset:(CGSize)offset
{
    if (view.clipsToBounds) {
        ERROR(@"Shadow will not be visible since the view's clipsToBounds is YES. Set it to NO.");
    }
    view.layer.shadowColor = [color CGColor];
    view.layer.shadowOffset = offset;
    view.layer.shadowOpacity = 0.5f;
    view.layer.shadowRadius = 3.0f;
}

+ (void)setBackgroundPlainToView:(UIView *)view
{
    view.backgroundColor = [UIColor whiteColor];
}

+ (void)setBackgroundStripesToView:(UIView *)view
{
    view.backgroundColor = [UIColor MCTMercuryColor];
}

+ (void)addGradientToView:(UIView *)view withColors:(NSArray *)colors
{
    T_UI();
    CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
    gradient.frame = view.bounds;
    gradient.colors = colors;
    [view.layer insertSublayer:gradient atIndex:0];
}

+ (void)removeGradientFromView:(UIView *)view
{
    T_UI();
    for (CALayer *layer in [view.layer.sublayers reverseObjectEnumerator])
        if ([layer isKindOfClass:[CAGradientLayer class]])
            [layer removeFromSuperlayer];
}

+ (CGSize)keyboardSizeWithNotification:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    return [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

+ (CGSize)sizeForLabel:(UILabel *)label withWidth:(CGFloat)width
{
    T_UI();
    CGSize size = [label sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];

    return size;
}

+ (CGSize)sizeForLabel:(UILabel *)label
{
    T_UI();
    return [MCTUIUtils sizeForLabel:label withWidth:label.frame.size.width];
}

+ (CGSize)sizeForTextView:(UITextView *)textView withWidth:(CGFloat)width
{
    T_UI();

    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = textView.font;
    gettingSizeLabel.text = textView.text;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByClipping;

    CGSize size = [gettingSizeLabel sizeThatFits:CGSizeMake(width - 16, CGFLOAT_MAX)];

    return CGSizeMake(size.width + 16, size.height + 16);
}

+ (CGSize)sizeForTTButton:(TTButton *)ttBtn constrainedToSize:(CGSize)size
{
    T_UI();
    TTTextStyle *ttStyle = [[ttBtn styleForState:UIControlStateNormal] firstStyleOfClass:[TTTextStyle class]];
    UIFont *font = ttStyle ? ttStyle.font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    NSLineBreakMode lineBreakMode = ttStyle ? ttStyle.lineBreakMode : NSLineBreakByTruncatingTail;

    TTBoxStyle *ttBoxStyle = [[ttBtn styleForState:UIControlStateNormal] firstStyleOfClass:[TTBoxStyle class]];
    CGFloat padding = 2 + (ttBoxStyle ? ttBoxStyle.padding.left + ttBoxStyle.padding.right : 0);

    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = font;
    gettingSizeLabel.text = [ttBtn titleForState:UIControlStateNormal];
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = lineBreakMode;

    CGSize capSize = [gettingSizeLabel sizeThatFits:CGSizeMake(size.width - padding, size.height)];

    int m = (int) (capSize.height / 21);
    return CGSizeMake(capSize.width + padding,
                      3 * m + capSize.height + ttBoxStyle.padding.top + ttBoxStyle.padding.bottom);
}

+ (CGSize)availableSizeForViewWithController:(UIViewController *)vc
{
    T_UI();
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGFloat navHeight = vc.navigationController.navigationBar.frame.size.height;
    CGFloat tabHeight = 0;
    if (!vc.hidesBottomBarWhenPushed && !vc.tabBarController.tabBar.hidden)
        tabHeight = vc.tabBarController.tabBar.frame.size.height;
    return CGSizeMake(appFrame.size.width, appFrame.size.height - navHeight - tabHeight);
}

+ (CGFloat)heightForCell:(UITableViewCell *)cell
{
    T_UI();
    CGFloat w = cell.contentView.frame.size.width - 2 * cell.indentationWidth;
    if (cell.accessoryType != UITableViewCellAccessoryNone)
        w -= 29;

    CGSize titleSize = [MCTUIUtils sizeForLabel:cell.detailTextLabel withWidth:w];
    CGSize descrSize = [MCTUIUtils sizeForLabel:cell.textLabel withWidth:w];
    return fmax(44, titleSize.height + descrSize.height + 2 * cell.indentationWidth);
}

+ (BOOL)bottomAlignLabel:(UILabel *)label
{
    T_UI();
    CGRect frame = label.frame;
    CGSize size = [MCTUIUtils sizeForLabel:label];
    if (size.height > frame.size.height) {
        return NO;
    }

    frame.origin.y = frame.origin.y + frame.size.height - size.height;
    frame.size.height = size.height;
    label.frame = frame;
    return YES;
}

+ (BOOL)topAlignLabel:(UILabel *)label
{
    T_UI();
    CGSize size = [MCTUIUtils sizeForLabel:label];
    if (size.height > label.height) {
        return NO;
    }

    label.height = size.height;
    return YES;
}

#pragma mark -

+ (TTButton *)replaceUIButtonWithTTButton:(UIButton *)uiBtn
{
    T_UI();
    return [MCTUIUtils replaceUIButtonWithTTButton:uiBtn style:MCT_STYLE_EMBOSSED_BUTTON];
}

+ (TTButton *)replaceUIButtonWithTTButton:(UIButton *)uiBtn
                                    style:(NSString *)styleName
{
    T_UI();
    TTButton *ttBtn = [TTButton buttonWithStyle:styleName
                                          title:[uiBtn titleForState:UIControlStateNormal]];
    // Copy targets & actions for all touch events
    for (id target in [uiBtn allTargets]) {
        if ([target isKindOfClass:[NSNull class]])
            continue;

        UIControlEvents event = 0;
        for (int e = 0; event < UIControlEventAllTouchEvents; e++) {
            event = pow(2, e);
            for (NSString *selectorName in [uiBtn actionsForTarget:target forControlEvent:event]) {
                [ttBtn addTarget:target action:NSSelectorFromString(selectorName) forControlEvents:event];
            }
        }
    }

    ttBtn.autoresizingMask = uiBtn.autoresizingMask;
    ttBtn.enabled = uiBtn.enabled;
    ttBtn.frame = uiBtn.frame;
    ttBtn.hidden = uiBtn.hidden;
    ttBtn.height += 5;
    [uiBtn.superview insertSubview:ttBtn atIndex:[uiBtn.superview.subviews indexOfObject:uiBtn]];
    [uiBtn removeFromSuperview];

    return ttBtn;
}

#pragma mark -

+ (UIActionSheet *)showActivityActionSheetWithTitle:(NSString *)title inViewController:(UIViewController *)vc
{
    T_UI();
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                              delegate:nil
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:nil];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(150, 40, 20, 20);
    spinner.tag = 1;
    [spinner startAnimating];

    [actionSheet addSubview:spinner];

    [MCTUIUtils showActionSheet:actionSheet inViewController:vc];
    actionSheet.bounds = CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, 90);
    return actionSheet;
}

+ (UIActionSheet *)showProgressActionSheetWithTitle:(NSString *)title inViewController:(UIViewController *)vc
{
    T_UI();
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                              delegate:nil
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:nil];

    [MCTUIUtils addProgressViewToActionSheet:actionSheet];
    [MCTUIUtils showActionSheet:actionSheet inViewController:vc];
    actionSheet.bounds = CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, 65);
    return actionSheet;
}

+ (UIProgressView *)addProgressViewToActionSheet:(UIActionSheet *)actionSheet
{
    T_UI();
    CGFloat w = [UIScreen mainScreen].applicationFrame.size.width;
    UIProgressView *progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progress.tag = 1;
    progress.center = CGPointMake(w / 2, 65 - 20 - progress.frame.size.height / 2);
    [actionSheet addSubview:progress];
    return progress;
}

+ (void)showActionSheet:(UIActionSheet *)actionSheet inViewController:(UIViewController *)vc
{
    T_UI();
    UITabBar *tabBar = vc.tabBarController.tabBar;
    if (tabBar) {
        [actionSheet showFromTabBar:tabBar];
    } else {
        [actionSheet showInView:vc.view];
    }
}

+ (UIAlertView *)showAlertWithTitle:(NSString *)title andText:(NSString *)text
{
    T_UI();
    return [MCTUIUtils showAlertWithTitle:title andText:text andTag:0];
}

+ (UIAlertView *)showAlertWithTitle:(NSString *)title andText:(NSString *)text andTag:(int)tag
{
    T_UI();
    return [MCTUIUtils showAlertWithTitle:title
                                  andText:text
                     andCancelButtonTitle:NSLocalizedString(@"Roger that", nil)
                                   andTag:tag];
}

+ (UIAlertView *)showAlertWithTitle:(NSString *)title
                            andText:(NSString *)text
               andCancelButtonTitle:(NSString *)cancel
                             andTag:(NSInteger)tag
{
    T_UI();
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:text
                                                    delegate:nil
                                           cancelButtonTitle:cancel
                                           otherButtonTitles:nil];
    alert.tag = tag;
    [alert show];
    return alert;
}

+ (UIAlertView *)showErrorAlertWithText:(NSString *)text
{
    T_UI();
    return [MCTUIUtils showAlertWithTitle:NSLocalizedString(@"Error", nil) andText:text];
}

+ (UIAlertView *)showErrorPleaseRetryAlert
{
    T_UI();
    return [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"An error occurred. Please try again.", nil)];
}

+ (UIAlertView *)showNetworkErrorAlert
{
    T_UI();
    return [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"You are not connected to the internet. Please check your network configuration and try again.", nil)];
}

+ (UIAlertView *)showAlertWithFacebookError:(NSError *)error andSessionState:(FBSessionState)state
{
    T_UI();
    if (error) {
        LOG(@"Facebook error: %@", error);
        if (error.fberrorShouldNotifyUser ||
            error.fberrorCategory == FBErrorCategoryPermissions ||
            error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {

            [MCTUIUtils showAlertWithTitle:nil andText:error.fberrorUserMessage];
        } else {
            [MCTUIUtils showErrorPleaseRetryAlert];
        }
    } else {
        LOG(@"Facebook session state: %d", state);
        [MCTUIUtils showErrorPleaseRetryAlert];
    }
}

+ (UIAlertView *)showAlertWithFacebookErrorIntent:(MCTIntent *)intent
{
    T_UI();
    if ([intent boolForKey:@"error"]) {
        LOG(@"Facebook error intent: %@", intent);
        if ([intent hasStringKey:@"fberrorUserMessage"] && ([intent boolForKey:@"fberrorShouldNotifyUser"] ||
            [intent longForKey:@"fberrorCategory"] == FBErrorCategoryPermissions ||
            [intent longForKey:@"fberrorCategory"] == FBErrorCategoryAuthenticationReopenSession)) {

            [MCTUIUtils showAlertWithTitle:nil andText:[intent stringForKey:@"fberrorUserMessage"]];
        } else {
            [MCTUIUtils showErrorPleaseRetryAlert];
        }
    } else {
        ERROR(@"There is no error in this facebookErrorIntent: %@", intent);
    }
}

+ (UIAlertView *)showAlertViewForPhoneNumber:(NSString *)phoneNumber
                                withDelegate:(NSObject<UIAlertViewDelegate> *)delegate
                                  andMessage:(NSString *)message
                                      andTag:(NSInteger)tag
{
    T_UI();
    UIAlertView *alertView;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",
                                       [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""]]];
    NSString *title = NSLocalizedString(@"Phone call", nil);
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        alertView = [[UIAlertView alloc] initWithTitle:title
                                                message:message
                                               delegate:delegate
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                      otherButtonTitles:NSLocalizedString(@"Call", nil), nil];
        alertView.tag = tag;
        [alertView show];
    } else {
        alertView = [MCTUIUtils showAlertWithTitle:title
                                           andText:message
                              andCancelButtonTitle:NSLocalizedString(@"Close", nil)
                                            andTag:tag];
        alertView.delegate = delegate;
    }
    return alertView;
}


+ (UIAlertView *)showAlertViewForPhoneNumber:(NSString *)phoneNumber
                                withDelegate:(NSObject<UIAlertViewDelegate> *)delegate
                                      andTag:(NSInteger)tag
{
    T_UI();
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Call %@", nil), phoneNumber];
    return [MCTUIUtils showAlertViewForPhoneNumber:phoneNumber
                                      withDelegate:delegate
                                        andMessage:message
                                            andTag:tag];
}

+ (void)compressImage:(UIImage *)image
             withSize:(NSInteger)imageSize
            toMaxSize:(NSInteger)maxSizeInBytes
     inViewController:(MCTUIViewController *)vc
           completion:(void (^)(UIImage *resizedImage))completionBlock
{
    T_UI();
    UIView *view = vc.navigationController ? vc.navigationController.view : vc.view;
    vc.currentProgressHUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:vc.currentProgressHUD];
    vc.currentProgressHUD.labelText = NSLocalizedString(@"Compressing, please wait…", nil);
    vc.currentProgressHUD.mode = MBProgressHUDModeIndeterminate;
    vc.currentProgressHUD.dimBackground = YES;
    [vc.currentProgressHUD show:YES];

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        UIImage *resizedImage = image;
        NSInteger size = imageSize;
        NSInteger previousImageSize;

        while (size > maxSizeInBytes) {
            LOG(@"image size %d > max size %d", size, maxSizeInBytes);
            resizedImage = [resizedImage resizedImage:CGSizeMake(resizedImage.size.width * 0.8, resizedImage.size.height * 0.8)
                                 interpolationQuality:kCGInterpolationMedium];

            previousImageSize = size;
            size = [UIImageJPEGRepresentation(resizedImage, 0) length];

            if (size >= previousImageSize) {
                LOG(@"Could not reduce the image size any further");
                break;
            }
        }
        LOG(@"image size %d <= max size %d", size, maxSizeInBytes);

        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(resizedImage);
            [vc.currentProgressHUD hide:YES];
            MCT_RELEASE(vc.currentProgressHUD);
        });
    }];
}

+ (UIImage *)imageByRotatingImage:(UIImage*)initImage
{
    CGImageRef imgRef = initImage.CGImage;

    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);

    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat boundHeight;

    switch (initImage.imageOrientation) {
        case UIImageOrientationDown: { // EXIF = 3
            transform = CGAffineTransformMakeTranslation(0, 0);
            transform = CGAffineTransformRotate(transform, 2 * M_PI);
            break;
        }
        case UIImageOrientationLeft: { // EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        }
        case UIImageOrientationRight: { // EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        }
        case UIImageOrientationUp: // EXIF = 1
        default:
            return initImage;
    }

    // Create the bitmap context
    CGContextRef    context = NULL;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;

    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (bounds.size.width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * bounds.size.height);
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL) {
        return nil;
    }

    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    CGColorSpaceRef colorspace = CGImageGetColorSpace(imgRef);
    context = CGBitmapContextCreate (bitmapData,bounds.size.width,bounds.size.height,8,bitmapBytesPerRow,
                                     colorspace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);

    if (context == NULL)
        // error creating context
        return nil;

    CGContextScaleCTM(context, -1.0, -1.0);
    CGContextTranslateCTM(context, -bounds.size.width, -bounds.size.height);

    CGContextConcatCTM(context, transform);

    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(context, CGRectMake(0,0,width, height), imgRef);

    CGImageRef imgRef2 = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    free(bitmapData);
    UIImage * image = [UIImage imageWithCGImage:imgRef2 scale:initImage.scale orientation:UIImageOrientationUp];
    CGImageRelease(imgRef2);
    return image;
}

+ (void)createMP4VideoForVideoWithURL:(NSURL *)videoURL
                                toURL:(NSURL *)outputURL
                    completionHandler:(void (^)(BOOL success, NSError *error))completionHandler
{
    AVAsset *video = [AVAsset assetWithURL:videoURL];
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:video
                                                                            presetName:AVAssetExportPresetMediumQuality];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.outputURL = outputURL;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        completionHandler(exportSession.status != AVAssetExportSessionStatusCompleted, exportSession.error);
    }];
}

+ (UIImage *)createThumbnailForVideoWithURL:(NSURL *)videoURL
                                contentType:(NSString *)contentType
{
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;

    CMTime time = [asset duration];
    time.value = 0;

    NSError *error = nil;
    CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:NULL error:&error];
    UIImage *thumbnail;
    if (error) {
        LOG(@"couldn't generate thumbnail, error: %@", error);
        thumbnail = [UIImage imageNamed:@"attachment_video.png"];
    } else {
        thumbnail = [UIImage imageWithCGImage:imageRef];
    }
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC

    return thumbnail;
}

+ (UIImage *)createThumbnailWithSize:(CGSize)destinationSize
                            forImage:(UIImage *)originalImage
{
    CGSize imageSize = originalImage.size;
    if (imageSize.width > imageSize.height) {
        // imageView height should shrink
        destinationSize.height = destinationSize.width * imageSize.height / imageSize.width;
    } else if (imageSize.width < imageSize.height) {
        // imageView width should shrink
        destinationSize.width = destinationSize.height * imageSize.width / imageSize.height;
    }

    UIGraphicsBeginImageContext(destinationSize);
    [originalImage drawInRect:CGRectMake(0, 0, destinationSize.width, destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)resizeImageView:(UIImageView *)imageView withAllowShrinking:(BOOL)allowShrinking
{
    CGSize imageSize = imageView.image.size;

    if (allowShrinking && imageSize.width < imageView.width && imageSize.height < imageView.height) {
        imageView.size = imageSize;
    } else if (imageSize.width > imageSize.height) {
        // imageView height should shrink
        imageView.height = imageView.width * imageSize.height / imageSize.width;
    } else if (imageSize.width < imageSize.height) {
        // imageView width should shrink
        imageView.width = imageView.height * imageSize.width / imageSize.height;
    }
}

+ (void)forcePortrait
{
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
}

+ (UIView *)superViewWithClass:(Class)cls forView:(UIView *)view
{
    UIView *v = view.superview;
    while (v && ![v isKindOfClass:cls]) {
        v = v.superview;
    }
    return v;
}


+ (CAGradientLayer *)addGradientToView:(UIView *)view withColors:(NSArray *)colors andRoundedCorners:(BOOL)withRoundedCorners
{
    T_UI();
    CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
    gradient.frame = view.bounds;
    gradient.colors = colors;
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    gradient.cornerRadius = view.layer.cornerRadius;
    if (withRoundedCorners)
    {
        view.layer.cornerRadius = 5;
        view.layer.masksToBounds = YES;
    }

    [view.layer insertSublayer:gradient atIndex:0];
    return gradient;
}

+ (CAGradientLayer *)addGradientToView:(UIView *)view
{
    return [MCTUIUtils addGradientToView:view
                              withColors:@[(id)[UIColor MCTAppPrimaryColor].CGColor,
                                           (id)[UIColor MCTAppSecondaryColor].CGColor]
                       andRoundedCorners: YES ];
}

+ (void)addBackgroundColorToView:(UIView *)view
{
    view.backgroundColor = [UIColor MCTHomeScreenBackgroundColor];

}


@end