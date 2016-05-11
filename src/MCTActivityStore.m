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

#import "MCTActivityStore.h"
#import "MCTComponentFramework.h"
#import "MCTIntent.h"

#define MCT_INITIAL_LAST_READ_ACTIVITY_ID -1

@interface MCTActivityStore ()

- (void)initPreparedStatements;
- (void)destroyPreparedStatements;

@end


@implementation MCTActivityStore

static sqlite3_stmt *stmtCountReadActivityUI_;
static sqlite3_stmt *stmtCountUnreadActivityUI_;
static sqlite3_stmt *stmtGetActivityByIndexUI_;
static sqlite3_stmt *stmtGetLastReadActivityIdUI_;

static sqlite3_stmt *stmtSetLastReadActivityIdCOMM_;
static sqlite3_stmt *stmtInsertActivityCOMM_;
static sqlite3_stmt *stmtDeleteActivityCOMM_;

- (MCTActivityStore *)init
{
    T_BIZZ();
    if (self = [super init]) {
        self.cachedLastId = MCT_INITIAL_LAST_READ_ACTIVITY_ID;
        [self initPreparedStatements];
    }
    return self;
}


- (void)initPreparedStatements
{
    T_BIZZ();
    DB_LOCKED_OPERATION({
        [self prepareStatement:&stmtCountReadActivityUI_
                  withQueryKey:@"sql_activity_count_read"];

        [self prepareStatement:&stmtCountUnreadActivityUI_
                  withQueryKey:@"sql_activity_count_unread"];

        [self prepareStatement:&stmtGetActivityByIndexUI_
                  withQueryKey:@"sql_activity_get_by_index"];

        [self prepareStatement:&stmtGetLastReadActivityIdUI_
                  withQueryKey:@"sql_activity_get_last_unread_activity"];

        [self prepareStatement:&stmtSetLastReadActivityIdCOMM_
                  withQueryKey:@"sql_activity_update_last_unread_activity"];

        [self prepareStatement:&stmtInsertActivityCOMM_
                  withQueryKey:@"sql_activity_insert"];

        [self prepareStatement:&stmtDeleteActivityCOMM_
                  withQueryKey:@"sql_activity_delete_for_message"];

    });
}

- (void)destroyPreparedStatements
{
    T_BIZZ();
    DB_LOCKED_OPERATION({
        [self finalizeStatement:stmtCountReadActivityUI_
                   withQueryKey:@"sql_activity_count_read"];

        [self finalizeStatement:stmtCountUnreadActivityUI_
                   withQueryKey:@"sql_activity_count_unread"];

        [self finalizeStatement:stmtGetActivityByIndexUI_
                   withQueryKey:@"sql_activity_get_by_index"];

        [self finalizeStatement:stmtGetLastReadActivityIdUI_
                   withQueryKey:@"sql_activity_get_last_unread_activity"];

        [self finalizeStatement:stmtSetLastReadActivityIdCOMM_
                   withQueryKey:@"sql_activity_update_last_unread_activity"];

        [self finalizeStatement:stmtInsertActivityCOMM_
                   withQueryKey:@"sql_activity_insert"];

        [self finalizeStatement:stmtDeleteActivityCOMM_
                   withQueryKey:@"sql_activity_delete_for_message"];
    });
}

- (void)saveActivity:(MCTActivity *)activity
{
    T_DONTCARE();
    DB_LOCKED_OPERATION({

        @try {
            int e;

            sqlite3_bind_int64(stmtInsertActivityCOMM_, 1, activity.timestamp);
            sqlite3_bind_int64(stmtInsertActivityCOMM_, 2, activity.type);
            sqlite3_bind_text(stmtInsertActivityCOMM_, 3, [activity.reference UTF8String], -1, NULL);

            if (activity.parameters == nil) {
                sqlite3_bind_null(stmtInsertActivityCOMM_, 4);
            } else {
                NSData *parameters = [NSKeyedArchiver archivedDataWithRootObject:activity.parameters];
                sqlite3_bind_blob(stmtInsertActivityCOMM_, 4, [parameters bytes], (int)[parameters length], NULL);
            }

            if (activity.friendReference == nil) {
                sqlite3_bind_null(stmtInsertActivityCOMM_, 5);
            } else {
                sqlite3_bind_text(stmtInsertActivityCOMM_, 5, [activity.friendReference UTF8String], -1, NULL);
            }

            if ((e = sqlite3_step(stmtInsertActivityCOMM_)) != SQLITE_DONE) {
                LOG(@"Failed to insert activity %@", activity);
                MCT_THROW_SQL_EXCEPTION(e);
            }

        } @finally {
            sqlite3_reset(stmtInsertActivityCOMM_);
        }

    });

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_ACTIVITY_NEW];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (MCTActivity *)activityByIndex:(NSInteger)index
{
    T_UI();
    MCTActivity *activity;

    DB_LOCKED_OPERATION({
        @try {
            int e;

            sqlite3_bind_int64(stmtGetActivityByIndexUI_, 1, index);
            if ((e = sqlite3_step(stmtGetActivityByIndexUI_)) != SQLITE_ROW) {
                LOG(@"Failed to get activity with id %d", index);
                MCT_THROW_SQL_EXCEPTION(e);
            }

            activity = [MCTActivity activity];
            activity.idX = sqlite3_column_int(stmtGetActivityByIndexUI_, 0);
            activity.timestamp = sqlite3_column_int64(stmtGetActivityByIndexUI_, 1);
            activity.type = sqlite3_column_int(stmtGetActivityByIndexUI_, 2);

            activity.reference = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetActivityByIndexUI_, 3)];

            int paramLength = sqlite3_column_bytes(stmtGetActivityByIndexUI_, 4);
            if (paramLength > 0) {
                NSData *parameters = [NSData dataWithBytes:sqlite3_column_blob(stmtGetActivityByIndexUI_, 4)
                                                    length:paramLength];
                activity.parameters = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:parameters];
            }

            activity.friendReference = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetActivityByIndexUI_, 5)];

        } @finally {
            sqlite3_reset(stmtGetActivityByIndexUI_);
        }
    });

    return activity;
}

