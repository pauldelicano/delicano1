#import "Get.h"
#import "Update.h"
#import "Time.h"

@implementation Get

+ (Sequences *)sequence:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Sequences"];
    Sequences *sequence = [self fetch:db request:request].lastObject;
    if(sequence == nil) {
        sequence = [NSEntityDescription insertNewObjectForEntityForName:@"Sequences" inManagedObjectContext:db];
        sequence.stores = 0;
        sequence.storeContacts = 0;
        sequence.gps = 0;
        sequence.tracking = 0;
        sequence.schedules = 0;
        sequence.visits = 0;
        sequence.visitInventories = 0;
        sequence.visitForms = 0;
        sequence.visitPhotos = 0;
        sequence.timeIn = 0;
        sequence.timeOut = 0;
        sequence.checkIn = 0;
        sequence.checkOut = 0;
        sequence.photos = 0;
        if(![Update save:db]) {
            return nil;
        }
    }
    return sequence;
}

+ (Device *)device:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Device"];
    return [self fetch:db request:request].lastObject;
}

+ (NSString *)apiKey:(NSManagedObjectContext *)db {
    Device *device = [self device:db];
    return device != nil ? device.apiKey : nil;
}

+ (Company *)company:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Company"];
    return [self fetch:db request:request].lastObject;
}

+ (Modules *)module:(NSManagedObjectContext *)db moduleID:(long)moduleID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Modules"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"moduleID == %ld", moduleID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (BOOL)isModuleEnabled:(NSManagedObjectContext *)db moduleID:(long)moduleID {
    if(moduleID == 3 || moduleID == 4 || moduleID == 5) {
        return NO;//paul
    }
    return [self module:db moduleID:moduleID].isEnabled;
}

+ (Users *)user:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isLogout == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (long)userID:(NSManagedObjectContext *)db {
    Users *user = [self user:db];
    return user != nil ? user.userID : 0;
}

+ (Employees *)employee:(NSManagedObjectContext *)db employeeID:(long)employeeID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Employees"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", employeeID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (Settings *)setting:(NSManagedObjectContext *)db settingID:(long)settingID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Settings"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"settingID == %ld", settingID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (SettingsTeams *)settingTeam:(NSManagedObjectContext *)db settingID:(long)settingID teamID:(long)teamID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SettingsTeams"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"settingID == %ld", settingID]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"teamID == %ld", teamID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (BOOL)isSettingEnabled:(NSManagedObjectContext *)db settingID:(long)settingID teamID:(long)teamID {
    return [[self settingTeam:db settingID:settingID teamID:teamID].value isEqualToString:@"yes"];
}

+ (Conventions *)convention:(NSManagedObjectContext *)db conventionID:(long)conventionID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conventions"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"conventionID == %ld", conventionID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (NSString *)conventionName:(NSManagedObjectContext *)db conventionID:(long)conventionID {
    return [self convention:db conventionID:conventionID].value.capitalizedString;
}

+ (AlertTypes *)alertType:(NSManagedObjectContext *)db alertTypeID:(long)alertTypeID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AlertTypes"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"alertTypeID == %ld", alertTypeID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (TimeSecurity *)timeSecurity:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimeSecurity"];
    return [self fetch:db request:request].lastObject;
}

+ (SyncBatch *)syncBatch:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SyncBatch"];
    return [self fetch:db request:request].lastObject;
}

+ (NSString *)syncBatchID:(NSManagedObjectContext *)db {
    SyncBatch *syncBatch = [self syncBatch:db];
    return syncBatch != nil ? syncBatch.syncBatchID : nil;
}

+ (Announcements *)announcement:(NSManagedObjectContext *)db announcementID:(long)announcementID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Announcements"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"announcementID == %ld", announcementID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (AnnouncementSeen *)announcementSeen:(NSManagedObjectContext *)db announcementID:(long)announcementID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AnnouncementSeen"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"announcementID == %ld", announcementID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (long)unSeenAnnouncementsCount:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Announcements"];
    request.includesSubentities = NO;
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    NSDate *currentDate = NSDate.date;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"scheduledDate < %@ OR (scheduledDate == %@ AND scheduledTime <= %@)", [Time formatDate:DATE_FORMAT date:currentDate], [Time formatDate:DATE_FORMAT date:currentDate], [Time formatDate:TIME_FORMAT date:currentDate]]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSeen == %@", @NO]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].count;
}

+ (long)syncAnnouncementSeenCount:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AnnouncementSeen"];
    request.includesSubentities = NO;
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].count;
}

