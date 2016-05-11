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

#import "MCTLogForwarding.h"
#import "MCTComponentFramework.h"

static MCTLogForwarder *logForwarder;

#pragma mark -

// http://stackoverflow.com/questions/1236273/objective-c-equivalent-of-javas-blockingqueue

enum {
    kNoWorkQueued = 0,
    kWorkQueued = 1
};

@interface MCTBlockingQueue : NSObject

@property(nonatomic, strong) NSMutableArray *queue;
@property(nonatomic, strong) NSConditionLock *queueLock;

- (id)dequeueUnitOfWorkWaitingUntilDate:(NSDate *)timeoutData;
- (void)queueUnitOfWork:(id)unitOfWork;

@end


@implementation MCTBlockingQueue


- (id)init
{
    if ((self = [super init])) {
        self.queueLock = [[NSConditionLock alloc] initWithCondition:kNoWorkQueued];
        self.queue = [[NSMutableArray alloc] init];
    }
    return self;
}


- (id)dequeueUnitOfWorkWaitingUntilDate:(NSDate *)timeoutDate
{
    id unitOfWork = nil;
    if ([self.queueLock lockWhenCondition:kWorkQueued beforeDate:timeoutDate]) {
        unitOfWork = self.queue[0];
        [self.queue removeObjectAtIndex:0];
        [self.queueLock unlockWithCondition:[self.queue count] ? kWorkQueued : kNoWorkQueued];
    }
    return unitOfWork;
}

- (void)queueUnitOfWork:(id)unitOfWork
{
    [self.queueLock lock];
    [self.queue addObject:unitOfWork];
    [self.queueLock unlockWithCondition:kWorkQueued];
}

@end


#pragma mark -

@interface MCTLogForwarder ()

@property(nonatomic, copy) NSString *target;
@property(nonatomic, assign) BOOL forwarding;
@property(nonatomic, strong) MCTBlockingQueue *queue;
@property(nonatomic, strong) NSString *stopper;
@property(nonatomic, strong) MCTOperationQueue *operationQueue;

@end


@implementation MCTLogForwarder



+ (void)initialize
{
    logForwarder = [[MCTLogForwarder alloc] init];
    logForwarder.forwarding = NO;
    logForwarder.queue = [[MCTBlockingQueue alloc] init];
    logForwarder.target = nil;
    logForwarder.stopper = [[NSString alloc] init];
    logForwarder.operationQueue = [MCTOperationQueue queueWithName:@"LOGFWD"];
    [logForwarder.operationQueue setMaxConcurrentOperationCount:1];
}

+ (MCTLogForwarder *)logForwarder
{
    return logForwarder;
}

- (void)startWithTarget:(NSString *)target
{
    @synchronized(self) {
        if (self.forwarding) {
            return;
        }

        self.target = target;
        self.forwarding = YES;
        [self.queue.queue removeAllObjects];

        [self.operationQueue addOperation:[MCTInvocationOperation operationWithTarget:self
                                                                             selector:@selector(run)
                                                                               object:nil]];
    }
}

- (void)stop
{
    @synchronized(self) {
        if (!self.forwarding) {
            return;
        }
        [self.queue queueUnitOfWork:self.stopper];
        self.forwarding = NO;
    }
}

- (void)logWithTimestamp:(NSString *)now
               queueName:(NSString *)currentQueueName
                  prefix:(const char * const)prefix
                logLevel:(const char * const)logLevel
                function:(const char * const)function
                    file:(NSString *)file
              lineNumber:(const int)lineNumber
{
    @synchronized(self) {
        if (!self.forwarding) {
            return;
        }
    }

    NSString *msg = [NSString stringWithFormat:@"%@ (%@) %@%@ %-40@ (%@:%d)",
                     now,
                     currentQueueName,
                     [NSString stringWithUTF8String:prefix],
                     [NSString stringWithUTF8String:logLevel],
                     [NSString stringWithUTF8String:function],
                     [file lastPathComponent],
                     lineNumber];
    [self.queue queueUnitOfWork:msg];
}

- (void)logWithTimestamp:(NSString *)now
               queueName:(NSString *)currentQueueName
                  prefix:(const char * const)prefix
                 message:(NSString *)message
{

    @synchronized(self) {
        if (!self.forwarding) {
            return;
        }
    }

    NSString *msg = [NSString stringWithFormat:@"%@ (%@) %@%@",
                     now,
                     currentQueueName,
                     [NSString stringWithUTF8String:prefix],
                     message];
    [self.queue queueUnitOfWork:msg];
}

- (void)logErrorWithMessage:(NSString *)message
                 stackTrace:(NSString *)stackTrace
{
    @synchronized(self) {
        if (!self.forwarding) {
            return;
        }
    }

    [self.queue queueUnitOfWork:[NSString stringWithFormat:@"%@\n%@", message, stackTrace]];
}

- (void)run
{
    MCTCommunicationManager *commManager = [MCTComponentFramework commManager];
    __ASSERT_MCT_QUEUE(@"LOGFWD");

    while (YES) {
        NSString *msg = [self.queue dequeueUnitOfWorkWaitingUntilDate:[NSDate dateWithTimeIntervalSinceNow:30*60]];
        if (msg == nil) {
            // Nothing in the queue
            continue;
        }

        if (msg == self.stopper) {
            return;
        }

        NSMutableString *sb = [NSMutableString stringWithString:msg];

        while (YES) {
            // Stop when 20 items are taken from the queue, or if nothing has been logged for 0.5 seconds
            int lineCount = 0;

            msg = [self.queue dequeueUnitOfWorkWaitingUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
            if (msg == nil) {
                break;
            }

            if (msg == self.stopper) {
                return;
            }

            [sb appendString:@"\n"];
            [sb appendString:msg];
            if (lineCount++ > 20) {
                break;
            }
        }

        [commManager log:sb toXmppAccount:self.target];
    }
}

@end