#import "Tx.h"
#import "App.h"
#import "Process.h"
#import "Get.h"
#import "Load.h"
#import "Update.h"
#import "Http.h"
#import "Time.h"

@implementation Tx

+ (BOOL)authorize:(NSManagedObjectContext *)db params:(NSDictionary *)params delegate:(id)delegate {
    BOOL result = NO;
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"authorization-request"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count; x++) {
                NSString *deviceID = [params objectForKey:@"tablet_id"];
                Device *device = [Get device:db];
                if(device == nil) {
                    device = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:db];
                }
                device.deviceID = deviceID;
                device.authorizationCode = [params objectForKey:@"authorization_code"];
                device.apiKey = [data[x] objectForKey:@"api_key"];
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
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)login:(NSManagedObjectContext *)db params:(NSDictionary *)param delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = [NSMutableDictionary.alloc initWithDictionary:param];
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"login"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count; x++) {
                long userID = [[data[x] objectForKey:@"employee_id"] longLongValue];
                Users *user = [Get user:db];
                if(user == nil) {
                    user = [NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:db];
                }
                user.userID = userID;
                NSDate *currentDate = NSDate.date;
                user.date = [Time getFormattedDate:DATE_FORMAT date:currentDate];
                user.time = [Time getFormattedDate:TIME_FORMAT date:currentDate];
                user.isLogout = NO;
                Employees *employee = [Get employee:db employeeID:userID];
                if(employee == nil) {
                    employee = [NSEntityDescription insertNewObjectForEntityForName:@"Employees" inManagedObjectContext:db];
                    employee.employeeID = userID;
                }
                employee.firstName = [data[x] objectForKey:@"firstname"];
                employee.lastName = [data[x] objectForKey:@"lastname"];
                employee.teamID = [[data[x] objectForKey:@"team_id"] longLongValue];
                employee.employeeNumber = [data[x] objectForKey:@"employee_number"];
                employee.isActive = YES;
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
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncAnnouncementSeen:(NSManagedObjectContext *)db announcementSeen:(AnnouncementSeen *)announcementSeen delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", announcementSeen.announcementID] forKey:@"announcement_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", [Get announcement:db announcementID:announcementSeen.announcementID].employeeID] forKey:@"employee_id"];
    [params setObject:announcementSeen.date forKey:@"date_seen"];
    [params setObject:announcementSeen.time forKey:@"time_seen"];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"add-announcement-seen"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count; x++) {
                announcementSeen.isSync = YES;
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
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncStore:(NSManagedObjectContext *)db store:(Stores *)store delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", store.storeID] forKey:@"local_record_id"];
    [params setObject:store.syncBatchID forKey:@"sync_batch_id"];
    [params setObject:store.name forKey:@"store_name"];
    [params setObject:store.shortName forKey:@"short_name"];
    [params setObject:store.contactNumber forKey:@"contact_number"];
    [params setObject:store.email forKey:@"email"];
    [params setObject:store.address forKey:@"address"];
    NSMutableArray *employeeIDs = NSMutableArray.alloc.init;
    if([store.shareWith isEqualToString:@"my-team"]) {
        long teamID = [Get employee:db employeeID:store.employeeID].teamID;
        NSArray<Employees *> *employees = [Load employeeIDs:db teamID:teamID];
        for(int x = 0; x < employees.count; x++) {
            [employeeIDs addObject:[NSString stringWithFormat:@"%lld", employees[x].employeeID]];
        }
        [params setObject:[NSArray.alloc initWithObjects:[NSString stringWithFormat:@"%ld", teamID], nil] forKey:@"team"];
    }
    else {
        [employeeIDs addObject:[NSString stringWithFormat:@"%lld", store.employeeID]];
    }
    [params setObject:employeeIDs forKey:@"employee"];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"add-store"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count; x++) {
                store.webStoreID = [[data[x] objectForKey:@"store_id"] longLongValue];
                store.isSync = YES;
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
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)updateStore:(NSManagedObjectContext *)db store:(Stores *)store delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", store.webStoreID] forKey:@"store_id"];
    [params setObject:store.name forKey:@"store_name"];
    [params setObject:store.shortName forKey:@"short_name"];
    [params setObject:store.contactNumber forKey:@"contact_number"];
    [params setObject:store.email forKey:@"email"];
    [params setObject:store.address forKey:@"address"];
    NSMutableArray *employeeIDs = NSMutableArray.alloc.init;
    if([store.shareWith isEqualToString:@"my-team"]) {
        long teamID = [Get employee:db employeeID:store.employeeID].teamID;
        NSArray<Employees *> *employees = [Load employeeIDs:db teamID:teamID];
        for(int x = 0; x < employees.count; x++) {
            [employeeIDs addObject:[NSString stringWithFormat:@"%lld", employees[x].employeeID]];
        }
        [params setObject:[NSArray.alloc initWithObjects:[NSString stringWithFormat:@"%ld", teamID], nil] forKey:@"team"];
    }
    else {
        [employeeIDs addObject:[NSString stringWithFormat:@"%lld", store.employeeID]];
    }
    [params setObject:employeeIDs forKey:@"employee"];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"edit-store"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        store.isWebUpdate = YES;
        if(![Update save:db]) {
            message = @"";
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncStoreContact:(NSManagedObjectContext *)db storeContact:(StoreContacts *)storeContact delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", storeContact.storeContactID] forKey:@"local_record_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", [Get store:db storeID:storeContact.storeID].webStoreID] forKey:@"store_id"];
    [params setObject:storeContact.name forKey:@"name"];
    [params setObject:storeContact.designation forKey:@"designation"];
    [params setObject:storeContact.email forKey:@"email"];
    [params setObject:storeContact.mobileNumber forKey:@"mobile"];
    [params setObject:storeContact.landlineNumber forKey:@"telephone"];
    [params setObject:storeContact.birthdate forKey:@"birthdate"];
    [params setObject:storeContact.remarks forKey:@"remarks"];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"add-store-contact-person"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count; x++) {
                storeContact.webStoreContactID = [[data[x] objectForKey:@"contact_id"] longLongValue];
                storeContact.isSync = YES;
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
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)updateStoreContact:(NSManagedObjectContext *)db storeContact:(StoreContacts *)storeContact delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", storeContact.webStoreContactID] forKey:@"contact_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", [Get store:db storeID:storeContact.storeID].webStoreID] forKey:@"store_id"];
    [params setObject:storeContact.name forKey:@"name"];
    [params setObject:storeContact.designation forKey:@"designation"];
    [params setObject:storeContact.email forKey:@"email"];
    [params setObject:storeContact.mobileNumber forKey:@"mobile"];
    [params setObject:storeContact.landlineNumber forKey:@"telephone"];
    [params setObject:storeContact.birthdate forKey:@"birthdate"];
    [params setObject:storeContact.remarks forKey:@"remarks"];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"edit-store-contact-person"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        storeContact.isWebUpdate = YES;
        if(![Update save:db]) {
            message = @"";
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncSchedule:(NSManagedObjectContext *)db schedule:(Schedules *)schedule delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", schedule.scheduleID] forKey:@"local_record_id"];
    [params setObject:schedule.syncBatchID forKey:@"sync_batch_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", schedule.employeeID] forKey:@"employee_id"];
    [params setObject:schedule.scheduleDate forKey:@"date"];
    [params setObject:schedule.timeIn forKey:@"time_in"];
    [params setObject:schedule.timeOut forKey:@"time_out"];
    [params setObject:[NSString stringWithFormat:@"%lld", schedule.shiftTypeID] forKey:@"shift_type_id"];
    [params setObject:[NSString stringWithFormat:@"%d", YES] forKey:@"from_app"];
    [params setObject:[NSString stringWithFormat:@"%d", schedule.isDayOff] forKey:@"is_day_off"];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"add-schedule"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count; x++) {
                schedule.webScheduleID = [[data[x] objectForKey:@"schedule_id"] longLongValue];
                schedule.isFromWeb = YES;
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
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)updateSchedule:(NSManagedObjectContext *)db schedule:(Schedules *)schedule delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", schedule.scheduleID] forKey:@"local_record_id"];
    [params setObject:schedule.syncBatchID forKey:@"sync_batch_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", schedule.employeeID] forKey:@"employee_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", schedule.webScheduleID] forKey:@"schedule_id"];
    [params setObject:schedule.scheduleDate forKey:@"date"];
    [params setObject:schedule.timeIn forKey:@"time_in"];
    [params setObject:schedule.timeOut forKey:@"time_out"];
    [params setObject:[NSString stringWithFormat:@"%lld", schedule.shiftTypeID] forKey:@"shift_type_id"];
    [params setObject:[NSString stringWithFormat:@"%d", YES] forKey:@"from_app"];
    [params setObject:[NSString stringWithFormat:@"%d", schedule.isDayOff] forKey:@"is_day_off"];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"edit-schedule"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        schedule.isFromWeb = YES;
        schedule.isSync = YES;
        if(![Update save:db]) {
            message = @"";
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncTimeIn:(NSManagedObjectContext *)db timeIn:(TimeIn *)timeIn delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", timeIn.timeInID] forKey:@"local_record_id"];
    [params setObject:timeIn.syncBatchID forKey:@"sync_batch_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", timeIn.employeeID] forKey:@"employee_id"];
    [params setObject:timeIn.date forKey:@"date_in"];
    [params setObject:timeIn.time forKey:@"time_in"];
    GPS *gps = [Get gps:db gpsID:timeIn.gpsID];
    if(gps != nil && gps.date != nil && gps.time != nil) {
        [params setObject:gps.date forKey:@"gps_date"];
        [params setObject:gps.time forKey:@"gps_time"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.latitude] forKey:@"latitude"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.longitude] forKey:@"longitude"];
        [params setObject:[NSString stringWithFormat:@"%d", gps.isValid] forKey:@"is_valid"];
    }
    else {
        [params setObject:@"0000-00-00" forKey:@"gps_date"];
        [params setObject:@"00:00:00" forKey:@"gps_time"];
        [params setObject:@"0" forKey:@"latitude"];
        [params setObject:@"0" forKey:@"longitude"];
        [params setObject:@"0" forKey:@"is_valid"];
    }
    [params setObject:[NSString stringWithFormat:@"%lld", [Get store:db storeID:timeIn.storeID].webStoreID] forKey:@"store_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", [Get schedule:db scheduleID:timeIn.scheduleID].webScheduleID] forKey:@"schedule_id"];
    [params setObject:timeIn.batteryLevel forKey:@"batery_level"];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"time-in"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        timeIn.isSync = YES;
        if(![Update save:db]) {
            message = @"";
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)uploadTimeInPhoto:(NSManagedObjectContext *)db timeIn:(TimeIn *)timeIn delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", timeIn.timeInID] forKey:@"local_record_id"];
    [params setObject:timeIn.syncBatchID forKey:@"sync_batch_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", timeIn.employeeID] forKey:@"employee_id"];
    NSDictionary *response = [Http postFile:[NSString stringWithFormat:@"%@%@", WEB_FILES, @"upload-time-in-photo"] params:params file:timeIn.photo timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        timeIn.isPhotoUpload = YES;
        if(![Update save:db]) {
            message = @"";
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncTimeOut:(NSManagedObjectContext *)db timeOut:(TimeOut *)timeOut delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", timeOut.timeOutID] forKey:@"local_record_id"];
    [params setObject:timeOut.syncBatchID forKey:@"sync_batch_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", timeOut.timeInID] forKey:@"local_record_id_in"];
    [params setObject:[Get timeIn:db timeInID:timeOut.timeInID].syncBatchID forKey:@"sync_batch_id_in"];
    [params setObject:[NSString stringWithFormat:@"%lld", timeOut.employeeID] forKey:@"employee_id"];
    [params setObject:timeOut.date forKey:@"date_out"];
    [params setObject:timeOut.time forKey:@"time_out"];
    GPS *gps = [Get gps:db gpsID:timeOut.gpsID];
    if(gps != nil && gps.date != nil && gps.time != nil) {
        [params setObject:gps.date forKey:@"gps_date"];
        [params setObject:gps.time forKey:@"gps_time"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.latitude] forKey:@"latitude"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.longitude] forKey:@"longitude"];
        [params setObject:[NSString stringWithFormat:@"%d", gps.isValid] forKey:@"is_valid"];
    }
    else {
        [params setObject:@"0000-00-00" forKey:@"gps_date"];
        [params setObject:@"00:00:00" forKey:@"gps_time"];
        [params setObject:@"0" forKey:@"latitude"];
        [params setObject:@"0" forKey:@"longitude"];
        [params setObject:@"0" forKey:@"is_valid"];
    }
    [params setObject:[NSString stringWithFormat:@"%lld", [Get store:db storeID:timeOut.storeID].webStoreID] forKey:@"store_id"];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"time-out"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        timeOut.isSync = YES;
        if(![Update save:db]) {
            message = @"";
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)uploadTimeOutPhoto:(NSManagedObjectContext *)db timeOut:(TimeOut *)timeOut delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", timeOut.timeOutID] forKey:@"local_record_id"];
    [params setObject:timeOut.syncBatchID forKey:@"sync_batch_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", timeOut.employeeID] forKey:@"employee_id"];
    NSDictionary *response = [Http postFile:[NSString stringWithFormat:@"%@%@", WEB_FILES, @"upload-time-out-photo"] params:params file:timeOut.photo timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        timeOut.isPhotoUpload = YES;
        if(![Update save:db]) {
            message = @"";
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)uploadTimeOutSignature:(NSManagedObjectContext *)db timeOut:(TimeOut *)timeOut delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", timeOut.timeOutID] forKey:@"local_record_id"];
    [params setObject:timeOut.syncBatchID forKey:@"sync_batch_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", timeOut.employeeID] forKey:@"employee_id"];
    NSDictionary *response = [Http postFile:[NSString stringWithFormat:@"%@%@", WEB_FILES, @"upload-signature-photo"] params:params file:timeOut.photo timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        timeOut.isSignatureUpload = YES;
        if(![Update save:db]) {
            message = @"";
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)uploadVisitPhoto:(NSManagedObjectContext *)db photo:(Photos *)photo delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", photo.photoID] forKey:@"local_record_id"];
    [params setObject:photo.syncBatchID forKey:@"sync_batch_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", photo.employeeID] forKey:@"employee_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", [Get employee:db employeeID:photo.employeeID].teamID] forKey:@"team_id"];
    [params setObject:photo.date forKey:@"date_created"];
    [params setObject:photo.time forKey:@"time_created"];
    [params setObject:[NSString stringWithFormat:@"%d", photo.isSignature] forKey:@"is_signature"];
    NSDictionary *response = [Http postFile:[NSString stringWithFormat:@"%@%@", WEB_FILES, @"upload-form-photo"] params:params file:photo.filename timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count; x++) {
                photo.webPhotoID = [[data[x] objectForKey:@"photo_id"] longLongValue];
                photo.isUpload = YES;
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
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncVisit:(NSManagedObjectContext *)db visit:(Visits *)visit delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", visit.visitID] forKey:@"local_record_id"];
    [params setObject:visit.syncBatchID forKey:@"sync_batch_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", visit.employeeID] forKey:@"employee_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", visit.employeeID] forKey:@"created_by"];
    [params setObject:visit.createdDate forKey:@"date_created"];
    [params setObject:visit.createdTime forKey:@"time_created"];
    [params setObject:visit.startDate forKey:@"start_date"];
    [params setObject:visit.endDate forKey:@"end_date"];
    [params setObject:[NSString stringWithFormat:@"%lld", visit.webVisitID] forKey:@"itinerary_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", [Get store:db storeID:visit.storeID].webStoreID] forKey:@"store_id"];
    [params setObject:visit.notes forKey:@"notes"];
    NSArray<Photos *> *visitPhotos = [Load visitPhotos:db visitID:visit.visitID];
    NSMutableArray *webPhotoIDs = NSMutableArray.alloc.init;
    for(int x = 0; x < visitPhotos.count; x++) {
        [webPhotoIDs addObject:[NSString stringWithFormat:@"%lld", visitPhotos[x].webPhotoID]];
    }
    [params setObject:webPhotoIDs forKey:@"photos"];
