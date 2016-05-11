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

#include <string.h>

#import "MCTDatabaseManager.h"
#import "MCTDatabaseUpdateMgr.h"
#import "MCTUtils.h"

#define MAIN_DB_FILENAME @"mobicage.db"
#define MAIN_DB_VERSION 71
#define MAIN_DB_UPGRADE_SCRIPT_SQL @"update_%d_to_%d.sql"
#define MAIN_DB_VERSION_CATEGORY "db"
#define MAIN_DB_VERSION_KEY "mobicage_database_version"

#define DB_QUERIES_PLIST @"queries.plist"



void sqlLogger(void *arg1, const char *args) {
    int MAXLEN = 1000;
    if (strlen(args) >= MAXLEN) {
        char shortstr[MAXLEN + 4];
        strncpy(shortstr, args, MAXLEN);
        strncat(shortstr, "...", 3);
        LOG(@"SQL | %s", shortstr);
    } else {
        LOG(@"SQL | %s", args);
    }
}

@interface MCTDatabaseManager ()

@property (nonatomic, strong, readwrite) NSDictionary *queries;

- (void)loadQueries;

- (BOOL)processSQLScriptsFromVersion:(int)fromVersion;

- (NSString *)databaseFilePath;

@end

@implementation MCTDatabaseManager

@synthesize writeableDB = _writeableDB;


- (NSString *)databaseFilePath
{
    T_UI();
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[self dbFileName]];
}

/* Return YES if success, NO if error */
- (BOOL)processSQLScriptsFromVersion:(int)fromVersion
{
    T_UI();
    int e;

    if (fromVersion == [self dbVersion]) {
        LOG(@"DB is already at correct version %d", fromVersion);
        return YES;
    } else if (fromVersion > [self dbVersion]) {
        BUG(@"Cannot upgrade db: fromVersion: %d toVersion: %d", fromVersion, [self dbVersion]);
        return YES;
    }

    NSString *appHome = [[NSBundle mainBundle] bundlePath];

    for (int version=fromVersion; version<[self dbVersion]; version++) {
        NSString *path = [appHome stringByAppendingPathComponent:[NSString stringWithFormat:[self dbUpgradeScriptFormat], version, version+1]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            BUG(@"Cannot find file at path %@", path);
            return NO;
        }

        LOG(@"Upgrade DB using %@", [path lastPathComponent]);

        NSError *err;
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
        if (content == nil) {
            ERROR(@"Error while reading file [%@]", path);
            if (err) {
                ERROR(@"Error details: %@", err);
                return NO;
            }
        }
        
        char *errorMsg;
        if ((e = sqlite3_exec(self.writeableDB, [content UTF8String], NULL, NULL, &errorMsg)) != SQLITE_OK) {
            BUG(@"Cannot exec SQL statement %@\nErrorcode = %d\nError = %s", content, e, errorMsg);
            return NO;
        }

        // Update DB version
        char *insertSql = "INSERT OR REPLACE INTO ConfigurationProvider(category, valuetype, key, value) values (?, ?, ?, ?)";
        sqlite3_stmt *statement;

        if ((e = sqlite3_prepare_v2([self dbWithConfigurationProvider], insertSql, -1, &statement, nil)) != SQLITE_OK) {
            BUG(@"DB error %d", e);
            return NO;
        }

        @try {
            if ((e = sqlite3_bind_text(statement, 1, [self dbVersionCategory], -1, NULL)) != SQLITE_OK) {
                BUG(@"DB error %d", e);
                return NO;
            }

            if ((e = sqlite3_bind_text(statement, 2, MCT_DB_VALUETYPE_STRING, -1, NULL)) != SQLITE_OK) {
                BUG(@"DB error %d", e);
                return NO;
            }

            if ((e = sqlite3_bind_text(statement, 3, [self dbVersionKey], -1, NULL)) != SQLITE_OK) {
                BUG(@"DB error %d", e);
                return NO;
            }

            if ((e = sqlite3_bind_text(statement, 4, [[NSString stringWithFormat:@"%d", version+1] UTF8String], -1, NULL)) != SQLITE_OK) {
                BUG(@"DB error %d", e);
                return NO;
            }

            if ((e = sqlite3_step(statement)) != SQLITE_DONE) {
                BUG(@"Cannot update DB version: %d-%d ; ERROR %d", version, version+1, e);
                return NO;
            }
        }
        @finally {
            sqlite3_finalize(statement);
        }

        SEL sel = NSSelectorFromString([NSString stringWithFormat:@"update_%d_to_%d", version, version+1]);
        if ([self.dbUpdateMgr respondsToSelector:sel]) {
            IMP imp = [self.dbUpdateMgr methodForSelector:sel];
            void (*func)(id, SEL) = (void *)imp;
            func(self.dbUpdateMgr, sel);
        }
    }

    MCT_RELEASE(self.dbUpdateMgr);

    return YES;
}

