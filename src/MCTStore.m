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
#import "MCTStore.h"

#include <execinfo.h>


@interface MCTStore ()

@property (nonatomic) BOOL isInTransaction;

@end


@implementation MCTStore

- (BOOL)prepareStatement:(sqlite3_stmt **)ppStmt withQueryKey:(NSString *)key
{
    T_DONTCARE();
    if (!self.dbMgr)
        self.dbMgr = [MCTComponentFramework dbManager];

    NSDictionary *queries = [self.dbMgr queries];

    int e = sqlite3_prepare(self.dbMgr.writeableDB, [[queries stringForKey:key] UTF8String], -1, ppStmt, NULL);
    if (e != SQLITE_OK) {
        LOG(@"Failed to prepare query: %@\n %@", key, [queries objectForKey:key]);
        MCT_THROW_SQL_EXCEPTION(e);
    }

    return YES;
}

- (void)finalizeStatement:(sqlite3_stmt *)stmt withQueryKey:(NSString *)key
{
    int e = sqlite3_finalize(stmt);
    if (e != SQLITE_OK) {
        ERROR("Failed to finalize statement: %@", stmt);
    }
}

- (void)dbLockedOperationWithBlock:(void (^)(void))block
{
    T_DONTCARE();
    @synchronized([self.dbMgr lock]) {
        block();
    }
}

- (void)dbLockedTransactionWithBlock:(void (^)(void))block
{
    T_DONTCARE();
    if (self.isInTransaction) {
        [self dbLockedOperationWithBlock:block];
        return;
    }

    LOG(@"DB LOCKED TXN START %@", [MCTUtils callerMethod]);

    @try {
        @synchronized([self.dbMgr lock]) {
            int e;
            if ((e = sqlite3_exec(self.dbMgr.writeableDB, "BEGIN EXCLUSIVE;", 0, 0, 0)) != SQLITE_OK) {
                LOG(@"Cannot begin transaction");
                MCT_THROW_SQL_EXCEPTION(e);
            }

            self.isInTransaction = YES;

            @try {
                BOOL committed = NO;

                @try {
                    block();
                    
                    if ((e = sqlite3_exec(self.dbMgr.writeableDB, "COMMIT;", 0, 0, 0)) != SQLITE_OK) {
                        LOG(@"Cannot commit transaction");
                        MCT_THROW_SQL_EXCEPTION(e);
                    }
                    committed = YES;
                } @finally {
                    if (!committed) {
                        if ((e = sqlite3_exec(self.dbMgr.writeableDB, "ROLLBACK;", 0, 0, 0)) != SQLITE_OK) {
                            LOG(@"Cannot rollback transaction");
                            MCT_THROW_SQL_EXCEPTION(e);
                        }
                        LOG(@"Rollback successful!");
                    }
                }
            }
            @finally {
                self.isInTransaction = NO;
            }
        }
    } @finally {
        LOG(@"DB LOCKED TXN STOP %@", [MCTUtils callerMethod]);
    }
}

@end