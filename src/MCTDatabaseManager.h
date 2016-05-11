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

#import "sqlite3.h"

#import "MCTDatabaseUpdateMgr.h"

#define MCT_DB_VALUETYPE_STRING  "S"
#define MCT_DB_VALUETYPE_LONG    "L"
#define MCT_DB_VALUETYPE_BOOLEAN "B"


@interface MCTDatabaseManager : NSObject

@property (nonatomic) sqlite3 *writeableDB;
@property (nonatomic, strong, readonly) NSDictionary *queries;
@property (nonatomic, strong) NSObject *lock;
@property (nonatomic, strong) NSObject *dbUpdateMgr;

- (MCTDatabaseManager *)initFromSQLScripts;
- (BOOL)wipe;

- (NSObject *)createUpdateMgr;
- (NSString *)dbFileName;
- (MCTlong)dbVersion;
- (NSString *)dbUpgradeScriptFormat;
- (const char *)dbVersionCategory;
- (const char *)dbVersionKey;
- (sqlite3 *)dbWithConfigurationProvider;

@end