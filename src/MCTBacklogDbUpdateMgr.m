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

#import "MCTBacklogDbUpdateMgr.h"
#import "MCTComponentFramework.h"


@implementation MCTBacklogDbUpdateMgr


- (void)dealloc
{
    self.dbMgr = nil;
}

- (void)update_0_to_1
{
    HERE();
    int e;

    sqlite3 *mobicageDB = [MCTComponentFramework writeableDB];
    sqlite3 *backlogDB = self.dbMgr.writeableDB;

    const char *select = "SELECT callid, calltype, timestamp, has_priority, last_resend_timestamp, retention_timeout, response_handler, function, callbody FROM backlog";
    const char *insert = "INSERT INTO backlog (callid, calltype, timestamp, has_priority, last_resend_timestamp, retention_timeout, response_handler, function, callbody) VALUES (?,?,?,?,?,?,?,?,?)";

    sqlite3_stmt *stmtSelect;
    if ((e = sqlite3_prepare(mobicageDB, select, -1, &stmtSelect, NULL)) != SQLITE_OK) {
        LOG(@"Failed to prepare backlog select query");
        MCT_THROW_SQL_EXCEPTION(e);
    }

    @try {
        sqlite3_stmt *stmtInsert;
        if ((e = sqlite3_prepare(backlogDB, insert, -1, &stmtInsert, NULL)) != SQLITE_OK) {
            LOG(@"Failed to prepare backlog insert query");
            MCT_THROW_SQL_EXCEPTION(e);
        }

        if ((e = sqlite3_exec(backlogDB, "BEGIN EXCLUSIVE;", 0, 0, 0)) != SQLITE_OK) {
            LOG(@"Cannot begin transaction");
            MCT_THROW_SQL_EXCEPTION(e);
        }

        BOOL committed = NO;

        @try {
            @try {
                while ((e = sqlite3_step(stmtSelect)) != SQLITE_DONE) {
                    if (e != SQLITE_ROW) {
                        LOG(@"Error getting backlog items");
                        MCT_THROW_SQL_EXCEPTION(e);
                    }

                    @try {
                        sqlite3_bind_text(stmtInsert, 1, (const char *) sqlite3_column_text(stmtSelect, 0), -1, NULL);
                        sqlite3_bind_int(stmtInsert, 2, sqlite3_column_int(stmtSelect, 1));
                        sqlite3_bind_int(stmtInsert, 3, sqlite3_column_int(stmtSelect, 2));
                        sqlite3_bind_int(stmtInsert, 4, sqlite3_column_int(stmtSelect, 3));
                        sqlite3_bind_int(stmtInsert, 5, sqlite3_column_int(stmtSelect, 4));
                        sqlite3_bind_int(stmtInsert, 6, sqlite3_column_int(stmtSelect, 5));
                        sqlite3_bind_blob(stmtInsert, 7, sqlite3_column_blob(stmtSelect, 6), sqlite3_column_bytes(stmtSelect, 6), NULL);
                        sqlite3_bind_text(stmtInsert, 8, (const char *) sqlite3_column_text(stmtSelect, 7), -1, NULL);
                        sqlite3_bind_text(stmtInsert, 9, (const char *) sqlite3_column_text(stmtSelect, 8), -1, NULL);

                        if ((e = sqlite3_step(stmtInsert)) != SQLITE_DONE) {
                            LOG(@"Failed to copy backlog item");
                            const char *err = sqlite3_errmsg(backlogDB);
                            if (err != NULL)
                                LOG(@"%@", [NSString stringWithUTF8String:err]);
                            MCT_THROW_SQL_EXCEPTION(e);
                        }
                    }
                    @finally {
                        sqlite3_reset(stmtInsert);
                    }
                }

                if ((e = sqlite3_exec(backlogDB, "COMMIT;", 0, 0, 0)) != SQLITE_OK) {
                    LOG(@"Cannot commit transaction");
                    MCT_THROW_SQL_EXCEPTION(e);
                }
                committed = YES;
            }
            @finally {
                sqlite3_finalize(stmtInsert);
            }
        }
        @finally {
            if (!committed) {
                if ((e = sqlite3_exec(backlogDB, "ROLLBACK;", 0, 0, 0)) != SQLITE_OK) {
                    LOG(@"Cannot rollback transaction");
                    MCT_THROW_SQL_EXCEPTION(e);
                }
                LOG(@"Rollback successful!");
            }
        }

    }
    @finally {
        sqlite3_finalize(stmtSelect);
    }

    if ((e = sqlite3_exec(mobicageDB, "DROP TABLE backlog;", 0, 0, 0)) != SQLITE_OK) {
        LOG(@"Error dropping backlog table");
        MCT_THROW_SQL_EXCEPTION(e);
    }
}

@end