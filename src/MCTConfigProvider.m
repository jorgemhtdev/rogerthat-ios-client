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

#import "MCTConfigProvider.h"
#import "MCTComponentFramework.h"

#define CATEGORY "" // We do not use categories


@implementation MCTConfigProvider

static sqlite3_stmt *insertItemStatementCOMM_;
static sqlite3_stmt *getItemStatementCOMM_;
static sqlite3_stmt *deleteItemStatementCOMM_;

#pragma mark -
#pragma mark constructor & destructor

- (BOOL)initPreparedStatements
{
    T_UI();
    [self dbLockedOperationWithBlock:^{
        [self prepareStatement:&insertItemStatementCOMM_
                  withQueryKey:@"sql_configprovider_insert"];
        [self prepareStatement:&getItemStatementCOMM_
                  withQueryKey:@"sql_configprovider_get"];
        [self prepareStatement:&deleteItemStatementCOMM_
                  withQueryKey:@"sql_configprovider_delete"];
    }];

    return YES;
}

- (void) destroyPreparedStatements
{
    T_UI();
    [self dbLockedOperationWithBlock:^{
        [self finalizeStatement:insertItemStatementCOMM_
                   withQueryKey:@"sql_configprovider_insert"];
        [self finalizeStatement:getItemStatementCOMM_
                   withQueryKey:@"sql_configprovider_get"];
        [self finalizeStatement:deleteItemStatementCOMM_
                   withQueryKey:@"sql_configprovider_delete"];
    }];
}

- (MCTConfigProvider *) init
{
    T_UI();
    self = [super init];
    if (self) {
        if (![self initPreparedStatements]) {
            ERROR(@"Error initializing config provider prepared statements");
            self = nil;
        }
    }
    return self;
}

- (void) dealloc
{
    T_UI();
    [self destroyPreparedStatements];
    
}

#pragma mark -
#pragma mark functionality

// TODO: hardening for nil or MCTNull key or value
- (void)setString:(NSString *)value forKey:(NSString *)key
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {

            int e;

            if ((e = sqlite3_bind_text(insertItemStatementCOMM_, 1, CATEGORY, -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_text(insertItemStatementCOMM_, 2, MCT_DB_VALUETYPE_STRING, -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_text(insertItemStatementCOMM_, 3, [key UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_text(insertItemStatementCOMM_, 4, [value UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_step(insertItemStatementCOMM_)) != SQLITE_DONE)
                MCT_THROW_SQL_EXCEPTION(e);

        } @finally {

            sqlite3_reset(insertItemStatementCOMM_);

        }

    }];
}

// TODO: hardening for nil or MCTNull key or value
- (NSString *)stringForKey:(NSString *)key
{
    T_DONTCARE();
    __block NSString *result;
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            if ((e = sqlite3_bind_text(getItemStatementCOMM_, 1, CATEGORY, -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_text(getItemStatementCOMM_, 2, MCT_DB_VALUETYPE_STRING, -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_text(getItemStatementCOMM_, 3, [key UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            e = sqlite3_step(getItemStatementCOMM_);

            if (e == SQLITE_DONE) {
                result = nil;
                return ;
            }

            if (e != SQLITE_ROW)
                MCT_THROW_SQL_EXCEPTION(e);

            result = [NSString stringWithUTF8StringSafe:sqlite3_column_text(getItemStatementCOMM_, 0)];

            if ((e = sqlite3_step(getItemStatementCOMM_)) != SQLITE_DONE)
                MCT_THROW_SQL_EXCEPTION(e);

        } @finally {

            sqlite3_reset(getItemStatementCOMM_);

        }

    }];

    return result;
}

- (void)deleteStringForKey:(NSString *)key
{
    T_DONTCARE();

    [self dbLockedOperationWithBlock:^{

        @try {

            int e;

            if ((e = sqlite3_bind_text(deleteItemStatementCOMM_, 1, CATEGORY, -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_text(deleteItemStatementCOMM_, 2, MCT_DB_VALUETYPE_STRING, -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_bind_text(deleteItemStatementCOMM_, 3, [key UTF8String], -1, NULL)) != SQLITE_OK)
                MCT_THROW_SQL_EXCEPTION(e);

            if ((e = sqlite3_step(deleteItemStatementCOMM_)) != SQLITE_DONE)
                MCT_THROW_SQL_EXCEPTION(e);

        } @finally {

            sqlite3_reset(deleteItemStatementCOMM_);

        }

    }];
}

@end