+ (Stores *)store:(NSManagedObjectContext *)db storeID:(long)storeID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Stores"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"storeID == %ld", storeID]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", [Get userID:db]]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (Stores *)store:(NSManagedObjectContext *)db webStoreID:(long)webStoreID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Stores"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"webStoreID == %ld", webStoreID]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", [Get userID:db]]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (long)syncStoresCount:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Stores"];
    request.includesSubentities = NO;
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@ OR (isSync == %@ AND isUpdate == %@ AND isWebUpdate == %@)", @NO, @YES, @YES, @NO]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].count;
}

+ (StoreContacts *)storeContact:(NSManagedObjectContext *)db storeContactID:(long)storeContactID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"StoreContacts"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"storeContactID == %ld", storeContactID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (StoreContacts *)storeContact:(NSManagedObjectContext *)db webStoreContactID:(long)webStoreContactID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"StoreContacts"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"webStoreContactID == %ld", webStoreContactID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (long)syncStoreContactsCount:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"StoreContacts"];
    request.includesSubentities = NO;
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@ OR (designation.length > 0 AND email.length > 0 AND birthdate.length > 0 AND isSync == %@ AND isUpdate == %@ AND isWebUpdate == %@)", @NO, @YES, @YES, @NO]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].count;
}

+ (ScheduleTimes *)scheduleTime:(NSManagedObjectContext *)db scheduleTimeID:(long)scheduleTimeID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ScheduleTimes"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"scheduleTimeID == %ld", scheduleTimeID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (Schedules *)schedule:(NSManagedObjectContext *)db scheduleID:(long)scheduleID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Schedules"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"scheduleID == %ld", scheduleID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (Schedules *)schedule:(NSManagedObjectContext *)db webScheduleID:(long)webScheduleID scheduleDate:(NSString *)scheduleDate {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Schedules"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"webScheduleID == %ld OR scheduleDate == %@", webScheduleID, scheduleDate]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (long)syncSchedulesCount:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Schedules"];
    request.includesSubentities = NO;
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", [Get userID:db]]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@ OR (isFromWeb == %@ AND isSync == %@)", @NO, @NO, @YES]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].count;
}

+ (TimeIn *)timeIn:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimeIn"];
    return [self fetch:db request:request].lastObject;
}

+ (TimeIn *)timeIn:(NSManagedObjectContext *)db timeInID:(long)timeInID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimeIn"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"timeInID == %ld", timeInID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (BOOL)isTimeIn:(NSManagedObjectContext *)db {
    TimeIn *timeIn = [self timeIn:db];
    if(timeIn == nil) {
        return NO;
    }
    return ![self isTimeOut:db timeInID:timeIn.timeInID];
}

+ (long)syncTimeInCount:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimeIn"];
    request.includesSubentities = NO;
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].count;
}

+ (long)uploadTimeInPhotoCount:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimeIn"];
    request.includesSubentities = NO;
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0"]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isPhotoUpload == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].count;
}

+ (TimeOut *)timeOut:(NSManagedObjectContext *)db timeInID:(long)timeInID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimeOut"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"timeInID == %ld", timeInID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (TimeOut *)timeOut:(NSManagedObjectContext *)db timeOutID:(long)timeOutID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimeOut"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"timeOutID == %ld", timeOutID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (BOOL)isTimeOut:(NSManagedObjectContext *)db timeInID:(long)timeInID {
    return [self timeOut:db timeInID:timeInID] != nil ? YES : NO;
}

+ (long)syncTimeOutCount:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimeOut"];
    request.includesSubentities = NO;
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].count;
}

+ (long)uploadTimeOutPhotoCount:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimeOut"];
    request.includesSubentities = NO;
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0"]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isPhotoUpload == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].count;
}

+ (long)uploadTimeOutSignatureCount:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimeOut"];
    request.includesSubentities = NO;
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"signature.length > 0"]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSignatureUpload == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].count;
}

+ (BreakTypes *)breakType:(NSManagedObjectContext *)db breakTypeID:(long)breakTypeID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BreakTypes"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"breakTypeID == %ld", breakTypeID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (OvertimeReasons *)overtimeReason:(NSManagedObjectContext *)db overtimeReasonID:(long)overtimeReasonID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"OvertimeReasons"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"overtimeReasonID == %ld", overtimeReasonID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (Photos *)photo:(NSManagedObjectContext *)db photoID:(long)photoID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photos"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"photoID == %ld", photoID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (long)uploadVisitPhotosCount:(NSManagedObjectContext *)db {
    long count = 0;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VisitPhotos"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    NSArray<VisitPhotos *> *visitPhotos = [self fetch:db request:request];
    for(int x = 0 ; x < visitPhotos.count; x++) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photos"];
        request.includesSubentities = NO;
        NSMutableArray *subpredicates = NSMutableArray.alloc.init;
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"photoID == %ld", visitPhotos[x].photoID]];
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"isUpload == %@", @NO]];
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @NO]];
        request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
        count += [self fetch:db request:request].count;
    }
    return count;
}

