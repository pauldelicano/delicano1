#import "Get.h"
#import "App.h"
#import "Time.h"

@implementation Get

+ (Sequences *)sequence:(NSManagedObjectContext *)db {
    Sequences *sequence = [self execute:db entity:@"Sequences"];
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
    }
    return sequence;
}

+ (Device *)device:(NSManagedObjectContext *)db {
    return [self execute:db entity:@"Device"];
}

+ (NSString *)apiKey:(NSManagedObjectContext *)db {
    return [self device:db].apiKey;
}

+ (Company *)company:(NSManagedObjectContext *)db {
    return [self execute:db entity:@"Company"];
}

+ (Modules *)module:(NSManagedObjectContext *)db moduleID:(long)moduleID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"moduleID == %ld", moduleID]];
    return [self execute:db entity:@"Modules" predicates:predicates];
}

+ (BOOL)isModuleEnabled:(NSManagedObjectContext *)db moduleID:(long)moduleID {
    if(moduleID == 3 || moduleID == 4 || moduleID == 5) {
//        return NO;//paul
    }
    return [self module:db moduleID:moduleID].isEnabled;
}

+ (Users *)user:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isLogout == %@", @NO]];
    return [self execute:db entity:@"Users" predicates:predicates];
}

+ (long)userID:(NSManagedObjectContext *)db {
    return [self user:db].userID;
}

+ (Employees *)employee:(NSManagedObjectContext *)db employeeID:(long)employeeID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", employeeID]];
    return [self execute:db entity:@"Employees" predicates:predicates];
}

+ (long)teamID:(NSManagedObjectContext *)db employeeID:(long)employeeID {
    return [self employee:db employeeID:employeeID].teamID;
}

+ (Settings *)setting:(NSManagedObjectContext *)db settingID:(long)settingID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"settingID == %ld", settingID]];
    return [self execute:db entity:@"Settings" predicates:predicates];
}

+ (SettingsTeams *)settingTeam:(NSManagedObjectContext *)db settingID:(long)settingID teamID:(long)teamID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"settingID == %ld", settingID]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"teamID == %ld", teamID]];
    return [self execute:db entity:@"SettingsTeams" predicates:predicates];
}

+ (BOOL)isSettingEnabled:(NSManagedObjectContext *)db settingID:(long)settingID  teamID:(long)teamID {
    return [[self settingTeam:db settingID:settingID teamID:teamID].value isEqualToString:@"yes"];
}

+ (NSString *)settingCurrencySymbol:(NSManagedObjectContext *)db teamID:(long)teamID {
    NSString *currencySymbol;
    NSString *currencyCode = [self settingTeam:db settingID:SETTING_DISPLAY_CURRENCY teamID:teamID].value;
    if([currencyCode isEqualToString:@"AUD"] || [currencyCode isEqualToString:@"CAD"] || [currencyCode isEqualToString:@"HKD"] || [currencyCode isEqualToString:@"SGD"] || [currencyCode isEqualToString:@"USD"]) {
        currencySymbol = @"$";
    }
    if([currencyCode isEqualToString:@"EUR"]) {
        currencySymbol = @"€";
    }
    if([currencyCode isEqualToString:@"JPY"]) {
        currencySymbol = @"¥";
    }
    if([currencyCode isEqualToString:@"PHP"]) {
        currencySymbol = @"₱";
    }
    if([currencyCode isEqualToString:@"GBP"]) {
        currencySymbol = @"£";
    }
    if([currencyCode isEqualToString:@"TWD"]) {
        currencySymbol = @"NT$";
    }
    if([currencyCode isEqualToString:@"THB"]) {
        currencySymbol = @"฿";
    }
    if([currencyCode isEqualToString:@"TRY"]) {
        currencySymbol = @"₺";
    }
    return currencySymbol;
}

+ (NSString *)settingDateFormat:(NSManagedObjectContext *)db teamID:(long)teamID {
    NSString *format = DATE_FORMAT;
    NSString *setting = [self settingTeam:db settingID:SETTING_DISPLAY_DATE_FORMAT teamID:teamID].value;
    if([setting isEqualToString:@"1"]) {
        format = @"MMMM d, yyyy";
    }
    if([setting isEqualToString:@"2"]) {
        format = @"dd-MMM-yy";
    }
    if([setting isEqualToString:@"3"]) {
        format = @"yyyy-MM-dd";
    }
    if([setting isEqualToString:@"4"]) {
        format = @"MM/dd/yyyy";
    }
    if([setting isEqualToString:@"5"]) {
        format = @"MMM d, yyyy";
    }
    return format;
}

