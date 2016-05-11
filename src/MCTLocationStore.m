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
#import "MCTLocationStore.h"

#define MCT_INITIAL_LAST_READ_ACTIVITY_ID -1

@interface MCTLocationStore ()

- (void)initPreparedStatements;
- (void)destroyPreparedStatements;

@end


@implementation MCTLocationStore

static sqlite3_stmt *stmtInsertBeaconDiscovery_;
static sqlite3_stmt *stmtGetBeaconDiscovery_;
static sqlite3_stmt *stmtUpdateBeaconDiscovery_;
static sqlite3_stmt *stmtSelectBeaconDiscoveryByEmail_;
static sqlite3_stmt *stmtDeleteBeaconDiscoveryByEmail_;
static sqlite3_stmt *stmtDeleteBeaconDiscoveryByUuidAndName_;
static sqlite3_stmt *stmtGetFriendConnectedOnBeaconDiscovery_;
static sqlite3_stmt *stmtClearBeaconRegions_;
static sqlite3_stmt *stmtInsertBeaconRegion_;
static sqlite3_stmt *stmtGetBeaconRegions_;


- (MCTLocationStore *)init
{
    T_BIZZ();
    if (self = [super init]) {
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
    DB_LOCKED_OPERATION({
        [self prepareStatement:&stmtInsertBeaconDiscovery_
                  withQueryKey:@"sql_insert_beacon_discovery"];
        [self prepareStatement:&stmtGetBeaconDiscovery_
                  withQueryKey:@"sql_get_beacon_discovery"];
        [self prepareStatement:&stmtUpdateBeaconDiscovery_
                  withQueryKey:@"sql_update_beacon_discovery"];
        [self prepareStatement:&stmtSelectBeaconDiscoveryByEmail_
                  withQueryKey:@"sql_select_beacon_discovery_by_email"];
        [self prepareStatement:&stmtDeleteBeaconDiscoveryByEmail_
                  withQueryKey:@"sql_delete_beacon_discovery_by_email"];
        [self prepareStatement:&stmtDeleteBeaconDiscoveryByUuidAndName_
                  withQueryKey:@"sql_delete_beacon_discovery_by_uuid_and_name"];
        [self prepareStatement:&stmtGetFriendConnectedOnBeaconDiscovery_
                  withQueryKey:@"sql_get_friend_connected_on_beacon_discovery"];
        [self prepareStatement:&stmtClearBeaconRegions_
                  withQueryKey:@"sql_clear_beacon_regions"];
        [self prepareStatement:&stmtInsertBeaconRegion_
                  withQueryKey:@"sql_insert_beacon_region"];
        [self prepareStatement:&stmtGetBeaconRegions_
                  withQueryKey:@"sql_get_beacon_regions"];
    });
}

- (void)destroyPreparedStatements
{
    T_BIZZ();
    DB_LOCKED_OPERATION({
        [self finalizeStatement:stmtInsertBeaconDiscovery_
                   withQueryKey:@"sql_insert_beacon_discovery"];
        [self finalizeStatement:stmtGetBeaconDiscovery_
                   withQueryKey:@"sql_get_beacon_discovery"];
        [self finalizeStatement:stmtUpdateBeaconDiscovery_
                   withQueryKey:@"sql_update_beacon_discovery"];
        [self finalizeStatement:stmtSelectBeaconDiscoveryByEmail_
                   withQueryKey:@"sql_select_beacon_discovery_by_email"];
        [self finalizeStatement:stmtDeleteBeaconDiscoveryByEmail_
                   withQueryKey:@"sql_delete_beacon_discovery_by_email"];
        [self finalizeStatement:stmtDeleteBeaconDiscoveryByUuidAndName_
                   withQueryKey:@"sql_delete_beacon_discovery_by_uuid_and_name"];
        [self finalizeStatement:stmtGetFriendConnectedOnBeaconDiscovery_
                   withQueryKey:@"sql_get_friend_connected_on_beacon_discovery"];
        [self finalizeStatement:stmtClearBeaconRegions_
                  withQueryKey:@"sql_clear_beacon_regions"];
        [self finalizeStatement:stmtInsertBeaconRegion_
                   withQueryKey:@"sql_insert_beacon_region"];
        [self finalizeStatement:stmtGetBeaconRegions_
                   withQueryKey:@"sql_get_beacon_regions"];
    });
}

- (void)saveBeaconDiscoveryWithUUID:(NSString *)uuid name:(NSString *)name
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            sqlite3_bind_text(stmtInsertBeaconDiscovery_, 1, [uuid UTF8String], -1, NULL);
            sqlite3_bind_text(stmtInsertBeaconDiscovery_, 2, [name UTF8String], -1, NULL);
            sqlite3_bind_int64(stmtInsertBeaconDiscovery_, 3, [MCTUtils currentTimeMillis]);

            if ((e = sqlite3_step(stmtInsertBeaconDiscovery_)) != SQLITE_DONE) {
                LOG(@"Failed to insert beacon discovery uuid: %@ name: %@ ", uuid, name);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtInsertBeaconDiscovery_);
        }

    }];
}

