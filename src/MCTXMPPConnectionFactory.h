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

#import "GCDAsyncSocket.h"
#import "XMPPSRVResolver.h"

@class MCTXMPPConnectionFactory;


@protocol MCTXMPPConnectionFactoryDelegate <NSObject>

- (void)connectionFactory:(MCTXMPPConnectionFactory *)factory didFindGoodSrvResult:(XMPPSRVRecord *)record;
- (void)connectionFactoryDidNotFindGoodSrvResult:(MCTXMPPConnectionFactory *)factory;

@end


#pragma mark -

@interface MCTXMPPConnectionFactory : NSObject <GCDAsyncSocketDelegate>

@property dispatch_source_t waitForPreferredPortTimer;

@property (nonatomic, weak) id <MCTXMPPConnectionFactoryDelegate> delegate;

- (id)initWithDelegate:(id <MCTXMPPConnectionFactoryDelegate>)delegate andSrvRecords:(NSArray *)srvRecords xmppQueue:(dispatch_queue_t)xmppQueue;
- (void)findGoodConnection;

@end


#pragma mark -

@interface XMPPSRVRecord (MCTXMPPConnectionFactory)

- (NSString *)hostName;

@end