+ (NSString *)settingTimeFormat:(NSManagedObjectContext *)db teamID:(long)teamID {
    NSString *format = TIME_FORMAT;
    NSString *setting = [self settingTeam:db settingID:SETTING_DISPLAY_TIME_FORMAT teamID:teamID].value;
    if([setting isEqualToString:@"12"]) {
        format = @"hh:mm a";
    }
    if([setting isEqualToString:@"24"]) {
        format = @"HH:mm";
    }
    return format;
}

+ (Conventions *)convention:(NSManagedObjectContext *)db conventionID:(long)conventionID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"conventionID == %ld", conventionID]];
    return [self execute:db entity:@"Conventions" predicates:predicates];
}

+ (NSString *)conventionName:(NSManagedObjectContext *)db conventionID:(long)conventionID {
    return [self convention:db conventionID:conventionID].value.capitalizedString;
}

+ (AlertTypes *)alertType:(NSManagedObjectContext *)db alertTypeID:(long)alertTypeID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"alertTypeID == %ld", alertTypeID]];
    return [self execute:db entity:@"AlertTypes" predicates:predicates];
}

+ (TimeSecurity *)timeSecurity:(NSManagedObjectContext *)db {
    return [self execute:db entity:@"TimeSecurity"];
}

+ (SyncBatch *)syncBatch:(NSManagedObjectContext *)db {
    return [self execute:db entity:@"SyncBatch"];
}

+ (NSString *)syncBatchID:(NSManagedObjectContext *)db {
    return [self syncBatch:db].syncBatchID;
}

+ (Announcements *)announcement:(NSManagedObjectContext *)db announcementID:(long)announcementID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"announcementID == %ld", announcementID]];
    return [self execute:db entity:@"Announcements" predicates:predicates];
}

+ (AnnouncementSeen *)announcementSeen:(NSManagedObjectContext *)db announcementID:(long)announcementID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"announcementID == %ld", announcementID]];
    return [self execute:db entity:@"AnnouncementSeen" predicates:predicates];
}

+ (long)unSeenAnnouncementsCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    NSDate *currentDate = NSDate.date;
    [predicates addObject:[NSPredicate predicateWithFormat:@"scheduledDate < %@ OR (scheduledDate == %@ AND scheduledTime <= %@)", [Time getFormattedDate:DATE_FORMAT date:currentDate], [Time getFormattedDate:DATE_FORMAT date:currentDate], [Time getFormattedDate:TIME_FORMAT date:currentDate]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [self userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSeen == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    return [self count:db entity:@"Announcements" predicates:predicates];
}

+ (long)syncAnnouncementSeenCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self count:db entity:@"AnnouncementSeen" predicates:predicates];
}

+ (Stores *)store:(NSManagedObjectContext *)db webStoreID:(long)webStoreID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"webStoreID == %ld", webStoreID]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", [self userID:db]]];
    return [self execute:db entity:@"Stores" predicates:predicates];
}

+ (Stores *)store:(NSManagedObjectContext *)db storeID:(long)storeID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"storeID == %ld", storeID]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", [self userID:db]]];
    return [self execute:db entity:@"Stores" predicates:predicates];
}

+ (long)syncStoresCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@ OR (isSync == %@ AND isUpdate == %@ AND isWebUpdate == %@)", @NO, @YES, @YES, @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    return [self count:db entity:@"Stores" predicates:predicates];
}

+ (StoreContacts *)storeContact:(NSManagedObjectContext *)db webStoreContactID:(long)webStoreContactID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"webStoreContactID == %ld", webStoreContactID]];
    return [self execute:db entity:@"StoreContacts" predicates:predicates];
}

+ (StoreContacts *)storeContact:(NSManagedObjectContext *)db storeContactID:(long)storeContactID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"storeContactID == %ld", storeContactID]];
    return [self execute:db entity:@"StoreContacts" predicates:predicates];
}

+ (long)syncStoreContactsCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@ OR (designation.length > 0 AND email.length > 0 AND birthdate.length > 0 AND isSync == %@ AND isUpdate == %@ AND isWebUpdate == %@)", @NO, @YES, @YES, @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    return [self count:db entity:@"StoreContacts" predicates:predicates];
}

+ (ScheduleTimes *)scheduleTime:(NSManagedObjectContext *)db scheduleTimeID:(long)scheduleTimeID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"scheduleTimeID == %ld", scheduleTimeID]];
    return [self execute:db entity:@"ScheduleTimes" predicates:predicates];
}

+ (Schedules *)schedule:(NSManagedObjectContext *)db webScheduleID:(long)webScheduleID scheduleDate:(NSString *)scheduleDate {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"webScheduleID == %ld OR scheduleDate == %@", webScheduleID, scheduleDate]];
    return [self execute:db entity:@"Schedules" predicates:predicates];
}