- (BOOL)beaconDiscoveryExistsWithUUID:(NSString *)uuid name:(NSString *)name
{
    T_DONTCARE();
    __block BOOL exists = NO;
    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            sqlite3_bind_text(stmtGetBeaconDiscovery_, 1, [uuid UTF8String], -1, NULL);
            sqlite3_bind_text(stmtGetBeaconDiscovery_, 2, [name UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtGetBeaconDiscovery_)) == SQLITE_ROW) {
                exists = YES;
            }
        }
        @finally {
            sqlite3_reset(stmtGetBeaconDiscovery_);
        }

    }];
    return exists;
}

- (void)updateBeaconDiscoveryWithUUID:(NSString *)uuid
                                 name:(NSString *)name
                          friendEmail:(NSString *)friendEmail
                                  tag:(NSString *)tag
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{

        @try {
            int e;
            if ( [MCTUtils isEmptyOrWhitespaceString:friendEmail] ){
                sqlite3_bind_null(stmtUpdateBeaconDiscovery_, 1);
            }
            else {
                sqlite3_bind_text(stmtUpdateBeaconDiscovery_, 1, [friendEmail UTF8String], -1, NULL);
            }

            if ( [MCTUtils isEmptyOrWhitespaceString:tag] ){
                sqlite3_bind_null(stmtUpdateBeaconDiscovery_, 2);
            }
            else {
                sqlite3_bind_text(stmtUpdateBeaconDiscovery_, 2, [tag UTF8String], -1, NULL);
            }

            sqlite3_bind_text(stmtUpdateBeaconDiscovery_, 3, [uuid UTF8String], -1, NULL);
            sqlite3_bind_text(stmtUpdateBeaconDiscovery_, 4, [name UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateBeaconDiscovery_)) != SQLITE_DONE) {
                LOG(@"Failed to update beacon discovery uuid: %@ name: %@ friendEmail: %@ tag: %@", uuid, name, friendEmail, tag);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateBeaconDiscovery_);
        }
    }];
}

- (NSArray *)beaconDiscoveriesWithFriendEmail:(NSString *)friendEmail
{
    T_DONTCARE();
    NSMutableArray *beaconDiscoveries = [NSMutableArray array];

    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            sqlite3_bind_text(stmtSelectBeaconDiscoveryByEmail_, 1, [friendEmail UTF8String], -1, NULL);

            while ((e = sqlite3_step(stmtSelectBeaconDiscoveryByEmail_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get beacon discoveries for %@", friendEmail);
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO *beaconDiscovery =
                    [MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO transferObject];
                beaconDiscovery.uuid = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtSelectBeaconDiscoveryByEmail_, 0)];
                beaconDiscovery.name = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtSelectBeaconDiscoveryByEmail_, 1)];
                [beaconDiscoveries addObject:beaconDiscovery];
            }
        }
        @finally {
            sqlite3_reset(stmtSelectBeaconDiscoveryByEmail_);
        }
    }];

    return beaconDiscoveries;
}

- (void)deleteBeaconDiscoveryWithFriendEmail:(NSString *)friendEmail
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            sqlite3_bind_text(stmtDeleteBeaconDiscoveryByEmail_, 1, [friendEmail UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtDeleteBeaconDiscoveryByEmail_)) != SQLITE_DONE) {
                LOG(@"Failed to delete beacon discovery friendEmail: %@", friendEmail);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtDeleteBeaconDiscoveryByEmail_);
        }
    }];
}

- (void)deleteBeaconDiscoveryWithUUID:(NSString *)uuid name:(NSString *)name
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            sqlite3_bind_text(stmtDeleteBeaconDiscoveryByUuidAndName_, 1, [uuid UTF8String], -1, NULL);
            sqlite3_bind_text(stmtDeleteBeaconDiscoveryByUuidAndName_, 2, [name UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtDeleteBeaconDiscoveryByUuidAndName_)) != SQLITE_DONE) {
                LOG(@"Failed to delete beacon discovery uuid: %@ name: %@", uuid, name);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtDeleteBeaconDiscoveryByUuidAndName_);
        }
    }];
}

