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

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "MCTAlertMgr.h"
#import "MCTComponentFramework.h"
#import "MCTMessageEnums.h"
#import "MCTOperation.h"
#import "MCTUtils.h"


@interface MCTAlertMgr() 

- (BOOL)shouldStartSound:(BOOL)alertNow;

- (void)vibrate;
- (void)startVibrating;

- (void)startSound:(NSNumber *)alertNow;
- (void)startSilence;
- (void)stopAlarm;

- (int)ringTimeWithFlags:(int)flags;
- (int)intervalWithFlags:(int)flags;
- (BOOL)shouldBeSilentWithFlags:(int)flags;
- (BOOL)shouldVibrateWithFlags:(int)flags;

@property (nonatomic) BOOL shouldBeSilent;
@property (nonatomic) BOOL shouldVibrate;
@property (nonatomic) BOOL isRinging;
@property (nonatomic) int ringTime;
@property (nonatomic) int ringInterval;
@property (nonatomic) MCTlong lastTimeAnalyzed;
@property (nonatomic) MCTlong alarmStartTime;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) UIBackgroundTaskIdentifier bgTask;

@end


@implementation MCTAlertMgr



+ (MCTAlertMgr *)alertMgr
{
    T_BIZZ();
    return [[MCTAlertMgr alloc] init];
}

- (id)init
{
    T_BIZZ();
    if (self = [super init]) {
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

        NSError *error = nil;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (error) {
            ERROR(@"Error while setting AVAudioSession category:\n%@", error);
        }

        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_NEW_ALARM_SOUND];

        [[MCTComponentFramework intentFramework]
         registerIntentListener:self
               forIntentActions:[NSArray arrayWithObjects:kINTENT_MESSAGE_RECEIVED, kINTENT_MESSAGE_MODIFIED,
                                 kINTENT_NEW_ALARM_SOUND, kINTENT_THREAD_ACKED, nil]
                        onQueue:[MCTComponentFramework workQueue]];

        self.lastTimeAnalyzed = [MCTUtils currentServerTime];
        [[MCTComponentFramework workQueue]
         addOperation:[MCTInvocationOperation operationWithTarget:self
                                                         selector:@selector(analyze:)
                                                           object:[NSNumber numberWithBool:NO]]];


        self.defaultAlarmSound = [[NSBundle mainBundle] pathForResource:@"alarm_ring" ofType:@"wav"];
        self.beepSound = [[NSBundle mainBundle] pathForResource:@"msg-received" ofType:@"wav"];

        // Look for custom alarm in Documents/alarm/
        NSString *alarmFolder = [[MCTUtils documentsFolder] stringByAppendingPathComponent:@"alarm"];
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:alarmFolder error:nil];
        LOG(@"Custom alarm folder contents: %@", files);

        for (NSString *fileName in files) {
            if ([fileName hasPrefix:@"alarm"]) {
                self.alarmSound = [alarmFolder stringByAppendingPathComponent:fileName];
                LOG(@"Custom alarm sound: %@", self.alarmSound);
                break;
            }
        }

        if (self.alarmSound == nil) {
            self.alarmSound = self.defaultAlarmSound;
        }
    }
    return self;
}

#pragma mark -

- (void)onIntent:(MCTIntent *)intent
{
    T_BIZZ();
    // TODO: What if thread deleted
    // TODO: Does an alarm need to stop when a new message (without alarm) arrives?
    if (intent.action == kINTENT_MESSAGE_RECEIVED && ![intent hasBoolKey:@"is_silent"]) {
        if (self.lastTimeAnalyzed < intent.creationTimestamp / 1000) {
            [self analyze:MCTYES];
        }
    } else if (intent.action == kINTENT_MESSAGE_MODIFIED && [intent hasBoolKey:@"needsMyAnswer_changed"]) {
        // I pressed a button -> re-analyze
        if (self.lastTimeAnalyzed < intent.creationTimestamp / 1000) {
            [self analyze:MCTNO];
        }
    } else if (intent.action == kINTENT_THREAD_ACKED) {
        if (self.lastTimeAnalyzed < intent.creationTimestamp / 1000) {
            [self analyze:MCTNO];
        }
    } else if (intent.action == kINTENT_NEW_ALARM_SOUND) {
        NSString *newAlarmSound = [intent stringForKey:@"file"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:newAlarmSound]) {
            self.alarmSound = newAlarmSound;
        }
    }
}

