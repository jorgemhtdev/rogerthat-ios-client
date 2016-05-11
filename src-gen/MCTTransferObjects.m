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

#import "MCTTransferObjects.h"

@implementation MCTTransferObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"Transfer object of type [%@]:\n%@", [self class], [[(id)self dictRepresentation] description]];
}

- (id)errorDuringInitBecauseOfFieldWithName:(NSString *)fieldName
{
    ERROR(@"Cannot init %@. Bad field with name %@", [self class], fieldName);
    return nil;
}

@end



///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory

@synthesize items = items_;
@synthesize idX = idX_;
@synthesize name = name_;

- (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *)init
{
    if (self = [super init]) {
        self.items = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"items"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"items"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"items"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *tmp_obj = [MCT_com_mobicage_models_properties_forms_AdvancedOrderItem transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"items"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.items = tmp_obj_array_0;
        }

        self.idX = [dict stringForKey:@"id"];
        if (self.idX == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"id"];
        if (self.idX == MCTNull)
            self.idX = nil;

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        return self;
    }
}

+ (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *)transferObject
{
    return [[MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory alloc] init];
}

+ (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.items == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory.items");
    } else if ([self.items isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.items count]];
        for (MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *obj in self.items)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"items"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory.items");
    }

    [dict setString:self.idX forKey:@"id"];

    [dict setString:self.name forKey:@"name"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_models_properties_forms_AdvancedOrderItem

@synthesize descriptionX = descriptionX_;
@synthesize has_price = has_price_;
@synthesize idX = idX_;
@synthesize image_url = image_url_;
@synthesize name = name_;
@synthesize step = step_;
@synthesize step_unit = step_unit_;
@synthesize step_unit_conversion = step_unit_conversion_;
@synthesize unit = unit_;
@synthesize unit_price = unit_price_;
@synthesize value = value_;

- (MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.descriptionX = [dict stringForKey:@"description" withDefaultValue:nil];
        if (self.descriptionX == MCTNull)
            self.descriptionX = nil;

        self.has_price = [dict boolForKey:@"has_price" withDefaultValue:YES];

        self.idX = [dict stringForKey:@"id"];
        if (self.idX == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"id"];
        if (self.idX == MCTNull)
            self.idX = nil;

        self.image_url = [dict stringForKey:@"image_url"];
        if (self.image_url == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"image_url"];
        if (self.image_url == MCTNull)
            self.image_url = nil;

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        if (![dict containsLongObjectForKey:@"step"])
            return [self errorDuringInitBecauseOfFieldWithName:@"step"];
        self.step = [dict longForKey:@"step"];

        self.step_unit = [dict stringForKey:@"step_unit" withDefaultValue:nil];
        if (self.step_unit == MCTNull)
            self.step_unit = nil;

        self.step_unit_conversion = [dict longForKey:@"step_unit_conversion" withDefaultValue:0];

        self.unit = [dict stringForKey:@"unit"];
        if (self.unit == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"unit"];
        if (self.unit == MCTNull)
            self.unit = nil;

        if (![dict containsLongObjectForKey:@"unit_price"])
            return [self errorDuringInitBecauseOfFieldWithName:@"unit_price"];
        self.unit_price = [dict longForKey:@"unit_price"];

        if (![dict containsLongObjectForKey:@"value"])
            return [self errorDuringInitBecauseOfFieldWithName:@"value"];
        self.value = [dict longForKey:@"value"];

        return self;
    }
}

+ (MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *)transferObject
{
    return [[MCT_com_mobicage_models_properties_forms_AdvancedOrderItem alloc] init];
}

+ (MCT_com_mobicage_models_properties_forms_AdvancedOrderItem *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_models_properties_forms_AdvancedOrderItem alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.descriptionX forKey:@"description"];

    [dict setBool:self.has_price forKey:@"has_price"];

    [dict setString:self.idX forKey:@"id"];

    [dict setString:self.image_url forKey:@"image_url"];

    [dict setString:self.name forKey:@"name"];

    [dict setLong:self.step forKey:@"step"];

    [dict setString:self.step_unit forKey:@"step_unit"];

    [dict setLong:self.step_unit_conversion forKey:@"step_unit_conversion"];

    [dict setString:self.unit forKey:@"unit"];

    [dict setLong:self.unit_price forKey:@"unit_price"];

    [dict setLong:self.value forKey:@"value"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_models_properties_forms_FormResult

@synthesize result = result_;
@synthesize type = type_;

- (MCT_com_mobicage_models_properties_forms_FormResult *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_models_properties_forms_FormResult *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_models_properties_forms_WidgetResult *tmp_to_0 = [MCT_com_mobicage_models_properties_forms_WidgetResult transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_models_properties_forms_WidgetResult *)tmp_to_0;
        }

        self.type = [dict stringForKey:@"type"];
        if (self.type == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        if (self.type == MCTNull)
            self.type = nil;

        return self;
    }
}

+ (MCT_com_mobicage_models_properties_forms_FormResult *)transferObject
{
    return [[MCT_com_mobicage_models_properties_forms_FormResult alloc] init];
}

+ (MCT_com_mobicage_models_properties_forms_FormResult *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_models_properties_forms_FormResult alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setString:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_models_properties_forms_MyDigiPassAddress

@synthesize address_1 = address_1_;
@synthesize address_2 = address_2_;
@synthesize city = city_;
@synthesize country = country_;
@synthesize state = state_;
@synthesize zip = zip_;

- (MCT_com_mobicage_models_properties_forms_MyDigiPassAddress *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_models_properties_forms_MyDigiPassAddress *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.address_1 = [dict stringForKey:@"address_1"];
        if (self.address_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"address_1"];
        if (self.address_1 == MCTNull)
            self.address_1 = nil;

        self.address_2 = [dict stringForKey:@"address_2"];
        if (self.address_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"address_2"];
        if (self.address_2 == MCTNull)
            self.address_2 = nil;

        self.city = [dict stringForKey:@"city"];
        if (self.city == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"city"];
        if (self.city == MCTNull)
            self.city = nil;

        self.country = [dict stringForKey:@"country"];
        if (self.country == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"country"];
        if (self.country == MCTNull)
            self.country = nil;

        self.state = [dict stringForKey:@"state"];
        if (self.state == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"state"];
        if (self.state == MCTNull)
            self.state = nil;

        self.zip = [dict stringForKey:@"zip"];
        if (self.zip == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"zip"];
        if (self.zip == MCTNull)
            self.zip = nil;

        return self;
    }
}

+ (MCT_com_mobicage_models_properties_forms_MyDigiPassAddress *)transferObject
{
    return [[MCT_com_mobicage_models_properties_forms_MyDigiPassAddress alloc] init];
}

+ (MCT_com_mobicage_models_properties_forms_MyDigiPassAddress *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_models_properties_forms_MyDigiPassAddress alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.address_1 forKey:@"address_1"];

    [dict setString:self.address_2 forKey:@"address_2"];

    [dict setString:self.city forKey:@"city"];

    [dict setString:self.country forKey:@"country"];

    [dict setString:self.state forKey:@"state"];

    [dict setString:self.zip forKey:@"zip"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress

@synthesize municipality = municipality_;
@synthesize street_and_number = street_and_number_;
@synthesize zip_code = zip_code_;

- (MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.municipality = [dict stringForKey:@"municipality"];
        if (self.municipality == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"municipality"];
        if (self.municipality == MCTNull)
            self.municipality = nil;

        self.street_and_number = [dict stringForKey:@"street_and_number"];
        if (self.street_and_number == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"street_and_number"];
        if (self.street_and_number == MCTNull)
            self.street_and_number = nil;

        self.zip_code = [dict stringForKey:@"zip_code"];
        if (self.zip_code == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"zip_code"];
        if (self.zip_code == MCTNull)
            self.zip_code = nil;

        return self;
    }
}

+ (MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress *)transferObject
{
    return [[MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress alloc] init];
}

+ (MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.municipality forKey:@"municipality"];

    [dict setString:self.street_and_number forKey:@"street_and_number"];

    [dict setString:self.zip_code forKey:@"zip_code"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile

@synthesize card_number = card_number_;
@synthesize chip_number = chip_number_;
@synthesize created_at = created_at_;
@synthesize date_of_birth = date_of_birth_;
@synthesize first_name = first_name_;
@synthesize first_name_3 = first_name_3_;
@synthesize gender = gender_;
@synthesize issuing_municipality = issuing_municipality_;
@synthesize last_name = last_name_;
@synthesize location_of_birth = location_of_birth_;
@synthesize nationality = nationality_;
@synthesize noble_condition = noble_condition_;
@synthesize validity_begins_at = validity_begins_at_;
@synthesize validity_ends_at = validity_ends_at_;

- (MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.card_number = [dict stringForKey:@"card_number"];
        if (self.card_number == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"card_number"];
        if (self.card_number == MCTNull)
            self.card_number = nil;

        self.chip_number = [dict stringForKey:@"chip_number"];
        if (self.chip_number == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"chip_number"];
        if (self.chip_number == MCTNull)
            self.chip_number = nil;

        self.created_at = [dict stringForKey:@"created_at"];
        if (self.created_at == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"created_at"];
        if (self.created_at == MCTNull)
            self.created_at = nil;

        self.date_of_birth = [dict stringForKey:@"date_of_birth"];
        if (self.date_of_birth == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"date_of_birth"];
        if (self.date_of_birth == MCTNull)
            self.date_of_birth = nil;

        self.first_name = [dict stringForKey:@"first_name"];
        if (self.first_name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"first_name"];
        if (self.first_name == MCTNull)
            self.first_name = nil;

        self.first_name_3 = [dict stringForKey:@"first_name_3"];
        if (self.first_name_3 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"first_name_3"];
        if (self.first_name_3 == MCTNull)
            self.first_name_3 = nil;

        self.gender = [dict stringForKey:@"gender"];
        if (self.gender == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"gender"];
        if (self.gender == MCTNull)
            self.gender = nil;

        self.issuing_municipality = [dict stringForKey:@"issuing_municipality"];
        if (self.issuing_municipality == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"issuing_municipality"];
        if (self.issuing_municipality == MCTNull)
            self.issuing_municipality = nil;

        self.last_name = [dict stringForKey:@"last_name"];
        if (self.last_name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"last_name"];
        if (self.last_name == MCTNull)
            self.last_name = nil;

        self.location_of_birth = [dict stringForKey:@"location_of_birth"];
        if (self.location_of_birth == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"location_of_birth"];
        if (self.location_of_birth == MCTNull)
            self.location_of_birth = nil;

        self.nationality = [dict stringForKey:@"nationality"];
        if (self.nationality == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"nationality"];
        if (self.nationality == MCTNull)
            self.nationality = nil;

        self.noble_condition = [dict stringForKey:@"noble_condition"];
        if (self.noble_condition == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"noble_condition"];
        if (self.noble_condition == MCTNull)
            self.noble_condition = nil;

        self.validity_begins_at = [dict stringForKey:@"validity_begins_at"];
        if (self.validity_begins_at == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"validity_begins_at"];
        if (self.validity_begins_at == MCTNull)
            self.validity_begins_at = nil;

        self.validity_ends_at = [dict stringForKey:@"validity_ends_at"];
        if (self.validity_ends_at == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"validity_ends_at"];
        if (self.validity_ends_at == MCTNull)
            self.validity_ends_at = nil;

        return self;
    }
}

+ (MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile *)transferObject
{
    return [[MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile alloc] init];
}

+ (MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.card_number forKey:@"card_number"];

    [dict setString:self.chip_number forKey:@"chip_number"];

    [dict setString:self.created_at forKey:@"created_at"];

    [dict setString:self.date_of_birth forKey:@"date_of_birth"];

    [dict setString:self.first_name forKey:@"first_name"];

    [dict setString:self.first_name_3 forKey:@"first_name_3"];

    [dict setString:self.gender forKey:@"gender"];

    [dict setString:self.issuing_municipality forKey:@"issuing_municipality"];

    [dict setString:self.last_name forKey:@"last_name"];

    [dict setString:self.location_of_birth forKey:@"location_of_birth"];

    [dict setString:self.nationality forKey:@"nationality"];

    [dict setString:self.noble_condition forKey:@"noble_condition"];

    [dict setString:self.validity_begins_at forKey:@"validity_begins_at"];

    [dict setString:self.validity_ends_at forKey:@"validity_ends_at"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_models_properties_forms_MyDigiPassProfile

@synthesize born_on = born_on_;
@synthesize first_name = first_name_;
@synthesize last_name = last_name_;
@synthesize preferred_locale = preferred_locale_;
@synthesize updated_at = updated_at_;
@synthesize uuid = uuid_;

- (MCT_com_mobicage_models_properties_forms_MyDigiPassProfile *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_models_properties_forms_MyDigiPassProfile *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.born_on = [dict stringForKey:@"born_on"];
        if (self.born_on == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"born_on"];
        if (self.born_on == MCTNull)
            self.born_on = nil;

        self.first_name = [dict stringForKey:@"first_name"];
        if (self.first_name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"first_name"];
        if (self.first_name == MCTNull)
            self.first_name = nil;

        self.last_name = [dict stringForKey:@"last_name"];
        if (self.last_name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"last_name"];
        if (self.last_name == MCTNull)
            self.last_name = nil;

        self.preferred_locale = [dict stringForKey:@"preferred_locale"];
        if (self.preferred_locale == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"preferred_locale"];
        if (self.preferred_locale == MCTNull)
            self.preferred_locale = nil;

        self.updated_at = [dict stringForKey:@"updated_at"];
        if (self.updated_at == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"updated_at"];
        if (self.updated_at == MCTNull)
            self.updated_at = nil;

        self.uuid = [dict stringForKey:@"uuid"];
        if (self.uuid == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"uuid"];
        if (self.uuid == MCTNull)
            self.uuid = nil;

        return self;
    }
}

+ (MCT_com_mobicage_models_properties_forms_MyDigiPassProfile *)transferObject
{
    return [[MCT_com_mobicage_models_properties_forms_MyDigiPassProfile alloc] init];
}

+ (MCT_com_mobicage_models_properties_forms_MyDigiPassProfile *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_models_properties_forms_MyDigiPassProfile alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.born_on forKey:@"born_on"];

    [dict setString:self.first_name forKey:@"first_name"];

    [dict setString:self.last_name forKey:@"last_name"];

    [dict setString:self.preferred_locale forKey:@"preferred_locale"];

    [dict setString:self.updated_at forKey:@"updated_at"];

    [dict setString:self.uuid forKey:@"uuid"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_models_properties_forms_WidgetResult


- (MCT_com_mobicage_models_properties_forms_WidgetResult *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_models_properties_forms_WidgetResult *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_models_properties_forms_WidgetResult *)transferObject
{
    return [[MCT_com_mobicage_models_properties_forms_WidgetResult alloc] init];
}

+ (MCT_com_mobicage_models_properties_forms_WidgetResult *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_models_properties_forms_WidgetResult alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_activity_CallRecordTO

@synthesize geoPoint = geoPoint_;
@synthesize rawLocation = rawLocation_;
@synthesize countrycode = countrycode_;
@synthesize duration = duration_;
@synthesize idX = idX_;
@synthesize phoneNumber = phoneNumber_;
@synthesize starttime = starttime_;
@synthesize type = type_;

- (MCT_com_mobicage_to_activity_CallRecordTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_activity_CallRecordTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"geoPoint"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"geoPoint"];
        if (tmp_dict_0 == MCTNull)
            self.geoPoint = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_activity_GeoPointTO *tmp_to_0 = [MCT_com_mobicage_to_activity_GeoPointTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"geoPoint"];
            self.geoPoint = (MCT_com_mobicage_to_activity_GeoPointTO *)tmp_to_0;
        }

        NSDictionary *tmp_dict_1 = [dict dictForKey:@"rawLocation"];
        if (tmp_dict_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"rawLocation"];
        if (tmp_dict_1 == MCTNull)
            self.rawLocation = nil;
        else if (tmp_dict_1 != nil) {
            MCT_com_mobicage_to_activity_RawLocationInfoTO *tmp_to_1 = [MCT_com_mobicage_to_activity_RawLocationInfoTO transferObjectWithDict:tmp_dict_1];
            if (tmp_to_1 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"rawLocation"];
            self.rawLocation = (MCT_com_mobicage_to_activity_RawLocationInfoTO *)tmp_to_1;
        }

        self.countrycode = [dict stringForKey:@"countrycode"];
        if (self.countrycode == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"countrycode"];
        if (self.countrycode == MCTNull)
            self.countrycode = nil;

        if (![dict containsLongObjectForKey:@"duration"])
            return [self errorDuringInitBecauseOfFieldWithName:@"duration"];
        self.duration = [dict longForKey:@"duration"];

        if (![dict containsLongObjectForKey:@"id"])
            return [self errorDuringInitBecauseOfFieldWithName:@"id"];
        self.idX = [dict longForKey:@"id"];

        self.phoneNumber = [dict stringForKey:@"phoneNumber"];
        if (self.phoneNumber == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"phoneNumber"];
        if (self.phoneNumber == MCTNull)
            self.phoneNumber = nil;

        if (![dict containsLongObjectForKey:@"starttime"])
            return [self errorDuringInitBecauseOfFieldWithName:@"starttime"];
        self.starttime = [dict longForKey:@"starttime"];

        if (![dict containsLongObjectForKey:@"type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        self.type = [dict longForKey:@"type"];

        return self;
    }
}

+ (MCT_com_mobicage_to_activity_CallRecordTO *)transferObject
{
    return [[MCT_com_mobicage_to_activity_CallRecordTO alloc] init];
}

+ (MCT_com_mobicage_to_activity_CallRecordTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_activity_CallRecordTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.geoPoint dictRepresentation] forKey:@"geoPoint"];

    [dict setDict:[self.rawLocation dictRepresentation] forKey:@"rawLocation"];

    [dict setString:self.countrycode forKey:@"countrycode"];

    [dict setLong:self.duration forKey:@"duration"];

    [dict setLong:self.idX forKey:@"id"];

    [dict setString:self.phoneNumber forKey:@"phoneNumber"];

    [dict setLong:self.starttime forKey:@"starttime"];

    [dict setLong:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_activity_CellTowerTO

@synthesize cid = cid_;
@synthesize strength = strength_;

- (MCT_com_mobicage_to_activity_CellTowerTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_activity_CellTowerTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"cid"])
            return [self errorDuringInitBecauseOfFieldWithName:@"cid"];
        self.cid = [dict longForKey:@"cid"];

        if (![dict containsLongObjectForKey:@"strength"])
            return [self errorDuringInitBecauseOfFieldWithName:@"strength"];
        self.strength = [dict longForKey:@"strength"];

        return self;
    }
}

+ (MCT_com_mobicage_to_activity_CellTowerTO *)transferObject
{
    return [[MCT_com_mobicage_to_activity_CellTowerTO alloc] init];
}

+ (MCT_com_mobicage_to_activity_CellTowerTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_activity_CellTowerTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.cid forKey:@"cid"];

    [dict setLong:self.strength forKey:@"strength"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_activity_GeoPointTO

@synthesize accuracy = accuracy_;
@synthesize latitude = latitude_;
@synthesize longitude = longitude_;

- (MCT_com_mobicage_to_activity_GeoPointTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_activity_GeoPointTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"accuracy"])
            return [self errorDuringInitBecauseOfFieldWithName:@"accuracy"];
        self.accuracy = [dict longForKey:@"accuracy"];

        if (![dict containsLongObjectForKey:@"latitude"])
            return [self errorDuringInitBecauseOfFieldWithName:@"latitude"];
        self.latitude = [dict longForKey:@"latitude"];

        if (![dict containsLongObjectForKey:@"longitude"])
            return [self errorDuringInitBecauseOfFieldWithName:@"longitude"];
        self.longitude = [dict longForKey:@"longitude"];

        return self;
    }
}

+ (MCT_com_mobicage_to_activity_GeoPointTO *)transferObject
{
    return [[MCT_com_mobicage_to_activity_GeoPointTO alloc] init];
}

+ (MCT_com_mobicage_to_activity_GeoPointTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_activity_GeoPointTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.accuracy forKey:@"accuracy"];

    [dict setLong:self.latitude forKey:@"latitude"];

    [dict setLong:self.longitude forKey:@"longitude"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_activity_GeoPointWithTimestampTO

@synthesize accuracy = accuracy_;
@synthesize latitude = latitude_;
@synthesize longitude = longitude_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"accuracy"])
            return [self errorDuringInitBecauseOfFieldWithName:@"accuracy"];
        self.accuracy = [dict longForKey:@"accuracy"];

        if (![dict containsLongObjectForKey:@"latitude"])
            return [self errorDuringInitBecauseOfFieldWithName:@"latitude"];
        self.latitude = [dict longForKey:@"latitude"];

        if (![dict containsLongObjectForKey:@"longitude"])
            return [self errorDuringInitBecauseOfFieldWithName:@"longitude"];
        self.longitude = [dict longForKey:@"longitude"];

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *)transferObject
{
    return [[MCT_com_mobicage_to_activity_GeoPointWithTimestampTO alloc] init];
}

+ (MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_activity_GeoPointWithTimestampTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.accuracy forKey:@"accuracy"];

    [dict setLong:self.latitude forKey:@"latitude"];

    [dict setLong:self.longitude forKey:@"longitude"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_activity_LocationRecordTO

@synthesize geoPoint = geoPoint_;
@synthesize rawLocation = rawLocation_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_activity_LocationRecordTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_activity_LocationRecordTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"geoPoint"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"geoPoint"];
        if (tmp_dict_0 == MCTNull)
            self.geoPoint = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_activity_GeoPointTO *tmp_to_0 = [MCT_com_mobicage_to_activity_GeoPointTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"geoPoint"];
            self.geoPoint = (MCT_com_mobicage_to_activity_GeoPointTO *)tmp_to_0;
        }

        NSDictionary *tmp_dict_1 = [dict dictForKey:@"rawLocation"];
        if (tmp_dict_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"rawLocation"];
        if (tmp_dict_1 == MCTNull)
            self.rawLocation = nil;
        else if (tmp_dict_1 != nil) {
            MCT_com_mobicage_to_activity_RawLocationInfoTO *tmp_to_1 = [MCT_com_mobicage_to_activity_RawLocationInfoTO transferObjectWithDict:tmp_dict_1];
            if (tmp_to_1 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"rawLocation"];
            self.rawLocation = (MCT_com_mobicage_to_activity_RawLocationInfoTO *)tmp_to_1;
        }

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_activity_LocationRecordTO *)transferObject
{
    return [[MCT_com_mobicage_to_activity_LocationRecordTO alloc] init];
}

+ (MCT_com_mobicage_to_activity_LocationRecordTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_activity_LocationRecordTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.geoPoint dictRepresentation] forKey:@"geoPoint"];

    [dict setDict:[self.rawLocation dictRepresentation] forKey:@"rawLocation"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_activity_LogCallRequestTO

@synthesize record = record_;

- (MCT_com_mobicage_to_activity_LogCallRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_activity_LogCallRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"record"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"record"];
        if (tmp_dict_0 == MCTNull)
            self.record = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_activity_CallRecordTO *tmp_to_0 = [MCT_com_mobicage_to_activity_CallRecordTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"record"];
            self.record = (MCT_com_mobicage_to_activity_CallRecordTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_activity_LogCallRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_activity_LogCallRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_activity_LogCallRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_activity_LogCallRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.record dictRepresentation] forKey:@"record"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_activity_LogCallResponseTO

@synthesize recordId = recordId_;

- (MCT_com_mobicage_to_activity_LogCallResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_activity_LogCallResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"recordId"])
            return [self errorDuringInitBecauseOfFieldWithName:@"recordId"];
        self.recordId = [dict longForKey:@"recordId"];

        return self;
    }
}

+ (MCT_com_mobicage_to_activity_LogCallResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_activity_LogCallResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_activity_LogCallResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_activity_LogCallResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.recordId forKey:@"recordId"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_activity_LogLocationRecipientTO

@synthesize friend = friend_;
@synthesize target = target_;

- (MCT_com_mobicage_to_activity_LogLocationRecipientTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_activity_LogLocationRecipientTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.friend = [dict stringForKey:@"friend"];
        if (self.friend == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friend"];
        if (self.friend == MCTNull)
            self.friend = nil;

        if (![dict containsLongObjectForKey:@"target"])
            return [self errorDuringInitBecauseOfFieldWithName:@"target"];
        self.target = [dict longForKey:@"target"];

        return self;
    }
}

+ (MCT_com_mobicage_to_activity_LogLocationRecipientTO *)transferObject
{
    return [[MCT_com_mobicage_to_activity_LogLocationRecipientTO alloc] init];
}

+ (MCT_com_mobicage_to_activity_LogLocationRecipientTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_activity_LogLocationRecipientTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.friend forKey:@"friend"];

    [dict setLong:self.target forKey:@"target"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_activity_LogLocationsRequestTO

@synthesize recipients = recipients_;
@synthesize records = records_;

- (MCT_com_mobicage_to_activity_LogLocationsRequestTO *)init
{
    if (self = [super init]) {
        self.recipients = [NSMutableArray array];
        self.records = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_activity_LogLocationsRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"recipients"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"recipients"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"recipients"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_activity_LogLocationRecipientTO *tmp_obj = [MCT_com_mobicage_to_activity_LogLocationRecipientTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"recipients"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.recipients = tmp_obj_array_0;
        }

        NSArray *tmp_dict_array_1 = [dict arrayForKey:@"records"];
        if (tmp_dict_array_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"records"];
        if (tmp_dict_array_1 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"records"];
        else {
            NSMutableArray *tmp_obj_array_1 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_1 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_1) {
                MCT_com_mobicage_to_activity_LocationRecordTO *tmp_obj = [MCT_com_mobicage_to_activity_LocationRecordTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"records"];
                [tmp_obj_array_1 addObject:tmp_obj];
            }
            self.records = tmp_obj_array_1;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_activity_LogLocationsRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_activity_LogLocationsRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_activity_LogLocationsRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_activity_LogLocationsRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.recipients == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_activity_LogLocationsRequestTO.recipients");
    } else if ([self.recipients isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.recipients count]];
        for (MCT_com_mobicage_to_activity_LogLocationRecipientTO *obj in self.recipients)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"recipients"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_activity_LogLocationsRequestTO.recipients");
    }

    if (self.records == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_activity_LogLocationsRequestTO.records");
    } else if ([self.records isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.records count]];
        for (MCT_com_mobicage_to_activity_LocationRecordTO *obj in self.records)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"records"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_activity_LogLocationsRequestTO.records");
    }

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_activity_LogLocationsResponseTO


- (MCT_com_mobicage_to_activity_LogLocationsResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_activity_LogLocationsResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_activity_LogLocationsResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_activity_LogLocationsResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_activity_LogLocationsResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_activity_LogLocationsResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_activity_RawLocationInfoTO

@synthesize towers = towers_;
@synthesize cid = cid_;
@synthesize lac = lac_;
@synthesize mobileDataType = mobileDataType_;
@synthesize net = net_;
@synthesize signalStrength = signalStrength_;

- (MCT_com_mobicage_to_activity_RawLocationInfoTO *)init
{
    if (self = [super init]) {
        self.towers = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_activity_RawLocationInfoTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"towers"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"towers"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"towers"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_activity_CellTowerTO *tmp_obj = [MCT_com_mobicage_to_activity_CellTowerTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"towers"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.towers = tmp_obj_array_0;
        }

        if (![dict containsLongObjectForKey:@"cid"])
            return [self errorDuringInitBecauseOfFieldWithName:@"cid"];
        self.cid = [dict longForKey:@"cid"];

        if (![dict containsLongObjectForKey:@"lac"])
            return [self errorDuringInitBecauseOfFieldWithName:@"lac"];
        self.lac = [dict longForKey:@"lac"];

        if (![dict containsLongObjectForKey:@"mobileDataType"])
            return [self errorDuringInitBecauseOfFieldWithName:@"mobileDataType"];
        self.mobileDataType = [dict longForKey:@"mobileDataType"];

        if (![dict containsLongObjectForKey:@"net"])
            return [self errorDuringInitBecauseOfFieldWithName:@"net"];
        self.net = [dict longForKey:@"net"];

        if (![dict containsLongObjectForKey:@"signalStrength"])
            return [self errorDuringInitBecauseOfFieldWithName:@"signalStrength"];
        self.signalStrength = [dict longForKey:@"signalStrength"];

        return self;
    }
}

+ (MCT_com_mobicage_to_activity_RawLocationInfoTO *)transferObject
{
    return [[MCT_com_mobicage_to_activity_RawLocationInfoTO alloc] init];
}

+ (MCT_com_mobicage_to_activity_RawLocationInfoTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_activity_RawLocationInfoTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.towers == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_activity_RawLocationInfoTO.towers");
    } else if ([self.towers isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.towers count]];
        for (MCT_com_mobicage_to_activity_CellTowerTO *obj in self.towers)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"towers"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_activity_RawLocationInfoTO.towers");
    }

    [dict setLong:self.cid forKey:@"cid"];

    [dict setLong:self.lac forKey:@"lac"];

    [dict setLong:self.mobileDataType forKey:@"mobileDataType"];

    [dict setLong:self.net forKey:@"net"];

    [dict setLong:self.signalStrength forKey:@"signalStrength"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_beacon_BeaconRegionTO

@synthesize has_major = has_major_;
@synthesize has_minor = has_minor_;
@synthesize major = major_;
@synthesize minor = minor_;
@synthesize uuid = uuid_;

- (MCT_com_mobicage_to_beacon_BeaconRegionTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_beacon_BeaconRegionTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsBoolObjectForKey:@"has_major"])
            return [self errorDuringInitBecauseOfFieldWithName:@"has_major"];
        self.has_major = [dict boolForKey:@"has_major"];

        if (![dict containsBoolObjectForKey:@"has_minor"])
            return [self errorDuringInitBecauseOfFieldWithName:@"has_minor"];
        self.has_minor = [dict boolForKey:@"has_minor"];

        if (![dict containsLongObjectForKey:@"major"])
            return [self errorDuringInitBecauseOfFieldWithName:@"major"];
        self.major = [dict longForKey:@"major"];

        if (![dict containsLongObjectForKey:@"minor"])
            return [self errorDuringInitBecauseOfFieldWithName:@"minor"];
        self.minor = [dict longForKey:@"minor"];

        self.uuid = [dict stringForKey:@"uuid"];
        if (self.uuid == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"uuid"];
        if (self.uuid == MCTNull)
            self.uuid = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_beacon_BeaconRegionTO *)transferObject
{
    return [[MCT_com_mobicage_to_beacon_BeaconRegionTO alloc] init];
}

+ (MCT_com_mobicage_to_beacon_BeaconRegionTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_beacon_BeaconRegionTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setBool:self.has_major forKey:@"has_major"];

    [dict setBool:self.has_minor forKey:@"has_minor"];

    [dict setLong:self.major forKey:@"major"];

    [dict setLong:self.minor forKey:@"minor"];

    [dict setString:self.uuid forKey:@"uuid"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_beacon_GetBeaconRegionsRequestTO


- (MCT_com_mobicage_to_beacon_GetBeaconRegionsRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_beacon_GetBeaconRegionsRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_beacon_GetBeaconRegionsRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_beacon_GetBeaconRegionsRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_beacon_GetBeaconRegionsRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_beacon_GetBeaconRegionsRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO

@synthesize regions = regions_;

- (MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO *)init
{
    if (self = [super init]) {
        self.regions = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"regions"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"regions"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"regions"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_beacon_BeaconRegionTO *tmp_obj = [MCT_com_mobicage_to_beacon_BeaconRegionTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"regions"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.regions = tmp_obj_array_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.regions == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO.regions");
    } else if ([self.regions isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.regions count]];
        for (MCT_com_mobicage_to_beacon_BeaconRegionTO *obj in self.regions)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"regions"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_beacon_GetBeaconRegionsResponseTO.regions");
    }

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_beacon_UpdateBeaconRegionsRequestTO


- (MCT_com_mobicage_to_beacon_UpdateBeaconRegionsRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_beacon_UpdateBeaconRegionsRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_beacon_UpdateBeaconRegionsRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_beacon_UpdateBeaconRegionsRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_beacon_UpdateBeaconRegionsRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_beacon_UpdateBeaconRegionsRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_beacon_UpdateBeaconRegionsResponseTO


- (MCT_com_mobicage_to_beacon_UpdateBeaconRegionsResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_beacon_UpdateBeaconRegionsResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_beacon_UpdateBeaconRegionsResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_beacon_UpdateBeaconRegionsResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_beacon_UpdateBeaconRegionsResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_beacon_UpdateBeaconRegionsResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretRequestTO

@synthesize invitor_code = invitor_code_;
@synthesize secret = secret_;

- (MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.invitor_code = [dict stringForKey:@"invitor_code"];
        if (self.invitor_code == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"invitor_code"];
        if (self.invitor_code == MCTNull)
            self.invitor_code = nil;

        self.secret = [dict stringForKey:@"secret"];
        if (self.secret == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"secret"];
        if (self.secret == MCTNull)
            self.secret = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.invitor_code forKey:@"invitor_code"];

    [dict setString:self.secret forKey:@"secret"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretResponseTO


- (MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_AckInvitationByInvitationSecretResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_BecameFriendsRequestTO

@synthesize friend = friend_;
@synthesize user = user_;

- (MCT_com_mobicage_to_friends_BecameFriendsRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_BecameFriendsRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"friend"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friend"];
        if (tmp_dict_0 == MCTNull)
            self.friend = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_friends_FriendRelationTO *tmp_to_0 = [MCT_com_mobicage_to_friends_FriendRelationTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"friend"];
            self.friend = (MCT_com_mobicage_to_friends_FriendRelationTO *)tmp_to_0;
        }

        self.user = [dict stringForKey:@"user"];
        if (self.user == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"user"];
        if (self.user == MCTNull)
            self.user = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_BecameFriendsRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_BecameFriendsRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_BecameFriendsRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_BecameFriendsRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.friend dictRepresentation] forKey:@"friend"];

    [dict setString:self.user forKey:@"user"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_BecameFriendsResponseTO


- (MCT_com_mobicage_to_friends_BecameFriendsResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_BecameFriendsResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_friends_BecameFriendsResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_BecameFriendsResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_BecameFriendsResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_BecameFriendsResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_BreakFriendshipRequestTO

@synthesize friend = friend_;

- (MCT_com_mobicage_to_friends_BreakFriendshipRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_BreakFriendshipRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.friend = [dict stringForKey:@"friend"];
        if (self.friend == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friend"];
        if (self.friend == MCTNull)
            self.friend = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_BreakFriendshipRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_BreakFriendshipRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_BreakFriendshipRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_BreakFriendshipRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.friend forKey:@"friend"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_BreakFriendshipResponseTO


- (MCT_com_mobicage_to_friends_BreakFriendshipResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_BreakFriendshipResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_friends_BreakFriendshipResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_BreakFriendshipResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_BreakFriendshipResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_BreakFriendshipResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_DeleteGroupRequestTO

@synthesize guid = guid_;

- (MCT_com_mobicage_to_friends_DeleteGroupRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_DeleteGroupRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.guid = [dict stringForKey:@"guid"];
        if (self.guid == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"guid"];
        if (self.guid == MCTNull)
            self.guid = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_DeleteGroupRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_DeleteGroupRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_DeleteGroupRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_DeleteGroupRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.guid forKey:@"guid"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_DeleteGroupResponseTO


- (MCT_com_mobicage_to_friends_DeleteGroupResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_DeleteGroupResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_friends_DeleteGroupResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_DeleteGroupResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_DeleteGroupResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_DeleteGroupResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_ErrorTO

@synthesize action = action_;
@synthesize caption = caption_;
@synthesize message = message_;
@synthesize title = title_;

- (MCT_com_mobicage_to_friends_ErrorTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_ErrorTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.action = [dict stringForKey:@"action" withDefaultValue:nil];
        if (self.action == MCTNull)
            self.action = nil;

        self.caption = [dict stringForKey:@"caption" withDefaultValue:nil];
        if (self.caption == MCTNull)
            self.caption = nil;

        self.message = [dict stringForKey:@"message" withDefaultValue:nil];
        if (self.message == MCTNull)
            self.message = nil;

        self.title = [dict stringForKey:@"title" withDefaultValue:nil];
        if (self.title == MCTNull)
            self.title = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_ErrorTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_ErrorTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_ErrorTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_ErrorTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.action forKey:@"action"];

    [dict setString:self.caption forKey:@"caption"];

    [dict setString:self.message forKey:@"message"];

    [dict setString:self.title forKey:@"title"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO

@synthesize fbId = fbId_;
@synthesize fbName = fbName_;
@synthesize fbPicture = fbPicture_;
@synthesize rtId = rtId_;

- (MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.fbId = [dict stringForKey:@"fbId"];
        if (self.fbId == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"fbId"];
        if (self.fbId == MCTNull)
            self.fbId = nil;

        self.fbName = [dict stringForKey:@"fbName"];
        if (self.fbName == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"fbName"];
        if (self.fbName == MCTNull)
            self.fbName = nil;

        self.fbPicture = [dict stringForKey:@"fbPicture"];
        if (self.fbPicture == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"fbPicture"];
        if (self.fbPicture == MCTNull)
            self.fbPicture = nil;

        self.rtId = [dict stringForKey:@"rtId"];
        if (self.rtId == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"rtId"];
        if (self.rtId == MCTNull)
            self.rtId = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.fbId forKey:@"fbId"];

    [dict setString:self.fbName forKey:@"fbName"];

    [dict setString:self.fbPicture forKey:@"fbPicture"];

    [dict setString:self.rtId forKey:@"rtId"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_FindFriendItemTO

@synthesize avatar_url = avatar_url_;
@synthesize email = email_;
@synthesize name = name_;

- (MCT_com_mobicage_to_friends_FindFriendItemTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_FindFriendItemTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.avatar_url = [dict stringForKey:@"avatar_url"];
        if (self.avatar_url == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar_url"];
        if (self.avatar_url == MCTNull)
            self.avatar_url = nil;

        self.email = [dict stringForKey:@"email"];
        if (self.email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"email"];
        if (self.email == MCTNull)
            self.email = nil;

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_FindFriendItemTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_FindFriendItemTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_FindFriendItemTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_FindFriendItemTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.avatar_url forKey:@"avatar_url"];

    [dict setString:self.email forKey:@"email"];

    [dict setString:self.name forKey:@"name"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_FindFriendRequestTO

@synthesize avatar_size = avatar_size_;
@synthesize cursor = cursor_;
@synthesize search_string = search_string_;

- (MCT_com_mobicage_to_friends_FindFriendRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_FindFriendRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.avatar_size = [dict longForKey:@"avatar_size" withDefaultValue:50];

        self.cursor = [dict stringForKey:@"cursor" withDefaultValue:nil];
        if (self.cursor == MCTNull)
            self.cursor = nil;

        self.search_string = [dict stringForKey:@"search_string"];
        if (self.search_string == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"search_string"];
        if (self.search_string == MCTNull)
            self.search_string = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_FindFriendRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_FindFriendRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_FindFriendRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_FindFriendRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.avatar_size forKey:@"avatar_size"];

    [dict setString:self.cursor forKey:@"cursor"];

    [dict setString:self.search_string forKey:@"search_string"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_FindFriendResponseTO

@synthesize items = items_;
@synthesize cursor = cursor_;
@synthesize error_string = error_string_;

- (MCT_com_mobicage_to_friends_FindFriendResponseTO *)init
{
    if (self = [super init]) {
        self.items = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_friends_FindFriendResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"items"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"items"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"items"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_friends_FindFriendItemTO *tmp_obj = [MCT_com_mobicage_to_friends_FindFriendItemTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"items"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.items = tmp_obj_array_0;
        }

        self.cursor = [dict stringForKey:@"cursor" withDefaultValue:nil];
        if (self.cursor == MCTNull)
            self.cursor = nil;

        self.error_string = [dict stringForKey:@"error_string"];
        if (self.error_string == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"error_string"];
        if (self.error_string == MCTNull)
            self.error_string = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_FindFriendResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_FindFriendResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_FindFriendResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_FindFriendResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.items == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_friends_FindFriendResponseTO.items");
    } else if ([self.items isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.items count]];
        for (MCT_com_mobicage_to_friends_FindFriendItemTO *obj in self.items)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"items"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_friends_FindFriendResponseTO.items");
    }

    [dict setString:self.cursor forKey:@"cursor"];

    [dict setString:self.error_string forKey:@"error_string"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailRequestTO

@synthesize email_addresses = email_addresses_;

- (MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailRequestTO *)init
{
    if (self = [super init]) {
        self.email_addresses = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_unicode_array_0 = [dict arrayForKey:@"email_addresses"];
        if (tmp_unicode_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"email_addresses"];
        for (id obj in tmp_unicode_array_0) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"email_addresses"];
        }
        self.email_addresses = tmp_unicode_array_0;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.email_addresses forKey:@"email_addresses"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailResponseTO

@synthesize matched_addresses = matched_addresses_;

- (MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailResponseTO *)init
{
    if (self = [super init]) {
        self.matched_addresses = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_unicode_array_0 = [dict arrayForKey:@"matched_addresses"];
        if (tmp_unicode_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"matched_addresses"];
        for (id obj in tmp_unicode_array_0) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"matched_addresses"];
        }
        self.matched_addresses = tmp_unicode_array_0;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_FindRogerthatUsersViaEmailResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.matched_addresses forKey:@"matched_addresses"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookRequestTO

@synthesize access_token = access_token_;

- (MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.access_token = [dict stringForKey:@"access_token"];
        if (self.access_token == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"access_token"];
        if (self.access_token == MCTNull)
            self.access_token = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.access_token forKey:@"access_token"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO

@synthesize matches = matches_;

- (MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO *)init
{
    if (self = [super init]) {
        self.matches = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"matches"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"matches"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"matches"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO *tmp_obj = [MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"matches"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.matches = tmp_obj_array_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.matches == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO.matches");
    } else if ([self.matches isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.matches count]];
        for (MCT_com_mobicage_to_friends_FacebookRogerthatProfileMatchTO *obj in self.matches)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"matches"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_friends_FindRogerthatUsersViaFacebookResponseTO.matches");
    }

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_FriendCategoryTO

@synthesize avatar = avatar_;
@synthesize guid = guid_;
@synthesize name = name_;

- (MCT_com_mobicage_to_friends_FriendCategoryTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_FriendCategoryTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.avatar = [dict stringForKey:@"avatar"];
        if (self.avatar == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar"];
        if (self.avatar == MCTNull)
            self.avatar = nil;

        self.guid = [dict stringForKey:@"guid"];
        if (self.guid == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"guid"];
        if (self.guid == MCTNull)
            self.guid = nil;

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_FriendCategoryTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_FriendCategoryTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_FriendCategoryTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_FriendCategoryTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.avatar forKey:@"avatar"];

    [dict setString:self.guid forKey:@"guid"];

    [dict setString:self.name forKey:@"name"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_FriendRelationTO

@synthesize avatarId = avatarId_;
@synthesize email = email_;
@synthesize name = name_;
@synthesize type = type_;

- (MCT_com_mobicage_to_friends_FriendRelationTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_FriendRelationTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"avatarId"])
            return [self errorDuringInitBecauseOfFieldWithName:@"avatarId"];
        self.avatarId = [dict longForKey:@"avatarId"];

        self.email = [dict stringForKey:@"email"];
        if (self.email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"email"];
        if (self.email == MCTNull)
            self.email = nil;

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        if (![dict containsLongObjectForKey:@"type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        self.type = [dict longForKey:@"type"];

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_FriendRelationTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_FriendRelationTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_FriendRelationTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_FriendRelationTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.avatarId forKey:@"avatarId"];

    [dict setString:self.email forKey:@"email"];

    [dict setString:self.name forKey:@"name"];

    [dict setLong:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_FriendTO

@synthesize actionMenu = actionMenu_;
@synthesize appData = appData_;
@synthesize avatarHash = avatarHash_;
@synthesize avatarId = avatarId_;
@synthesize broadcastFlowHash = broadcastFlowHash_;
@synthesize callbacks = callbacks_;
@synthesize category_id = category_id_;
@synthesize contentBrandingHash = contentBrandingHash_;
@synthesize descriptionX = descriptionX_;
@synthesize descriptionBranding = descriptionBranding_;
@synthesize email = email_;
@synthesize existence = existence_;
@synthesize flags = flags_;
@synthesize generation = generation_;
@synthesize hasUserData = hasUserData_;
@synthesize name = name_;
@synthesize organizationType = organizationType_;
@synthesize pokeDescription = pokeDescription_;
@synthesize profileData = profileData_;
@synthesize qualifiedIdentifier = qualifiedIdentifier_;
@synthesize shareLocation = shareLocation_;
@synthesize sharesContacts = sharesContacts_;
@synthesize sharesLocation = sharesLocation_;
@synthesize type = type_;
@synthesize userData = userData_;
@synthesize versions = versions_;

- (MCT_com_mobicage_to_friends_FriendTO *)init
{
    if (self = [super init]) {
        self.versions = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_friends_FriendTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"actionMenu"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"actionMenu"];
        if (tmp_dict_0 == MCTNull)
            self.actionMenu = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_friends_ServiceMenuTO *tmp_to_0 = [MCT_com_mobicage_to_friends_ServiceMenuTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"actionMenu"];
            self.actionMenu = (MCT_com_mobicage_to_friends_ServiceMenuTO *)tmp_to_0;
        }

        self.appData = [dict stringForKey:@"appData" withDefaultValue:nil];
        if (self.appData == MCTNull)
            self.appData = nil;

        self.avatarHash = [dict stringForKey:@"avatarHash"];
        if (self.avatarHash == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatarHash"];
        if (self.avatarHash == MCTNull)
            self.avatarHash = nil;

        if (![dict containsLongObjectForKey:@"avatarId"])
            return [self errorDuringInitBecauseOfFieldWithName:@"avatarId"];
        self.avatarId = [dict longForKey:@"avatarId"];

        self.broadcastFlowHash = [dict stringForKey:@"broadcastFlowHash" withDefaultValue:nil];
        if (self.broadcastFlowHash == MCTNull)
            self.broadcastFlowHash = nil;

        self.callbacks = [dict longForKey:@"callbacks" withDefaultValue:0];

        self.category_id = [dict stringForKey:@"category_id" withDefaultValue:nil];
        if (self.category_id == MCTNull)
            self.category_id = nil;

        self.contentBrandingHash = [dict stringForKey:@"contentBrandingHash" withDefaultValue:nil];
        if (self.contentBrandingHash == MCTNull)
            self.contentBrandingHash = nil;

        self.descriptionX = [dict stringForKey:@"description"];
        if (self.descriptionX == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"description"];
        if (self.descriptionX == MCTNull)
            self.descriptionX = nil;

        self.descriptionBranding = [dict stringForKey:@"descriptionBranding"];
        if (self.descriptionBranding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"descriptionBranding"];
        if (self.descriptionBranding == MCTNull)
            self.descriptionBranding = nil;

        self.email = [dict stringForKey:@"email"];
        if (self.email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"email"];
        if (self.email == MCTNull)
            self.email = nil;

        self.existence = [dict longForKey:@"existence" withDefaultValue:0];

        self.flags = [dict longForKey:@"flags" withDefaultValue:0];

        if (![dict containsLongObjectForKey:@"generation"])
            return [self errorDuringInitBecauseOfFieldWithName:@"generation"];
        self.generation = [dict longForKey:@"generation"];

        self.hasUserData = [dict boolForKey:@"hasUserData" withDefaultValue:NO];

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        self.organizationType = [dict longForKey:@"organizationType" withDefaultValue:0];

        self.pokeDescription = [dict stringForKey:@"pokeDescription"];
        if (self.pokeDescription == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"pokeDescription"];
        if (self.pokeDescription == MCTNull)
            self.pokeDescription = nil;

        self.profileData = [dict stringForKey:@"profileData" withDefaultValue:nil];
        if (self.profileData == MCTNull)
            self.profileData = nil;

        self.qualifiedIdentifier = [dict stringForKey:@"qualifiedIdentifier" withDefaultValue:nil];
        if (self.qualifiedIdentifier == MCTNull)
            self.qualifiedIdentifier = nil;

        if (![dict containsBoolObjectForKey:@"shareLocation"])
            return [self errorDuringInitBecauseOfFieldWithName:@"shareLocation"];
        self.shareLocation = [dict boolForKey:@"shareLocation"];

        if (![dict containsBoolObjectForKey:@"sharesContacts"])
            return [self errorDuringInitBecauseOfFieldWithName:@"sharesContacts"];
        self.sharesContacts = [dict boolForKey:@"sharesContacts"];

        if (![dict containsBoolObjectForKey:@"sharesLocation"])
            return [self errorDuringInitBecauseOfFieldWithName:@"sharesLocation"];
        self.sharesLocation = [dict boolForKey:@"sharesLocation"];

        if (![dict containsLongObjectForKey:@"type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        self.type = [dict longForKey:@"type"];

        self.userData = [dict stringForKey:@"userData" withDefaultValue:nil];
        if (self.userData == MCTNull)
            self.userData = nil;

        NSArray *tmp_int_array_25 = [dict arrayForKey:@"versions" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        for (id obj in tmp_int_array_25) {
            if (![obj isKindOfClass:MCTLongClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"versions"];
            MCTlong l = [obj longValue];
            if (l < MCT_MIN_LONG || l > MCT_MAX_LONG)
                return [self errorDuringInitBecauseOfFieldWithName:@"versions"];
        }
        self.versions = tmp_int_array_25;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_FriendTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_FriendTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_FriendTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_FriendTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.actionMenu dictRepresentation] forKey:@"actionMenu"];

    [dict setString:self.appData forKey:@"appData"];

    [dict setString:self.avatarHash forKey:@"avatarHash"];

    [dict setLong:self.avatarId forKey:@"avatarId"];

    [dict setString:self.broadcastFlowHash forKey:@"broadcastFlowHash"];

    [dict setLong:self.callbacks forKey:@"callbacks"];

    [dict setString:self.category_id forKey:@"category_id"];

    [dict setString:self.contentBrandingHash forKey:@"contentBrandingHash"];

    [dict setString:self.descriptionX forKey:@"description"];

    [dict setString:self.descriptionBranding forKey:@"descriptionBranding"];

    [dict setString:self.email forKey:@"email"];

    [dict setLong:self.existence forKey:@"existence"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setLong:self.generation forKey:@"generation"];

    [dict setBool:self.hasUserData forKey:@"hasUserData"];

    [dict setString:self.name forKey:@"name"];

    [dict setLong:self.organizationType forKey:@"organizationType"];

    [dict setString:self.pokeDescription forKey:@"pokeDescription"];

    [dict setString:self.profileData forKey:@"profileData"];

    [dict setString:self.qualifiedIdentifier forKey:@"qualifiedIdentifier"];

    [dict setBool:self.shareLocation forKey:@"shareLocation"];

    [dict setBool:self.sharesContacts forKey:@"sharesContacts"];

    [dict setBool:self.sharesLocation forKey:@"sharesLocation"];

    [dict setLong:self.type forKey:@"type"];

    [dict setString:self.userData forKey:@"userData"];

    // TODO: add checking that all members are indeed longs
    [dict setArray:self.versions forKey:@"versions"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetAvatarRequestTO

@synthesize avatarId = avatarId_;
@synthesize size = size_;

- (MCT_com_mobicage_to_friends_GetAvatarRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetAvatarRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"avatarId"])
            return [self errorDuringInitBecauseOfFieldWithName:@"avatarId"];
        self.avatarId = [dict longForKey:@"avatarId"];

        if (![dict containsLongObjectForKey:@"size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"size"];
        self.size = [dict longForKey:@"size"];

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetAvatarRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetAvatarRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetAvatarRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetAvatarRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.avatarId forKey:@"avatarId"];

    [dict setLong:self.size forKey:@"size"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetAvatarResponseTO

@synthesize avatar = avatar_;

- (MCT_com_mobicage_to_friends_GetAvatarResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetAvatarResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.avatar = [dict stringForKey:@"avatar"];
        if (self.avatar == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar"];
        if (self.avatar == MCTNull)
            self.avatar = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetAvatarResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetAvatarResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetAvatarResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetAvatarResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.avatar forKey:@"avatar"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetCategoryRequestTO

@synthesize category_id = category_id_;

- (MCT_com_mobicage_to_friends_GetCategoryRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetCategoryRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.category_id = [dict stringForKey:@"category_id"];
        if (self.category_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"category_id"];
        if (self.category_id == MCTNull)
            self.category_id = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetCategoryRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetCategoryRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetCategoryRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetCategoryRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.category_id forKey:@"category_id"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetCategoryResponseTO

@synthesize category = category_;

- (MCT_com_mobicage_to_friends_GetCategoryResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetCategoryResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"category"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"category"];
        if (tmp_dict_0 == MCTNull)
            self.category = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_friends_FriendCategoryTO *tmp_to_0 = [MCT_com_mobicage_to_friends_FriendCategoryTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"category"];
            self.category = (MCT_com_mobicage_to_friends_FriendCategoryTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetCategoryResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetCategoryResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetCategoryResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetCategoryResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.category dictRepresentation] forKey:@"category"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetFriendEmailsRequestTO


- (MCT_com_mobicage_to_friends_GetFriendEmailsRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetFriendEmailsRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetFriendEmailsRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetFriendEmailsRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetFriendEmailsRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetFriendEmailsRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetFriendEmailsResponseTO

@synthesize emails = emails_;
@synthesize friend_set_version = friend_set_version_;
@synthesize generation = generation_;

- (MCT_com_mobicage_to_friends_GetFriendEmailsResponseTO *)init
{
    if (self = [super init]) {
        self.emails = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetFriendEmailsResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_unicode_array_0 = [dict arrayForKey:@"emails"];
        if (tmp_unicode_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"emails"];
        for (id obj in tmp_unicode_array_0) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"emails"];
        }
        self.emails = tmp_unicode_array_0;

        self.friend_set_version = [dict longForKey:@"friend_set_version" withDefaultValue:0];

        if (![dict containsLongObjectForKey:@"generation"])
            return [self errorDuringInitBecauseOfFieldWithName:@"generation"];
        self.generation = [dict longForKey:@"generation"];

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetFriendEmailsResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetFriendEmailsResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetFriendEmailsResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetFriendEmailsResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.emails forKey:@"emails"];

    [dict setLong:self.friend_set_version forKey:@"friend_set_version"];

    [dict setLong:self.generation forKey:@"generation"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetFriendInvitationSecretsRequestTO


- (MCT_com_mobicage_to_friends_GetFriendInvitationSecretsRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetFriendInvitationSecretsRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetFriendInvitationSecretsRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetFriendInvitationSecretsRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetFriendInvitationSecretsRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetFriendInvitationSecretsRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetFriendInvitationSecretsResponseTO

@synthesize secrets = secrets_;

- (MCT_com_mobicage_to_friends_GetFriendInvitationSecretsResponseTO *)init
{
    if (self = [super init]) {
        self.secrets = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetFriendInvitationSecretsResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_unicode_array_0 = [dict arrayForKey:@"secrets"];
        if (tmp_unicode_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"secrets"];
        for (id obj in tmp_unicode_array_0) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"secrets"];
        }
        self.secrets = tmp_unicode_array_0;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetFriendInvitationSecretsResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetFriendInvitationSecretsResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetFriendInvitationSecretsResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetFriendInvitationSecretsResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.secrets forKey:@"secrets"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetFriendRequestTO

@synthesize avatar_size = avatar_size_;
@synthesize email = email_;

- (MCT_com_mobicage_to_friends_GetFriendRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetFriendRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"avatar_size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar_size"];
        self.avatar_size = [dict longForKey:@"avatar_size"];

        self.email = [dict stringForKey:@"email"];
        if (self.email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"email"];
        if (self.email == MCTNull)
            self.email = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetFriendRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetFriendRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetFriendRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetFriendRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.avatar_size forKey:@"avatar_size"];

    [dict setString:self.email forKey:@"email"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetFriendResponseTO

@synthesize friend = friend_;
@synthesize avatar = avatar_;
@synthesize generation = generation_;

- (MCT_com_mobicage_to_friends_GetFriendResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetFriendResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"friend"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friend"];
        if (tmp_dict_0 == MCTNull)
            self.friend = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_friends_FriendTO *tmp_to_0 = [MCT_com_mobicage_to_friends_FriendTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"friend"];
            self.friend = (MCT_com_mobicage_to_friends_FriendTO *)tmp_to_0;
        }

        self.avatar = [dict stringForKey:@"avatar"];
        if (self.avatar == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar"];
        if (self.avatar == MCTNull)
            self.avatar = nil;

        if (![dict containsLongObjectForKey:@"generation"])
            return [self errorDuringInitBecauseOfFieldWithName:@"generation"];
        self.generation = [dict longForKey:@"generation"];

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetFriendResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetFriendResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetFriendResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetFriendResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.friend dictRepresentation] forKey:@"friend"];

    [dict setString:self.avatar forKey:@"avatar"];

    [dict setLong:self.generation forKey:@"generation"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetFriendsListRequestTO


- (MCT_com_mobicage_to_friends_GetFriendsListRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetFriendsListRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetFriendsListRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetFriendsListRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetFriendsListRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetFriendsListRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetFriendsListResponseTO

@synthesize friends = friends_;
@synthesize generation = generation_;

- (MCT_com_mobicage_to_friends_GetFriendsListResponseTO *)init
{
    if (self = [super init]) {
        self.friends = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetFriendsListResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"friends"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friends"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"friends"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_friends_FriendTO *tmp_obj = [MCT_com_mobicage_to_friends_FriendTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"friends"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.friends = tmp_obj_array_0;
        }

        if (![dict containsLongObjectForKey:@"generation"])
            return [self errorDuringInitBecauseOfFieldWithName:@"generation"];
        self.generation = [dict longForKey:@"generation"];

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetFriendsListResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetFriendsListResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetFriendsListResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetFriendsListResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.friends == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_friends_GetFriendsListResponseTO.friends");
    } else if ([self.friends isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.friends count]];
        for (MCT_com_mobicage_to_friends_FriendTO *obj in self.friends)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"friends"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_friends_GetFriendsListResponseTO.friends");
    }

    [dict setLong:self.generation forKey:@"generation"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetGroupAvatarRequestTO

@synthesize avatar_hash = avatar_hash_;
@synthesize size = size_;

- (MCT_com_mobicage_to_friends_GetGroupAvatarRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetGroupAvatarRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.avatar_hash = [dict stringForKey:@"avatar_hash"];
        if (self.avatar_hash == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar_hash"];
        if (self.avatar_hash == MCTNull)
            self.avatar_hash = nil;

        if (![dict containsLongObjectForKey:@"size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"size"];
        self.size = [dict longForKey:@"size"];

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetGroupAvatarRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetGroupAvatarRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetGroupAvatarRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetGroupAvatarRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.avatar_hash forKey:@"avatar_hash"];

    [dict setLong:self.size forKey:@"size"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetGroupAvatarResponseTO

@synthesize avatar = avatar_;

- (MCT_com_mobicage_to_friends_GetGroupAvatarResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetGroupAvatarResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.avatar = [dict stringForKey:@"avatar"];
        if (self.avatar == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar"];
        if (self.avatar == MCTNull)
            self.avatar = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetGroupAvatarResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetGroupAvatarResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetGroupAvatarResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetGroupAvatarResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.avatar forKey:@"avatar"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetGroupsRequestTO


- (MCT_com_mobicage_to_friends_GetGroupsRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetGroupsRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetGroupsRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetGroupsRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetGroupsRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetGroupsRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetGroupsResponseTO

@synthesize groups = groups_;

- (MCT_com_mobicage_to_friends_GetGroupsResponseTO *)init
{
    if (self = [super init]) {
        self.groups = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetGroupsResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"groups"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"groups"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"groups"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_friends_GroupTO *tmp_obj = [MCT_com_mobicage_to_friends_GroupTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"groups"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.groups = tmp_obj_array_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetGroupsResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetGroupsResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetGroupsResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetGroupsResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.groups == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_friends_GetGroupsResponseTO.groups");
    } else if ([self.groups isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.groups count]];
        for (MCT_com_mobicage_to_friends_GroupTO *obj in self.groups)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"groups"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_friends_GetGroupsResponseTO.groups");
    }

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetUserInfoRequestTO

@synthesize allow_cross_app = allow_cross_app_;
@synthesize code = code_;

- (MCT_com_mobicage_to_friends_GetUserInfoRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetUserInfoRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.allow_cross_app = [dict boolForKey:@"allow_cross_app" withDefaultValue:NO];

        self.code = [dict stringForKey:@"code"];
        if (self.code == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"code"];
        if (self.code == MCTNull)
            self.code = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetUserInfoRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetUserInfoRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetUserInfoRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetUserInfoRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setBool:self.allow_cross_app forKey:@"allow_cross_app"];

    [dict setString:self.code forKey:@"code"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GetUserInfoResponseTO

@synthesize error = error_;
@synthesize app_id = app_id_;
@synthesize avatar = avatar_;
@synthesize avatar_id = avatar_id_;
@synthesize descriptionX = descriptionX_;
@synthesize descriptionBranding = descriptionBranding_;
@synthesize email = email_;
@synthesize name = name_;
@synthesize profileData = profileData_;
@synthesize qualifiedIdentifier = qualifiedIdentifier_;
@synthesize type = type_;

- (MCT_com_mobicage_to_friends_GetUserInfoResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GetUserInfoResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"error" withDefaultValue:nil];
        if (tmp_dict_0 == MCTNull)
            self.error = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_friends_ErrorTO *tmp_to_0 = [MCT_com_mobicage_to_friends_ErrorTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"error"];
            self.error = (MCT_com_mobicage_to_friends_ErrorTO *)tmp_to_0;
        }

        self.app_id = [dict stringForKey:@"app_id" withDefaultValue:nil];
        if (self.app_id == MCTNull)
            self.app_id = nil;

        self.avatar = [dict stringForKey:@"avatar"];
        if (self.avatar == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar"];
        if (self.avatar == MCTNull)
            self.avatar = nil;

        self.avatar_id = [dict longForKey:@"avatar_id" withDefaultValue:-1];

        self.descriptionX = [dict stringForKey:@"description"];
        if (self.descriptionX == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"description"];
        if (self.descriptionX == MCTNull)
            self.descriptionX = nil;

        self.descriptionBranding = [dict stringForKey:@"descriptionBranding"];
        if (self.descriptionBranding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"descriptionBranding"];
        if (self.descriptionBranding == MCTNull)
            self.descriptionBranding = nil;

        self.email = [dict stringForKey:@"email"];
        if (self.email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"email"];
        if (self.email == MCTNull)
            self.email = nil;

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        self.profileData = [dict stringForKey:@"profileData" withDefaultValue:nil];
        if (self.profileData == MCTNull)
            self.profileData = nil;

        self.qualifiedIdentifier = [dict stringForKey:@"qualifiedIdentifier"];
        if (self.qualifiedIdentifier == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"qualifiedIdentifier"];
        if (self.qualifiedIdentifier == MCTNull)
            self.qualifiedIdentifier = nil;

        if (![dict containsLongObjectForKey:@"type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        self.type = [dict longForKey:@"type"];

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GetUserInfoResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GetUserInfoResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GetUserInfoResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GetUserInfoResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.error dictRepresentation] forKey:@"error"];

    [dict setString:self.app_id forKey:@"app_id"];

    [dict setString:self.avatar forKey:@"avatar"];

    [dict setLong:self.avatar_id forKey:@"avatar_id"];

    [dict setString:self.descriptionX forKey:@"description"];

    [dict setString:self.descriptionBranding forKey:@"descriptionBranding"];

    [dict setString:self.email forKey:@"email"];

    [dict setString:self.name forKey:@"name"];

    [dict setString:self.profileData forKey:@"profileData"];

    [dict setString:self.qualifiedIdentifier forKey:@"qualifiedIdentifier"];

    [dict setLong:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_GroupTO

@synthesize avatar_hash = avatar_hash_;
@synthesize guid = guid_;
@synthesize members = members_;
@synthesize name = name_;

- (MCT_com_mobicage_to_friends_GroupTO *)init
{
    if (self = [super init]) {
        self.members = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_friends_GroupTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.avatar_hash = [dict stringForKey:@"avatar_hash"];
        if (self.avatar_hash == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar_hash"];
        if (self.avatar_hash == MCTNull)
            self.avatar_hash = nil;

        self.guid = [dict stringForKey:@"guid"];
        if (self.guid == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"guid"];
        if (self.guid == MCTNull)
            self.guid = nil;

        NSArray *tmp_unicode_array_2 = [dict arrayForKey:@"members"];
        if (tmp_unicode_array_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"members"];
        for (id obj in tmp_unicode_array_2) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"members"];
        }
        self.members = tmp_unicode_array_2;

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_GroupTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_GroupTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_GroupTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_GroupTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.avatar_hash forKey:@"avatar_hash"];

    [dict setString:self.guid forKey:@"guid"];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.members forKey:@"members"];

    [dict setString:self.name forKey:@"name"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_InviteFriendRequestTO

@synthesize email = email_;
@synthesize message = message_;

- (MCT_com_mobicage_to_friends_InviteFriendRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_InviteFriendRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.email = [dict stringForKey:@"email"];
        if (self.email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"email"];
        if (self.email == MCTNull)
            self.email = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_InviteFriendRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_InviteFriendRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_InviteFriendRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_InviteFriendRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.email forKey:@"email"];

    [dict setString:self.message forKey:@"message"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_InviteFriendResponseTO


- (MCT_com_mobicage_to_friends_InviteFriendResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_InviteFriendResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_friends_InviteFriendResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_InviteFriendResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_InviteFriendResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_InviteFriendResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_LogInvitationSecretSentRequestTO

@synthesize phone_number = phone_number_;
@synthesize secret = secret_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_friends_LogInvitationSecretSentRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_LogInvitationSecretSentRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.phone_number = [dict stringForKey:@"phone_number"];
        if (self.phone_number == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"phone_number"];
        if (self.phone_number == MCTNull)
            self.phone_number = nil;

        self.secret = [dict stringForKey:@"secret"];
        if (self.secret == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"secret"];
        if (self.secret == MCTNull)
            self.secret = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_LogInvitationSecretSentRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_LogInvitationSecretSentRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_LogInvitationSecretSentRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_LogInvitationSecretSentRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.phone_number forKey:@"phone_number"];

    [dict setString:self.secret forKey:@"secret"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_LogInvitationSecretSentResponseTO


- (MCT_com_mobicage_to_friends_LogInvitationSecretSentResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_LogInvitationSecretSentResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_friends_LogInvitationSecretSentResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_LogInvitationSecretSentResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_LogInvitationSecretSentResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_LogInvitationSecretSentResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_PutGroupRequestTO

@synthesize avatar = avatar_;
@synthesize guid = guid_;
@synthesize members = members_;
@synthesize name = name_;

- (MCT_com_mobicage_to_friends_PutGroupRequestTO *)init
{
    if (self = [super init]) {
        self.members = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_friends_PutGroupRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.avatar = [dict stringForKey:@"avatar"];
        if (self.avatar == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar"];
        if (self.avatar == MCTNull)
            self.avatar = nil;

        self.guid = [dict stringForKey:@"guid"];
        if (self.guid == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"guid"];
        if (self.guid == MCTNull)
            self.guid = nil;

        NSArray *tmp_unicode_array_2 = [dict arrayForKey:@"members"];
        if (tmp_unicode_array_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"members"];
        for (id obj in tmp_unicode_array_2) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"members"];
        }
        self.members = tmp_unicode_array_2;

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_PutGroupRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_PutGroupRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_PutGroupRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_PutGroupRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.avatar forKey:@"avatar"];

    [dict setString:self.guid forKey:@"guid"];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.members forKey:@"members"];

    [dict setString:self.name forKey:@"name"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_PutGroupResponseTO

@synthesize avatar_hash = avatar_hash_;

- (MCT_com_mobicage_to_friends_PutGroupResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_PutGroupResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.avatar_hash = [dict stringForKey:@"avatar_hash"];
        if (self.avatar_hash == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar_hash"];
        if (self.avatar_hash == MCTNull)
            self.avatar_hash = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_PutGroupResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_PutGroupResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_PutGroupResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_PutGroupResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.avatar_hash forKey:@"avatar_hash"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_RequestShareLocationRequestTO

@synthesize friend = friend_;
@synthesize message = message_;

- (MCT_com_mobicage_to_friends_RequestShareLocationRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_RequestShareLocationRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.friend = [dict stringForKey:@"friend"];
        if (self.friend == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friend"];
        if (self.friend == MCTNull)
            self.friend = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_RequestShareLocationRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_RequestShareLocationRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_RequestShareLocationRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_RequestShareLocationRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.friend forKey:@"friend"];

    [dict setString:self.message forKey:@"message"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_RequestShareLocationResponseTO


- (MCT_com_mobicage_to_friends_RequestShareLocationResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_RequestShareLocationResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_friends_RequestShareLocationResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_RequestShareLocationResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_RequestShareLocationResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_RequestShareLocationResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_ServiceMenuItemTO

@synthesize coords = coords_;
@synthesize hashedTag = hashedTag_;
@synthesize iconHash = iconHash_;
@synthesize label = label_;
@synthesize requiresWifi = requiresWifi_;
@synthesize runInBackground = runInBackground_;
@synthesize screenBranding = screenBranding_;
@synthesize staticFlowHash = staticFlowHash_;

- (MCT_com_mobicage_to_friends_ServiceMenuItemTO *)init
{
    if (self = [super init]) {
        self.coords = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_friends_ServiceMenuItemTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_int_array_0 = [dict arrayForKey:@"coords"];
        if (tmp_int_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"coords"];
        for (id obj in tmp_int_array_0) {
            if (![obj isKindOfClass:MCTLongClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"coords"];
            MCTlong l = [obj longValue];
            if (l < MCT_MIN_LONG || l > MCT_MAX_LONG)
                return [self errorDuringInitBecauseOfFieldWithName:@"coords"];
        }
        self.coords = tmp_int_array_0;

        self.hashedTag = [dict stringForKey:@"hashedTag" withDefaultValue:nil];
        if (self.hashedTag == MCTNull)
            self.hashedTag = nil;

        self.iconHash = [dict stringForKey:@"iconHash"];
        if (self.iconHash == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"iconHash"];
        if (self.iconHash == MCTNull)
            self.iconHash = nil;

        self.label = [dict stringForKey:@"label"];
        if (self.label == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"label"];
        if (self.label == MCTNull)
            self.label = nil;

        self.requiresWifi = [dict boolForKey:@"requiresWifi" withDefaultValue:NO];

        self.runInBackground = [dict boolForKey:@"runInBackground" withDefaultValue:YES];

        self.screenBranding = [dict stringForKey:@"screenBranding"];
        if (self.screenBranding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"screenBranding"];
        if (self.screenBranding == MCTNull)
            self.screenBranding = nil;

        self.staticFlowHash = [dict stringForKey:@"staticFlowHash" withDefaultValue:nil];
        if (self.staticFlowHash == MCTNull)
            self.staticFlowHash = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_ServiceMenuItemTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_ServiceMenuItemTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_ServiceMenuItemTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_ServiceMenuItemTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // TODO: add checking that all members are indeed longs
    [dict setArray:self.coords forKey:@"coords"];

    [dict setString:self.hashedTag forKey:@"hashedTag"];

    [dict setString:self.iconHash forKey:@"iconHash"];

    [dict setString:self.label forKey:@"label"];

    [dict setBool:self.requiresWifi forKey:@"requiresWifi"];

    [dict setBool:self.runInBackground forKey:@"runInBackground"];

    [dict setString:self.screenBranding forKey:@"screenBranding"];

    [dict setString:self.staticFlowHash forKey:@"staticFlowHash"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_ServiceMenuTO

@synthesize items = items_;
@synthesize aboutLabel = aboutLabel_;
@synthesize branding = branding_;
@synthesize callConfirmation = callConfirmation_;
@synthesize callLabel = callLabel_;
@synthesize messagesLabel = messagesLabel_;
@synthesize phoneNumber = phoneNumber_;
@synthesize share = share_;
@synthesize shareCaption = shareCaption_;
@synthesize shareDescription = shareDescription_;
@synthesize shareImageUrl = shareImageUrl_;
@synthesize shareLabel = shareLabel_;
@synthesize shareLinkUrl = shareLinkUrl_;
@synthesize staticFlowBrandings = staticFlowBrandings_;

- (MCT_com_mobicage_to_friends_ServiceMenuTO *)init
{
    if (self = [super init]) {
        self.items = [NSMutableArray array];
        self.staticFlowBrandings = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_friends_ServiceMenuTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"items"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"items"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"items"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_friends_ServiceMenuItemTO *tmp_obj = [MCT_com_mobicage_to_friends_ServiceMenuItemTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"items"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.items = tmp_obj_array_0;
        }

        self.aboutLabel = [dict stringForKey:@"aboutLabel"];
        if (self.aboutLabel == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"aboutLabel"];
        if (self.aboutLabel == MCTNull)
            self.aboutLabel = nil;

        self.branding = [dict stringForKey:@"branding"];
        if (self.branding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"branding"];
        if (self.branding == MCTNull)
            self.branding = nil;

        self.callConfirmation = [dict stringForKey:@"callConfirmation"];
        if (self.callConfirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"callConfirmation"];
        if (self.callConfirmation == MCTNull)
            self.callConfirmation = nil;

        self.callLabel = [dict stringForKey:@"callLabel"];
        if (self.callLabel == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"callLabel"];
        if (self.callLabel == MCTNull)
            self.callLabel = nil;

        self.messagesLabel = [dict stringForKey:@"messagesLabel"];
        if (self.messagesLabel == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"messagesLabel"];
        if (self.messagesLabel == MCTNull)
            self.messagesLabel = nil;

        self.phoneNumber = [dict stringForKey:@"phoneNumber"];
        if (self.phoneNumber == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"phoneNumber"];
        if (self.phoneNumber == MCTNull)
            self.phoneNumber = nil;

        if (![dict containsBoolObjectForKey:@"share"])
            return [self errorDuringInitBecauseOfFieldWithName:@"share"];
        self.share = [dict boolForKey:@"share"];

        self.shareCaption = [dict stringForKey:@"shareCaption"];
        if (self.shareCaption == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"shareCaption"];
        if (self.shareCaption == MCTNull)
            self.shareCaption = nil;

        self.shareDescription = [dict stringForKey:@"shareDescription"];
        if (self.shareDescription == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"shareDescription"];
        if (self.shareDescription == MCTNull)
            self.shareDescription = nil;

        self.shareImageUrl = [dict stringForKey:@"shareImageUrl"];
        if (self.shareImageUrl == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"shareImageUrl"];
        if (self.shareImageUrl == MCTNull)
            self.shareImageUrl = nil;

        self.shareLabel = [dict stringForKey:@"shareLabel"];
        if (self.shareLabel == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"shareLabel"];
        if (self.shareLabel == MCTNull)
            self.shareLabel = nil;

        self.shareLinkUrl = [dict stringForKey:@"shareLinkUrl"];
        if (self.shareLinkUrl == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"shareLinkUrl"];
        if (self.shareLinkUrl == MCTNull)
            self.shareLinkUrl = nil;

        NSArray *tmp_unicode_array_13 = [dict arrayForKey:@"staticFlowBrandings"];
        if (tmp_unicode_array_13 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"staticFlowBrandings"];
        for (id obj in tmp_unicode_array_13) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"staticFlowBrandings"];
        }
        self.staticFlowBrandings = tmp_unicode_array_13;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_ServiceMenuTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_ServiceMenuTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_ServiceMenuTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_ServiceMenuTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.items == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_friends_ServiceMenuTO.items");
    } else if ([self.items isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.items count]];
        for (MCT_com_mobicage_to_friends_ServiceMenuItemTO *obj in self.items)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"items"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_friends_ServiceMenuTO.items");
    }

    [dict setString:self.aboutLabel forKey:@"aboutLabel"];

    [dict setString:self.branding forKey:@"branding"];

    [dict setString:self.callConfirmation forKey:@"callConfirmation"];

    [dict setString:self.callLabel forKey:@"callLabel"];

    [dict setString:self.messagesLabel forKey:@"messagesLabel"];

    [dict setString:self.phoneNumber forKey:@"phoneNumber"];

    [dict setBool:self.share forKey:@"share"];

    [dict setString:self.shareCaption forKey:@"shareCaption"];

    [dict setString:self.shareDescription forKey:@"shareDescription"];

    [dict setString:self.shareImageUrl forKey:@"shareImageUrl"];

    [dict setString:self.shareLabel forKey:@"shareLabel"];

    [dict setString:self.shareLinkUrl forKey:@"shareLinkUrl"];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.staticFlowBrandings forKey:@"staticFlowBrandings"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_ShareLocationRequestTO

@synthesize enabled = enabled_;
@synthesize friend = friend_;

- (MCT_com_mobicage_to_friends_ShareLocationRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_ShareLocationRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsBoolObjectForKey:@"enabled"])
            return [self errorDuringInitBecauseOfFieldWithName:@"enabled"];
        self.enabled = [dict boolForKey:@"enabled"];

        self.friend = [dict stringForKey:@"friend"];
        if (self.friend == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friend"];
        if (self.friend == MCTNull)
            self.friend = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_ShareLocationRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_ShareLocationRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_ShareLocationRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_ShareLocationRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setBool:self.enabled forKey:@"enabled"];

    [dict setString:self.friend forKey:@"friend"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_ShareLocationResponseTO


- (MCT_com_mobicage_to_friends_ShareLocationResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_ShareLocationResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_friends_ShareLocationResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_ShareLocationResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_ShareLocationResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_ShareLocationResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_UpdateFriendRequestTO

@synthesize friend = friend_;
@synthesize generation = generation_;
@synthesize status = status_;

- (MCT_com_mobicage_to_friends_UpdateFriendRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_UpdateFriendRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"friend"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friend"];
        if (tmp_dict_0 == MCTNull)
            self.friend = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_friends_FriendTO *tmp_to_0 = [MCT_com_mobicage_to_friends_FriendTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"friend"];
            self.friend = (MCT_com_mobicage_to_friends_FriendTO *)tmp_to_0;
        }

        if (![dict containsLongObjectForKey:@"generation"])
            return [self errorDuringInitBecauseOfFieldWithName:@"generation"];
        self.generation = [dict longForKey:@"generation"];

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_UpdateFriendRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_UpdateFriendRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_UpdateFriendRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_UpdateFriendRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.friend dictRepresentation] forKey:@"friend"];

    [dict setLong:self.generation forKey:@"generation"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_UpdateFriendResponseTO

@synthesize reason = reason_;
@synthesize updated = updated_;

- (MCT_com_mobicage_to_friends_UpdateFriendResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_UpdateFriendResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.reason = [dict stringForKey:@"reason"];
        if (self.reason == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"reason"];
        if (self.reason == MCTNull)
            self.reason = nil;

        if (![dict containsBoolObjectForKey:@"updated"])
            return [self errorDuringInitBecauseOfFieldWithName:@"updated"];
        self.updated = [dict boolForKey:@"updated"];

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_UpdateFriendResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_UpdateFriendResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_UpdateFriendResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_UpdateFriendResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.reason forKey:@"reason"];

    [dict setBool:self.updated forKey:@"updated"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_UpdateFriendSetRequestTO

@synthesize added_friend = added_friend_;
@synthesize friends = friends_;
@synthesize version = version_;

- (MCT_com_mobicage_to_friends_UpdateFriendSetRequestTO *)init
{
    if (self = [super init]) {
        self.friends = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_friends_UpdateFriendSetRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"added_friend"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"added_friend"];
        if (tmp_dict_0 == MCTNull)
            self.added_friend = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_friends_FriendTO *tmp_to_0 = [MCT_com_mobicage_to_friends_FriendTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"added_friend"];
            self.added_friend = (MCT_com_mobicage_to_friends_FriendTO *)tmp_to_0;
        }

        NSArray *tmp_unicode_array_1 = [dict arrayForKey:@"friends"];
        if (tmp_unicode_array_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friends"];
        for (id obj in tmp_unicode_array_1) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"friends"];
        }
        self.friends = tmp_unicode_array_1;

        if (![dict containsLongObjectForKey:@"version"])
            return [self errorDuringInitBecauseOfFieldWithName:@"version"];
        self.version = [dict longForKey:@"version"];

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_UpdateFriendSetRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_UpdateFriendSetRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_UpdateFriendSetRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_UpdateFriendSetRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.added_friend dictRepresentation] forKey:@"added_friend"];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.friends forKey:@"friends"];

    [dict setLong:self.version forKey:@"version"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO

@synthesize reason = reason_;
@synthesize updated = updated_;

- (MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.reason = [dict stringForKey:@"reason"];
        if (self.reason == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"reason"];
        if (self.reason == MCTNull)
            self.reason = nil;

        if (![dict containsBoolObjectForKey:@"updated"])
            return [self errorDuringInitBecauseOfFieldWithName:@"updated"];
        self.updated = [dict boolForKey:@"updated"];

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_UpdateFriendSetResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.reason forKey:@"reason"];

    [dict setBool:self.updated forKey:@"updated"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_UpdateGroupsRequestTO


- (MCT_com_mobicage_to_friends_UpdateGroupsRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_UpdateGroupsRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_friends_UpdateGroupsRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_UpdateGroupsRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_UpdateGroupsRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_UpdateGroupsRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_UpdateGroupsResponseTO


- (MCT_com_mobicage_to_friends_UpdateGroupsResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_UpdateGroupsResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_friends_UpdateGroupsResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_UpdateGroupsResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_UpdateGroupsResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_UpdateGroupsResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_UserScannedRequestTO

@synthesize app_id = app_id_;
@synthesize email = email_;
@synthesize service_email = service_email_;

- (MCT_com_mobicage_to_friends_UserScannedRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_UserScannedRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.app_id = [dict stringForKey:@"app_id"];
        if (self.app_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"app_id"];
        if (self.app_id == MCTNull)
            self.app_id = nil;

        self.email = [dict stringForKey:@"email"];
        if (self.email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"email"];
        if (self.email == MCTNull)
            self.email = nil;

        self.service_email = [dict stringForKey:@"service_email"];
        if (self.service_email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"service_email"];
        if (self.service_email == MCTNull)
            self.service_email = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_friends_UserScannedRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_UserScannedRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_UserScannedRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_UserScannedRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.app_id forKey:@"app_id"];

    [dict setString:self.email forKey:@"email"];

    [dict setString:self.service_email forKey:@"service_email"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_friends_UserScannedResponseTO


- (MCT_com_mobicage_to_friends_UserScannedResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_friends_UserScannedResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_friends_UserScannedResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_friends_UserScannedResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_friends_UserScannedResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_friends_UserScannedResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_js_embedding_GetJSEmbeddingRequestTO


- (MCT_com_mobicage_to_js_embedding_GetJSEmbeddingRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_js_embedding_GetJSEmbeddingRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_js_embedding_GetJSEmbeddingRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_js_embedding_GetJSEmbeddingRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_js_embedding_GetJSEmbeddingRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_js_embedding_GetJSEmbeddingRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_js_embedding_GetJSEmbeddingResponseTO

@synthesize items = items_;

- (MCT_com_mobicage_to_js_embedding_GetJSEmbeddingResponseTO *)init
{
    if (self = [super init]) {
        self.items = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_js_embedding_GetJSEmbeddingResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"items"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"items"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"items"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO *tmp_obj = [MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"items"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.items = tmp_obj_array_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_js_embedding_GetJSEmbeddingResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_js_embedding_GetJSEmbeddingResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_js_embedding_GetJSEmbeddingResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_js_embedding_GetJSEmbeddingResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.items == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_js_embedding_GetJSEmbeddingResponseTO.items");
    } else if ([self.items isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.items count]];
        for (MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO *obj in self.items)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"items"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_js_embedding_GetJSEmbeddingResponseTO.items");
    }

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO

@synthesize hashX = hashX_;
@synthesize name = name_;

- (MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.hashX = [dict stringForKey:@"hash"];
        if (self.hashX == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"hash"];
        if (self.hashX == MCTNull)
            self.hashX = nil;

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO *)transferObject
{
    return [[MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO alloc] init];
}

+ (MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.hashX forKey:@"hash"];

    [dict setString:self.name forKey:@"name"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO

@synthesize items = items_;

- (MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO *)init
{
    if (self = [super init]) {
        self.items = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"items"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"items"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"items"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO *tmp_obj = [MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"items"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.items = tmp_obj_array_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.items == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO.items");
    } else if ([self.items isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.items count]];
        for (MCT_com_mobicage_to_js_embedding_JSEmbeddingItemTO *obj in self.items)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"items"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingRequestTO.items");
    }

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingResponseTO


- (MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_js_embedding_UpdateJSEmbeddingResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO

@synthesize name = name_;
@synthesize uuid = uuid_;

- (MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        self.uuid = [dict stringForKey:@"uuid"];
        if (self.uuid == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"uuid"];
        if (self.uuid == MCTNull)
            self.uuid = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_BeaconDiscoveredRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.name forKey:@"name"];

    [dict setString:self.uuid forKey:@"uuid"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_BeaconDiscoveredResponseTO

@synthesize friend_email = friend_email_;
@synthesize tag = tag_;

- (MCT_com_mobicage_to_location_BeaconDiscoveredResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_BeaconDiscoveredResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.friend_email = [dict stringForKey:@"friend_email"];
        if (self.friend_email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friend_email"];
        if (self.friend_email == MCTNull)
            self.friend_email = nil;

        self.tag = [dict stringForKey:@"tag" withDefaultValue:nil];
        if (self.tag == MCTNull)
            self.tag = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_location_BeaconDiscoveredResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_BeaconDiscoveredResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_location_BeaconDiscoveredResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_BeaconDiscoveredResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.friend_email forKey:@"friend_email"];

    [dict setString:self.tag forKey:@"tag"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_BeaconInReachRequestTO

@synthesize friend_email = friend_email_;
@synthesize name = name_;
@synthesize proximity = proximity_;
@synthesize uuid = uuid_;

- (MCT_com_mobicage_to_location_BeaconInReachRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_BeaconInReachRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.friend_email = [dict stringForKey:@"friend_email"];
        if (self.friend_email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friend_email"];
        if (self.friend_email == MCTNull)
            self.friend_email = nil;

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        if (![dict containsLongObjectForKey:@"proximity"])
            return [self errorDuringInitBecauseOfFieldWithName:@"proximity"];
        self.proximity = [dict longForKey:@"proximity"];

        self.uuid = [dict stringForKey:@"uuid"];
        if (self.uuid == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"uuid"];
        if (self.uuid == MCTNull)
            self.uuid = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_location_BeaconInReachRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_BeaconInReachRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_location_BeaconInReachRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_BeaconInReachRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.friend_email forKey:@"friend_email"];

    [dict setString:self.name forKey:@"name"];

    [dict setLong:self.proximity forKey:@"proximity"];

    [dict setString:self.uuid forKey:@"uuid"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_BeaconInReachResponseTO


- (MCT_com_mobicage_to_location_BeaconInReachResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_BeaconInReachResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_location_BeaconInReachResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_BeaconInReachResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_location_BeaconInReachResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_BeaconInReachResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_BeaconOutOfReachRequestTO

@synthesize friend_email = friend_email_;
@synthesize name = name_;
@synthesize uuid = uuid_;

- (MCT_com_mobicage_to_location_BeaconOutOfReachRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_BeaconOutOfReachRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.friend_email = [dict stringForKey:@"friend_email"];
        if (self.friend_email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friend_email"];
        if (self.friend_email == MCTNull)
            self.friend_email = nil;

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        self.uuid = [dict stringForKey:@"uuid"];
        if (self.uuid == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"uuid"];
        if (self.uuid == MCTNull)
            self.uuid = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_location_BeaconOutOfReachRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_BeaconOutOfReachRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_location_BeaconOutOfReachRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_BeaconOutOfReachRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.friend_email forKey:@"friend_email"];

    [dict setString:self.name forKey:@"name"];

    [dict setString:self.uuid forKey:@"uuid"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_BeaconOutOfReachResponseTO


- (MCT_com_mobicage_to_location_BeaconOutOfReachResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_BeaconOutOfReachResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_location_BeaconOutOfReachResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_BeaconOutOfReachResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_location_BeaconOutOfReachResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_BeaconOutOfReachResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_DeleteBeaconDiscoveryRequestTO

@synthesize name = name_;
@synthesize uuid = uuid_;

- (MCT_com_mobicage_to_location_DeleteBeaconDiscoveryRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_DeleteBeaconDiscoveryRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        self.uuid = [dict stringForKey:@"uuid"];
        if (self.uuid == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"uuid"];
        if (self.uuid == MCTNull)
            self.uuid = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_location_DeleteBeaconDiscoveryRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_DeleteBeaconDiscoveryRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_location_DeleteBeaconDiscoveryRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_DeleteBeaconDiscoveryRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.name forKey:@"name"];

    [dict setString:self.uuid forKey:@"uuid"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_DeleteBeaconDiscoveryResponseTO


- (MCT_com_mobicage_to_location_DeleteBeaconDiscoveryResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_DeleteBeaconDiscoveryResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_location_DeleteBeaconDiscoveryResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_DeleteBeaconDiscoveryResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_location_DeleteBeaconDiscoveryResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_DeleteBeaconDiscoveryResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_FriendLocationTO

@synthesize location = location_;
@synthesize email = email_;

- (MCT_com_mobicage_to_location_FriendLocationTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_FriendLocationTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"location"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"location"];
        if (tmp_dict_0 == MCTNull)
            self.location = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *tmp_to_0 = [MCT_com_mobicage_to_activity_GeoPointWithTimestampTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"location"];
            self.location = (MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *)tmp_to_0;
        }

        self.email = [dict stringForKey:@"email"];
        if (self.email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"email"];
        if (self.email == MCTNull)
            self.email = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_location_FriendLocationTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_FriendLocationTO alloc] init];
}

+ (MCT_com_mobicage_to_location_FriendLocationTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_FriendLocationTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.location dictRepresentation] forKey:@"location"];

    [dict setString:self.email forKey:@"email"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_GetFriendLocationRequestTO

@synthesize friend = friend_;

- (MCT_com_mobicage_to_location_GetFriendLocationRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_GetFriendLocationRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.friend = [dict stringForKey:@"friend"];
        if (self.friend == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friend"];
        if (self.friend == MCTNull)
            self.friend = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_location_GetFriendLocationRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_GetFriendLocationRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_location_GetFriendLocationRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_GetFriendLocationRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.friend forKey:@"friend"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_GetFriendLocationResponseTO

@synthesize location = location_;

- (MCT_com_mobicage_to_location_GetFriendLocationResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_GetFriendLocationResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"location"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"location"];
        if (tmp_dict_0 == MCTNull)
            self.location = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *tmp_to_0 = [MCT_com_mobicage_to_activity_GeoPointWithTimestampTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"location"];
            self.location = (MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_location_GetFriendLocationResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_GetFriendLocationResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_location_GetFriendLocationResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_GetFriendLocationResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.location dictRepresentation] forKey:@"location"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_GetFriendsLocationRequestTO


- (MCT_com_mobicage_to_location_GetFriendsLocationRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_GetFriendsLocationRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_location_GetFriendsLocationRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_GetFriendsLocationRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_location_GetFriendsLocationRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_GetFriendsLocationRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_GetFriendsLocationResponseTO

@synthesize locations = locations_;

- (MCT_com_mobicage_to_location_GetFriendsLocationResponseTO *)init
{
    if (self = [super init]) {
        self.locations = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_location_GetFriendsLocationResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"locations"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"locations"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"locations"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_location_FriendLocationTO *tmp_obj = [MCT_com_mobicage_to_location_FriendLocationTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"locations"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.locations = tmp_obj_array_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_location_GetFriendsLocationResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_GetFriendsLocationResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_location_GetFriendsLocationResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_GetFriendsLocationResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.locations == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_location_GetFriendsLocationResponseTO.locations");
    } else if ([self.locations isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.locations count]];
        for (MCT_com_mobicage_to_location_FriendLocationTO *obj in self.locations)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"locations"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_location_GetFriendsLocationResponseTO.locations");
    }

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_GetLocationErrorTO

@synthesize message = message_;
@synthesize status = status_;

- (MCT_com_mobicage_to_location_GetLocationErrorTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_GetLocationErrorTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_location_GetLocationErrorTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_GetLocationErrorTO alloc] init];
}

+ (MCT_com_mobicage_to_location_GetLocationErrorTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_GetLocationErrorTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.message forKey:@"message"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_GetLocationRequestTO

@synthesize friend = friend_;
@synthesize high_prio = high_prio_;
@synthesize target = target_;

- (MCT_com_mobicage_to_location_GetLocationRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_GetLocationRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.friend = [dict stringForKey:@"friend"];
        if (self.friend == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friend"];
        if (self.friend == MCTNull)
            self.friend = nil;

        if (![dict containsBoolObjectForKey:@"high_prio"])
            return [self errorDuringInitBecauseOfFieldWithName:@"high_prio"];
        self.high_prio = [dict boolForKey:@"high_prio"];

        if (![dict containsLongObjectForKey:@"target"])
            return [self errorDuringInitBecauseOfFieldWithName:@"target"];
        self.target = [dict longForKey:@"target"];

        return self;
    }
}

+ (MCT_com_mobicage_to_location_GetLocationRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_GetLocationRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_location_GetLocationRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_GetLocationRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.friend forKey:@"friend"];

    [dict setBool:self.high_prio forKey:@"high_prio"];

    [dict setLong:self.target forKey:@"target"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_GetLocationResponseTO

@synthesize error = error_;

- (MCT_com_mobicage_to_location_GetLocationResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_GetLocationResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"error"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"error"];
        if (tmp_dict_0 == MCTNull)
            self.error = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_location_GetLocationErrorTO *tmp_to_0 = [MCT_com_mobicage_to_location_GetLocationErrorTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"error"];
            self.error = (MCT_com_mobicage_to_location_GetLocationErrorTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_location_GetLocationResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_GetLocationResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_location_GetLocationResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_GetLocationResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.error dictRepresentation] forKey:@"error"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_LocationResultRequestTO

@synthesize location = location_;
@synthesize friend = friend_;

- (MCT_com_mobicage_to_location_LocationResultRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_LocationResultRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"location"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"location"];
        if (tmp_dict_0 == MCTNull)
            self.location = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *tmp_to_0 = [MCT_com_mobicage_to_activity_GeoPointWithTimestampTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"location"];
            self.location = (MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *)tmp_to_0;
        }

        self.friend = [dict stringForKey:@"friend"];
        if (self.friend == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friend"];
        if (self.friend == MCTNull)
            self.friend = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_location_LocationResultRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_LocationResultRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_location_LocationResultRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_LocationResultRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.location dictRepresentation] forKey:@"location"];

    [dict setString:self.friend forKey:@"friend"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_LocationResultResponseTO


- (MCT_com_mobicage_to_location_LocationResultResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_LocationResultResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_location_LocationResultResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_LocationResultResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_location_LocationResultResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_LocationResultResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_TrackLocationRequestTO

@synthesize distance_filter = distance_filter_;
@synthesize friend = friend_;
@synthesize high_prio = high_prio_;
@synthesize target = target_;
@synthesize until = until_;

- (MCT_com_mobicage_to_location_TrackLocationRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_TrackLocationRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"distance_filter"])
            return [self errorDuringInitBecauseOfFieldWithName:@"distance_filter"];
        self.distance_filter = [dict longForKey:@"distance_filter"];

        self.friend = [dict stringForKey:@"friend"];
        if (self.friend == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"friend"];
        if (self.friend == MCTNull)
            self.friend = nil;

        if (![dict containsBoolObjectForKey:@"high_prio"])
            return [self errorDuringInitBecauseOfFieldWithName:@"high_prio"];
        self.high_prio = [dict boolForKey:@"high_prio"];

        if (![dict containsLongObjectForKey:@"target"])
            return [self errorDuringInitBecauseOfFieldWithName:@"target"];
        self.target = [dict longForKey:@"target"];

        if (![dict containsLongObjectForKey:@"until"])
            return [self errorDuringInitBecauseOfFieldWithName:@"until"];
        self.until = [dict longForKey:@"until"];

        return self;
    }
}

+ (MCT_com_mobicage_to_location_TrackLocationRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_TrackLocationRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_location_TrackLocationRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_TrackLocationRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.distance_filter forKey:@"distance_filter"];

    [dict setString:self.friend forKey:@"friend"];

    [dict setBool:self.high_prio forKey:@"high_prio"];

    [dict setLong:self.target forKey:@"target"];

    [dict setLong:self.until forKey:@"until"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_location_TrackLocationResponseTO

@synthesize error = error_;

- (MCT_com_mobicage_to_location_TrackLocationResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_location_TrackLocationResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"error"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"error"];
        if (tmp_dict_0 == MCTNull)
            self.error = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_location_GetLocationErrorTO *tmp_to_0 = [MCT_com_mobicage_to_location_GetLocationErrorTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"error"];
            self.error = (MCT_com_mobicage_to_location_GetLocationErrorTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_location_TrackLocationResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_location_TrackLocationResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_location_TrackLocationResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_location_TrackLocationResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.error dictRepresentation] forKey:@"error"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_AckMessageRequestTO

@synthesize button_id = button_id_;
@synthesize custom_reply = custom_reply_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_AckMessageRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_AckMessageRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.custom_reply = [dict stringForKey:@"custom_reply"];
        if (self.custom_reply == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"custom_reply"];
        if (self.custom_reply == MCTNull)
            self.custom_reply = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_AckMessageRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_AckMessageRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_AckMessageRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_AckMessageRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.custom_reply forKey:@"custom_reply"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_AckMessageResponseTO

@synthesize result = result_;

- (MCT_com_mobicage_to_messaging_AckMessageResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_AckMessageResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"result"])
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        self.result = [dict longForKey:@"result"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_AckMessageResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_AckMessageResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_AckMessageResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_AckMessageResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.result forKey:@"result"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_AttachmentTO

@synthesize content_type = content_type_;
@synthesize download_url = download_url_;
@synthesize name = name_;
@synthesize size = size_;

- (MCT_com_mobicage_to_messaging_AttachmentTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_AttachmentTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.content_type = [dict stringForKey:@"content_type"];
        if (self.content_type == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"content_type"];
        if (self.content_type == MCTNull)
            self.content_type = nil;

        self.download_url = [dict stringForKey:@"download_url"];
        if (self.download_url == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"download_url"];
        if (self.download_url == MCTNull)
            self.download_url = nil;

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        if (![dict containsLongObjectForKey:@"size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"size"];
        self.size = [dict longForKey:@"size"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_AttachmentTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_AttachmentTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_AttachmentTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_AttachmentTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.content_type forKey:@"content_type"];

    [dict setString:self.download_url forKey:@"download_url"];

    [dict setString:self.name forKey:@"name"];

    [dict setLong:self.size forKey:@"size"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_ButtonTO

@synthesize action = action_;
@synthesize caption = caption_;
@synthesize idX = idX_;
@synthesize ui_flags = ui_flags_;

- (MCT_com_mobicage_to_messaging_ButtonTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_ButtonTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.action = [dict stringForKey:@"action"];
        if (self.action == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"action"];
        if (self.action == MCTNull)
            self.action = nil;

        self.caption = [dict stringForKey:@"caption"];
        if (self.caption == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"caption"];
        if (self.caption == MCTNull)
            self.caption = nil;

        self.idX = [dict stringForKey:@"id"];
        if (self.idX == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"id"];
        if (self.idX == MCTNull)
            self.idX = nil;

        self.ui_flags = [dict longForKey:@"ui_flags" withDefaultValue:0];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_ButtonTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_ButtonTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_ButtonTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_ButtonTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.action forKey:@"action"];

    [dict setString:self.caption forKey:@"caption"];

    [dict setString:self.idX forKey:@"id"];

    [dict setLong:self.ui_flags forKey:@"ui_flags"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_ConversationDeletedRequestTO

@synthesize parent_message_key = parent_message_key_;

- (MCT_com_mobicage_to_messaging_ConversationDeletedRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_ConversationDeletedRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_ConversationDeletedRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_ConversationDeletedRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_ConversationDeletedRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_ConversationDeletedRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_ConversationDeletedResponseTO


- (MCT_com_mobicage_to_messaging_ConversationDeletedResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_ConversationDeletedResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_ConversationDeletedResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_ConversationDeletedResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_ConversationDeletedResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_ConversationDeletedResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_DeleteConversationRequestTO

@synthesize parent_message_key = parent_message_key_;

- (MCT_com_mobicage_to_messaging_DeleteConversationRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_DeleteConversationRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_DeleteConversationRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_DeleteConversationRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_DeleteConversationRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_DeleteConversationRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_DeleteConversationResponseTO


- (MCT_com_mobicage_to_messaging_DeleteConversationResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_DeleteConversationResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_DeleteConversationResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_DeleteConversationResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_DeleteConversationResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_DeleteConversationResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_EndMessageFlowRequestTO

@synthesize message_flow_run_id = message_flow_run_id_;
@synthesize parent_message_key = parent_message_key_;
@synthesize wait_for_followup = wait_for_followup_;

- (MCT_com_mobicage_to_messaging_EndMessageFlowRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_EndMessageFlowRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.message_flow_run_id = [dict stringForKey:@"message_flow_run_id"];
        if (self.message_flow_run_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_flow_run_id"];
        if (self.message_flow_run_id == MCTNull)
            self.message_flow_run_id = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        self.wait_for_followup = [dict boolForKey:@"wait_for_followup" withDefaultValue:NO];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_EndMessageFlowRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_EndMessageFlowRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_EndMessageFlowRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_EndMessageFlowRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.message_flow_run_id forKey:@"message_flow_run_id"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setBool:self.wait_for_followup forKey:@"wait_for_followup"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_EndMessageFlowResponseTO


- (MCT_com_mobicage_to_messaging_EndMessageFlowResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_EndMessageFlowResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_EndMessageFlowResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_EndMessageFlowResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_EndMessageFlowResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_EndMessageFlowResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_GetConversationAvatarRequestTO

@synthesize avatar_hash = avatar_hash_;
@synthesize thread_key = thread_key_;

- (MCT_com_mobicage_to_messaging_GetConversationAvatarRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_GetConversationAvatarRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.avatar_hash = [dict stringForKey:@"avatar_hash"];
        if (self.avatar_hash == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar_hash"];
        if (self.avatar_hash == MCTNull)
            self.avatar_hash = nil;

        self.thread_key = [dict stringForKey:@"thread_key"];
        if (self.thread_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"thread_key"];
        if (self.thread_key == MCTNull)
            self.thread_key = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_GetConversationAvatarRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_GetConversationAvatarRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_GetConversationAvatarRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_GetConversationAvatarRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.avatar_hash forKey:@"avatar_hash"];

    [dict setString:self.thread_key forKey:@"thread_key"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_GetConversationAvatarResponseTO

@synthesize avatar = avatar_;

- (MCT_com_mobicage_to_messaging_GetConversationAvatarResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_GetConversationAvatarResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.avatar = [dict stringForKey:@"avatar"];
        if (self.avatar == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar"];
        if (self.avatar == MCTNull)
            self.avatar = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_GetConversationAvatarResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_GetConversationAvatarResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_GetConversationAvatarResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_GetConversationAvatarResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.avatar forKey:@"avatar"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_GetConversationRequestTO

@synthesize offset = offset_;
@synthesize parent_message_key = parent_message_key_;

- (MCT_com_mobicage_to_messaging_GetConversationRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_GetConversationRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.offset = [dict stringForKey:@"offset" withDefaultValue:nil];
        if (self.offset == MCTNull)
            self.offset = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_GetConversationRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_GetConversationRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_GetConversationRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_GetConversationRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.offset forKey:@"offset"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_GetConversationResponseTO

@synthesize conversation_sent = conversation_sent_;

- (MCT_com_mobicage_to_messaging_GetConversationResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_GetConversationResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsBoolObjectForKey:@"conversation_sent"])
            return [self errorDuringInitBecauseOfFieldWithName:@"conversation_sent"];
        self.conversation_sent = [dict boolForKey:@"conversation_sent"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_GetConversationResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_GetConversationResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_GetConversationResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_GetConversationResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setBool:self.conversation_sent forKey:@"conversation_sent"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_LockMessageRequestTO

@synthesize message_key = message_key_;
@synthesize message_parent_key = message_parent_key_;

- (MCT_com_mobicage_to_messaging_LockMessageRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_LockMessageRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.message_parent_key = [dict stringForKey:@"message_parent_key"];
        if (self.message_parent_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_parent_key"];
        if (self.message_parent_key == MCTNull)
            self.message_parent_key = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_LockMessageRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_LockMessageRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_LockMessageRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_LockMessageRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.message_parent_key forKey:@"message_parent_key"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_LockMessageResponseTO

@synthesize members = members_;

- (MCT_com_mobicage_to_messaging_LockMessageResponseTO *)init
{
    if (self = [super init]) {
        self.members = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_LockMessageResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"members"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"members"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"members"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_MemberStatusTO *tmp_obj = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"members"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.members = tmp_obj_array_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_LockMessageResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_LockMessageResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_LockMessageResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_LockMessageResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.members == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_LockMessageResponseTO.members");
    } else if ([self.members isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.members count]];
        for (MCT_com_mobicage_to_messaging_MemberStatusTO *obj in self.members)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"members"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_LockMessageResponseTO.members");
    }

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_MarkMessagesAsReadRequestTO

@synthesize message_keys = message_keys_;
@synthesize parent_message_key = parent_message_key_;

- (MCT_com_mobicage_to_messaging_MarkMessagesAsReadRequestTO *)init
{
    if (self = [super init]) {
        self.message_keys = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_MarkMessagesAsReadRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_unicode_array_0 = [dict arrayForKey:@"message_keys"];
        if (tmp_unicode_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_keys"];
        for (id obj in tmp_unicode_array_0) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"message_keys"];
        }
        self.message_keys = tmp_unicode_array_0;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_MarkMessagesAsReadRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_MarkMessagesAsReadRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_MarkMessagesAsReadRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_MarkMessagesAsReadRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.message_keys forKey:@"message_keys"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_MarkMessagesAsReadResponseTO


- (MCT_com_mobicage_to_messaging_MarkMessagesAsReadResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_MarkMessagesAsReadResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_MarkMessagesAsReadResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_MarkMessagesAsReadResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_MarkMessagesAsReadResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_MarkMessagesAsReadResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_MemberStatusTO

@synthesize acked_timestamp = acked_timestamp_;
@synthesize button_id = button_id_;
@synthesize custom_reply = custom_reply_;
@synthesize member = member_;
@synthesize received_timestamp = received_timestamp_;
@synthesize status = status_;

- (MCT_com_mobicage_to_messaging_MemberStatusTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_MemberStatusTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"acked_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"acked_timestamp"];
        self.acked_timestamp = [dict longForKey:@"acked_timestamp"];

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.custom_reply = [dict stringForKey:@"custom_reply"];
        if (self.custom_reply == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"custom_reply"];
        if (self.custom_reply == MCTNull)
            self.custom_reply = nil;

        self.member = [dict stringForKey:@"member"];
        if (self.member == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"member"];
        if (self.member == MCTNull)
            self.member = nil;

        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_MemberStatusTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_MemberStatusTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_MemberStatusTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_MemberStatusTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.acked_timestamp forKey:@"acked_timestamp"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.custom_reply forKey:@"custom_reply"];

    [dict setString:self.member forKey:@"member"];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO

@synthesize acked_timestamp = acked_timestamp_;
@synthesize button_id = button_id_;
@synthesize custom_reply = custom_reply_;
@synthesize flags = flags_;
@synthesize member = member_;
@synthesize message = message_;
@synthesize parent_message = parent_message_;
@synthesize received_timestamp = received_timestamp_;
@synthesize status = status_;

- (MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"acked_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"acked_timestamp"];
        self.acked_timestamp = [dict longForKey:@"acked_timestamp"];

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.custom_reply = [dict stringForKey:@"custom_reply"];
        if (self.custom_reply == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"custom_reply"];
        if (self.custom_reply == MCTNull)
            self.custom_reply = nil;

        self.flags = [dict longForKey:@"flags" withDefaultValue:-1];

        self.member = [dict stringForKey:@"member"];
        if (self.member == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"member"];
        if (self.member == MCTNull)
            self.member = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        self.parent_message = [dict stringForKey:@"parent_message"];
        if (self.parent_message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message"];
        if (self.parent_message == MCTNull)
            self.parent_message = nil;

        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_MemberStatusUpdateRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.acked_timestamp forKey:@"acked_timestamp"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.custom_reply forKey:@"custom_reply"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setString:self.member forKey:@"member"];

    [dict setString:self.message forKey:@"message"];

    [dict setString:self.parent_message forKey:@"parent_message"];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_MemberStatusUpdateResponseTO


- (MCT_com_mobicage_to_messaging_MemberStatusUpdateResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_MemberStatusUpdateResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_MemberStatusUpdateResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_MemberStatusUpdateResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_MemberStatusUpdateResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_MemberStatusUpdateResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_MessageLockedRequestTO

@synthesize members = members_;
@synthesize dirty_behavior = dirty_behavior_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;

- (MCT_com_mobicage_to_messaging_MessageLockedRequestTO *)init
{
    if (self = [super init]) {
        self.members = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_MessageLockedRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"members"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"members"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"members"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_MemberStatusTO *tmp_obj = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"members"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.members = tmp_obj_array_0;
        }

        if (![dict containsLongObjectForKey:@"dirty_behavior"])
            return [self errorDuringInitBecauseOfFieldWithName:@"dirty_behavior"];
        self.dirty_behavior = [dict longForKey:@"dirty_behavior"];

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_MessageLockedRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_MessageLockedRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_MessageLockedRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_MessageLockedRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.members == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_MessageLockedRequestTO.members");
    } else if ([self.members isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.members count]];
        for (MCT_com_mobicage_to_messaging_MemberStatusTO *obj in self.members)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"members"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_MessageLockedRequestTO.members");
    }

    [dict setLong:self.dirty_behavior forKey:@"dirty_behavior"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_MessageLockedResponseTO


- (MCT_com_mobicage_to_messaging_MessageLockedResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_MessageLockedResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_MessageLockedResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_MessageLockedResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_MessageLockedResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_MessageLockedResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_MessageTO

@synthesize attachments = attachments_;
@synthesize buttons = buttons_;
@synthesize members = members_;
@synthesize alert_flags = alert_flags_;
@synthesize branding = branding_;
@synthesize broadcast_type = broadcast_type_;
@synthesize context = context_;
@synthesize default_priority = default_priority_;
@synthesize default_sticky = default_sticky_;
@synthesize dismiss_button_ui_flags = dismiss_button_ui_flags_;
@synthesize flags = flags_;
@synthesize key = key_;
@synthesize message = message_;
@synthesize message_type = message_type_;
@synthesize parent_key = parent_key_;
@synthesize priority = priority_;
@synthesize sender = sender_;
@synthesize threadTimestamp = threadTimestamp_;
@synthesize thread_avatar_hash = thread_avatar_hash_;
@synthesize thread_background_color = thread_background_color_;
@synthesize thread_size = thread_size_;
@synthesize thread_text_color = thread_text_color_;
@synthesize timeout = timeout_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_MessageTO *)init
{
    if (self = [super init]) {
        self.attachments = [NSMutableArray array];
        self.buttons = [NSMutableArray array];
        self.members = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_MessageTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"attachments" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
        if (tmp_dict_array_0 != nil) {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_AttachmentTO *tmp_obj = [MCT_com_mobicage_to_messaging_AttachmentTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.attachments = tmp_obj_array_0;
        }

        NSArray *tmp_dict_array_1 = [dict arrayForKey:@"buttons"];
        if (tmp_dict_array_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"buttons"];
        if (tmp_dict_array_1 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"buttons"];
        else {
            NSMutableArray *tmp_obj_array_1 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_1 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_1) {
                MCT_com_mobicage_to_messaging_ButtonTO *tmp_obj = [MCT_com_mobicage_to_messaging_ButtonTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"buttons"];
                [tmp_obj_array_1 addObject:tmp_obj];
            }
            self.buttons = tmp_obj_array_1;
        }

        NSArray *tmp_dict_array_2 = [dict arrayForKey:@"members"];
        if (tmp_dict_array_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"members"];
        if (tmp_dict_array_2 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"members"];
        else {
            NSMutableArray *tmp_obj_array_2 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_2 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_2) {
                MCT_com_mobicage_to_messaging_MemberStatusTO *tmp_obj = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"members"];
                [tmp_obj_array_2 addObject:tmp_obj];
            }
            self.members = tmp_obj_array_2;
        }

        if (![dict containsLongObjectForKey:@"alert_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"alert_flags"];
        self.alert_flags = [dict longForKey:@"alert_flags"];

        self.branding = [dict stringForKey:@"branding"];
        if (self.branding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"branding"];
        if (self.branding == MCTNull)
            self.branding = nil;

        self.broadcast_type = [dict stringForKey:@"broadcast_type" withDefaultValue:nil];
        if (self.broadcast_type == MCTNull)
            self.broadcast_type = nil;

        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        self.default_priority = [dict longForKey:@"default_priority" withDefaultValue:1];

        self.default_sticky = [dict boolForKey:@"default_sticky" withDefaultValue:NO];

        self.dismiss_button_ui_flags = [dict longForKey:@"dismiss_button_ui_flags" withDefaultValue:0];

        if (![dict containsLongObjectForKey:@"flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flags"];
        self.flags = [dict longForKey:@"flags"];

        self.key = [dict stringForKey:@"key"];
        if (self.key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"key"];
        if (self.key == MCTNull)
            self.key = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        if (![dict containsLongObjectForKey:@"message_type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"message_type"];
        self.message_type = [dict longForKey:@"message_type"];

        self.parent_key = [dict stringForKey:@"parent_key"];
        if (self.parent_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_key"];
        if (self.parent_key == MCTNull)
            self.parent_key = nil;

        self.priority = [dict longForKey:@"priority" withDefaultValue:1];

        self.sender = [dict stringForKey:@"sender"];
        if (self.sender == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"sender"];
        if (self.sender == MCTNull)
            self.sender = nil;

        if (![dict containsLongObjectForKey:@"threadTimestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"threadTimestamp"];
        self.threadTimestamp = [dict longForKey:@"threadTimestamp"];

        self.thread_avatar_hash = [dict stringForKey:@"thread_avatar_hash" withDefaultValue:nil];
        if (self.thread_avatar_hash == MCTNull)
            self.thread_avatar_hash = nil;

        self.thread_background_color = [dict stringForKey:@"thread_background_color" withDefaultValue:nil];
        if (self.thread_background_color == MCTNull)
            self.thread_background_color = nil;

        if (![dict containsLongObjectForKey:@"thread_size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"thread_size"];
        self.thread_size = [dict longForKey:@"thread_size"];

        self.thread_text_color = [dict stringForKey:@"thread_text_color" withDefaultValue:nil];
        if (self.thread_text_color == MCTNull)
            self.thread_text_color = nil;

        if (![dict containsLongObjectForKey:@"timeout"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timeout"];
        self.timeout = [dict longForKey:@"timeout"];

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_MessageTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_MessageTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_MessageTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_MessageTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.attachments == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_MessageTO.attachments");
    } else if ([self.attachments isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.attachments count]];
        for (MCT_com_mobicage_to_messaging_AttachmentTO *obj in self.attachments)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"attachments"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_MessageTO.attachments");
    }

    if (self.buttons == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_MessageTO.buttons");
    } else if ([self.buttons isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.buttons count]];
        for (MCT_com_mobicage_to_messaging_ButtonTO *obj in self.buttons)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"buttons"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_MessageTO.buttons");
    }

    if (self.members == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_MessageTO.members");
    } else if ([self.members isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.members count]];
        for (MCT_com_mobicage_to_messaging_MemberStatusTO *obj in self.members)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"members"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_MessageTO.members");
    }

    [dict setLong:self.alert_flags forKey:@"alert_flags"];

    [dict setString:self.branding forKey:@"branding"];

    [dict setString:self.broadcast_type forKey:@"broadcast_type"];

    [dict setString:self.context forKey:@"context"];

    [dict setLong:self.default_priority forKey:@"default_priority"];

    [dict setBool:self.default_sticky forKey:@"default_sticky"];

    [dict setLong:self.dismiss_button_ui_flags forKey:@"dismiss_button_ui_flags"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setString:self.key forKey:@"key"];

    [dict setString:self.message forKey:@"message"];

    [dict setLong:self.message_type forKey:@"message_type"];

    [dict setString:self.parent_key forKey:@"parent_key"];

    [dict setLong:self.priority forKey:@"priority"];

    [dict setString:self.sender forKey:@"sender"];

    [dict setLong:self.threadTimestamp forKey:@"threadTimestamp"];

    [dict setString:self.thread_avatar_hash forKey:@"thread_avatar_hash"];

    [dict setString:self.thread_background_color forKey:@"thread_background_color"];

    [dict setLong:self.thread_size forKey:@"thread_size"];

    [dict setString:self.thread_text_color forKey:@"thread_text_color"];

    [dict setLong:self.timeout forKey:@"timeout"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_NewMessageRequestTO

@synthesize message = message_;

- (MCT_com_mobicage_to_messaging_NewMessageRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_NewMessageRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"message"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (tmp_dict_0 == MCTNull)
            self.message = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_MessageTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_MessageTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"message"];
            self.message = (MCT_com_mobicage_to_messaging_MessageTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_NewMessageRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_NewMessageRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_NewMessageRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_NewMessageRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.message dictRepresentation] forKey:@"message"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_NewMessageResponseTO

@synthesize received_timestamp = received_timestamp_;

- (MCT_com_mobicage_to_messaging_NewMessageResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_NewMessageResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_NewMessageResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_NewMessageResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_NewMessageResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_NewMessageResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_SendMessageRequestTO

@synthesize attachments = attachments_;
@synthesize buttons = buttons_;
@synthesize flags = flags_;
@synthesize members = members_;
@synthesize message = message_;
@synthesize parent_key = parent_key_;
@synthesize priority = priority_;
@synthesize sender_reply = sender_reply_;
@synthesize timeout = timeout_;

- (MCT_com_mobicage_to_messaging_SendMessageRequestTO *)init
{
    if (self = [super init]) {
        self.attachments = [NSMutableArray array];
        self.buttons = [NSMutableArray array];
        self.members = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_SendMessageRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"attachments" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
        if (tmp_dict_array_0 != nil) {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_AttachmentTO *tmp_obj = [MCT_com_mobicage_to_messaging_AttachmentTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.attachments = tmp_obj_array_0;
        }

        NSArray *tmp_dict_array_1 = [dict arrayForKey:@"buttons"];
        if (tmp_dict_array_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"buttons"];
        if (tmp_dict_array_1 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"buttons"];
        else {
            NSMutableArray *tmp_obj_array_1 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_1 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_1) {
                MCT_com_mobicage_to_messaging_ButtonTO *tmp_obj = [MCT_com_mobicage_to_messaging_ButtonTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"buttons"];
                [tmp_obj_array_1 addObject:tmp_obj];
            }
            self.buttons = tmp_obj_array_1;
        }

        if (![dict containsLongObjectForKey:@"flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flags"];
        self.flags = [dict longForKey:@"flags"];

        NSArray *tmp_unicode_array_3 = [dict arrayForKey:@"members"];
        if (tmp_unicode_array_3 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"members"];
        for (id obj in tmp_unicode_array_3) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"members"];
        }
        self.members = tmp_unicode_array_3;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        self.parent_key = [dict stringForKey:@"parent_key"];
        if (self.parent_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_key"];
        if (self.parent_key == MCTNull)
            self.parent_key = nil;

        if (![dict containsLongObjectForKey:@"priority"])
            return [self errorDuringInitBecauseOfFieldWithName:@"priority"];
        self.priority = [dict longForKey:@"priority"];

        self.sender_reply = [dict stringForKey:@"sender_reply"];
        if (self.sender_reply == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"sender_reply"];
        if (self.sender_reply == MCTNull)
            self.sender_reply = nil;

        if (![dict containsLongObjectForKey:@"timeout"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timeout"];
        self.timeout = [dict longForKey:@"timeout"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_SendMessageRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_SendMessageRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_SendMessageRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_SendMessageRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.attachments == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_SendMessageRequestTO.attachments");
    } else if ([self.attachments isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.attachments count]];
        for (MCT_com_mobicage_to_messaging_AttachmentTO *obj in self.attachments)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"attachments"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_SendMessageRequestTO.attachments");
    }

    if (self.buttons == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_SendMessageRequestTO.buttons");
    } else if ([self.buttons isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.buttons count]];
        for (MCT_com_mobicage_to_messaging_ButtonTO *obj in self.buttons)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"buttons"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_SendMessageRequestTO.buttons");
    }

    [dict setLong:self.flags forKey:@"flags"];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.members forKey:@"members"];

    [dict setString:self.message forKey:@"message"];

    [dict setString:self.parent_key forKey:@"parent_key"];

    [dict setLong:self.priority forKey:@"priority"];

    [dict setString:self.sender_reply forKey:@"sender_reply"];

    [dict setLong:self.timeout forKey:@"timeout"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_SendMessageResponseTO

@synthesize key = key_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_SendMessageResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_SendMessageResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.key = [dict stringForKey:@"key"];
        if (self.key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"key"];
        if (self.key == MCTNull)
            self.key = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_SendMessageResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_SendMessageResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_SendMessageResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_SendMessageResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.key forKey:@"key"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_StartFlowRequestTO

@synthesize attachments_to_dwnl = attachments_to_dwnl_;
@synthesize brandings_to_dwnl = brandings_to_dwnl_;
@synthesize message_flow_run_id = message_flow_run_id_;
@synthesize parent_message_key = parent_message_key_;
@synthesize service = service_;
@synthesize static_flow = static_flow_;
@synthesize static_flow_hash = static_flow_hash_;

- (MCT_com_mobicage_to_messaging_StartFlowRequestTO *)init
{
    if (self = [super init]) {
        self.attachments_to_dwnl = [NSMutableArray array];
        self.brandings_to_dwnl = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_StartFlowRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_unicode_array_0 = [dict arrayForKey:@"attachments_to_dwnl"];
        if (tmp_unicode_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"attachments_to_dwnl"];
        for (id obj in tmp_unicode_array_0) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"attachments_to_dwnl"];
        }
        self.attachments_to_dwnl = tmp_unicode_array_0;

        NSArray *tmp_unicode_array_1 = [dict arrayForKey:@"brandings_to_dwnl"];
        if (tmp_unicode_array_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"brandings_to_dwnl"];
        for (id obj in tmp_unicode_array_1) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"brandings_to_dwnl"];
        }
        self.brandings_to_dwnl = tmp_unicode_array_1;

        self.message_flow_run_id = [dict stringForKey:@"message_flow_run_id"];
        if (self.message_flow_run_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_flow_run_id"];
        if (self.message_flow_run_id == MCTNull)
            self.message_flow_run_id = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        self.service = [dict stringForKey:@"service"];
        if (self.service == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"service"];
        if (self.service == MCTNull)
            self.service = nil;

        self.static_flow = [dict stringForKey:@"static_flow"];
        if (self.static_flow == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"static_flow"];
        if (self.static_flow == MCTNull)
            self.static_flow = nil;

        self.static_flow_hash = [dict stringForKey:@"static_flow_hash"];
        if (self.static_flow_hash == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"static_flow_hash"];
        if (self.static_flow_hash == MCTNull)
            self.static_flow_hash = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_StartFlowRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_StartFlowRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_StartFlowRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_StartFlowRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.attachments_to_dwnl forKey:@"attachments_to_dwnl"];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.brandings_to_dwnl forKey:@"brandings_to_dwnl"];

    [dict setString:self.message_flow_run_id forKey:@"message_flow_run_id"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setString:self.service forKey:@"service"];

    [dict setString:self.static_flow forKey:@"static_flow"];

    [dict setString:self.static_flow_hash forKey:@"static_flow_hash"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_StartFlowResponseTO


- (MCT_com_mobicage_to_messaging_StartFlowResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_StartFlowResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_StartFlowResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_StartFlowResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_StartFlowResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_StartFlowResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_TransferCompletedRequestTO

@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize result_url = result_url_;

- (MCT_com_mobicage_to_messaging_TransferCompletedRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_TransferCompletedRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        self.result_url = [dict stringForKey:@"result_url"];
        if (self.result_url == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result_url"];
        if (self.result_url == MCTNull)
            self.result_url = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_TransferCompletedRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_TransferCompletedRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_TransferCompletedRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_TransferCompletedRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setString:self.result_url forKey:@"result_url"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_TransferCompletedResponseTO


- (MCT_com_mobicage_to_messaging_TransferCompletedResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_TransferCompletedResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_TransferCompletedResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_TransferCompletedResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_TransferCompletedResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_TransferCompletedResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_UpdateMessageRequestTO

@synthesize existence = existence_;
@synthesize flags = flags_;
@synthesize has_existence = has_existence_;
@synthesize has_flags = has_flags_;
@synthesize last_child_message = last_child_message_;
@synthesize message = message_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize thread_avatar_hash = thread_avatar_hash_;
@synthesize thread_background_color = thread_background_color_;
@synthesize thread_text_color = thread_text_color_;

- (MCT_com_mobicage_to_messaging_UpdateMessageRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_UpdateMessageRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"existence"])
            return [self errorDuringInitBecauseOfFieldWithName:@"existence"];
        self.existence = [dict longForKey:@"existence"];

        if (![dict containsLongObjectForKey:@"flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flags"];
        self.flags = [dict longForKey:@"flags"];

        if (![dict containsBoolObjectForKey:@"has_existence"])
            return [self errorDuringInitBecauseOfFieldWithName:@"has_existence"];
        self.has_existence = [dict boolForKey:@"has_existence"];

        if (![dict containsBoolObjectForKey:@"has_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"has_flags"];
        self.has_flags = [dict boolForKey:@"has_flags"];

        self.last_child_message = [dict stringForKey:@"last_child_message"];
        if (self.last_child_message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"last_child_message"];
        if (self.last_child_message == MCTNull)
            self.last_child_message = nil;

        self.message = [dict stringForKey:@"message" withDefaultValue:nil];
        if (self.message == MCTNull)
            self.message = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        self.thread_avatar_hash = [dict stringForKey:@"thread_avatar_hash" withDefaultValue:nil];
        if (self.thread_avatar_hash == MCTNull)
            self.thread_avatar_hash = nil;

        self.thread_background_color = [dict stringForKey:@"thread_background_color" withDefaultValue:nil];
        if (self.thread_background_color == MCTNull)
            self.thread_background_color = nil;

        self.thread_text_color = [dict stringForKey:@"thread_text_color" withDefaultValue:nil];
        if (self.thread_text_color == MCTNull)
            self.thread_text_color = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_UpdateMessageRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_UpdateMessageRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_UpdateMessageRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_UpdateMessageRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.existence forKey:@"existence"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setBool:self.has_existence forKey:@"has_existence"];

    [dict setBool:self.has_flags forKey:@"has_flags"];

    [dict setString:self.last_child_message forKey:@"last_child_message"];

    [dict setString:self.message forKey:@"message"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setString:self.thread_avatar_hash forKey:@"thread_avatar_hash"];

    [dict setString:self.thread_background_color forKey:@"thread_background_color"];

    [dict setString:self.thread_text_color forKey:@"thread_text_color"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_UpdateMessageResponseTO


- (MCT_com_mobicage_to_messaging_UpdateMessageResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_UpdateMessageResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_UpdateMessageResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_UpdateMessageResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_UpdateMessageResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_UpdateMessageResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_UploadChunkRequestTO

@synthesize chunk = chunk_;
@synthesize content_type = content_type_;
@synthesize message_key = message_key_;
@synthesize number = number_;
@synthesize parent_message_key = parent_message_key_;
@synthesize photo_hash = photo_hash_;
@synthesize service_identity_user = service_identity_user_;
@synthesize total_chunks = total_chunks_;

- (MCT_com_mobicage_to_messaging_UploadChunkRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_UploadChunkRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.chunk = [dict stringForKey:@"chunk"];
        if (self.chunk == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"chunk"];
        if (self.chunk == MCTNull)
            self.chunk = nil;

        self.content_type = [dict stringForKey:@"content_type"];
        if (self.content_type == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"content_type"];
        if (self.content_type == MCTNull)
            self.content_type = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        if (![dict containsLongObjectForKey:@"number"])
            return [self errorDuringInitBecauseOfFieldWithName:@"number"];
        self.number = [dict longForKey:@"number"];

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        self.photo_hash = [dict stringForKey:@"photo_hash"];
        if (self.photo_hash == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"photo_hash"];
        if (self.photo_hash == MCTNull)
            self.photo_hash = nil;

        self.service_identity_user = [dict stringForKey:@"service_identity_user"];
        if (self.service_identity_user == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"service_identity_user"];
        if (self.service_identity_user == MCTNull)
            self.service_identity_user = nil;

        if (![dict containsLongObjectForKey:@"total_chunks"])
            return [self errorDuringInitBecauseOfFieldWithName:@"total_chunks"];
        self.total_chunks = [dict longForKey:@"total_chunks"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_UploadChunkRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_UploadChunkRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_UploadChunkRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_UploadChunkRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.chunk forKey:@"chunk"];

    [dict setString:self.content_type forKey:@"content_type"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setLong:self.number forKey:@"number"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setString:self.photo_hash forKey:@"photo_hash"];

    [dict setString:self.service_identity_user forKey:@"service_identity_user"];

    [dict setLong:self.total_chunks forKey:@"total_chunks"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_UploadChunkResponseTO


- (MCT_com_mobicage_to_messaging_UploadChunkResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_UploadChunkResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_UploadChunkResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_UploadChunkResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_UploadChunkResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_UploadChunkResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO

@synthesize attachments = attachments_;
@synthesize form = form_;
@synthesize member = member_;
@synthesize alert_flags = alert_flags_;
@synthesize branding = branding_;
@synthesize broadcast_type = broadcast_type_;
@synthesize context = context_;
@synthesize default_priority = default_priority_;
@synthesize default_sticky = default_sticky_;
@synthesize flags = flags_;
@synthesize key = key_;
@synthesize message = message_;
@synthesize message_type = message_type_;
@synthesize parent_key = parent_key_;
@synthesize priority = priority_;
@synthesize sender = sender_;
@synthesize threadTimestamp = threadTimestamp_;
@synthesize thread_avatar_hash = thread_avatar_hash_;
@synthesize thread_background_color = thread_background_color_;
@synthesize thread_size = thread_size_;
@synthesize thread_text_color = thread_text_color_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO *)init
{
    if (self = [super init]) {
        self.attachments = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"attachments" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
        if (tmp_dict_array_0 != nil) {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_AttachmentTO *tmp_obj = [MCT_com_mobicage_to_messaging_AttachmentTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.attachments = tmp_obj_array_0;
        }

        NSDictionary *tmp_dict_1 = [dict dictForKey:@"form"];
        if (tmp_dict_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form"];
        if (tmp_dict_1 == MCTNull)
            self.form = nil;
        else if (tmp_dict_1 != nil) {
            MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormTO *tmp_to_1 = [MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormTO transferObjectWithDict:tmp_dict_1];
            if (tmp_to_1 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form"];
            self.form = (MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormTO *)tmp_to_1;
        }

        NSDictionary *tmp_dict_2 = [dict dictForKey:@"member"];
        if (tmp_dict_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"member"];
        if (tmp_dict_2 == MCTNull)
            self.member = nil;
        else if (tmp_dict_2 != nil) {
            MCT_com_mobicage_to_messaging_MemberStatusTO *tmp_to_2 = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObjectWithDict:tmp_dict_2];
            if (tmp_to_2 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"member"];
            self.member = (MCT_com_mobicage_to_messaging_MemberStatusTO *)tmp_to_2;
        }

        if (![dict containsLongObjectForKey:@"alert_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"alert_flags"];
        self.alert_flags = [dict longForKey:@"alert_flags"];

        self.branding = [dict stringForKey:@"branding"];
        if (self.branding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"branding"];
        if (self.branding == MCTNull)
            self.branding = nil;

        self.broadcast_type = [dict stringForKey:@"broadcast_type" withDefaultValue:nil];
        if (self.broadcast_type == MCTNull)
            self.broadcast_type = nil;

        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        self.default_priority = [dict longForKey:@"default_priority" withDefaultValue:1];

        self.default_sticky = [dict boolForKey:@"default_sticky" withDefaultValue:NO];

        if (![dict containsLongObjectForKey:@"flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flags"];
        self.flags = [dict longForKey:@"flags"];

        self.key = [dict stringForKey:@"key"];
        if (self.key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"key"];
        if (self.key == MCTNull)
            self.key = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        if (![dict containsLongObjectForKey:@"message_type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"message_type"];
        self.message_type = [dict longForKey:@"message_type"];

        self.parent_key = [dict stringForKey:@"parent_key"];
        if (self.parent_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_key"];
        if (self.parent_key == MCTNull)
            self.parent_key = nil;

        self.priority = [dict longForKey:@"priority" withDefaultValue:1];

        self.sender = [dict stringForKey:@"sender"];
        if (self.sender == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"sender"];
        if (self.sender == MCTNull)
            self.sender = nil;

        if (![dict containsLongObjectForKey:@"threadTimestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"threadTimestamp"];
        self.threadTimestamp = [dict longForKey:@"threadTimestamp"];

        self.thread_avatar_hash = [dict stringForKey:@"thread_avatar_hash" withDefaultValue:nil];
        if (self.thread_avatar_hash == MCTNull)
            self.thread_avatar_hash = nil;

        self.thread_background_color = [dict stringForKey:@"thread_background_color" withDefaultValue:nil];
        if (self.thread_background_color == MCTNull)
            self.thread_background_color = nil;

        if (![dict containsLongObjectForKey:@"thread_size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"thread_size"];
        self.thread_size = [dict longForKey:@"thread_size"];

        self.thread_text_color = [dict stringForKey:@"thread_text_color" withDefaultValue:nil];
        if (self.thread_text_color == MCTNull)
            self.thread_text_color = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.attachments == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO.attachments");
    } else if ([self.attachments isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.attachments count]];
        for (MCT_com_mobicage_to_messaging_AttachmentTO *obj in self.attachments)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"attachments"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO.attachments");
    }

    [dict setDict:[self.form dictRepresentation] forKey:@"form"];

    [dict setDict:[self.member dictRepresentation] forKey:@"member"];

    [dict setLong:self.alert_flags forKey:@"alert_flags"];

    [dict setString:self.branding forKey:@"branding"];

    [dict setString:self.broadcast_type forKey:@"broadcast_type"];

    [dict setString:self.context forKey:@"context"];

    [dict setLong:self.default_priority forKey:@"default_priority"];

    [dict setBool:self.default_sticky forKey:@"default_sticky"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setString:self.key forKey:@"key"];

    [dict setString:self.message forKey:@"message"];

    [dict setLong:self.message_type forKey:@"message_type"];

    [dict setString:self.parent_key forKey:@"parent_key"];

    [dict setLong:self.priority forKey:@"priority"];

    [dict setString:self.sender forKey:@"sender"];

    [dict setLong:self.threadTimestamp forKey:@"threadTimestamp"];

    [dict setString:self.thread_avatar_hash forKey:@"thread_avatar_hash"];

    [dict setString:self.thread_background_color forKey:@"thread_background_color"];

    [dict setLong:self.thread_size forKey:@"thread_size"];

    [dict setString:self.thread_text_color forKey:@"thread_text_color"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormTO

@synthesize widget = widget_;
@synthesize javascript_validation = javascript_validation_;
@synthesize negative_button = negative_button_;
@synthesize negative_button_ui_flags = negative_button_ui_flags_;
@synthesize negative_confirmation = negative_confirmation_;
@synthesize positive_button = positive_button_;
@synthesize positive_button_ui_flags = positive_button_ui_flags_;
@synthesize positive_confirmation = positive_confirmation_;
@synthesize type = type_;

- (MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"widget"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
        if (tmp_dict_0 == MCTNull)
            self.widget = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
            self.widget = (MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO *)tmp_to_0;
        }

        self.javascript_validation = [dict stringForKey:@"javascript_validation" withDefaultValue:nil];
        if (self.javascript_validation == MCTNull)
            self.javascript_validation = nil;

        self.negative_button = [dict stringForKey:@"negative_button"];
        if (self.negative_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button"];
        if (self.negative_button == MCTNull)
            self.negative_button = nil;

        if (![dict containsLongObjectForKey:@"negative_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button_ui_flags"];
        self.negative_button_ui_flags = [dict longForKey:@"negative_button_ui_flags"];

        self.negative_confirmation = [dict stringForKey:@"negative_confirmation"];
        if (self.negative_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_confirmation"];
        if (self.negative_confirmation == MCTNull)
            self.negative_confirmation = nil;

        self.positive_button = [dict stringForKey:@"positive_button"];
        if (self.positive_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button"];
        if (self.positive_button == MCTNull)
            self.positive_button = nil;

        if (![dict containsLongObjectForKey:@"positive_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button_ui_flags"];
        self.positive_button_ui_flags = [dict longForKey:@"positive_button_ui_flags"];

        self.positive_confirmation = [dict stringForKey:@"positive_confirmation"];
        if (self.positive_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_confirmation"];
        if (self.positive_confirmation == MCTNull)
            self.positive_confirmation = nil;

        self.type = [dict stringForKey:@"type"];
        if (self.type == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        if (self.type == MCTNull)
            self.type = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.widget dictRepresentation] forKey:@"widget"];

    [dict setString:self.javascript_validation forKey:@"javascript_validation"];

    [dict setString:self.negative_button forKey:@"negative_button"];

    [dict setLong:self.negative_button_ui_flags forKey:@"negative_button_ui_flags"];

    [dict setString:self.negative_confirmation forKey:@"negative_confirmation"];

    [dict setString:self.positive_button forKey:@"positive_button"];

    [dict setLong:self.positive_button_ui_flags forKey:@"positive_button_ui_flags"];

    [dict setString:self.positive_confirmation forKey:@"positive_confirmation"];

    [dict setString:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO

@synthesize categories = categories_;
@synthesize currency = currency_;
@synthesize leap_time = leap_time_;

- (MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO *)init
{
    if (self = [super init]) {
        self.categories = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"categories"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"categories"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"categories"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *tmp_obj = [MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"categories"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.categories = tmp_obj_array_0;
        }

        self.currency = [dict stringForKey:@"currency"];
        if (self.currency == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"currency"];
        if (self.currency == MCTNull)
            self.currency = nil;

        if (![dict containsLongObjectForKey:@"leap_time"])
            return [self errorDuringInitBecauseOfFieldWithName:@"leap_time"];
        self.leap_time = [dict longForKey:@"leap_time"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.categories == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO.categories");
    } else if ([self.categories isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.categories count]];
        for (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *obj in self.categories)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"categories"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_AdvancedOrderTO.categories");
    }

    [dict setString:self.currency forKey:@"currency"];

    [dict setLong:self.leap_time forKey:@"leap_time"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO

@synthesize categories = categories_;
@synthesize currency = currency_;

- (MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *)init
{
    if (self = [super init]) {
        self.categories = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"categories"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"categories"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"categories"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *tmp_obj = [MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"categories"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.categories = tmp_obj_array_0;
        }

        self.currency = [dict stringForKey:@"currency"];
        if (self.currency == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"currency"];
        if (self.currency == MCTNull)
            self.currency = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.categories == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO.categories");
    } else if ([self.categories isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.categories count]];
        for (MCT_com_mobicage_models_properties_forms_AdvancedOrderCategory *obj in self.categories)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"categories"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO.categories");
    }

    [dict setString:self.currency forKey:@"currency"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO

@synthesize attachments = attachments_;
@synthesize form = form_;
@synthesize member = member_;
@synthesize alert_flags = alert_flags_;
@synthesize branding = branding_;
@synthesize broadcast_type = broadcast_type_;
@synthesize context = context_;
@synthesize default_priority = default_priority_;
@synthesize default_sticky = default_sticky_;
@synthesize flags = flags_;
@synthesize key = key_;
@synthesize message = message_;
@synthesize message_type = message_type_;
@synthesize parent_key = parent_key_;
@synthesize priority = priority_;
@synthesize sender = sender_;
@synthesize threadTimestamp = threadTimestamp_;
@synthesize thread_avatar_hash = thread_avatar_hash_;
@synthesize thread_background_color = thread_background_color_;
@synthesize thread_size = thread_size_;
@synthesize thread_text_color = thread_text_color_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO *)init
{
    if (self = [super init]) {
        self.attachments = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"attachments" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
        if (tmp_dict_array_0 != nil) {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_AttachmentTO *tmp_obj = [MCT_com_mobicage_to_messaging_AttachmentTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.attachments = tmp_obj_array_0;
        }

        NSDictionary *tmp_dict_1 = [dict dictForKey:@"form"];
        if (tmp_dict_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form"];
        if (tmp_dict_1 == MCTNull)
            self.form = nil;
        else if (tmp_dict_1 != nil) {
            MCT_com_mobicage_to_messaging_forms_AutoCompleteFormTO *tmp_to_1 = [MCT_com_mobicage_to_messaging_forms_AutoCompleteFormTO transferObjectWithDict:tmp_dict_1];
            if (tmp_to_1 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form"];
            self.form = (MCT_com_mobicage_to_messaging_forms_AutoCompleteFormTO *)tmp_to_1;
        }

        NSDictionary *tmp_dict_2 = [dict dictForKey:@"member"];
        if (tmp_dict_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"member"];
        if (tmp_dict_2 == MCTNull)
            self.member = nil;
        else if (tmp_dict_2 != nil) {
            MCT_com_mobicage_to_messaging_MemberStatusTO *tmp_to_2 = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObjectWithDict:tmp_dict_2];
            if (tmp_to_2 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"member"];
            self.member = (MCT_com_mobicage_to_messaging_MemberStatusTO *)tmp_to_2;
        }

        if (![dict containsLongObjectForKey:@"alert_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"alert_flags"];
        self.alert_flags = [dict longForKey:@"alert_flags"];

        self.branding = [dict stringForKey:@"branding"];
        if (self.branding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"branding"];
        if (self.branding == MCTNull)
            self.branding = nil;

        self.broadcast_type = [dict stringForKey:@"broadcast_type" withDefaultValue:nil];
        if (self.broadcast_type == MCTNull)
            self.broadcast_type = nil;

        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        self.default_priority = [dict longForKey:@"default_priority" withDefaultValue:1];

        self.default_sticky = [dict boolForKey:@"default_sticky" withDefaultValue:NO];

        if (![dict containsLongObjectForKey:@"flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flags"];
        self.flags = [dict longForKey:@"flags"];

        self.key = [dict stringForKey:@"key"];
        if (self.key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"key"];
        if (self.key == MCTNull)
            self.key = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        if (![dict containsLongObjectForKey:@"message_type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"message_type"];
        self.message_type = [dict longForKey:@"message_type"];

        self.parent_key = [dict stringForKey:@"parent_key"];
        if (self.parent_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_key"];
        if (self.parent_key == MCTNull)
            self.parent_key = nil;

        self.priority = [dict longForKey:@"priority" withDefaultValue:1];

        self.sender = [dict stringForKey:@"sender"];
        if (self.sender == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"sender"];
        if (self.sender == MCTNull)
            self.sender = nil;

        if (![dict containsLongObjectForKey:@"threadTimestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"threadTimestamp"];
        self.threadTimestamp = [dict longForKey:@"threadTimestamp"];

        self.thread_avatar_hash = [dict stringForKey:@"thread_avatar_hash" withDefaultValue:nil];
        if (self.thread_avatar_hash == MCTNull)
            self.thread_avatar_hash = nil;

        self.thread_background_color = [dict stringForKey:@"thread_background_color" withDefaultValue:nil];
        if (self.thread_background_color == MCTNull)
            self.thread_background_color = nil;

        if (![dict containsLongObjectForKey:@"thread_size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"thread_size"];
        self.thread_size = [dict longForKey:@"thread_size"];

        self.thread_text_color = [dict stringForKey:@"thread_text_color" withDefaultValue:nil];
        if (self.thread_text_color == MCTNull)
            self.thread_text_color = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.attachments == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO.attachments");
    } else if ([self.attachments isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.attachments count]];
        for (MCT_com_mobicage_to_messaging_AttachmentTO *obj in self.attachments)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"attachments"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO.attachments");
    }

    [dict setDict:[self.form dictRepresentation] forKey:@"form"];

    [dict setDict:[self.member dictRepresentation] forKey:@"member"];

    [dict setLong:self.alert_flags forKey:@"alert_flags"];

    [dict setString:self.branding forKey:@"branding"];

    [dict setString:self.broadcast_type forKey:@"broadcast_type"];

    [dict setString:self.context forKey:@"context"];

    [dict setLong:self.default_priority forKey:@"default_priority"];

    [dict setBool:self.default_sticky forKey:@"default_sticky"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setString:self.key forKey:@"key"];

    [dict setString:self.message forKey:@"message"];

    [dict setLong:self.message_type forKey:@"message_type"];

    [dict setString:self.parent_key forKey:@"parent_key"];

    [dict setLong:self.priority forKey:@"priority"];

    [dict setString:self.sender forKey:@"sender"];

    [dict setLong:self.threadTimestamp forKey:@"threadTimestamp"];

    [dict setString:self.thread_avatar_hash forKey:@"thread_avatar_hash"];

    [dict setString:self.thread_background_color forKey:@"thread_background_color"];

    [dict setLong:self.thread_size forKey:@"thread_size"];

    [dict setString:self.thread_text_color forKey:@"thread_text_color"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_AutoCompleteFormTO

@synthesize widget = widget_;
@synthesize javascript_validation = javascript_validation_;
@synthesize negative_button = negative_button_;
@synthesize negative_button_ui_flags = negative_button_ui_flags_;
@synthesize negative_confirmation = negative_confirmation_;
@synthesize positive_button = positive_button_;
@synthesize positive_button_ui_flags = positive_button_ui_flags_;
@synthesize positive_confirmation = positive_confirmation_;
@synthesize type = type_;

- (MCT_com_mobicage_to_messaging_forms_AutoCompleteFormTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_AutoCompleteFormTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"widget"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
        if (tmp_dict_0 == MCTNull)
            self.widget = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_AutoCompleteTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_AutoCompleteTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
            self.widget = (MCT_com_mobicage_to_messaging_forms_AutoCompleteTO *)tmp_to_0;
        }

        self.javascript_validation = [dict stringForKey:@"javascript_validation" withDefaultValue:nil];
        if (self.javascript_validation == MCTNull)
            self.javascript_validation = nil;

        self.negative_button = [dict stringForKey:@"negative_button"];
        if (self.negative_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button"];
        if (self.negative_button == MCTNull)
            self.negative_button = nil;

        if (![dict containsLongObjectForKey:@"negative_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button_ui_flags"];
        self.negative_button_ui_flags = [dict longForKey:@"negative_button_ui_flags"];

        self.negative_confirmation = [dict stringForKey:@"negative_confirmation"];
        if (self.negative_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_confirmation"];
        if (self.negative_confirmation == MCTNull)
            self.negative_confirmation = nil;

        self.positive_button = [dict stringForKey:@"positive_button"];
        if (self.positive_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button"];
        if (self.positive_button == MCTNull)
            self.positive_button = nil;

        if (![dict containsLongObjectForKey:@"positive_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button_ui_flags"];
        self.positive_button_ui_flags = [dict longForKey:@"positive_button_ui_flags"];

        self.positive_confirmation = [dict stringForKey:@"positive_confirmation"];
        if (self.positive_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_confirmation"];
        if (self.positive_confirmation == MCTNull)
            self.positive_confirmation = nil;

        self.type = [dict stringForKey:@"type"];
        if (self.type == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        if (self.type == MCTNull)
            self.type = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_AutoCompleteFormTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_AutoCompleteFormTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_AutoCompleteFormTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_AutoCompleteFormTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.widget dictRepresentation] forKey:@"widget"];

    [dict setString:self.javascript_validation forKey:@"javascript_validation"];

    [dict setString:self.negative_button forKey:@"negative_button"];

    [dict setLong:self.negative_button_ui_flags forKey:@"negative_button_ui_flags"];

    [dict setString:self.negative_confirmation forKey:@"negative_confirmation"];

    [dict setString:self.positive_button forKey:@"positive_button"];

    [dict setLong:self.positive_button_ui_flags forKey:@"positive_button_ui_flags"];

    [dict setString:self.positive_confirmation forKey:@"positive_confirmation"];

    [dict setString:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_AutoCompleteTO

@synthesize choices = choices_;
@synthesize max_chars = max_chars_;
@synthesize place_holder = place_holder_;
@synthesize suggestions = suggestions_;
@synthesize value = value_;

- (MCT_com_mobicage_to_messaging_forms_AutoCompleteTO *)init
{
    if (self = [super init]) {
        self.choices = [NSMutableArray array];
        self.suggestions = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_AutoCompleteTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_unicode_array_0 = [dict arrayForKey:@"choices"];
        if (tmp_unicode_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"choices"];
        for (id obj in tmp_unicode_array_0) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"choices"];
        }
        self.choices = tmp_unicode_array_0;

        if (![dict containsLongObjectForKey:@"max_chars"])
            return [self errorDuringInitBecauseOfFieldWithName:@"max_chars"];
        self.max_chars = [dict longForKey:@"max_chars"];

        self.place_holder = [dict stringForKey:@"place_holder"];
        if (self.place_holder == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"place_holder"];
        if (self.place_holder == MCTNull)
            self.place_holder = nil;

        NSArray *tmp_unicode_array_3 = [dict arrayForKey:@"suggestions"];
        if (tmp_unicode_array_3 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"suggestions"];
        for (id obj in tmp_unicode_array_3) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"suggestions"];
        }
        self.suggestions = tmp_unicode_array_3;

        self.value = [dict stringForKey:@"value"];
        if (self.value == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"value"];
        if (self.value == MCTNull)
            self.value = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_AutoCompleteTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_AutoCompleteTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_AutoCompleteTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_AutoCompleteTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.choices forKey:@"choices"];

    [dict setLong:self.max_chars forKey:@"max_chars"];

    [dict setString:self.place_holder forKey:@"place_holder"];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.suggestions forKey:@"suggestions"];

    [dict setString:self.value forKey:@"value"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_ChoiceTO

@synthesize label = label_;
@synthesize value = value_;

- (MCT_com_mobicage_to_messaging_forms_ChoiceTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_ChoiceTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.label = [dict stringForKey:@"label"];
        if (self.label == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"label"];
        if (self.label == MCTNull)
            self.label = nil;

        self.value = [dict stringForKey:@"value"];
        if (self.value == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"value"];
        if (self.value == MCTNull)
            self.value = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_ChoiceTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_ChoiceTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_ChoiceTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_ChoiceTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.label forKey:@"label"];

    [dict setString:self.value forKey:@"value"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO

@synthesize attachments = attachments_;
@synthesize form = form_;
@synthesize member = member_;
@synthesize alert_flags = alert_flags_;
@synthesize branding = branding_;
@synthesize broadcast_type = broadcast_type_;
@synthesize context = context_;
@synthesize default_priority = default_priority_;
@synthesize default_sticky = default_sticky_;
@synthesize flags = flags_;
@synthesize key = key_;
@synthesize message = message_;
@synthesize message_type = message_type_;
@synthesize parent_key = parent_key_;
@synthesize priority = priority_;
@synthesize sender = sender_;
@synthesize threadTimestamp = threadTimestamp_;
@synthesize thread_avatar_hash = thread_avatar_hash_;
@synthesize thread_background_color = thread_background_color_;
@synthesize thread_size = thread_size_;
@synthesize thread_text_color = thread_text_color_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO *)init
{
    if (self = [super init]) {
        self.attachments = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"attachments" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
        if (tmp_dict_array_0 != nil) {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_AttachmentTO *tmp_obj = [MCT_com_mobicage_to_messaging_AttachmentTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.attachments = tmp_obj_array_0;
        }

        NSDictionary *tmp_dict_1 = [dict dictForKey:@"form"];
        if (tmp_dict_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form"];
        if (tmp_dict_1 == MCTNull)
            self.form = nil;
        else if (tmp_dict_1 != nil) {
            MCT_com_mobicage_to_messaging_forms_DateSelectFormTO *tmp_to_1 = [MCT_com_mobicage_to_messaging_forms_DateSelectFormTO transferObjectWithDict:tmp_dict_1];
            if (tmp_to_1 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form"];
            self.form = (MCT_com_mobicage_to_messaging_forms_DateSelectFormTO *)tmp_to_1;
        }

        NSDictionary *tmp_dict_2 = [dict dictForKey:@"member"];
        if (tmp_dict_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"member"];
        if (tmp_dict_2 == MCTNull)
            self.member = nil;
        else if (tmp_dict_2 != nil) {
            MCT_com_mobicage_to_messaging_MemberStatusTO *tmp_to_2 = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObjectWithDict:tmp_dict_2];
            if (tmp_to_2 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"member"];
            self.member = (MCT_com_mobicage_to_messaging_MemberStatusTO *)tmp_to_2;
        }

        if (![dict containsLongObjectForKey:@"alert_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"alert_flags"];
        self.alert_flags = [dict longForKey:@"alert_flags"];

        self.branding = [dict stringForKey:@"branding"];
        if (self.branding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"branding"];
        if (self.branding == MCTNull)
            self.branding = nil;

        self.broadcast_type = [dict stringForKey:@"broadcast_type" withDefaultValue:nil];
        if (self.broadcast_type == MCTNull)
            self.broadcast_type = nil;

        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        self.default_priority = [dict longForKey:@"default_priority" withDefaultValue:1];

        self.default_sticky = [dict boolForKey:@"default_sticky" withDefaultValue:NO];

        if (![dict containsLongObjectForKey:@"flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flags"];
        self.flags = [dict longForKey:@"flags"];

        self.key = [dict stringForKey:@"key"];
        if (self.key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"key"];
        if (self.key == MCTNull)
            self.key = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        if (![dict containsLongObjectForKey:@"message_type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"message_type"];
        self.message_type = [dict longForKey:@"message_type"];

        self.parent_key = [dict stringForKey:@"parent_key"];
        if (self.parent_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_key"];
        if (self.parent_key == MCTNull)
            self.parent_key = nil;

        self.priority = [dict longForKey:@"priority" withDefaultValue:1];

        self.sender = [dict stringForKey:@"sender"];
        if (self.sender == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"sender"];
        if (self.sender == MCTNull)
            self.sender = nil;

        if (![dict containsLongObjectForKey:@"threadTimestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"threadTimestamp"];
        self.threadTimestamp = [dict longForKey:@"threadTimestamp"];

        self.thread_avatar_hash = [dict stringForKey:@"thread_avatar_hash" withDefaultValue:nil];
        if (self.thread_avatar_hash == MCTNull)
            self.thread_avatar_hash = nil;

        self.thread_background_color = [dict stringForKey:@"thread_background_color" withDefaultValue:nil];
        if (self.thread_background_color == MCTNull)
            self.thread_background_color = nil;

        if (![dict containsLongObjectForKey:@"thread_size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"thread_size"];
        self.thread_size = [dict longForKey:@"thread_size"];

        self.thread_text_color = [dict stringForKey:@"thread_text_color" withDefaultValue:nil];
        if (self.thread_text_color == MCTNull)
            self.thread_text_color = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.attachments == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO.attachments");
    } else if ([self.attachments isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.attachments count]];
        for (MCT_com_mobicage_to_messaging_AttachmentTO *obj in self.attachments)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"attachments"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO.attachments");
    }

    [dict setDict:[self.form dictRepresentation] forKey:@"form"];

    [dict setDict:[self.member dictRepresentation] forKey:@"member"];

    [dict setLong:self.alert_flags forKey:@"alert_flags"];

    [dict setString:self.branding forKey:@"branding"];

    [dict setString:self.broadcast_type forKey:@"broadcast_type"];

    [dict setString:self.context forKey:@"context"];

    [dict setLong:self.default_priority forKey:@"default_priority"];

    [dict setBool:self.default_sticky forKey:@"default_sticky"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setString:self.key forKey:@"key"];

    [dict setString:self.message forKey:@"message"];

    [dict setLong:self.message_type forKey:@"message_type"];

    [dict setString:self.parent_key forKey:@"parent_key"];

    [dict setLong:self.priority forKey:@"priority"];

    [dict setString:self.sender forKey:@"sender"];

    [dict setLong:self.threadTimestamp forKey:@"threadTimestamp"];

    [dict setString:self.thread_avatar_hash forKey:@"thread_avatar_hash"];

    [dict setString:self.thread_background_color forKey:@"thread_background_color"];

    [dict setLong:self.thread_size forKey:@"thread_size"];

    [dict setString:self.thread_text_color forKey:@"thread_text_color"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_DateSelectFormTO

@synthesize widget = widget_;
@synthesize javascript_validation = javascript_validation_;
@synthesize negative_button = negative_button_;
@synthesize negative_button_ui_flags = negative_button_ui_flags_;
@synthesize negative_confirmation = negative_confirmation_;
@synthesize positive_button = positive_button_;
@synthesize positive_button_ui_flags = positive_button_ui_flags_;
@synthesize positive_confirmation = positive_confirmation_;
@synthesize type = type_;

- (MCT_com_mobicage_to_messaging_forms_DateSelectFormTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_DateSelectFormTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"widget"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
        if (tmp_dict_0 == MCTNull)
            self.widget = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_DateSelectTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_DateSelectTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
            self.widget = (MCT_com_mobicage_to_messaging_forms_DateSelectTO *)tmp_to_0;
        }

        self.javascript_validation = [dict stringForKey:@"javascript_validation" withDefaultValue:nil];
        if (self.javascript_validation == MCTNull)
            self.javascript_validation = nil;

        self.negative_button = [dict stringForKey:@"negative_button"];
        if (self.negative_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button"];
        if (self.negative_button == MCTNull)
            self.negative_button = nil;

        if (![dict containsLongObjectForKey:@"negative_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button_ui_flags"];
        self.negative_button_ui_flags = [dict longForKey:@"negative_button_ui_flags"];

        self.negative_confirmation = [dict stringForKey:@"negative_confirmation"];
        if (self.negative_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_confirmation"];
        if (self.negative_confirmation == MCTNull)
            self.negative_confirmation = nil;

        self.positive_button = [dict stringForKey:@"positive_button"];
        if (self.positive_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button"];
        if (self.positive_button == MCTNull)
            self.positive_button = nil;

        if (![dict containsLongObjectForKey:@"positive_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button_ui_flags"];
        self.positive_button_ui_flags = [dict longForKey:@"positive_button_ui_flags"];

        self.positive_confirmation = [dict stringForKey:@"positive_confirmation"];
        if (self.positive_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_confirmation"];
        if (self.positive_confirmation == MCTNull)
            self.positive_confirmation = nil;

        self.type = [dict stringForKey:@"type"];
        if (self.type == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        if (self.type == MCTNull)
            self.type = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_DateSelectFormTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_DateSelectFormTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_DateSelectFormTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_DateSelectFormTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.widget dictRepresentation] forKey:@"widget"];

    [dict setString:self.javascript_validation forKey:@"javascript_validation"];

    [dict setString:self.negative_button forKey:@"negative_button"];

    [dict setLong:self.negative_button_ui_flags forKey:@"negative_button_ui_flags"];

    [dict setString:self.negative_confirmation forKey:@"negative_confirmation"];

    [dict setString:self.positive_button forKey:@"positive_button"];

    [dict setLong:self.positive_button_ui_flags forKey:@"positive_button_ui_flags"];

    [dict setString:self.positive_confirmation forKey:@"positive_confirmation"];

    [dict setString:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_DateSelectTO

@synthesize date = date_;
@synthesize has_date = has_date_;
@synthesize has_max_date = has_max_date_;
@synthesize has_min_date = has_min_date_;
@synthesize max_date = max_date_;
@synthesize min_date = min_date_;
@synthesize minute_interval = minute_interval_;
@synthesize mode = mode_;
@synthesize unit = unit_;

- (MCT_com_mobicage_to_messaging_forms_DateSelectTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_DateSelectTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"date"])
            return [self errorDuringInitBecauseOfFieldWithName:@"date"];
        self.date = [dict longForKey:@"date"];

        if (![dict containsBoolObjectForKey:@"has_date"])
            return [self errorDuringInitBecauseOfFieldWithName:@"has_date"];
        self.has_date = [dict boolForKey:@"has_date"];

        if (![dict containsBoolObjectForKey:@"has_max_date"])
            return [self errorDuringInitBecauseOfFieldWithName:@"has_max_date"];
        self.has_max_date = [dict boolForKey:@"has_max_date"];

        if (![dict containsBoolObjectForKey:@"has_min_date"])
            return [self errorDuringInitBecauseOfFieldWithName:@"has_min_date"];
        self.has_min_date = [dict boolForKey:@"has_min_date"];

        if (![dict containsLongObjectForKey:@"max_date"])
            return [self errorDuringInitBecauseOfFieldWithName:@"max_date"];
        self.max_date = [dict longForKey:@"max_date"];

        if (![dict containsLongObjectForKey:@"min_date"])
            return [self errorDuringInitBecauseOfFieldWithName:@"min_date"];
        self.min_date = [dict longForKey:@"min_date"];

        if (![dict containsLongObjectForKey:@"minute_interval"])
            return [self errorDuringInitBecauseOfFieldWithName:@"minute_interval"];
        self.minute_interval = [dict longForKey:@"minute_interval"];

        self.mode = [dict stringForKey:@"mode"];
        if (self.mode == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"mode"];
        if (self.mode == MCTNull)
            self.mode = nil;

        self.unit = [dict stringForKey:@"unit"];
        if (self.unit == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"unit"];
        if (self.unit == MCTNull)
            self.unit = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_DateSelectTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_DateSelectTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_DateSelectTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_DateSelectTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.date forKey:@"date"];

    [dict setBool:self.has_date forKey:@"has_date"];

    [dict setBool:self.has_max_date forKey:@"has_max_date"];

    [dict setBool:self.has_min_date forKey:@"has_min_date"];

    [dict setLong:self.max_date forKey:@"max_date"];

    [dict setLong:self.min_date forKey:@"min_date"];

    [dict setLong:self.minute_interval forKey:@"minute_interval"];

    [dict setString:self.mode forKey:@"mode"];

    [dict setString:self.unit forKey:@"unit"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO

@synthesize values = values_;

- (MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *)init
{
    if (self = [super init]) {
        self.values = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_float_array_0 = [dict arrayForKey:@"values"];
        if (tmp_float_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"values"];
        for (id obj in tmp_float_array_0) {
            if (!([obj isKindOfClass:MCTFloatClass] || [obj isKindOfClass:MCTLongClass]))
                return [self errorDuringInitBecauseOfFieldWithName:@"values"];
        }
        self.values = tmp_float_array_0;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // TODO: add checking that all members are indeed floats
    [dict setArray:self.values forKey:@"values"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO

@synthesize value = value_;

- (MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsFloatObjectForKey:@"value"])
            return [self errorDuringInitBecauseOfFieldWithName:@"value"];
        else
            self.value = [dict floatForKey:@"value"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setFloat:self.value forKey:@"value"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO

@synthesize attachments = attachments_;
@synthesize form = form_;
@synthesize member = member_;
@synthesize alert_flags = alert_flags_;
@synthesize branding = branding_;
@synthesize broadcast_type = broadcast_type_;
@synthesize context = context_;
@synthesize default_priority = default_priority_;
@synthesize default_sticky = default_sticky_;
@synthesize flags = flags_;
@synthesize key = key_;
@synthesize message = message_;
@synthesize message_type = message_type_;
@synthesize parent_key = parent_key_;
@synthesize priority = priority_;
@synthesize sender = sender_;
@synthesize threadTimestamp = threadTimestamp_;
@synthesize thread_avatar_hash = thread_avatar_hash_;
@synthesize thread_background_color = thread_background_color_;
@synthesize thread_size = thread_size_;
@synthesize thread_text_color = thread_text_color_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO *)init
{
    if (self = [super init]) {
        self.attachments = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"attachments" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
        if (tmp_dict_array_0 != nil) {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_AttachmentTO *tmp_obj = [MCT_com_mobicage_to_messaging_AttachmentTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.attachments = tmp_obj_array_0;
        }

        NSDictionary *tmp_dict_1 = [dict dictForKey:@"form"];
        if (tmp_dict_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form"];
        if (tmp_dict_1 == MCTNull)
            self.form = nil;
        else if (tmp_dict_1 != nil) {
            MCT_com_mobicage_to_messaging_forms_GPSLocationFormTO *tmp_to_1 = [MCT_com_mobicage_to_messaging_forms_GPSLocationFormTO transferObjectWithDict:tmp_dict_1];
            if (tmp_to_1 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form"];
            self.form = (MCT_com_mobicage_to_messaging_forms_GPSLocationFormTO *)tmp_to_1;
        }

        NSDictionary *tmp_dict_2 = [dict dictForKey:@"member"];
        if (tmp_dict_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"member"];
        if (tmp_dict_2 == MCTNull)
            self.member = nil;
        else if (tmp_dict_2 != nil) {
            MCT_com_mobicage_to_messaging_MemberStatusTO *tmp_to_2 = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObjectWithDict:tmp_dict_2];
            if (tmp_to_2 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"member"];
            self.member = (MCT_com_mobicage_to_messaging_MemberStatusTO *)tmp_to_2;
        }

        if (![dict containsLongObjectForKey:@"alert_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"alert_flags"];
        self.alert_flags = [dict longForKey:@"alert_flags"];

        self.branding = [dict stringForKey:@"branding"];
        if (self.branding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"branding"];
        if (self.branding == MCTNull)
            self.branding = nil;

        self.broadcast_type = [dict stringForKey:@"broadcast_type" withDefaultValue:nil];
        if (self.broadcast_type == MCTNull)
            self.broadcast_type = nil;

        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        self.default_priority = [dict longForKey:@"default_priority" withDefaultValue:1];

        self.default_sticky = [dict boolForKey:@"default_sticky" withDefaultValue:NO];

        if (![dict containsLongObjectForKey:@"flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flags"];
        self.flags = [dict longForKey:@"flags"];

        self.key = [dict stringForKey:@"key"];
        if (self.key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"key"];
        if (self.key == MCTNull)
            self.key = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        if (![dict containsLongObjectForKey:@"message_type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"message_type"];
        self.message_type = [dict longForKey:@"message_type"];

        self.parent_key = [dict stringForKey:@"parent_key"];
        if (self.parent_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_key"];
        if (self.parent_key == MCTNull)
            self.parent_key = nil;

        self.priority = [dict longForKey:@"priority" withDefaultValue:1];

        self.sender = [dict stringForKey:@"sender"];
        if (self.sender == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"sender"];
        if (self.sender == MCTNull)
            self.sender = nil;

        if (![dict containsLongObjectForKey:@"threadTimestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"threadTimestamp"];
        self.threadTimestamp = [dict longForKey:@"threadTimestamp"];

        self.thread_avatar_hash = [dict stringForKey:@"thread_avatar_hash" withDefaultValue:nil];
        if (self.thread_avatar_hash == MCTNull)
            self.thread_avatar_hash = nil;

        self.thread_background_color = [dict stringForKey:@"thread_background_color" withDefaultValue:nil];
        if (self.thread_background_color == MCTNull)
            self.thread_background_color = nil;

        if (![dict containsLongObjectForKey:@"thread_size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"thread_size"];
        self.thread_size = [dict longForKey:@"thread_size"];

        self.thread_text_color = [dict stringForKey:@"thread_text_color" withDefaultValue:nil];
        if (self.thread_text_color == MCTNull)
            self.thread_text_color = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.attachments == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO.attachments");
    } else if ([self.attachments isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.attachments count]];
        for (MCT_com_mobicage_to_messaging_AttachmentTO *obj in self.attachments)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"attachments"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO.attachments");
    }

    [dict setDict:[self.form dictRepresentation] forKey:@"form"];

    [dict setDict:[self.member dictRepresentation] forKey:@"member"];

    [dict setLong:self.alert_flags forKey:@"alert_flags"];

    [dict setString:self.branding forKey:@"branding"];

    [dict setString:self.broadcast_type forKey:@"broadcast_type"];

    [dict setString:self.context forKey:@"context"];

    [dict setLong:self.default_priority forKey:@"default_priority"];

    [dict setBool:self.default_sticky forKey:@"default_sticky"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setString:self.key forKey:@"key"];

    [dict setString:self.message forKey:@"message"];

    [dict setLong:self.message_type forKey:@"message_type"];

    [dict setString:self.parent_key forKey:@"parent_key"];

    [dict setLong:self.priority forKey:@"priority"];

    [dict setString:self.sender forKey:@"sender"];

    [dict setLong:self.threadTimestamp forKey:@"threadTimestamp"];

    [dict setString:self.thread_avatar_hash forKey:@"thread_avatar_hash"];

    [dict setString:self.thread_background_color forKey:@"thread_background_color"];

    [dict setLong:self.thread_size forKey:@"thread_size"];

    [dict setString:self.thread_text_color forKey:@"thread_text_color"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_GPSLocationFormTO

@synthesize widget = widget_;
@synthesize javascript_validation = javascript_validation_;
@synthesize negative_button = negative_button_;
@synthesize negative_button_ui_flags = negative_button_ui_flags_;
@synthesize negative_confirmation = negative_confirmation_;
@synthesize positive_button = positive_button_;
@synthesize positive_button_ui_flags = positive_button_ui_flags_;
@synthesize positive_confirmation = positive_confirmation_;
@synthesize type = type_;

- (MCT_com_mobicage_to_messaging_forms_GPSLocationFormTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_GPSLocationFormTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"widget"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
        if (tmp_dict_0 == MCTNull)
            self.widget = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_GPSLocationTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_GPSLocationTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
            self.widget = (MCT_com_mobicage_to_messaging_forms_GPSLocationTO *)tmp_to_0;
        }

        self.javascript_validation = [dict stringForKey:@"javascript_validation" withDefaultValue:nil];
        if (self.javascript_validation == MCTNull)
            self.javascript_validation = nil;

        self.negative_button = [dict stringForKey:@"negative_button"];
        if (self.negative_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button"];
        if (self.negative_button == MCTNull)
            self.negative_button = nil;

        if (![dict containsLongObjectForKey:@"negative_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button_ui_flags"];
        self.negative_button_ui_flags = [dict longForKey:@"negative_button_ui_flags"];

        self.negative_confirmation = [dict stringForKey:@"negative_confirmation"];
        if (self.negative_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_confirmation"];
        if (self.negative_confirmation == MCTNull)
            self.negative_confirmation = nil;

        self.positive_button = [dict stringForKey:@"positive_button"];
        if (self.positive_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button"];
        if (self.positive_button == MCTNull)
            self.positive_button = nil;

        if (![dict containsLongObjectForKey:@"positive_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button_ui_flags"];
        self.positive_button_ui_flags = [dict longForKey:@"positive_button_ui_flags"];

        self.positive_confirmation = [dict stringForKey:@"positive_confirmation"];
        if (self.positive_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_confirmation"];
        if (self.positive_confirmation == MCTNull)
            self.positive_confirmation = nil;

        self.type = [dict stringForKey:@"type"];
        if (self.type == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        if (self.type == MCTNull)
            self.type = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_GPSLocationFormTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_GPSLocationFormTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_GPSLocationFormTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_GPSLocationFormTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.widget dictRepresentation] forKey:@"widget"];

    [dict setString:self.javascript_validation forKey:@"javascript_validation"];

    [dict setString:self.negative_button forKey:@"negative_button"];

    [dict setLong:self.negative_button_ui_flags forKey:@"negative_button_ui_flags"];

    [dict setString:self.negative_confirmation forKey:@"negative_confirmation"];

    [dict setString:self.positive_button forKey:@"positive_button"];

    [dict setLong:self.positive_button_ui_flags forKey:@"positive_button_ui_flags"];

    [dict setString:self.positive_confirmation forKey:@"positive_confirmation"];

    [dict setString:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_GPSLocationTO

@synthesize gps = gps_;

- (MCT_com_mobicage_to_messaging_forms_GPSLocationTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_GPSLocationTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsBoolObjectForKey:@"gps"])
            return [self errorDuringInitBecauseOfFieldWithName:@"gps"];
        self.gps = [dict boolForKey:@"gps"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_GPSLocationTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_GPSLocationTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_GPSLocationTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_GPSLocationTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setBool:self.gps forKey:@"gps"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO

@synthesize altitude = altitude_;
@synthesize horizontal_accuracy = horizontal_accuracy_;
@synthesize latitude = latitude_;
@synthesize longitude = longitude_;
@synthesize timestamp = timestamp_;
@synthesize vertical_accuracy = vertical_accuracy_;

- (MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsFloatObjectForKey:@"altitude"])
            return [self errorDuringInitBecauseOfFieldWithName:@"altitude"];
        else
            self.altitude = [dict floatForKey:@"altitude"];

        self.horizontal_accuracy = [dict floatForKey:@"horizontal_accuracy" withDefaultValue:-1];

        if (![dict containsFloatObjectForKey:@"latitude"])
            return [self errorDuringInitBecauseOfFieldWithName:@"latitude"];
        else
            self.latitude = [dict floatForKey:@"latitude"];

        if (![dict containsFloatObjectForKey:@"longitude"])
            return [self errorDuringInitBecauseOfFieldWithName:@"longitude"];
        else
            self.longitude = [dict floatForKey:@"longitude"];

        self.timestamp = [dict longForKey:@"timestamp" withDefaultValue:0];

        self.vertical_accuracy = [dict floatForKey:@"vertical_accuracy" withDefaultValue:-1];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setFloat:self.altitude forKey:@"altitude"];

    [dict setFloat:self.horizontal_accuracy forKey:@"horizontal_accuracy"];

    [dict setFloat:self.latitude forKey:@"latitude"];

    [dict setFloat:self.longitude forKey:@"longitude"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    [dict setFloat:self.vertical_accuracy forKey:@"vertical_accuracy"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO

@synthesize value = value_;

- (MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"value"])
            return [self errorDuringInitBecauseOfFieldWithName:@"value"];
        self.value = [dict longForKey:@"value"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.value forKey:@"value"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO

@synthesize attachments = attachments_;
@synthesize form = form_;
@synthesize member = member_;
@synthesize alert_flags = alert_flags_;
@synthesize branding = branding_;
@synthesize broadcast_type = broadcast_type_;
@synthesize context = context_;
@synthesize default_priority = default_priority_;
@synthesize default_sticky = default_sticky_;
@synthesize flags = flags_;
@synthesize key = key_;
@synthesize message = message_;
@synthesize message_type = message_type_;
@synthesize parent_key = parent_key_;
@synthesize priority = priority_;
@synthesize sender = sender_;
@synthesize threadTimestamp = threadTimestamp_;
@synthesize thread_avatar_hash = thread_avatar_hash_;
@synthesize thread_background_color = thread_background_color_;
@synthesize thread_size = thread_size_;
@synthesize thread_text_color = thread_text_color_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO *)init
{
    if (self = [super init]) {
        self.attachments = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"attachments" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
        if (tmp_dict_array_0 != nil) {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_AttachmentTO *tmp_obj = [MCT_com_mobicage_to_messaging_AttachmentTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.attachments = tmp_obj_array_0;
        }

        NSDictionary *tmp_dict_1 = [dict dictForKey:@"form"];
        if (tmp_dict_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form"];
        if (tmp_dict_1 == MCTNull)
            self.form = nil;
        else if (tmp_dict_1 != nil) {
            MCT_com_mobicage_to_messaging_forms_MultiSelectFormTO *tmp_to_1 = [MCT_com_mobicage_to_messaging_forms_MultiSelectFormTO transferObjectWithDict:tmp_dict_1];
            if (tmp_to_1 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form"];
            self.form = (MCT_com_mobicage_to_messaging_forms_MultiSelectFormTO *)tmp_to_1;
        }

        NSDictionary *tmp_dict_2 = [dict dictForKey:@"member"];
        if (tmp_dict_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"member"];
        if (tmp_dict_2 == MCTNull)
            self.member = nil;
        else if (tmp_dict_2 != nil) {
            MCT_com_mobicage_to_messaging_MemberStatusTO *tmp_to_2 = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObjectWithDict:tmp_dict_2];
            if (tmp_to_2 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"member"];
            self.member = (MCT_com_mobicage_to_messaging_MemberStatusTO *)tmp_to_2;
        }

        if (![dict containsLongObjectForKey:@"alert_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"alert_flags"];
        self.alert_flags = [dict longForKey:@"alert_flags"];

        self.branding = [dict stringForKey:@"branding"];
        if (self.branding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"branding"];
        if (self.branding == MCTNull)
            self.branding = nil;

        self.broadcast_type = [dict stringForKey:@"broadcast_type" withDefaultValue:nil];
        if (self.broadcast_type == MCTNull)
            self.broadcast_type = nil;

        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        self.default_priority = [dict longForKey:@"default_priority" withDefaultValue:1];

        self.default_sticky = [dict boolForKey:@"default_sticky" withDefaultValue:NO];

        if (![dict containsLongObjectForKey:@"flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flags"];
        self.flags = [dict longForKey:@"flags"];

        self.key = [dict stringForKey:@"key"];
        if (self.key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"key"];
        if (self.key == MCTNull)
            self.key = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        if (![dict containsLongObjectForKey:@"message_type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"message_type"];
        self.message_type = [dict longForKey:@"message_type"];

        self.parent_key = [dict stringForKey:@"parent_key"];
        if (self.parent_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_key"];
        if (self.parent_key == MCTNull)
            self.parent_key = nil;

        self.priority = [dict longForKey:@"priority" withDefaultValue:1];

        self.sender = [dict stringForKey:@"sender"];
        if (self.sender == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"sender"];
        if (self.sender == MCTNull)
            self.sender = nil;

        if (![dict containsLongObjectForKey:@"threadTimestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"threadTimestamp"];
        self.threadTimestamp = [dict longForKey:@"threadTimestamp"];

        self.thread_avatar_hash = [dict stringForKey:@"thread_avatar_hash" withDefaultValue:nil];
        if (self.thread_avatar_hash == MCTNull)
            self.thread_avatar_hash = nil;

        self.thread_background_color = [dict stringForKey:@"thread_background_color" withDefaultValue:nil];
        if (self.thread_background_color == MCTNull)
            self.thread_background_color = nil;

        if (![dict containsLongObjectForKey:@"thread_size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"thread_size"];
        self.thread_size = [dict longForKey:@"thread_size"];

        self.thread_text_color = [dict stringForKey:@"thread_text_color" withDefaultValue:nil];
        if (self.thread_text_color == MCTNull)
            self.thread_text_color = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.attachments == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO.attachments");
    } else if ([self.attachments isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.attachments count]];
        for (MCT_com_mobicage_to_messaging_AttachmentTO *obj in self.attachments)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"attachments"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO.attachments");
    }

    [dict setDict:[self.form dictRepresentation] forKey:@"form"];

    [dict setDict:[self.member dictRepresentation] forKey:@"member"];

    [dict setLong:self.alert_flags forKey:@"alert_flags"];

    [dict setString:self.branding forKey:@"branding"];

    [dict setString:self.broadcast_type forKey:@"broadcast_type"];

    [dict setString:self.context forKey:@"context"];

    [dict setLong:self.default_priority forKey:@"default_priority"];

    [dict setBool:self.default_sticky forKey:@"default_sticky"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setString:self.key forKey:@"key"];

    [dict setString:self.message forKey:@"message"];

    [dict setLong:self.message_type forKey:@"message_type"];

    [dict setString:self.parent_key forKey:@"parent_key"];

    [dict setLong:self.priority forKey:@"priority"];

    [dict setString:self.sender forKey:@"sender"];

    [dict setLong:self.threadTimestamp forKey:@"threadTimestamp"];

    [dict setString:self.thread_avatar_hash forKey:@"thread_avatar_hash"];

    [dict setString:self.thread_background_color forKey:@"thread_background_color"];

    [dict setLong:self.thread_size forKey:@"thread_size"];

    [dict setString:self.thread_text_color forKey:@"thread_text_color"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_MultiSelectFormTO

@synthesize widget = widget_;
@synthesize javascript_validation = javascript_validation_;
@synthesize negative_button = negative_button_;
@synthesize negative_button_ui_flags = negative_button_ui_flags_;
@synthesize negative_confirmation = negative_confirmation_;
@synthesize positive_button = positive_button_;
@synthesize positive_button_ui_flags = positive_button_ui_flags_;
@synthesize positive_confirmation = positive_confirmation_;
@synthesize type = type_;

- (MCT_com_mobicage_to_messaging_forms_MultiSelectFormTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_MultiSelectFormTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"widget"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
        if (tmp_dict_0 == MCTNull)
            self.widget = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_MultiSelectTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_MultiSelectTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
            self.widget = (MCT_com_mobicage_to_messaging_forms_MultiSelectTO *)tmp_to_0;
        }

        self.javascript_validation = [dict stringForKey:@"javascript_validation" withDefaultValue:nil];
        if (self.javascript_validation == MCTNull)
            self.javascript_validation = nil;

        self.negative_button = [dict stringForKey:@"negative_button"];
        if (self.negative_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button"];
        if (self.negative_button == MCTNull)
            self.negative_button = nil;

        if (![dict containsLongObjectForKey:@"negative_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button_ui_flags"];
        self.negative_button_ui_flags = [dict longForKey:@"negative_button_ui_flags"];

        self.negative_confirmation = [dict stringForKey:@"negative_confirmation"];
        if (self.negative_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_confirmation"];
        if (self.negative_confirmation == MCTNull)
            self.negative_confirmation = nil;

        self.positive_button = [dict stringForKey:@"positive_button"];
        if (self.positive_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button"];
        if (self.positive_button == MCTNull)
            self.positive_button = nil;

        if (![dict containsLongObjectForKey:@"positive_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button_ui_flags"];
        self.positive_button_ui_flags = [dict longForKey:@"positive_button_ui_flags"];

        self.positive_confirmation = [dict stringForKey:@"positive_confirmation"];
        if (self.positive_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_confirmation"];
        if (self.positive_confirmation == MCTNull)
            self.positive_confirmation = nil;

        self.type = [dict stringForKey:@"type"];
        if (self.type == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        if (self.type == MCTNull)
            self.type = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_MultiSelectFormTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_MultiSelectFormTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_MultiSelectFormTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_MultiSelectFormTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.widget dictRepresentation] forKey:@"widget"];

    [dict setString:self.javascript_validation forKey:@"javascript_validation"];

    [dict setString:self.negative_button forKey:@"negative_button"];

    [dict setLong:self.negative_button_ui_flags forKey:@"negative_button_ui_flags"];

    [dict setString:self.negative_confirmation forKey:@"negative_confirmation"];

    [dict setString:self.positive_button forKey:@"positive_button"];

    [dict setLong:self.positive_button_ui_flags forKey:@"positive_button_ui_flags"];

    [dict setString:self.positive_confirmation forKey:@"positive_confirmation"];

    [dict setString:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_MultiSelectTO

@synthesize choices = choices_;
@synthesize values = values_;

- (MCT_com_mobicage_to_messaging_forms_MultiSelectTO *)init
{
    if (self = [super init]) {
        self.choices = [NSMutableArray array];
        self.values = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_MultiSelectTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"choices"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"choices"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"choices"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_forms_ChoiceTO *tmp_obj = [MCT_com_mobicage_to_messaging_forms_ChoiceTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"choices"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.choices = tmp_obj_array_0;
        }

        NSArray *tmp_unicode_array_1 = [dict arrayForKey:@"values"];
        if (tmp_unicode_array_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"values"];
        for (id obj in tmp_unicode_array_1) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"values"];
        }
        self.values = tmp_unicode_array_1;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_MultiSelectTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_MultiSelectTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_MultiSelectTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_MultiSelectTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.choices == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_MultiSelectTO.choices");
    } else if ([self.choices isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.choices count]];
        for (MCT_com_mobicage_to_messaging_forms_ChoiceTO *obj in self.choices)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"choices"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_MultiSelectTO.choices");
    }

    // TODO: add checking that all members are indeed string
    [dict setArray:self.values forKey:@"values"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO

@synthesize attachments = attachments_;
@synthesize form = form_;
@synthesize member = member_;
@synthesize alert_flags = alert_flags_;
@synthesize branding = branding_;
@synthesize broadcast_type = broadcast_type_;
@synthesize context = context_;
@synthesize default_priority = default_priority_;
@synthesize default_sticky = default_sticky_;
@synthesize flags = flags_;
@synthesize key = key_;
@synthesize message = message_;
@synthesize message_type = message_type_;
@synthesize parent_key = parent_key_;
@synthesize priority = priority_;
@synthesize sender = sender_;
@synthesize threadTimestamp = threadTimestamp_;
@synthesize thread_avatar_hash = thread_avatar_hash_;
@synthesize thread_background_color = thread_background_color_;
@synthesize thread_size = thread_size_;
@synthesize thread_text_color = thread_text_color_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO *)init
{
    if (self = [super init]) {
        self.attachments = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"attachments" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
        if (tmp_dict_array_0 != nil) {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_AttachmentTO *tmp_obj = [MCT_com_mobicage_to_messaging_AttachmentTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.attachments = tmp_obj_array_0;
        }

        NSDictionary *tmp_dict_1 = [dict dictForKey:@"form"];
        if (tmp_dict_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form"];
        if (tmp_dict_1 == MCTNull)
            self.form = nil;
        else if (tmp_dict_1 != nil) {
            MCT_com_mobicage_to_messaging_forms_MyDigiPassFormTO *tmp_to_1 = [MCT_com_mobicage_to_messaging_forms_MyDigiPassFormTO transferObjectWithDict:tmp_dict_1];
            if (tmp_to_1 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form"];
            self.form = (MCT_com_mobicage_to_messaging_forms_MyDigiPassFormTO *)tmp_to_1;
        }

        NSDictionary *tmp_dict_2 = [dict dictForKey:@"member"];
        if (tmp_dict_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"member"];
        if (tmp_dict_2 == MCTNull)
            self.member = nil;
        else if (tmp_dict_2 != nil) {
            MCT_com_mobicage_to_messaging_MemberStatusTO *tmp_to_2 = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObjectWithDict:tmp_dict_2];
            if (tmp_to_2 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"member"];
            self.member = (MCT_com_mobicage_to_messaging_MemberStatusTO *)tmp_to_2;
        }

        if (![dict containsLongObjectForKey:@"alert_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"alert_flags"];
        self.alert_flags = [dict longForKey:@"alert_flags"];

        self.branding = [dict stringForKey:@"branding"];
        if (self.branding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"branding"];
        if (self.branding == MCTNull)
            self.branding = nil;

        self.broadcast_type = [dict stringForKey:@"broadcast_type" withDefaultValue:nil];
        if (self.broadcast_type == MCTNull)
            self.broadcast_type = nil;

        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        self.default_priority = [dict longForKey:@"default_priority" withDefaultValue:1];

        self.default_sticky = [dict boolForKey:@"default_sticky" withDefaultValue:NO];

        if (![dict containsLongObjectForKey:@"flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flags"];
        self.flags = [dict longForKey:@"flags"];

        self.key = [dict stringForKey:@"key"];
        if (self.key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"key"];
        if (self.key == MCTNull)
            self.key = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        if (![dict containsLongObjectForKey:@"message_type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"message_type"];
        self.message_type = [dict longForKey:@"message_type"];

        self.parent_key = [dict stringForKey:@"parent_key"];
        if (self.parent_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_key"];
        if (self.parent_key == MCTNull)
            self.parent_key = nil;

        self.priority = [dict longForKey:@"priority" withDefaultValue:1];

        self.sender = [dict stringForKey:@"sender"];
        if (self.sender == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"sender"];
        if (self.sender == MCTNull)
            self.sender = nil;

        if (![dict containsLongObjectForKey:@"threadTimestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"threadTimestamp"];
        self.threadTimestamp = [dict longForKey:@"threadTimestamp"];

        self.thread_avatar_hash = [dict stringForKey:@"thread_avatar_hash" withDefaultValue:nil];
        if (self.thread_avatar_hash == MCTNull)
            self.thread_avatar_hash = nil;

        self.thread_background_color = [dict stringForKey:@"thread_background_color" withDefaultValue:nil];
        if (self.thread_background_color == MCTNull)
            self.thread_background_color = nil;

        if (![dict containsLongObjectForKey:@"thread_size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"thread_size"];
        self.thread_size = [dict longForKey:@"thread_size"];

        self.thread_text_color = [dict stringForKey:@"thread_text_color" withDefaultValue:nil];
        if (self.thread_text_color == MCTNull)
            self.thread_text_color = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.attachments == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO.attachments");
    } else if ([self.attachments isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.attachments count]];
        for (MCT_com_mobicage_to_messaging_AttachmentTO *obj in self.attachments)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"attachments"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO.attachments");
    }

    [dict setDict:[self.form dictRepresentation] forKey:@"form"];

    [dict setDict:[self.member dictRepresentation] forKey:@"member"];

    [dict setLong:self.alert_flags forKey:@"alert_flags"];

    [dict setString:self.branding forKey:@"branding"];

    [dict setString:self.broadcast_type forKey:@"broadcast_type"];

    [dict setString:self.context forKey:@"context"];

    [dict setLong:self.default_priority forKey:@"default_priority"];

    [dict setBool:self.default_sticky forKey:@"default_sticky"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setString:self.key forKey:@"key"];

    [dict setString:self.message forKey:@"message"];

    [dict setLong:self.message_type forKey:@"message_type"];

    [dict setString:self.parent_key forKey:@"parent_key"];

    [dict setLong:self.priority forKey:@"priority"];

    [dict setString:self.sender forKey:@"sender"];

    [dict setLong:self.threadTimestamp forKey:@"threadTimestamp"];

    [dict setString:self.thread_avatar_hash forKey:@"thread_avatar_hash"];

    [dict setString:self.thread_background_color forKey:@"thread_background_color"];

    [dict setLong:self.thread_size forKey:@"thread_size"];

    [dict setString:self.thread_text_color forKey:@"thread_text_color"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_MyDigiPassFormTO

@synthesize widget = widget_;
@synthesize javascript_validation = javascript_validation_;
@synthesize negative_button = negative_button_;
@synthesize negative_button_ui_flags = negative_button_ui_flags_;
@synthesize negative_confirmation = negative_confirmation_;
@synthesize positive_button = positive_button_;
@synthesize positive_button_ui_flags = positive_button_ui_flags_;
@synthesize positive_confirmation = positive_confirmation_;
@synthesize type = type_;

- (MCT_com_mobicage_to_messaging_forms_MyDigiPassFormTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_MyDigiPassFormTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"widget"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
        if (tmp_dict_0 == MCTNull)
            self.widget = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_MyDigiPassTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_MyDigiPassTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
            self.widget = (MCT_com_mobicage_to_messaging_forms_MyDigiPassTO *)tmp_to_0;
        }

        self.javascript_validation = [dict stringForKey:@"javascript_validation" withDefaultValue:nil];
        if (self.javascript_validation == MCTNull)
            self.javascript_validation = nil;

        self.negative_button = [dict stringForKey:@"negative_button"];
        if (self.negative_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button"];
        if (self.negative_button == MCTNull)
            self.negative_button = nil;

        if (![dict containsLongObjectForKey:@"negative_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button_ui_flags"];
        self.negative_button_ui_flags = [dict longForKey:@"negative_button_ui_flags"];

        self.negative_confirmation = [dict stringForKey:@"negative_confirmation"];
        if (self.negative_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_confirmation"];
        if (self.negative_confirmation == MCTNull)
            self.negative_confirmation = nil;

        self.positive_button = [dict stringForKey:@"positive_button"];
        if (self.positive_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button"];
        if (self.positive_button == MCTNull)
            self.positive_button = nil;

        if (![dict containsLongObjectForKey:@"positive_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button_ui_flags"];
        self.positive_button_ui_flags = [dict longForKey:@"positive_button_ui_flags"];

        self.positive_confirmation = [dict stringForKey:@"positive_confirmation"];
        if (self.positive_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_confirmation"];
        if (self.positive_confirmation == MCTNull)
            self.positive_confirmation = nil;

        self.type = [dict stringForKey:@"type"];
        if (self.type == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        if (self.type == MCTNull)
            self.type = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassFormTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_MyDigiPassFormTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassFormTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_MyDigiPassFormTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.widget dictRepresentation] forKey:@"widget"];

    [dict setString:self.javascript_validation forKey:@"javascript_validation"];

    [dict setString:self.negative_button forKey:@"negative_button"];

    [dict setLong:self.negative_button_ui_flags forKey:@"negative_button_ui_flags"];

    [dict setString:self.negative_confirmation forKey:@"negative_confirmation"];

    [dict setString:self.positive_button forKey:@"positive_button"];

    [dict setLong:self.positive_button_ui_flags forKey:@"positive_button_ui_flags"];

    [dict setString:self.positive_confirmation forKey:@"positive_confirmation"];

    [dict setString:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_MyDigiPassTO

@synthesize scope = scope_;

- (MCT_com_mobicage_to_messaging_forms_MyDigiPassTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_MyDigiPassTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.scope = [dict stringForKey:@"scope" withDefaultValue:@"eid_profile"];
        if (self.scope == MCTNull)
            self.scope = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_MyDigiPassTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_MyDigiPassTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.scope forKey:@"scope"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO

@synthesize address = address_;
@synthesize eid_address = eid_address_;
@synthesize eid_profile = eid_profile_;
@synthesize profile = profile_;
@synthesize eid_photo = eid_photo_;
@synthesize email = email_;
@synthesize phone = phone_;

- (MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"address" withDefaultValue:nil];
        if (tmp_dict_0 == MCTNull)
            self.address = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_models_properties_forms_MyDigiPassAddress *tmp_to_0 = [MCT_com_mobicage_models_properties_forms_MyDigiPassAddress transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"address"];
            self.address = (MCT_com_mobicage_models_properties_forms_MyDigiPassAddress *)tmp_to_0;
        }

        NSDictionary *tmp_dict_1 = [dict dictForKey:@"eid_address" withDefaultValue:nil];
        if (tmp_dict_1 == MCTNull)
            self.eid_address = nil;
        else if (tmp_dict_1 != nil) {
            MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress *tmp_to_1 = [MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress transferObjectWithDict:tmp_dict_1];
            if (tmp_to_1 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"eid_address"];
            self.eid_address = (MCT_com_mobicage_models_properties_forms_MyDigiPassEidAddress *)tmp_to_1;
        }

        NSDictionary *tmp_dict_2 = [dict dictForKey:@"eid_profile" withDefaultValue:nil];
        if (tmp_dict_2 == MCTNull)
            self.eid_profile = nil;
        else if (tmp_dict_2 != nil) {
            MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile *tmp_to_2 = [MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile transferObjectWithDict:tmp_dict_2];
            if (tmp_to_2 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"eid_profile"];
            self.eid_profile = (MCT_com_mobicage_models_properties_forms_MyDigiPassEidProfile *)tmp_to_2;
        }

        NSDictionary *tmp_dict_3 = [dict dictForKey:@"profile" withDefaultValue:nil];
        if (tmp_dict_3 == MCTNull)
            self.profile = nil;
        else if (tmp_dict_3 != nil) {
            MCT_com_mobicage_models_properties_forms_MyDigiPassProfile *tmp_to_3 = [MCT_com_mobicage_models_properties_forms_MyDigiPassProfile transferObjectWithDict:tmp_dict_3];
            if (tmp_to_3 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"profile"];
            self.profile = (MCT_com_mobicage_models_properties_forms_MyDigiPassProfile *)tmp_to_3;
        }

        self.eid_photo = [dict stringForKey:@"eid_photo" withDefaultValue:nil];
        if (self.eid_photo == MCTNull)
            self.eid_photo = nil;

        self.email = [dict stringForKey:@"email" withDefaultValue:nil];
        if (self.email == MCTNull)
            self.email = nil;

        self.phone = [dict stringForKey:@"phone" withDefaultValue:nil];
        if (self.phone == MCTNull)
            self.phone = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.address dictRepresentation] forKey:@"address"];

    [dict setDict:[self.eid_address dictRepresentation] forKey:@"eid_address"];

    [dict setDict:[self.eid_profile dictRepresentation] forKey:@"eid_profile"];

    [dict setDict:[self.profile dictRepresentation] forKey:@"profile"];

    [dict setString:self.eid_photo forKey:@"eid_photo"];

    [dict setString:self.email forKey:@"email"];

    [dict setString:self.phone forKey:@"phone"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormRequestTO

@synthesize form_message = form_message_;

- (MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"form_message"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
        if (tmp_dict_0 == MCTNull)
            self.form_message = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
            self.form_message = (MCT_com_mobicage_to_messaging_forms_AdvancedOrderFormMessageTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.form_message dictRepresentation] forKey:@"form_message"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormResponseTO

@synthesize received_timestamp = received_timestamp_;

- (MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewAdvancedOrderFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormRequestTO

@synthesize form_message = form_message_;

- (MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"form_message"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
        if (tmp_dict_0 == MCTNull)
            self.form_message = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
            self.form_message = (MCT_com_mobicage_to_messaging_forms_AutoCompleteFormMessageTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.form_message dictRepresentation] forKey:@"form_message"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormResponseTO

@synthesize received_timestamp = received_timestamp_;

- (MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewAutoCompleteFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewDateSelectFormRequestTO

@synthesize form_message = form_message_;

- (MCT_com_mobicage_to_messaging_forms_NewDateSelectFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewDateSelectFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"form_message"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
        if (tmp_dict_0 == MCTNull)
            self.form_message = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
            self.form_message = (MCT_com_mobicage_to_messaging_forms_DateSelectFormMessageTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewDateSelectFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewDateSelectFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewDateSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewDateSelectFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.form_message dictRepresentation] forKey:@"form_message"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewDateSelectFormResponseTO

@synthesize received_timestamp = received_timestamp_;

- (MCT_com_mobicage_to_messaging_forms_NewDateSelectFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewDateSelectFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewDateSelectFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewDateSelectFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewDateSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewDateSelectFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormRequestTO

@synthesize form_message = form_message_;

- (MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"form_message"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
        if (tmp_dict_0 == MCTNull)
            self.form_message = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
            self.form_message = (MCT_com_mobicage_to_messaging_forms_GPSLocationFormMessageTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.form_message dictRepresentation] forKey:@"form_message"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormResponseTO

@synthesize received_timestamp = received_timestamp_;

- (MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewGPSLocationFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormRequestTO

@synthesize form_message = form_message_;

- (MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"form_message"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
        if (tmp_dict_0 == MCTNull)
            self.form_message = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
            self.form_message = (MCT_com_mobicage_to_messaging_forms_MultiSelectFormMessageTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.form_message dictRepresentation] forKey:@"form_message"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormResponseTO

@synthesize received_timestamp = received_timestamp_;

- (MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewMultiSelectFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormRequestTO

@synthesize form_message = form_message_;

- (MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"form_message"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
        if (tmp_dict_0 == MCTNull)
            self.form_message = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
            self.form_message = (MCT_com_mobicage_to_messaging_forms_MyDigiPassFormMessageTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.form_message dictRepresentation] forKey:@"form_message"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormResponseTO

@synthesize received_timestamp = received_timestamp_;

- (MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewMyDigiPassFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormRequestTO

@synthesize form_message = form_message_;

- (MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"form_message"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
        if (tmp_dict_0 == MCTNull)
            self.form_message = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
            self.form_message = (MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.form_message dictRepresentation] forKey:@"form_message"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormResponseTO

@synthesize received_timestamp = received_timestamp_;

- (MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewPhotoUploadFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormRequestTO

@synthesize form_message = form_message_;

- (MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"form_message"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
        if (tmp_dict_0 == MCTNull)
            self.form_message = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
            self.form_message = (MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.form_message dictRepresentation] forKey:@"form_message"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormResponseTO

@synthesize received_timestamp = received_timestamp_;

- (MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewRangeSliderFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormRequestTO

@synthesize form_message = form_message_;

- (MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"form_message"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
        if (tmp_dict_0 == MCTNull)
            self.form_message = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
            self.form_message = (MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.form_message dictRepresentation] forKey:@"form_message"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormResponseTO

@synthesize received_timestamp = received_timestamp_;

- (MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewSingleSelectFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormRequestTO

@synthesize form_message = form_message_;

- (MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"form_message"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
        if (tmp_dict_0 == MCTNull)
            self.form_message = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
            self.form_message = (MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.form_message dictRepresentation] forKey:@"form_message"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormResponseTO

@synthesize received_timestamp = received_timestamp_;

- (MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewSingleSliderFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewTextBlockFormRequestTO

@synthesize form_message = form_message_;

- (MCT_com_mobicage_to_messaging_forms_NewTextBlockFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewTextBlockFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"form_message"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
        if (tmp_dict_0 == MCTNull)
            self.form_message = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
            self.form_message = (MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewTextBlockFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewTextBlockFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewTextBlockFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewTextBlockFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.form_message dictRepresentation] forKey:@"form_message"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewTextBlockFormResponseTO

@synthesize received_timestamp = received_timestamp_;

- (MCT_com_mobicage_to_messaging_forms_NewTextBlockFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewTextBlockFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewTextBlockFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewTextBlockFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewTextBlockFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewTextBlockFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewTextLineFormRequestTO

@synthesize form_message = form_message_;

- (MCT_com_mobicage_to_messaging_forms_NewTextLineFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewTextLineFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"form_message"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
        if (tmp_dict_0 == MCTNull)
            self.form_message = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form_message"];
            self.form_message = (MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewTextLineFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewTextLineFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewTextLineFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewTextLineFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.form_message dictRepresentation] forKey:@"form_message"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_NewTextLineFormResponseTO

@synthesize received_timestamp = received_timestamp_;

- (MCT_com_mobicage_to_messaging_forms_NewTextLineFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_NewTextLineFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_NewTextLineFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_NewTextLineFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_NewTextLineFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_NewTextLineFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO

@synthesize attachments = attachments_;
@synthesize form = form_;
@synthesize member = member_;
@synthesize alert_flags = alert_flags_;
@synthesize branding = branding_;
@synthesize broadcast_type = broadcast_type_;
@synthesize context = context_;
@synthesize default_priority = default_priority_;
@synthesize default_sticky = default_sticky_;
@synthesize flags = flags_;
@synthesize key = key_;
@synthesize message = message_;
@synthesize message_type = message_type_;
@synthesize parent_key = parent_key_;
@synthesize priority = priority_;
@synthesize sender = sender_;
@synthesize threadTimestamp = threadTimestamp_;
@synthesize thread_avatar_hash = thread_avatar_hash_;
@synthesize thread_background_color = thread_background_color_;
@synthesize thread_size = thread_size_;
@synthesize thread_text_color = thread_text_color_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO *)init
{
    if (self = [super init]) {
        self.attachments = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"attachments" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
        if (tmp_dict_array_0 != nil) {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_AttachmentTO *tmp_obj = [MCT_com_mobicage_to_messaging_AttachmentTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.attachments = tmp_obj_array_0;
        }

        NSDictionary *tmp_dict_1 = [dict dictForKey:@"form"];
        if (tmp_dict_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form"];
        if (tmp_dict_1 == MCTNull)
            self.form = nil;
        else if (tmp_dict_1 != nil) {
            MCT_com_mobicage_to_messaging_forms_PhotoUploadFormTO *tmp_to_1 = [MCT_com_mobicage_to_messaging_forms_PhotoUploadFormTO transferObjectWithDict:tmp_dict_1];
            if (tmp_to_1 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form"];
            self.form = (MCT_com_mobicage_to_messaging_forms_PhotoUploadFormTO *)tmp_to_1;
        }

        NSDictionary *tmp_dict_2 = [dict dictForKey:@"member"];
        if (tmp_dict_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"member"];
        if (tmp_dict_2 == MCTNull)
            self.member = nil;
        else if (tmp_dict_2 != nil) {
            MCT_com_mobicage_to_messaging_MemberStatusTO *tmp_to_2 = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObjectWithDict:tmp_dict_2];
            if (tmp_to_2 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"member"];
            self.member = (MCT_com_mobicage_to_messaging_MemberStatusTO *)tmp_to_2;
        }

        if (![dict containsLongObjectForKey:@"alert_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"alert_flags"];
        self.alert_flags = [dict longForKey:@"alert_flags"];

        self.branding = [dict stringForKey:@"branding"];
        if (self.branding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"branding"];
        if (self.branding == MCTNull)
            self.branding = nil;

        self.broadcast_type = [dict stringForKey:@"broadcast_type" withDefaultValue:nil];
        if (self.broadcast_type == MCTNull)
            self.broadcast_type = nil;

        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        self.default_priority = [dict longForKey:@"default_priority" withDefaultValue:1];

        self.default_sticky = [dict boolForKey:@"default_sticky" withDefaultValue:NO];

        if (![dict containsLongObjectForKey:@"flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flags"];
        self.flags = [dict longForKey:@"flags"];

        self.key = [dict stringForKey:@"key"];
        if (self.key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"key"];
        if (self.key == MCTNull)
            self.key = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        if (![dict containsLongObjectForKey:@"message_type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"message_type"];
        self.message_type = [dict longForKey:@"message_type"];

        self.parent_key = [dict stringForKey:@"parent_key"];
        if (self.parent_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_key"];
        if (self.parent_key == MCTNull)
            self.parent_key = nil;

        self.priority = [dict longForKey:@"priority" withDefaultValue:1];

        self.sender = [dict stringForKey:@"sender"];
        if (self.sender == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"sender"];
        if (self.sender == MCTNull)
            self.sender = nil;

        if (![dict containsLongObjectForKey:@"threadTimestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"threadTimestamp"];
        self.threadTimestamp = [dict longForKey:@"threadTimestamp"];

        self.thread_avatar_hash = [dict stringForKey:@"thread_avatar_hash" withDefaultValue:nil];
        if (self.thread_avatar_hash == MCTNull)
            self.thread_avatar_hash = nil;

        self.thread_background_color = [dict stringForKey:@"thread_background_color" withDefaultValue:nil];
        if (self.thread_background_color == MCTNull)
            self.thread_background_color = nil;

        if (![dict containsLongObjectForKey:@"thread_size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"thread_size"];
        self.thread_size = [dict longForKey:@"thread_size"];

        self.thread_text_color = [dict stringForKey:@"thread_text_color" withDefaultValue:nil];
        if (self.thread_text_color == MCTNull)
            self.thread_text_color = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.attachments == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO.attachments");
    } else if ([self.attachments isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.attachments count]];
        for (MCT_com_mobicage_to_messaging_AttachmentTO *obj in self.attachments)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"attachments"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_PhotoUploadFormMessageTO.attachments");
    }

    [dict setDict:[self.form dictRepresentation] forKey:@"form"];

    [dict setDict:[self.member dictRepresentation] forKey:@"member"];

    [dict setLong:self.alert_flags forKey:@"alert_flags"];

    [dict setString:self.branding forKey:@"branding"];

    [dict setString:self.broadcast_type forKey:@"broadcast_type"];

    [dict setString:self.context forKey:@"context"];

    [dict setLong:self.default_priority forKey:@"default_priority"];

    [dict setBool:self.default_sticky forKey:@"default_sticky"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setString:self.key forKey:@"key"];

    [dict setString:self.message forKey:@"message"];

    [dict setLong:self.message_type forKey:@"message_type"];

    [dict setString:self.parent_key forKey:@"parent_key"];

    [dict setLong:self.priority forKey:@"priority"];

    [dict setString:self.sender forKey:@"sender"];

    [dict setLong:self.threadTimestamp forKey:@"threadTimestamp"];

    [dict setString:self.thread_avatar_hash forKey:@"thread_avatar_hash"];

    [dict setString:self.thread_background_color forKey:@"thread_background_color"];

    [dict setLong:self.thread_size forKey:@"thread_size"];

    [dict setString:self.thread_text_color forKey:@"thread_text_color"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_PhotoUploadFormTO

@synthesize widget = widget_;
@synthesize javascript_validation = javascript_validation_;
@synthesize negative_button = negative_button_;
@synthesize negative_button_ui_flags = negative_button_ui_flags_;
@synthesize negative_confirmation = negative_confirmation_;
@synthesize positive_button = positive_button_;
@synthesize positive_button_ui_flags = positive_button_ui_flags_;
@synthesize positive_confirmation = positive_confirmation_;
@synthesize type = type_;

- (MCT_com_mobicage_to_messaging_forms_PhotoUploadFormTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_PhotoUploadFormTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"widget"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
        if (tmp_dict_0 == MCTNull)
            self.widget = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_PhotoUploadTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_PhotoUploadTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
            self.widget = (MCT_com_mobicage_to_messaging_forms_PhotoUploadTO *)tmp_to_0;
        }

        self.javascript_validation = [dict stringForKey:@"javascript_validation" withDefaultValue:nil];
        if (self.javascript_validation == MCTNull)
            self.javascript_validation = nil;

        self.negative_button = [dict stringForKey:@"negative_button"];
        if (self.negative_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button"];
        if (self.negative_button == MCTNull)
            self.negative_button = nil;

        if (![dict containsLongObjectForKey:@"negative_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button_ui_flags"];
        self.negative_button_ui_flags = [dict longForKey:@"negative_button_ui_flags"];

        self.negative_confirmation = [dict stringForKey:@"negative_confirmation"];
        if (self.negative_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_confirmation"];
        if (self.negative_confirmation == MCTNull)
            self.negative_confirmation = nil;

        self.positive_button = [dict stringForKey:@"positive_button"];
        if (self.positive_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button"];
        if (self.positive_button == MCTNull)
            self.positive_button = nil;

        if (![dict containsLongObjectForKey:@"positive_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button_ui_flags"];
        self.positive_button_ui_flags = [dict longForKey:@"positive_button_ui_flags"];

        self.positive_confirmation = [dict stringForKey:@"positive_confirmation"];
        if (self.positive_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_confirmation"];
        if (self.positive_confirmation == MCTNull)
            self.positive_confirmation = nil;

        self.type = [dict stringForKey:@"type"];
        if (self.type == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        if (self.type == MCTNull)
            self.type = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_PhotoUploadFormTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_PhotoUploadFormTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_PhotoUploadFormTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_PhotoUploadFormTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.widget dictRepresentation] forKey:@"widget"];

    [dict setString:self.javascript_validation forKey:@"javascript_validation"];

    [dict setString:self.negative_button forKey:@"negative_button"];

    [dict setLong:self.negative_button_ui_flags forKey:@"negative_button_ui_flags"];

    [dict setString:self.negative_confirmation forKey:@"negative_confirmation"];

    [dict setString:self.positive_button forKey:@"positive_button"];

    [dict setLong:self.positive_button_ui_flags forKey:@"positive_button_ui_flags"];

    [dict setString:self.positive_confirmation forKey:@"positive_confirmation"];

    [dict setString:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_PhotoUploadTO

@synthesize camera = camera_;
@synthesize gallery = gallery_;
@synthesize quality = quality_;
@synthesize ratio = ratio_;

- (MCT_com_mobicage_to_messaging_forms_PhotoUploadTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_PhotoUploadTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsBoolObjectForKey:@"camera"])
            return [self errorDuringInitBecauseOfFieldWithName:@"camera"];
        self.camera = [dict boolForKey:@"camera"];

        if (![dict containsBoolObjectForKey:@"gallery"])
            return [self errorDuringInitBecauseOfFieldWithName:@"gallery"];
        self.gallery = [dict boolForKey:@"gallery"];

        self.quality = [dict stringForKey:@"quality"];
        if (self.quality == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"quality"];
        if (self.quality == MCTNull)
            self.quality = nil;

        self.ratio = [dict stringForKey:@"ratio"];
        if (self.ratio == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"ratio"];
        if (self.ratio == MCTNull)
            self.ratio = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_PhotoUploadTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_PhotoUploadTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_PhotoUploadTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_PhotoUploadTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setBool:self.camera forKey:@"camera"];

    [dict setBool:self.gallery forKey:@"gallery"];

    [dict setString:self.quality forKey:@"quality"];

    [dict setString:self.ratio forKey:@"ratio"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO

@synthesize attachments = attachments_;
@synthesize form = form_;
@synthesize member = member_;
@synthesize alert_flags = alert_flags_;
@synthesize branding = branding_;
@synthesize broadcast_type = broadcast_type_;
@synthesize context = context_;
@synthesize default_priority = default_priority_;
@synthesize default_sticky = default_sticky_;
@synthesize flags = flags_;
@synthesize key = key_;
@synthesize message = message_;
@synthesize message_type = message_type_;
@synthesize parent_key = parent_key_;
@synthesize priority = priority_;
@synthesize sender = sender_;
@synthesize threadTimestamp = threadTimestamp_;
@synthesize thread_avatar_hash = thread_avatar_hash_;
@synthesize thread_background_color = thread_background_color_;
@synthesize thread_size = thread_size_;
@synthesize thread_text_color = thread_text_color_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO *)init
{
    if (self = [super init]) {
        self.attachments = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"attachments" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
        if (tmp_dict_array_0 != nil) {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_AttachmentTO *tmp_obj = [MCT_com_mobicage_to_messaging_AttachmentTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.attachments = tmp_obj_array_0;
        }

        NSDictionary *tmp_dict_1 = [dict dictForKey:@"form"];
        if (tmp_dict_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form"];
        if (tmp_dict_1 == MCTNull)
            self.form = nil;
        else if (tmp_dict_1 != nil) {
            MCT_com_mobicage_to_messaging_forms_RangeSliderFormTO *tmp_to_1 = [MCT_com_mobicage_to_messaging_forms_RangeSliderFormTO transferObjectWithDict:tmp_dict_1];
            if (tmp_to_1 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form"];
            self.form = (MCT_com_mobicage_to_messaging_forms_RangeSliderFormTO *)tmp_to_1;
        }

        NSDictionary *tmp_dict_2 = [dict dictForKey:@"member"];
        if (tmp_dict_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"member"];
        if (tmp_dict_2 == MCTNull)
            self.member = nil;
        else if (tmp_dict_2 != nil) {
            MCT_com_mobicage_to_messaging_MemberStatusTO *tmp_to_2 = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObjectWithDict:tmp_dict_2];
            if (tmp_to_2 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"member"];
            self.member = (MCT_com_mobicage_to_messaging_MemberStatusTO *)tmp_to_2;
        }

        if (![dict containsLongObjectForKey:@"alert_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"alert_flags"];
        self.alert_flags = [dict longForKey:@"alert_flags"];

        self.branding = [dict stringForKey:@"branding"];
        if (self.branding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"branding"];
        if (self.branding == MCTNull)
            self.branding = nil;

        self.broadcast_type = [dict stringForKey:@"broadcast_type" withDefaultValue:nil];
        if (self.broadcast_type == MCTNull)
            self.broadcast_type = nil;

        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        self.default_priority = [dict longForKey:@"default_priority" withDefaultValue:1];

        self.default_sticky = [dict boolForKey:@"default_sticky" withDefaultValue:NO];

        if (![dict containsLongObjectForKey:@"flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flags"];
        self.flags = [dict longForKey:@"flags"];

        self.key = [dict stringForKey:@"key"];
        if (self.key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"key"];
        if (self.key == MCTNull)
            self.key = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        if (![dict containsLongObjectForKey:@"message_type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"message_type"];
        self.message_type = [dict longForKey:@"message_type"];

        self.parent_key = [dict stringForKey:@"parent_key"];
        if (self.parent_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_key"];
        if (self.parent_key == MCTNull)
            self.parent_key = nil;

        self.priority = [dict longForKey:@"priority" withDefaultValue:1];

        self.sender = [dict stringForKey:@"sender"];
        if (self.sender == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"sender"];
        if (self.sender == MCTNull)
            self.sender = nil;

        if (![dict containsLongObjectForKey:@"threadTimestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"threadTimestamp"];
        self.threadTimestamp = [dict longForKey:@"threadTimestamp"];

        self.thread_avatar_hash = [dict stringForKey:@"thread_avatar_hash" withDefaultValue:nil];
        if (self.thread_avatar_hash == MCTNull)
            self.thread_avatar_hash = nil;

        self.thread_background_color = [dict stringForKey:@"thread_background_color" withDefaultValue:nil];
        if (self.thread_background_color == MCTNull)
            self.thread_background_color = nil;

        if (![dict containsLongObjectForKey:@"thread_size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"thread_size"];
        self.thread_size = [dict longForKey:@"thread_size"];

        self.thread_text_color = [dict stringForKey:@"thread_text_color" withDefaultValue:nil];
        if (self.thread_text_color == MCTNull)
            self.thread_text_color = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.attachments == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO.attachments");
    } else if ([self.attachments isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.attachments count]];
        for (MCT_com_mobicage_to_messaging_AttachmentTO *obj in self.attachments)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"attachments"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_RangeSliderFormMessageTO.attachments");
    }

    [dict setDict:[self.form dictRepresentation] forKey:@"form"];

    [dict setDict:[self.member dictRepresentation] forKey:@"member"];

    [dict setLong:self.alert_flags forKey:@"alert_flags"];

    [dict setString:self.branding forKey:@"branding"];

    [dict setString:self.broadcast_type forKey:@"broadcast_type"];

    [dict setString:self.context forKey:@"context"];

    [dict setLong:self.default_priority forKey:@"default_priority"];

    [dict setBool:self.default_sticky forKey:@"default_sticky"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setString:self.key forKey:@"key"];

    [dict setString:self.message forKey:@"message"];

    [dict setLong:self.message_type forKey:@"message_type"];

    [dict setString:self.parent_key forKey:@"parent_key"];

    [dict setLong:self.priority forKey:@"priority"];

    [dict setString:self.sender forKey:@"sender"];

    [dict setLong:self.threadTimestamp forKey:@"threadTimestamp"];

    [dict setString:self.thread_avatar_hash forKey:@"thread_avatar_hash"];

    [dict setString:self.thread_background_color forKey:@"thread_background_color"];

    [dict setLong:self.thread_size forKey:@"thread_size"];

    [dict setString:self.thread_text_color forKey:@"thread_text_color"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_RangeSliderFormTO

@synthesize widget = widget_;
@synthesize javascript_validation = javascript_validation_;
@synthesize negative_button = negative_button_;
@synthesize negative_button_ui_flags = negative_button_ui_flags_;
@synthesize negative_confirmation = negative_confirmation_;
@synthesize positive_button = positive_button_;
@synthesize positive_button_ui_flags = positive_button_ui_flags_;
@synthesize positive_confirmation = positive_confirmation_;
@synthesize type = type_;

- (MCT_com_mobicage_to_messaging_forms_RangeSliderFormTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_RangeSliderFormTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"widget"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
        if (tmp_dict_0 == MCTNull)
            self.widget = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_RangeSliderTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_RangeSliderTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
            self.widget = (MCT_com_mobicage_to_messaging_forms_RangeSliderTO *)tmp_to_0;
        }

        self.javascript_validation = [dict stringForKey:@"javascript_validation" withDefaultValue:nil];
        if (self.javascript_validation == MCTNull)
            self.javascript_validation = nil;

        self.negative_button = [dict stringForKey:@"negative_button"];
        if (self.negative_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button"];
        if (self.negative_button == MCTNull)
            self.negative_button = nil;

        if (![dict containsLongObjectForKey:@"negative_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button_ui_flags"];
        self.negative_button_ui_flags = [dict longForKey:@"negative_button_ui_flags"];

        self.negative_confirmation = [dict stringForKey:@"negative_confirmation"];
        if (self.negative_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_confirmation"];
        if (self.negative_confirmation == MCTNull)
            self.negative_confirmation = nil;

        self.positive_button = [dict stringForKey:@"positive_button"];
        if (self.positive_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button"];
        if (self.positive_button == MCTNull)
            self.positive_button = nil;

        if (![dict containsLongObjectForKey:@"positive_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button_ui_flags"];
        self.positive_button_ui_flags = [dict longForKey:@"positive_button_ui_flags"];

        self.positive_confirmation = [dict stringForKey:@"positive_confirmation"];
        if (self.positive_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_confirmation"];
        if (self.positive_confirmation == MCTNull)
            self.positive_confirmation = nil;

        self.type = [dict stringForKey:@"type"];
        if (self.type == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        if (self.type == MCTNull)
            self.type = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_RangeSliderFormTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_RangeSliderFormTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_RangeSliderFormTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_RangeSliderFormTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.widget dictRepresentation] forKey:@"widget"];

    [dict setString:self.javascript_validation forKey:@"javascript_validation"];

    [dict setString:self.negative_button forKey:@"negative_button"];

    [dict setLong:self.negative_button_ui_flags forKey:@"negative_button_ui_flags"];

    [dict setString:self.negative_confirmation forKey:@"negative_confirmation"];

    [dict setString:self.positive_button forKey:@"positive_button"];

    [dict setLong:self.positive_button_ui_flags forKey:@"positive_button_ui_flags"];

    [dict setString:self.positive_confirmation forKey:@"positive_confirmation"];

    [dict setString:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_RangeSliderTO

@synthesize high_value = high_value_;
@synthesize low_value = low_value_;
@synthesize max = max_;
@synthesize min = min_;
@synthesize precision = precision_;
@synthesize step = step_;
@synthesize unit = unit_;

- (MCT_com_mobicage_to_messaging_forms_RangeSliderTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_RangeSliderTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsFloatObjectForKey:@"high_value"])
            return [self errorDuringInitBecauseOfFieldWithName:@"high_value"];
        else
            self.high_value = [dict floatForKey:@"high_value"];

        if (![dict containsFloatObjectForKey:@"low_value"])
            return [self errorDuringInitBecauseOfFieldWithName:@"low_value"];
        else
            self.low_value = [dict floatForKey:@"low_value"];

        if (![dict containsFloatObjectForKey:@"max"])
            return [self errorDuringInitBecauseOfFieldWithName:@"max"];
        else
            self.max = [dict floatForKey:@"max"];

        if (![dict containsFloatObjectForKey:@"min"])
            return [self errorDuringInitBecauseOfFieldWithName:@"min"];
        else
            self.min = [dict floatForKey:@"min"];

        if (![dict containsLongObjectForKey:@"precision"])
            return [self errorDuringInitBecauseOfFieldWithName:@"precision"];
        self.precision = [dict longForKey:@"precision"];

        if (![dict containsFloatObjectForKey:@"step"])
            return [self errorDuringInitBecauseOfFieldWithName:@"step"];
        else
            self.step = [dict floatForKey:@"step"];

        self.unit = [dict stringForKey:@"unit"];
        if (self.unit == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"unit"];
        if (self.unit == MCTNull)
            self.unit = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_RangeSliderTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_RangeSliderTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_RangeSliderTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_RangeSliderTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setFloat:self.high_value forKey:@"high_value"];

    [dict setFloat:self.low_value forKey:@"low_value"];

    [dict setFloat:self.max forKey:@"max"];

    [dict setFloat:self.min forKey:@"min"];

    [dict setLong:self.precision forKey:@"precision"];

    [dict setFloat:self.step forKey:@"step"];

    [dict setString:self.unit forKey:@"unit"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO

@synthesize attachments = attachments_;
@synthesize form = form_;
@synthesize member = member_;
@synthesize alert_flags = alert_flags_;
@synthesize branding = branding_;
@synthesize broadcast_type = broadcast_type_;
@synthesize context = context_;
@synthesize default_priority = default_priority_;
@synthesize default_sticky = default_sticky_;
@synthesize flags = flags_;
@synthesize key = key_;
@synthesize message = message_;
@synthesize message_type = message_type_;
@synthesize parent_key = parent_key_;
@synthesize priority = priority_;
@synthesize sender = sender_;
@synthesize threadTimestamp = threadTimestamp_;
@synthesize thread_avatar_hash = thread_avatar_hash_;
@synthesize thread_background_color = thread_background_color_;
@synthesize thread_size = thread_size_;
@synthesize thread_text_color = thread_text_color_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO *)init
{
    if (self = [super init]) {
        self.attachments = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"attachments" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
        if (tmp_dict_array_0 != nil) {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_AttachmentTO *tmp_obj = [MCT_com_mobicage_to_messaging_AttachmentTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.attachments = tmp_obj_array_0;
        }

        NSDictionary *tmp_dict_1 = [dict dictForKey:@"form"];
        if (tmp_dict_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form"];
        if (tmp_dict_1 == MCTNull)
            self.form = nil;
        else if (tmp_dict_1 != nil) {
            MCT_com_mobicage_to_messaging_forms_SingleSelectFormTO *tmp_to_1 = [MCT_com_mobicage_to_messaging_forms_SingleSelectFormTO transferObjectWithDict:tmp_dict_1];
            if (tmp_to_1 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form"];
            self.form = (MCT_com_mobicage_to_messaging_forms_SingleSelectFormTO *)tmp_to_1;
        }

        NSDictionary *tmp_dict_2 = [dict dictForKey:@"member"];
        if (tmp_dict_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"member"];
        if (tmp_dict_2 == MCTNull)
            self.member = nil;
        else if (tmp_dict_2 != nil) {
            MCT_com_mobicage_to_messaging_MemberStatusTO *tmp_to_2 = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObjectWithDict:tmp_dict_2];
            if (tmp_to_2 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"member"];
            self.member = (MCT_com_mobicage_to_messaging_MemberStatusTO *)tmp_to_2;
        }

        if (![dict containsLongObjectForKey:@"alert_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"alert_flags"];
        self.alert_flags = [dict longForKey:@"alert_flags"];

        self.branding = [dict stringForKey:@"branding"];
        if (self.branding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"branding"];
        if (self.branding == MCTNull)
            self.branding = nil;

        self.broadcast_type = [dict stringForKey:@"broadcast_type" withDefaultValue:nil];
        if (self.broadcast_type == MCTNull)
            self.broadcast_type = nil;

        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        self.default_priority = [dict longForKey:@"default_priority" withDefaultValue:1];

        self.default_sticky = [dict boolForKey:@"default_sticky" withDefaultValue:NO];

        if (![dict containsLongObjectForKey:@"flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flags"];
        self.flags = [dict longForKey:@"flags"];

        self.key = [dict stringForKey:@"key"];
        if (self.key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"key"];
        if (self.key == MCTNull)
            self.key = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        if (![dict containsLongObjectForKey:@"message_type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"message_type"];
        self.message_type = [dict longForKey:@"message_type"];

        self.parent_key = [dict stringForKey:@"parent_key"];
        if (self.parent_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_key"];
        if (self.parent_key == MCTNull)
            self.parent_key = nil;

        self.priority = [dict longForKey:@"priority" withDefaultValue:1];

        self.sender = [dict stringForKey:@"sender"];
        if (self.sender == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"sender"];
        if (self.sender == MCTNull)
            self.sender = nil;

        if (![dict containsLongObjectForKey:@"threadTimestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"threadTimestamp"];
        self.threadTimestamp = [dict longForKey:@"threadTimestamp"];

        self.thread_avatar_hash = [dict stringForKey:@"thread_avatar_hash" withDefaultValue:nil];
        if (self.thread_avatar_hash == MCTNull)
            self.thread_avatar_hash = nil;

        self.thread_background_color = [dict stringForKey:@"thread_background_color" withDefaultValue:nil];
        if (self.thread_background_color == MCTNull)
            self.thread_background_color = nil;

        if (![dict containsLongObjectForKey:@"thread_size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"thread_size"];
        self.thread_size = [dict longForKey:@"thread_size"];

        self.thread_text_color = [dict stringForKey:@"thread_text_color" withDefaultValue:nil];
        if (self.thread_text_color == MCTNull)
            self.thread_text_color = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.attachments == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO.attachments");
    } else if ([self.attachments isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.attachments count]];
        for (MCT_com_mobicage_to_messaging_AttachmentTO *obj in self.attachments)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"attachments"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_SingleSelectFormMessageTO.attachments");
    }

    [dict setDict:[self.form dictRepresentation] forKey:@"form"];

    [dict setDict:[self.member dictRepresentation] forKey:@"member"];

    [dict setLong:self.alert_flags forKey:@"alert_flags"];

    [dict setString:self.branding forKey:@"branding"];

    [dict setString:self.broadcast_type forKey:@"broadcast_type"];

    [dict setString:self.context forKey:@"context"];

    [dict setLong:self.default_priority forKey:@"default_priority"];

    [dict setBool:self.default_sticky forKey:@"default_sticky"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setString:self.key forKey:@"key"];

    [dict setString:self.message forKey:@"message"];

    [dict setLong:self.message_type forKey:@"message_type"];

    [dict setString:self.parent_key forKey:@"parent_key"];

    [dict setLong:self.priority forKey:@"priority"];

    [dict setString:self.sender forKey:@"sender"];

    [dict setLong:self.threadTimestamp forKey:@"threadTimestamp"];

    [dict setString:self.thread_avatar_hash forKey:@"thread_avatar_hash"];

    [dict setString:self.thread_background_color forKey:@"thread_background_color"];

    [dict setLong:self.thread_size forKey:@"thread_size"];

    [dict setString:self.thread_text_color forKey:@"thread_text_color"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SingleSelectFormTO

@synthesize widget = widget_;
@synthesize javascript_validation = javascript_validation_;
@synthesize negative_button = negative_button_;
@synthesize negative_button_ui_flags = negative_button_ui_flags_;
@synthesize negative_confirmation = negative_confirmation_;
@synthesize positive_button = positive_button_;
@synthesize positive_button_ui_flags = positive_button_ui_flags_;
@synthesize positive_confirmation = positive_confirmation_;
@synthesize type = type_;

- (MCT_com_mobicage_to_messaging_forms_SingleSelectFormTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SingleSelectFormTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"widget"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
        if (tmp_dict_0 == MCTNull)
            self.widget = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_SingleSelectTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_SingleSelectTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
            self.widget = (MCT_com_mobicage_to_messaging_forms_SingleSelectTO *)tmp_to_0;
        }

        self.javascript_validation = [dict stringForKey:@"javascript_validation" withDefaultValue:nil];
        if (self.javascript_validation == MCTNull)
            self.javascript_validation = nil;

        self.negative_button = [dict stringForKey:@"negative_button"];
        if (self.negative_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button"];
        if (self.negative_button == MCTNull)
            self.negative_button = nil;

        if (![dict containsLongObjectForKey:@"negative_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button_ui_flags"];
        self.negative_button_ui_flags = [dict longForKey:@"negative_button_ui_flags"];

        self.negative_confirmation = [dict stringForKey:@"negative_confirmation"];
        if (self.negative_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_confirmation"];
        if (self.negative_confirmation == MCTNull)
            self.negative_confirmation = nil;

        self.positive_button = [dict stringForKey:@"positive_button"];
        if (self.positive_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button"];
        if (self.positive_button == MCTNull)
            self.positive_button = nil;

        if (![dict containsLongObjectForKey:@"positive_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button_ui_flags"];
        self.positive_button_ui_flags = [dict longForKey:@"positive_button_ui_flags"];

        self.positive_confirmation = [dict stringForKey:@"positive_confirmation"];
        if (self.positive_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_confirmation"];
        if (self.positive_confirmation == MCTNull)
            self.positive_confirmation = nil;

        self.type = [dict stringForKey:@"type"];
        if (self.type == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        if (self.type == MCTNull)
            self.type = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SingleSelectFormTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SingleSelectFormTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SingleSelectFormTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SingleSelectFormTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.widget dictRepresentation] forKey:@"widget"];

    [dict setString:self.javascript_validation forKey:@"javascript_validation"];

    [dict setString:self.negative_button forKey:@"negative_button"];

    [dict setLong:self.negative_button_ui_flags forKey:@"negative_button_ui_flags"];

    [dict setString:self.negative_confirmation forKey:@"negative_confirmation"];

    [dict setString:self.positive_button forKey:@"positive_button"];

    [dict setLong:self.positive_button_ui_flags forKey:@"positive_button_ui_flags"];

    [dict setString:self.positive_confirmation forKey:@"positive_confirmation"];

    [dict setString:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SingleSelectTO

@synthesize choices = choices_;
@synthesize value = value_;

- (MCT_com_mobicage_to_messaging_forms_SingleSelectTO *)init
{
    if (self = [super init]) {
        self.choices = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SingleSelectTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"choices"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"choices"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"choices"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_forms_ChoiceTO *tmp_obj = [MCT_com_mobicage_to_messaging_forms_ChoiceTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"choices"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.choices = tmp_obj_array_0;
        }

        self.value = [dict stringForKey:@"value"];
        if (self.value == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"value"];
        if (self.value == MCTNull)
            self.value = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SingleSelectTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SingleSelectTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SingleSelectTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SingleSelectTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.choices == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_SingleSelectTO.choices");
    } else if ([self.choices isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.choices count]];
        for (MCT_com_mobicage_to_messaging_forms_ChoiceTO *obj in self.choices)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"choices"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_SingleSelectTO.choices");
    }

    [dict setString:self.value forKey:@"value"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO

@synthesize attachments = attachments_;
@synthesize form = form_;
@synthesize member = member_;
@synthesize alert_flags = alert_flags_;
@synthesize branding = branding_;
@synthesize broadcast_type = broadcast_type_;
@synthesize context = context_;
@synthesize default_priority = default_priority_;
@synthesize default_sticky = default_sticky_;
@synthesize flags = flags_;
@synthesize key = key_;
@synthesize message = message_;
@synthesize message_type = message_type_;
@synthesize parent_key = parent_key_;
@synthesize priority = priority_;
@synthesize sender = sender_;
@synthesize threadTimestamp = threadTimestamp_;
@synthesize thread_avatar_hash = thread_avatar_hash_;
@synthesize thread_background_color = thread_background_color_;
@synthesize thread_size = thread_size_;
@synthesize thread_text_color = thread_text_color_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO *)init
{
    if (self = [super init]) {
        self.attachments = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"attachments" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
        if (tmp_dict_array_0 != nil) {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_AttachmentTO *tmp_obj = [MCT_com_mobicage_to_messaging_AttachmentTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.attachments = tmp_obj_array_0;
        }

        NSDictionary *tmp_dict_1 = [dict dictForKey:@"form"];
        if (tmp_dict_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form"];
        if (tmp_dict_1 == MCTNull)
            self.form = nil;
        else if (tmp_dict_1 != nil) {
            MCT_com_mobicage_to_messaging_forms_SingleSliderFormTO *tmp_to_1 = [MCT_com_mobicage_to_messaging_forms_SingleSliderFormTO transferObjectWithDict:tmp_dict_1];
            if (tmp_to_1 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form"];
            self.form = (MCT_com_mobicage_to_messaging_forms_SingleSliderFormTO *)tmp_to_1;
        }

        NSDictionary *tmp_dict_2 = [dict dictForKey:@"member"];
        if (tmp_dict_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"member"];
        if (tmp_dict_2 == MCTNull)
            self.member = nil;
        else if (tmp_dict_2 != nil) {
            MCT_com_mobicage_to_messaging_MemberStatusTO *tmp_to_2 = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObjectWithDict:tmp_dict_2];
            if (tmp_to_2 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"member"];
            self.member = (MCT_com_mobicage_to_messaging_MemberStatusTO *)tmp_to_2;
        }

        if (![dict containsLongObjectForKey:@"alert_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"alert_flags"];
        self.alert_flags = [dict longForKey:@"alert_flags"];

        self.branding = [dict stringForKey:@"branding"];
        if (self.branding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"branding"];
        if (self.branding == MCTNull)
            self.branding = nil;

        self.broadcast_type = [dict stringForKey:@"broadcast_type" withDefaultValue:nil];
        if (self.broadcast_type == MCTNull)
            self.broadcast_type = nil;

        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        self.default_priority = [dict longForKey:@"default_priority" withDefaultValue:1];

        self.default_sticky = [dict boolForKey:@"default_sticky" withDefaultValue:NO];

        if (![dict containsLongObjectForKey:@"flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flags"];
        self.flags = [dict longForKey:@"flags"];

        self.key = [dict stringForKey:@"key"];
        if (self.key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"key"];
        if (self.key == MCTNull)
            self.key = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        if (![dict containsLongObjectForKey:@"message_type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"message_type"];
        self.message_type = [dict longForKey:@"message_type"];

        self.parent_key = [dict stringForKey:@"parent_key"];
        if (self.parent_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_key"];
        if (self.parent_key == MCTNull)
            self.parent_key = nil;

        self.priority = [dict longForKey:@"priority" withDefaultValue:1];

        self.sender = [dict stringForKey:@"sender"];
        if (self.sender == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"sender"];
        if (self.sender == MCTNull)
            self.sender = nil;

        if (![dict containsLongObjectForKey:@"threadTimestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"threadTimestamp"];
        self.threadTimestamp = [dict longForKey:@"threadTimestamp"];

        self.thread_avatar_hash = [dict stringForKey:@"thread_avatar_hash" withDefaultValue:nil];
        if (self.thread_avatar_hash == MCTNull)
            self.thread_avatar_hash = nil;

        self.thread_background_color = [dict stringForKey:@"thread_background_color" withDefaultValue:nil];
        if (self.thread_background_color == MCTNull)
            self.thread_background_color = nil;

        if (![dict containsLongObjectForKey:@"thread_size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"thread_size"];
        self.thread_size = [dict longForKey:@"thread_size"];

        self.thread_text_color = [dict stringForKey:@"thread_text_color" withDefaultValue:nil];
        if (self.thread_text_color == MCTNull)
            self.thread_text_color = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.attachments == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO.attachments");
    } else if ([self.attachments isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.attachments count]];
        for (MCT_com_mobicage_to_messaging_AttachmentTO *obj in self.attachments)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"attachments"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_SingleSliderFormMessageTO.attachments");
    }

    [dict setDict:[self.form dictRepresentation] forKey:@"form"];

    [dict setDict:[self.member dictRepresentation] forKey:@"member"];

    [dict setLong:self.alert_flags forKey:@"alert_flags"];

    [dict setString:self.branding forKey:@"branding"];

    [dict setString:self.broadcast_type forKey:@"broadcast_type"];

    [dict setString:self.context forKey:@"context"];

    [dict setLong:self.default_priority forKey:@"default_priority"];

    [dict setBool:self.default_sticky forKey:@"default_sticky"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setString:self.key forKey:@"key"];

    [dict setString:self.message forKey:@"message"];

    [dict setLong:self.message_type forKey:@"message_type"];

    [dict setString:self.parent_key forKey:@"parent_key"];

    [dict setLong:self.priority forKey:@"priority"];

    [dict setString:self.sender forKey:@"sender"];

    [dict setLong:self.threadTimestamp forKey:@"threadTimestamp"];

    [dict setString:self.thread_avatar_hash forKey:@"thread_avatar_hash"];

    [dict setString:self.thread_background_color forKey:@"thread_background_color"];

    [dict setLong:self.thread_size forKey:@"thread_size"];

    [dict setString:self.thread_text_color forKey:@"thread_text_color"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SingleSliderFormTO

@synthesize widget = widget_;
@synthesize javascript_validation = javascript_validation_;
@synthesize negative_button = negative_button_;
@synthesize negative_button_ui_flags = negative_button_ui_flags_;
@synthesize negative_confirmation = negative_confirmation_;
@synthesize positive_button = positive_button_;
@synthesize positive_button_ui_flags = positive_button_ui_flags_;
@synthesize positive_confirmation = positive_confirmation_;
@synthesize type = type_;

- (MCT_com_mobicage_to_messaging_forms_SingleSliderFormTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SingleSliderFormTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"widget"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
        if (tmp_dict_0 == MCTNull)
            self.widget = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_SingleSliderTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_SingleSliderTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
            self.widget = (MCT_com_mobicage_to_messaging_forms_SingleSliderTO *)tmp_to_0;
        }

        self.javascript_validation = [dict stringForKey:@"javascript_validation" withDefaultValue:nil];
        if (self.javascript_validation == MCTNull)
            self.javascript_validation = nil;

        self.negative_button = [dict stringForKey:@"negative_button"];
        if (self.negative_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button"];
        if (self.negative_button == MCTNull)
            self.negative_button = nil;

        if (![dict containsLongObjectForKey:@"negative_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button_ui_flags"];
        self.negative_button_ui_flags = [dict longForKey:@"negative_button_ui_flags"];

        self.negative_confirmation = [dict stringForKey:@"negative_confirmation"];
        if (self.negative_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_confirmation"];
        if (self.negative_confirmation == MCTNull)
            self.negative_confirmation = nil;

        self.positive_button = [dict stringForKey:@"positive_button"];
        if (self.positive_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button"];
        if (self.positive_button == MCTNull)
            self.positive_button = nil;

        if (![dict containsLongObjectForKey:@"positive_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button_ui_flags"];
        self.positive_button_ui_flags = [dict longForKey:@"positive_button_ui_flags"];

        self.positive_confirmation = [dict stringForKey:@"positive_confirmation"];
        if (self.positive_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_confirmation"];
        if (self.positive_confirmation == MCTNull)
            self.positive_confirmation = nil;

        self.type = [dict stringForKey:@"type"];
        if (self.type == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        if (self.type == MCTNull)
            self.type = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SingleSliderFormTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SingleSliderFormTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SingleSliderFormTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SingleSliderFormTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.widget dictRepresentation] forKey:@"widget"];

    [dict setString:self.javascript_validation forKey:@"javascript_validation"];

    [dict setString:self.negative_button forKey:@"negative_button"];

    [dict setLong:self.negative_button_ui_flags forKey:@"negative_button_ui_flags"];

    [dict setString:self.negative_confirmation forKey:@"negative_confirmation"];

    [dict setString:self.positive_button forKey:@"positive_button"];

    [dict setLong:self.positive_button_ui_flags forKey:@"positive_button_ui_flags"];

    [dict setString:self.positive_confirmation forKey:@"positive_confirmation"];

    [dict setString:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SingleSliderTO

@synthesize max = max_;
@synthesize min = min_;
@synthesize precision = precision_;
@synthesize step = step_;
@synthesize unit = unit_;
@synthesize value = value_;

- (MCT_com_mobicage_to_messaging_forms_SingleSliderTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SingleSliderTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsFloatObjectForKey:@"max"])
            return [self errorDuringInitBecauseOfFieldWithName:@"max"];
        else
            self.max = [dict floatForKey:@"max"];

        if (![dict containsFloatObjectForKey:@"min"])
            return [self errorDuringInitBecauseOfFieldWithName:@"min"];
        else
            self.min = [dict floatForKey:@"min"];

        if (![dict containsLongObjectForKey:@"precision"])
            return [self errorDuringInitBecauseOfFieldWithName:@"precision"];
        self.precision = [dict longForKey:@"precision"];

        if (![dict containsFloatObjectForKey:@"step"])
            return [self errorDuringInitBecauseOfFieldWithName:@"step"];
        else
            self.step = [dict floatForKey:@"step"];

        self.unit = [dict stringForKey:@"unit"];
        if (self.unit == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"unit"];
        if (self.unit == MCTNull)
            self.unit = nil;

        if (![dict containsFloatObjectForKey:@"value"])
            return [self errorDuringInitBecauseOfFieldWithName:@"value"];
        else
            self.value = [dict floatForKey:@"value"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SingleSliderTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SingleSliderTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SingleSliderTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SingleSliderTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setFloat:self.max forKey:@"max"];

    [dict setFloat:self.min forKey:@"min"];

    [dict setLong:self.precision forKey:@"precision"];

    [dict setFloat:self.step forKey:@"step"];

    [dict setString:self.unit forKey:@"unit"];

    [dict setFloat:self.value forKey:@"value"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormRequestTO

@synthesize result = result_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *)tmp_to_0;
        }

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormResponseTO

@synthesize result = result_;

- (MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"result"])
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        self.result = [dict longForKey:@"result"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitAdvancedOrderFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.result forKey:@"result"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormRequestTO

@synthesize result = result_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)tmp_to_0;
        }

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormResponseTO

@synthesize result = result_;

- (MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"result"])
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        self.result = [dict longForKey:@"result"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitAutoCompleteFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.result forKey:@"result"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormRequestTO

@synthesize result = result_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *)tmp_to_0;
        }

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormResponseTO

@synthesize result = result_;

- (MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"result"])
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        self.result = [dict longForKey:@"result"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitDateSelectFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.result forKey:@"result"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormRequestTO

@synthesize result = result_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *)tmp_to_0;
        }

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormResponseTO

@synthesize result = result_;

- (MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"result"])
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        self.result = [dict longForKey:@"result"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitGPSLocationFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.result forKey:@"result"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormRequestTO

@synthesize result = result_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *)tmp_to_0;
        }

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormResponseTO

@synthesize result = result_;

- (MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"result"])
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        self.result = [dict longForKey:@"result"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitMultiSelectFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.result forKey:@"result"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormRequestTO

@synthesize result = result_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *)tmp_to_0;
        }

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormResponseTO

@synthesize result = result_;

- (MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"result"])
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        self.result = [dict longForKey:@"result"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitMyDigiPassFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.result forKey:@"result"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormRequestTO

@synthesize result = result_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)tmp_to_0;
        }

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormResponseTO

@synthesize result = result_;

- (MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"result"])
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        self.result = [dict longForKey:@"result"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitPhotoUploadFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.result forKey:@"result"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormRequestTO

@synthesize result = result_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *)tmp_to_0;
        }

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormResponseTO

@synthesize result = result_;

- (MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"result"])
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        self.result = [dict longForKey:@"result"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitRangeSliderFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.result forKey:@"result"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormRequestTO

@synthesize result = result_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)tmp_to_0;
        }

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormResponseTO

@synthesize result = result_;

- (MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"result"])
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        self.result = [dict longForKey:@"result"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitSingleSelectFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.result forKey:@"result"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormRequestTO

@synthesize result = result_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *)tmp_to_0;
        }

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormResponseTO

@synthesize result = result_;

- (MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"result"])
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        self.result = [dict longForKey:@"result"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitSingleSliderFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.result forKey:@"result"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormRequestTO

@synthesize result = result_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)tmp_to_0;
        }

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormResponseTO

@synthesize result = result_;

- (MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"result"])
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        self.result = [dict longForKey:@"result"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitTextBlockFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.result forKey:@"result"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormRequestTO

@synthesize result = result_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)tmp_to_0;
        }

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormResponseTO

@synthesize result = result_;

- (MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"result"])
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        self.result = [dict longForKey:@"result"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_SubmitTextLineFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.result forKey:@"result"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO

@synthesize attachments = attachments_;
@synthesize form = form_;
@synthesize member = member_;
@synthesize alert_flags = alert_flags_;
@synthesize branding = branding_;
@synthesize broadcast_type = broadcast_type_;
@synthesize context = context_;
@synthesize default_priority = default_priority_;
@synthesize default_sticky = default_sticky_;
@synthesize flags = flags_;
@synthesize key = key_;
@synthesize message = message_;
@synthesize message_type = message_type_;
@synthesize parent_key = parent_key_;
@synthesize priority = priority_;
@synthesize sender = sender_;
@synthesize threadTimestamp = threadTimestamp_;
@synthesize thread_avatar_hash = thread_avatar_hash_;
@synthesize thread_background_color = thread_background_color_;
@synthesize thread_size = thread_size_;
@synthesize thread_text_color = thread_text_color_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO *)init
{
    if (self = [super init]) {
        self.attachments = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"attachments" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
        if (tmp_dict_array_0 != nil) {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_AttachmentTO *tmp_obj = [MCT_com_mobicage_to_messaging_AttachmentTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.attachments = tmp_obj_array_0;
        }

        NSDictionary *tmp_dict_1 = [dict dictForKey:@"form"];
        if (tmp_dict_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form"];
        if (tmp_dict_1 == MCTNull)
            self.form = nil;
        else if (tmp_dict_1 != nil) {
            MCT_com_mobicage_to_messaging_forms_TextBlockFormTO *tmp_to_1 = [MCT_com_mobicage_to_messaging_forms_TextBlockFormTO transferObjectWithDict:tmp_dict_1];
            if (tmp_to_1 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form"];
            self.form = (MCT_com_mobicage_to_messaging_forms_TextBlockFormTO *)tmp_to_1;
        }

        NSDictionary *tmp_dict_2 = [dict dictForKey:@"member"];
        if (tmp_dict_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"member"];
        if (tmp_dict_2 == MCTNull)
            self.member = nil;
        else if (tmp_dict_2 != nil) {
            MCT_com_mobicage_to_messaging_MemberStatusTO *tmp_to_2 = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObjectWithDict:tmp_dict_2];
            if (tmp_to_2 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"member"];
            self.member = (MCT_com_mobicage_to_messaging_MemberStatusTO *)tmp_to_2;
        }

        if (![dict containsLongObjectForKey:@"alert_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"alert_flags"];
        self.alert_flags = [dict longForKey:@"alert_flags"];

        self.branding = [dict stringForKey:@"branding"];
        if (self.branding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"branding"];
        if (self.branding == MCTNull)
            self.branding = nil;

        self.broadcast_type = [dict stringForKey:@"broadcast_type" withDefaultValue:nil];
        if (self.broadcast_type == MCTNull)
            self.broadcast_type = nil;

        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        self.default_priority = [dict longForKey:@"default_priority" withDefaultValue:1];

        self.default_sticky = [dict boolForKey:@"default_sticky" withDefaultValue:NO];

        if (![dict containsLongObjectForKey:@"flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flags"];
        self.flags = [dict longForKey:@"flags"];

        self.key = [dict stringForKey:@"key"];
        if (self.key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"key"];
        if (self.key == MCTNull)
            self.key = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        if (![dict containsLongObjectForKey:@"message_type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"message_type"];
        self.message_type = [dict longForKey:@"message_type"];

        self.parent_key = [dict stringForKey:@"parent_key"];
        if (self.parent_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_key"];
        if (self.parent_key == MCTNull)
            self.parent_key = nil;

        self.priority = [dict longForKey:@"priority" withDefaultValue:1];

        self.sender = [dict stringForKey:@"sender"];
        if (self.sender == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"sender"];
        if (self.sender == MCTNull)
            self.sender = nil;

        if (![dict containsLongObjectForKey:@"threadTimestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"threadTimestamp"];
        self.threadTimestamp = [dict longForKey:@"threadTimestamp"];

        self.thread_avatar_hash = [dict stringForKey:@"thread_avatar_hash" withDefaultValue:nil];
        if (self.thread_avatar_hash == MCTNull)
            self.thread_avatar_hash = nil;

        self.thread_background_color = [dict stringForKey:@"thread_background_color" withDefaultValue:nil];
        if (self.thread_background_color == MCTNull)
            self.thread_background_color = nil;

        if (![dict containsLongObjectForKey:@"thread_size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"thread_size"];
        self.thread_size = [dict longForKey:@"thread_size"];

        self.thread_text_color = [dict stringForKey:@"thread_text_color" withDefaultValue:nil];
        if (self.thread_text_color == MCTNull)
            self.thread_text_color = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.attachments == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO.attachments");
    } else if ([self.attachments isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.attachments count]];
        for (MCT_com_mobicage_to_messaging_AttachmentTO *obj in self.attachments)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"attachments"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_TextBlockFormMessageTO.attachments");
    }

    [dict setDict:[self.form dictRepresentation] forKey:@"form"];

    [dict setDict:[self.member dictRepresentation] forKey:@"member"];

    [dict setLong:self.alert_flags forKey:@"alert_flags"];

    [dict setString:self.branding forKey:@"branding"];

    [dict setString:self.broadcast_type forKey:@"broadcast_type"];

    [dict setString:self.context forKey:@"context"];

    [dict setLong:self.default_priority forKey:@"default_priority"];

    [dict setBool:self.default_sticky forKey:@"default_sticky"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setString:self.key forKey:@"key"];

    [dict setString:self.message forKey:@"message"];

    [dict setLong:self.message_type forKey:@"message_type"];

    [dict setString:self.parent_key forKey:@"parent_key"];

    [dict setLong:self.priority forKey:@"priority"];

    [dict setString:self.sender forKey:@"sender"];

    [dict setLong:self.threadTimestamp forKey:@"threadTimestamp"];

    [dict setString:self.thread_avatar_hash forKey:@"thread_avatar_hash"];

    [dict setString:self.thread_background_color forKey:@"thread_background_color"];

    [dict setLong:self.thread_size forKey:@"thread_size"];

    [dict setString:self.thread_text_color forKey:@"thread_text_color"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_TextBlockFormTO

@synthesize widget = widget_;
@synthesize javascript_validation = javascript_validation_;
@synthesize negative_button = negative_button_;
@synthesize negative_button_ui_flags = negative_button_ui_flags_;
@synthesize negative_confirmation = negative_confirmation_;
@synthesize positive_button = positive_button_;
@synthesize positive_button_ui_flags = positive_button_ui_flags_;
@synthesize positive_confirmation = positive_confirmation_;
@synthesize type = type_;

- (MCT_com_mobicage_to_messaging_forms_TextBlockFormTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_TextBlockFormTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"widget"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
        if (tmp_dict_0 == MCTNull)
            self.widget = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_TextBlockTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_TextBlockTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
            self.widget = (MCT_com_mobicage_to_messaging_forms_TextBlockTO *)tmp_to_0;
        }

        self.javascript_validation = [dict stringForKey:@"javascript_validation" withDefaultValue:nil];
        if (self.javascript_validation == MCTNull)
            self.javascript_validation = nil;

        self.negative_button = [dict stringForKey:@"negative_button"];
        if (self.negative_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button"];
        if (self.negative_button == MCTNull)
            self.negative_button = nil;

        if (![dict containsLongObjectForKey:@"negative_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button_ui_flags"];
        self.negative_button_ui_flags = [dict longForKey:@"negative_button_ui_flags"];

        self.negative_confirmation = [dict stringForKey:@"negative_confirmation"];
        if (self.negative_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_confirmation"];
        if (self.negative_confirmation == MCTNull)
            self.negative_confirmation = nil;

        self.positive_button = [dict stringForKey:@"positive_button"];
        if (self.positive_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button"];
        if (self.positive_button == MCTNull)
            self.positive_button = nil;

        if (![dict containsLongObjectForKey:@"positive_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button_ui_flags"];
        self.positive_button_ui_flags = [dict longForKey:@"positive_button_ui_flags"];

        self.positive_confirmation = [dict stringForKey:@"positive_confirmation"];
        if (self.positive_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_confirmation"];
        if (self.positive_confirmation == MCTNull)
            self.positive_confirmation = nil;

        self.type = [dict stringForKey:@"type"];
        if (self.type == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        if (self.type == MCTNull)
            self.type = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_TextBlockFormTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_TextBlockFormTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_TextBlockFormTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_TextBlockFormTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.widget dictRepresentation] forKey:@"widget"];

    [dict setString:self.javascript_validation forKey:@"javascript_validation"];

    [dict setString:self.negative_button forKey:@"negative_button"];

    [dict setLong:self.negative_button_ui_flags forKey:@"negative_button_ui_flags"];

    [dict setString:self.negative_confirmation forKey:@"negative_confirmation"];

    [dict setString:self.positive_button forKey:@"positive_button"];

    [dict setLong:self.positive_button_ui_flags forKey:@"positive_button_ui_flags"];

    [dict setString:self.positive_confirmation forKey:@"positive_confirmation"];

    [dict setString:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_TextBlockTO

@synthesize max_chars = max_chars_;
@synthesize place_holder = place_holder_;
@synthesize value = value_;

- (MCT_com_mobicage_to_messaging_forms_TextBlockTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_TextBlockTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"max_chars"])
            return [self errorDuringInitBecauseOfFieldWithName:@"max_chars"];
        self.max_chars = [dict longForKey:@"max_chars"];

        self.place_holder = [dict stringForKey:@"place_holder"];
        if (self.place_holder == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"place_holder"];
        if (self.place_holder == MCTNull)
            self.place_holder = nil;

        self.value = [dict stringForKey:@"value"];
        if (self.value == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"value"];
        if (self.value == MCTNull)
            self.value = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_TextBlockTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_TextBlockTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_TextBlockTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_TextBlockTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.max_chars forKey:@"max_chars"];

    [dict setString:self.place_holder forKey:@"place_holder"];

    [dict setString:self.value forKey:@"value"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO

@synthesize attachments = attachments_;
@synthesize form = form_;
@synthesize member = member_;
@synthesize alert_flags = alert_flags_;
@synthesize branding = branding_;
@synthesize broadcast_type = broadcast_type_;
@synthesize context = context_;
@synthesize default_priority = default_priority_;
@synthesize default_sticky = default_sticky_;
@synthesize flags = flags_;
@synthesize key = key_;
@synthesize message = message_;
@synthesize message_type = message_type_;
@synthesize parent_key = parent_key_;
@synthesize priority = priority_;
@synthesize sender = sender_;
@synthesize threadTimestamp = threadTimestamp_;
@synthesize thread_avatar_hash = thread_avatar_hash_;
@synthesize thread_background_color = thread_background_color_;
@synthesize thread_size = thread_size_;
@synthesize thread_text_color = thread_text_color_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO *)init
{
    if (self = [super init]) {
        self.attachments = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"attachments" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
        if (tmp_dict_array_0 != nil) {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_messaging_AttachmentTO *tmp_obj = [MCT_com_mobicage_to_messaging_AttachmentTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"attachments"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.attachments = tmp_obj_array_0;
        }

        NSDictionary *tmp_dict_1 = [dict dictForKey:@"form"];
        if (tmp_dict_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form"];
        if (tmp_dict_1 == MCTNull)
            self.form = nil;
        else if (tmp_dict_1 != nil) {
            MCT_com_mobicage_to_messaging_forms_TextLineFormTO *tmp_to_1 = [MCT_com_mobicage_to_messaging_forms_TextLineFormTO transferObjectWithDict:tmp_dict_1];
            if (tmp_to_1 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form"];
            self.form = (MCT_com_mobicage_to_messaging_forms_TextLineFormTO *)tmp_to_1;
        }

        NSDictionary *tmp_dict_2 = [dict dictForKey:@"member"];
        if (tmp_dict_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"member"];
        if (tmp_dict_2 == MCTNull)
            self.member = nil;
        else if (tmp_dict_2 != nil) {
            MCT_com_mobicage_to_messaging_MemberStatusTO *tmp_to_2 = [MCT_com_mobicage_to_messaging_MemberStatusTO transferObjectWithDict:tmp_dict_2];
            if (tmp_to_2 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"member"];
            self.member = (MCT_com_mobicage_to_messaging_MemberStatusTO *)tmp_to_2;
        }

        if (![dict containsLongObjectForKey:@"alert_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"alert_flags"];
        self.alert_flags = [dict longForKey:@"alert_flags"];

        self.branding = [dict stringForKey:@"branding"];
        if (self.branding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"branding"];
        if (self.branding == MCTNull)
            self.branding = nil;

        self.broadcast_type = [dict stringForKey:@"broadcast_type" withDefaultValue:nil];
        if (self.broadcast_type == MCTNull)
            self.broadcast_type = nil;

        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        self.default_priority = [dict longForKey:@"default_priority" withDefaultValue:1];

        self.default_sticky = [dict boolForKey:@"default_sticky" withDefaultValue:NO];

        if (![dict containsLongObjectForKey:@"flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flags"];
        self.flags = [dict longForKey:@"flags"];

        self.key = [dict stringForKey:@"key"];
        if (self.key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"key"];
        if (self.key == MCTNull)
            self.key = nil;

        self.message = [dict stringForKey:@"message"];
        if (self.message == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message"];
        if (self.message == MCTNull)
            self.message = nil;

        if (![dict containsLongObjectForKey:@"message_type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"message_type"];
        self.message_type = [dict longForKey:@"message_type"];

        self.parent_key = [dict stringForKey:@"parent_key"];
        if (self.parent_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_key"];
        if (self.parent_key == MCTNull)
            self.parent_key = nil;

        self.priority = [dict longForKey:@"priority" withDefaultValue:1];

        self.sender = [dict stringForKey:@"sender"];
        if (self.sender == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"sender"];
        if (self.sender == MCTNull)
            self.sender = nil;

        if (![dict containsLongObjectForKey:@"threadTimestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"threadTimestamp"];
        self.threadTimestamp = [dict longForKey:@"threadTimestamp"];

        self.thread_avatar_hash = [dict stringForKey:@"thread_avatar_hash" withDefaultValue:nil];
        if (self.thread_avatar_hash == MCTNull)
            self.thread_avatar_hash = nil;

        self.thread_background_color = [dict stringForKey:@"thread_background_color" withDefaultValue:nil];
        if (self.thread_background_color == MCTNull)
            self.thread_background_color = nil;

        if (![dict containsLongObjectForKey:@"thread_size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"thread_size"];
        self.thread_size = [dict longForKey:@"thread_size"];

        self.thread_text_color = [dict stringForKey:@"thread_text_color" withDefaultValue:nil];
        if (self.thread_text_color == MCTNull)
            self.thread_text_color = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.attachments == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO.attachments");
    } else if ([self.attachments isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.attachments count]];
        for (MCT_com_mobicage_to_messaging_AttachmentTO *obj in self.attachments)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"attachments"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_messaging_forms_TextLineFormMessageTO.attachments");
    }

    [dict setDict:[self.form dictRepresentation] forKey:@"form"];

    [dict setDict:[self.member dictRepresentation] forKey:@"member"];

    [dict setLong:self.alert_flags forKey:@"alert_flags"];

    [dict setString:self.branding forKey:@"branding"];

    [dict setString:self.broadcast_type forKey:@"broadcast_type"];

    [dict setString:self.context forKey:@"context"];

    [dict setLong:self.default_priority forKey:@"default_priority"];

    [dict setBool:self.default_sticky forKey:@"default_sticky"];

    [dict setLong:self.flags forKey:@"flags"];

    [dict setString:self.key forKey:@"key"];

    [dict setString:self.message forKey:@"message"];

    [dict setLong:self.message_type forKey:@"message_type"];

    [dict setString:self.parent_key forKey:@"parent_key"];

    [dict setLong:self.priority forKey:@"priority"];

    [dict setString:self.sender forKey:@"sender"];

    [dict setLong:self.threadTimestamp forKey:@"threadTimestamp"];

    [dict setString:self.thread_avatar_hash forKey:@"thread_avatar_hash"];

    [dict setString:self.thread_background_color forKey:@"thread_background_color"];

    [dict setLong:self.thread_size forKey:@"thread_size"];

    [dict setString:self.thread_text_color forKey:@"thread_text_color"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_TextLineFormTO

@synthesize widget = widget_;
@synthesize javascript_validation = javascript_validation_;
@synthesize negative_button = negative_button_;
@synthesize negative_button_ui_flags = negative_button_ui_flags_;
@synthesize negative_confirmation = negative_confirmation_;
@synthesize positive_button = positive_button_;
@synthesize positive_button_ui_flags = positive_button_ui_flags_;
@synthesize positive_confirmation = positive_confirmation_;
@synthesize type = type_;

- (MCT_com_mobicage_to_messaging_forms_TextLineFormTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_TextLineFormTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"widget"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
        if (tmp_dict_0 == MCTNull)
            self.widget = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_TextLineTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_TextLineTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"widget"];
            self.widget = (MCT_com_mobicage_to_messaging_forms_TextLineTO *)tmp_to_0;
        }

        self.javascript_validation = [dict stringForKey:@"javascript_validation" withDefaultValue:nil];
        if (self.javascript_validation == MCTNull)
            self.javascript_validation = nil;

        self.negative_button = [dict stringForKey:@"negative_button"];
        if (self.negative_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button"];
        if (self.negative_button == MCTNull)
            self.negative_button = nil;

        if (![dict containsLongObjectForKey:@"negative_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_button_ui_flags"];
        self.negative_button_ui_flags = [dict longForKey:@"negative_button_ui_flags"];

        self.negative_confirmation = [dict stringForKey:@"negative_confirmation"];
        if (self.negative_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"negative_confirmation"];
        if (self.negative_confirmation == MCTNull)
            self.negative_confirmation = nil;

        self.positive_button = [dict stringForKey:@"positive_button"];
        if (self.positive_button == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button"];
        if (self.positive_button == MCTNull)
            self.positive_button = nil;

        if (![dict containsLongObjectForKey:@"positive_button_ui_flags"])
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_button_ui_flags"];
        self.positive_button_ui_flags = [dict longForKey:@"positive_button_ui_flags"];

        self.positive_confirmation = [dict stringForKey:@"positive_confirmation"];
        if (self.positive_confirmation == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"positive_confirmation"];
        if (self.positive_confirmation == MCTNull)
            self.positive_confirmation = nil;

        self.type = [dict stringForKey:@"type"];
        if (self.type == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        if (self.type == MCTNull)
            self.type = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_TextLineFormTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_TextLineFormTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_TextLineFormTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_TextLineFormTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.widget dictRepresentation] forKey:@"widget"];

    [dict setString:self.javascript_validation forKey:@"javascript_validation"];

    [dict setString:self.negative_button forKey:@"negative_button"];

    [dict setLong:self.negative_button_ui_flags forKey:@"negative_button_ui_flags"];

    [dict setString:self.negative_confirmation forKey:@"negative_confirmation"];

    [dict setString:self.positive_button forKey:@"positive_button"];

    [dict setLong:self.positive_button_ui_flags forKey:@"positive_button_ui_flags"];

    [dict setString:self.positive_confirmation forKey:@"positive_confirmation"];

    [dict setString:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_TextLineTO

@synthesize max_chars = max_chars_;
@synthesize place_holder = place_holder_;
@synthesize value = value_;

- (MCT_com_mobicage_to_messaging_forms_TextLineTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_TextLineTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"max_chars"])
            return [self errorDuringInitBecauseOfFieldWithName:@"max_chars"];
        self.max_chars = [dict longForKey:@"max_chars"];

        self.place_holder = [dict stringForKey:@"place_holder"];
        if (self.place_holder == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"place_holder"];
        if (self.place_holder == MCTNull)
            self.place_holder = nil;

        self.value = [dict stringForKey:@"value"];
        if (self.value == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"value"];
        if (self.value == MCTNull)
            self.value = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_TextLineTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_TextLineTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_TextLineTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_TextLineTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.max_chars forKey:@"max_chars"];

    [dict setString:self.place_holder forKey:@"place_holder"];

    [dict setString:self.value forKey:@"value"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO

@synthesize values = values_;

- (MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *)init
{
    if (self = [super init]) {
        self.values = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_unicode_array_0 = [dict arrayForKey:@"values"];
        if (tmp_unicode_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"values"];
        for (id obj in tmp_unicode_array_0) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"values"];
        }
        self.values = tmp_unicode_array_0;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.values forKey:@"values"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO

@synthesize value = value_;

- (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.value = [dict stringForKey:@"value"];
        if (self.value == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"value"];
        if (self.value == MCTNull)
            self.value = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.value forKey:@"value"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormRequestTO

@synthesize result = result_;
@synthesize acked_timestamp = acked_timestamp_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize received_timestamp = received_timestamp_;
@synthesize status = status_;

- (MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_AdvancedOrderWidgetResultTO *)tmp_to_0;
        }

        if (![dict containsLongObjectForKey:@"acked_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"acked_timestamp"];
        self.acked_timestamp = [dict longForKey:@"acked_timestamp"];

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setLong:self.acked_timestamp forKey:@"acked_timestamp"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormResponseTO


- (MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateAdvancedOrderFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormRequestTO

@synthesize result = result_;
@synthesize acked_timestamp = acked_timestamp_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize received_timestamp = received_timestamp_;
@synthesize status = status_;

- (MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)tmp_to_0;
        }

        if (![dict containsLongObjectForKey:@"acked_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"acked_timestamp"];
        self.acked_timestamp = [dict longForKey:@"acked_timestamp"];

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setLong:self.acked_timestamp forKey:@"acked_timestamp"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormResponseTO


- (MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateAutoCompleteFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormRequestTO

@synthesize result = result_;
@synthesize acked_timestamp = acked_timestamp_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize received_timestamp = received_timestamp_;
@synthesize status = status_;

- (MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_LongWidgetResultTO *)tmp_to_0;
        }

        if (![dict containsLongObjectForKey:@"acked_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"acked_timestamp"];
        self.acked_timestamp = [dict longForKey:@"acked_timestamp"];

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setLong:self.acked_timestamp forKey:@"acked_timestamp"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormResponseTO


- (MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateDateSelectFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormRequestTO

@synthesize result = result_;
@synthesize acked_timestamp = acked_timestamp_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize received_timestamp = received_timestamp_;
@synthesize status = status_;

- (MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_LocationWidgetResultTO *)tmp_to_0;
        }

        if (![dict containsLongObjectForKey:@"acked_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"acked_timestamp"];
        self.acked_timestamp = [dict longForKey:@"acked_timestamp"];

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setLong:self.acked_timestamp forKey:@"acked_timestamp"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormResponseTO


- (MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateGPSLocationFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormRequestTO

@synthesize result = result_;
@synthesize acked_timestamp = acked_timestamp_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize received_timestamp = received_timestamp_;
@synthesize status = status_;

- (MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_UnicodeListWidgetResultTO *)tmp_to_0;
        }

        if (![dict containsLongObjectForKey:@"acked_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"acked_timestamp"];
        self.acked_timestamp = [dict longForKey:@"acked_timestamp"];

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setLong:self.acked_timestamp forKey:@"acked_timestamp"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormResponseTO


- (MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateMultiSelectFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormRequestTO

@synthesize result = result_;
@synthesize acked_timestamp = acked_timestamp_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize received_timestamp = received_timestamp_;
@synthesize status = status_;

- (MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *)tmp_to_0;
        }

        if (![dict containsLongObjectForKey:@"acked_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"acked_timestamp"];
        self.acked_timestamp = [dict longForKey:@"acked_timestamp"];

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setLong:self.acked_timestamp forKey:@"acked_timestamp"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormResponseTO


- (MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateMyDigiPassFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormRequestTO

@synthesize result = result_;
@synthesize acked_timestamp = acked_timestamp_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize received_timestamp = received_timestamp_;
@synthesize status = status_;

- (MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)tmp_to_0;
        }

        if (![dict containsLongObjectForKey:@"acked_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"acked_timestamp"];
        self.acked_timestamp = [dict longForKey:@"acked_timestamp"];

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setLong:self.acked_timestamp forKey:@"acked_timestamp"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormResponseTO


- (MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdatePhotoUploadFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormRequestTO

@synthesize result = result_;
@synthesize acked_timestamp = acked_timestamp_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize received_timestamp = received_timestamp_;
@synthesize status = status_;

- (MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_FloatListWidgetResultTO *)tmp_to_0;
        }

        if (![dict containsLongObjectForKey:@"acked_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"acked_timestamp"];
        self.acked_timestamp = [dict longForKey:@"acked_timestamp"];

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setLong:self.acked_timestamp forKey:@"acked_timestamp"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormResponseTO


- (MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateRangeSliderFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormRequestTO

@synthesize result = result_;
@synthesize acked_timestamp = acked_timestamp_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize received_timestamp = received_timestamp_;
@synthesize status = status_;

- (MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)tmp_to_0;
        }

        if (![dict containsLongObjectForKey:@"acked_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"acked_timestamp"];
        self.acked_timestamp = [dict longForKey:@"acked_timestamp"];

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setLong:self.acked_timestamp forKey:@"acked_timestamp"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormResponseTO


- (MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateSingleSelectFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormRequestTO

@synthesize result = result_;
@synthesize acked_timestamp = acked_timestamp_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize received_timestamp = received_timestamp_;
@synthesize status = status_;

- (MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_FloatWidgetResultTO *)tmp_to_0;
        }

        if (![dict containsLongObjectForKey:@"acked_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"acked_timestamp"];
        self.acked_timestamp = [dict longForKey:@"acked_timestamp"];

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setLong:self.acked_timestamp forKey:@"acked_timestamp"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormResponseTO


- (MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateSingleSliderFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormRequestTO

@synthesize result = result_;
@synthesize acked_timestamp = acked_timestamp_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize received_timestamp = received_timestamp_;
@synthesize status = status_;

- (MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)tmp_to_0;
        }

        if (![dict containsLongObjectForKey:@"acked_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"acked_timestamp"];
        self.acked_timestamp = [dict longForKey:@"acked_timestamp"];

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setLong:self.acked_timestamp forKey:@"acked_timestamp"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormResponseTO


- (MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateTextBlockFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormRequestTO

@synthesize result = result_;
@synthesize acked_timestamp = acked_timestamp_;
@synthesize button_id = button_id_;
@synthesize message_key = message_key_;
@synthesize parent_message_key = parent_message_key_;
@synthesize received_timestamp = received_timestamp_;
@synthesize status = status_;

- (MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (tmp_dict_0 == MCTNull)
            self.result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"result"];
            self.result = (MCT_com_mobicage_to_messaging_forms_UnicodeWidgetResultTO *)tmp_to_0;
        }

        if (![dict containsLongObjectForKey:@"acked_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"acked_timestamp"];
        self.acked_timestamp = [dict longForKey:@"acked_timestamp"];

        self.button_id = [dict stringForKey:@"button_id"];
        if (self.button_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"button_id"];
        if (self.button_id == MCTNull)
            self.button_id = nil;

        self.message_key = [dict stringForKey:@"message_key"];
        if (self.message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_key"];
        if (self.message_key == MCTNull)
            self.message_key = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        if (![dict containsLongObjectForKey:@"received_timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"received_timestamp"];
        self.received_timestamp = [dict longForKey:@"received_timestamp"];

        if (![dict containsLongObjectForKey:@"status"])
            return [self errorDuringInitBecauseOfFieldWithName:@"status"];
        self.status = [dict longForKey:@"status"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.result dictRepresentation] forKey:@"result"];

    [dict setLong:self.acked_timestamp forKey:@"acked_timestamp"];

    [dict setString:self.button_id forKey:@"button_id"];

    [dict setString:self.message_key forKey:@"message_key"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setLong:self.received_timestamp forKey:@"received_timestamp"];

    [dict setLong:self.status forKey:@"status"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormResponseTO


- (MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_forms_UpdateTextLineFormResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_jsmfr_FlowStartedRequestTO

@synthesize message_flow_run_id = message_flow_run_id_;
@synthesize service = service_;
@synthesize static_flow_hash = static_flow_hash_;
@synthesize thread_key = thread_key_;

- (MCT_com_mobicage_to_messaging_jsmfr_FlowStartedRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_jsmfr_FlowStartedRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.message_flow_run_id = [dict stringForKey:@"message_flow_run_id"];
        if (self.message_flow_run_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_flow_run_id"];
        if (self.message_flow_run_id == MCTNull)
            self.message_flow_run_id = nil;

        self.service = [dict stringForKey:@"service"];
        if (self.service == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"service"];
        if (self.service == MCTNull)
            self.service = nil;

        self.static_flow_hash = [dict stringForKey:@"static_flow_hash"];
        if (self.static_flow_hash == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"static_flow_hash"];
        if (self.static_flow_hash == MCTNull)
            self.static_flow_hash = nil;

        self.thread_key = [dict stringForKey:@"thread_key"];
        if (self.thread_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"thread_key"];
        if (self.thread_key == MCTNull)
            self.thread_key = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_jsmfr_FlowStartedRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_FlowStartedRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_jsmfr_FlowStartedRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_FlowStartedRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.message_flow_run_id forKey:@"message_flow_run_id"];

    [dict setString:self.service forKey:@"service"];

    [dict setString:self.static_flow_hash forKey:@"static_flow_hash"];

    [dict setString:self.thread_key forKey:@"thread_key"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_jsmfr_FlowStartedResponseTO


- (MCT_com_mobicage_to_messaging_jsmfr_FlowStartedResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_jsmfr_FlowStartedResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_jsmfr_FlowStartedResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_FlowStartedResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_jsmfr_FlowStartedResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_FlowStartedResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_jsmfr_JsMessageFlowMemberRunTO

@synthesize hashed_tag = hashed_tag_;
@synthesize message_flow_run_id = message_flow_run_id_;
@synthesize parent_message_key = parent_message_key_;
@synthesize sender = sender_;
@synthesize service_action = service_action_;

- (MCT_com_mobicage_to_messaging_jsmfr_JsMessageFlowMemberRunTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_jsmfr_JsMessageFlowMemberRunTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.hashed_tag = [dict stringForKey:@"hashed_tag"];
        if (self.hashed_tag == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"hashed_tag"];
        if (self.hashed_tag == MCTNull)
            self.hashed_tag = nil;

        self.message_flow_run_id = [dict stringForKey:@"message_flow_run_id"];
        if (self.message_flow_run_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_flow_run_id"];
        if (self.message_flow_run_id == MCTNull)
            self.message_flow_run_id = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        self.sender = [dict stringForKey:@"sender"];
        if (self.sender == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"sender"];
        if (self.sender == MCTNull)
            self.sender = nil;

        self.service_action = [dict stringForKey:@"service_action"];
        if (self.service_action == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"service_action"];
        if (self.service_action == MCTNull)
            self.service_action = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_jsmfr_JsMessageFlowMemberRunTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_JsMessageFlowMemberRunTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_jsmfr_JsMessageFlowMemberRunTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_JsMessageFlowMemberRunTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.hashed_tag forKey:@"hashed_tag"];

    [dict setString:self.message_flow_run_id forKey:@"message_flow_run_id"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    [dict setString:self.sender forKey:@"sender"];

    [dict setString:self.service_action forKey:@"service_action"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorRequestTO

@synthesize descriptionX = descriptionX_;
@synthesize errorMessage = errorMessage_;
@synthesize jsCommand = jsCommand_;
@synthesize mobicageVersion = mobicageVersion_;
@synthesize platform = platform_;
@synthesize platformVersion = platformVersion_;
@synthesize stackTrace = stackTrace_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.descriptionX = [dict stringForKey:@"description"];
        if (self.descriptionX == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"description"];
        if (self.descriptionX == MCTNull)
            self.descriptionX = nil;

        self.errorMessage = [dict stringForKey:@"errorMessage"];
        if (self.errorMessage == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"errorMessage"];
        if (self.errorMessage == MCTNull)
            self.errorMessage = nil;

        self.jsCommand = [dict stringForKey:@"jsCommand"];
        if (self.jsCommand == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"jsCommand"];
        if (self.jsCommand == MCTNull)
            self.jsCommand = nil;

        self.mobicageVersion = [dict stringForKey:@"mobicageVersion"];
        if (self.mobicageVersion == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"mobicageVersion"];
        if (self.mobicageVersion == MCTNull)
            self.mobicageVersion = nil;

        if (![dict containsLongObjectForKey:@"platform"])
            return [self errorDuringInitBecauseOfFieldWithName:@"platform"];
        self.platform = [dict longForKey:@"platform"];

        self.platformVersion = [dict stringForKey:@"platformVersion"];
        if (self.platformVersion == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"platformVersion"];
        if (self.platformVersion == MCTNull)
            self.platformVersion = nil;

        self.stackTrace = [dict stringForKey:@"stackTrace"];
        if (self.stackTrace == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"stackTrace"];
        if (self.stackTrace == MCTNull)
            self.stackTrace = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.descriptionX forKey:@"description"];

    [dict setString:self.errorMessage forKey:@"errorMessage"];

    [dict setString:self.jsCommand forKey:@"jsCommand"];

    [dict setString:self.mobicageVersion forKey:@"mobicageVersion"];

    [dict setLong:self.platform forKey:@"platform"];

    [dict setString:self.platformVersion forKey:@"platformVersion"];

    [dict setString:self.stackTrace forKey:@"stackTrace"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorResponseTO


- (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_MessageFlowErrorResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedRequestTO

@synthesize end_id = end_id_;
@synthesize message_flow_run_id = message_flow_run_id_;
@synthesize parent_message_key = parent_message_key_;

- (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.end_id = [dict stringForKey:@"end_id"];
        if (self.end_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"end_id"];
        if (self.end_id == MCTNull)
            self.end_id = nil;

        self.message_flow_run_id = [dict stringForKey:@"message_flow_run_id"];
        if (self.message_flow_run_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_flow_run_id"];
        if (self.message_flow_run_id == MCTNull)
            self.message_flow_run_id = nil;

        self.parent_message_key = [dict stringForKey:@"parent_message_key"];
        if (self.parent_message_key == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"parent_message_key"];
        if (self.parent_message_key == MCTNull)
            self.parent_message_key = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.end_id forKey:@"end_id"];

    [dict setString:self.message_flow_run_id forKey:@"message_flow_run_id"];

    [dict setString:self.parent_message_key forKey:@"parent_message_key"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedResponseTO


- (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_MessageFlowFinishedResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultRequestTO

@synthesize run = run_;
@synthesize email_admins = email_admins_;
@synthesize emails = emails_;
@synthesize end_id = end_id_;
@synthesize flush_id = flush_id_;
@synthesize message_flow_name = message_flow_name_;
@synthesize results_email = results_email_;

- (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultRequestTO *)init
{
    if (self = [super init]) {
        self.emails = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"run"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"run"];
        if (tmp_dict_0 == MCTNull)
            self.run = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_messaging_jsmfr_JsMessageFlowMemberRunTO *tmp_to_0 = [MCT_com_mobicage_to_messaging_jsmfr_JsMessageFlowMemberRunTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"run"];
            self.run = (MCT_com_mobicage_to_messaging_jsmfr_JsMessageFlowMemberRunTO *)tmp_to_0;
        }

        if (![dict containsBoolObjectForKey:@"email_admins"])
            return [self errorDuringInitBecauseOfFieldWithName:@"email_admins"];
        self.email_admins = [dict boolForKey:@"email_admins"];

        NSArray *tmp_unicode_array_2 = [dict arrayForKey:@"emails"];
        if (tmp_unicode_array_2 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"emails"];
        for (id obj in tmp_unicode_array_2) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"emails"];
        }
        self.emails = tmp_unicode_array_2;

        self.end_id = [dict stringForKey:@"end_id"];
        if (self.end_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"end_id"];
        if (self.end_id == MCTNull)
            self.end_id = nil;

        self.flush_id = [dict stringForKey:@"flush_id"];
        if (self.flush_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"flush_id"];
        if (self.flush_id == MCTNull)
            self.flush_id = nil;

        self.message_flow_name = [dict stringForKey:@"message_flow_name"];
        if (self.message_flow_name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_flow_name"];
        if (self.message_flow_name == MCTNull)
            self.message_flow_name = nil;

        if (![dict containsBoolObjectForKey:@"results_email"])
            return [self errorDuringInitBecauseOfFieldWithName:@"results_email"];
        self.results_email = [dict boolForKey:@"results_email"];

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.run dictRepresentation] forKey:@"run"];

    [dict setBool:self.email_admins forKey:@"email_admins"];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.emails forKey:@"emails"];

    [dict setString:self.end_id forKey:@"end_id"];

    [dict setString:self.flush_id forKey:@"flush_id"];

    [dict setString:self.message_flow_name forKey:@"message_flow_name"];

    [dict setBool:self.results_email forKey:@"results_email"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultResponseTO


- (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_MessageFlowMemberResultResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageRequestTO

@synthesize form_result = form_result_;
@synthesize message_flow_run_id = message_flow_run_id_;
@synthesize step_id = step_id_;

- (MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"form_result"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"form_result"];
        if (tmp_dict_0 == MCTNull)
            self.form_result = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_models_properties_forms_FormResult *tmp_to_0 = [MCT_com_mobicage_models_properties_forms_FormResult transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"form_result"];
            self.form_result = (MCT_com_mobicage_models_properties_forms_FormResult *)tmp_to_0;
        }

        self.message_flow_run_id = [dict stringForKey:@"message_flow_run_id" withDefaultValue:nil];
        if (self.message_flow_run_id == MCTNull)
            self.message_flow_run_id = nil;

        self.step_id = [dict stringForKey:@"step_id" withDefaultValue:nil];
        if (self.step_id == MCTNull)
            self.step_id = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.form_result dictRepresentation] forKey:@"form_result"];

    [dict setString:self.message_flow_run_id forKey:@"message_flow_run_id"];

    [dict setString:self.step_id forKey:@"step_id"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageResponseTO


- (MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_messaging_jsmfr_NewFlowMessageResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_FindServiceCategoryTO

@synthesize items = items_;
@synthesize category = category_;
@synthesize cursor = cursor_;

- (MCT_com_mobicage_to_service_FindServiceCategoryTO *)init
{
    if (self = [super init]) {
        self.items = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_service_FindServiceCategoryTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"items"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"items"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"items"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_service_FindServiceItemTO *tmp_obj = [MCT_com_mobicage_to_service_FindServiceItemTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"items"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.items = tmp_obj_array_0;
        }

        self.category = [dict stringForKey:@"category"];
        if (self.category == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"category"];
        if (self.category == MCTNull)
            self.category = nil;

        self.cursor = [dict stringForKey:@"cursor" withDefaultValue:nil];
        if (self.cursor == MCTNull)
            self.cursor = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_service_FindServiceCategoryTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_FindServiceCategoryTO alloc] init];
}

+ (MCT_com_mobicage_to_service_FindServiceCategoryTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_FindServiceCategoryTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.items == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_service_FindServiceCategoryTO.items");
    } else if ([self.items isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.items count]];
        for (MCT_com_mobicage_to_service_FindServiceItemTO *obj in self.items)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"items"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_service_FindServiceCategoryTO.items");
    }

    [dict setString:self.category forKey:@"category"];

    [dict setString:self.cursor forKey:@"cursor"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_FindServiceItemTO

@synthesize avatar = avatar_;
@synthesize avatar_id = avatar_id_;
@synthesize descriptionX = descriptionX_;
@synthesize description_branding = description_branding_;
@synthesize detail_text = detail_text_;
@synthesize email = email_;
@synthesize name = name_;
@synthesize qualified_identifier = qualified_identifier_;

- (MCT_com_mobicage_to_service_FindServiceItemTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_FindServiceItemTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.avatar = [dict stringForKey:@"avatar"];
        if (self.avatar == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar"];
        if (self.avatar == MCTNull)
            self.avatar = nil;

        if (![dict containsLongObjectForKey:@"avatar_id"])
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar_id"];
        self.avatar_id = [dict longForKey:@"avatar_id"];

        self.descriptionX = [dict stringForKey:@"description"];
        if (self.descriptionX == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"description"];
        if (self.descriptionX == MCTNull)
            self.descriptionX = nil;

        self.description_branding = [dict stringForKey:@"description_branding"];
        if (self.description_branding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"description_branding"];
        if (self.description_branding == MCTNull)
            self.description_branding = nil;

        self.detail_text = [dict stringForKey:@"detail_text" withDefaultValue:nil];
        if (self.detail_text == MCTNull)
            self.detail_text = nil;

        self.email = [dict stringForKey:@"email"];
        if (self.email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"email"];
        if (self.email == MCTNull)
            self.email = nil;

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        self.qualified_identifier = [dict stringForKey:@"qualified_identifier"];
        if (self.qualified_identifier == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"qualified_identifier"];
        if (self.qualified_identifier == MCTNull)
            self.qualified_identifier = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_service_FindServiceItemTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_FindServiceItemTO alloc] init];
}

+ (MCT_com_mobicage_to_service_FindServiceItemTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_FindServiceItemTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.avatar forKey:@"avatar"];

    [dict setLong:self.avatar_id forKey:@"avatar_id"];

    [dict setString:self.descriptionX forKey:@"description"];

    [dict setString:self.description_branding forKey:@"description_branding"];

    [dict setString:self.detail_text forKey:@"detail_text"];

    [dict setString:self.email forKey:@"email"];

    [dict setString:self.name forKey:@"name"];

    [dict setString:self.qualified_identifier forKey:@"qualified_identifier"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_FindServiceRequestTO

@synthesize geo_point = geo_point_;
@synthesize avatar_size = avatar_size_;
@synthesize cursor = cursor_;
@synthesize organization_type = organization_type_;
@synthesize search_string = search_string_;

- (MCT_com_mobicage_to_service_FindServiceRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_FindServiceRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"geo_point"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"geo_point"];
        if (tmp_dict_0 == MCTNull)
            self.geo_point = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *tmp_to_0 = [MCT_com_mobicage_to_activity_GeoPointWithTimestampTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"geo_point"];
            self.geo_point = (MCT_com_mobicage_to_activity_GeoPointWithTimestampTO *)tmp_to_0;
        }

        self.avatar_size = [dict longForKey:@"avatar_size" withDefaultValue:50];

        self.cursor = [dict stringForKey:@"cursor" withDefaultValue:nil];
        if (self.cursor == MCTNull)
            self.cursor = nil;

        if (![dict containsLongObjectForKey:@"organization_type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"organization_type"];
        self.organization_type = [dict longForKey:@"organization_type"];

        self.search_string = [dict stringForKey:@"search_string"];
        if (self.search_string == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"search_string"];
        if (self.search_string == MCTNull)
            self.search_string = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_service_FindServiceRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_FindServiceRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_service_FindServiceRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_FindServiceRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.geo_point dictRepresentation] forKey:@"geo_point"];

    [dict setLong:self.avatar_size forKey:@"avatar_size"];

    [dict setString:self.cursor forKey:@"cursor"];

    [dict setLong:self.organization_type forKey:@"organization_type"];

    [dict setString:self.search_string forKey:@"search_string"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_FindServiceResponseTO

@synthesize matches = matches_;
@synthesize error_string = error_string_;

- (MCT_com_mobicage_to_service_FindServiceResponseTO *)init
{
    if (self = [super init]) {
        self.matches = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_service_FindServiceResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_dict_array_0 = [dict arrayForKey:@"matches"];
        if (tmp_dict_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"matches"];
        if (tmp_dict_array_0 == MCTNull)
            return [self errorDuringInitBecauseOfFieldWithName:@"matches"];
        else {
            NSMutableArray *tmp_obj_array_0 = [NSMutableArray arrayWithCapacity:[tmp_dict_array_0 count]];
            for (NSDictionary *tmp_dict in tmp_dict_array_0) {
                MCT_com_mobicage_to_service_FindServiceCategoryTO *tmp_obj = [MCT_com_mobicage_to_service_FindServiceCategoryTO transferObjectWithDict:tmp_dict];
                if (tmp_obj == nil)
                    return [self errorDuringInitBecauseOfFieldWithName:@"matches"];
                [tmp_obj_array_0 addObject:tmp_obj];
            }
            self.matches = tmp_obj_array_0;
        }

        self.error_string = [dict stringForKey:@"error_string"];
        if (self.error_string == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"error_string"];
        if (self.error_string == MCTNull)
            self.error_string = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_service_FindServiceResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_FindServiceResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_service_FindServiceResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_FindServiceResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.matches == nil) {
        ERROR(@"nil value not supported for array field MCT_com_mobicage_to_service_FindServiceResponseTO.matches");
    } else if ([self.matches isKindOfClass:MCTArrayClass]) {
        // TODO: check type of fields
        NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:[self.matches count]];
        for (MCT_com_mobicage_to_service_FindServiceCategoryTO *obj in self.matches)
            [tmp_array addObject:[obj dictRepresentation]];
        [dict setArray:tmp_array forKey:@"matches"];
    } else {
        ERROR(@"expecting array field MCT_com_mobicage_to_service_FindServiceResponseTO.matches");
    }

    [dict setString:self.error_string forKey:@"error_string"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_GetMenuIconRequestTO

@synthesize coords = coords_;
@synthesize service = service_;
@synthesize size = size_;

- (MCT_com_mobicage_to_service_GetMenuIconRequestTO *)init
{
    if (self = [super init]) {
        self.coords = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_service_GetMenuIconRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_int_array_0 = [dict arrayForKey:@"coords"];
        if (tmp_int_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"coords"];
        for (id obj in tmp_int_array_0) {
            if (![obj isKindOfClass:MCTLongClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"coords"];
            MCTlong l = [obj longValue];
            if (l < MCT_MIN_LONG || l > MCT_MAX_LONG)
                return [self errorDuringInitBecauseOfFieldWithName:@"coords"];
        }
        self.coords = tmp_int_array_0;

        self.service = [dict stringForKey:@"service"];
        if (self.service == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"service"];
        if (self.service == MCTNull)
            self.service = nil;

        if (![dict containsLongObjectForKey:@"size"])
            return [self errorDuringInitBecauseOfFieldWithName:@"size"];
        self.size = [dict longForKey:@"size"];

        return self;
    }
}

+ (MCT_com_mobicage_to_service_GetMenuIconRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_GetMenuIconRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_service_GetMenuIconRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_GetMenuIconRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // TODO: add checking that all members are indeed longs
    [dict setArray:self.coords forKey:@"coords"];

    [dict setString:self.service forKey:@"service"];

    [dict setLong:self.size forKey:@"size"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_GetMenuIconResponseTO

@synthesize icon = icon_;
@synthesize iconHash = iconHash_;

- (MCT_com_mobicage_to_service_GetMenuIconResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_GetMenuIconResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.icon = [dict stringForKey:@"icon"];
        if (self.icon == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"icon"];
        if (self.icon == MCTNull)
            self.icon = nil;

        self.iconHash = [dict stringForKey:@"iconHash"];
        if (self.iconHash == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"iconHash"];
        if (self.iconHash == MCTNull)
            self.iconHash = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_service_GetMenuIconResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_GetMenuIconResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_service_GetMenuIconResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_GetMenuIconResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.icon forKey:@"icon"];

    [dict setString:self.iconHash forKey:@"iconHash"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_GetServiceActionInfoRequestTO

@synthesize action = action_;
@synthesize allow_cross_app = allow_cross_app_;
@synthesize code = code_;

- (MCT_com_mobicage_to_service_GetServiceActionInfoRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_GetServiceActionInfoRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.action = [dict stringForKey:@"action"];
        if (self.action == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"action"];
        if (self.action == MCTNull)
            self.action = nil;

        self.allow_cross_app = [dict boolForKey:@"allow_cross_app" withDefaultValue:NO];

        self.code = [dict stringForKey:@"code"];
        if (self.code == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"code"];
        if (self.code == MCTNull)
            self.code = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_service_GetServiceActionInfoRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_GetServiceActionInfoRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_service_GetServiceActionInfoRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_GetServiceActionInfoRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.action forKey:@"action"];

    [dict setBool:self.allow_cross_app forKey:@"allow_cross_app"];

    [dict setString:self.code forKey:@"code"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_GetServiceActionInfoResponseTO

@synthesize error = error_;
@synthesize actionDescription = actionDescription_;
@synthesize app_id = app_id_;
@synthesize avatar = avatar_;
@synthesize avatar_id = avatar_id_;
@synthesize descriptionX = descriptionX_;
@synthesize descriptionBranding = descriptionBranding_;
@synthesize email = email_;
@synthesize name = name_;
@synthesize profileData = profileData_;
@synthesize qualifiedIdentifier = qualifiedIdentifier_;
@synthesize staticFlow = staticFlow_;
@synthesize staticFlowBrandings = staticFlowBrandings_;
@synthesize staticFlowHash = staticFlowHash_;
@synthesize type = type_;

- (MCT_com_mobicage_to_service_GetServiceActionInfoResponseTO *)init
{
    if (self = [super init]) {
        self.staticFlowBrandings = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_service_GetServiceActionInfoResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"error" withDefaultValue:nil];
        if (tmp_dict_0 == MCTNull)
            self.error = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_friends_ErrorTO *tmp_to_0 = [MCT_com_mobicage_to_friends_ErrorTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"error"];
            self.error = (MCT_com_mobicage_to_friends_ErrorTO *)tmp_to_0;
        }

        self.actionDescription = [dict stringForKey:@"actionDescription"];
        if (self.actionDescription == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"actionDescription"];
        if (self.actionDescription == MCTNull)
            self.actionDescription = nil;

        self.app_id = [dict stringForKey:@"app_id" withDefaultValue:nil];
        if (self.app_id == MCTNull)
            self.app_id = nil;

        self.avatar = [dict stringForKey:@"avatar"];
        if (self.avatar == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar"];
        if (self.avatar == MCTNull)
            self.avatar = nil;

        self.avatar_id = [dict longForKey:@"avatar_id" withDefaultValue:-1];

        self.descriptionX = [dict stringForKey:@"description"];
        if (self.descriptionX == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"description"];
        if (self.descriptionX == MCTNull)
            self.descriptionX = nil;

        self.descriptionBranding = [dict stringForKey:@"descriptionBranding"];
        if (self.descriptionBranding == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"descriptionBranding"];
        if (self.descriptionBranding == MCTNull)
            self.descriptionBranding = nil;

        self.email = [dict stringForKey:@"email"];
        if (self.email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"email"];
        if (self.email == MCTNull)
            self.email = nil;

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        self.profileData = [dict stringForKey:@"profileData" withDefaultValue:nil];
        if (self.profileData == MCTNull)
            self.profileData = nil;

        self.qualifiedIdentifier = [dict stringForKey:@"qualifiedIdentifier"];
        if (self.qualifiedIdentifier == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"qualifiedIdentifier"];
        if (self.qualifiedIdentifier == MCTNull)
            self.qualifiedIdentifier = nil;

        self.staticFlow = [dict stringForKey:@"staticFlow"];
        if (self.staticFlow == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"staticFlow"];
        if (self.staticFlow == MCTNull)
            self.staticFlow = nil;

        NSArray *tmp_unicode_array_12 = [dict arrayForKey:@"staticFlowBrandings"];
        if (tmp_unicode_array_12 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"staticFlowBrandings"];
        for (id obj in tmp_unicode_array_12) {
            if (![obj isKindOfClass:MCTStringClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"staticFlowBrandings"];
        }
        self.staticFlowBrandings = tmp_unicode_array_12;

        self.staticFlowHash = [dict stringForKey:@"staticFlowHash"];
        if (self.staticFlowHash == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"staticFlowHash"];
        if (self.staticFlowHash == MCTNull)
            self.staticFlowHash = nil;

        if (![dict containsLongObjectForKey:@"type"])
            return [self errorDuringInitBecauseOfFieldWithName:@"type"];
        self.type = [dict longForKey:@"type"];

        return self;
    }
}

+ (MCT_com_mobicage_to_service_GetServiceActionInfoResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_GetServiceActionInfoResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_service_GetServiceActionInfoResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_GetServiceActionInfoResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.error dictRepresentation] forKey:@"error"];

    [dict setString:self.actionDescription forKey:@"actionDescription"];

    [dict setString:self.app_id forKey:@"app_id"];

    [dict setString:self.avatar forKey:@"avatar"];

    [dict setLong:self.avatar_id forKey:@"avatar_id"];

    [dict setString:self.descriptionX forKey:@"description"];

    [dict setString:self.descriptionBranding forKey:@"descriptionBranding"];

    [dict setString:self.email forKey:@"email"];

    [dict setString:self.name forKey:@"name"];

    [dict setString:self.profileData forKey:@"profileData"];

    [dict setString:self.qualifiedIdentifier forKey:@"qualifiedIdentifier"];

    [dict setString:self.staticFlow forKey:@"staticFlow"];

    // TODO: add checking that all members are indeed string
    [dict setArray:self.staticFlowBrandings forKey:@"staticFlowBrandings"];

    [dict setString:self.staticFlowHash forKey:@"staticFlowHash"];

    [dict setLong:self.type forKey:@"type"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_GetStaticFlowRequestTO

@synthesize coords = coords_;
@synthesize service = service_;
@synthesize staticFlowHash = staticFlowHash_;

- (MCT_com_mobicage_to_service_GetStaticFlowRequestTO *)init
{
    if (self = [super init]) {
        self.coords = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_service_GetStaticFlowRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_int_array_0 = [dict arrayForKey:@"coords"];
        if (tmp_int_array_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"coords"];
        for (id obj in tmp_int_array_0) {
            if (![obj isKindOfClass:MCTLongClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"coords"];
            MCTlong l = [obj longValue];
            if (l < MCT_MIN_LONG || l > MCT_MAX_LONG)
                return [self errorDuringInitBecauseOfFieldWithName:@"coords"];
        }
        self.coords = tmp_int_array_0;

        self.service = [dict stringForKey:@"service"];
        if (self.service == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"service"];
        if (self.service == MCTNull)
            self.service = nil;

        self.staticFlowHash = [dict stringForKey:@"staticFlowHash"];
        if (self.staticFlowHash == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"staticFlowHash"];
        if (self.staticFlowHash == MCTNull)
            self.staticFlowHash = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_service_GetStaticFlowRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_GetStaticFlowRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_service_GetStaticFlowRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_GetStaticFlowRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // TODO: add checking that all members are indeed longs
    [dict setArray:self.coords forKey:@"coords"];

    [dict setString:self.service forKey:@"service"];

    [dict setString:self.staticFlowHash forKey:@"staticFlowHash"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_GetStaticFlowResponseTO

@synthesize staticFlow = staticFlow_;

- (MCT_com_mobicage_to_service_GetStaticFlowResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_GetStaticFlowResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.staticFlow = [dict stringForKey:@"staticFlow"];
        if (self.staticFlow == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"staticFlow"];
        if (self.staticFlow == MCTNull)
            self.staticFlow = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_service_GetStaticFlowResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_GetStaticFlowResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_service_GetStaticFlowResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_GetStaticFlowResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.staticFlow forKey:@"staticFlow"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_PokeServiceRequestTO

@synthesize context = context_;
@synthesize email = email_;
@synthesize hashed_tag = hashed_tag_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_service_PokeServiceRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_PokeServiceRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        self.email = [dict stringForKey:@"email"];
        if (self.email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"email"];
        if (self.email == MCTNull)
            self.email = nil;

        self.hashed_tag = [dict stringForKey:@"hashed_tag"];
        if (self.hashed_tag == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"hashed_tag"];
        if (self.hashed_tag == MCTNull)
            self.hashed_tag = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_service_PokeServiceRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_PokeServiceRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_service_PokeServiceRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_PokeServiceRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.context forKey:@"context"];

    [dict setString:self.email forKey:@"email"];

    [dict setString:self.hashed_tag forKey:@"hashed_tag"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_PokeServiceResponseTO


- (MCT_com_mobicage_to_service_PokeServiceResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_PokeServiceResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_service_PokeServiceResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_PokeServiceResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_service_PokeServiceResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_PokeServiceResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_PressMenuIconRequestTO

@synthesize context = context_;
@synthesize coords = coords_;
@synthesize generation = generation_;
@synthesize hashed_tag = hashed_tag_;
@synthesize message_flow_run_id = message_flow_run_id_;
@synthesize service = service_;
@synthesize static_flow_hash = static_flow_hash_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_service_PressMenuIconRequestTO *)init
{
    if (self = [super init]) {
        self.coords = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_service_PressMenuIconRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        NSArray *tmp_int_array_1 = [dict arrayForKey:@"coords"];
        if (tmp_int_array_1 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"coords"];
        for (id obj in tmp_int_array_1) {
            if (![obj isKindOfClass:MCTLongClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"coords"];
            MCTlong l = [obj longValue];
            if (l < MCT_MIN_LONG || l > MCT_MAX_LONG)
                return [self errorDuringInitBecauseOfFieldWithName:@"coords"];
        }
        self.coords = tmp_int_array_1;

        if (![dict containsLongObjectForKey:@"generation"])
            return [self errorDuringInitBecauseOfFieldWithName:@"generation"];
        self.generation = [dict longForKey:@"generation"];

        self.hashed_tag = [dict stringForKey:@"hashed_tag"];
        if (self.hashed_tag == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"hashed_tag"];
        if (self.hashed_tag == MCTNull)
            self.hashed_tag = nil;

        self.message_flow_run_id = [dict stringForKey:@"message_flow_run_id"];
        if (self.message_flow_run_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_flow_run_id"];
        if (self.message_flow_run_id == MCTNull)
            self.message_flow_run_id = nil;

        self.service = [dict stringForKey:@"service"];
        if (self.service == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"service"];
        if (self.service == MCTNull)
            self.service = nil;

        self.static_flow_hash = [dict stringForKey:@"static_flow_hash"];
        if (self.static_flow_hash == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"static_flow_hash"];
        if (self.static_flow_hash == MCTNull)
            self.static_flow_hash = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_service_PressMenuIconRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_PressMenuIconRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_service_PressMenuIconRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_PressMenuIconRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.context forKey:@"context"];

    // TODO: add checking that all members are indeed longs
    [dict setArray:self.coords forKey:@"coords"];

    [dict setLong:self.generation forKey:@"generation"];

    [dict setString:self.hashed_tag forKey:@"hashed_tag"];

    [dict setString:self.message_flow_run_id forKey:@"message_flow_run_id"];

    [dict setString:self.service forKey:@"service"];

    [dict setString:self.static_flow_hash forKey:@"static_flow_hash"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_PressMenuIconResponseTO


- (MCT_com_mobicage_to_service_PressMenuIconResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_PressMenuIconResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_service_PressMenuIconResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_PressMenuIconResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_service_PressMenuIconResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_PressMenuIconResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_ReceiveApiCallResultRequestTO

@synthesize error = error_;
@synthesize idX = idX_;
@synthesize result = result_;

- (MCT_com_mobicage_to_service_ReceiveApiCallResultRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_ReceiveApiCallResultRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.error = [dict stringForKey:@"error"];
        if (self.error == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"error"];
        if (self.error == MCTNull)
            self.error = nil;

        if (![dict containsLongObjectForKey:@"id"])
            return [self errorDuringInitBecauseOfFieldWithName:@"id"];
        self.idX = [dict longForKey:@"id"];

        self.result = [dict stringForKey:@"result"];
        if (self.result == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"result"];
        if (self.result == MCTNull)
            self.result = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_service_ReceiveApiCallResultRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_ReceiveApiCallResultRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_service_ReceiveApiCallResultRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_ReceiveApiCallResultRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.error forKey:@"error"];

    [dict setLong:self.idX forKey:@"id"];

    [dict setString:self.result forKey:@"result"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_ReceiveApiCallResultResponseTO


- (MCT_com_mobicage_to_service_ReceiveApiCallResultResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_ReceiveApiCallResultResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_service_ReceiveApiCallResultResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_ReceiveApiCallResultResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_service_ReceiveApiCallResultResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_ReceiveApiCallResultResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_SendApiCallRequestTO

@synthesize hashed_tag = hashed_tag_;
@synthesize idX = idX_;
@synthesize method = method_;
@synthesize params = params_;
@synthesize service = service_;

- (MCT_com_mobicage_to_service_SendApiCallRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_SendApiCallRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.hashed_tag = [dict stringForKey:@"hashed_tag"];
        if (self.hashed_tag == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"hashed_tag"];
        if (self.hashed_tag == MCTNull)
            self.hashed_tag = nil;

        if (![dict containsLongObjectForKey:@"id"])
            return [self errorDuringInitBecauseOfFieldWithName:@"id"];
        self.idX = [dict longForKey:@"id"];

        self.method = [dict stringForKey:@"method"];
        if (self.method == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"method"];
        if (self.method == MCTNull)
            self.method = nil;

        self.params = [dict stringForKey:@"params"];
        if (self.params == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"params"];
        if (self.params == MCTNull)
            self.params = nil;

        self.service = [dict stringForKey:@"service"];
        if (self.service == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"service"];
        if (self.service == MCTNull)
            self.service = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_service_SendApiCallRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_SendApiCallRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_service_SendApiCallRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_SendApiCallRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.hashed_tag forKey:@"hashed_tag"];

    [dict setLong:self.idX forKey:@"id"];

    [dict setString:self.method forKey:@"method"];

    [dict setString:self.params forKey:@"params"];

    [dict setString:self.service forKey:@"service"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_SendApiCallResponseTO


- (MCT_com_mobicage_to_service_SendApiCallResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_SendApiCallResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_service_SendApiCallResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_SendApiCallResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_service_SendApiCallResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_SendApiCallResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_ShareServiceRequestTO

@synthesize recipient = recipient_;
@synthesize service_email = service_email_;

- (MCT_com_mobicage_to_service_ShareServiceRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_ShareServiceRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.recipient = [dict stringForKey:@"recipient"];
        if (self.recipient == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"recipient"];
        if (self.recipient == MCTNull)
            self.recipient = nil;

        self.service_email = [dict stringForKey:@"service_email"];
        if (self.service_email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"service_email"];
        if (self.service_email == MCTNull)
            self.service_email = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_service_ShareServiceRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_ShareServiceRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_service_ShareServiceRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_ShareServiceRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.recipient forKey:@"recipient"];

    [dict setString:self.service_email forKey:@"service_email"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_ShareServiceResponseTO


- (MCT_com_mobicage_to_service_ShareServiceResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_ShareServiceResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_service_ShareServiceResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_ShareServiceResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_service_ShareServiceResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_ShareServiceResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_StartServiceActionRequestTO

@synthesize action = action_;
@synthesize context = context_;
@synthesize email = email_;
@synthesize message_flow_run_id = message_flow_run_id_;
@synthesize static_flow_hash = static_flow_hash_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_service_StartServiceActionRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_StartServiceActionRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.action = [dict stringForKey:@"action"];
        if (self.action == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"action"];
        if (self.action == MCTNull)
            self.action = nil;

        self.context = [dict stringForKey:@"context"];
        if (self.context == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"context"];
        if (self.context == MCTNull)
            self.context = nil;

        self.email = [dict stringForKey:@"email"];
        if (self.email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"email"];
        if (self.email == MCTNull)
            self.email = nil;

        self.message_flow_run_id = [dict stringForKey:@"message_flow_run_id"];
        if (self.message_flow_run_id == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"message_flow_run_id"];
        if (self.message_flow_run_id == MCTNull)
            self.message_flow_run_id = nil;

        self.static_flow_hash = [dict stringForKey:@"static_flow_hash"];
        if (self.static_flow_hash == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"static_flow_hash"];
        if (self.static_flow_hash == MCTNull)
            self.static_flow_hash = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_service_StartServiceActionRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_StartServiceActionRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_service_StartServiceActionRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_StartServiceActionRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.action forKey:@"action"];

    [dict setString:self.context forKey:@"context"];

    [dict setString:self.email forKey:@"email"];

    [dict setString:self.message_flow_run_id forKey:@"message_flow_run_id"];

    [dict setString:self.static_flow_hash forKey:@"static_flow_hash"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_StartServiceActionResponseTO


- (MCT_com_mobicage_to_service_StartServiceActionResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_StartServiceActionResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_service_StartServiceActionResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_StartServiceActionResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_service_StartServiceActionResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_StartServiceActionResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_UpdateUserDataRequestTO

@synthesize app_data = app_data_;
@synthesize service = service_;
@synthesize user_data = user_data_;

- (MCT_com_mobicage_to_service_UpdateUserDataRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_UpdateUserDataRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.app_data = [dict stringForKey:@"app_data" withDefaultValue:nil];
        if (self.app_data == MCTNull)
            self.app_data = nil;

        self.service = [dict stringForKey:@"service"];
        if (self.service == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"service"];
        if (self.service == MCTNull)
            self.service = nil;

        self.user_data = [dict stringForKey:@"user_data" withDefaultValue:nil];
        if (self.user_data == MCTNull)
            self.user_data = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_service_UpdateUserDataRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_UpdateUserDataRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_service_UpdateUserDataRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_UpdateUserDataRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.app_data forKey:@"app_data"];

    [dict setString:self.service forKey:@"service"];

    [dict setString:self.user_data forKey:@"user_data"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_service_UpdateUserDataResponseTO


- (MCT_com_mobicage_to_service_UpdateUserDataResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_service_UpdateUserDataResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_service_UpdateUserDataResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_service_UpdateUserDataResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_service_UpdateUserDataResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_service_UpdateUserDataResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_EditProfileRequestTO

@synthesize access_token = access_token_;
@synthesize avatar = avatar_;
@synthesize birthdate = birthdate_;
@synthesize extra_fields = extra_fields_;
@synthesize gender = gender_;
@synthesize has_birthdate = has_birthdate_;
@synthesize has_gender = has_gender_;
@synthesize name = name_;

- (MCT_com_mobicage_to_system_EditProfileRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_EditProfileRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.access_token = [dict stringForKey:@"access_token"];
        if (self.access_token == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"access_token"];
        if (self.access_token == MCTNull)
            self.access_token = nil;

        self.avatar = [dict stringForKey:@"avatar"];
        if (self.avatar == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"avatar"];
        if (self.avatar == MCTNull)
            self.avatar = nil;

        self.birthdate = [dict longForKey:@"birthdate" withDefaultValue:0];

        self.extra_fields = [dict stringForKey:@"extra_fields" withDefaultValue:nil];
        if (self.extra_fields == MCTNull)
            self.extra_fields = nil;

        self.gender = [dict longForKey:@"gender" withDefaultValue:0];

        self.has_birthdate = [dict boolForKey:@"has_birthdate" withDefaultValue:NO];

        self.has_gender = [dict boolForKey:@"has_gender" withDefaultValue:NO];

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_system_EditProfileRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_EditProfileRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_system_EditProfileRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_EditProfileRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.access_token forKey:@"access_token"];

    [dict setString:self.avatar forKey:@"avatar"];

    [dict setLong:self.birthdate forKey:@"birthdate"];

    [dict setString:self.extra_fields forKey:@"extra_fields"];

    [dict setLong:self.gender forKey:@"gender"];

    [dict setBool:self.has_birthdate forKey:@"has_birthdate"];

    [dict setBool:self.has_gender forKey:@"has_gender"];

    [dict setString:self.name forKey:@"name"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_EditProfileResponseTO


- (MCT_com_mobicage_to_system_EditProfileResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_EditProfileResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_system_EditProfileResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_EditProfileResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_system_EditProfileResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_EditProfileResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_ForwardLogsRequestTO

@synthesize jid = jid_;

- (MCT_com_mobicage_to_system_ForwardLogsRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_ForwardLogsRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.jid = [dict stringForKey:@"jid"];
        if (self.jid == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"jid"];
        if (self.jid == MCTNull)
            self.jid = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_system_ForwardLogsRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_ForwardLogsRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_system_ForwardLogsRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_ForwardLogsRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.jid forKey:@"jid"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_ForwardLogsResponseTO


- (MCT_com_mobicage_to_system_ForwardLogsResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_ForwardLogsResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_system_ForwardLogsResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_ForwardLogsResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_system_ForwardLogsResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_ForwardLogsResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO

@synthesize email = email_;
@synthesize size = size_;

- (MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.email = [dict stringForKey:@"email"];
        if (self.email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"email"];
        if (self.email == MCTNull)
            self.email = nil;

        self.size = [dict stringForKey:@"size"];
        if (self.size == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"size"];
        if (self.size == MCTNull)
            self.size = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_GetIdentityQRCodeRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.email forKey:@"email"];

    [dict setString:self.size forKey:@"size"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_GetIdentityQRCodeResponseTO

@synthesize qrcode = qrcode_;
@synthesize shortUrl = shortUrl_;

- (MCT_com_mobicage_to_system_GetIdentityQRCodeResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_GetIdentityQRCodeResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.qrcode = [dict stringForKey:@"qrcode"];
        if (self.qrcode == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"qrcode"];
        if (self.qrcode == MCTNull)
            self.qrcode = nil;

        self.shortUrl = [dict stringForKey:@"shortUrl"];
        if (self.shortUrl == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"shortUrl"];
        if (self.shortUrl == MCTNull)
            self.shortUrl = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_system_GetIdentityQRCodeResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_GetIdentityQRCodeResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_system_GetIdentityQRCodeResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_GetIdentityQRCodeResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.qrcode forKey:@"qrcode"];

    [dict setString:self.shortUrl forKey:@"shortUrl"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_GetIdentityRequestTO


- (MCT_com_mobicage_to_system_GetIdentityRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_GetIdentityRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_system_GetIdentityRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_GetIdentityRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_system_GetIdentityRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_GetIdentityRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_GetIdentityResponseTO

@synthesize identity = identity_;
@synthesize shortUrl = shortUrl_;

- (MCT_com_mobicage_to_system_GetIdentityResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_GetIdentityResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"identity"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"identity"];
        if (tmp_dict_0 == MCTNull)
            self.identity = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_system_IdentityTO *tmp_to_0 = [MCT_com_mobicage_to_system_IdentityTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"identity"];
            self.identity = (MCT_com_mobicage_to_system_IdentityTO *)tmp_to_0;
        }

        self.shortUrl = [dict stringForKey:@"shortUrl"];
        if (self.shortUrl == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"shortUrl"];
        if (self.shortUrl == MCTNull)
            self.shortUrl = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_system_GetIdentityResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_GetIdentityResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_system_GetIdentityResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_GetIdentityResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.identity dictRepresentation] forKey:@"identity"];

    [dict setString:self.shortUrl forKey:@"shortUrl"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_HeartBeatRequestTO

@synthesize SDKVersion = SDKVersion_;
@synthesize appType = appType_;
@synthesize buildFingerPrint = buildFingerPrint_;
@synthesize deviceModelName = deviceModelName_;
@synthesize flushBackLog = flushBackLog_;
@synthesize localeCountry = localeCountry_;
@synthesize localeLanguage = localeLanguage_;
@synthesize majorVersion = majorVersion_;
@synthesize minorVersion = minorVersion_;
@synthesize netCarrierCode = netCarrierCode_;
@synthesize netCarrierName = netCarrierName_;
@synthesize netCountry = netCountry_;
@synthesize netCountryCode = netCountryCode_;
@synthesize networkState = networkState_;
@synthesize product = product_;
@synthesize simCarrierCode = simCarrierCode_;
@synthesize simCarrierName = simCarrierName_;
@synthesize simCountry = simCountry_;
@synthesize simCountryCode = simCountryCode_;
@synthesize timestamp = timestamp_;
@synthesize timezone = timezone_;
@synthesize timezoneDeltaGMT = timezoneDeltaGMT_;

- (MCT_com_mobicage_to_system_HeartBeatRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_HeartBeatRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.SDKVersion = [dict stringForKey:@"SDKVersion"];
        if (self.SDKVersion == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"SDKVersion"];
        if (self.SDKVersion == MCTNull)
            self.SDKVersion = nil;

        if (![dict containsLongObjectForKey:@"appType"])
            return [self errorDuringInitBecauseOfFieldWithName:@"appType"];
        self.appType = [dict longForKey:@"appType"];

        self.buildFingerPrint = [dict stringForKey:@"buildFingerPrint"];
        if (self.buildFingerPrint == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"buildFingerPrint"];
        if (self.buildFingerPrint == MCTNull)
            self.buildFingerPrint = nil;

        self.deviceModelName = [dict stringForKey:@"deviceModelName"];
        if (self.deviceModelName == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"deviceModelName"];
        if (self.deviceModelName == MCTNull)
            self.deviceModelName = nil;

        if (![dict containsBoolObjectForKey:@"flushBackLog"])
            return [self errorDuringInitBecauseOfFieldWithName:@"flushBackLog"];
        self.flushBackLog = [dict boolForKey:@"flushBackLog"];

        self.localeCountry = [dict stringForKey:@"localeCountry"];
        if (self.localeCountry == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"localeCountry"];
        if (self.localeCountry == MCTNull)
            self.localeCountry = nil;

        self.localeLanguage = [dict stringForKey:@"localeLanguage"];
        if (self.localeLanguage == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"localeLanguage"];
        if (self.localeLanguage == MCTNull)
            self.localeLanguage = nil;

        if (![dict containsLongObjectForKey:@"majorVersion"])
            return [self errorDuringInitBecauseOfFieldWithName:@"majorVersion"];
        self.majorVersion = [dict longForKey:@"majorVersion"];

        if (![dict containsLongObjectForKey:@"minorVersion"])
            return [self errorDuringInitBecauseOfFieldWithName:@"minorVersion"];
        self.minorVersion = [dict longForKey:@"minorVersion"];

        self.netCarrierCode = [dict stringForKey:@"netCarrierCode"];
        if (self.netCarrierCode == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"netCarrierCode"];
        if (self.netCarrierCode == MCTNull)
            self.netCarrierCode = nil;

        self.netCarrierName = [dict stringForKey:@"netCarrierName"];
        if (self.netCarrierName == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"netCarrierName"];
        if (self.netCarrierName == MCTNull)
            self.netCarrierName = nil;

        self.netCountry = [dict stringForKey:@"netCountry"];
        if (self.netCountry == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"netCountry"];
        if (self.netCountry == MCTNull)
            self.netCountry = nil;

        self.netCountryCode = [dict stringForKey:@"netCountryCode"];
        if (self.netCountryCode == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"netCountryCode"];
        if (self.netCountryCode == MCTNull)
            self.netCountryCode = nil;

        self.networkState = [dict stringForKey:@"networkState"];
        if (self.networkState == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"networkState"];
        if (self.networkState == MCTNull)
            self.networkState = nil;

        self.product = [dict stringForKey:@"product"];
        if (self.product == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"product"];
        if (self.product == MCTNull)
            self.product = nil;

        self.simCarrierCode = [dict stringForKey:@"simCarrierCode"];
        if (self.simCarrierCode == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"simCarrierCode"];
        if (self.simCarrierCode == MCTNull)
            self.simCarrierCode = nil;

        self.simCarrierName = [dict stringForKey:@"simCarrierName"];
        if (self.simCarrierName == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"simCarrierName"];
        if (self.simCarrierName == MCTNull)
            self.simCarrierName = nil;

        self.simCountry = [dict stringForKey:@"simCountry"];
        if (self.simCountry == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"simCountry"];
        if (self.simCountry == MCTNull)
            self.simCountry = nil;

        self.simCountryCode = [dict stringForKey:@"simCountryCode"];
        if (self.simCountryCode == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"simCountryCode"];
        if (self.simCountryCode == MCTNull)
            self.simCountryCode = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        self.timezone = [dict stringForKey:@"timezone"];
        if (self.timezone == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"timezone"];
        if (self.timezone == MCTNull)
            self.timezone = nil;

        if (![dict containsLongObjectForKey:@"timezoneDeltaGMT"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timezoneDeltaGMT"];
        self.timezoneDeltaGMT = [dict longForKey:@"timezoneDeltaGMT"];

        return self;
    }
}

+ (MCT_com_mobicage_to_system_HeartBeatRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_HeartBeatRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_system_HeartBeatRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_HeartBeatRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.SDKVersion forKey:@"SDKVersion"];

    [dict setLong:self.appType forKey:@"appType"];

    [dict setString:self.buildFingerPrint forKey:@"buildFingerPrint"];

    [dict setString:self.deviceModelName forKey:@"deviceModelName"];

    [dict setBool:self.flushBackLog forKey:@"flushBackLog"];

    [dict setString:self.localeCountry forKey:@"localeCountry"];

    [dict setString:self.localeLanguage forKey:@"localeLanguage"];

    [dict setLong:self.majorVersion forKey:@"majorVersion"];

    [dict setLong:self.minorVersion forKey:@"minorVersion"];

    [dict setString:self.netCarrierCode forKey:@"netCarrierCode"];

    [dict setString:self.netCarrierName forKey:@"netCarrierName"];

    [dict setString:self.netCountry forKey:@"netCountry"];

    [dict setString:self.netCountryCode forKey:@"netCountryCode"];

    [dict setString:self.networkState forKey:@"networkState"];

    [dict setString:self.product forKey:@"product"];

    [dict setString:self.simCarrierCode forKey:@"simCarrierCode"];

    [dict setString:self.simCarrierName forKey:@"simCarrierName"];

    [dict setString:self.simCountry forKey:@"simCountry"];

    [dict setString:self.simCountryCode forKey:@"simCountryCode"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    [dict setString:self.timezone forKey:@"timezone"];

    [dict setLong:self.timezoneDeltaGMT forKey:@"timezoneDeltaGMT"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_HeartBeatResponseTO

@synthesize systemTime = systemTime_;

- (MCT_com_mobicage_to_system_HeartBeatResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_HeartBeatResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"systemTime"])
            return [self errorDuringInitBecauseOfFieldWithName:@"systemTime"];
        self.systemTime = [dict longForKey:@"systemTime"];

        return self;
    }
}

+ (MCT_com_mobicage_to_system_HeartBeatResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_HeartBeatResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_system_HeartBeatResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_HeartBeatResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.systemTime forKey:@"systemTime"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_IdentityTO

@synthesize avatarId = avatarId_;
@synthesize birthdate = birthdate_;
@synthesize email = email_;
@synthesize gender = gender_;
@synthesize hasBirthdate = hasBirthdate_;
@synthesize hasGender = hasGender_;
@synthesize name = name_;
@synthesize profileData = profileData_;
@synthesize qualifiedIdentifier = qualifiedIdentifier_;

- (MCT_com_mobicage_to_system_IdentityTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_IdentityTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsLongObjectForKey:@"avatarId"])
            return [self errorDuringInitBecauseOfFieldWithName:@"avatarId"];
        self.avatarId = [dict longForKey:@"avatarId"];

        self.birthdate = [dict longForKey:@"birthdate" withDefaultValue:0];

        self.email = [dict stringForKey:@"email"];
        if (self.email == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"email"];
        if (self.email == MCTNull)
            self.email = nil;

        self.gender = [dict longForKey:@"gender" withDefaultValue:0];

        self.hasBirthdate = [dict boolForKey:@"hasBirthdate" withDefaultValue:NO];

        self.hasGender = [dict boolForKey:@"hasGender" withDefaultValue:NO];

        self.name = [dict stringForKey:@"name"];
        if (self.name == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"name"];
        if (self.name == MCTNull)
            self.name = nil;

        self.profileData = [dict stringForKey:@"profileData" withDefaultValue:nil];
        if (self.profileData == MCTNull)
            self.profileData = nil;

        self.qualifiedIdentifier = [dict stringForKey:@"qualifiedIdentifier"];
        if (self.qualifiedIdentifier == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"qualifiedIdentifier"];
        if (self.qualifiedIdentifier == MCTNull)
            self.qualifiedIdentifier = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_system_IdentityTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_IdentityTO alloc] init];
}

+ (MCT_com_mobicage_to_system_IdentityTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_IdentityTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setLong:self.avatarId forKey:@"avatarId"];

    [dict setLong:self.birthdate forKey:@"birthdate"];

    [dict setString:self.email forKey:@"email"];

    [dict setLong:self.gender forKey:@"gender"];

    [dict setBool:self.hasBirthdate forKey:@"hasBirthdate"];

    [dict setBool:self.hasGender forKey:@"hasGender"];

    [dict setString:self.name forKey:@"name"];

    [dict setString:self.profileData forKey:@"profileData"];

    [dict setString:self.qualifiedIdentifier forKey:@"qualifiedIdentifier"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_IdentityUpdateRequestTO

@synthesize identity = identity_;

- (MCT_com_mobicage_to_system_IdentityUpdateRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_IdentityUpdateRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"identity"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"identity"];
        if (tmp_dict_0 == MCTNull)
            self.identity = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_system_IdentityTO *tmp_to_0 = [MCT_com_mobicage_to_system_IdentityTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"identity"];
            self.identity = (MCT_com_mobicage_to_system_IdentityTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_system_IdentityUpdateRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_IdentityUpdateRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_system_IdentityUpdateRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_IdentityUpdateRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.identity dictRepresentation] forKey:@"identity"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_IdentityUpdateResponseTO


- (MCT_com_mobicage_to_system_IdentityUpdateResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_IdentityUpdateResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_system_IdentityUpdateResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_IdentityUpdateResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_system_IdentityUpdateResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_IdentityUpdateResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_LogErrorRequestTO

@synthesize descriptionX = descriptionX_;
@synthesize errorMessage = errorMessage_;
@synthesize mobicageVersion = mobicageVersion_;
@synthesize platform = platform_;
@synthesize platformVersion = platformVersion_;
@synthesize timestamp = timestamp_;

- (MCT_com_mobicage_to_system_LogErrorRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_LogErrorRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.descriptionX = [dict stringForKey:@"description"];
        if (self.descriptionX == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"description"];
        if (self.descriptionX == MCTNull)
            self.descriptionX = nil;

        self.errorMessage = [dict stringForKey:@"errorMessage"];
        if (self.errorMessage == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"errorMessage"];
        if (self.errorMessage == MCTNull)
            self.errorMessage = nil;

        self.mobicageVersion = [dict stringForKey:@"mobicageVersion"];
        if (self.mobicageVersion == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"mobicageVersion"];
        if (self.mobicageVersion == MCTNull)
            self.mobicageVersion = nil;

        if (![dict containsLongObjectForKey:@"platform"])
            return [self errorDuringInitBecauseOfFieldWithName:@"platform"];
        self.platform = [dict longForKey:@"platform"];

        self.platformVersion = [dict stringForKey:@"platformVersion"];
        if (self.platformVersion == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"platformVersion"];
        if (self.platformVersion == MCTNull)
            self.platformVersion = nil;

        if (![dict containsLongObjectForKey:@"timestamp"])
            return [self errorDuringInitBecauseOfFieldWithName:@"timestamp"];
        self.timestamp = [dict longForKey:@"timestamp"];

        return self;
    }
}

+ (MCT_com_mobicage_to_system_LogErrorRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_LogErrorRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_system_LogErrorRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_LogErrorRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.descriptionX forKey:@"description"];

    [dict setString:self.errorMessage forKey:@"errorMessage"];

    [dict setString:self.mobicageVersion forKey:@"mobicageVersion"];

    [dict setLong:self.platform forKey:@"platform"];

    [dict setString:self.platformVersion forKey:@"platformVersion"];

    [dict setLong:self.timestamp forKey:@"timestamp"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_LogErrorResponseTO


- (MCT_com_mobicage_to_system_LogErrorResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_LogErrorResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_system_LogErrorResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_LogErrorResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_system_LogErrorResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_LogErrorResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_SaveSettingsRequest

@synthesize callLogging = callLogging_;
@synthesize tracking = tracking_;

- (MCT_com_mobicage_to_system_SaveSettingsRequest *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_SaveSettingsRequest *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        if (![dict containsBoolObjectForKey:@"callLogging"])
            return [self errorDuringInitBecauseOfFieldWithName:@"callLogging"];
        self.callLogging = [dict boolForKey:@"callLogging"];

        if (![dict containsBoolObjectForKey:@"tracking"])
            return [self errorDuringInitBecauseOfFieldWithName:@"tracking"];
        self.tracking = [dict boolForKey:@"tracking"];

        return self;
    }
}

+ (MCT_com_mobicage_to_system_SaveSettingsRequest *)transferObject
{
    return [[MCT_com_mobicage_to_system_SaveSettingsRequest alloc] init];
}

+ (MCT_com_mobicage_to_system_SaveSettingsRequest *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_SaveSettingsRequest alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setBool:self.callLogging forKey:@"callLogging"];

    [dict setBool:self.tracking forKey:@"tracking"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_SaveSettingsResponse

@synthesize settings = settings_;

- (MCT_com_mobicage_to_system_SaveSettingsResponse *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_SaveSettingsResponse *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"settings"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"settings"];
        if (tmp_dict_0 == MCTNull)
            self.settings = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_system_SettingsTO *tmp_to_0 = [MCT_com_mobicage_to_system_SettingsTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"settings"];
            self.settings = (MCT_com_mobicage_to_system_SettingsTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_system_SaveSettingsResponse *)transferObject
{
    return [[MCT_com_mobicage_to_system_SaveSettingsResponse alloc] init];
}

+ (MCT_com_mobicage_to_system_SaveSettingsResponse *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_SaveSettingsResponse alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.settings dictRepresentation] forKey:@"settings"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_SetMobilePhoneNumberRequestTO

@synthesize phoneNumber = phoneNumber_;

- (MCT_com_mobicage_to_system_SetMobilePhoneNumberRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_SetMobilePhoneNumberRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.phoneNumber = [dict stringForKey:@"phoneNumber"];
        if (self.phoneNumber == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"phoneNumber"];
        if (self.phoneNumber == MCTNull)
            self.phoneNumber = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_system_SetMobilePhoneNumberRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_SetMobilePhoneNumberRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_system_SetMobilePhoneNumberRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_SetMobilePhoneNumberRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.phoneNumber forKey:@"phoneNumber"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_SetMobilePhoneNumberResponseTO


- (MCT_com_mobicage_to_system_SetMobilePhoneNumberResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_SetMobilePhoneNumberResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_system_SetMobilePhoneNumberResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_SetMobilePhoneNumberResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_system_SetMobilePhoneNumberResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_SetMobilePhoneNumberResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_SettingsTO

@synthesize backgroundFetchTimestamps = backgroundFetchTimestamps_;
@synthesize geoLocationSamplingIntervalBattery = geoLocationSamplingIntervalBattery_;
@synthesize geoLocationSamplingIntervalCharging = geoLocationSamplingIntervalCharging_;
@synthesize geoLocationTracking = geoLocationTracking_;
@synthesize geoLocationTrackingDays = geoLocationTrackingDays_;
@synthesize geoLocationTrackingTimeslot = geoLocationTrackingTimeslot_;
@synthesize operatingVersion = operatingVersion_;
@synthesize recordGeoLocationWithPhoneCalls = recordGeoLocationWithPhoneCalls_;
@synthesize recordPhoneCalls = recordPhoneCalls_;
@synthesize recordPhoneCallsDays = recordPhoneCallsDays_;
@synthesize recordPhoneCallsTimeslot = recordPhoneCallsTimeslot_;
@synthesize useGPSBattery = useGPSBattery_;
@synthesize useGPSCharging = useGPSCharging_;
@synthesize version = version_;
@synthesize wifiOnlyDownloads = wifiOnlyDownloads_;
@synthesize xmppReconnectInterval = xmppReconnectInterval_;

- (MCT_com_mobicage_to_system_SettingsTO *)init
{
    if (self = [super init]) {
        self.backgroundFetchTimestamps = [NSMutableArray array];
        self.geoLocationTrackingTimeslot = [NSMutableArray array];
        self.recordPhoneCallsTimeslot = [NSMutableArray array];
        return self;
    }
}

- (MCT_com_mobicage_to_system_SettingsTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSArray *tmp_int_array_0 = [dict arrayForKey:@"backgroundFetchTimestamps" withDefaultValue:[NSMutableArray arrayWithCapacity:0]];
        for (id obj in tmp_int_array_0) {
            if (![obj isKindOfClass:MCTLongClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"backgroundFetchTimestamps"];
            MCTlong l = [obj longValue];
            if (l < MCT_MIN_LONG || l > MCT_MAX_LONG)
                return [self errorDuringInitBecauseOfFieldWithName:@"backgroundFetchTimestamps"];
        }
        self.backgroundFetchTimestamps = tmp_int_array_0;

        if (![dict containsLongObjectForKey:@"geoLocationSamplingIntervalBattery"])
            return [self errorDuringInitBecauseOfFieldWithName:@"geoLocationSamplingIntervalBattery"];
        self.geoLocationSamplingIntervalBattery = [dict longForKey:@"geoLocationSamplingIntervalBattery"];

        if (![dict containsLongObjectForKey:@"geoLocationSamplingIntervalCharging"])
            return [self errorDuringInitBecauseOfFieldWithName:@"geoLocationSamplingIntervalCharging"];
        self.geoLocationSamplingIntervalCharging = [dict longForKey:@"geoLocationSamplingIntervalCharging"];

        if (![dict containsBoolObjectForKey:@"geoLocationTracking"])
            return [self errorDuringInitBecauseOfFieldWithName:@"geoLocationTracking"];
        self.geoLocationTracking = [dict boolForKey:@"geoLocationTracking"];

        if (![dict containsLongObjectForKey:@"geoLocationTrackingDays"])
            return [self errorDuringInitBecauseOfFieldWithName:@"geoLocationTrackingDays"];
        self.geoLocationTrackingDays = [dict longForKey:@"geoLocationTrackingDays"];

        NSArray *tmp_int_array_5 = [dict arrayForKey:@"geoLocationTrackingTimeslot"];
        if (tmp_int_array_5 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"geoLocationTrackingTimeslot"];
        for (id obj in tmp_int_array_5) {
            if (![obj isKindOfClass:MCTLongClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"geoLocationTrackingTimeslot"];
            MCTlong l = [obj longValue];
            if (l < MCT_MIN_LONG || l > MCT_MAX_LONG)
                return [self errorDuringInitBecauseOfFieldWithName:@"geoLocationTrackingTimeslot"];
        }
        self.geoLocationTrackingTimeslot = tmp_int_array_5;

        if (![dict containsLongObjectForKey:@"operatingVersion"])
            return [self errorDuringInitBecauseOfFieldWithName:@"operatingVersion"];
        self.operatingVersion = [dict longForKey:@"operatingVersion"];

        if (![dict containsBoolObjectForKey:@"recordGeoLocationWithPhoneCalls"])
            return [self errorDuringInitBecauseOfFieldWithName:@"recordGeoLocationWithPhoneCalls"];
        self.recordGeoLocationWithPhoneCalls = [dict boolForKey:@"recordGeoLocationWithPhoneCalls"];

        if (![dict containsBoolObjectForKey:@"recordPhoneCalls"])
            return [self errorDuringInitBecauseOfFieldWithName:@"recordPhoneCalls"];
        self.recordPhoneCalls = [dict boolForKey:@"recordPhoneCalls"];

        if (![dict containsLongObjectForKey:@"recordPhoneCallsDays"])
            return [self errorDuringInitBecauseOfFieldWithName:@"recordPhoneCallsDays"];
        self.recordPhoneCallsDays = [dict longForKey:@"recordPhoneCallsDays"];

        NSArray *tmp_int_array_10 = [dict arrayForKey:@"recordPhoneCallsTimeslot"];
        if (tmp_int_array_10 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"recordPhoneCallsTimeslot"];
        for (id obj in tmp_int_array_10) {
            if (![obj isKindOfClass:MCTLongClass])
                return [self errorDuringInitBecauseOfFieldWithName:@"recordPhoneCallsTimeslot"];
            MCTlong l = [obj longValue];
            if (l < MCT_MIN_LONG || l > MCT_MAX_LONG)
                return [self errorDuringInitBecauseOfFieldWithName:@"recordPhoneCallsTimeslot"];
        }
        self.recordPhoneCallsTimeslot = tmp_int_array_10;

        if (![dict containsBoolObjectForKey:@"useGPSBattery"])
            return [self errorDuringInitBecauseOfFieldWithName:@"useGPSBattery"];
        self.useGPSBattery = [dict boolForKey:@"useGPSBattery"];

        if (![dict containsBoolObjectForKey:@"useGPSCharging"])
            return [self errorDuringInitBecauseOfFieldWithName:@"useGPSCharging"];
        self.useGPSCharging = [dict boolForKey:@"useGPSCharging"];

        if (![dict containsLongObjectForKey:@"version"])
            return [self errorDuringInitBecauseOfFieldWithName:@"version"];
        self.version = [dict longForKey:@"version"];

        self.wifiOnlyDownloads = [dict boolForKey:@"wifiOnlyDownloads" withDefaultValue:NO];

        if (![dict containsLongObjectForKey:@"xmppReconnectInterval"])
            return [self errorDuringInitBecauseOfFieldWithName:@"xmppReconnectInterval"];
        self.xmppReconnectInterval = [dict longForKey:@"xmppReconnectInterval"];

        return self;
    }
}

+ (MCT_com_mobicage_to_system_SettingsTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_SettingsTO alloc] init];
}

+ (MCT_com_mobicage_to_system_SettingsTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_SettingsTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // TODO: add checking that all members are indeed longs
    [dict setArray:self.backgroundFetchTimestamps forKey:@"backgroundFetchTimestamps"];

    [dict setLong:self.geoLocationSamplingIntervalBattery forKey:@"geoLocationSamplingIntervalBattery"];

    [dict setLong:self.geoLocationSamplingIntervalCharging forKey:@"geoLocationSamplingIntervalCharging"];

    [dict setBool:self.geoLocationTracking forKey:@"geoLocationTracking"];

    [dict setLong:self.geoLocationTrackingDays forKey:@"geoLocationTrackingDays"];

    // TODO: add checking that all members are indeed longs
    [dict setArray:self.geoLocationTrackingTimeslot forKey:@"geoLocationTrackingTimeslot"];

    [dict setLong:self.operatingVersion forKey:@"operatingVersion"];

    [dict setBool:self.recordGeoLocationWithPhoneCalls forKey:@"recordGeoLocationWithPhoneCalls"];

    [dict setBool:self.recordPhoneCalls forKey:@"recordPhoneCalls"];

    [dict setLong:self.recordPhoneCallsDays forKey:@"recordPhoneCallsDays"];

    // TODO: add checking that all members are indeed longs
    [dict setArray:self.recordPhoneCallsTimeslot forKey:@"recordPhoneCallsTimeslot"];

    [dict setBool:self.useGPSBattery forKey:@"useGPSBattery"];

    [dict setBool:self.useGPSCharging forKey:@"useGPSCharging"];

    [dict setLong:self.version forKey:@"version"];

    [dict setBool:self.wifiOnlyDownloads forKey:@"wifiOnlyDownloads"];

    [dict setLong:self.xmppReconnectInterval forKey:@"xmppReconnectInterval"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_UnregisterMobileRequestTO


- (MCT_com_mobicage_to_system_UnregisterMobileRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_UnregisterMobileRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_system_UnregisterMobileRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_UnregisterMobileRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_system_UnregisterMobileRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_UnregisterMobileRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_UnregisterMobileResponseTO


- (MCT_com_mobicage_to_system_UnregisterMobileResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_UnregisterMobileResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_system_UnregisterMobileResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_UnregisterMobileResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_system_UnregisterMobileResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_UnregisterMobileResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenRequestTO

@synthesize token = token_;

- (MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.token = [dict stringForKey:@"token"];
        if (self.token == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"token"];
        if (self.token == MCTNull)
            self.token = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.token forKey:@"token"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenResponseTO


- (MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_UpdateApplePushDeviceTokenResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_UpdateAvailableRequestTO

@synthesize downloadUrl = downloadUrl_;
@synthesize majorVersion = majorVersion_;
@synthesize minorVersion = minorVersion_;
@synthesize releaseNotes = releaseNotes_;

- (MCT_com_mobicage_to_system_UpdateAvailableRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_UpdateAvailableRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        self.downloadUrl = [dict stringForKey:@"downloadUrl"];
        if (self.downloadUrl == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"downloadUrl"];
        if (self.downloadUrl == MCTNull)
            self.downloadUrl = nil;

        if (![dict containsLongObjectForKey:@"majorVersion"])
            return [self errorDuringInitBecauseOfFieldWithName:@"majorVersion"];
        self.majorVersion = [dict longForKey:@"majorVersion"];

        if (![dict containsLongObjectForKey:@"minorVersion"])
            return [self errorDuringInitBecauseOfFieldWithName:@"minorVersion"];
        self.minorVersion = [dict longForKey:@"minorVersion"];

        self.releaseNotes = [dict stringForKey:@"releaseNotes"];
        if (self.releaseNotes == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"releaseNotes"];
        if (self.releaseNotes == MCTNull)
            self.releaseNotes = nil;

        return self;
    }
}

+ (MCT_com_mobicage_to_system_UpdateAvailableRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_UpdateAvailableRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_system_UpdateAvailableRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_UpdateAvailableRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setString:self.downloadUrl forKey:@"downloadUrl"];

    [dict setLong:self.majorVersion forKey:@"majorVersion"];

    [dict setLong:self.minorVersion forKey:@"minorVersion"];

    [dict setString:self.releaseNotes forKey:@"releaseNotes"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_UpdateAvailableResponseTO


- (MCT_com_mobicage_to_system_UpdateAvailableResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_UpdateAvailableResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_system_UpdateAvailableResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_UpdateAvailableResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_system_UpdateAvailableResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_UpdateAvailableResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_UpdateSettingsRequestTO

@synthesize settings = settings_;

- (MCT_com_mobicage_to_system_UpdateSettingsRequestTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_UpdateSettingsRequestTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        NSDictionary *tmp_dict_0 = [dict dictForKey:@"settings"];
        if (tmp_dict_0 == nil)
            return [self errorDuringInitBecauseOfFieldWithName:@"settings"];
        if (tmp_dict_0 == MCTNull)
            self.settings = nil;
        else if (tmp_dict_0 != nil) {
            MCT_com_mobicage_to_system_SettingsTO *tmp_to_0 = [MCT_com_mobicage_to_system_SettingsTO transferObjectWithDict:tmp_dict_0];
            if (tmp_to_0 == nil)
                return [self errorDuringInitBecauseOfFieldWithName:@"settings"];
            self.settings = (MCT_com_mobicage_to_system_SettingsTO *)tmp_to_0;
        }

        return self;
    }
}

+ (MCT_com_mobicage_to_system_UpdateSettingsRequestTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_UpdateSettingsRequestTO alloc] init];
}

+ (MCT_com_mobicage_to_system_UpdateSettingsRequestTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_UpdateSettingsRequestTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setDict:[self.settings dictRepresentation] forKey:@"settings"];

    return dict;
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation MCT_com_mobicage_to_system_UpdateSettingsResponseTO


- (MCT_com_mobicage_to_system_UpdateSettingsResponseTO *)init
{
    if (self = [super init]) {
        return self;
    }
}

- (MCT_com_mobicage_to_system_UpdateSettingsResponseTO *)initWithDict:(NSDictionary *)dict
{
    if ((dict == nil) || ![dict isKindOfClass:MCTDictClass])
        return [self errorDuringInitBecauseOfFieldWithName:@""];

    if (self = [super init]) {
        return self;
    }
}

+ (MCT_com_mobicage_to_system_UpdateSettingsResponseTO *)transferObject
{
    return [[MCT_com_mobicage_to_system_UpdateSettingsResponseTO alloc] init];
}

+ (MCT_com_mobicage_to_system_UpdateSettingsResponseTO *)transferObjectWithDict:(NSDictionary *)dict
{
    return [[MCT_com_mobicage_to_system_UpdateSettingsResponseTO alloc] initWithDict:dict];
}

- (NSDictionary *)dictRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    return dict;
}

@end
