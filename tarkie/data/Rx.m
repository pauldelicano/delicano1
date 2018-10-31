#import "Rx.h"
#import "App.h"
#import "Process.h"
#import "Get.h"
#import "Update.h"
#import "Http.h"
#import "File.h"
#import "Time.h"
#import "Sqlite.h"

@implementation Rx

static BOOL isCanceled;

+ (BOOL)patches:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    int64_t userID = [Get userID:db];
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", userID];
    params[@"get_by"] = @"pending";
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-adminpanel-patch"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            Sqlite *sqlite = Sqlite.alloc.init;
            [sqlite openConnection];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t patchID = [data[x][@"patch_id"] longLongValue];
                NSString *query = data[x][@"query"];
                Patches *patch = [Get patch:db patchID:patchID];
                if(patch == nil) {
                    patch = [NSEntityDescription insertNewObjectForEntityForName:@"Patches" inManagedObjectContext:db];
                    patch.patchID = patchID;
                }
                patch.date = data[x][@"date_created"];
                patch.time = data[x][@"time_created"];
                patch.employeeID = userID;
                patch.query = query;
                patch.isDone = [data[x][@"is_done"] intValue] == 1;
                patch.isDone = [sqlite executeQuery:data[x][@"query"]];
                patch.isSync = NO;
            }
            [sqlite closeConnection];
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)company:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-company"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            Company *company = [Get company:db];
            if(company == nil) {
                company = [NSEntityDescription insertNewObjectForEntityForName:@"Company" inManagedObjectContext:db];
            }
            for(int x = 0; x < data.count && !isCanceled; x++) {
                company.companyID = [data[x][@"company_id"] longLongValue];
                company.name = data[x][@"company_name"];
                company.logoURL = data[x][@"company_logo"];
                NSArray *modules = data[x][@"modules"];
                for(int y = 1; y <= MODULE_FORMS; y++) {
                    Modules *module = [Get module:db moduleID:y];
                    if(module == nil) {
                        module = [NSEntityDescription insertNewObjectForEntityForName:@"Modules" inManagedObjectContext:db];
                        module.moduleID = y;
                    }
                    module.name = nil;
                    module.isEnabled = NO;
                    switch(y) {
                        case MODULE_ATTENDANCE: {
                            module.name = @"attendance";
                            break;
                        }
                        case MODULE_VISITS: {
                            module.name = @"itinerary";
                            break;
                        }
                        case MODULE_EXPENSE: {
                            module.name = @"expense";
                            break;
                        }
                        case MODULE_INVENTORY: {
                            module.name = @"inventory";
                            break;
                        }
                        case MODULE_FORMS: {
                            module.name = @"forms";
                            break;
                        }
                    }
                    if(module.name != nil) {
                        module.isEnabled = [modules indexOfObject:module.name] != -1;
                    }
                }
            }
            if(![Update save:db]) {
                message = @"";
            }
            if(message == nil) {
                [File deleteFromCaches:[NSString stringWithFormat:@"COMPANY_LOGO_%lld%@", company.companyID, @".png"]];
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)employees:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-employee-details"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            [Update employeesDeactivate:db];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t employeeID = [data[x][@"employee_id"] longLongValue];
                Employees *employee = [Get employee:db employeeID:employeeID];
                if(employee == nil) {
                    employee = [NSEntityDescription insertNewObjectForEntityForName:@"Employees" inManagedObjectContext:db];
                    employee.employeeID = employeeID;
                }
                employee.firstName = data[x][@"firstname"];
                employee.lastName = data[x][@"lastname"];
                employee.employeeNumber = data[x][@"employee_number"];
                employee.photoURL = data[x][@"picture_url"];
                employee.teamID = [data[x][@"team_id"] longLongValue];
                employee.storeID = [data[x][@"store_id"] longLongValue];
                employee.withLate = [data[x][@"eligible_for_late"] intValue] == 1;
                employee.withOvertime = [data[x][@"eligible_for_ot"] intValue] == 1;
                employee.isApprover = [data[x][@"is_approver"] intValue] == 1;
                employee.isActive = [data[x][@"is_active"] isEqualToString:@"yes"];
            }
            if(![Update save:db]) {
                message = @"";
            }
            if(message == nil) {
                [File deleteFromCaches:[NSString stringWithFormat:@"EMPLOYEE_PHOTO_%lld%@", [Get userID:db], @".png"]];
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)settings:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-settings"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            NSNumber *teamID = [NSNumber numberWithUnsignedLongLong:[Get employee:db employeeID:[Get userID:db]].teamID];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                NSString *settingName = data[x][@"settings_code"];
                int64_t settingID = [data[x][@"settings_id"] longLongValue];
                settingID = [Get settingID:db settingName:settingName];
                Settings *setting = [Get setting:db settingID:settingID];
                if(setting == nil) {
                    setting = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:db];
                    setting.settingID = settingID;
                }
                setting.name = settingName;
                SettingsTeams *settingTeam = [Get settingTeam:db settingID:settingID teamID:teamID.longLongValue];
                if(settingTeam == nil) {
                    settingTeam = [NSEntityDescription insertNewObjectForEntityForName:@"SettingsTeams" inManagedObjectContext:db];
                    settingTeam.settingID = settingID;
                    settingTeam.teamID = teamID.longLongValue;
                }
                NSString *value = data[x][@"settings_value"];
                if(![value isEqualToString:@"no"]) {
                    id team = data[x][@"team_id"];
                    if(([team isKindOfClass:NSArray.class] && [team indexOfObject:teamID] == -1) || ([team isKindOfClass:NSString.class] && ![team isEqualToString:@"allteams"])) {
                        value = @"no";
                    }
                }
                settingTeam.value = value;
            }
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)conventions:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-naming-convention"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count && !isCanceled; x++) {
                for(int y = 1; y <= CONVENTION_SALES; y++) {
                    Conventions *convention = [Get convention:db conventionID:y];
                    if(convention == nil) {
                        convention = [NSEntityDescription insertNewObjectForEntityForName:@"Conventions" inManagedObjectContext:db];
                        convention.conventionID = y;
                    }
                    convention.name = nil;
                    convention.value = nil;
                    switch(y) {
                        case CONVENTION_EMPLOYEES: {
                            convention.name = @"employees";
                            convention.value = @"employees";
                            break;
                        }
                        case CONVENTION_STORES: {
                            convention.name = @"stores";
                            convention.value = @"stores";
                            break;
                        }
                        case CONVENTION_TIME_IN: {
                            convention.name = @"startday";
                            convention.value = @"time in";
                            break;
                        }
                        case CONVENTION_TIME_OUT: {
                            convention.name = @"endday";
                            convention.value = @"time out";
                            break;
                        }
                        case CONVENTION_VISITS: {
                            convention.name = @"visits";
                            convention.value = @"visits";
                            break;
                        }
                        case CONVENTION_TEAMS: {
                            convention.name = @"teams";
                            convention.value = @"teams";
                            break;
                        }
                        case CONVENTION_INVOICE: {
                            convention.name = @"invoice";
                            convention.value = @"invoice";
                            break;
                        }
                        case CONVENTION_DELIVERIES: {
                            convention.name = @"deliveries";
                            convention.value = @"deliveries";
                            break;
                        }
                        case CONVENTION_RETURNS: {
                            convention.name = @"returns";
                            convention.value = @"returns";
                            break;
                        }
                        case CONVENTION_SALES: {
                            convention.name = @"sales";
                            convention.value = @"sales";
                            break;
                        }
                    }
                    if(convention.name != nil) {
                        NSString *value = data[x][convention.name];
                        if(value.length > 0 && ![value isEqualToString:@"keep"]) {
                            convention.value = value;
                        }
                    }
                }
            }
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)serverTime:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-server-time"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count && !isCanceled; x++) {
                TimeSecurity *timeSecurity = [Get timeSecurity:db];
                if(timeSecurity == nil) {
                    timeSecurity = [NSEntityDescription insertNewObjectForEntityForName:@"TimeSecurity" inManagedObjectContext:db];
                }
                NSDate *server = [Time getDateFromString:data[x][@"date_time"]];
                timeSecurity.serverDate = [Time getFormattedDate:DATE_FORMAT date:server];
                timeSecurity.serverTime = [Time getFormattedDate:TIME_FORMAT date:server];
                timeSecurity.upTime = [Time getUptime];
            }
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncBatchID:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-sync-batch-id"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count && !isCanceled; x++) {
                SyncBatch *syncBatch = [Get syncBatch:db];
                if(syncBatch == nil) {
                    syncBatch = [NSEntityDescription insertNewObjectForEntityForName:@"SyncBatch" inManagedObjectContext:db];
                }
                syncBatch.syncBatchID = [data[x][@"sync_batch_id"] stringValue];
                NSDate *currentDate = NSDate.date;
                syncBatch.date = [Time getFormattedDate:DATE_FORMAT date:currentDate];
                syncBatch.time = [Time getFormattedDate:TIME_FORMAT date:currentDate];
            }
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)announcements:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    int64_t userID = [Get userID:db];
    params[@"team_id"] = [NSString stringWithFormat:@"%lld", [Get employee:db employeeID:userID].teamID];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-announcements-for-app"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            [Update announcementsDeactivate:db];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t announcementID = [data[x][@"announcement_id"] longLongValue];
                Announcements *announcement = [Get announcement:db announcementID:announcementID];
                if(announcement == nil) {
                    announcement = [NSEntityDescription insertNewObjectForEntityForName:@"Announcements" inManagedObjectContext:db];
                    announcement.announcementID = announcementID;
                    announcement.isSeen = NO;
                    if([[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", data[x][@"date_to_show"], data[x][@"time_to_show"]]] earlierDate:NSDate.date]) {
                        announcement.isSeen = YES;
                    }
                }
                else {
                    if(![announcement.subject isEqualToString:data[x][@"title"]] || ![announcement.message isEqualToString:data[x][@"body"]] || ![announcement.scheduledDate isEqualToString:data[x][@"date_to_show"]] || ![announcement.scheduledTime isEqualToString:data[x][@"time_to_show"]]) {
                        announcement.isSeen = NO;
                    }
                }
                announcement.subject = data[x][@"title"];
                announcement.message = data[x][@"body"];
                announcement.createdDate = data[x][@"date_created"];
                announcement.createdTime = data[x][@"time_created"];
                announcement.scheduledDate = data[x][@"date_to_show"];
                announcement.scheduledTime = data[x][@"time_to_show"];
                announcement.employeeID = userID;
                announcement.createdByID = [data[x][@"employee_id"] longLongValue];
                announcement.isActive = [data[x][@"is_active"] intValue] == 1;
            }
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)stores:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    int64_t userID = [Get userID:db];
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", userID];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-stores-for-app"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            [Update storesDeactivate:db];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t webStoreID = [data[x][@"store_id"] longLongValue];
                Stores *store = [Get store:db webStoreID:webStoreID];
                if(store == nil) {
                    store = [NSEntityDescription insertNewObjectForEntityForName:@"Stores" inManagedObjectContext:db];
                    store.storeID = [Get sequenceID:db entity:@"Stores" attribute:@"storeID"] + 1;
                    store.webStoreID = webStoreID;
                    store.employeeID = userID;
                    store.isFromWeb = YES;
                }
                store.name = data[x][@"store_name"];
                store.shortName = data[x][@"short_name"];
                store.contactNumber = data[x][@"contact_number"];
                store.email = data[x][@"email"];
                store.address = data[x][@"address"];
                store.class1ID = [data[x][@"store_class_1_id"] longLongValue];
                store.class2ID = [data[x][@"store_class_2_id"] longLongValue];
                store.class3ID = [data[x][@"store_class_3_id"] longLongValue];
                store.latitude = [data[x][@"latitude"] doubleValue];
                store.longitude = [data[x][@"longitude"] doubleValue];
                store.geoFenceRadius = [data[x][@"geo_fence_radius"] longLongValue];
                store.isTag = YES;
                store.isActive = [data[x][@"is_active"] isEqualToString:@"1"];
                store.isSync = YES;
                store.isUpdate = YES;
                store.isWebUpdate = YES;
            }
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)storeContacts:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-store-contact-person-for-app"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            [Update storeContactsDeactivate:db];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t webStoreContactID = [data[x][@"contact_id"] longLongValue];
                StoreContacts *storeContact = [Get storeContact:db webStoreContactID:webStoreContactID];
                if(storeContact == nil) {
                    storeContact = [NSEntityDescription insertNewObjectForEntityForName:@"StoreContacts" inManagedObjectContext:db];
                    storeContact.storeContactID = [Get sequenceID:db entity:@"StoreContacts" attribute:@"storeContactID"] + 1;
                    storeContact.webStoreContactID = webStoreContactID;
                    storeContact.employeeID = [Get userID:db];
                    storeContact.isFromWeb = YES;
                }
                storeContact.storeID = [data[x][@"store_id"] longLongValue];
                storeContact.name = data[x][@"name"];
                storeContact.designation = data[x][@"designation"];
                storeContact.email = data[x][@"email"];
                storeContact.birthdate = data[x][@"birthdate"];
                storeContact.mobileNumber = data[x][@"mobile"];
                storeContact.landlineNumber = data[x][@"telephone"];
                storeContact.remarks = data[x][@"remarks"];
                storeContact.isActive = YES;
                storeContact.isSync = YES;
                storeContact.isUpdate = YES;
                storeContact.isWebUpdate = YES;
            }
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)storeCustomFields:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
//    params[@"sync_date"] = @"";
//    params[@"limit"] = @"";
//    params[@"offset"] = @"";
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-custom-field-data"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)storeCustomFieldsPages:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
//    params[@"sync_date"] = @"";
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-custom-field-data-count"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)scheduleTimes:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-schedule-time"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            [Update scheduleTimesDeactivate:db];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t scheduleTimeID = [data[x][@"time_schedule_id"] longLongValue];
                ScheduleTimes *scheduleTime = [Get scheduleTime:db scheduleTimeID:scheduleTimeID];
                if(scheduleTime == nil) {
                    scheduleTime = [NSEntityDescription insertNewObjectForEntityForName:@"ScheduleTimes" inManagedObjectContext:db];
                    scheduleTime.scheduleTimeID = scheduleTimeID;
                }
                scheduleTime.timeIn = data[x][@"time_in"];
                scheduleTime.timeOut = data[x][@"time_out"];
                scheduleTime.isActive = [data[x][@"is_active"] isEqualToString:@"1"];
            }
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)schedules:(NSManagedObjectContext *)db isToday:(BOOL)isToday delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    int64_t userID = [Get userID:db];
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", userID];
    NSDate *currentDate = NSDate.date;
    params[@"start_date"] = [Time getFormattedDate:DATE_FORMAT date:currentDate];
    params[@"end_date"] = [Time getFormattedDate:DATE_FORMAT date:isToday ? currentDate : [currentDate dateByAddingTimeInterval:60 * 60 * 24 * 15]];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-schedule"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(!isToday) {
                [Update schedulesDeactivate:db];
            }
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t webScheduleID = [data[x][@"schedule_id"] longLongValue];
                NSString *scheduleDate = data[x][@"date"];
                Schedules *schedule = [Get schedule:db webScheduleID:webScheduleID scheduleDate:scheduleDate];
                if(schedule == nil) {
                    schedule = [NSEntityDescription insertNewObjectForEntityForName:@"Schedules" inManagedObjectContext:db];
                    schedule.scheduleID = [Get sequenceID:db entity:@"Schedules" attribute:@"scheduleID"] + 1;
                    NSDate *currentDate = NSDate.date;
                    schedule.date = [Time getFormattedDate:DATE_FORMAT date:currentDate];
                    schedule.time = [Time getFormattedDate:TIME_FORMAT date:currentDate];
                    schedule.employeeID = userID;
                    schedule.isFromWeb = YES;
                }
                if(!isToday) {
                    schedule.webScheduleID = webScheduleID;
                    schedule.scheduleDate = scheduleDate;
                    schedule.timeIn = data[x][@"time_in"];
                    schedule.timeOut = data[x][@"time_out"];
                    schedule.shiftTypeID = [data[x][@"shift_type_id"] longLongValue];
                    schedule.isDayOff = [data[x][@"is_day_off"] isEqualToString:@"1"];
                    schedule.isActive = YES;
                }
                schedule.isSync = YES;
            }
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)breakTypes:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-breaks"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            [Update breakTypesDeactivate:db];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t breakTypeID = [data[x][@"break_id"] longLongValue];
                BreakTypes *breakType = [Get breakType:db breakTypeID:breakTypeID];
                if(breakType == nil) {
                    breakType = [NSEntityDescription insertNewObjectForEntityForName:@"BreakTypes" inManagedObjectContext:db];
                    breakType.breakTypeID = breakTypeID;
                }
                breakType.name = data[x][@"break_name"];
                breakType.duration = [data[x][@"duration"] longLongValue];
                breakType.isActive = YES;
            }
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)overtimeReasons:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"api_key"] = [Get apiKey:db];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-overtime-reasons"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            [Update overtimeReasonsDeactivate:db];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t overtimeReasonID = [data[x][@"overtime_reason_id"] longLongValue];
                OvertimeReasons *overtimeReason = [Get overtimeReason:db overtimeReasonID:overtimeReasonID];
                if(overtimeReason == nil) {
                    overtimeReason = [NSEntityDescription insertNewObjectForEntityForName:@"OvertimeReasons" inManagedObjectContext:db];
                    overtimeReason.overtimeReasonID = overtimeReasonID;
                }
                overtimeReason.name = data[x][@"overtime_reason"];
                overtimeReason.isActive = YES;
            }
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)visits:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", [Get userID:db]];
    NSDate *currentDate = NSDate.date;
    params[@"start_date"] = [Time getFormattedDate:DATE_FORMAT date:[currentDate dateByAddingTimeInterval:60 * 60 * 24 * -15]];
    params[@"end_date"] = [Time getFormattedDate:DATE_FORMAT date:[currentDate dateByAddingTimeInterval:60 * 60 * 24 * 15]];
    params[@"get_deleted"] = @"yes";
    params[@"status"] = @"pending";
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-itinerary"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t webVisitID = [data[x][@"itinerary_id"] longLongValue];
                Visits *visit = [Get visit:db webVisitID:webVisitID];
                if(visit == nil) {
                    visit = [NSEntityDescription insertNewObjectForEntityForName:@"Visits" inManagedObjectContext:db];
                    visit.visitID = [Get sequenceID:db entity:@"Visits" attribute:@"visitID"] + 1;
                    visit.webVisitID = webVisitID;
                }

                int64_t employeeID = [data[x][@"employee_id"] longLongValue];
                Employees *employee = [Get employee:db employeeID:employeeID];
                if(employee == nil) {
                    employee = [NSEntityDescription insertNewObjectForEntityForName:@"Employees" inManagedObjectContext:db];
                    employee.employeeID = employeeID;
                }
                employee.firstName = data[x][@"employee_firstname"];
                employee.lastName = data[x][@"employee_lastname"];

                int64_t webStoreID = [data[x][@"store_id"] longLongValue];
                Stores *store = [Get store:db webStoreID:webStoreID];
                if(store == nil) {
                    store = [NSEntityDescription insertNewObjectForEntityForName:@"Stores" inManagedObjectContext:db];
                    store.storeID = [Get sequenceID:db entity:@"Stores" attribute:@"storeID"] + 1;
                    store.webStoreID = webStoreID;
                    store.isFromTask = YES;
                    store.isFromWeb = YES;
                }
                store.employeeID = employeeID;
                store.isTag = YES;
                store.isActive = YES;
                store.isSync = YES;
                store.isUpdate = YES;
                store.isWebUpdate = YES;
                store.name = data[x][@"store_name"];
                store.shortName = data[x][@"store_short_name"];
                store.address = data[x][@"store_address"];
                store.contactNumber = data[x][@"store_contact_number"];
                store.email = data[x][@"store_email"];
                store.latitude = [data[x][@"store_latitude"] doubleValue];
                store.longitude = [data[x][@"store_longitude"] doubleValue];
                store.geoFenceRadius = [data[x][@"store_radius"] longLongValue];

                visit.storeID = store.storeID;
                visit.name = [Get isSettingEnabled:db settingID:SETTING_STORE_DISPLAY_LONG_NAME teamID:employee.teamID] ? store.name : store.shortName;
                visit.employeeID = employeeID;
                visit.startDate = data[x][@"start_date"];
                visit.endDate = data[x][@"end_date"];
                visit.notes = data[x][@"notes"];
                visit.status = data[x][@"status"];
                visit.invoice = data[x][@"mapping_code"];
                visit.deliveries = data[x][@"delivery_fee"];
                visit.isDelete = [data[x][@"is_deleted"] isEqualToString:@"1"];
                visit.isCheckIn = ![data[x][@"date_in"] isEqualToString:@"0000-00-00"];
                visit.isCheckOut = ![data[x][@"date_out"] isEqualToString:@"0000-00-00"];
                
                for(NSDictionary *dictionary in data[x][@"inventory"]) {
                    int64_t inventoryID = [dictionary[@"inventory_id"] longLongValue];
                    VisitInventories *inventory = [Get visitInventory:db visitID:visit.visitID inventoryID:inventoryID];
                    if(inventory == nil) {
                        inventory = [NSEntityDescription insertNewObjectForEntityForName:@"VisitInventories" inManagedObjectContext:db];
                        inventory.visitInventoryID = [Get sequenceID:db entity:@"VisitInventories" attribute:@"visitInventoryID"] + 1;
                        inventory.visitID = visit.visitID;
                        inventory.inventoryID = inventoryID;
                        inventory.isFromWeb = YES;
                    }
                    inventory.name = dictionary[@"inventory_type_name"];
                    inventory.isActive = YES;
                }
                
                for(NSDictionary *dictionary in data[x][@"forms"]) {
                    int64_t formID = [dictionary[@"form_id"] longLongValue];
                    VisitForms *form = [Get visitForm:db visitID:visit.visitID formID:formID];
                    if(form == nil) {
                        form = [NSEntityDescription insertNewObjectForEntityForName:@"VisitForms" inManagedObjectContext:db];
                        form.visitFormID = [Get sequenceID:db entity:@"VisitForms" attribute:@"visitFormID"] + 1;
                        form.visitID = visit.visitID;
                        form.formID = formID;
                        form.isFromWeb = YES;
                    }
                    form.name = dictionary[@"form_name"];
                    form.isActive = YES;
                }
            }
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)expenseTypeCategories:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-expense-categories"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            [Update expenseTypeCategoriesDeactivate:db];
            if([Get expenseType:db expenseTypeID:1] == nil) {
                ExpenseTypes *expenseType = [NSEntityDescription insertNewObjectForEntityForName:@"ExpenseTypes" inManagedObjectContext:db];
                expenseType.expenseTypeID = 1;
                expenseType.name = @"Fuel Consumption";
                expenseType.isRequired = NO;
                expenseType.isActive = YES;
            }
            if([Get expenseType:db expenseTypeID:2] == nil) {
                ExpenseTypes *expenseType = [NSEntityDescription insertNewObjectForEntityForName:@"ExpenseTypes" inManagedObjectContext:db];
                expenseType.expenseTypeID = 2;
                expenseType.name = @"Fuel Purchase";
                expenseType.isRequired = NO;
                expenseType.isActive = YES;
            }
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t expenseTypeCategoryID = [data[x][@"expense_category_id"] longLongValue];
                ExpenseTypeCategories *expenseTypeCategory = [Get expenseTypeCategory:db expenseTypeCategoryID:expenseTypeCategoryID];
                if(expenseTypeCategory == nil) {
                    expenseTypeCategory = [NSEntityDescription insertNewObjectForEntityForName:@"ExpenseTypeCategories" inManagedObjectContext:db];
                    expenseTypeCategory.expenseTypeCategoryID = expenseTypeCategoryID;
                }
                expenseTypeCategory.name = data[x][@"expense_category_name"];
                expenseTypeCategory.isActive = YES;
                message = [self expenseTypes:db expenseTypeCategoryID:expenseTypeCategory.expenseTypeCategoryID delegate:delegate];
                if(message != nil) {
                    break;
                }
            }
            if(![Update save:db]) {
                if(message == nil) {
                    message = @"";
                }
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (NSString *)expenseTypes:(NSManagedObjectContext *)db expenseTypeCategoryID:(int64_t)expenseTypeCategoryID delegate:(id)delegate {
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"expense_category_id"] = [NSString stringWithFormat:@"%lld", expenseTypeCategoryID];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-expense-types"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            [Update expenseTypesDeactivate:db expenseTypeCategoryID:expenseTypeCategoryID];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t expenseTypeID = [data[x][@"expense_type_id"] longLongValue];
                ExpenseTypes *expenseType = [Get expenseType:db expenseTypeID:expenseTypeID];
                if(expenseType == nil) {
                    expenseType = [NSEntityDescription insertNewObjectForEntityForName:@"ExpenseTypes" inManagedObjectContext:db];
                    expenseType.expenseTypeID = expenseTypeID;
                    expenseType.expenseTypeCategoryID = expenseTypeCategoryID;
                }
                expenseType.name = data[x][@"expense_type_name"];
                expenseType.isRequired = [data[x][@"is_required"] isEqualToString:@"yes"];
                expenseType.isActive = YES;
            }
        }
    }
    if(isCanceled) {
        message = nil;
    }
    return message;
}

+ (BOOL)inventories:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)inventoryBrands:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)inventoryCategories:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)inventoryDiscounts:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)inventoryFacingItems:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)inventoryOrders:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)inventoryPlanoGramTypes:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)inventoryPlanoGramItems:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)inventoryPullOutReasons:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)inventoryReasons:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)inventoryStoreAssign:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)inventorySubBrands:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)inventoryUOMs:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)forms:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)formFields:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = response[@"data"];
        if(data != nil) {
            if(![Update save:db]) {
                message = @"";
            }
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (void)isCanceled:(BOOL)canceled {
    isCanceled = canceled;
}

@end
