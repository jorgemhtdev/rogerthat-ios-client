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

#import "MCTHTTPRequest.h"
#import "MCTRegistrationInfo.h"
#import "MCTXMPPConnection.h"

#define MCT_CONFIGKEY_INVITATION_USERCODE @"INVITATION_USERCODE"
#define MCT_CONFIGKEY_INVITATION_SECRET @"INVITATION_SECRET"


@protocol MCTFinishRegistrationCallback
- (void)finishRegistrationSuccess;
- (void)finishRegistrationFailure;
- (void)finishRegistrationAttempt:(int)attempt withInfo:(MCTRegistrationInfo *)info;
@end

@interface MCTFinishRegistration : NSObject<MCTXMPPConnectionDelegate>

@property(nonatomic, strong) MCTXMPPConnection *testXMPPConnection;
@property(nonatomic, strong) NSObject<MCTFinishRegistrationCallback> *delegate;
@property(nonatomic, strong) MCTRegistrationInfo *registrationInfo;
@property(nonatomic, strong) MCTFormDataRequest *finishRegistrationRequest;
@property(nonatomic, assign) int attemptCount;
@property(nonatomic, assign) BOOL canceled;
@property(nonatomic, assign) BOOL ageAndGenderSet;

- (void)doFinishRegistration;
- (void)cancel;

@end