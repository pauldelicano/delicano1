#import "Rx.h"
#import "App.h"
#import "Process.h"
#import "Get.h"
#import "Update.h"
#import "Http.h"
#import "File.h"
#import "Time.h"

@implementation Rx

static BOOL isCanceled;

+ (BOOL)company:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-company"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            Company *company = [Get company:db];
            if(company == nil) {
                company = [NSEntityDescription insertNewObjectForEntityForName:@"Company" inManagedObjectContext:db];
            }
            for(int x = 0; x < data.count && !isCanceled; x++) {
                company.companyID = [[data[x] objectForKey:@"company_id"] intValue];
                company.name = [data[x] objectForKey:@"company_name"];
                company.logoURL = [data[x] objectForKey:@"company_logo"];
                NSArray *modules = [data[x] objectForKey:@"modules"];
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
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-employee-details"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            [Update employeesDeactivate:db];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t employeeID = [[data[x] objectForKey:@"employee_id"] intValue];
                Employees *employee = [Get employee:db employeeID:employeeID];
                if(employee == nil) {
                    employee = [NSEntityDescription insertNewObjectForEntityForName:@"Employees" inManagedObjectContext:db];
                    employee.employeeID = employeeID;
                }
                employee.firstName = [data[x] objectForKey:@"firstname"];
                employee.lastName = [data[x] objectForKey:@"lastname"];
                employee.employeeNumber = [data[x] objectForKey:@"employee_number"];
                employee.photoURL = [data[x] objectForKey:@"picture_url"];
                employee.teamID = [[data[x] objectForKey:@"team_id"] intValue];
                employee.storeID = [[data[x] objectForKey:@"store_id"] intValue];
                employee.withLate = [[data[x] objectForKey:@"eligible_for_late"] intValue] == 1;
                employee.withOvertime = [[data[x] objectForKey:@"eligible_for_ot"] intValue] == 1;
                employee.isApprover = [[data[x] objectForKey:@"is_approver"] intValue] == 1;
                employee.isActive = [[data[x] objectForKey:@"is_active"] isEqualToString:@"yes"];
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
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-settings"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            NSNumber *teamID = [NSNumber numberWithUnsignedLongLong:[Get employee:db employeeID:[Get userID:db]].teamID];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                NSString *settingName = [data[x] objectForKey:@"settings_code"];
                int64_t settingID = [[data[x] objectForKey:@"settings_id"] intValue];
                settingID = [Get settingID:db settingName:settingName];
                Settings *setting = [Get setting:db settingID:settingID];
                if(setting == nil) {
                    setting = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:db];
                    setting.settingID = settingID;
                }
                setting.name = settingName;
                SettingsTeams *settingTeam = [Get settingTeam:db settingID:settingID teamID:teamID.intValue];
                if(settingTeam == nil) {
                    settingTeam = [NSEntityDescription insertNewObjectForEntityForName:@"SettingsTeams" inManagedObjectContext:db];
                    settingTeam.settingID = settingID;
                    settingTeam.teamID = teamID.intValue;
                }
                NSString *value = [data[x] objectForKey:@"settings_value"];
                if(![value isEqualToString:@"no"]) {
                    id team = [data[x] objectForKey:@"team_id"];
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
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-naming-convention"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
                        NSString *value = [data[x] objectForKey:convention.name];
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

+ (BOOL)alertTypes:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-alert-types"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t alertTypeID = [[data[x] objectForKey:@"alert_type_id"] intValue];
                AlertTypes *alertType = [Get alertType:db alertTypeID:alertTypeID];
                if(alertType == nil) {
                    alertType = [NSEntityDescription insertNewObjectForEntityForName:@"AlertTypes" inManagedObjectContext:db];
                    alertType.alertTypeID = alertTypeID;
                }
                alertType.name = [data[x] objectForKey:@"alert_type"];
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
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-server-time"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count && !isCanceled; x++) {
                TimeSecurity *timeSecurity = [Get timeSecurity:db];
                if(timeSecurity == nil) {
                    timeSecurity = [NSEntityDescription insertNewObjectForEntityForName:@"TimeSecurity" inManagedObjectContext:db];
                }
                NSDate *server = [Time getDateFromString:[data[x] objectForKey:@"date_time"]];
                timeSecurity.serverDate = [Time getFormattedDate:DATE_FORMAT date:server];
                timeSecurity.serverTime = [Time getFormattedDate:TIME_FORMAT date:server];
                timeSecurity.upTime = NSProcessInfo.processInfo.systemUptime;
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
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-sync-batch-id"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count && !isCanceled; x++) {
                SyncBatch *syncBatch = [Get syncBatch:db];
                if(syncBatch == nil) {
                    syncBatch = [NSEntityDescription insertNewObjectForEntityForName:@"SyncBatch" inManagedObjectContext:db];
                }
                syncBatch.syncBatchID = [[data[x] objectForKey:@"sync_batch_id"] stringValue];
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
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    int64_t userID = [Get userID:db];
    [params setObject:[NSString stringWithFormat:@"%lld", [Get employee:db employeeID:userID].teamID] forKey:@"team_id"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-announcements-for-app"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            [Update announcementsDeactivate:db];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t announcementID = [[data[x] objectForKey:@"announcement_id"] intValue];
                Announcements *announcement = [Get announcement:db announcementID:announcementID];
                if(announcement == nil) {
                    announcement = [NSEntityDescription insertNewObjectForEntityForName:@"Announcements" inManagedObjectContext:db];
                    announcement.announcementID = announcementID;
                    announcement.isSeen = NO;
                    if([[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", [data[x] objectForKey:@"date_to_show"], [data[x] objectForKey:@"time_to_show"]]] earlierDate:NSDate.date]) {
                        announcement.isSeen = YES;
                    }
                }
                else {
                    if(![announcement.subject isEqualToString:[data[x] objectForKey:@"title"]] || ![announcement.message isEqualToString:[data[x] objectForKey:@"body"]] || ![announcement.scheduledDate isEqualToString:[data[x] objectForKey:@"date_to_show"]] || ![announcement.scheduledTime isEqualToString:[data[x] objectForKey:@"time_to_show"]]) {
                        announcement.isSeen = NO;
                    }
                }
                announcement.subject = [data[x] objectForKey:@"title"];
                announcement.message = [data[x] objectForKey:@"body"];
                announcement.createdDate = [data[x] objectForKey:@"date_created"];
                announcement.createdTime = [data[x] objectForKey:@"time_created"];
                announcement.scheduledDate = [data[x] objectForKey:@"date_to_show"];
                announcement.scheduledTime = [data[x] objectForKey:@"time_to_show"];
                announcement.employeeID = userID;
                announcement.createdByID = [[data[x] objectForKey:@"employee_id"] intValue];
                announcement.isActive = [[data[x] objectForKey:@"is_active"] intValue] == 1;
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
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    int64_t userID = [Get userID:db];
    [params setObject:[NSString stringWithFormat:@"%lld", userID] forKey:@"employee_id"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-stores-for-app"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            [Update storesDeactivate:db];
            Sequences *sequence = [Get sequence:db];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t webStoreID = [[data[x] objectForKey:@"store_id"] intValue];
                Stores *store = [Get store:db webStoreID:webStoreID];
                if(store == nil) {
                    store = [NSEntityDescription insertNewObjectForEntityForName:@"Stores" inManagedObjectContext:db];
                    sequence.stores += 1;
                    store.storeID = sequence.stores;
                    store.webStoreID = webStoreID;
                    store.employeeID = userID;
                    store.isFromWeb = YES;
                }
                store.name = [data[x] objectForKey:@"store_name"];
                store.shortName = [data[x] objectForKey:@"short_name"];
                store.contactNumber = [data[x] objectForKey:@"contact_number"];
                store.email = [data[x] objectForKey:@"email"];
                store.address = [data[x] objectForKey:@"address"];
                store.class1ID = [[data[x] objectForKey:@"store_class_1_id"] intValue];
                store.class2ID = [[data[x] objectForKey:@"store_class_2_id"] intValue];
                store.class3ID = [[data[x] objectForKey:@"store_class_3_id"] intValue];
                store.latitude = [[data[x] objectForKey:@"latitude"] doubleValue];
                store.longitude = [[data[x] objectForKey:@"longitude"] doubleValue];
                store.geoFenceRadius = [[data[x] objectForKey:@"geo_fence_radius"] intValue];
                store.isTag = YES;
                store.isActive = [[data[x] objectForKey:@"is_active"] isEqualToString:@"1"];
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
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-store-contact-person-for-app"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            [Update storeContactsDeactivate:db];
            Sequences *sequence = [Get sequence:db];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t webStoreContactID = [[data[x] objectForKey:@"contact_id"] intValue];
                StoreContacts *storeContact = [Get storeContact:db webStoreContactID:webStoreContactID];
                if(storeContact == nil) {
                    storeContact = [NSEntityDescription insertNewObjectForEntityForName:@"StoreContacts" inManagedObjectContext:db];
                    sequence.storeContacts += 1;
                    storeContact.storeContactID = sequence.stores;
                    storeContact.webStoreContactID = webStoreContactID;
                    storeContact.employeeID = [Get userID:db];
                    storeContact.isFromWeb = YES;
                }
                storeContact.storeID = [[data[x] objectForKey:@"store_id"] intValue];
                storeContact.name = [data[x] objectForKey:@"name"];
                storeContact.designation = [data[x] objectForKey:@"designation"];
                storeContact.email = [data[x] objectForKey:@"email"];
                storeContact.birthdate = [data[x] objectForKey:@"birthdate"];
                storeContact.mobileNumber = [data[x] objectForKey:@"mobile"];
                storeContact.landlineNumber = [data[x] objectForKey:@"telephone"];
                storeContact.remarks = [data[x] objectForKey:@"remarks"];
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
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
//    [params setObject:@"" forKey:@"sync_date"];
//    [params setObject:@"" forKey:@"limit"];
//    [params setObject:@"" forKey:@"offset"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-custom-field-data"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
//    [params setObject:@"" forKey:@"sync_date"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-custom-field-data-count"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-schedule-time"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            [Update scheduleTimesDeactivate:db];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t scheduleTimeID = [[data[x] objectForKey:@"time_schedule_id"] intValue];
                ScheduleTimes *scheduleTime = [Get scheduleTime:db scheduleTimeID:scheduleTimeID];
                if(scheduleTime == nil) {
                    scheduleTime = [NSEntityDescription insertNewObjectForEntityForName:@"ScheduleTimes" inManagedObjectContext:db];
                    scheduleTime.scheduleTimeID = scheduleTimeID;
                }
                scheduleTime.timeIn = [data[x] objectForKey:@"time_in"];
                scheduleTime.timeOut = [data[x] objectForKey:@"time_out"];
                scheduleTime.isActive = [[data[x] objectForKey:@"is_active"] isEqualToString:@"1"];
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
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    int64_t userID = [Get userID:db];
    [params setObject:[NSString stringWithFormat:@"%lld", userID] forKey:@"employee_id"];
    NSDate *currentDate = NSDate.date;
    [params setObject:[Time getFormattedDate:DATE_FORMAT date:currentDate] forKey:@"start_date"];
    [params setObject:[Time getFormattedDate:DATE_FORMAT date:isToday ? currentDate : [currentDate dateByAddingTimeInterval:60 * 60 * 24 * 15]] forKey:@"end_date"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-schedule"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            if(!isToday) {
                [Update schedulesDeactivate:db];
            }
            Sequences *sequence = [Get sequence:db];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t webScheduleID = [[data[x] objectForKey:@"schedule_id"] intValue];
                NSString *scheduleDate = [data[x] objectForKey:@"date"];
                Schedules *schedule = [Get schedule:db webScheduleID:webScheduleID scheduleDate:scheduleDate];
                if(schedule == nil) {
                    schedule = [NSEntityDescription insertNewObjectForEntityForName:@"Schedules" inManagedObjectContext:db];
                    sequence.schedules += 1;
                    schedule.scheduleID = sequence.schedules;
                    NSDate *currentDate = NSDate.date;
                    schedule.date = [Time getFormattedDate:DATE_FORMAT date:currentDate];
                    schedule.time = [Time getFormattedDate:TIME_FORMAT date:currentDate];
                    schedule.employeeID = userID;
                    schedule.isFromWeb = YES;
                }
                if(!isToday) {
                    schedule.webScheduleID = webScheduleID;
                    schedule.scheduleDate = scheduleDate;
                    schedule.timeIn = [data[x] objectForKey:@"time_in"];
                    schedule.timeOut = [data[x] objectForKey:@"time_out"];
                    schedule.shiftTypeID = [[data[x] objectForKey:@"shift_type_id"] intValue];
                    schedule.isDayOff = [[data[x] objectForKey:@"is_day_off"] isEqualToString:@"1"];
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
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-breaks"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t breakTypeID = [[data[x] objectForKey:@"break_id"] intValue];
                BreakTypes *breakType = [Get breakType:db breakTypeID:breakTypeID];
                if(breakType == nil) {
                    breakType = [NSEntityDescription insertNewObjectForEntityForName:@"BreakTypes" inManagedObjectContext:db];
                    breakType.breakTypeID = breakTypeID;
                }
                breakType.name = [data[x] objectForKey:@"name"];
                breakType.duration = [[data[x] objectForKey:@"duration"] intValue];
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
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-overtime-reasons"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            [Update overtimeReasonsDeactivate:db];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t overtimeReasonID = [[data[x] objectForKey:@"overtime_reason_id"] intValue];
                OvertimeReasons *overtimeReason = [Get overtimeReason:db overtimeReasonID:overtimeReasonID];
                if(overtimeReason == nil) {
                    overtimeReason = [NSEntityDescription insertNewObjectForEntityForName:@"OvertimeReasons" inManagedObjectContext:db];
                    overtimeReason.overtimeReasonID = overtimeReasonID;
                }
                overtimeReason.name = [data[x] objectForKey:@"overtime_reason"];
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
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", [Get userID:db]] forKey:@"employee_id"];
    NSDate *currentDate = NSDate.date;
    [params setObject:[Time getFormattedDate:DATE_FORMAT date:[currentDate dateByAddingTimeInterval:60 * 60 * 24 * -15]] forKey:@"start_date"];
    [params setObject:[Time getFormattedDate:DATE_FORMAT date:[currentDate dateByAddingTimeInterval:60 * 60 * 24 * 15]] forKey:@"end_date"];
    [params setObject:@"yes" forKey:@"get_deleted"];
    [params setObject:@"pending" forKey:@"status"];
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @"get-itinerary"] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            Sequences *sequence = [Get sequence:db];
            for(int x = 0; x < data.count && !isCanceled; x++) {
                int64_t webVisitID = [[data[x] objectForKey:@"itinerary_id"] intValue];
                Visits *visit = [Get visit:db webVisitID:webVisitID];
                if(visit == nil) {
                    visit = [NSEntityDescription insertNewObjectForEntityForName:@"Visits" inManagedObjectContext:db];
                    sequence.visits += 1;
                    visit.visitID = sequence.visits;
                    visit.webVisitID = webVisitID;
                }

                int64_t employeeID = [[data[x] objectForKey:@"employee_id"] intValue];
                Employees *employee = [Get employee:db employeeID:employeeID];
                if(employee == nil) {
                    employee = [NSEntityDescription insertNewObjectForEntityForName:@"Employees" inManagedObjectContext:db];
                    employee.employeeID = employeeID;
                }
                employee.firstName = [data[x] objectForKey:@"employee_firstname"];
                employee.lastName = [data[x] objectForKey:@"employee_lastname"];

                int64_t webStoreID = [[data[x] objectForKey:@"store_id"] intValue];
                Stores *store = [Get store:db webStoreID:webStoreID];
                if(store == nil) {
                    store = [NSEntityDescription insertNewObjectForEntityForName:@"Stores" inManagedObjectContext:db];
                    sequence.stores += 1;
                    store.storeID = sequence.stores;
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
                store.name = [data[x] objectForKey:@"store_name"];
                store.shortName = [data[x] objectForKey:@"store_short_name"];
                store.address = [data[x] objectForKey:@"store_address"];
                store.contactNumber = [data[x] objectForKey:@"store_contact_number"];
                store.email = [data[x] objectForKey:@"store_email"];
                store.latitude = [[data[x] objectForKey:@"store_latitude"] doubleValue];
                store.longitude = [[data[x] objectForKey:@"store_longitude"] doubleValue];
                store.geoFenceRadius = [[data[x] objectForKey:@"store_radius"] intValue];

                visit.storeID = store.storeID;
                visit.name = [Get isSettingEnabled:db settingID:SETTING_STORE_DISPLAY_LONG_NAME teamID:employee.teamID] ? store.name : store.shortName;
                visit.employeeID = employeeID;
                visit.startDate = [data[x] objectForKey:@"start_date"];
                visit.endDate = [data[x] objectForKey:@"end_date"];
                visit.notes = [data[x] objectForKey:@"notes"];
                visit.status = [data[x] objectForKey:@"status"];
                visit.invoice = [data[x] objectForKey:@"mapping_code"];
                visit.deliveries = [data[x] objectForKey:@"delivery_fee"];
                visit.isDelete = [[data[x] objectForKey:@"is_deleted"] isEqualToString:@"1"];
                visit.isCheckIn = ![[data[x] objectForKey:@"date_in"] isEqualToString:@"0000-00-00"];
                visit.isCheckOut = ![[data[x] objectForKey:@"date_out"] isEqualToString:@"0000-00-00"];
                
                NSArray *inventories = [data[x] objectForKey:@"inventory"];
                for(int x = 0; x < inventories.count; x++) {
                    int64_t inventoryID = [[inventories[x] objectForKey:@"inventory_id"] intValue];
                    VisitInventories *inventory = [Get visitInventory:db visitID:visit.visitID inventoryID:inventoryID];
                    if(inventory == nil) {
                        inventory = [NSEntityDescription insertNewObjectForEntityForName:@"VisitInventories" inManagedObjectContext:db];
                        sequence.visitInventories += 1;
                        inventory.visitInventoryID = sequence.visitInventories;
                        inventory.visitID = visit.visitID;
                        inventory.inventoryID = inventoryID;
                        inventory.isFromWeb = YES;
                    }
                    inventory.name = [inventories[x] objectForKey:@"inventory_type_name"];
                    inventory.isActive = YES;
                }
                
                NSArray<NSDictionary *> *forms = [data[x] objectForKey:@"forms"];
                for(int x = 0; x < forms.count; x++) {
                    int64_t formID = [[forms[x] objectForKey:@"form_id"] intValue];
                    VisitForms *form = [Get visitForm:db visitID:visit.visitID formID:formID];
                    if(form == nil) {
                        form = [NSEntityDescription insertNewObjectForEntityForName:@"VisitForms" inManagedObjectContext:db];
                        sequence.visitForms += 1;
                        form.visitFormID = sequence.visitForms;
                        form.visitID = visit.visitID;
                        form.formID = formID;
                        form.isFromWeb = YES;
                    }
                    form.name = [forms[x] objectForKey:@"form_name"];
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
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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

+ (BOOL)expenseTypes:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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

+ (BOOL)inventories:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    NSDictionary *response = [Http get:[NSString stringWithFormat:@"%@%@", WEB_API, @""] params:params timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
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