#pragma mark -

- (void)analyze:(NSNumber *)alertNow
{
    T_BIZZ();
    [self startBackgroundTask];

    float maxRingIntensity = 0;

    self.shouldBeSilent = YES;
    self.shouldVibrate = NO;

    self.ringTime = 0;
    self.ringInterval = 0;

    NSArray *alertFlags = [self.store alertFlagsOfOpenMessagesSince:self.lastTimeAnalyzed];
    LOG(@"%@", alertFlags);

    for (NSNumber *flagsNumber in alertFlags) {
        int flags = [flagsNumber intValue];

        int tmpRingTime = [self ringTimeWithFlags:flags];
        int tmpInterval = [self intervalWithFlags:flags];
        BOOL tmpSilent = [self shouldBeSilentWithFlags:flags];
        BOOL tmpVibrate = [self shouldVibrateWithFlags:flags];

        self.shouldVibrate |= tmpVibrate;
        self.shouldBeSilent &= tmpSilent;

        if (self.ringTime == 0)
            self.ringTime = tmpRingTime;
        if (self.ringInterval == 0)
            self.ringInterval = tmpInterval;

        if (tmpInterval != 0) {
            float ringIntensity = (float) tmpRingTime / (float) tmpInterval;

            if (ringIntensity > maxRingIntensity) {
                maxRingIntensity = ringIntensity;
                self.ringTime = tmpRingTime;
                self.ringInterval = tmpInterval;
            }
        }
    }

    if ([self shouldStartSound:[alertNow boolValue]]) {
        [self performSelectorOnMainThread:@selector(alarmWillStart) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(startSound:) withObject:alertNow waitUntilDone:NO];
        self.alarmStartTime = [MCTUtils currentTimeMillis];
    } else {
        [self performSelectorOnMainThread:@selector(stopAlarm) withObject:nil waitUntilDone:NO];
    }

    self.lastTimeAnalyzed = [MCTUtils currentServerTime];
}