- (void)updateLastReadActivityId
{
    T_BIZZ();
    DB_LOCKED_TRANSACTION({
        @try {
            int e;

            if ((e = sqlite3_step(stmtSetLastReadActivityIdCOMM_)) != SQLITE_DONE) {
                LOG(@"Error updating last read activity id");
                MCT_THROW_SQL_EXCEPTION(e);
            }
        } @finally {
            sqlite3_reset(stmtSetLastReadActivityIdCOMM_);
        }
    });

    self.cachedLastId = MCT_INITIAL_LAST_READ_ACTIVITY_ID;

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_ACTIVITY_READ_ALL];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (int)lastReadActivityId
{
    T_UI();
    if (self.cachedLastId == MCT_INITIAL_LAST_READ_ACTIVITY_ID) {
        DB_LOCKED_OPERATION({
            @try {
                int e;

                if ((e = sqlite3_step(stmtGetLastReadActivityIdUI_)) != SQLITE_ROW) {
                    LOG(@"Error retrieving last read activity id");
                    MCT_THROW_SQL_EXCEPTION(e);
                }
                self.cachedLastId = sqlite3_column_int(stmtGetLastReadActivityIdUI_, 0);

            } @finally {
                sqlite3_reset(stmtGetLastReadActivityIdUI_);
            }
        });
    }
    return self.cachedLastId;
}

- (int)countReadActivities
{
    T_UI();
    int count;

    DB_LOCKED_OPERATION({
        @try {
            int e;

            sqlite3_bind_int(stmtCountReadActivityUI_, 1, [self lastReadActivityId]);

            if ((e = sqlite3_step(stmtCountReadActivityUI_)) != SQLITE_ROW) {
                LOG(@"Error retrieving read activity count");
                MCT_THROW_SQL_EXCEPTION(e);
            }
            count = sqlite3_column_int(stmtCountReadActivityUI_, 0);

        } @finally {
            sqlite3_reset(stmtCountReadActivityUI_);
        }
    });

    return count;
}

- (int)countUnreadActivities
{
    T_UI();
    int count;

    DB_LOCKED_OPERATION({
        @try {
            int e;

            sqlite3_bind_int(stmtCountUnreadActivityUI_, 1, [self lastReadActivityId]);

            if ((e = sqlite3_step(stmtCountUnreadActivityUI_)) != SQLITE_ROW) {
                LOG(@"Error retrieving unread activity count");
                MCT_THROW_SQL_EXCEPTION(e);
            }
            count = sqlite3_column_int(stmtCountUnreadActivityUI_, 0);

        } @finally {
            sqlite3_reset(stmtCountUnreadActivityUI_);
        }
    });

    return count;
}

- (void)deletedActivityByReference:(NSString *)reference
{
    T_DONTCARE();
    DB_LOCKED_OPERATION({
        @try {
            int e;

            sqlite3_bind_text(stmtDeleteActivityCOMM_, 1, [reference UTF8String], -1, NULL);
            sqlite3_bind_text(stmtDeleteActivityCOMM_, 2, [reference UTF8String], -1, NULL);
            if ((e = sqlite3_step(stmtDeleteActivityCOMM_)) != SQLITE_DONE) {
                LOG(@"Error deleting activity with reference %@", reference);
                MCT_THROW_SQL_EXCEPTION(e);
            }


        } @finally {
            sqlite3_reset(stmtDeleteActivityCOMM_);
        }
    });
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_ACTIVITY_DELETED];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}


@end