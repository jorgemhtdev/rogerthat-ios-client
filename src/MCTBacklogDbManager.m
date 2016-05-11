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

#import "MCTBacklogDbManager.h"
#import "MCTBacklogDbUpdateMgr.h"
#import "MCTComponentFramework.h"


#define DB_FILENAME @"backlog.db"
#define DB_VERSION 2
#define DB_UPGRADE_SCRIPT_SQL @"backlog_update_%d_to_%d.sql"
#define DB_VERSION_CATEGORY "backlog_db"
#define DB_VERSION_KEY "mobicage_backlog_db_version"


@implementation MCTBacklogDbManager

- (NSObject *)createUpdateMgr
{
    MCTBacklogDbUpdateMgr *updateMgr = [[MCTBacklogDbUpdateMgr alloc] init];
    updateMgr.dbMgr = self;
    return updateMgr;
}

- (NSString *)dbFileName
{
    return DB_FILENAME;
}

- (MCTlong)dbVersion
{
    return DB_VERSION;
}

- (NSString *)dbUpgradeScriptFormat
{
    return DB_UPGRADE_SCRIPT_SQL;
}

- (const char *)dbVersionCategory
{
    return DB_VERSION_CATEGORY;
}

- (const char *)dbVersionKey
{
    return DB_VERSION_KEY;
}

- (sqlite3 *)dbWithConfigurationProvider
{
    return [MCTComponentFramework writeableDB];
}

@end