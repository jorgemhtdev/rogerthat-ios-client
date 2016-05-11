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
#import "MCTIntentFramework.h"
#import "MCTOperation.h"


@interface IntentSetEntry : NSObject

@property(nonatomic, weak) NSObject<IMCTIntentReceiver> *receiver; // explicitly do not retain intent receiver!
@property(nonatomic, weak) NSOperationQueue *queue;                // queue object lives as long as application itself
@end

@implementation IntentSetEntry


- (IntentSetEntry *)initWithReceiver:(NSObject<IMCTIntentReceiver> *)receiver andQueue:(NSOperationQueue *)queue
{
    self = [super init];
    if (self) {
        self.receiver = receiver;
        self.queue = queue;
    }
    return self;
}

// No dealloc method since we do not retain anything

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    return (self.receiver == ((IntentSetEntry *)object).receiver) && (self.queue == ((IntentSetEntry *)object).queue);
}

- (NSUInteger)hash
{
    return [self.receiver hash] + [self.queue hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"IntentSetEntry for receiver %@ opqueue %@", self.receiver, self.queue];
}

@end


#pragma mark -

@interface DeliverIntentOperation : MCTOperation

@property (nonatomic, strong) MCTIntent *intent;
@property (nonatomic, strong) NSObject<IMCTIntentReceiver> *receiver; // retain the receiver!

@end


@implementation DeliverIntentOperation


- (void)main
{
    // TODO: should check here once more that receiver is still registered
    //       since this operation might have been in the queue for a while
    //       before it is executed
    //
    //       We could get intents that are delivered AFTER a receiver has unregistered!

    @try {
        [self.receiver onIntent:self.intent];
    } @catch (NSException *exception) {
        [MCTSystemPlugin logError:exception withMessage:nil];
    }
}

@end


#pragma mark -

@interface MCTIntentFramework()

@property(nonatomic, strong) NSMutableDictionary *intentDict;
@property(nonatomic, strong) NSObject *intentLock;

// Sticky intents are not like on android. They only live in memory and are gone when the application is terminated.
@property(nonatomic, strong) NSMutableArray *stickyIntents;

@property(nonatomic, strong) NSMutableArray *stashedIntents;
@property(nonatomic, strong) NSMutableSet *highPriorityIntents;
@property(nonatomic, assign) volatile BOOL isBacklogRunning;

- (void)initialize;
- (void)deliverIntent:(MCTIntent *)intent withEntry:(IntentSetEntry *)entry;
- (void)purgeStashedIntents;
- (BOOL)unregisterIntentListener:(NSObject<IMCTIntentReceiver> *)receiver forIntentAction:(NSString *)action fromExternalSource:(BOOL)external;
- (void)registerIntentListener:(NSObject<IMCTIntentReceiver> *)receiver forIntentAction:(NSString *)action onQueue:(NSOperationQueue *)opQueue fromExternalSource:(BOOL)external;

@end



@implementation MCTIntentFramework


