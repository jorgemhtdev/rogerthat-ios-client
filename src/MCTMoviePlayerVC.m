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

#import "MCTMoviePlayerVC.h"
#import "MCTUIUtils.h"

@interface MCTMoviePlayerVC ()

@end

@implementation MCTMoviePlayerVC

+ (instancetype)viewControllerWithContentURL:(NSURL *)contentURL
{
    MCTMoviePlayerVC *vc = [[MCTMoviePlayerVC alloc] init];
    // Workaround for local flows. MPMoviePlayerController acts weird with symlinks, so we follow the symlink path.
    NSString *symLinkTarget = [[NSFileManager defaultManager] destinationOfSymbolicLinkAtPath:[contentURL path]
                                                                                        error:nil];
    if (symLinkTarget) {
        vc.url = [NSURL fileURLWithPath:symLinkTarget];
    } else {
        vc.url = contentURL;
    }
    return vc;
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.url];
    self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.moviePlayer.view.frame = self.view.bounds;
    self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
    self.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [self.view addSubview:self.moviePlayer.view];

    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.translucent = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willExitFullscreen:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterFullscreen:)
                                                 name:MPMoviePlayerDidEnterFullscreenNotification
                                               object:nil];

    [self.moviePlayer play];
}

- (void)forcePortrait
{
    self.navigationController.navigationBar.translucent = YES;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self resetNavigationControllerAppearance];

    [MCTUIUtils forcePortrait];

    // Force resize of navigationBar after rotation
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    T_UI();
    if (![self.navigationController.viewControllers containsObject:self]) {
        IF_IOS8_OR_GREATER({
            // Force change to portrait
            [self forcePortrait];
        });

        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.moviePlayer stop];
    }

    [super viewWillDisappear:animated];
}


- (BOOL)shouldAutorotate
{
    T_UI();
    HERE();
    IF_PRE_IOS8({
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) &&
            (self.moviePlayer.playbackState == MPMoviePlaybackStatePaused ||
             self.moviePlayer.playbackState == MPMoviePlaybackStateStopped)) {
                BOOL shouldAutoRotate = !UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)
                    && UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation);
                LOG(@"%@, %@", [self class], BOOLSTR(shouldAutoRotate));
                return shouldAutoRotate;
            }
    });
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    T_UI();
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    T_UI();
    IF_PRE_IOS8({
        return UIInterfaceOrientationPortrait;
    });
    return UIInterfaceOrientationLandscapeLeft;
}


#pragma mark -

- (void)playbackStateDidChange:(NSNotification *)notification
{
    T_UI();
    HERE();
    MPMoviePlayerController *player = notification.object;
    LOG(@"MPMoviePlayerController.plabackState is %d", player.playbackState);
    BOOL hidden = player.playbackState != MPMoviePlaybackStatePaused
        && player.playbackState != MPMoviePlaybackStateStopped
        && player.playbackState != MPMoviePlaybackStateInterrupted;

    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:hidden animated:YES];
    self.navigationController.navigationBar.translucent = NO;

    IF_PRE_IOS8({
        if (!hidden) {
            [self forcePortrait];
        }
    });
}

- (void)willExitFullscreen:(NSNotification *)notification
{
    T_UI();
    HERE();
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.translucent = YES;
    [self resetNavigationControllerAppearance];
}


- (void)didEnterFullscreen:(NSNotification *)notification
{
    T_UI();
    HERE();
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    [self resetNavigationControllerAppearance];
}

@end