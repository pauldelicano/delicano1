#import "Tx.h"
#import <SSZipArchive/SSZipArchive.h>
#import "App.h"
#import "Process.h"
#import "Get.h"
#import "Load.h"
#import "Update.h"
#import "Http.h"
#import "File.h"
#import "Time.h"

@implementation Tx

static BOOL isCanceled;

+ (BOOL)authorize:(NSManagedObjectContext *)db params:(NSDictionary *)params delegate:(id)delegate {
    BOOL result = NO;
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"authorization-request"] params:params timeout:HTTP_TIMEOUT_TX];
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
                NSString *deviceID = params[@"tablet_id"];
                Device *device = [Get device:db];
                if(device == nil) {
                    device = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:db];
                }
                device.deviceID = deviceID;
                device.authorizationCode = params[@"authorization_code"];
                device.apiKey = data[x][@"api_key"];
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

+ (BOOL)login:(NSManagedObjectContext *)db params:(NSDictionary *)param delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = [NSMutableDictionary.alloc initWithDictionary:param];
    params[@"api_key"] = [Get apiKey:db];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"login"] params:params timeout:HTTP_TIMEOUT_TX];
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
                int64_t userID = [data[x][@"employee_id"] longLongValue];
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
                employee.firstName = data[x][@"firstname"];
                employee.lastName = data[x][@"lastname"];
                employee.teamID = [data[x][@"team_id"] longLongValue];
                employee.employeeNumber = data[x][@"employee_number"];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)sendBackupData:(NSManagedObjectContext *)db delegate:(id)delegate {
    BOOL result = NO;
    Employees *employee = [Get employee:db employeeID:[Get userID:db]];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@_%@_%@.zip", [Get company:db].name, employee.lastName, employee.firstName, [Time getFormattedDate:[NSString stringWithFormat:@"%@_%@", DATE_FORMAT, TIME_FORMAT] date:NSDate.date], [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    fileName = [fileName stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    NSString *backup = [File documentPath:@"Backup"];
    if(![NSFileManager.defaultManager createDirectoryAtPath:backup withIntermediateDirectories:YES attributes:nil error:nil]) {
        [delegate onProcessResult:@""];
        return NO;
    }
    [File deleteFromDocument:@"Backup/tarkie.db"];
    if(![NSFileManager.defaultManager copyItemAtPath:[File documentPath:@"tarkie.db"] toPath:[File documentPath:@"Backup/tarkie.db"] error:nil]) {
        [delegate onProcessResult:@""];
        return NO;
    }
    if(![SSZipArchive createZipFileAtPath:[File documentPath:fileName] withContentsOfDirectory:backup]) {
        [delegate onProcessResult:@""];
        return NO;
    }
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"action"] = @"upload-backup";
    params[@"api_key"] = @"75TvNCip314ts6l1Q1N9i2F3BcRWr090y31W54G279UxaoQx5Z";
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", employee.employeeID];
    NSDictionary *response = [Http postFile:@"https://www.tarkie.com/API/2.3/backup.php" params:params file:fileName timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    [File deleteFromDocument:fileName];
    if(message == nil) {
        [File deleteFromDocument:@"Backup"];
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

+ (BOOL)patchData:(NSManagedObjectContext *)db patch:(Patches *)patch delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"patch_id"] = [NSString stringWithFormat:@"%lld", patch.patchID];
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", patch.employeeID];
    params[@"status"] = @"done";
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"edit-adminpanel-patch"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        patch.isSync = YES;
        if(![Update save:db]) {
            message = @"";
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

+ (BOOL)syncAlert:(NSManagedObjectContext *)db alert:(Alerts *)alert delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", alert.alertID];
    params[@"sync_batch_id"] = alert.syncBatchID;
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", alert.employeeID];
    params[@"date"] = alert.date;
    params[@"time"] = alert.time;
    params[@"alert_type_id"] = [NSString stringWithFormat:@"%lld", alert.alertTypeID];
    params[@"value"] = alert.value != nil ? alert.value : @"";
    TimeIn *timeIn = [Get timeIn:db timeInID:alert.timeInID];
    if(timeIn != nil) {
        params[@"local_record_id_in"] = [NSString stringWithFormat:@"%lld", timeIn.timeInID];
        params[@"sync_batch_id_in"] = timeIn.syncBatchID;
    }
    GPS *gps = [Get gps:db gpsID:alert.gpsID];
    if(gps != nil) {
        params[@"gps_date"] = gps.date != nil ? gps.date : @"0000-00-00";
        params[@"gps_time"] = gps.time != nil ? gps.time : @"00:00:00";
        params[@"latitude"] = [NSString stringWithFormat:@"%f", gps.latitude];
        params[@"longitude"] = [NSString stringWithFormat:@"%f", gps.longitude];
        params[@"is_valid"] = gps.isValid ? @"yes" : @"no";
    }
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"add-alert"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        alert.isSync = YES;
        if(![Update save:db]) {
            message = @"";
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

+ (BOOL)syncAnnouncementSeen:(NSManagedObjectContext *)db announcementSeen:(AnnouncementSeen *)announcementSeen delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"announcement_id"] = [NSString stringWithFormat:@"%lld", announcementSeen.announcementID];
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", [Get announcement:db announcementID:announcementSeen.announcementID].employeeID];
    params[@"date_seen"] = announcementSeen.date;
    params[@"time_seen"] = announcementSeen.time;
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"add-announcement-seen"] params:params timeout:HTTP_TIMEOUT_TX];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncStore:(NSManagedObjectContext *)db store:(Stores *)store delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", store.storeID];
    params[@"sync_batch_id"] = store.syncBatchID;
    params[@"store_name"] = store.name;
    params[@"short_name"] = store.shortName;
    params[@"contact_number"] = store.contactNumber;
    params[@"email"] = store.email;
    params[@"address"] = store.address;
    NSMutableArray *employeeIDs = NSMutableArray.alloc.init;
    if([store.shareWith isEqualToString:@"my-team"]) {
        int64_t teamID = [Get employee:db employeeID:store.employeeID].teamID;
        for(Employees *employee in [Load employeeIDs:db teamID:teamID]) {
            [employeeIDs addObject:[NSString stringWithFormat:@"%lld", employee.employeeID]];
        }
        params[@"team"] = [NSArray.alloc initWithObjects:[NSString stringWithFormat:@"%lld", teamID], nil];
    }
    else {
        [employeeIDs addObject:[NSString stringWithFormat:@"%lld", store.employeeID]];
    }
    params[@"employee"] = employeeIDs;
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"add-store"] params:params timeout:HTTP_TIMEOUT_TX];
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
                store.webStoreID = [data[x][@"store_id"] longLongValue];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)updateStore:(NSManagedObjectContext *)db store:(Stores *)store delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"store_id"] = [NSString stringWithFormat:@"%lld", store.webStoreID];
    params[@"store_name"] = store.name;
    params[@"short_name"] = store.shortName;
    params[@"contact_number"] = store.contactNumber;
    params[@"email"] = store.email;
    params[@"address"] = store.address;
    NSMutableArray *employeeIDs = NSMutableArray.alloc.init;
    if([store.shareWith isEqualToString:@"my-team"]) {
        int64_t teamID = [Get employee:db employeeID:store.employeeID].teamID;
        for(Employees *employee in [Load employeeIDs:db teamID:teamID]) {
            [employeeIDs addObject:[NSString stringWithFormat:@"%lld", employee.employeeID]];
        }
        params[@"team"] = [NSArray.alloc initWithObjects:[NSString stringWithFormat:@"%lld", teamID], nil];
    }
    else {
        [employeeIDs addObject:[NSString stringWithFormat:@"%lld", store.employeeID]];
    }
    params[@"employee"] = employeeIDs;
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"edit-store"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncStoreContact:(NSManagedObjectContext *)db storeContact:(StoreContacts *)storeContact delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", storeContact.storeContactID];
    params[@"store_id"] = [NSString stringWithFormat:@"%lld", [Get store:db storeID:storeContact.storeID].webStoreID];
    params[@"name"] = storeContact.name;
    params[@"designation"] = storeContact.designation;
    params[@"email"] = storeContact.email;
    params[@"mobile"] = storeContact.mobileNumber;
    params[@"telephone"] = storeContact.landlineNumber;
    params[@"birthdate"] = storeContact.birthdate;
    params[@"remarks"] = storeContact.remarks;
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"add-store-contact-person"] params:params timeout:HTTP_TIMEOUT_TX];
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
                storeContact.webStoreContactID = [data[x][@"contact_id"] longLongValue];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)updateStoreContact:(NSManagedObjectContext *)db storeContact:(StoreContacts *)storeContact delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"contact_id"] = [NSString stringWithFormat:@"%lld", storeContact.webStoreContactID];
    params[@"store_id"] = [NSString stringWithFormat:@"%lld", [Get store:db storeID:storeContact.storeID].webStoreID];
    params[@"name"] = storeContact.name;
    params[@"designation"] = storeContact.designation;
    params[@"email"] = storeContact.email;
    params[@"mobile"] = storeContact.mobileNumber;
    params[@"telephone"] = storeContact.landlineNumber;
    params[@"birthdate"] = storeContact.birthdate;
    params[@"remarks"] = storeContact.remarks;
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"edit-store-contact-person"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncSchedule:(NSManagedObjectContext *)db schedule:(Schedules *)schedule delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", schedule.scheduleID];
    params[@"sync_batch_id"] = schedule.syncBatchID;
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", schedule.employeeID];
    params[@"date"] = schedule.scheduleDate;
    params[@"time_in"] = schedule.timeIn;
    params[@"time_out"] = schedule.timeOut;
    params[@"shift_type_id"] = [NSString stringWithFormat:@"%lld", schedule.shiftTypeID];
    params[@"from_app"] = [NSString stringWithFormat:@"%d", YES];
    params[@"is_day_off"] = [NSString stringWithFormat:@"%d", schedule.isDayOff];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"add-schedule"] params:params timeout:HTTP_TIMEOUT_TX];
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
                schedule.webScheduleID = [data[x][@"schedule_id"] longLongValue];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)updateSchedule:(NSManagedObjectContext *)db schedule:(Schedules *)schedule delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", schedule.scheduleID];
    params[@"sync_batch_id"] = schedule.syncBatchID;
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", schedule.employeeID];
    params[@"schedule_id"] = [NSString stringWithFormat:@"%lld", schedule.webScheduleID];
    params[@"date"] = schedule.scheduleDate;
    params[@"time_in"] = schedule.timeIn;
    params[@"time_out"] = schedule.timeOut;
    params[@"shift_type_id"] = [NSString stringWithFormat:@"%lld", schedule.shiftTypeID];
    params[@"from_app"] = [NSString stringWithFormat:@"%d", YES];
    params[@"is_day_off"] = [NSString stringWithFormat:@"%d", schedule.isDayOff];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"edit-schedule"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncTimeIn:(NSManagedObjectContext *)db timeIn:(TimeIn *)timeIn delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", timeIn.timeInID];
    params[@"sync_batch_id"] = timeIn.syncBatchID;
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", timeIn.employeeID];
    params[@"date_in"] = timeIn.date;
    params[@"time_in"] = timeIn.time;
    GPS *gps = [Get gps:db gpsID:timeIn.gpsID];
    if(gps != nil) {
        params[@"gps_date"] = gps.date != nil ? gps.date : @"0000-00-00";
        params[@"gps_time"] = gps.time != nil ? gps.time : @"00:00:00";
        params[@"latitude"] = [NSString stringWithFormat:@"%f", gps.latitude];
        params[@"longitude"] = [NSString stringWithFormat:@"%f", gps.longitude];
        params[@"is_valid"] = gps.isValid ? @"yes" : @"no";
    }
    params[@"store_id"] = [NSString stringWithFormat:@"%lld", [Get store:db storeID:timeIn.storeID].webStoreID];
    params[@"schedule_id"] = [NSString stringWithFormat:@"%lld", [Get schedule:db scheduleID:timeIn.scheduleID].webScheduleID];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"time-in"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)uploadTimeInPhoto:(NSManagedObjectContext *)db timeIn:(TimeIn *)timeIn delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", timeIn.timeInID];
    params[@"sync_batch_id"] = timeIn.syncBatchID;
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", timeIn.employeeID];
    NSDictionary *response = [Http postImage:[NSString stringWithFormat:@"%@%@", WEB_FILES, @"upload-time-in-photo"] params:params image:timeIn.photo timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncTimeOut:(NSManagedObjectContext *)db timeOut:(TimeOut *)timeOut delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", timeOut.timeOutID];
    params[@"sync_batch_id"] = timeOut.syncBatchID;
    params[@"date_out"] = timeOut.date;
    params[@"time_out"] = timeOut.time;
    TimeIn *timeIn = [Get timeIn:db timeInID:timeOut.timeInID];
    params[@"local_record_id_in"] = [NSString stringWithFormat:@"%lld", timeIn.timeInID];
    params[@"sync_batch_id_in"] = timeIn.syncBatchID;
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", timeIn.employeeID];
    GPS *gps = [Get gps:db gpsID:timeOut.gpsID];
    if(gps != nil) {
        params[@"gps_date"] = gps.date != nil ? gps.date : @"0000-00-00";
        params[@"gps_time"] = gps.time != nil ? gps.time : @"00:00:00";
        params[@"latitude"] = [NSString stringWithFormat:@"%f", gps.latitude];
        params[@"longitude"] = [NSString stringWithFormat:@"%f", gps.longitude];
        params[@"is_valid"] = gps.isValid ? @"yes" : @"no";
    }
    params[@"store_id"] = [NSString stringWithFormat:@"%lld", [Get store:db storeID:timeOut.storeID].webStoreID];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"time-out"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)uploadTimeOutPhoto:(NSManagedObjectContext *)db timeOut:(TimeOut *)timeOut delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", timeOut.timeOutID];
    params[@"sync_batch_id"] = timeOut.syncBatchID;
    TimeIn *timeIn = [Get timeIn:db timeInID:timeOut.timeInID];
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", timeIn.employeeID];
    NSDictionary *response = [Http postImage:[NSString stringWithFormat:@"%@%@", WEB_FILES, @"upload-time-out-photo"] params:params image:timeOut.photo timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)uploadTimeOutSignature:(NSManagedObjectContext *)db timeOut:(TimeOut *)timeOut delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", timeOut.timeOutID];
    params[@"sync_batch_id"] = timeOut.syncBatchID;
    TimeIn *timeIn = [Get timeIn:db timeInID:timeOut.timeInID];
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", timeIn.employeeID];
    NSDictionary *response = [Http postImage:[NSString stringWithFormat:@"%@%@", WEB_FILES, @"upload-signature-photo"] params:params image:timeOut.signature timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncBreakIn:(NSManagedObjectContext *)db breakIn:(BreakIn *)breakIn delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", breakIn.breakInID];
    params[@"sync_batch_id"] = breakIn.syncBatchID;
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", [Get timeIn:db timeInID:breakIn.timeInID].employeeID];
    params[@"date_in"] = breakIn.date;
    params[@"time_in"] = breakIn.time;
    GPS *gps = [Get gps:db gpsID:breakIn.gpsID];
    if(gps != nil) {
        params[@"gps_date"] = gps.date != nil ? gps.date : @"0000-00-00";
        params[@"gps_time"] = gps.time != nil ? gps.time : @"00:00:00";
        params[@"latitude"] = [NSString stringWithFormat:@"%f", gps.latitude];
        params[@"longitude"] = [NSString stringWithFormat:@"%f", gps.longitude];
        params[@"is_valid"] = gps.isValid ? @"yes" : @"no";
    }
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"break-in"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        breakIn.isSync = YES;
        if(![Update save:db]) {
            message = @"";
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

+ (BOOL)syncBreakOut:(NSManagedObjectContext *)db breakOut:(BreakOut *)breakOut delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", breakOut.breakOutID];
    params[@"sync_batch_id"] = breakOut.syncBatchID;
    params[@"date_out"] = breakOut.date;
    params[@"time_out"] = breakOut.time;
    BreakIn *breakIn = [Get breakIn:db breakInID:breakOut.breakInID];
    params[@"local_record_id_in"] = [NSString stringWithFormat:@"%lld", breakIn.breakInID];
    params[@"sync_batch_id_in"] = breakIn.syncBatchID;
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", [Get timeIn:db timeInID:breakIn.timeInID].employeeID];
    GPS *gps = [Get gps:db gpsID:breakOut.gpsID];
    if(gps != nil) {
        params[@"gps_date"] = gps.date != nil ? gps.date : @"0000-00-00";
        params[@"gps_time"] = gps.time != nil ? gps.time : @"00:00:00";
        params[@"latitude"] = [NSString stringWithFormat:@"%f", gps.latitude];
        params[@"longitude"] = [NSString stringWithFormat:@"%f", gps.longitude];
        params[@"is_valid"] = gps.isValid ? @"yes" : @"no";
    }
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"break-out"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        breakOut.isSync = YES;
        if(![Update save:db]) {
            message = @"";
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

+ (BOOL)syncOvertime:(NSManagedObjectContext *)db overtime:(Overtime *)overtime delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", overtime.overtimeID];
    params[@"sync_batch_id"] = overtime.syncBatchID;
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", overtime.employeeID];
    TimeIn *timeIn = [Get timeIn:db timeInID:overtime.timeInID];
    params[@"local_record_id_in"] = [NSString stringWithFormat:@"%lld", timeIn.timeInID];
    params[@"sync_batch_id_in"] = timeIn.syncBatchID;
    params[@"overtime_hours"] = [NSString stringWithFormat:@"%f", overtime.overtimeHours];
    params[@"reason_id"] = [overtime.overtimeReasonID componentsSeparatedByString:@","];
    params[@"remarks"] = overtime.remarks;
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"add-overtime"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        overtime.isSync = YES;
        if(![Update save:db]) {
            message = @"";
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

+ (BOOL)syncTracking:(NSManagedObjectContext *)db tracking:(Tracking *)tracking delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", tracking.trackingID];
    params[@"sync_batch_id"] = tracking.syncBatchID;
    params[@"time_in_local_record_id"] = [NSString stringWithFormat:@"%lld", tracking.timeInID];
    params[@"time_in_sync_batch_id"] = [Get timeIn:db timeInID:tracking.timeInID].syncBatchID;
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", tracking.employeeID];
    params[@"date"] = tracking.date;
    params[@"time"] = tracking.time;
    GPS *gps = [Get gps:db gpsID:tracking.gpsID];
    if(gps != nil) {
        params[@"gps_date"] = gps.date != nil ? gps.date : @"0000-00-00";
        params[@"gps_time"] = gps.time != nil ? gps.time : @"00:00:00";
        params[@"latitude"] = [NSString stringWithFormat:@"%f", gps.latitude];
        params[@"longitude"] = [NSString stringWithFormat:@"%f", gps.longitude];
        params[@"is_valid"] = gps.isValid ? @"yes" : @"no";
    }
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"add-gps-location"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        tracking.isSync = YES;
        if(![Update save:db]) {
            message = @"";
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

+ (BOOL)uploadVisitPhoto:(NSManagedObjectContext *)db photo:(Photos *)photo delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", photo.photoID];
    params[@"sync_batch_id"] = photo.syncBatchID;
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", photo.employeeID];
    params[@"team_id"] = [NSString stringWithFormat:@"%lld", [Get employee:db employeeID:photo.employeeID].teamID];
    params[@"date_created"] = photo.date;
    params[@"time_created"] = photo.time;
    params[@"is_signature"] = [NSString stringWithFormat:@"%d", photo.isSignature];
    NSDictionary *response = [Http postImage:[NSString stringWithFormat:@"%@%@", WEB_FILES, @"upload-form-photo"] params:params image:photo.filename timeout:HTTP_TIMEOUT_RX];
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
                photo.webPhotoID = [data[x][@"photo_id"] longLongValue];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncVisit:(NSManagedObjectContext *)db visit:(Visits *)visit delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", visit.visitID];
    params[@"sync_batch_id"] = visit.syncBatchID;
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", visit.employeeID];
    params[@"created_by"] = [NSString stringWithFormat:@"%lld", visit.employeeID];
    params[@"date_created"] = visit.createdDate;
    params[@"time_created"] = visit.createdTime;
    params[@"start_date"] = visit.startDate;
    params[@"end_date"] = visit.endDate;
    params[@"itinerary_id"] = [NSString stringWithFormat:@"%lld", visit.webVisitID];
    params[@"store_id"] = [NSString stringWithFormat:@"%lld", [Get store:db storeID:visit.storeID].webStoreID];
    params[@"notes"] = visit.notes;
    NSMutableArray *webPhotoIDs = NSMutableArray.alloc.init;
    for(Photos *visitPhoto in [Load visitPhotos:db visitID:visit.visitID]) {
        [webPhotoIDs addObject:[NSString stringWithFormat:@"%lld", visitPhoto.webPhotoID]];
    }
    params[@"photos"] = webPhotoIDs;
//    paramsObj.put("forms", formArray);
//    paramsObj.put("entries", entryArray);
//    paramsObj.put("inventory", inventoryArray);
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"add-itinerary-visit"] params:params timeout:HTTP_TIMEOUT_TX];
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
                visit.webVisitID = [data[x][@"itinerary_id"] longLongValue];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)updateVisit:(NSManagedObjectContext *)db visit:(Visits *)visit delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", visit.employeeID];
    params[@"start_date"] = visit.startDate;
    params[@"end_date"] = visit.endDate;
    params[@"itinerary_id"] = [NSString stringWithFormat:@"%lld", visit.webVisitID];
    params[@"store_id"] = [NSString stringWithFormat:@"%lld", [Get store:db storeID:visit.storeID].webStoreID];
    params[@"notes"] = visit.notes;
    NSMutableArray *webPhotoIDs = NSMutableArray.alloc.init;
    for(Photos *visitPhoto in [Load visitPhotos:db visitID:visit.visitID]) {
        [webPhotoIDs addObject:[NSString stringWithFormat:@"%lld", visitPhoto.webPhotoID]];
    }
    params[@"photos"] = webPhotoIDs;
//    paramsObj.put("forms", formArray);
//    paramsObj.put("entries", entryArray);
//    paramsObj.put("inventory", inventoryArray);
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"edit-itinerary-visit"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)deleteVisit:(NSManagedObjectContext *)db visit:(Visits *)visit delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"itinerary_id"] = [NSArray.alloc initWithObjects:[NSString stringWithFormat:@"%lld", visit.webVisitID], nil];
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"delete-itinerary-visit"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncCheckIn:(NSManagedObjectContext *)db checkIn:(CheckIn *)checkIn delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", checkIn.checkInID];
    params[@"sync_batch_id"] = checkIn.syncBatchID;
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", [Get timeIn:db timeInID:checkIn.timeInID].employeeID];
    params[@"date_in"] = checkIn.date;
    params[@"time_in"] = checkIn.time;
    params[@"itinerary_id"] = [NSString stringWithFormat:@"%lld", [Get visit:db visitID:checkIn.visitID].webVisitID];
    GPS *gps = [Get gps:db gpsID:checkIn.gpsID];
    if(gps != nil) {
        params[@"gps_date"] = gps.date != nil ? gps.date : @"0000-00-00";
        params[@"gps_time"] = gps.time != nil ? gps.time : @"00:00:00";
        params[@"latitude"] = [NSString stringWithFormat:@"%f", gps.latitude];
        params[@"longitude"] = [NSString stringWithFormat:@"%f", gps.longitude];
        params[@"is_valid"] = gps.isValid ? @"yes" : @"no";
    }
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"check-in"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)uploadCheckInPhoto:(NSManagedObjectContext *)db checkIn:(CheckIn *)checkIn delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"itinerary_id"] = [NSString stringWithFormat:@"%lld", [Get visit:db visitID:checkIn.visitID].webVisitID];
    params[@"type"] = @"check-in";
    NSDictionary *response = [Http postImage:[NSString stringWithFormat:@"%@%@", WEB_FILES, @"upload-check-in-out-photo"] params:params image:checkIn.photo timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncCheckOut:(NSManagedObjectContext *)db checkOut:(CheckOut *)checkOut delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", checkOut.checkOutID];
    params[@"sync_batch_id"] = checkOut.syncBatchID;
    CheckIn *checkIn = [Get checkIn:db checkInID:checkOut.checkInID];
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", [Get timeIn:db timeInID:checkIn.timeInID].employeeID];
    params[@"date_out"] = checkOut.date;
    params[@"time_out"] = checkOut.time;
    Visits *visit = [Get visit:db visitID:checkIn.visitID];
    params[@"itinerary_id"] = [NSString stringWithFormat:@"%lld", visit.webVisitID];
    GPS *gps = [Get gps:db gpsID:checkOut.gpsID];
    if(gps != nil) {
        params[@"gps_date"] = gps.date != nil ? gps.date : @"0000-00-00";
        params[@"gps_time"] = gps.time != nil ? gps.time : @"00:00:00";
        params[@"latitude"] = [NSString stringWithFormat:@"%f", gps.latitude];
        params[@"longitude"] = [NSString stringWithFormat:@"%f", gps.longitude];
        params[@"is_valid"] = gps.isValid ? @"yes" : @"no";
    }
    params[@"status"] = visit.status;
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"check-out"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)uploadCheckOutPhoto:(NSManagedObjectContext *)db checkOut:(CheckOut *)checkOut delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"itinerary_id"] = [NSString stringWithFormat:@"%lld", [Get visit:db visitID:[Get checkIn:db checkInID:checkOut.checkInID].visitID].webVisitID];
    params[@"type"] = @"check-out";
    NSDictionary *response = [Http postImage:[NSString stringWithFormat:@"%@%@", WEB_FILES, @"upload-check-in-out-photo"] params:params image:checkOut.photo timeout:HTTP_TIMEOUT_RX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
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
    if(isCanceled) {
        message = nil;
        result = NO;
    }
    [delegate onProcessResult:message];
    return result;
}

