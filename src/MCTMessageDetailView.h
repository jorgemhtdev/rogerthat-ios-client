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

#import "MCTUIViewController.h"
#import "MCTBrandingMgr.h"
#import "MCTFriendsPlugin.h"
#import "MCTIntentFramework.h"
#import "MCTMessage.h"
#import "MCTMessagesPlugin.h"


@class MCTMessageDetailView;

@interface MCTMessageDetailView : UIControl <IMCTIntentReceiver, UIWebViewDelegate> 

@property (nonatomic, strong) MCTMessage *message;
@property (nonatomic, strong) MCTBrandingResult *brandingResult;
@property (nonatomic, weak) MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *viewController;
@property (nonatomic, copy) NSString *myAnswer;
@property (nonatomic) BOOL detailsExpanded;
@property (nonatomic, strong) UIScrollView *scrollView;

- (MCTMessageDetailView *)initWithFrame:(CGRect)frame
                       inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc
                     withBrandingResult:(MCTBrandingResult *)brandingResult
                             andIsRefresh:(BOOL)isRefresh;

- (void)onShowDetailsTapped;
- (void)unregisterDelegatesAndListeners;

- (void)scrollToBottom;
- (void)scrollUpForBottomViewWithHeight:(CGFloat)h;
- (void)scrollBack;

- (void)processAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)processActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)refreshViewWithIsOtherMessage:(BOOL)isOther;

@end