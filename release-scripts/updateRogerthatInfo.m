#import <Foundation/Foundation.h>

int main (int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSMutableString *mutablePath = [NSMutableString string];

    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [[mainBundle bundlePath] stringByAppendingPathComponent:@".."];
    [mutablePath setString:path];
    [mutablePath appendString:@"/"];
    [mutablePath appendString:@"rogerthat_Info.plist"];

    NSLog(@"path: %@", mutablePath);

    NSMutableDictionary *configDict = [NSMutableDictionary dictionaryWithContentsOfFile:mutablePath];

    NSString *appBundle = @"com.mobicage.rogerthat.${PRODUCT_NAME}";
    NSString *appId = [NSString stringWithUTF8String:argv[1]];
    NSString *appName = [NSString stringWithUTF8String:argv[2]];
    NSString *facebookAppId = [NSString stringWithUTF8String:argv[3]];
    BOOL useVOIP = [@"true" isEqualToString:[[NSString stringWithUTF8String:argv[4]] lowercaseString]];
    NSString *colorScheme = [NSString stringWithUTF8String:argv[5]];

    NSLog(@"CFBundleIdentifier: %@ -> %@", configDict[@"CFBundleIdentifier"], appBundle);
    NSLog(@"CFBundleDisplayName: %@ -> %@", configDict[@"CFBundleDisplayName"], appName);
    NSLog(@"FacebookAppID: %@ -> %@", configDict[@"FacebookAppID"], facebookAppId);
    NSLog(@"useVOIP: %@", useVOIP ? @"YES" : @"NO");
    NSLog(@"colorScheme: %@", colorScheme);

    configDict[@"CFBundleIdentifier"] = appBundle;
    configDict[@"CFBundleDisplayName"] = appName;
    configDict[@"UIStatusBarStyle"] = [@"dark" isEqualToString:colorScheme] ? @"UIStatusBarStyleLightContent" : @"UIStatusBarStyleDefault";

    BOOL hasFacebookScheme = NO;
    for (NSInteger i = [configDict[@"CFBundleURLTypes"] count] - 1; i >= 0; i--) {
        NSDictionary *val = configDict[@"CFBundleURLTypes"][i];
        NSString *scheme = val[@"CFBundleURLSchemes"][0];
        NSString *urlId = val[@"CFBundleURLName"];
        if (urlId && [urlId hasPrefix:@"com.mobicage.rogerthat."] && [urlId hasSuffix:@".mdp"]) {
            if ([appId isEqualToString:@"rogerthat"]) {
                [val setValue:@"com.mobicage.rogerthat.mdp" forKey:@"CFBundleURLName"];
            } else {
                [val setValue:[NSString stringWithFormat:@"com.mobicage.rogerthat.%@.mdp",
                               [appId stringByReplacingOccurrencesOfString:@"-" withString:@"."]]
                       forKey:@"CFBundleURLName"];
            }
            val[@"CFBundleURLSchemes"][0] = [NSString stringWithFormat:@"mdp-%@", appId];
            NSLog(@"CFBundleURLSchemes MDP: %@ -> %@", scheme, val[@"CFBundleURLSchemes"][0]);
        } else if (urlId && [urlId hasPrefix:@"com.mobicage.rogerthat."] && [urlId hasSuffix:@".oauth"]) {
            if ([appId isEqualToString:@"rogerthat"]) {
                [val setValue:@"com.mobicage.rogerthat.oauth" forKey:@"CFBundleURLName"];
            } else {
                [val setValue:[NSString stringWithFormat:@"com.mobicage.rogerthat.%@.oauth",
                               [appId stringByReplacingOccurrencesOfString:@"-" withString:@"."]]
                       forKey:@"CFBundleURLName"];
            }
            val[@"CFBundleURLSchemes"][0] = [NSString stringWithFormat:@"oauth-%@", appId];
            NSLog(@"CFBundleURLSchemes OAUTH: %@ -> %@", scheme, val[@"CFBundleURLSchemes"][0]);
        } else if ([scheme hasPrefix:@"fb"]) {
            hasFacebookScheme = YES;
            if ([facebookAppId isEqualToString:@"None"]) {
                [configDict[@"CFBundleURLTypes"] removeObjectAtIndex:i];
            } else {
                val[@"CFBundleURLSchemes"][0] = [NSString stringWithFormat:@"fb%@", facebookAppId];
                NSLog(@"CFBundleURLSchemes Facebook: %@ -> %@", scheme, val[@"CFBundleURLSchemes"][0]);
            }
        }
    }

    if ([facebookAppId isEqualToString:@"None"]) {
        [configDict removeObjectForKey:@"FacebookAppID"];
        [configDict removeObjectForKey:@"FacebookDisplayName"];
    } else {
        NSLog(@"FacebookDisplayName: %@ -> %@", configDict[@"FacebookDisplayName"], appName);
        [configDict setObject:facebookAppId forKey:@"FacebookAppID"];
        [configDict setObject:appName forKey:@"FacebookDisplayName"];
        if (!hasFacebookScheme) {
            NSMutableDictionary *fbSchemeDict = [NSMutableDictionary dictionary];
            NSString *scheme = [NSString stringWithFormat:@"fb%@", facebookAppId];
            [fbSchemeDict setObject:[NSArray arrayWithObjects:scheme, nil] forKey:@"CFBundleURLSchemes"];
            [configDict[@"CFBundleURLTypes"] addObject:fbSchemeDict];

            NSLog(@"Created CFBundleURLSchemes Facebook: %@", scheme);
        }
    }

    for (NSUInteger i = 0; i < [configDict[@"LSApplicationQueriesSchemes"] count]; i++) {
        NSString *scheme = configDict[@"LSApplicationQueriesSchemes"][i];
        if ([scheme hasPrefix:@"mdp-"]) {
            configDict[@"LSApplicationQueriesSchemes"][i] = [NSString stringWithFormat:@"mdp-%@", appId];
        }
        if ([scheme hasPrefix:@"oauth-"]) {
            configDict[@"LSApplicationQueriesSchemes"][i] = [NSString stringWithFormat:@"oauth-%@", appId];
        }
    }

    NSMutableArray *backgroundModes = [NSMutableArray arrayWithArray:configDict[@"UIBackgroundModes"]];
    if (useVOIP) {
        if (![backgroundModes containsObject:@"voip"]) {
            [backgroundModes addObject:@"voip"];
        }
    } else {
        if ([backgroundModes containsObject:@"voip"]) {
            [backgroundModes removeObject:@"voip"];
        }
    }
    configDict[@"UIBackgroundModes"] = backgroundModes;

    [configDict writeToFile:mutablePath atomically:YES];
    
    [pool drain];
    return 0;
}