- (NSDictionary *)friendConnectedToBeaconDiscoveryWithUUID:(NSString *)uuid name:(NSString *)name
{
    T_DONTCARE();
    __block NSMutableDictionary *beaconInfo = nil;
    [self dbLockedOperationWithBlock:^{

        @try {
            int e;

            sqlite3_bind_text(stmtGetFriendConnectedOnBeaconDiscovery_, 1, [uuid UTF8String], -1, NULL);
            sqlite3_bind_text(stmtGetFriendConnectedOnBeaconDiscovery_, 2, [name UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtGetFriendConnectedOnBeaconDiscovery_)) == SQLITE_ROW) {
                beaconInfo = [NSMutableDictionary dictionary];
                [beaconInfo setString:[NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFriendConnectedOnBeaconDiscovery_, 0)] forKey:@"email"];
                [beaconInfo setString:[NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetFriendConnectedOnBeaconDiscovery_, 1)] forKey:@"tag"];
                [beaconInfo setLong:sqlite3_column_int(stmtGetFriendConnectedOnBeaconDiscovery_, 2) forKey:@"callbacks"];
            }
        }
        @finally {
            sqlite3_reset(stmtGetFriendConnectedOnBeaconDiscovery_);
        }
        
    }];
    return beaconInfo;
}

- (void)clearBeaconRegions
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            if ((e = sqlite3_step(stmtClearBeaconRegions_)) != SQLITE_DONE) {
                LOG(@"Failed to delete all beacon regions");
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtClearBeaconRegions_);
        }
    }];
}

- (void)insertBeaconRegion:(MCT_com_mobicage_to_beacon_BeaconRegionTO *)beaconRegion
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtInsertBeaconRegion_, 1, [beaconRegion.uuid UTF8String], -1, NULL);
            if (beaconRegion.has_major) {
                sqlite3_bind_int64(stmtInsertBeaconRegion_, 2, beaconRegion.major);
            } else {
                sqlite3_bind_null(stmtInsertBeaconRegion_, 2);
            }
            if (beaconRegion.has_minor) {
                sqlite3_bind_int64(stmtInsertBeaconRegion_, 3, beaconRegion.minor);
            } else {
                sqlite3_bind_null(stmtInsertBeaconRegion_, 3);
            }

            if ((e = sqlite3_step(stmtInsertBeaconRegion_)) != SQLITE_DONE) {
                LOG(@"Failed to insert beacon region %@", [beaconRegion dictRepresentation]);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtInsertBeaconRegion_);
        }
    }];
}

- (void)setBeaconRegions:(NSArray *)regions
{
    T_DONTCARE()
    [self dbLockedTransactionWithBlock:^{
        [self clearBeaconRegions];
        for (MCT_com_mobicage_to_beacon_BeaconRegionTO *region in regions) {
            [self insertBeaconRegion:region];
        }
    }];

    [[MCTComponentFramework intentFramework] broadcastIntent:[MCTIntent intentWithAction:kINTENT_BEACON_REGIONS_UPDATED]];
}

- (NSArray *)beaconRegions
{
    T_DONTCARE();
    NSMutableArray *beaconRegions = [NSMutableArray array];

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            while ((e = sqlite3_step(stmtGetBeaconRegions_)) != SQLITE_DONE) {
                if (e != SQLITE_ROW) {
                    LOG(@"Failed to get beacon regions");
                    MCT_THROW_SQL_EXCEPTION(e);
                }

                MCT_com_mobicage_to_beacon_BeaconRegionTO *regionTO =
                    [MCT_com_mobicage_to_beacon_BeaconRegionTO transferObject];
                regionTO.uuid = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetBeaconRegions_, 0)];
                regionTO.has_major = sqlite3_column_type(stmtGetBeaconRegions_, 1) != SQLITE_NULL;
                regionTO.major = regionTO.has_major ? sqlite3_column_int(stmtGetBeaconRegions_, 1) : -1;
                regionTO.has_minor = sqlite3_column_type(stmtGetBeaconRegions_, 2) != SQLITE_NULL;
                regionTO.minor = regionTO.has_minor ? sqlite3_column_int(stmtGetBeaconRegions_, 2) : -1;
                [beaconRegions addObject:regionTO];
            }
        }
        @finally {
            sqlite3_reset(stmtGetBeaconRegions_);
        }
    }];

    return beaconRegions;
}

@end