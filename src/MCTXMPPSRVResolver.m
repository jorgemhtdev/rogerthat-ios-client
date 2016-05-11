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

#import <CoreLocation/CoreLocation.h>

#import "MCTComponentFramework.h"
#import "MCTFriendLocationAnnotation.h"
#import "MCTFriendsPlugin.h"
#import "MCTGeoActionVerifyVC.h"
#import "MCTGeoActionVC.h"
#import "MCTHTTPRequest.h"
#import "MCTUIUtils.h"
#import "MCTXMPPSRVResolver.h"

#import "MCTJSONUtils.h"


@interface MCTXMPPSRVResolver ()

@property (nonatomic, weak) id<XMPPSRVResolverDelegate> delegate;
@property (nonatomic, weak) dispatch_queue_t delegateQueue;

@end



@implementation MCTXMPPSRVResolver


- (id)initWithdDelegate:(id)aDelegate delegateQueue:(dispatch_queue_t)dq resolverQueue:(dispatch_queue_t)rq
{
    if (self = [super initWithdDelegate:aDelegate delegateQueue:dq resolverQueue:rq]) {
        self.delegate = aDelegate;
        self.delegateQueue = dq;
    }
    return self;
}


- (void)startWithSRVName:(NSString *)aSRVName timeout:(NSTimeInterval)aTimeout
{
    if (![MCTUtils connectedToInternet]) {
        XMPPLOG(@"MCTXMPPSRVResolver: Not connected to internet");
        dispatch_async(self.delegateQueue, ^{
            [self.delegate xmppSRVResolver:self didNotResolveDueToError:nil];
        });
        return;
    }

    NSString *url = [NSString stringWithFormat:@"%@%@", MCT_HTTPS_BASE_URL, MCT_LOAD_SRV_RECORDS];

    MCTHTTPRequest *httpRequest = [MCTHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    httpRequest.timeOutSeconds = 5;
    httpRequest.delegate = self;
    httpRequest.didFailSelector = @selector(resolveAddressFailed:);
    httpRequest.didFinishSelector = @selector(resolveAddressFinished:);
    httpRequest.shouldRedirect = NO;
    httpRequest.validatesSecureCertificate = YES;
    [[MCTComponentFramework commQueue] addOperation:httpRequest];
}

- (void)resolveAddressFailed:(MCTHTTPRequest *)request
{
    T_UI();
    ERROR(@"Failed to resolve address: %@", request.error);

    dispatch_async(self.delegateQueue, ^{
        [self.delegate xmppSRVResolver:self didNotResolveDueToError:nil];
    });
}

- (void)resolveAddressFinished:(MCTHTTPRequest *)request
{
    T_UI();
    dispatch_async(self.delegateQueue, ^{
        NSString *jsonString = [request responseString];
        LOG(@"DNS SRV records: %@", jsonString);
        NSMutableArray *records = [NSMutableArray array];
        if ([[jsonString uppercaseString] hasPrefix:@"<HTML"]){
            LOG(@"Received HTML in DNS SRV call. Ignoring...");
            [self.delegate xmppSRVResolver:self didNotResolveDueToError:nil];
        }
        else{
            NSArray *json = [jsonString MCT_JSONValue];
            for (NSDictionary *ipAndPort in json) {
                [records addObject:[XMPPSRVRecord recordWithPriority:[ipAndPort longForKey:@"priority"]
                                                              weight:0
                                                                port:[ipAndPort longForKey:@"port"]
                                                              target:[ipAndPort stringForKey:@"ip"]]];
            }
            [self.delegate xmppSRVResolver:self didResolveRecords:records];
        }
    });
}

@end