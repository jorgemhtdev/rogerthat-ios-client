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
#import "MCTEncoding.h"
#import "MCTFriendsPlugin.h"
#import "MCTIdentityStore.h"
#import "MCTIdentity.h"
#import "MCTIntent.h"
#import "MCTIntentFramework.h"
#import "MCTOperation.h"
#import "MCTTransferObjects.h"

#define MCT_DUMMY_EMAIL @"dummy"

@interface MCTIdentityStore ()

@property (nonatomic, strong) MCTIdentity *identity;

- (void)initPreparedStatements;
- (void)destroyPreparedStatements;

- (void)updateIdentity:(MCT_com_mobicage_to_system_IdentityTO *)identity;

@end


@implementation MCTIdentityStore


static sqlite3_stmt *stmtGetIdentity_;
static sqlite3_stmt *stmtGetIdentityQRCode_;
static sqlite3_stmt *stmtUpdateIdentity_;
static sqlite3_stmt *stmtUpdateIdentityAvatar_;
static sqlite3_stmt *stmtUpdateIdentityQRCode_;
static sqlite3_stmt *stmtUpdateIdentityShortUrl_;


- (MCTIdentityStore *)init
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
        [self prepareStatement:&stmtGetIdentity_
                  withQueryKey:@"sql_get_identity"];

        [self prepareStatement:&stmtGetIdentityQRCode_
                  withQueryKey:@"sql_get_identity_qr_code"];

        [self prepareStatement:&stmtUpdateIdentity_
                  withQueryKey:@"sql_update_identity"];

        [self prepareStatement:&stmtUpdateIdentityAvatar_
                  withQueryKey:@"sql_update_identity_avatar"];

        [self prepareStatement:&stmtUpdateIdentityQRCode_
                  withQueryKey:@"sql_update_identity_qr_code"];

        [self prepareStatement:&stmtUpdateIdentityShortUrl_
                  withQueryKey:@"sql_update_identity_short_url"];
    }];
}

- (void)destroyPreparedStatements
{
    T_BIZZ();
    [self dbLockedOperationWithBlock:^{
        [self finalizeStatement:stmtGetIdentity_
                   withQueryKey:@"sql_get_identity"];

        [self finalizeStatement:stmtGetIdentityQRCode_
                   withQueryKey:@"sql_get_identity_qr_code"];

        [self finalizeStatement:stmtUpdateIdentity_
                   withQueryKey:@"sql_update_identity"];

        [self finalizeStatement:stmtUpdateIdentityAvatar_
                   withQueryKey:@"sql_update_identity_avatar"];

        [self finalizeStatement:stmtUpdateIdentityQRCode_
                   withQueryKey:@"sql_update_identity_qr_code"];

        [self finalizeStatement:stmtUpdateIdentityShortUrl_
                   withQueryKey:@"sql_update_identity_short_url"];
    }];
}

- (MCTIdentity *)myIdentity
{
    T_DONTCARE();

    if (self.identity == nil) {
        [self dbLockedOperationWithBlock:^{
            if (self.identity == nil) {
                @try {
                    int e;

                    if ((e = sqlite3_step(stmtGetIdentity_)) == SQLITE_DONE) {
                        return;
                    } else if (e != SQLITE_ROW) {
                        MCT_THROW_SQL_EXCEPTION(e);
                    }

                    NSString *email = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetIdentity_, 0)];
                    if ([email isEqualToString:MCT_DUMMY_EMAIL]) {
                        return;
                    }

                    MCTIdentity *me = [MCTIdentity identity];
                    me.email = email;
                    me.name = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetIdentity_, 1)];
                    int avatarLength = sqlite3_column_bytes(stmtGetIdentity_, 2);
                    if (avatarLength != 0) {
                        const void *avatarBytes = sqlite3_column_blob(stmtGetIdentity_, 2);
                        me.avatar = [NSData dataWithBytes:avatarBytes length:avatarLength];
                    }
                    me.shortUrl = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetIdentity_, 4)];
                    me.qualifiedIdentifier = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetIdentity_, 5)];
                    me.avatarId = sqlite3_column_int64(stmtGetIdentity_, 6);


                    if (sqlite3_column_type(stmtGetIdentity_, 7) == SQLITE_NULL) {
                        me.hasBirthdate = NO;
                        me.birthdate = 0;
                    } else {
                        me.hasBirthdate = YES;
                        me.birthdate = sqlite3_column_int64(stmtGetIdentity_, 7);
                    }

                    if (sqlite3_column_type(stmtGetIdentity_, 8) == SQLITE_NULL) {
                        me.hasGender = NO;
                        me.gender = 0;
                    } else {
                        me.hasGender = YES;
                        me.gender = sqlite3_column_int64(stmtGetIdentity_, 8);
                    }

                    me.profileData = [NSString stringWithUTF8StringSafe:sqlite3_column_text(stmtGetIdentity_, 9)];

                    self.identity = me;
                    self.identity.emailHash = [MCTEncoding emailHashForEmail:self.identity.email
                                                                    withType:MCTFriendTypeUser];
                }
                @finally {
                    sqlite3_reset(stmtGetIdentity_);
                }
            }
        }];
    }
    return self.identity;
}

