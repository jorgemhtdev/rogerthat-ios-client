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

#import "MCTIntentFramework.h"
#import "MCTMessage.h"
#import "MCTWidget.h"


@interface MCTFormView : UIControl <IMCTIntentReceiver>

@property (nonatomic, strong) MCTMessage *message;
@property (nonatomic) MCTColorScheme colorScheme;
@property (nonatomic, strong) IBOutlet UIControl<MCTWidget> *widgetView;
@property (nonatomic, weak) MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *viewController;
@property (nonatomic, strong) IBOutlet TTButton *positiveBtn;
@property (nonatomic, strong) IBOutlet TTButton *negativeBtn;
@property (nonatomic, strong) IBOutlet UIImageView *avatarView;
@property (nonatomic) CGFloat width;

+ (MCTFormView *)viewWithMessage:(MCTMessage *)msg
                        andWidth:(CGFloat)w
                  andColorScheme:(MCTColorScheme)colorScheme
                inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc;
+ (NSString *)valueStringForForm:(NSDictionary *)form;

- (void)refreshView;

- (CGFloat)height;
- (CGFloat)maxWidgetHeight;
- (void)excecuteButtonTapped:(UIControl *)sender andShouldValidateResult:(BOOL)shouldValidateResult;
- (NSString *)positiveButtonText;
- (BOOL)processAlertViewClickedButtonAtIndex:(NSInteger)buttonIndex;
- (BOOL)processActionSheetClickedButtonAtIndex:(NSInteger)buttonIndex;

@end