+ (BOOL)syncExpenses:(NSManagedObjectContext *)db expense:(Expense *)expense delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", expense.expenseID];
    params[@"sync_batch_id"] = expense.syncBatchID;
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", expense.employeeID];
    params[@"date"] = expense.date;
    params[@"time"] = expense.time;
    GPS *gps = [Get gps:db gpsID:expense.gpsID];
    if(gps != nil) {
        params[@"gps_date"] = gps.date != nil ? gps.date : @"0000-00-00";
        params[@"gps_time"] = gps.time != nil ? gps.time : @"00:00:00";
        params[@"latitude"] = [NSString stringWithFormat:@"%f", gps.latitude];
        params[@"longitude"] = [NSString stringWithFormat:@"%f", gps.longitude];
        params[@"is_valid"] = gps.isValid ? @"yes" : @"no";
    }
    params[@"store_id"] = [NSString stringWithFormat:@"%lld", expense.storeID];
    params[@"expense_type_id"] = [NSString stringWithFormat:@"%lld", expense.expenseTypeID];
    params[@"amount"] = [NSString stringWithFormat:@"%.2f", expense.amount];
    params[@"reimbursable"] = expense.isReimbursable ? @"yes" : @"no";
    params[@"origin"] = expense.origin != nil ? expense.origin : @"";
    params[@"destination"] = expense.destination != nil ? expense.destination : @"";
    params[@"notes"] = expense.notes != nil ? expense.notes : @"";
    if(expense.expenseTypeID == 1) {
        ExpenseFuelConsumption *expenseFuelConsumption = [Get expenseFuelConsumption:db expenseID:expense.expenseID];
        params[@"mileage_rate"] = [NSString stringWithFormat:@"%.2f", expenseFuelConsumption.rate];
        params[@"is_kilometer"] = expenseFuelConsumption.isKilometer ? @"yes" : @"no";
        params[@"start_odometer"] = [NSString stringWithFormat:@"%lld", expenseFuelConsumption.start];
        params[@"end_odometer"] = [NSString stringWithFormat:@"%lld", expenseFuelConsumption.end];
        params[@"with_receipt"] = @"no";
    }
    else if(expense.expenseTypeID == 2) {
        ExpenseFuelPurchase *expenseFuelPurchase = [Get expenseFuelPurchase:db expenseID:expense.expenseID];
        params[@"number_of_liters"] = [NSString stringWithFormat:@"%.2f", expenseFuelPurchase.liters];
        params[@"price"] = [NSString stringWithFormat:@"%.2f", expenseFuelPurchase.price];
        params[@"odometer"] = [NSString stringWithFormat:@"%lld", expenseFuelPurchase.start];
        params[@"with_receipt"] = expenseFuelPurchase.withOR ? @"yes" : @"no";
        params[@"or_number"] = expenseFuelPurchase.orNumber != nil ? expenseFuelPurchase.orNumber : @"";
        params[@"establishment"] = expenseFuelPurchase.establishment != nil ? expenseFuelPurchase.establishment : @"";
    }
    else {
        ExpenseDefault *expenseDefault = [Get expenseDefault:db expenseID:expense.expenseID];
        params[@"with_receipt"] = expenseDefault.withOR ? @"yes" : @"no";
        params[@"or_number"] = expenseDefault.orNumber != nil ? expenseDefault.orNumber : @"";
        params[@"establishment"] = expenseDefault.establishment != nil ? expenseDefault.establishment : @"";
    }
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"add-expense"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        expense.isSync = YES;
        if(![Update save:db]) {
            message = @"";
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

+ (BOOL)updateExpenses:(NSManagedObjectContext *)db expense:(Expense *)expense delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", expense.expenseID];
    params[@"sync_batch_id"] = expense.syncBatchID;
    params[@"employee_id"] = [NSString stringWithFormat:@"%lld", expense.employeeID];
    params[@"date"] = expense.date;
    params[@"time"] = expense.time;
    GPS *gps = [Get gps:db gpsID:expense.gpsID];
    if(gps != nil) {
        params[@"gps_date"] = gps.date != nil ? gps.date : @"0000-00-00";
        params[@"gps_time"] = gps.time != nil ? gps.time : @"00:00:00";
        params[@"latitude"] = [NSString stringWithFormat:@"%f", gps.latitude];
        params[@"longitude"] = [NSString stringWithFormat:@"%f", gps.longitude];
        params[@"is_valid"] = gps.isValid ? @"yes" : @"no";
    }
    params[@"store_id"] = [NSString stringWithFormat:@"%lld", expense.storeID];
    params[@"expense_type_id"] = [NSString stringWithFormat:@"%lld", expense.expenseTypeID];
    params[@"amount"] = [NSString stringWithFormat:@"%.2f", expense.amount];
    params[@"reimbursable"] = expense.isReimbursable ? @"yes" : @"no";
    params[@"origin"] = expense.origin != nil ? expense.origin : @"";
    params[@"destination"] = expense.destination != nil ? expense.destination : @"";
    params[@"notes"] = expense.notes != nil ? expense.notes : @"";
    if(expense.expenseTypeID == 1) {
        ExpenseFuelConsumption *expenseFuelConsumption = [Get expenseFuelConsumption:db expenseID:expense.expenseID];
        params[@"mileage_rate"] = [NSString stringWithFormat:@"%.2f", expenseFuelConsumption.rate];
        params[@"is_kilometer"] = expenseFuelConsumption.isKilometer ? @"yes" : @"no";
        params[@"start_odometer"] = [NSString stringWithFormat:@"%lld", expenseFuelConsumption.start];
        params[@"end_odometer"] = [NSString stringWithFormat:@"%lld", expenseFuelConsumption.end];
        params[@"with_receipt"] = @"no";
    }
    else if(expense.expenseTypeID == 2) {
        ExpenseFuelPurchase *expenseFuelPurchase = [Get expenseFuelPurchase:db expenseID:expense.expenseID];
        params[@"number_of_liters"] = [NSString stringWithFormat:@"%.2f", expenseFuelPurchase.liters];
        params[@"price"] = [NSString stringWithFormat:@"%.2f", expenseFuelPurchase.price];
        params[@"odometer"] = [NSString stringWithFormat:@"%lld", expenseFuelPurchase.start];
        params[@"with_receipt"] = expenseFuelPurchase.withOR ? @"yes" : @"no";
        params[@"or_number"] = expenseFuelPurchase.orNumber != nil ? expenseFuelPurchase.orNumber : @"";
        params[@"establishment"] = expenseFuelPurchase.establishment != nil ? expenseFuelPurchase.establishment : @"";
    }
    else {
        ExpenseDefault *expenseDefault = [Get expenseDefault:db expenseID:expense.expenseID];
        params[@"with_receipt"] = expenseDefault.withOR ? @"yes" : @"no";
        params[@"or_number"] = expenseDefault.orNumber != nil ? expenseDefault.orNumber : @"";
        params[@"establishment"] = expenseDefault.establishment != nil ? expenseDefault.establishment : @"";
    }
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"edit-expense"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        expense.isWebUpdate = YES;
        if(![Update save:db]) {
            message = @"";
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

+ (BOOL)deleteExpenses:(NSManagedObjectContext *)db expense:(Expense *)expense delegate:(id)delegate {
    BOOL result = NO;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    params[@"api_key"] = [Get apiKey:db];
    params[@"local_record_id"] = [NSString stringWithFormat:@"%lld", expense.expenseID];
    params[@"sync_batch_id"] = expense.syncBatchID;
    GPS *gps = [Get gps:db gpsID:expense.gpsID];
    if(gps != nil) {
        params[@"gps_date"] = gps.date != nil ? gps.date : @"0000-00-00";
        params[@"gps_time"] = gps.time != nil ? gps.time : @"00:00:00";
        params[@"latitude"] = [NSString stringWithFormat:@"%f", gps.latitude];
        params[@"longitude"] = [NSString stringWithFormat:@"%f", gps.longitude];
        params[@"is_valid"] = gps.isValid ? @"yes" : @"no";
    }
    NSDictionary *response = [Http post:[NSString stringWithFormat:@"%@%@", WEB_API, @"delete-expense"] params:params timeout:HTTP_TIMEOUT_TX];
    NSDictionary *init = [response[@"init"] lastObject];
    NSString *status = init[@"status"];
    NSString *message = nil;
    if([status isEqualToString:@"error"]) {
        message = init[@"message"];
    }
    if(message == nil) {
        expense.isWebDelete = YES;
        if(![Update save:db]) {
            message = @"";
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
