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

#import "MCTBacklog.h"
#import "MCTRPCCall.h"
#import "MCTRPCResponse.h"
#import "MCTAbstractResponseHandler.h"
#import "MCTTransferObjects.h"
#import "MCTComponentFramework.h"
#import "MCTBacklogStreamer.h"


#define RESEND_TIMESTAMP_NEVER_SENT 0LL

#define PRIORITY_HIGH 1LL
#define PRIORITY_LOW  2LL
#define PRIORITY_ALREADY_SENT -1LL


static MCTlong PACKET_GRACETIME_MILLIS;
static MCTlong MESSAGE_LINGER_INTERVAL;
static MCTlong MESSAGE_ALLOWED_FUTURE_TIME_INTERVAL;
static MCTlong MESSAGE_RETENTION_INTERVAL;
static MCTlong DUPLICATE_AVOIDANCE_RETENTION_INTERVAL;

@implementation MCTBacklog

static sqlite3_stmt *deleteAllItemsStatement_;
static sqlite3_stmt *deleteItemStatement_;
static sqlite3_stmt *getBodyStatement_;
static sqlite3_stmt *getItemResponseHandlerStatement_;
static sqlite3_stmt *hasItemsToSendStatement_;
static sqlite3_stmt *insertItemStatement_;
static sqlite3_stmt *itemHasBodyStatement_;
static sqlite3_stmt *removePreviousUnsentCallsStatement_;
static sqlite3_stmt *runRetentionCleanupStatement_;
static sqlite3_stmt *singleCallsByFunctionStatement_;
static sqlite3_stmt *updateItemBodyStatement_;
static sqlite3_stmt *updateItemLastResendTimeStatement_;
static sqlite3_stmt *updateItemRetentionStatement_;
static sqlite3_stmt *backlogItemExists_;

#pragma mark -
#pragma mark clinit & constructor & destructor

+ (void)initialize
{
    T_BACKLOG();
    PACKET_GRACETIME_MILLIS = 30 * 1000;
    MESSAGE_LINGER_INTERVAL = 20 * 3600 * 24 * 1000;
    MESSAGE_ALLOWED_FUTURE_TIME_INTERVAL = 3600 * 24 * 1000;
    MESSAGE_RETENTION_INTERVAL = 3600 * 24 * 1000 + MESSAGE_LINGER_INTERVAL;
    DUPLICATE_AVOIDANCE_RETENTION_INTERVAL = 3600 * 24 * 1000;
}

- (BOOL)initPreparedStatements
{
    T_BACKLOG();
    @try {
        [self dbLockedOperationWithBlock:^{

            [self prepareStatement:&insertItemStatement_
                      withQueryKey:@"sql_backlog_insert"];

            [self prepareStatement:&updateItemLastResendTimeStatement_
                      withQueryKey:@"sql_backlog_update_last_resend"];

            [self prepareStatement:&updateItemRetentionStatement_
                      withQueryKey:@"sql_backlog_update_retention_timeout"];

            [self prepareStatement:&runRetentionCleanupStatement_
                      withQueryKey:@"sql_backlog_run_retention"];

            [self prepareStatement:&hasItemsToSendStatement_
                      withQueryKey:@"sql_backlog_exists"];

            [self prepareStatement:&itemHasBodyStatement_
                      withQueryKey:@"sql_backlog_has_body"];

            [self prepareStatement:&updateItemBodyStatement_
                      withQueryKey:@"sql_backlog_update_body"];

            [self prepareStatement:&deleteItemStatement_
                      withQueryKey:@"sql_backlog_delete_item"];

            [self prepareStatement:&getItemResponseHandlerStatement_
                      withQueryKey:@"sql_backlog_get_response_handler"];

            [self prepareStatement:&deleteAllItemsStatement_
                      withQueryKey:@"sql_backlog_delete_all"];

            [self prepareStatement:&getBodyStatement_
                      withQueryKey:@"sql_backlog_get_body"];

            [self prepareStatement:&removePreviousUnsentCallsStatement_
                      withQueryKey:@"sql_backlog_remove_previous_unsent_calls"];

            [self prepareStatement:&singleCallsByFunctionStatement_
                      withQueryKey:@"sql_backlog_singlecall_body"];

            [self prepareStatement:&backlogItemExists_
                      withQueryKey:@"sql_backlog_item_exist"];
        }];
    }
    @catch (SqlException *e) {
        return NO;
    }

    return YES;
}

