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

#import "MCTRPCProtocol.h"
#import "MCTUtils.h"
#import "MCTJSONUtils.h"
#import "MCTCallReceiver.h"
#import "MCTTransferObjects.h"
#import "MCTRPCResponse.h"
#import "MCTResultParser.h"
#import "MCTComponentFramework.h"
#import "MCTIntent.h"

#define MCT_CONFIG_KEY_AP @"ap"

#define BEGIN_LOOP_DICT_IN_ARRAY(dict, array) \
{ \
NSArray *_loop_array = (array); \
if ((_loop_array) != nil) { \
for (NSDictionary *dict in (_loop_array)) { \
if ([dict isKindOfClass:[NSDictionary class]])

#define END_LOOP_DICT_IN_ARRAY \
else \
{ \
ERROR(@"Expect dictionary object in array enumeration"); \
} \
} \
} \
}

#define BEGIN_LOOP_STRING_IN_ARRAY(str, array) \
{ \
    NSArray *_loop_array = (array); \
    if ((_loop_array) != nil) { \
        for (NSString *str in (_loop_array)) { \
            if ([str isKindOfClass:[NSString class]])

#define END_LOOP_STRING_IN_ARRAY \
else \
{ \
ERROR(@"Expect string object in array enumeration"); \
} \
} \
} \
}


@implementation MCTRPCProtocol


#pragma mark -
#pragma mark initialization & destruction

- (id)init
{
    if (self = [super init]) {
        NSString *alt = [[MCTComponentFramework configProvider] stringForKey:MCT_CONFIG_KEY_AP];
        if (![MCTUtils isEmptyOrWhitespaceString:alt])
            self.alternativeUrl = alt;
        self.defaultUrl = [MCT_HTTPS_BASE_URL stringByAppendingString:MCT_RPC_URL];
    }
    return self;
}

- (void)setCredentials:(MCTCredentials *)newCredentials
{
    T_BACKLOG();
    if (newCredentials != self.credentials)
    {
        _credentials = newCredentials;

        MCTCredentials *newHeaderCredentials = [MCTCredentials credentials];
        newHeaderCredentials.username = [_credentials.username MCTBase64Encode];
        newHeaderCredentials.password = [_credentials.password MCTBase64Encode];
        self.headerCredentials = newHeaderCredentials;
    }
}

- (void)resetDestinationUrl
{
    T_BACKLOG();
    [[MCTComponentFramework configProvider] deleteStringForKey:MCT_CONFIG_KEY_AP];
    MCT_RELEASE(self.alternativeUrl);
}

#pragma mark -
#pragma mark protocol

- (BOOL)processIncomingCall:(MCTRPCCall *)call
{
    T_BACKLOG();

    @try {
        [self.backlog insertIncomingRpcCall:call];
    }
    @catch (SqlConstraintException *e) {
        LOG(@"Duplicate key constraint violation");
        if([self.backlog itemHasBody:call.callid]) {
            [self onCallProcessed:call.callid];
            return NO;
        } else {
            LOG(@"Duplicate processing of call [%@]", call.callid);
        }
    }
    @catch (SqlException *e) {
        [MCTSystemPlugin logError:e withMessage:nil];
        return NO;
    }
    @catch (NSException *e) {
        [MCTSystemPlugin logError:e withMessage:nil];
        return NO;
    }

    MCTRPCResponse *response = [MCTRPCResponse response];
    response.timestamp = call.timestamp;
    response.callid = call.callid;

    NSString *error = nil;
    id<IJSONable> result = nil;
    @try {
        result = [self.callReceiver processIncomingCall:call];
    }
    @catch (MCTBizzException *e) {
        error = [NSString stringWithFormat:@"%@: %@", e.name, e.reason];
    }
    @catch (NSException *e) {
        [MCTSystemPlugin logError:e withMessage:nil];
        error = @"Error while processing incoming call";
    }

    response.error = error;
    if (result != nil) {
        if (result == MCTNull) // TODO: nil?
            response.resultDict = nil;
        else
            response.resultDict = [result dictRepresentation];
        response.success = YES;
    } else {
        response.success = NO;
        response.resultDict = nil;
    }

    [self.backlog updateBody:response];
    [self onCallProcessed:response.callid];

    return YES;
}

- (BOOL)processIncomingResponse:(MCTRPCResponse *)response
{
    T_BACKLOG();
    HERE();
    LOG(@"Processing incoming response: %@", response);
    BOOL processed = NO;
    @try {
        HERE();
        MCTAbstractResponseHandler *rh = [self.backlog responseHandlerForCallid:response.callid];
        if (rh == nil) {
            // ResponseHandler not found. Could for example be a singlecall (e.g. getFriends during initial install)
            LOG(@"Cannot find backlog item for incoming response for callid %@", response.callid);
        } else {
            [[MCTComponentFramework workQueue] addOperationWithBlock:^{
                if (response.success) {
                    id result;
                    if (response.resultDict == nil)
                        result = nil;
                    else
                        result = [MCTResultParser resultObjectFromResultDict:response.resultDict forFunction:rh.function];
                    [rh handleResult:result];
                } else {
                    [rh handleError:response.error];
                }
            }];
            processed = YES;
        }
    }
    @catch (NSException *e) {
        [MCTSystemPlugin logError:e withMessage:@"Error processing response"];
    }

    [self.backlog deleteItem:response.callid];
    [self onResponseProcessed:response.callid];
    return processed;
}

