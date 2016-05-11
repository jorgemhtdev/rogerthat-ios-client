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

#import "3rdParty/xmppframework/Core/XMPPIQ.h"

#import "MCTCommunicationManager.h"
#import "MCTComponentFramework.h"
#import "MCTCredentials.h"
#import "MCTOperation.h"
#import "MCTHTTPRequest.h"
#import "MCTUtils.h"

#import "GTMNSData+zlib.h"

#define MAX_COMMUNICATION_COUNT 50
#define COMMUNICATION_TIMEOUT 60


enum MCTCommunicationStatus {
    COMMUNICATION_FINISHED,         // we're sure that there is no need to further communicate right now
    COMMUNICATION_CONTINUE,         // we should communicate further, there might be client stuff
    COMMUNICATION_SERVER_HAS_MORE,  // server indicated that there is more to send from server to client
    COMMUNICATION_ERROR             // error during communication
};


@implementation MCTCommunicationLoop


+ (MCTCommunicationLoop *)loopWithCount:(int)count
{
    T_BACKLOG();
    MCTCommunicationLoop *loop = [[MCTCommunicationLoop alloc] init];
    loop.count = count;
    return loop;
}


@end

#pragma mark -
#pragma mark MCTCommunicationManager


@interface MCTCommunicationManager()

@property (nonatomic) BOOL communicating;
@property (nonatomic) UIBackgroundTaskIdentifier communicationBgTask;
@property (nonatomic, copy) NSString *currentRequestId;

- (void)communicate;
- (void)stopCommunicationCycleWithStatus:(MCTCommunicationResult)result loopCount:(int)loopCount;
- (void)startCommunicationLoop:(MCTCommunicationLoop *)loop;
- (NSString *)createJSONRequestStringForOutgoingCallsWithFilterOnWifiOnly:(BOOL)filterOnWifiOnly;
- (NSString *)createJSONRequestStringForOutgoingResponses:(NSArray *)callids;

@end


@implementation MCTCommunicationManager

// All owned by COMM thread

- (MCTCommunicationManager *)init
{
    T_BACKLOG();
    if (self = [super init]) {
        self.stopped = NO;
        self.force = NO;
        self.communicationBgTask = UIBackgroundTaskInvalid;

        NSString *username = [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_USERNAME];
        NSString *password = [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_PASSWORD];
        self.credentials = [MCTCredentials credentials];
        self.credentials.username = username;
        self.credentials.password = password;

        if (MCT_USE_XMPP_KICK_CHANNEL) {
            self.xmppConnection = [[MCTXMPPConnection alloc] initWithCredentials:self.credentials];
            [self.xmppConnection connectWithDelegate:self];
        }

        [self initializeURLSession];
        [self initializeLogForwardingURLSession];

        self.backlog = [[MCTBacklog alloc] init];
        self.callReceiver = [[MCTCallReceiver alloc] init];

        self.protocol = [[MCTRPCProtocol alloc] init];
        [self.protocol setCredentials:self.credentials];
        self.protocol.callReceiver = self.callReceiver;
        self.protocol.backlog = self.backlog;
        self.protocol.acksToSend = [NSMutableArray array];
        self.protocol.responsesToSend = [NSMutableArray array];


        [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                       forIntentActions:@[kINTENT_KICK_BACKLOG,
                                                                          kINTENT_PUSH_NOTIFICATION_SETTINGS_UPDATED]
                                                                onQueue:[MCTComponentFramework commQueue]];

        [[MCTComponentFramework intentFramework] addHighPriorityIntent:kINTENT_KICK_BACKLOG];
    }
    return self;
}

+ (NSString *)URLSessionIdentifier
{
    return @"commMgr";
}

- (NSURLSession *)initializeURLSession
{
    NSString *identifier = [MCTCommunicationManager URLSessionIdentifier];
    NSURLSessionConfiguration *sessionConfiguration = nil;
    IF_PRE_IOS8({
        sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
    });
    IF_IOS8_OR_GREATER({
        sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    });
    sessionConfiguration.allowsCellularAccess = YES;
    sessionConfiguration.discretionary = NO;
    sessionConfiguration.networkServiceType = NSURLNetworkServiceTypeDefault;
    sessionConfiguration.timeoutIntervalForRequest = COMMUNICATION_TIMEOUT;

    self.urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                    delegate:self
                                               delegateQueue:[MCTComponentFramework commQueue]];
    return self.urlSession;
}

