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

#import "MCTMessage.h"
#import "MCTMessagesPlugin.h"
#import "MCTUIViewController.h"

#import "TTView.h"

@interface MCTHumanMessageCell : UITableViewCell

@property BOOL cancelLock;
@property (nonatomic, strong) MCTMessage *message;
@property (nonatomic, weak) MCTUIViewController<UIAlertViewDelegate> *viewController;
@property (nonatomic) BOOL iAmSender;
@property (nonatomic, strong) TTView *bubble;
@property (nonatomic, strong) UILabel *senderLbl;
@property (nonatomic, strong) UITextView *msgTxt;
@property (nonatomic, strong) UIImageView *avaView;
@property (nonatomic, strong) UIImageView *lockView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) TTView *attachmentsView;
@property (nonatomic, strong) TTView *btnView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

+ (CGFloat)heightOfCellWithMessage:(MCTMessage *)msg;
+ (CGSize)sizeOfTTBtnWithButton:(MCT_com_mobicage_to_messaging_ButtonTO *)btn;

@end