- (BOOL)shouldStartSound:(BOOL)alertNow
{
    T_BIZZ();
    HERE();
    LOG(@"ringTime:       %d", self.ringTime);
    LOG(@"ringInterval:   %d", self.ringInterval);

    LOG(@"alertNow:       %@", BOOLSTR(alertNow));
    LOG(@"shouldBeSilent: %@", BOOLSTR(self.shouldBeSilent));
    LOG(@"shouldVibrate:  %@", BOOLSTR(self.shouldVibrate));

    if (self.ringTime > 0 || self.ringInterval > 0)
        return YES;

    // When in background, don't play msg-received sound IF we're registered for Apple Push
    BOOL applePushOK = MCT_DEBUG || ![[MCTComponentFramework appDelegate] failedToRegisterForRemoteNotifications];
    BOOL inBackground = [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive;

    LOG(@"inBackground:   %@", BOOLSTR(inBackground));
    LOG(@"applePushOK:    %@", BOOLSTR(applePushOK));

    if (alertNow && self.shouldBeSilent && self.shouldVibrate && !(inBackground && applePushOK)) {
        LOG(@"Vibration only");
        [self vibrate];
        return NO;
    }

    if (alertNow && !inBackground)
        return YES;

    if (alertNow && !applePushOK)
        return YES;

    LOG(@"Not playing any sound");
    return NO;
}

#pragma mark -

- (int)ringTimeWithFlags:(int)flags
{
    T_BIZZ();
    if ((flags & MCTAlertFlagRing5) != 0)
        return 5;
    if ((flags & MCTAlertFlagRing15) != 0)
        return 15;
    if ((flags & MCTAlertFlagRing30) != 0)
        return 30;
    if ((flags & MCTAlertFlagRing60) != 0)
        return 60;

    return 0;
}

- (int)intervalWithFlags:(int)flags
{
    T_BIZZ();
    if ((flags & MCTAlertFlagInterval5) != 0)
        return 5;
    if ((flags & MCTAlertFlagInterval15) != 0)
        return 15;
    if ((flags & MCTAlertFlagInterval30) != 0)
        return 30;
    if ((flags & MCTAlertFlagInterval60) != 0)
        return 60;
    if ((flags & MCTAlertFlagInterval300) != 0)
        return 300;
    if ((flags & MCTAlertFlagInterval900) != 0)
        return 900;
    if ((flags & MCTAlertFlagInterval3600) != 0)
        return 3600;

    return 0;
}

- (BOOL)shouldBeSilentWithFlags:(int)flags
{
    T_BIZZ();
    return ((flags & MCTAlertFlagSilent) != 0);
}

- (BOOL)shouldVibrateWithFlags:(int)flags
{
    T_BIZZ();
    return ((flags & MCTAlertFlagVibrate) != 0);
}

#pragma mark -

- (void)vibrate
{
    T_DONTCARE();
    HERE();
    if (self.isRinging || (self.shouldVibrate && self.ringTime == 0)) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)startVibrating
{
    T_UI();
    for (int i = 0; i <= self.ringTime; i++) {
        // AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) vibrates for 0.4 seconds and is 0.1 seconds silent
        [self performSelector:@selector(vibrate) withObject:nil afterDelay:i];
    }
}

- (void)startSound:(NSNumber *)alertNow
{
    T_UI();
    HERE();

    if (self.audioPlayer && self.audioPlayer.playing) {
        [self.audioPlayer stop];
        MCT_RELEASE(self.audioPlayer);
    }
    self.isRinging = NO;

    if (self.shouldVibrate && [alertNow boolValue]) {
        [self startVibrating];
    }

    BOOL isInForeground = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
    if ((![alertNow boolValue] || isInForeground ) && self.ringInterval == 0 && self.ringTime == 0)
        return;

    NSString *path = (self.ringTime == 0) ? self.beepSound : self.alarmSound;
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];

    if (self.audioPlayer == nil) {
        ERROR(@"%@", error);
        return;
    }

    self.audioPlayer.delegate = self;
    // TODO: Check mute switch with SharkfoodMuteSwitchDetector while playing sound
    // http://sharkfood.com/content/Developers/content/Sound%20Switch/
    self.audioPlayer.volume = (self.shouldBeSilent) ? 0 : 1;

    if (self.ringTime != 0 && [self.alarmSound isEqualToString:self.defaultAlarmSound]) {
        self.audioPlayer.numberOfLoops = self.ringTime - 1;
    } else {
        self.audioPlayer.numberOfLoops = 0;
    }

    [self.audioPlayer play];
    self.isRinging = YES;
}

- (void)startSilence
{
    T_UI();
    HERE();

    if (self.audioPlayer && self.audioPlayer.playing) {
        [self.audioPlayer stop];
        MCT_RELEASE(self.audioPlayer);
    }
    self.isRinging = NO;

    if (self.ringInterval == 0)
        return;

    NSError *error;
    NSString *path = self.defaultAlarmSound;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];

    if (self.audioPlayer == nil) {
        ERROR(@"%@", error);
        return;
    }

    self.audioPlayer.delegate = self;
    self.audioPlayer.volume = 0;
    self.audioPlayer.numberOfLoops = (self.ringInterval == 0) ? 0 : self.ringInterval - 1;

    [self.audioPlayer play];
}

- (void)stopAlarm
{
    T_UI();
    HERE();

    if (self.audioPlayer && self.audioPlayer.playing)
        [self.audioPlayer stop];
    MCT_RELEASE(self.audioPlayer);
    self.isRinging = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(vibrate) object:nil];
    [self alarmDidStop];
}

#pragma mark -
#pragma mark AVAudioPlayerDelegate