+ (Schedules *)schedule:(NSManagedObjectContext *)db scheduleID:(long)scheduleID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"scheduleID == %ld", scheduleID]];
    return [self execute:db entity:@"Schedules" predicates:predicates];
}

+ (long)syncSchedulesCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", [self userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@ OR (isFromWeb == %@ AND isSync == %@)", @NO, @NO, @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    return [self count:db entity:@"Schedules" predicates:predicates];
}

+ (TimeIn *)timeIn:(NSManagedObjectContext *)db {
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"timeInID" ascending:NO]];
    return [self execute:db entity:@"TimeIn" predicates:nil sortDescriptors:sortDescriptors];
}

+ (TimeIn *)timeIn:(NSManagedObjectContext *)db timeInID:(long)timeInID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"timeInID == %ld", timeInID]];
    return [self execute:db entity:@"TimeIn" predicates:predicates];
}

+ (BOOL)isTimeIn:(NSManagedObjectContext *)db {
    TimeIn *timeIn = [self timeIn:db];
    if(timeIn == nil) {
        return NO;
    }
    return ![self isTimeOut:db timeInID:timeIn.timeInID];
}

+ (long)timeInCount:(NSManagedObjectContext *)db date:(NSString *)date {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"date == %@", date]];
    return [self count:db entity:@"TimeIn" predicates:predicates];
}

+ (long)syncTimeInCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self count:db entity:@"TimeIn" predicates:predicates];
}

+ (long)uploadTimeInPhotoCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isPhotoUpload == %@", @NO]];
    return [self count:db entity:@"TimeIn" predicates:predicates];
}

+ (TimeOut *)timeOut:(NSManagedObjectContext *)db timeInID:(long)timeInID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"timeInID == %ld", timeInID]];
    return [self execute:db entity:@"TimeOut" predicates:predicates];
}

+ (TimeOut *)timeOut:(NSManagedObjectContext *)db timeOutID:(long)timeOutID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"timeOutID == %ld", timeOutID]];
    return [self execute:db entity:@"TimeOut" predicates:predicates];
}

+ (BOOL)isTimeOut:(NSManagedObjectContext *)db timeInID:(long)timeInID {
    return [self timeOut:db timeInID:timeInID] != nil ? YES : NO;
}

+ (long)syncTimeOutCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self count:db entity:@"TimeOut" predicates:predicates];
}

+ (long)uploadTimeOutPhotoCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isPhotoUpload == %@", @NO]];
    return [self count:db entity:@"TimeOut" predicates:predicates];
}

+ (long)uploadTimeOutSignatureCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"signature.length > 0"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSignatureUpload == %@", @NO]];
    return [self count:db entity:@"TimeOut" predicates:predicates];
}

+ (BreakTypes *)breakType:(NSManagedObjectContext *)db breakTypeID:(long)breakTypeID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"breakTypeID == %ld", breakTypeID]];
    return [self execute:db entity:@"BreakTypes" predicates:predicates];
}

+ (OvertimeReasons *)overtimeReason:(NSManagedObjectContext *)db overtimeReasonID:(long)overtimeReasonID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"overtimeReasonID == %ld", overtimeReasonID]];
    return [self execute:db entity:@"OvertimeReasons" predicates:predicates];
}

+ (Photos *)photo:(NSManagedObjectContext *)db photoID:(long)photoID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"photoID == %ld", photoID]];
    return [self execute:db entity:@"Photos" predicates:predicates];
}

+ (long)uploadVisitPhotosCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isUpload == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @NO]];
    return [self count:db entity:@"Photos" predicates:predicates];
}

+ (Visits *)visit:(NSManagedObjectContext *)db visitID:(long)visitID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    return [self execute:db entity:@"Visits" predicates:predicates];
}

+ (Visits *)visit:(NSManagedObjectContext *)db webVisitID:(long)webVisitID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"webVisitID == %ld", webVisitID]];
    return [self execute:db entity:@"Visits" predicates:predicates];
}

+ (long)visitTodayCount:(NSManagedObjectContext *)db date:(NSString *)date {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"%@ BETWEEN {startDate, endDate}", date]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isFromWeb == %@", @NO]];
    return [self count:db entity:@"Visits" predicates:predicates];
}

+ (long)syncVisitsCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"(isSync == %@ AND isDelete == %@) OR (storeID.length > 0 AND isSync == %@ AND isUpdate == %@ AND isWebUpdate == %@ AND isDelete == %@) OR (isSync == %@ AND isDelete == %@ AND isWebDelete = %@)", @NO, @NO, @YES, @YES, @NO, @NO, @YES, @YES, @NO]];
    return [self count:db entity:@"Visits" predicates:predicates];
}

