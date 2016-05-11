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
#import "MCTMobileInfo.h"
#import "MCTOperation.h"
#import "MCTSystemPlugin.h"

#include <signal.h>
#include <execinfo.h>


void mctExceptionHandler(NSException *exception)
{
    T_DONTCARE();
    [MCTSystemPlugin logError:exception withMessage:@"Uncaught exception"];
}

void mctSigHandler(int sig, siginfo_t *info, void *context)
{
    void *backtraceFrames[128];
    int frameCount = backtrace(backtraceFrames, 128);
    char **symbols = backtrace_symbols(backtraceFrames, frameCount);

    NSMutableString *errorMessage = [[NSMutableString alloc] initWithCapacity:4096];
    [errorMessage appendString:@"Uncaught Signal\n"];

    TRY_OR_LOG_EXCEPTION({
        const char* names[NSIG];
        names[SIGQUIT] = "SIGQUIT";
        names[SIGILL]  = "SIGILL";
        names[SIGTRAP] = "SIGTRAP";
        names[SIGABRT] = "SIGABRT";
        names[SIGEMT]  = "SIGEMT";
        names[SIGFPE]  = "SIGFPE";
        names[SIGBUS]  = "SIGBUS";
        names[SIGSEGV] = "SIGSEGV";
        names[SIGSYS]  = "SIGSYS";
        names[SIGPIPE] = "SIGPIPE";
        names[SIGALRM] = "SIGALRM";
        names[SIGXCPU] = "SIGXCPU";
        names[SIGXFSZ] = "SIGXFSZ";
        [errorMessage appendFormat:@"signal      %d (%s)\n", sig, names[sig]];
    });
    TRY_OR_LOG_EXCEPTION({
        [errorMessage appendFormat:@"si_signo    %d\n", info->si_signo];
    });
    TRY_OR_LOG_EXCEPTION({
        [errorMessage appendFormat:@"si_code     %d\n", info->si_code];
    });
    TRY_OR_LOG_EXCEPTION({
        [errorMessage appendFormat:@"si_value    %d\n", info->si_value.sival_int];
    });
    TRY_OR_LOG_EXCEPTION({
        [errorMessage appendFormat:@"si_errno    %d\n", info->si_errno];
    });
    TRY_OR_LOG_EXCEPTION({
        [errorMessage appendFormat:@"si_addr     %p\n", info->si_addr];
    });
    TRY_OR_LOG_EXCEPTION({
        [errorMessage appendFormat:@"si_status   %d\n", info->si_status];
    });

    if (symbols == NULL) {
        [errorMessage appendString:@"(No stack trace)"];
    } else {
        [errorMessage appendString:@"Stack trace:\n\n"];
        for (int i = 0; i < frameCount; ++i) {
            [errorMessage appendFormat:@"%s\n", symbols[i]];
        }
        free(symbols);
    }

    [MCTSystemPlugin logErrorOverHTTPWithMessage:errorMessage
                                     description:@"Uncaught exception"];

    signal(sig, SIG_DFL);
}

#pragma mark -

@implementation MCTOperation


- (void)start
{
    NSSetUncaughtExceptionHandler(&mctExceptionHandler);
    [super start];
}

@end


#pragma mark -

@implementation MCTInvocationOperation


+ (MCTInvocationOperation *)operationWithTarget:(NSObject *)target selector:(SEL)sel objects:(id)firstObject, ...
{
    NSMethodSignature *sig = [target methodSignatureForSelector:sel];
    if (!sig)
        return nil;

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setTarget:target];
    [inv setSelector:sel];

    int count = 2;
    id eachObject;
    va_list argumentList;

    if (firstObject) {
        [inv setArgument:&firstObject atIndex:count++];

        va_start(argumentList, firstObject);
        while ((eachObject = va_arg(argumentList, id)))
            [inv setArgument:&eachObject atIndex:count++];
        va_end(argumentList);
    }

    return [[MCTInvocationOperation alloc] initWithInvocation:inv];
}

+ (MCTInvocationOperation *)operationWithTarget:(id)target selector:(SEL)sel object:(id)arg
{
    return [[MCTInvocationOperation alloc] initWithTarget:target selector:sel object:arg];
}

- (void)start
{
    NSSetUncaughtExceptionHandler(&mctExceptionHandler);
    [super start];
}


@end


#pragma mark -

@implementation MCTOperationQueue


+ (MCTOperationQueue *)queueWithName:(NSString *)name
{
    MCTOperationQueue *queue = [[MCTOperationQueue alloc] init];
    queue.name = name;
    return queue;
}

- (void)addOperation:(NSOperation *)op
{
    if ([op isKindOfClass:[MCTInvocationOperation class]]) {
        MCTInvocationOperation *mctOp = (MCTInvocationOperation *)op;
        mctOp.name = self.name;
    } else if ([op isKindOfClass:[MCTOperation class]]) {
        MCTOperation *mctOp = (MCTOperation *)op;
        mctOp.name = self.name;
    }
    [super addOperation:op];
}

- (void)addOperationWithBlock:(void (^)(void))block
{
    [super addOperationWithBlock:^{
        @try {
            block();
        } @catch (NSException *e) {
            [MCTSystemPlugin logError:e withMessage:@"Exception in block!"];
        }
    }];
}


@end


#pragma mark -

@implementation MCTFakeOperationQueue

+ (MCTFakeOperationQueue *)queueWithName:(NSString *)name
{
    MCTFakeOperationQueue *queue = [[MCTFakeOperationQueue alloc] init];
    queue.name = name;
    return queue;
}


- (void)addOperation:(NSOperation *)operation
{
    ERROR(@"addOperation is not possible on a fake operation queue");
}

@end