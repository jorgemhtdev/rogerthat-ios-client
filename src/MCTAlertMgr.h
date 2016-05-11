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

#import <AVFoundation/AVAudioPlayer.h>

#import "MCTIntentFramework.h"
#import "MCTMessageStore.h"


@interface MCTAlertMgr : NSObject <IMCTIntentReceiver, AVAudioPlayerDelegate>

@property (nonatomic, strong) MCTMessageStore *store;
@property (nonatomic, copy) NSString *defaultAlarmSound;
@property (nonatomic, copy) NSString *alarmSound;
@property (nonatomic, copy) NSString *beepSound;

+ (MCTAlertMgr *)alertMgr;

- (void)analyze:(NSNumber *)alertNow;

@end