- (void)destroyPreparedStatements
{
    T_BACKLOG();
    [self dbLockedOperationWithBlock:^{
        sqlite3_finalize(insertItemStatement_);
        sqlite3_finalize(updateItemLastResendTimeStatement_);
        sqlite3_finalize(updateItemRetentionStatement_);
        sqlite3_finalize(runRetentionCleanupStatement_);
        sqlite3_finalize(hasItemsToSendStatement_);
        sqlite3_finalize(itemHasBodyStatement_);
        sqlite3_finalize(updateItemBodyStatement_);
        sqlite3_finalize(deleteItemStatement_);
        sqlite3_finalize(getItemResponseHandlerStatement_);
        sqlite3_finalize(deleteAllItemsStatement_);
        sqlite3_finalize(getBodyStatement_);
        sqlite3_finalize(removePreviousUnsentCallsStatement_);
        sqlite3_finalize(singleCallsByFunctionStatement_);
        sqlite3_finalize(backlogItemExists_);
    }];
}

- (MCTBacklog *)init
{
    T_BACKLOG();
    if (self = [super init]) {
        self.dbMgr = [MCTComponentFramework backlogDbManager];
        if (![self initPreparedStatements]) {
            ERROR(@"Error initializing backlog");
            self = nil;
        }
    }
    return self;
}

- (void)dealloc
{
    T_BACKLOG();

    [self destroyPreparedStatements];
}

#pragma mark -
#pragma mark statements

- (BOOL)hasItemsToSend
{
    T_BACKLOG();
    __block MCTlong count;

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            if ((e = sqlite3_bind_int64(hasItemsToSendStatement_, 1, (sqlite3_int64)([MCTUtils currentTimeMillis] - PACKET_GRACETIME_MILLIS))) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_step(hasItemsToSendStatement_)) != SQLITE_ROW)
                MCT_THROW_SQL_EXCEPTION(e);

            count = sqlite3_column_int64(hasItemsToSendStatement_, 0);

            if ((e = sqlite3_step(hasItemsToSendStatement_)) != SQLITE_DONE)
                MCT_THROW_SQL_EXCEPTION(e);
        }
        @finally {
            sqlite3_reset(hasItemsToSendStatement_);
        }
    }];

    return (count != 0);
}