- (void)updateIdentity:(MCT_com_mobicage_to_system_IdentityTO *)identity
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtUpdateIdentity_, 1, [identity.email UTF8String], -1, NULL);
            if ([MCTUtils isEmptyOrWhitespaceString:identity.name]) {
                sqlite3_bind_null(stmtUpdateIdentity_, 2);
            } else {
                sqlite3_bind_text(stmtUpdateIdentity_, 2, [identity.name UTF8String], -1, NULL);
            }
            if ([MCTUtils isEmptyOrWhitespaceString:identity.qualifiedIdentifier]) {
                sqlite3_bind_null(stmtUpdateIdentity_, 3);
            } else {
                sqlite3_bind_text(stmtUpdateIdentity_, 3, [identity.qualifiedIdentifier UTF8String], -1, NULL);
            }
            sqlite3_bind_int64(stmtUpdateIdentity_, 4, identity.avatarId);

            if(identity.hasBirthdate){
                sqlite3_bind_int64(stmtUpdateIdentity_, 5, identity.birthdate);
            } else{
                sqlite3_bind_null(stmtUpdateIdentity_, 5);
            }

            if(identity.hasGender){
                sqlite3_bind_int64(stmtUpdateIdentity_, 6, identity.gender);
            } else{
                sqlite3_bind_null(stmtUpdateIdentity_, 6);
            }

            if ([MCTUtils isEmptyOrWhitespaceString:identity.profileData]){
                sqlite3_bind_null(stmtUpdateIdentity_, 7);
            } else{
                sqlite3_bind_text(stmtUpdateIdentity_, 7, [identity.profileData UTF8String], -1, NULL);
            }

            if ((e = sqlite3_step(stmtUpdateIdentity_)) != SQLITE_DONE) {
                LOG(@"Failed to update identity %@", identity);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateIdentity_);
        }
    }];
}

- (void)updateShortUrl:(NSString *)shortUrl
{
    T_DONTCARE();
    if (shortUrl == nil)
        return;

    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_text(stmtUpdateIdentityShortUrl_, 1, [shortUrl UTF8String], -1, NULL);

            if ((e = sqlite3_step(stmtUpdateIdentityShortUrl_)) != SQLITE_DONE) {
                LOG(@"Failed to update identity short url %@", shortUrl);
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateIdentityShortUrl_);
        }
    }];

    MCT_RELEASE(self.identity);
}

- (void)updateMyIdentity:(MCT_com_mobicage_to_system_IdentityTO *)identity withShortUrl:(NSString *)shortUrl
{
    T_DONTCARE();

    [self dbLockedOperationWithBlock:^{
        [self updateIdentity:identity];
        [self updateShortUrl:shortUrl];
    }];

    // Clearing cached value
    MCT_RELEASE(self.identity);

    if (identity.avatarId != -1) {
        [[MCTComponentFramework friendsPlugin] requestAvatarWithId:identity.avatarId andEmail:identity.email];
    }

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_IDENTITY_MODIFIED];
    [intent setString:identity.email forKey:@"email"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (void)updateMyIdentityWithoutDownloadingAvatar:(MCTIdentity *)identity
{
    T_DONTCARE();
    NSString *email = identity.email;
    LOG(@"identity: %@", identity);
    [self dbLockedOperationWithBlock:^{
        [self updateIdentity:identity];
        if (identity.avatar)
            [self saveAvatarWithData:identity.avatar];

        // Clearing cached value
        MCT_RELEASE(self.identity);
    }];

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_IDENTITY_MODIFIED];
    [intent setString:email forKey:@"email"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (void)saveAvatarWithData:(NSData *)avatar
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_blob(stmtUpdateIdentityAvatar_, 1, [avatar bytes], (int)[avatar length], NULL);

            if ((e = sqlite3_step(stmtUpdateIdentityAvatar_)) != SQLITE_DONE) {
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateIdentityAvatar_);
        }

        // Clearing cached value
        MCT_RELEASE(self.identity);
    }];

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_IDENTITY_MODIFIED];
    [intent setString:[[self myIdentity] email] forKey:@"email"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (void)saveQRCodeWithData:(NSData *)qrCode andShortUrl:(NSString *)shortUrl
{
    T_DONTCARE();
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            sqlite3_bind_blob(stmtUpdateIdentityQRCode_, 1, [qrCode bytes], (int)[qrCode length], NULL);

            if ((e = sqlite3_step(stmtUpdateIdentityQRCode_)) != SQLITE_DONE) {
                MCT_THROW_SQL_EXCEPTION(e);
            }
        }
        @finally {
            sqlite3_reset(stmtUpdateIdentityQRCode_);
        }

        [self updateShortUrl:shortUrl];
    }];

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_IDENTITY_QR_RETREIVED];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (NSData *)qrCode
{
    T_UI();
    __block NSData *qr = nil;
    [self dbLockedOperationWithBlock:^{
        @try {
            int e;

            if ((e = sqlite3_step(stmtGetIdentityQRCode_)) != SQLITE_ROW) {
                MCT_THROW_SQL_EXCEPTION(e);
            }

            int qrLength = sqlite3_column_bytes(stmtGetIdentityQRCode_, 0);
            if (qrLength != 0) {
                const void *qrBytes = sqlite3_column_blob(stmtGetIdentityQRCode_, 0);
                qr = [NSData dataWithBytes:qrBytes length:qrLength];
            }
        }
        @finally {
            sqlite3_reset(stmtGetIdentityQRCode_);
        }
    }];
    return qr;
}

@end