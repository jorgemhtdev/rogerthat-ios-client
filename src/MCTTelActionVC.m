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

#import <AddressBook/AddressBook.h>

#import "MCTAddressBook.h"
#import "MCTContactEntry.h"
#import "MCTTelActionVC.h"
#import "MCTUIUtils.h"


@implementation MCTTelActionVC


+ (MCTTelActionVC *)viewController
{
    return [[MCTTelActionVC alloc] initWithNibName:@"telAction" bundle:nil];
}

- (void)viewDidLoad
{
    T_UI();
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Contacts", nil);

    NSArray *keys = [NSArray arrayWithObjects:(NSString *) kABPersonPhoneHomeFAXLabel,
                     (NSString *) kABPersonPhoneIPhoneLabel, (NSString *) kABPersonPhoneMainLabel,
                     (NSString *) kABPersonPhoneMobileLabel, (NSString *) kABPersonPhonePagerLabel,
                     (NSString *) kABPersonPhoneWorkFAXLabel, (NSString *) kABHomeLabel, (NSString *) kABOtherLabel,
                     (NSString *) kABWorkLabel, nil];

    NSArray *objects = [NSArray arrayWithObjects:@"Home fax", @"iPhone", @"Main", @"Mobile", @"Pager", @"Work fax",
                        @"Home", @"Other", @"Work", nil];

    NSDictionary *labelMapping = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

    self.contactEntries = [NSMutableArray array];

    ABAddressBookRef myAddressBook = ABAddressBookCreateWithOptions(NULL, nil);
    if (myAddressBook && [MCTAddressBook accessGrantedWithAddressBook:myAddressBook]) {
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(myAddressBook);
        CFIndex contactsCount = ABAddressBookGetPersonCount(myAddressBook);

        for (int i = 0; i < contactsCount; i++) {
            ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);

            CFStringRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            CFStringRef lastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);

            NSString *displayName;
            if (firstName == NULL && lastName == NULL)
                displayName = @"";
            else if (firstName == NULL)
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

            NSMutableArray *numbers = [NSMutableArray array];

            ABMutableMultiValueRef numberRefs = ABRecordCopyValue(ref, kABPersonPhoneProperty);
            for (int j = 0; j < ABMultiValueGetCount(numberRefs); j++) {
                CFStringRef lbl = ABMultiValueCopyLabelAtIndex(numberRefs, j);

                NSString *label = [labelMapping valueForKey:(__bridge NSString *)lbl];
                if (label == nil)
                    label = [NSString stringWithString:(__bridge NSString *)lbl];
                CFRelease(lbl);

                CFStringRef no = ABMultiValueCopyValueAtIndex(numberRefs, j);
                NSString *number = [NSString stringWithString:(__bridge NSString *)no];
                CFRelease(no);

                [numbers addObject:[MCTContactField fieldWithLabel:label andValue:number]];
            }
            CFRelease(numberRefs);
            if ([numbers count]) {
                NSSortDescriptor *labelSort = [[NSSortDescriptor alloc] initWithKey:@"label"
                                                                           ascending:YES
                                                                            selector:@selector(localizedCaseInsensitiveCompare:)];
                [numbers sortUsingDescriptors:[NSArray arrayWithObject:labelSort]];

                MCTContactEntry *contact = [[MCTContactEntry alloc] init];
                contact.numbers = numbers;
                contact.name = displayName;
                [self.contactEntries addObject:contact];
            }
        }
        CFRelease(allPeople);
        CFRelease(myAddressBook);
    }

    NSSortDescriptor *contactSort = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                    ascending:YES
                                                                  selector:@selector(localizedCaseInsensitiveCompare:)];
    [self.contactEntries sortUsingDescriptors:[NSArray arrayWithObject:contactSort]];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    T_UI();
    return [self.contactEntries count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    MCTContactEntry *entry = [self.contactEntries objectAtIndex:section];
    return [entry.numbers count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    T_UI();
    MCTContactEntry *entry = [self.contactEntries objectAtIndex:section];
    return entry.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTContactEntry *entry = [self.contactEntries objectAtIndex:indexPath.section];
    MCTContactField *phone = [entry.numbers objectAtIndex:indexPath.row];

    static NSString *ident = @"ident";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ident];
    cell.textLabel.text = phone.label;
    cell.detailTextLabel.text = phone.value;
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTContactEntry *entry = [self.contactEntries objectAtIndex:indexPath.section];
    MCTContactField *phone = [entry.numbers objectAtIndex:indexPath.row];

    self.actionTextField.text = phone.value;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end