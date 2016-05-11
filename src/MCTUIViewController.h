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

#import "MBProgressHUD.h"
#import "MCTBrandingMgr.h"

@protocol MCTUIViewControllerProtocol

@required
@property (nonatomic, strong) UIAlertView *currentAlertView;
@property (nonatomic, strong) UIActionSheet *currentActionSheet;
@property (nonatomic, strong) NSObject *activeObject;

@end

@interface MCTUIViewController : UIViewController <MCTUIViewControllerProtocol>

@property (nonatomic, strong) UIAlertController *currentAlertController;
@property (nonatomic, strong) UIAlertView *currentAlertView;
@property (nonatomic, strong) UIActionSheet *currentActionSheet;
@property (nonatomic, strong) NSObject *activeObject;
@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;
@property (nonatomic) UIStatusBarStyle statusBarStyle;
@property (nonatomic, copy) NSString *originalTitle;

- (void)resetNavigationControllerAppearance;
- (void)changeNavigationControllerAppearanceWithBrandingResult:(MCTBrandingResult *)brandingResultOrNil;
- (void)changeNavigationControllerAppearanceWithColorScheme:(MCTColorScheme)colorScheme
                                         andBackGroundColor:(UIColor *)backGroundColor;
- (MCTColorScheme)colorSchemeForBrandingResult:(MCTBrandingResult *)brandingResultOrNil;
- (UIColor *)backGroundColorForBrandingResult:(MCTBrandingResult *)brandingResultOrNil;


@end