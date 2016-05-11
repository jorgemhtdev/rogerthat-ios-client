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


#import "MCTBacklogStreamer.h"
#import "MCTBacklog.h"
#import "MCTComponentFramework.h"


@implementation MCTBacklogStreamer


- (BOOL)initPreparedStatements
{
    T_BACKLOG();

    DB_LOCKED_OPERATION({

        int e;

        if ((e = sqlite3_prepare_v2(self.db, self.retrieveBatchSQLStr, -1, & _retrieveBatchPreparedStatement, NULL)) != SQLITE_OK)
            return NO;

        if ((e = sqlite3_bind_int64(self.retrieveBatchPreparedStatement, 1, self.maxTimestamp)) != SQLITE_OK)
            return NO;

    });

    return YES;
}

- (void)destroyPreparedStatements
{
    T_BACKLOG();

    DB_LOCKED_OPERATION({

        if (self.retrieveBatchPreparedStatement) {
            sqlite3_finalize(self.retrieveBatchPreparedStatement);
            self.retrieveBatchPreparedStatement = NULL;
        }

    });
}

- (MCTBacklogStreamer *)initForDB:(sqlite3 *)db andSQLStr:(const char *)SQLStr andMaxtimestamp:(MCTlong)maxTimestamp
{
    T_BACKLOG();
    self = [super init];
    if (self != nil) {
        self.db = db;
        self.retrieveBatchSQLStr = SQLStr;
        self.maxTimestamp = maxTimestamp;
        if (![self initPreparedStatements])
            BUG(@"Error in Backlog Streamer initPreparedStatements");
    }
    return self;
}

- (MCTBacklogItem *)next
{
    T_BACKLOG();
    MCTBacklogItem *item;

    DB_LOCKED_OPERATION({

        // NOTE: here we do not reset the sqlite state machine since we step through the result

        int e;

        e = sqlite3_step(self.retrieveBatchPreparedStatement);

        if (e == SQLITE_DONE)
            return nil;

        if (e != SQLITE_ROW) {
            ERROR(@"Error during streaming backlog: [%d]", e);
            return nil;
        }

        item = [MCTBacklogItem item];
        item.callid = [NSString stringWithUTF8StringSafe:sqlite3_column_text(self.retrieveBatchPreparedStatement, 0)];
        item.type = sqlite3_column_int64(self.retrieveBatchPreparedStatement, 1);
        item.body = [NSString stringWithUTF8StringSafe:sqlite3_column_text(self.retrieveBatchPreparedStatement, 2)];
        item.timestamp = sqlite3_column_int64(self.retrieveBatchPreparedStatement, 3);

    });

    return item;
}

- (void)close
{
    T_BACKLOG();
    [self destroyPreparedStatements];
}

- (void)dealloc
{
    T_BACKLOG();
    [self close];
    
}

@end