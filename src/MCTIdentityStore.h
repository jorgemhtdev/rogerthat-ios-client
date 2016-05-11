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

#import "MCTIdentity.h"
#import "MCTStore.h"
#import "MCTTransferObjects.h"

@interface MCTIdentityStore : MCTStore

- (MCTIdentity *)myIdentity;
- (void)updateMyIdentity:(MCT_com_mobicage_to_system_IdentityTO *)identity withShortUrl:(NSString *)shortUrl;
- (void)updateMyIdentityWithoutDownloadingAvatar:(MCTIdentity *)identity;
- (void)updateShortUrl:(NSString *)shortUrl;
- (void)saveAvatarWithData:(NSData *)avatar;
- (void)saveQRCodeWithData:(NSData *)qrCode andShortUrl:(NSString *)shortUrl;
- (NSData *)qrCode;

@end