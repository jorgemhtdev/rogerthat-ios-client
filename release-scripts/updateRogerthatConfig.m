#import <Foundation/Foundation.h>

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // keys with their types defined in order
    NSArray *ARGV_KEYS_AND_TYPES = [NSArray arrayWithObjects:
                                    @"string",          @"APP_EMAIL",
                                    @"string",          @"APP_HOMESCREEN_BACKGROUND_COLOR",
                                    @"string",          @"APP_HOMESCREEN_TEXT_COLOR",
                                    @"string",          @"APP_HOMESCREEN_COLOR_SCHEME",
                                    @"boolean",         @"FULL_WIDTH_HEADERS",
                                    @"string",          @"APP_TINT_COLOR",
                                    @"int",             @"APP_TYPE",
                                    @"string",          @"HOME_SCREEN_STYLE",
                                    @"string",          @"HTTPS_BASE_URL",
                                    @"string",          @"HTTP_BASE_URL",
                                    @"boolean",         @"USE_TRUSTSTORE",
                                    @"boolean",         @"FRIENDS_ENABLED",
                                    @"string",          @"FRIENDS_CAPTION",
                                    @"boolean",         @"SHOW_FRIENDS_IN_MORE",
                                    @"boolean",         @"SHOW_PROFILE_IN_MORE",
                                    @"boolean",         @"SHOW_HOMESCREEN_FOOTER",
                                    @"string",          @"XMPP_KICK_COMPONENT",
                                    @"number_array",    @"SEARCH_SERVICES_IF_NONE_CONNECTED",
                                    @"string_array",    @"PROFILE_DATA_FIELDS",
                                    @"boolean",         @"PROFILE_SHOW_GENDER_AND_BIRTHDATE",
                                    @"boolean",         @"USE_XMPP_KICK_CHANNEL",
                                    @"boolean",         @"FACEBOOK_REGISTRATION",
                                    @"boolean",         @"MESSAGES_SHOW_REPLY_VS_UNREAD_COUNT",
                                    @"string",          @"REGISTRATION_MAIN_SIGNATURE",
                                    @"string",          @"REGISTRATION_EMAIL_SIGNATURE",
                                    @"string",          @"REGISTRATION_PIN_SIGNATURE",
                                    @"string",          @"EMAIL_HASH_ENCRYPTION_KEY",
                                    @"string",          @"ABOUT_WEBSITE",
                                    @"string",          @"ABOUT_WEBSITE_URL",
                                    @"string",          @"ABOUT_EMAIL",
                                    @"string",          @"ABOUT_TWITTER",
                                    @"string",          @"ABOUT_TWITTER_APP_URL",
                                    @"string",          @"ABOUT_TWITTER_URL",
                                    @"string",          @"ABOUT_FACEBOOK",
                                    @"string",          @"ABOUT_FACEBOOK_URL",
                                    nil];

    NSMutableString* mutablePath = [NSMutableString string];

    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [[mainBundle bundlePath] stringByAppendingPathComponent:@".."];
    [mutablePath setString:path];
    [mutablePath appendString:@"/"];
    [mutablePath appendString:@"MCResources"];
    [mutablePath appendString:@"/"];
    [mutablePath appendString:@"RogerthatConfig.plist"];

    NSLog(@"path: %@", mutablePath);

    NSMutableDictionary *configDict = [NSMutableDictionary dictionaryWithContentsOfFile:mutablePath];

    for (int i = 0; i < [ARGV_KEYS_AND_TYPES count]; i = i + 2) {
        NSString *type = [ARGV_KEYS_AND_TYPES objectAtIndex:i];
        NSString *key = [ARGV_KEYS_AND_TYPES objectAtIndex:i + 1];
        NSString *newValue = [NSString stringWithUTF8String:argv[i / 2 + 1]];

        if ([@"None" isEqualToString:newValue]) {
            newValue = @"";
        }

        NSObject *newValueObject;
        if ([@"string" isEqualToString:type]) {
            newValueObject = newValue;
        }

        else if ([@"int" isEqualToString:type]) {
            newValueObject = [NSNumber numberWithInteger:[newValue integerValue]];
        }

        else if ([@"boolean" isEqualToString:type]) {
            newValueObject = [NSNumber numberWithBool:[@"1" isEqualToString:newValue]];
        }

        else if ([@"string_array" isEqualToString:type]) {
            NSMutableArray *a = [NSMutableArray array];
            for (NSString *s in [newValue componentsSeparatedByString:@","]) {
                if ([s length] > 0) {
                    [a addObject:s];
                }
            }
            newValueObject = a;
        }

        else if ([@"number_array" isEqualToString:type]) {
            NSMutableArray *a = [NSMutableArray array];
            for (NSString *s in [newValue componentsSeparatedByString:@","]) {
                if ([s length] > 0) {
                    [a addObject:@([s longLongValue])];
                }
            }
            newValueObject = a;
        }

        else {
            @throw [[[NSException alloc] initWithName:@"UnsupportedTypeException"
                                               reason:[NSString stringWithFormat:@"Unsupported type: %@ for value %@", type, newValue]
                                             userInfo:nil] autorelease];
        }

        NSLog(@"%@: %@ -> %@", key, [configDict objectForKey:key], newValueObject);
        [configDict setObject:newValueObject
                       forKey:key];
    }

    [configDict writeToFile:mutablePath atomically:YES];

    [pool drain];
    return 0;
}