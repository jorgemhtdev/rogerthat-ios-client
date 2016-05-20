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

void mctExceptionHandler(NSException *exception);
void mctSigHandler(int sig, siginfo_t *info, void *context);

@interface MCTOperation : NSOperation {
    NSString *name_;
}

@property (copy) NSString *name;

@end


@interface MCTInvocationOperation : NSInvocationOperation {
    NSString *name_;
}

@property (copy) NSString *name;

+ (MCTInvocationOperation *)operationWithTarget:(NSObject *)target
                                       selector:(SEL)sel
                                        objects:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
+ (MCTInvocationOperation *)operationWithTarget:(id)target selector:(SEL)sel object:(id)arg;

@end


@interface MCTOperationQueue : NSOperationQueue

+ (MCTOperationQueue *)queueWithName:(NSString *)name;

@end


@interface MCTFakeOperationQueue : MCTOperationQueue

+ (MCTFakeOperationQueue *)queueWithName:(NSString *)name;

@end