/**
 * audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing.
 * This method is NOT called if the player is stopped due to an interruption.
 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    T_UI();
    HERE();

    if (player != self.audioPlayer) {
        return;
    }

    if (self.isRinging) {
        if (([MCTUtils currentTimeMillis] - self.alarmStartTime) / 1000 < self.ringTime) {
            [self startSound:[NSNumber numberWithBool:NO]];
        } else if (self.ringInterval == 0) {
            [self stopAlarm];
        } else {
            [self startSilence];
        }
    } else {
        [self startSound:[NSNumber numberWithBool:YES]];
        self.alarmStartTime = [MCTUtils currentTimeMillis];
    }
}

/**
 * if an error occurs while decoding it will be reported to the delegate.
 */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    T_UI();
    ERROR(@"%@", error);
}

#pragma mark -

- (void)alarmWillStart
{
    T_UI();
    HERE();
    [self startBackgroundTask];

    // TODO: remove the scheduling of stopAlarm when alarms work
    [self performSelector:@selector(stopAlarm) withObject:nil afterDelay:self.ringTime];

    NSError *error = nil;

    IF_PRE_IOS8({
        if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                                    error:&error]) {
            ERROR(@"Failed to set AudioSessionCategory.\n%@", error);
        }
    });

    IF_IOS8_OR_GREATER({
        if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                              withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                                    error:&error]) {
            ERROR(@"Failed to activate AudioSessionCategory.\n%@", error);
        }
    });

    if (![[AVAudioSession sharedInstance] setActive:YES
                                              error:&error]) {
        ERROR(@"Failed to activate AudioSession.\n%@", error);
    }

    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_1) {
        MPNowPlayingInfoCenter *info = [MPNowPlayingInfoCenter defaultCenter];
        info.nowPlayingInfo = @{MPMediaItemPropertyArtist: MCT_PRODUCT_NAME,
                                MPMediaItemPropertyTitle: NSLocalizedString(@"Alarm", nil)};


        MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];

        for (MPRemoteCommand *c in @[commandCenter.playCommand,
                                     commandCenter.stopCommand,
                                     commandCenter.togglePlayPauseCommand,
                                     commandCenter.nextTrackCommand,
                                     commandCenter.previousTrackCommand,
                                     commandCenter.togglePlayPauseCommand,
                                     commandCenter.skipForwardCommand,
                                     commandCenter.skipBackwardCommand,
                                     commandCenter.seekForwardCommand,
                                     commandCenter.seekBackwardCommand,
                                     commandCenter.ratingCommand,
                                     commandCenter.changePlaybackRateCommand,
                                     commandCenter.likeCommand,
                                     commandCenter.dislikeCommand,
                                     commandCenter.bookmarkCommand
                                     ]) {
            c.enabled = NO;
        }

        commandCenter.pauseCommand.enabled = YES;
        [commandCenter.pauseCommand addTarget:self action:@selector(remoteCommandPressed:)];
    }
}

- (void)remoteCommandPressed:(MPRemoteCommandEvent *)event
{
    T_UI();
    HERE();
    [self stopAlarm];
}

- (void)alarmDidStop
{
    T_UI();
    NSError *error = nil;
    if (![[AVAudioSession sharedInstance] setActive:NO
                                        withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                              error:&error]) {
        ERROR(@"%@", error);
    }

    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_1) {
        [[MPRemoteCommandCenter sharedCommandCenter].pauseCommand removeTarget:nil];
    }

    [self endBackgroundTask];
}

- (void)startBackgroundTask
{
    T_DONTCARE();
    if (self.bgTask == UIBackgroundTaskInvalid) {
        HERE();
        self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"MCTAlertMgr"
                                                                   expirationHandler:^{
                                                                       T_UI();
                                                                       LOG(@"In expirationHandler of MCTAlertMgr");
                                                                   }];
    }

    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        HTTPLOG(@"application.backgroundTimeRemaining = %f", [UIApplication sharedApplication].backgroundTimeRemaining);
    }
}

- (void)endBackgroundTask
{
    T_UI();
    if (self.bgTask != UIBackgroundTaskInvalid) {
        HERE();
        LOG(@"Ending MCTAlertMgr background task: %lu", (unsigned long)self.bgTask);
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}

@end