+ (NSString *)logForwardingURLSessionIdentifier
{
    return @"logForwarding";
}

- (NSURLSession *)initializeLogForwardingURLSession
{
    NSString *identifier = [MCTCommunicationManager logForwardingURLSessionIdentifier];
    NSURLSessionConfiguration *sessionConfiguration = nil;
    IF_PRE_IOS8({
        sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
    });
    IF_IOS8_OR_GREATER({
        sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    });
    sessionConfiguration.networkServiceType = NSURLNetworkServiceTypeDefault;
    sessionConfiguration.HTTPShouldUsePipelining = YES;
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 1;

    self.logForwardingURLSession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                                 delegate:self
                                                            delegateQueue:[MCTComponentFramework commQueue]];
    return self.logForwardingURLSession;
}

- (void)terminate
{
    T_BACKLOG();
    HTTPHERE();
    [self.xmppConnection disconnect];
    [self.urlSession invalidateAndCancel];
    self.stopped = YES;
    [[MCTComponentFramework intentFramework] unregisterIntentListener:self];
}

#pragma mark -
#pragma mark messaging logic

- (NSString *)createJSONRequestStringForOutgoingCallsWithFilterOnWifiOnly:(BOOL)filterOnWifiOnly
{
    T_BACKLOG();
    NSMutableString *callArrayStr = [NSMutableString stringWithString:@"["];
    BOOL firstOutgoingCall = YES;

    MCTBacklogStreamer *streamer = [self.backlog backlogStreamerWithFilterOnWifiOnly:filterOnWifiOnly];
    MCTBacklogItem *item;

    while (YES) {
        if ((item = [streamer next]) == nil)
            break;

        if (item.type == MCT_BACKLOG_MESSAGE_TYPE_CALL) {
            if (!firstOutgoingCall) {
                MCTlong size = [callArrayStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1 + [item.body lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                if (size > MCT_MAX_PACKET_SIZE) {
                    HTTPLOG(@"Reached limit of backlog data size");
                    break;
                }

                [callArrayStr appendString:@","];
            }

            firstOutgoingCall = NO;
            [callArrayStr appendString:item.body];
        } else {
            HTTPERROR(@"Illegal backlogitem type [%d] for callid [%@]", item.type, item.callid);
        }
    }

    [streamer close];

    [callArrayStr appendString:@"]"];

    return callArrayStr;
}

- (NSString *)createJSONRequestStringForOutgoingResponses:(NSArray *)callids
{
    T_BACKLOG();

    if (callids == nil)
        return @"[]";

    NSMutableString *responseArrayStr = [NSMutableString stringWithString:@"["];
    BOOL responseArrayNeedsComma = NO;

    NSString *callid;
    for (callid in callids) {
        NSString *body = [self.backlog bodyForCallid:callid];
        if (body != nil) {
            if (responseArrayNeedsComma)
                [responseArrayStr appendString:@","];

            responseArrayNeedsComma = YES;
            [responseArrayStr appendString:body];
        }
    }

    [responseArrayStr appendString:@"]"];

    return responseArrayStr;
}

// Check if network is up
// Read (batch of) CS calls from backlog
// Format request to server
// Do request to server
// Receive response from server
// Process response from server (which can alter backlog)
// If there is more or new stuff to send to server, or if server has more for client, redo communication
//    in this case, include responses to incoming server calls
// In case of network failures, stop communication
// In case there is nothing more to do, stop communication
- (void)communicate
{
    T_BACKLOG();
    HTTPHERE();

    if (self.communicating) {
        HTTPLOG(@"Skipping duplicate communication request");
        return;
    } else if (MCT_USE_XMPP_KICK_CHANNEL && [self.xmppConnection getAnalysingAndSetKickOnNextAnalyseIfAnalising:YES]) {
        HTTPLOG(@"XMPP connection is analysing... Skipping communication request");
        return;
    }
    self.communicating = YES;

    if (![MCTUtils connectedToInternet]) {
        HTTPLOG(@"Cannot communicate with server - no network");
        [self stopCommunicationCycleWithStatus:MCTCommunicationResultDisconnected loopCount:0];
        return;
    }

    [[MCTComponentFramework intentFramework] broadcastIntent:[MCTIntent intentWithAction:kINTENT_BACKLOG_STARTED]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    MCTCommunicationLoop *firstLoop = [MCTCommunicationLoop loopWithCount:1];
    firstLoop.force = YES;
    [self startCommunicationLoop:firstLoop];
}

- (void)startCommunicationBackgroundTask
{
    if (self.communicationBgTask == UIBackgroundTaskInvalid) {
        self.communicationBgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"-[MCTCommunicationManager communicate]"
                                                                                expirationHandler:^{
                                                                                    T_UI();
                                                                                    LOG(@"In expirationHandler of -[MCTCommunicationManager communicate]");
                                                                                    [[MCTComponentFramework commQueue] addOperationWithBlock:^{
                                                                                        [self stopCommunicationCycleWithStatus:MCTCommunicationResultError loopCount:-1];
                                                                                    }];
                                                                                }];
    }

    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        HTTPLOG(@"application.backgroundTimeRemaining = %f", [UIApplication sharedApplication].backgroundTimeRemaining);
    }
}

- (void)endCommunicationBackgroundTask
{
    if (self.communicationBgTask != UIBackgroundTaskInvalid) {
        LOG(@"Ending MCTCommunicationManager background task: %d", self.communicationBgTask);
        [[UIApplication sharedApplication] endBackgroundTask:self.communicationBgTask];
        self.communicationBgTask = UIBackgroundTaskInvalid;
    }
}

- (void)stopCurrentCommunicationCycleForErrorWithLoopCount:(int)loopCount
{
    T_BACKLOG();
    [self stopCommunicationCycleWithStatus:MCTCommunicationResultError loopCount:loopCount];
}

- (NSString *)descriptionOfCommunicationResult:(MCTCommunicationResult)report
{
    T_DONTCARE();
    switch (report) {
        case MCTCommunicationResultConnecting:
            return @"connecting";
        case MCTCommunicationResultDisconnected:
            return @"disconnected";
        case MCTCommunicationResultError:
            return @"error";
        case MCTCommunicationResultSuccess:
            return @"success";

        default:
            return @"undefined";
    }
}

- (void)stopCommunicationCycleWithStatus:(MCTCommunicationResult)report loopCount:(int)loopCount
{
    T_BACKLOG();
    HTTPLOG(@"Stop communication cycle with report status '%@' (self.communicating=%@)",
            [self descriptionOfCommunicationResult:report], BOOLSTR(self.communicating));
    HTTPLOG(@"--------------------------------------------------------------------------");

    // we need to broadcast if we did not connect during analysing:
    // * to remove spinner when waiting for incoming message
    // * to call background fetchCompletionHandler
    if (self.communicating) {
        MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_BACKLOG_FINISHED];
        [intent setLong:report forKey:@"status"];
        [intent setLong:loopCount forKey:@"loopCount"];
        [[MCTComponentFramework intentFramework] broadcastIntent:intent];
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    // Asking for some background time in case of failure, or stopping background time in case of success.
    NSTimeInterval fetchInterval;

    if (report != MCTCommunicationResultSuccess) {
        fetchInterval = 300.0; // 5 minutes
        HTTPLOG(@"MCTCommunicationManager backgroundFetchInterval: %f", fetchInterval);
    } else if (!MCT_USE_XMPP_KICK_CHANNEL && [[MCTComponentFramework appDelegate] failedToRegisterForRemoteNotifications]) {
        fetchInterval = 7200.0; // 2 hours
        HTTPLOG(@"MCTCommunicationManager backgroundFetchInterval: %f", fetchInterval);
    } else {
        fetchInterval = UIApplicationBackgroundFetchIntervalNever;
        HTTPLOG(@"MCTCommunicationManager backgroundFetchInterval: UIApplicationBackgroundFetchIntervalNever");
    }

    [[MCTComponentFramework systemPlugin] setBackgroundFetchInterval:fetchInterval];

    self.communicating = NO;
    [self endCommunicationBackgroundTask];

    if (MCT_USE_XMPP_KICK_CHANNEL && report != MCTCommunicationResultSuccess) {
        self.xmppConnection.kickOnNextAnalyse = YES;
    }
}

// TODO: do not keep re-sending the same calls/responses to server forever. we should
//       keep track of the callids and send them at most once (+ maybe the ACK)
// TODO: in case of network or other error: what is the behaviour?

// if (loop.force == YES), then communicate in any case
// if (loop.force == NO) and (there are no outgoing calls in local backlog) and (there are no responses to send)
//                       and (there are no acks to send), then do not communicate
- (void)startCommunicationLoop:(MCTCommunicationLoop *)loop
{
    T_BACKLOG();
    HTTPLOG(@"Starting communication loop %d", loop.count);
    [self startCommunicationBackgroundTask];

    BOOL filterOnWifiOnly = [[NSUserDefaults standardUserDefaults] boolForKey:MCT_SETTINGS_TRANSFER_WIFI_ONLY] && ![MCTUtils connectedToWifi];

    NSString *callArrayString = [self createJSONRequestStringForOutgoingCallsWithFilterOnWifiOnly:filterOnWifiOnly];
    BOOL hasNoOutgoingCallsInBacklog = [callArrayString isEqualToString:@"[]"];
    HTTPLOG(@"Has no outgoing calls in backlog = %@", BOOLSTR(hasNoOutgoingCallsInBacklog));

    if (loop.count == MAX_COMMUNICATION_COUNT || (!loop.force && [self.protocol.responsesToSend count] == 0
            && [self.protocol.acksToSend count] == 0 && hasNoOutgoingCallsInBacklog)) {

        if (loop.count == MAX_COMMUNICATION_COUNT) {
            NSString *reason = [NSString stringWithFormat:@"Reached max amount of communication cycles (%d)!",
                                MAX_COMMUNICATION_COUNT];
            HTTPLOG(@"%@", reason);
            NSException *e = [NSException exceptionWithName:@"MaxCommunicationCountReached"
                                                     reason:reason
                                                   userInfo:nil];
            [MCTSystemPlugin logError:e withMessage:@"Max communication count reached"];
        } else {
            HTTPLOG(@"Communication finished");
        }

        [self.backlog doRetentionCleanup];
        [self stopCommunicationCycleWithStatus:MCTCommunicationResultSuccess loopCount:loop.count];
        return;
    }

    HTTPLOG(@"--------------------------------------------------------------------------");
    HTTPLOG(@"Executing communication loop [%d]", loop.count);

    NSString *ackArrayString = [self.protocol.acksToSend MCT_JSONRepresentation];
    NSString *responseArrayString = [self createJSONRequestStringForOutgoingResponses:self.protocol.responsesToSend];

    [self.protocol.responsesToSend removeAllObjects];
    [self.protocol.acksToSend removeAllObjects];

    NSString *jsonRequestStr = [NSString stringWithFormat:@"{\"av\":1,\"c\":%@,\"r\":%@,\"a\":%@}",
                                callArrayString, responseArrayString, ackArrayString];

    NSString *url = OR(self.protocol.alternativeUrl, self.protocol.defaultUrl);
    LOG(@"Sending request to %@\n%@", url, jsonRequestStr);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.allowsCellularAccess = YES;
    request.timeoutInterval = COMMUNICATION_TIMEOUT;
    request.HTTPMethod = @"POST";
    request.HTTPBody = [jsonRequestStr dataUsingEncoding:NSUTF8StringEncoding];
    [request addValue:@"application/json-rpc; charset=\"utf-8\"" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[[self.protocol headerCredentials] username] forHTTPHeaderField:@"X-MCTracker-User"];
    [request addValue:[[self.protocol headerCredentials] password] forHTTPHeaderField:@"X-MCTracker-Pass"];

    // Need to have a downloadTask (and no dataTask) to be able to run the requests from the background
    NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:request];
    IF_IOS8_OR_GREATER({
        task.priority = 1.0;
    });

    self.currentRequestId = [MCTUtils guid];
    task.taskDescription = [@{@"loopCount": @(loop.count),
                              @"requestId": self.currentRequestId,
                              @"urlStr": url} MCT_JSONRepresentation];
    [task resume];

#if MCT_DEBUG
    LOG(@"currentRequestId: %@", self.currentRequestId);
#endif
    self.force = NO;

    [self endCommunicationBackgroundTask];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)       URLSession:(NSURLSession *)session
             downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    T_BACKLOG();