- (void)insertOutgoingRpcCall:(MCTRPCCall *)call
            withRequestString:(NSString *)requestString
          withResponseHandler:(MCTAbstractResponseHandler *)responseHandler
{
    T_BACKLOG();

    NSData *data = [MCTPickler pickleFromObject:responseHandler];

    [self dbLockedTransactionWithBlock:^{

        if ([call isSingleCall]) {
            @try {
                int e;

                sqlite3_bind_int(removePreviousUnsentCallsStatement_, 1, MCT_BACKLOG_MESSAGE_TYPE_CALL);
                sqlite3_bind_text(removePreviousUnsentCallsStatement_, 2, [call.function UTF8String], -1, NULL);

                if ((e = sqlite3_step(removePreviousUnsentCallsStatement_)) != SQLITE_DONE) {
                    LOG(@"Failed to remove previous unsent single call for function %@", call.function);
                    MCT_THROW_SQL_EXCEPTION(e);
                }
            }
            @finally {
                sqlite3_reset(removePreviousUnsentCallsStatement_);
            }
        } else if ([call isSpecialSingleCall]) {
            @try {
                int e;

                sqlite3_bind_text(singleCallsByFunctionStatement_, 1, [call.function UTF8String], -1, NULL);

                while ((e = sqlite3_step(singleCallsByFunctionStatement_)) != SQLITE_DONE) {
                    if (e != SQLITE_ROW) {
                        LOG(@"Failed to get backlog entries for single call %@", call.function);
                        MCT_THROW_SQL_EXCEPTION(e);
                    }

                    NSString *callId = [NSString stringWithUTF8StringSafe:sqlite3_column_text(singleCallsByFunctionStatement_, 0)];
                    NSString *callBody = [NSString stringWithUTF8StringSafe:sqlite3_column_text(singleCallsByFunctionStatement_, 1)];

                    if ([call isEqualToSpecialSingleCallWithBody:callBody]) {
                        [self deleteItem:callId];
                    }
                }
            }
            @finally {
                sqlite3_reset(singleCallsByFunctionStatement_);
            }
        }

        @try {
            int e;

            if ((e = sqlite3_bind_text(insertItemStatement_, 1, [call.callid UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e =sqlite3_bind_int64(insertItemStatement_, 2, MCT_BACKLOG_MESSAGE_TYPE_CALL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_int64(insertItemStatement_, 3, [MCTUtils currentTimeMillis])) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_text(insertItemStatement_, 4, [requestString UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            // TODO: use proper priorities based on the function?
            if ((e = sqlite3_bind_int64(insertItemStatement_, 5, PRIORITY_HIGH)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_int64(insertItemStatement_, 6, RESEND_TIMESTAMP_NEVER_SENT)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_int64(insertItemStatement_, 7, call.timestamp + MESSAGE_RETENTION_INTERVAL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_blob(insertItemStatement_, 8, [data bytes], (unsigned int)[data length], NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_text(insertItemStatement_, 9, [call.function UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_int(insertItemStatement_, 10, [call isWifiOnlyCall] ? 1 : 0)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_step(insertItemStatement_)) != SQLITE_DONE)
                MCT_THROW_SQL_EXCEPTION(e);
        }
        @finally {
            sqlite3_reset(insertItemStatement_);
        }
    }];
}

- (void)insertIncomingRpcCall:(MCTRPCCall *)call
{
    T_BACKLOG();

    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            if ((e = sqlite3_bind_text(insertItemStatement_, 1, [call.callid UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e =sqlite3_bind_int64(insertItemStatement_, 2, MCT_BACKLOG_MESSAGE_TYPE_RESPONSE)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_int64(insertItemStatement_, 3, call.timestamp)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_null(insertItemStatement_, 4)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_int64(insertItemStatement_, 5, PRIORITY_HIGH)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_int64(insertItemStatement_, 6, RESEND_TIMESTAMP_NEVER_SENT)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_int64(insertItemStatement_, 7, [MCTUtils currentTimeMillis] + MESSAGE_RETENTION_INTERVAL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_null(insertItemStatement_, 8)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_text(insertItemStatement_, 9, [call.function UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_int(insertItemStatement_, 10, [call isWifiOnlyCall] ? 1 : 0)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_step(insertItemStatement_)) != SQLITE_DONE) {
                if (e != SQLITE_CONSTRAINT) {
                    @try {
                        sqlite3_bind_text(backlogItemExists_, 1, [call.callid UTF8String], -1, NULL);

                        if (sqlite3_step(backlogItemExists_) == SQLITE_ROW) {
                            if (sqlite3_column_int(backlogItemExists_, 0) > 0) {
                                MCT_THROW_SQL_EXCEPTION(SQLITE_CONSTRAINT);
                            }
                        }
                    }
                    @finally {
                        sqlite3_reset(backlogItemExists_);
                    }
                }
                LOG(@"%d - Failed to insert call: %@", e, [call dictRepresentation]);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(insertItemStatement_);
        }

    }];

}

- (BOOL)itemHasBody:(NSString *)callid
{
    T_BACKLOG();
    __block MCTlong count;

    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            if ((e = sqlite3_bind_text(itemHasBodyStatement_, 1, [callid UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_step(itemHasBodyStatement_)) != SQLITE_ROW)
                MCT_THROW_SQL_EXCEPTION(e);

            count = sqlite3_column_int64(itemHasBodyStatement_, 0);

            if ((e = sqlite3_step(itemHasBodyStatement_)) != SQLITE_DONE)
                MCT_THROW_SQL_EXCEPTION(e);
        }
        @finally {
            sqlite3_reset(itemHasBodyStatement_);
        }

    }];

    return (count == 1);
}

- (void)updateBody:(MCTRPCResponse *)response
{
    T_BACKLOG();

    NSString *body = [[response dictRepresentation] MCT_JSONRepresentation];
    if (body == nil)
        @throw(JSON_EXCEPTION);

    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            if ((e = sqlite3_bind_text(updateItemBodyStatement_, 1, [body UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_text(updateItemBodyStatement_, 2, [response.callid UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_step(updateItemBodyStatement_)) != SQLITE_DONE)
                MCT_THROW_SQL_EXCEPTION(e);
        }
        @finally {
            sqlite3_reset(updateItemBodyStatement_);
        }

    }];
}

- (NSString *)bodyForCallid:(NSString *)callid
{
    T_BACKLOG();

    __block NSString *body = nil;

    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            if ((e = sqlite3_bind_text(getBodyStatement_, 1, [callid UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            e = sqlite3_step(getBodyStatement_);

            if (e == SQLITE_DONE) {
                LOG(@"No body for call %@", callid);
            } else if (e != SQLITE_ROW) {
                MCT_THROW_SQL_EXCEPTION(e);
            } else {
                body = [NSString stringWithUTF8StringSafe:sqlite3_column_text(getBodyStatement_, 0)];

                if ((e = sqlite3_step(getBodyStatement_)) != SQLITE_DONE)
                    MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(getBodyStatement_);
        }

    }];

    return body;
}

- (void)freezeRetentionForItem:(NSString *)callid
{
    T_BACKLOG();

    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            if ((e = sqlite3_bind_int64(updateItemRetentionStatement_, 1, [MCTUtils currentTimeMillis] + DUPLICATE_AVOIDANCE_RETENTION_INTERVAL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_text(updateItemRetentionStatement_, 2, [callid UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_step(updateItemRetentionStatement_)) != SQLITE_DONE)
                MCT_THROW_SQL_EXCEPTION(e);
        }
        @finally {
            sqlite3_reset(updateItemRetentionStatement_);
        }

    }];
}

- (void)updateLastResendTimestamp:(MCTlong)timestamp forCallid:(NSString *)callid
{
    T_BACKLOG();

    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            if ((e = sqlite3_bind_int64(updateItemLastResendTimeStatement_, 1, (sqlite3_int64)timestamp)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_text(updateItemLastResendTimeStatement_, 2, [callid UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_step(updateItemLastResendTimeStatement_)) != SQLITE_DONE)
                MCT_THROW_SQL_EXCEPTION(e);
        }
        @finally {
            sqlite3_reset(updateItemLastResendTimeStatement_);
        }

    }];
}

- (void)deleteItem:(NSString *)callid
{
    T_BACKLOG();

    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            if ((e = sqlite3_bind_text(deleteItemStatement_, 1, [callid UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_step(deleteItemStatement_)) != SQLITE_DONE)
                MCT_THROW_SQL_EXCEPTION(e);
        }
        @finally {
            sqlite3_reset(deleteItemStatement_);
        }

    }];
}

- (void)deleteAllItems
{
    T_BACKLOG();

    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            if ((e = sqlite3_step(deleteAllItemsStatement_)) != SQLITE_DONE)
                MCT_THROW_SQL_EXCEPTION(e);
        }
        @finally {
            sqlite3_reset(deleteAllItemsStatement_);
        }
    }];
}

- (MCTAbstractResponseHandler *)responseHandlerForCallid:(NSString *)callid
{
    T_BACKLOG();

    __block NSData *data = nil;

    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            if ((e = sqlite3_bind_text(getItemResponseHandlerStatement_, 1, [callid UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            e = sqlite3_step(getItemResponseHandlerStatement_);
            if (e == SQLITE_DONE) {
                ERROR(@"No responsehandler found for callid [%@]", callid);
            } else if (e != SQLITE_ROW) {
                MCT_THROW_SQL_EXCEPTION(e);
            } else {
                const void *blob = sqlite3_column_blob(getItemResponseHandlerStatement_, 0);
                int len = sqlite3_column_bytes(getItemResponseHandlerStatement_, 0);
                if ((blob == NULL) || (len == 0)) {
                    ERROR(@"No responsehandler found for callid [%@]", callid);
                } else {
                    data = [NSData dataWithBytes:blob length:len];

                    e = sqlite3_step(getItemResponseHandlerStatement_);
                    if (e != SQLITE_DONE)
                        MCT_THROW_SQL_EXCEPTION(e);
                }
            }
        }
        @finally {
            sqlite3_reset(getItemResponseHandlerStatement_);
        }
    }];

    LOG(@"returning unpickled object");
    return (MCTAbstractResponseHandler *)[MCTPickler objectFromPickle:data];
}

- (void)doRetentionCleanup
{
    T_BACKLOG();

    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            if ((e = sqlite3_bind_int64(runRetentionCleanupStatement_, 1, [MCTUtils currentTimeMillis])) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_step(runRetentionCleanupStatement_)) != SQLITE_DONE)
                MCT_THROW_SQL_EXCEPTION(e);
        }
        @finally {
            sqlite3_reset(runRetentionCleanupStatement_);
        }

    }];
}

- (MCTBacklogStreamer *)backlogStreamerWithFilterOnWifiOnly:(BOOL)filterOnWifiOnly
{
    T_BACKLOG();
    NSString *queryKey = filterOnWifiOnly ? @"sql_backlog_batch_wifi_only" : @"sql_backlog_batch";
    NSString *sqlBacklogBatch = [[[MCTComponentFramework dbManager] queries] objectForKey:queryKey];

    return [[MCTBacklogStreamer alloc] initForDB:self.dbMgr.writeableDB
                                        andSQLStr:[sqlBacklogBatch UTF8String]
                                  andMaxtimestamp:([MCTUtils currentTimeMillis] - PACKET_GRACETIME_MILLIS)];
}

@end