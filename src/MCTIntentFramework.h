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

#import "MCTIntent.h"

@protocol IMCTIntentReceiver
- (void)onIntent:(MCTIntent *)intent;
@end


@interface MCTIntentFramework : NSObject

- (void)registerIntentListener:(NSObject<IMCTIntentReceiver> *)obj
              forIntentActions:(NSArray *)actions
                       onQueue:(NSOperationQueue *)opQueue;
- (void)registerIntentListener:(NSObject<IMCTIntentReceiver> *)obj
               forIntentAction:(NSString *)action
                       onQueue:(NSOperationQueue *)opQueue;

- (BOOL)unregisterIntentListener:(NSObject<IMCTIntentReceiver> *)obj;
- (BOOL)unregisterIntentListener:(NSObject<IMCTIntentReceiver> *)obj forIntentAction:(NSString *)action;

- (void)broadcastIntent:(MCTIntent *)intent;
- (void)broadcastStickyIntent:(MCTIntent *)intent;

- (void)removeStickyIntent:(MCTIntent *)intent;

- (void)addHighPriorityIntent:(NSString *)action;

- (void)reset;

@end