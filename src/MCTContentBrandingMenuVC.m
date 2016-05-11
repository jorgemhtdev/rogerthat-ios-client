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
#import "MCTContentBrandingMenuVC.h"
#import "MCTServiceScreenBrandingVC.h"
#import "MCTUINavigationController.h"

@interface MCTContentBrandingMenuVC ()

@property (nonatomic, retain) MCTFriendsPlugin *friendsPlugin;
@property (nonatomic, retain) MCTBrandingMgr *brandingMgr;
@property (nonatomic, retain) MCTSystemPlugin *systemPlugin;

@end

@implementation MCTContentBrandingMenuVC



+ (MCTContentBrandingMenuVC *)viewController
{
    T_UI();
    return [[MCTContentBrandingMenuVC alloc] initWithNibName:@"contentBrandingMenu" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.friendsPlugin = [MCTComponentFramework friendsPlugin];
    self.brandingMgr = [MCTComponentFramework brandingMgr];
    self.systemPlugin = [MCTComponentFramework systemPlugin];

    self.txtLbl.text = NSLocalizedString(@"osa_loyalty_welcome", nil);

    self.statusLbl.text = NSLocalizedString(@"Initializing…", nil);
    self.progressView.progress = 0.0f;

    [self launchOsaSlideshowWhenDone];
    [self registerIntents];
    [self increaseProgressValue];
}

- (void)dealloc
{
    T_UI();
    [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
}

- (void)registerIntents
{
    T_UI();
    [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_REGISTRATION_COMPLETED];

    NSArray *actions = [NSArray arrayWithObjects:kINTENT_REGISTRATION_COMPLETED, kINTENT_FRIEND_ADDED, kINTENT_FRIENDS_RETRIEVED, kINTENT_SERVICE_BRANDING_RETRIEVED, kINTENT_GENERIC_BRANDING_RETRIEVED, kINTENT_JS_EMBEDDING_RETRIEVED, nil];
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:actions
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)increaseProgressValue
{
    self.progressView.progress += 0.01;
    if (self.progressView.progress < 1.0) {
        [self performSelector:@selector(increaseProgressValue) withObject:self afterDelay:0.25];
    }
}

- (void)launchOsaSlideshowWhenDone
{
    MCTFriendStore *friendStore = [self.friendsPlugin store];
    NSArray *friends = [friendStore friendEmails];
    if ([friends count] == 0) {
        LOG(@"[OSA] Service not available yet");
    } else if ([friends count] == 1) {
        if (self.progressView.progress < 0.25) {
            self.progressView.progress = 0.25;
        }

        MCTFriend *friend = [friendStore friendByEmail:friends[0]];

        if (![self.brandingMgr isBrandingAvailable:friend.contentBrandingHash]) {
            LOG(@"[OSA] Content branding not available yet");
            return;
        }

        if (self.progressView.progress < 0.5) {
            self.progressView.progress = 0.5;
        }

        BOOL packetAvailable = YES;
        NSDictionary *packets = [self.systemPlugin jsEmbeddedPackets];
        if ([packets count] == 0) {
            packetAvailable = NO;
        }
        for (MCTJSEmbedding *packet in packets.allValues) {
            if (packet.status == MCTJSEmbeddingStatusUnavailable) {
                packetAvailable = NO;
            }
        }

        if (!packetAvailable) {
            LOG(@"[OSA] JS Embedding packets not available yet");
            return;
        }

        if (self.progressView.progress < 1.0) {
            self.progressView.progress = 1.0;
        }

        MCTServiceMenuItem *smi = [[MCTServiceMenuItem alloc] init];
        smi.coords = @[@(0), @(0), @(0)];
        smi.label = @"OSA Loyalty";
        smi.hashedTag = @"";
        smi.screenBranding = friend.contentBrandingHash;
        smi.runInBackground = YES;
        MCTServiceScreenBrandingVC *vc = [MCTServiceScreenBrandingVC viewControllerWithService:friend
                                                                                          item:smi];

        vc.title = smi.label;
        dispatch_async(dispatch_get_main_queue(), ^{
            UINavigationController *nav = [[MCTUINavigationController alloc] initWithRootViewController:vc];
            nav.navigationBarHidden = YES;
            [self presentViewController:nav animated:NO completion:nil];
        });

    } else {
        BUG(@"[OSA] OSA Loyalty user has more than 1 friend");
    }
}

#pragma mark - MCTIntent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    [self launchOsaSlideshowWhenDone];
}

@end