+ (VisitInventories *)visitInventory:(NSManagedObjectContext *)db visitID:(long)visitID inventoryID:(long)inventoryID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"inventoryID == %ld", inventoryID]];
    return [self execute:db entity:@"VisitInventories" predicates:predicates];
}

+ (VisitForms *)visitForm:(NSManagedObjectContext *)db visitID:(long)visitID formID:(long)formID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"formID == %ld", formID]];
    return [self execute:db entity:@"VisitForms" predicates:predicates];
}

+ (CheckIn *)checkIn:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isCheckIn == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isCheckOut == %@", @NO]];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"visitID" ascending:YES]];
    Visits *visit = [self execute:db entity:@"Visits" predicates:predicates sortDescriptors:sortDescriptors];
    return [self checkIn:db visitID:visit.visitID];
}

+ (CheckIn *)checkIn:(NSManagedObjectContext *)db visitID:(long)visitID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    return [self execute:db entity:@"CheckIn" predicates:predicates];
}

+ (CheckIn *)checkIn:(NSManagedObjectContext *)db checkInID:(long)checkInID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"checkInID == %ld", checkInID]];
    return [self execute:db entity:@"CheckIn" predicates:predicates];
}

+ (BOOL)isCheckIn:(NSManagedObjectContext *)db  {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isCheckIn == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isCheckOut == %@", @NO]];
    return [self count:db entity:@"Visits" predicates:predicates] > 0;
}

+ (long)syncCheckInCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self count:db entity:@"CheckIn" predicates:predicates];
}

+ (long)uploadCheckInPhotoCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isPhotoUpload == %@", @NO]];
    return [self count:db entity:@"CheckIn" predicates:predicates];
}

+ (CheckOut *)checkOut:(NSManagedObjectContext *)db checkInID:(long)checkInID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"checkInID == %ld", checkInID]];
    return [self execute:db entity:@"CheckOut" predicates:predicates];
}

+ (long)syncCheckOutCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self count:db entity:@"CheckOut" predicates:predicates];
}

+ (long)uploadCheckOutPhotoCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isPhotoUpload == %@", @NO]];
    return [self count:db entity:@"CheckOut" predicates:predicates];
}

+ (long)syncTotalCount:(NSManagedObjectContext *)db {
    return [self syncAnnouncementSeenCount:db] + [self syncStoresCount:db] + [self syncStoreContactsCount:db] + [self syncSchedulesCount:db] + [self syncTimeInCount:db] + [self uploadTimeInPhotoCount:db] + [self syncTimeOutCount:db] + [self uploadTimeOutPhotoCount:db] + [self uploadTimeOutSignatureCount:db] + [self syncVisitsCount:db] + [self uploadVisitPhotosCount:db] + [self syncCheckInCount:db] + [self uploadCheckInPhotoCount:db] + [self syncCheckOutCount:db] + [self uploadCheckOutPhotoCount:db];
}

+ (GPS *)gps:(NSManagedObjectContext *)db gpsID:(long)gpsID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"gpsID == %ld", gpsID]];
    return [self execute:db entity:@"GPS" predicates:predicates];
}

+ (id)execute:(NSManagedObjectContext *)db entity:(NSString *)entity {
    return [self execute:db entity:entity predicates:nil sortDescriptors:nil];
}

+ (id)execute:(NSManagedObjectContext *)db entity:(NSString *)entity predicates:(NSArray<NSPredicate *> *)predicates {
    return [self execute:db entity:entity predicates:predicates sortDescriptors:nil];
}

+ (id)execute:(NSManagedObjectContext *)db entity:(NSString *)entity predicates:(NSArray<NSPredicate *> *)predicates sortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:predicates];
    fetchRequest.sortDescriptors = sortDescriptors;
    NSError *error = nil;
    NSArray *data = [db executeFetchRequest:fetchRequest error:&error];
    if(error != nil) {
        NSLog(@"error: get execute - %@", error.localizedDescription);
    }
    return data.lastObject;
}

+ (NSUInteger)count:(NSManagedObjectContext *)db entity:(NSString *)entity predicates:(NSArray<NSPredicate *> *)predicates {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    fetchRequest.includesSubentities = NO;
    fetchRequest.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:predicates];
    NSError *error = nil;
    NSUInteger count = [db countForFetchRequest:fetchRequest error:&error];
    if(error != nil) {
        NSLog(@"error: get count - %@", error.localizedDescription);
    }
    return count;
}

@end