- (MCTIntentFramework *)init
{
    T_UI();
    self = [super init];
    if (self) {
        self.intentLock = [[NSObject alloc] init];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    T_UI();
    self.intentDict = [NSMutableDictionary dictionary];
    self.stickyIntents = [NSMutableArray array];
    self.stashedIntents = [NSMutableArray array];
    self.highPriorityIntents = [NSMutableSet set];
    [self addHighPriorityIntent:kINTENT_BACKLOG_STARTED];
    [self addHighPriorityIntent:kINTENT_BACKLOG_FINISHED];
}

- (void)dealloc
{
    T_UI();
    if (self.intentDict) {
        if ([self.intentDict count] != 0) {
            ERROR(@"IFW: intentDict not empty in dealloc: %@", self.intentDict);
        }
        MCT_RELEASE(self.intentDict);
    }
    MCT_RELEASE(self.intentLock);
    MCT_RELEASE(self.stickyIntents);
    MCT_RELEASE(self.stashedIntents);
    MCT_RELEASE(self.highPriorityIntents);
}

- (void)registerIntentListener:(NSObject<IMCTIntentReceiver> *)receiver
              forIntentActions:(NSArray *)actions
                       onQueue:(NSOperationQueue *)opQueue
{
    T_DONTCARE();
    for (NSString *action in actions) {
        [self registerIntentListener:receiver forIntentAction:action onQueue:opQueue fromExternalSource:NO];
    }
}

- (void)registerIntentListener:(NSObject<IMCTIntentReceiver> *)receiver
               forIntentAction:(NSString *)action
                       onQueue:(NSOperationQueue *)opQueue
{
    [self registerIntentListener:receiver forIntentAction:action onQueue:opQueue fromExternalSource:YES];
}

- (void)registerIntentListener:(NSObject<IMCTIntentReceiver> *)receiver
               forIntentAction:(NSString *)action
                       onQueue:(NSOperationQueue *)opQueue
            fromExternalSource:(BOOL)external
{

    T_DONTCARE();

    if (![receiver conformsToProtocol:@protocol(IMCTIntentReceiver)]) {
        BUG(@"IFW: ERROR - Receiver does not conform to intent receiver protocol: %@", receiver);
        return;
    }

    //if (external)
        LOG(@"IFW: Register intent listener [<%@:0x%x>] for action [%@] on opQueue [%@]", [receiver class], receiver, action, opQueue);

    @synchronized(self.intentLock) {
        NSMutableSet *set = (NSMutableSet *)[self.intentDict objectForKey:action];
        if (set == nil) {
            set = [NSMutableSet set];
            [self.intentDict setObject:set forKey:action];
        }

        for (IntentSetEntry *entry in set)
            if (entry.receiver == receiver) {
                if (entry.queue != opQueue) {
                    ERROR(@"IFW: ERROR Registering intentreceiver [%@] for receiver [<%@:0x%x>] on multiple threads", action, [receiver class], receiver);
                    return;
                } else {
                    LOG(@"IFW: Duplicate registration for intent action [%@]: receiver [<%@:0x%x>]", action, [receiver class], receiver);
                }
            }

        IntentSetEntry *entry = [[IntentSetEntry alloc] initWithReceiver:receiver andQueue:opQueue];
        [set addObject:entry];

        for (MCTIntent *stickyIntent in self.stickyIntents)
            if (stickyIntent.action == action)
                [self deliverIntent:stickyIntent withEntry:entry];
    }
}

// YES if this receiver was indeed registered for this action
- (BOOL)unregisterIntentListener:(NSObject<IMCTIntentReceiver> *)receiver forIntentAction:(NSString *)action
{
    return [self unregisterIntentListener:receiver forIntentAction:action fromExternalSource:YES];
}

// private method
// YES if this receiver was indeed registered for this action
- (BOOL)unregisterIntentListener:(NSObject<IMCTIntentReceiver> *)receiver forIntentAction:(NSString *)action fromExternalSource:(BOOL)external

{
    T_DONTCARE();

    if (receiver == nil)
        return NO;

    BOOL wasRegistered = NO;
    @synchronized(self.intentLock) {
        NSMutableSet *set = (NSMutableSet *)[self.intentDict objectForKey:action];
        if (set) {
            NSMutableSet *entriesToRemove = [NSMutableSet set];
            for (IntentSetEntry *entry in set) {
                if (entry.receiver == receiver)
                    [entriesToRemove addObject:entry];
            }

            if ([entriesToRemove count]) {
                wasRegistered = YES;
                //if (external)
                    LOG(@"IFW: Unregister intent listener [<%@:0x%x>] for action [%@]", [receiver class], receiver, action);
            }

            for (IntentSetEntry *entry in entriesToRemove) {
                [set removeObject:entry];
            }
            if ([set count] == 0)
                [self.intentDict removeObjectForKey:action];
        }
    }
    return wasRegistered;
}

// YES if this receiver was indeed registered
- (BOOL)unregisterIntentListener:(NSObject<IMCTIntentReceiver> *)receiver
{
    T_DONTCARE();

    if (receiver == nil)
        return NO;

    LOG(@"IFW unregister [<%@:0x%x>]", [receiver class], receiver);
    BOOL wasRegistered = NO;
    @synchronized(self.intentLock) {
        for (NSString *action in [NSArray arrayWithArray:[self.intentDict allKeys]]) {
            // Make sure the unregister is effectively evaluate! No one-liners !
            BOOL didUnregisterNow = [self unregisterIntentListener:receiver forIntentAction:action fromExternalSource:NO];
            wasRegistered = didUnregisterNow || wasRegistered;
        }
    }
    return wasRegistered;
}

- (void)deliverIntent:(MCTIntent *)intent withEntry:(IntentSetEntry *)entry
{
    // This method is only invoked when lock is held
    T_DONTCARE();
    LOG(@"IFW: Delivering intent [%@] to [%@]", intent.action, entry.receiver);
    if (entry.queue == [MCTComponentFramework mainQueue]) {
        [entry.receiver performSelectorOnMainThread:@selector(onIntent:) withObject:intent waitUntilDone:NO];
    } else {
        DeliverIntentOperation *op = [[DeliverIntentOperation alloc] init];
        op.intent = intent;
        op.receiver = entry.receiver;
        [entry.queue addOperation:op];
    }

}

- (void)broadcastIntent:(MCTIntent *)intent
{
    T_DONTCARE();
    LOG(@"IFW: Broadcast intent [%@]", intent.action);

    if (!intent)
        return;

    @synchronized(self.intentLock) {
        if (intent.action == kINTENT_BACKLOG_STARTED) {
            self.isBacklogRunning = YES;
        } else if (intent.action == kINTENT_BACKLOG_FINISHED) {
            self.isBacklogRunning = NO;
            [self purgeStashedIntents];
        }

        if (self.isBacklogRunning && (intent.forceStash || ![self.highPriorityIntents containsObject:intent.action])) {
            LOG(@"IFW: Stashed intent [%@]", intent.action);
            [self.stashedIntents addObject:intent];
        } else {
            NSSet *set = [self.intentDict objectForKey:intent.action];
            if (set) {
                for (IntentSetEntry *entry in set) {
                    [self deliverIntent:intent withEntry:entry];
                }
            }
        }
    }
}

- (void)broadcastStickyIntent:(MCTIntent *)intent
{
    T_DONTCARE();
    @synchronized(self.intentLock) {
        [self.stickyIntents addObject:intent];
        [self broadcastIntent:intent];
    }
}

- (void)removeStickyIntent:(MCTIntent *)intent
{
    T_DONTCARE();
    @synchronized(self.intentLock) {
        [self.stickyIntents removeObject:intent];
    }
}

- (void)purgeStashedIntents
{
    T_DONTCARE();
    @synchronized(self.intentLock) {
        NSArray *stash = [NSArray arrayWithArray:self.stashedIntents];
        [self.stashedIntents removeAllObjects];
        for (MCTIntent *intent in [stash reverseObjectEnumerator]) {
            [self broadcastIntent:intent];
        }
    }
}

- (void)reset
{
    T_DONTCARE();
    @synchronized(self.intentLock) {
        [self initialize];
    }
}

- (void)addHighPriorityIntent:(NSString *)action
{
    T_DONTCARE();
    @synchronized(self.intentLock) {
        [self.highPriorityIntents addObject:action];
    }
}

- (NSString *)description
{
    T_DONTCARE();
    NSString *description;
    @synchronized(self.intentLock) {
        description = [NSString stringWithFormat:@"MCTIntentFramework\n\nintentDict = %@\n\nstickyIntents = %@\n",
                       self.intentDict, self.stickyIntents];
    }
    return description;
}

@end