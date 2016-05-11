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
#import "MCTMessage.h"
#import "MCTMessageDetailView.h"

#import <QuickLook/QuickLook.h>

@interface MCTMessageDetailVC : MCTUIViewController <UIAlertViewDelegate, UIActionSheetDelegate, IMCTIntentReceiver,
MBProgressHUDDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate>

@property(nonatomic, strong) MCTMessage *message;
@property(nonatomic, strong) MCTBrandingResult *brandingResult;
@property(nonatomic, strong) MCTMessageDetailView *detailView;
@property(nonatomic, copy) NSString *messageKey;
@property(nonatomic, strong) NSTimer *expectNextTimer;
@property(nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

+ (MCTMessageDetailVC *)viewControllerWithMessageKey:(NSString *)key;

- (UIActionSheet *)showActionSheetWithTitle:(NSString *)title;

- (void)onAttachmentClickedWithIndex:(NSInteger)index;

- (int)expectNextWithFlags:(MCTlong)uiFlags;
@end