#if MCT_DEBUG
    LOG(@"Download request finished: %@", downloadTask.taskDescription);
    LOG(@"Current requestId: %@", self.currentRequestId);
#endif

    if (session != self.urlSession) {
        [[NSFileManager defaultManager] removeItemAtURL:location error:nil];
        return;
    }

    if (((NSHTTPURLResponse *)downloadTask.response).statusCode != 200) {
        // Will be handled by URLSession:task:didCompleteWithError:
        [[NSFileManager defaultManager] removeItemAtURL:location error:nil];
        return;
    }

    NSDictionary *taskInfo = [downloadTask.taskDescription MCT_JSONValue];
    NSString *requestId = taskInfo[@"requestId"];

    if (self.currentRequestId == nil || ![self.currentRequestId isEqualToString:requestId]) {
        LOG(@"%@ != %@", self.currentRequestId, requestId);
        [[NSFileManager defaultManager] removeItemAtURL:location error:nil];
        return;
    }
    self.currentRequestId = nil;

    HTTPHERE();
    [self startCommunicationBackgroundTask];

    int count = [taskInfo[@"loopCount"] intValue];
    MCTCommunicationLoop *loop = [MCTCommunicationLoop loopWithCount:count];
    NSError *error = nil;
    loop.responseStr = [NSString stringWithContentsOfURL:location
                                                encoding:NSUTF8StringEncoding
                                                   error:&error];

    [[NSFileManager defaultManager] removeItemAtURL:location error:nil];

    if (error) {
        ERROR(@"Failed to read backlog response:\n%@", error);
        [self stopCommunicationCycleWithStatus:MCTCommunicationResultError
                                     loopCount:count];
        return;
    }

    HTTPLOG(@"getting response:\n%@", loop.responseStr);
    int communicationStatus;

    if (loop.responseStr == nil) {
        HTTPLOG(@"Error during communication to server");
        communicationStatus = COMMUNICATION_ERROR;
    } else if ([self.protocol processIncomingMessagesStr:loop.responseStr]) {
        communicationStatus = COMMUNICATION_SERVER_HAS_MORE;
    } else {
        communicationStatus = COMMUNICATION_CONTINUE;
    }

    if (communicationStatus == COMMUNICATION_ERROR) {
        [self stopCommunicationCycleWithStatus:MCTCommunicationResultError loopCount:loop.count];
    } else {
        // Start next loop
        self.xmppConnection.kickOnNextAnalyse = NO;
        MCTCommunicationLoop *nextLoop = [MCTCommunicationLoop loopWithCount:loop.count + 1];
        nextLoop.force = (communicationStatus == COMMUNICATION_SERVER_HAS_MORE) || self.force;
        [self startCommunicationLoop:nextLoop];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    T_BACKLOG();
    NSDictionary *taskInfo = [task.taskDescription MCT_JSONValue];
    if ([taskInfo[@"logForwarding"] boolValue]) {
        NSString *fileToBeRemoved = [taskInfo objectForKey:@"rm-file"];
        if (fileToBeRemoved) {
            [[NSFileManager defaultManager] removeItemAtPath:fileToBeRemoved error:nil];
        }
        return;
    }

    if (session != self.urlSession) {
        return;
    }

    if (error == nil && ((NSHTTPURLResponse *)task.response).statusCode == 200) {
        return; // URLSession:downloadTask:didFinishDownloadingToURL: will handle the happy path
    }

    NSString *requestId = taskInfo[@"requestId"];
    if (self.currentRequestId == nil || ![self.currentRequestId isEqualToString:requestId]) {
        LOG(@"%@ != %@", self.currentRequestId, requestId);
        return;
    }
    self.currentRequestId = nil;

    if (![self.protocol.defaultUrl isEqualToString:taskInfo[@"urlStr"]]) {
        if ([MCTUtils connectedToInternet]) {
            HTTPLOG(@"Re-do communication to default URL");
            [self.protocol resetDestinationUrl];
            MCTCommunicationLoop *loop = [MCTCommunicationLoop loopWithCount:[taskInfo[@"loopCount"] intValue]];
            loop.force = YES;
            [self startCommunicationLoop:loop];
            return;
        } else {
            HTTPLOG(@"Will not re-do communication to default URL - no network");
        }
    }

    HTTPLOG(@"task %@ failed with error %@", task, error);
    [self stopCommunicationCycleWithStatus:MCTCommunicationResultError loopCount:[taskInfo[@"loopCount"] intValue]];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    T_BACKLOG();
    if (session != self.urlSession)
        return;

    if (MCT_DEBUG_LOGGING) {
        HTTPLOG(@"Backlog resuming at %lld/%lld (%d%%)", fileOffset, expectedTotalBytes,
                expectedTotalBytes ? (100 * fileOffset / expectedTotalBytes) : 100);
    }
}