- (BOOL)processIncomingAck:(NSString *)callid
{
    T_BACKLOG();
    LOG(@"received ack for callid %@", callid);
    @try {
        [self.backlog freezeRetentionForItem:callid];
    }
    @catch (SqlException * e) {
        [MCTSystemPlugin logError:e withMessage:[NSString stringWithFormat:@"Error processing incoming ack %@", callid]];
        return NO;
    }

    return YES;
}

// Returns: whether server has_more to send to client
- (BOOL)processIncomingMessagesDict:(NSDictionary *)dict
{
    T_BACKLOG();
    if (![dict containsBoolObjectForKey:@"more"]) {
        ERROR(@"\"more\" not present in server response");
        return NO;
    }

    BOOL serverHasMore = [dict boolForKey:@"more"];

    if ([dict containsKey:@"r"])
        BEGIN_LOOP_DICT_IN_ARRAY(respdict, [dict arrayForKey:@"r"]) {
            @try {
                MCTRPCResponse *resp = [MCTRPCResponse responseWithDict:respdict];
                if (resp == nil)
                    ERROR(@"Received unparseable response from server: %@", respdict);
                else
                    [self processIncomingResponse:resp];
            }
            @catch (NSException *e) {
                [MCTSystemPlugin logError:e withMessage:[NSString stringWithFormat:@"Problems processing resp %@",
                                                         [respdict MCT_JSONRepresentation]]];
            }
        } END_LOOP_DICT_IN_ARRAY

    if ([dict containsKey:@"c"])
        BEGIN_LOOP_DICT_IN_ARRAY(calldict, [dict arrayForKey:@"c"]) {
            @try {
                MCTRPCCall *call = [MCTRPCCall callWithDict:calldict];
                if (call == nil)
                    ERROR(@"Received unparseable call from server %@", calldict);
                else
                    [self processIncomingCall:call];
            }
            @catch (NSException *e) {
                [MCTSystemPlugin logError:e withMessage:[NSString stringWithFormat:@"Problems processing call %@",
                                                         [calldict MCT_JSONRepresentation]]];
            }
        } END_LOOP_DICT_IN_ARRAY

    if ([dict containsKey:@"a"])
        BEGIN_LOOP_STRING_IN_ARRAY(callid, [dict arrayForKey:@"a"]) {
            @try {
                [self processIncomingAck:callid];
            }
            @catch (NSException *e) {
                [MCTSystemPlugin logError:e withMessage:[NSString stringWithFormat:@"Problems processing ack %@",
                                                         callid]];
            }
        } END_LOOP_STRING_IN_ARRAY

    return serverHasMore;
}

// Returns: whether server has_more to send to client
- (BOOL)processIncomingMessagesStr:(NSString *)messagesStr
{
    T_BACKLOG();
    if (messagesStr == nil) {
        ERROR(@"messageStr is nil");
        return NO;
    }

    id jsonValue = [messagesStr MCT_JSONValue];
    if (jsonValue == nil) {
        ERROR(@"Cannot parse json");
        return NO;
    }

    if ([jsonValue isKindOfClass:[NSArray class]]) {
        ERROR(@"json is array, expect dict");
        return NO;
    }

    NSDictionary *dict = jsonValue;

    if (![dict containsKey:@"av"]) {
        ERROR(@"No protocol version found");
        return NO;
    }

    long protocolVersion = [dict longForKey:@"av"];
    if (protocolVersion != MCT_PROTOCOL_VERSION) {
        ERROR(@"Cannot parse protocol version [%d] - expecting [%d]", protocolVersion, MCT_PROTOCOL_VERSION);
        return NO;
    }

    if ([dict containsKey:@"ap"]) {
        NSString *newApUrl = [dict stringForKey:@"ap"];
        if (![newApUrl isEqualToString:self.alternativeUrl]) {
            [[MCTComponentFramework configProvider] setString:newApUrl forKey:MCT_CONFIG_KEY_AP];
            self.alternativeUrl = newApUrl;
        }
    }

    BOOL serverHasMore = [self processIncomingMessagesDict:dict];

    return serverHasMore;
}

- (void)onCallProcessed:(NSString *)callid
{
    T_BACKLOG();
    LOG(@"onCallProcessed for callid %@", callid);
    [self.responsesToSend addObject:callid];
}

- (void)onResponseProcessed:(NSString *)callid
{
    T_BACKLOG();
    LOG(@"onResponseProcessed for callid %@", callid);
    [self.acksToSend addObject:callid];
}

- (void)callToServerWithFunction:(NSString *)function andArguments:(NSDictionary *)arguments andResponseHandler:(MCTAbstractResponseHandler *)responseHandler
{
    T_BACKLOG();
    responseHandler.function = function;

    MCTRPCCall *call = [MCTRPCCall call];
    call.callid = [MCTUtils guid];
    call.function = function;
    call.timestamp = [MCTUtils currentTimeMillis];
    call.arguments = arguments;

    NSString *requestStr = [[call dictRepresentation] MCT_JSONRepresentation];

    if (requestStr == nil) {
        ERROR(@"Cannot make JSON from outgoing call for function [%@]", function);
        return;
    }
    NSInteger size = [requestStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (size > MCT_MAX_PACKET_SIZE) {
        if ([function isEqualToString:@"com.mobicage.api.system.logError"]) {
            ERROR(@"Outgoing call too big! %@ size: %d bytes", function, size);
        } else {
            [MCTSystemPlugin logError:[NSException exceptionWithName:@"Outgoing call too big"
                                                              reason:function
                                                            userInfo:nil]
                          withMessage:[NSString stringWithFormat:@"size: %ld bytes", (long)size]];
        }
        return;
    }

    [self.backlog insertOutgoingRpcCall:call withRequestString:requestStr withResponseHandler:responseHandler];

    [[MCTComponentFramework commManager] kick];
}

@end