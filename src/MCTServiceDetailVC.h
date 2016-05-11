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
#import "MCTFriend.h"
#import "MCTFriendsPlugin.h"
#import "MCTIntentFramework.h"
#import "MCTServiceOwningVC.h"

@interface MCTServiceDetailVC : MCTUIViewController <IMCTIntentReceiver, UIWebViewDelegate, UIAlertViewDelegate, MCTServiceOwningVC>

+ (MCTServiceDetailVC *)viewControllerWithService:(MCTFriend *)service;

@property (nonatomic, strong) MCTFriend *service;
@property (nonatomic, strong) MCTFriendsPlugin *friendsPlugin;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *emailLabel;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, copy) NSString *firstShowAlertText;
@property (nonatomic, strong) MCTBrandingResult *brandingResult;

@end