- (void)        URLSession:(NSURLSession *)session
              downloadTask:(NSURLSessionDownloadTask *)downloadTask
              didWriteData:(int64_t)bytesWritten
        totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    T_BACKLOG();
    if (session != self.urlSession)
        return;

    if (MCT_DEBUG_LOGGING) {
        HTTPLOG(@"Backlog DOWNLOAD progress: %lld/%lld (%d%%)", totalBytesWritten, totalBytesExpectedToWrite,
                totalBytesExpectedToWrite ? (100 * totalBytesWritten / totalBytesExpectedToWrite) : 100);
    }
}

- (void)        URLSession:(NSURLSession *)session
                      task:(NSURLSessionTask *)task
           didSendBodyData:(int64_t)bytesSent
            totalBytesSent:(int64_t)totalBytesSent
  totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    T_BACKLOG();
    if (session != self.urlSession)
        return;

    if (MCT_DEBUG_LOGGING) {
        HTTPLOG(@"Backlog UPLOAD progress: %lld/%lld (%d%%)", totalBytesSent, totalBytesExpectedToSend,
                totalBytesExpectedToSend ? (100 * totalBytesSent / totalBytesExpectedToSend) : 100);
    }
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    T_BACKLOG();
    HTTPHERE();
    if (!error) {
        return; // session has been explicitly invalidated
    }

    HTTPLOG(@"URL session %@ did become invalid with error: %@", session.configuration.identifier, error);
    if (session.configuration.identifier == [MCTCommunicationManager URLSessionIdentifier]) {
        [self initializeURLSession];
    } else if (session.configuration.identifier == [MCTCommunicationManager logForwardingURLSessionIdentifier]) {
        [self initializeLogForwardingURLSession];
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    T_BACKLOG();
    HTTPHERE();
    [[MCTComponentFramework appDelegate] callCompletionHandlerForSession:session.configuration.identifier];
}


