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
#import "MCTFindFriendsViaFacebookRH.h"
#import "MCTMenuVC.h"
#import "MCTPickler.h"
#import "MCTTransferObjects.h"

#import "NSData+Base64.h"
#import "NSString+MCT_SBJSON.h"


#define PICKLE_CLASS_VERSION 1


@implementation MCTFindFriendsViaFacebookRH

- (void)presentLocalNotificationWithBody:(NSString *)body
{
    T_DONTCARE();
    NSString *path = MCT_GOTO_ADD_FRIENDS_VIA_FACEBOOK;

    // Cancel old LN
    NSString *serialized = [[MCTComponentFramework configProvider] stringForKey:path];
    if (serialized) {
        UILocalNotification *old = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataFromBase64String:serialized]];
        [[UIApplication sharedApplication] cancelLocalNotification:old];
    }

    UILocalNotification *ln = [[UILocalNotification alloc] init];
    ln.userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@%@", MCT_PREFIX_ROGERTHAT_URL, path]
                                              forKey:MCT_GOTO];
    ln.alertBody = body;
    ln.hasAction = NO;
    [[UIApplication sharedApplication] presentLocalNotificationNow:ln];

    // Store new LN
    serialized = [[NSKeyedArchiver archivedDataWithRootObject:ln] base64EncodedString];
    [[MCTComponentFramework configProvider] setString:serialized forKey:path];
}

- (void)handleError:(NSString *)error
{
    T_BIZZ();
    LOG(@"Error response for FindFriendsViaFacebook request: %@", error);
    [[MCTComponentFramework intentFramework] broadcastIntent:[MCTIntent intentWithAction:kINTENT_FB_FRIENDS_SCAN_FAILED]];

    [self presentLocalNotificationWithBody:[NSString stringWithFormat:NSLocalizedString(@"__error_find_from_facebook", nil), MCT_PRODUCT_NAME]];
}

- (void)handleResult:(MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO *)result
{
    T_BIZZ();
    LOG(@"Result received for FindFriendsViaFacebook request");
    NSMutableArray *jsonAble = [NSMutableArray arrayWithCapacity:[result.matches count]];
    for (MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO *match in result.matches) {
        [jsonAble addObject:[match dictRepresentation]];
    }

    NSString *resultStr = [jsonAble MCT_JSONRepresentation];
    [[MCTComponentFramework configProvider] setString:resultStr
                                               forKey:MCT_CONFIGKEY_FACEBOOK_FRIENDS_SCAN];

    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_FB_FRIENDS_SCANNED];
    [intent setString:@"result" forKey:resultStr];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];

    [self presentLocalNotificationWithBody:[NSString stringWithFormat:NSLocalizedString(@"__add_via_facebook_notification", nil), MCT_PRODUCT_NAME]];
}

- (MCTFindFriendsViaFacebookRH *)initWithCoder:(NSCoder *)coder forClassVersion:(int)classVersion
{
    T_BACKLOG();
    if (classVersion != PICKLE_CLASS_VERSION) {
        ERROR(@"Erroneous pickle class version %d", classVersion);
        return nil;
    }

    return [super initWithCoder:coder];
}

- (int)classVersion
{
    T_BACKLOG();
    return PICKLE_CLASS_VERSION;
}

@end