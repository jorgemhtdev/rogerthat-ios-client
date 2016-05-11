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

#import "MCTSystemStore.h"
#import "MCTComponentFramework.h"
#import "MCTJSEmbedding.h"

@interface MCTSystemStore ()

- (void)initPreparedStatements;
- (void)destroyPreparedStatements;

@end

@implementation MCTSystemStore

static sqlite3_stmt *stmtGetJSEmbeddedPackets_;
static sqlite3_stmt *stmtUpdateJSEmbeddedWithNameAndHash_;
static sqlite3_stmt *stmtDeleteJSEmbeddedWithName_;


- (MCTSystemStore *)init
{
    T_BIZZ();
    self = [super init];
    if (self != nil) {
        [self initPreparedStatements];
    }
    return self;
}

- (void)dealloc
{
    T_BIZZ();
    HERE();
    [self destroyPreparedStatements];
    
}

- (void)initPreparedStatements
{
    T_BIZZ();
    [self dbLockedOperationWithBlock:^{
        [self prepareStatement:&stmtGetJSEmbeddedPackets_
                  withQueryKey:@"sql_get_js_embedding"];

        [self prepareStatement:&stmtUpdateJSEmbeddedWithNameAndHash_
                  withQueryKey:@"sql_insert_js_embedding"];

        [self prepareStatement:&stmtDeleteJSEmbeddedWithName_
                  withQueryKey:@"sql_delete_js_embedding"];

    }];
}

- (void)destroyPreparedStatements
{
    T_BIZZ();
    [self dbLockedOperationWithBlock:^{
        [self finalizeStatement:stmtGetJSEmbeddedPackets_
                   withQueryKey:@"sql_get_js_embedding"];

        [self finalizeStatement:stmtUpdateJSEmbeddedWithNameAndHash_
                   withQueryKey:@"sql_insert_js_embedding"];

        [self finalizeStatement:stmtDeleteJSEmbeddedWithName_
                   withQueryKey:@"sql_delete_js_embedding"];

    }];
}

- (NSDictionary *)jsEmbeddedPackets
{
    T_DONTCARE();
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;
            while ((e = sqlite3_step(stmtGetJSEmbeddedPackets_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to loop over js embedded packets");
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                NSString *name = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetJSEmbeddedPackets_, 0)];
                NSString *embeddingHash = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetJSEmbeddedPackets_, 1)];
                MCTJSEmbeddingStatus status = sqlite3_column_int(stmtGetJSEmbeddedPackets_, 2);

                MCTJSEmbedding *jse = [MCTJSEmbedding jsEmbeddingWithName:name embeddingHash:embeddingHash status:status];
                [dict setValue:jse forKey:name];
            }
        }
        @finally {
            sqlite3_reset(stmtGetJSEmbeddedPackets_);
        }
    }];
    return dict;
}

- (void *)updateJSEmbeddedWithName:(NSString *)name hash:(NSString *)hash status:(MCTJSEmbeddingStatus)status
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            if ((e = sqlite3_bind_text(stmtUpdateJSEmbeddedWithNameAndHash_, 1, [name UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_text(stmtUpdateJSEmbeddedWithNameAndHash_, 2, [hash UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_int(stmtUpdateJSEmbeddedWithNameAndHash_, 3, status)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_step(stmtUpdateJSEmbeddedWithNameAndHash_)) != SQLITE_DONE)
                MCT_THROW_SQL_EXCEPTION(e);

        } @finally {
            sqlite3_reset(stmtUpdateJSEmbeddedWithNameAndHash_);
        }
        
    }];
}

- (void *)deleteJSEmbeddedWithName:(NSString *)name
{
    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            if ((e = sqlite3_bind_text(stmtDeleteJSEmbeddedWithName_, 1, [name UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_step(stmtDeleteJSEmbeddedWithName_)) != SQLITE_DONE)
                MCT_THROW_SQL_EXCEPTION(e);

        } @finally {
            sqlite3_reset(stmtDeleteJSEmbeddedWithName_);
        }
        
    }];
}

@end