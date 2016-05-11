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

#import "MCTAddressBook.h"
#import "MCTComponentFramework.h"
#import "MCTUtils.h"

@implementation MCTAddressBook

+ (BOOL)accessGrantedWithAddressBook:(ABAddressBookRef)myAddressBook
{
    T_DONTCARE();
    if (!myAddressBook)
        return NO;

    __block BOOL accessGranted = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(myAddressBook, ^(bool granted, CFErrorRef error) {
        accessGranted = granted;
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    return accessGranted;
}

+ (NSMutableArray *)loadPhoneContactsWithEmail:(BOOL)includeEmail andPhone:(BOOL)includePhone andSorted:(BOOL)sorted
{
    T_DONTCARE();
    NSMutableArray *contacts = [NSMutableArray array];

    if (!includeEmail && !includePhone) {
        ERROR(@"Returning empty list because you want to load phone contacts without emails/phones");
        return contacts;
    }

    ABAddressBookRef myAddressBook = ABAddressBookCreateWithOptions(NULL, nil);
    if (!myAddressBook || ![MCTAddressBook accessGrantedWithAddressBook:myAddressBook])
        return contacts;

    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(myAddressBook);
    CFIndex contactsCount = ABAddressBookGetPersonCount(myAddressBook);

    NSArray *keys = [NSArray arrayWithObjects:(NSString *) kABPersonPhoneHomeFAXLabel,
                     (NSString *) kABPersonPhoneIPhoneLabel, (NSString *) kABPersonPhoneMainLabel,
                     (NSString *) kABPersonPhoneMobileLabel, (NSString *) kABPersonPhonePagerLabel,
                     (NSString *) kABPersonPhoneWorkFAXLabel,
                     (NSString *) kABHomeLabel, (NSString *) kABOtherLabel, (NSString *) kABWorkLabel, nil];

    NSArray *objects = [NSArray arrayWithObjects:@"Home fax", @"iPhone", @"Main", @"Mobile", @"Pager", @"Work fax",
                        @"Home", @"Other", @"Work", nil];

    NSMutableDictionary *labelMapping = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];

    IF_IOS5_OR_GREATER(
        [labelMapping setObject:@"Other fax" forKey:(NSString *) kABPersonPhoneOtherFAXLabel];
    )

    for (int i = 0; i < contactsCount; i++) {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);

        NSMutableArray *numbers = [NSMutableArray array];

        if (includePhone) {
            ABMutableMultiValueRef numberRefs = ABRecordCopyValue(ref, kABPersonPhoneProperty);
            for (int j = 0; j < ABMultiValueGetCount(numberRefs); j++) {
                CFStringRef lbl = ABMultiValueCopyLabelAtIndex(numberRefs, j);

                NSString *label;
                if (lbl == NULL) {
                    // label can be null e.g. for MS Exchange contacts
                    // http://mattgemmell.com/2008/10/31/iphone-dev-tips-for-synced-contacts/
                    label = @"";
                } else {
                    label = [labelMapping valueForKey:(__bridge NSString *)lbl];
                    if (label == nil)
                        label = [NSString stringWithString:(__bridge NSString *)lbl];
                    CFRelease(lbl);
                }

                CFStringRef no = ABMultiValueCopyValueAtIndex(numberRefs, j);
                NSString *number = [NSString stringWithString:(__bridge NSString *)no];
                CFRelease(no);

                [numbers addObject:[MCTContactField fieldWithLabel:label andValue:number]];
            }
            CFRelease(numberRefs);
        }

        NSMutableArray *emails = [NSMutableArray array];

        if (includeEmail) {
            ABMutableMultiValueRef emailRefs = ABRecordCopyValue(ref, kABPersonEmailProperty);
            for (int j = 0; j < ABMultiValueGetCount(emailRefs); j++) {
                CFStringRef lbl = ABMultiValueCopyLabelAtIndex(emailRefs, j);
                
                NSString *label;
                if (lbl == NULL) {
                    // label can be null e.g. for MS Exchange contacts
                    // http://mattgemmell.com/2008/10/31/iphone-dev-tips-for-synced-contacts/
                    label = @"";
                } else {
                    label = [labelMapping valueForKey:(__bridge NSString *)lbl];
                    if (label == nil)
                        label = [NSString stringWithString:(__bridge NSString *)lbl];
                    CFRelease(lbl);
                }
                
                CFStringRef emailRef = ABMultiValueCopyValueAtIndex(emailRefs, j);
                NSString *email = [NSString stringWithString:(__bridge NSString *)emailRef];
                CFRelease(emailRef);
                
                [emails addObject:[MCTContactField fieldWithLabel:label andValue:email]];
            }
            CFRelease(emailRefs);
        }

        if ([numbers count] || [emails count]) {
            CFStringRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            CFStringRef lastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);

            NSString *displayName;
            if (firstName == NULL && lastName == NULL) {
                CFStringRef companyName = ABRecordCopyValue(ref, kABPersonOrganizationProperty);
                if (companyName != NULL) {
                    displayName = [NSString stringWithString:(__bridge NSString *)companyName];
                    CFRelease(companyName);
                }
                else
                    displayName = @"";
            } else if (firstName == NULL)
                displayName = [NSString stringWithString:(__bridge NSString *) lastName];
            else if (lastName == NULL)
                displayName = [NSString stringWithString:(__bridge NSString *) firstName];
            else if (ABPersonGetCompositeNameFormatForRecord(nil) == kABPersonCompositeNameFormatFirstNameFirst)
                displayName = [NSString stringWithFormat: @"%@ %@", firstName, lastName];
            else
                displayName = [NSString stringWithFormat: @"%@ %@", lastName, firstName];

            if (firstName != NULL)
                CFRelease(firstName);
            if (lastName != NULL)
                CFRelease(lastName);

            if ([MCTUtils isEmptyOrWhitespaceString:displayName]) {
                MCTContactField *field;
                if ([emails count]) {
                    field = [emails objectAtIndex:0];
                } else if ([numbers count]) {
                    field = [numbers objectAtIndex:0];
                } else {
                    continue;
                }
                displayName = field.value;
            }
            MCTContactEntry *contact = [[MCTContactEntry alloc] init];
            contact.name = displayName;
            contact.numbers = numbers;
            contact.emails = emails;
            
            if (sorted) {
                [emails sortByKeys:@"value", @"label", nil];
                [numbers sortByKeys:@"value", @"label", nil];
            }

            if (ABPersonHasImageData(ref)) {
                CFDataRef imageData;
                if ((imageData = ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail)) != NULL) {
                    contact.image = [NSData dataWithData:(__bridge NSData *) imageData];
                    CFRelease(imageData);
                }
            }

            [contacts addObject:contact];
        }
    }

    CFRelease(allPeople);
    CFRelease(myAddressBook);

    if (sorted) {
        [contacts sortByKeys:@"name", nil];
    }

    return contacts;
}

@end