+ (Visits *)visit:(NSManagedObjectContext *)db visitID:(long)visitID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Visits"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (Visits *)visit:(NSManagedObjectContext *)db webVisitID:(long)webVisitID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Visits"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"webVisitID == %ld", webVisitID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (long)syncVisitsCount:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Visits"];
    request.includesSubentities = NO;
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"(isSync == %@ AND isDelete == %@) OR (storeID.length > 0 AND isSync == %@ AND isUpdate == %@ AND isWebUpdate == %@ AND isDelete == %@) OR (isSync == %@ AND isDelete == %@ AND isWebDelete = %@)", @NO, @NO, @YES, @YES, @NO, @NO, @YES, @YES, @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].count;
}

+ (VisitInventories *)visitInventory:(NSManagedObjectContext *)db visitID:(long)visitID inventoryID:(long)inventoryID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VisitInventories"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"inventoryID == %ld", inventoryID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (VisitForms *)visitForm:(NSManagedObjectContext *)db visitID:(long)visitID formID:(long)formID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VisitForms"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"formID == %ld", formID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (CheckIn *)checkIn:(NSManagedObjectContext *)db timeInID:(long)timeInID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CheckIn"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"timeInID == %ld", timeInID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (CheckIn *)checkIn:(NSManagedObjectContext *)db visitID:(long)visitID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CheckIn"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (CheckIn *)checkIn:(NSManagedObjectContext *)db checkInID:(long)checkInID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CheckIn"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"checkInID == %ld", checkInID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (BOOL)isCheckIn:(NSManagedObjectContext *)db timeInID:(long)timeInID {
    CheckIn *checkIn = [self checkIn:db timeInID:timeInID];
    if(checkIn == nil) {
        return NO;
    }
    return ![self isCheckOut:db checkInID:checkIn.checkInID];
}

+ (long)syncCheckInCount:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CheckIn"];
    request.includesSubentities = NO;
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].count;
}

+ (long)uploadCheckInPhotoCount:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CheckIn"];
    request.includesSubentities = NO;
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0 AND isPhotoUpload == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].count;
}

+ (CheckOut *)checkOut:(NSManagedObjectContext *)db checkInID:(long)checkInID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CheckOut"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"checkInID == %ld", checkInID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (CheckOut *)checkOut:(NSManagedObjectContext *)db checkOutID:(long)checkOutID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CheckOut"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"checkOutID == %ld", checkOutID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (BOOL)isCheckOut:(NSManagedObjectContext *)db checkInID:(long)checkInID {
    return [self checkOut:db checkInID:checkInID] != nil ? YES : NO;
}

+ (long)syncCheckOutCount:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CheckOut"];
    request.includesSubentities = NO;
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].count;
}

+ (long)uploadCheckOutPhotoCount:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CheckOut"];
    request.includesSubentities = NO;
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0 AND isPhotoUpload == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].count;
}

+ (long)syncTotalCount:(NSManagedObjectContext *)db {
    return [self syncAnnouncementSeenCount:db] + [self syncStoresCount:db] + [self syncStoreContactsCount:db] + [self syncSchedulesCount:db] + [self syncTimeInCount:db] + [self uploadTimeInPhotoCount:db] + [self syncTimeOutCount:db] + [self uploadTimeOutPhotoCount:db] + [self uploadTimeOutSignatureCount:db] + [self syncVisitsCount:db] + [self uploadVisitPhotosCount:db] + [self syncCheckInCount:db] + [self uploadCheckInPhotoCount:db] + [self syncCheckOutCount:db] + [self uploadCheckOutPhotoCount:db];
}

+ (GPS *)gps:(NSManagedObjectContext *)db gpsID:(long)gpsID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GPS"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"gpsID == %ld", gpsID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request].lastObject;
}

+ (NSArray *)fetch:(NSManagedObjectContext *)db request:(NSFetchRequest *)request {
    NSError *error = nil;
    NSArray *data = [db executeFetchRequest:request error:&error];
    if(error != nil) {
        NSLog(@"error: get fetch - %@", error.localizedDescription);
    }
    return data;
}

@end