//    paramsObj.put("forms", formArray);
//    paramsObj.put("entries", entryArray);
//    paramsObj.put("inventory", inventoryArray);
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"add-itinerary-visit"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        NSArray<NSDictionary *> *data = [response objectForKey:@"data"];
        if(data != nil) {
            for(int x = 0; x < data.count; x++) {
                visit.webVisitID = [[data[x] objectForKey:@"itinerary_id"] longLongValue];
                visit.isSync = YES;
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
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)updateVisit:(NSManagedObjectContext *)db visit:(Visits *)visit delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", visit.employeeID] forKey:@"employee_id"];
    [params setObject:visit.startDate forKey:@"start_date"];
    [params setObject:visit.endDate forKey:@"end_date"];
    [params setObject:[NSString stringWithFormat:@"%lld", visit.webVisitID] forKey:@"itinerary_id"];
    [params setObject:[NSString stringWithFormat:@"%lld", [Get store:db storeID:visit.storeID].webStoreID] forKey:@"store_id"];
    [params setObject:visit.notes forKey:@"notes"];
    NSArray<Photos *> *visitPhotos = [Load visitPhotos:db visitID:visit.visitID];
    NSMutableArray *webPhotoIDs = NSMutableArray.alloc.init;
    for(int x = 0; x < visitPhotos.count; x++) {
        [webPhotoIDs addObject:[NSString stringWithFormat:@"%lld", visitPhotos[x].webPhotoID]];
    }
    [params setObject:webPhotoIDs forKey:@"photos"];
//    paramsObj.put("forms", formArray);
//    paramsObj.put("entries", entryArray);
//    paramsObj.put("inventory", inventoryArray);
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"edit-itinerary-visit"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        visit.isWebUpdate = YES;
        if(![Update save:db]) {
            message = @"";
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)deleteVisit:(NSManagedObjectContext *)db visit:(Visits *)visit delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSArray.alloc initWithObjects:[NSString stringWithFormat:@"%lld", visit.webVisitID], nil] forKey:@"itinerary_id"];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"delete-itinerary-visit"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        visit.isWebDelete = YES;
        if(![Update save:db]) {
            message = @"";
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncCheckIn:(NSManagedObjectContext *)db checkIn:(CheckIn *)checkIn delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", checkIn.checkInID] forKey:@"local_record_id"];
    [params setObject:checkIn.syncBatchID forKey:@"sync_batch_id"];
    Visits *visit = [Get visit:db visitID:checkIn.visitID];
    [params setObject:[NSString stringWithFormat:@"%lld", visit.employeeID] forKey:@"employee_id"];
    [params setObject:checkIn.date forKey:@"date_in"];
    [params setObject:checkIn.time forKey:@"time_in"];
    [params setObject:[NSString stringWithFormat:@"%lld", visit.webVisitID] forKey:@"itinerary_id"];
    GPS *gps = [Get gps:db gpsID:checkIn.gpsID];
    if(gps != nil && gps.date != nil && gps.time != nil) {
        [params setObject:gps.date forKey:@"gps_date"];
        [params setObject:gps.time forKey:@"gps_time"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.latitude] forKey:@"latitude"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.longitude] forKey:@"longitude"];
        [params setObject:[NSString stringWithFormat:@"%d", gps.isValid] forKey:@"is_valid"];
    }
    else {
        [params setObject:@"0000-00-00" forKey:@"gps_date"];
        [params setObject:@"00:00:00" forKey:@"gps_time"];
        [params setObject:@"0" forKey:@"latitude"];
        [params setObject:@"0" forKey:@"longitude"];
        [params setObject:@"0" forKey:@"is_valid"];
    }
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"check-in"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        checkIn.isSync = YES;
        if(![Update save:db]) {
            message = @"";
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)uploadCheckInPhoto:(NSManagedObjectContext *)db checkIn:(CheckIn *)checkIn delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", [Get visit:db visitID:checkIn.visitID].webVisitID] forKey:@"itinerary_id"];
    [params setObject:@"check-in" forKey:@"type"];
    NSDictionary *response = [Http postFile:[NSString stringWithFormat:@"%@%@", WEB_FILES, @"upload-check-in-out-photo"] params:params file:checkIn.photo timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        checkIn.isPhotoUpload = YES;
        if(![Update save:db]) {
            message = @"";
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncCheckOut:(NSManagedObjectContext *)db checkOut:(CheckOut *)checkOut delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", checkOut.checkOutID] forKey:@"local_record_id"];
    [params setObject:checkOut.syncBatchID forKey:@"sync_batch_id"];
    Visits *visit = [Get visit:db visitID:[Get checkIn:db checkInID:checkOut.checkInID].visitID];
    [params setObject:[NSString stringWithFormat:@"%lld", visit.employeeID] forKey:@"employee_id"];
    [params setObject:checkOut.date forKey:@"date_out"];
    [params setObject:checkOut.time forKey:@"time_out"];
    [params setObject:[NSString stringWithFormat:@"%lld", visit.webVisitID] forKey:@"itinerary_id"];
    GPS *gps = [Get gps:db gpsID:checkOut.gpsID];
    if(gps != nil && gps.date != nil && gps.time != nil) {
        [params setObject:gps.date forKey:@"gps_date"];
        [params setObject:gps.time forKey:@"gps_time"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.latitude] forKey:@"latitude"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.longitude] forKey:@"longitude"];
        [params setObject:[NSString stringWithFormat:@"%d", gps.isValid] forKey:@"is_valid"];
    }
    else {
        [params setObject:@"0000-00-00" forKey:@"gps_date"];
        [params setObject:@"00:00:00" forKey:@"gps_time"];
        [params setObject:@"0" forKey:@"latitude"];
        [params setObject:@"0" forKey:@"longitude"];
        [params setObject:@"0" forKey:@"is_valid"];
    }
    [params setObject:visit.status forKey:@"status"];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"check-out"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        checkOut.isSync = YES;
        if(![Update save:db]) {
            message = @"";
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)uploadCheckOutPhoto:(NSManagedObjectContext *)db checkOut:(CheckOut *)checkOut delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%lld", [Get visit:db visitID:[Get checkIn:db checkInID:checkOut.checkInID].visitID].webVisitID] forKey:@"itinerary_id"];
    [params setObject:@"check-out" forKey:@"type"];
    NSDictionary *response = [Http postFile:[NSString stringWithFormat:@"%@%@", WEB_FILES, @"upload-check-in-out-photo"] params:params file:checkOut.photo timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [[response objectForKey:@"init"] lastObject];
    NSString *status = [init objectForKey:@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = [init objectForKey:@"message"];
    }
    if(message == nil) {
        checkOut.isPhotoUpload = YES;
        if(![Update save:db]) {
            message = @"";
        }
    }
    if(message == nil) {
        message = @"ok";
        result = YES;
    }
    [delegate onProcessResult:message];
    return result;
}

@end