#pragma mark - MCTXMPPConnectionDelegate

- (void)xmppConnected
{
    T_DONTCARE();
    HTTPHERE();
    [self kick];
}

- (void)xmppDisconnectedWithWasAnalysing:(BOOL)wasAnalysing
{
    T_DONTCARE();
    HTTPHERE();
    LOG(@"XMPP channel disconnected");
}

- (void)log:(NSString *)msg toXmppAccount:(NSString *)target
{
    T_DONTCARE();
    NSString *t = [target copy];
    NSString *s = [msg copy];
    NSURLSession *session = self.logForwardingURLSession;
    dispatch_block_t block = ^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:MCT_LOG_FORWARDING_URL];
        [request addValue:@"application/json; charset=\"utf-8\"" forHTTPHeaderField:@"Content-Type"];

        NSDictionary *postParams = @{@"jid": t, @"message": s};
        NSError *error = nil;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:postParams options:kNilOptions error:&error];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDirectory = [paths objectAtIndex:0];
        NSString *fileName = [NSString stringWithUTF8String:mktemp((char *) [[cachesDirectory stringByAppendingPathComponent:@"log.XXXXXX"] UTF8String])];

        [postData writeToFile:fileName atomically:YES];

        if (!error) {
            request.HTTPMethod = @"POST";
            request.HTTPBody = postData;
            NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request
                                                                 fromFile:[NSURL fileURLWithPath:fileName]];
            task.taskDescription = [@{@"rm-file": fileName,
                                      @"logForwarding" : @(YES)} MCT_JSONRepresentation];
            [task resume];
        }
    };

    if (T_ON_COMM_QUEUE()) {
        block();
    } else {
        [[MCTComponentFramework commQueue] addOperationWithBlock:block];
    }
}


#pragma mark - IMCTIntentReceiver

// intent only raised and caught in this file
- (void)onIntent:(MCTIntent *)intent
{
    T_BACKLOG();
    HTTPLOG(@"Received intent %@", [intent action]);
    if (intent.action == kINTENT_KICK_BACKLOG) {
        if (self.stopped) {
            HTTPLOG(@"MCTCommunicationManager: received kick intent, but am already stopped");
            return;
        }
        if (self.communicating) {
            LOG(@"Already communicating");
            self.force = YES;
        } else {
            [self communicate];
        }
    } else if (intent.action == kINTENT_PUSH_NOTIFICATION_SETTINGS_UPDATED) {
        [self communicate];
    }
}

- (void)kick
{
    T_DONTCARE();
    [[MCTComponentFramework intentFramework] broadcastIntent:[MCTIntent intentWithAction:kINTENT_KICK_BACKLOG]];
}

@end