- (MCTDatabaseManager *)initFromSQLScripts
{
    T_UI();
    HERE();

    if (self = [super init]) {

        self.lock = [[NSObject alloc] init];
        self.dbUpdateMgr = [self createUpdateMgr];

        int versionOnDisk = 0;
        int e;
        BOOL isBrandNewDB = NO;

        NSString *dbPath = [self databaseFilePath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
            isBrandNewDB = YES;
        }

        if ((e = sqlite3_open_v2([dbPath UTF8String], &_writeableDB, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL)) != SQLITE_OK) {
            [self initFailedWithReason:[NSString stringWithFormat:@"Cannot open DB %@ - errorcode %d", dbPath, e]];
        }

        LOG(@"Successfully opened DB %@", dbPath);
        [MCTUtils addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:dbPath]];

#ifdef MCT_SQLITE_DEBUG
        sqlite3_trace(self.writeableDB, &sqlLogger, NULL);
        LOG(@"Successfully installed sqlite tracer");
#endif

        if (!isBrandNewDB) {

            sqlite3_stmt *statement;
            NSString *query = @"SELECT value FROM ConfigurationProvider WHERE category=? AND valuetype=? AND key=?;";
            if ((e = sqlite3_prepare_v2([self dbWithConfigurationProvider], [query UTF8String], -1, &statement, NULL)) != SQLITE_OK) {
                [self initFailedWithReason:[NSString stringWithFormat:@"Cannot query ConfigurationProvider - error %d", e]];
            }

            @try {

                if ((e = sqlite3_bind_text(statement, 1, [self dbVersionCategory], -1, NULL)) != SQLITE_OK) {
                    [self initFailedWithReason:[NSString stringWithFormat:@"DB error - %d", e]];
                }

                if ((e = sqlite3_bind_text(statement, 2, MCT_DB_VALUETYPE_STRING, -1, NULL)) != SQLITE_OK) {
                    [self initFailedWithReason:[NSString stringWithFormat:@"DB error - %d", e]];
                }

                if ((e = sqlite3_bind_text(statement, 3, [self dbVersionKey], -1, NULL)) != SQLITE_OK) {
                    [self initFailedWithReason:[NSString stringWithFormat:@"DB error - %d", e]];
                }

                if ((e = sqlite3_step(statement)) != SQLITE_ROW) {
                    [self initFailedWithReason:[NSString stringWithFormat:@"Error retrieving db version - error %d", e]];
                }

                const char *rowData;
                rowData = (const char *) sqlite3_column_text(statement, 0);
                versionOnDisk = atoi(rowData);

                if ((e = sqlite3_step(statement)) != SQLITE_DONE) {
                    [self initFailedWithReason:[NSString stringWithFormat:@"Error stepping through SQL result - %d", e]];
                }

            } @finally {

                sqlite3_finalize(statement);

            }
        }

        if (![self processSQLScriptsFromVersion:versionOnDisk]) {
            [self initFailedWithReason:@"Error processing SQL creation scripts"];
        }

        [self loadQueries];

    }

    return self;
}

- (void)initFailedWithReason:(NSString *)reason
{
    BUG(@"%@",reason);
    @throw([NSException exceptionWithName:[NSString stringWithFormat:@"Failed to init %@ from SQL scripts", [self databaseFilePath]]
                                   reason:reason
                                 userInfo:nil]);

}

- (void)loadQueries {
    T_UI();
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:DB_QUERIES_PLIST];
    self.queries = [NSDictionary dictionaryWithContentsOfFile:path];
}

- (BOOL)wipe
{
    T_UI();
    @synchronized(self.lock) {
        BOOL wipedCleanly = YES;
        if (self.writeableDB != NULL) {
            int e = sqlite3_close(self.writeableDB);
            if (e != SQLITE_OK) {
                BUG(@"Cannot close writeable DB - error %d", e);
                wipedCleanly = NO;
            } else {
                LOG(@"Writeable DB closed successfully");
            }
        }
        LOG(@"Removing database");
        [[NSFileManager defaultManager] removeItemAtPath:[self databaseFilePath] error:nil];
        LOG(@"Database removed");

        return wipedCleanly;
    }
}

- (NSObject *)createUpdateMgr
{
    return [MCTDatabaseUpdateMgr manager];
}

- (NSString *)dbFileName
{
    return MAIN_DB_FILENAME;
}

- (MCTlong)dbVersion
{
    return MAIN_DB_VERSION;
}

- (NSString *)dbUpgradeScriptFormat
{
    return MAIN_DB_UPGRADE_SCRIPT_SQL;
}

- (const char *)dbVersionCategory
{
    return MAIN_DB_VERSION_CATEGORY;
}

- (const char *)dbVersionKey
{
    return MAIN_DB_VERSION_KEY;
}

- (sqlite3 *)dbWithConfigurationProvider
{
    return self.writeableDB;
}

@end