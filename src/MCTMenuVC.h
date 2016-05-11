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
#import "MCTMessageFlowRun.h"
#import "MCTUIViewController.h"
#import "MCTProfileVC.h"

#define MCT_MENU_TAB_MESSAGES 0
#define MCT_MENU_TAB_SERVICES 1
#define MCT_MENU_TAB_FRIENDS  2
#define MCT_MENU_TAB_SCAN     3
#define MCT_MENU_TAB_MORE     4

#define MCT_CHANGE_TAB_WITH_ALERT_TITLE @"CHANGE_TAB_ALERT_TITLE"
#define MCT_CHANGE_TAB_WITH_ALERT_MESSAGE  @"CHANGE_TAB_ALERT_MESSAGE"

#define MCT_GOTO_ADD_FRIENDS @"goto/add_friends"
#define MCT_GOTO_ADD_FRIENDS_VIA_ADDRESSBOOK @"goto/add_friends/via_addressbook"
#define MCT_GOTO_ADD_FRIENDS_VIA_FACEBOOK @"goto/add_friends/via_facebook"
#define MCT_GOTO_QR_SCAN @"goto/qr_scan"


@interface MCTMenuVC : MCTUIViewController <UITabBarControllerDelegate, IMCTIntentReceiver, UIAlertViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, copy) NSString *msgLaunchOption;
@property (nonatomic, copy) NSString *ackLaunchOption;
@property (nonatomic) NSInteger updatedMessageCount;
@property (nonatomic, strong) NSMutableDictionary *jsMFRs;

- (void)switchToTab:(NSInteger)tabIndex popToRootViewController:(BOOL)popToRoot animated:(BOOL)animated;
- (void)setMessageBadgeValue;

- (void)executeMFR:(MCTMessageFlowRun *)mfr withUserInput:(NSDictionary *)userInput throwIfNotReady:(BOOL)throwIfNotReady;
- (BOOL)executeJavascriptValidationForKey:(NSString *)messageKey
                                andJSCode:(NSString *)javascriptCode
                                 andValue:(NSDictionary *)value
                                 andEmail:(NSString *)email;
- (void)startLocationUsage;
- (void)registerIntents;

@end