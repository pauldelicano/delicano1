#import "Load.h"
#import "App.h"
#import "Get.h"
#import "Time.h"

@implementation Load

+ (NSArray<NSDictionary *> *)drawerMenus:(NSManagedObjectContext *)db {
    NSMutableArray *menus = NSMutableArray.alloc.init;
    for(int x = 1; x <= MENU_LOGOUT; x++) {
        NSString *name;
        id icon;
        switch(x) {
            case MENU_TIME_IN_OUT: {
                name = @"Time In";
                icon = @"\uf185";
                break;
            }
            case MENU_BREAKS: {
                name = @"Breaks";
                icon = @"\uf0f4";
                break;
            }
            case MENU_STORES: {
                name = @"Stores";
                icon = @"\uf1ad";
                break;
            }
            case MENU_UPDATE_MASTER_FILE: {
                name = @"Update Master File";
                icon = @"\uf2f1";
                break;
            }
            case MENU_SEND_BACKUP_DATA: {
                name = @"Send Backup Data";
                icon = @"\uf093";
                break;
            }
            case MENU_BACKUP_DATA: {
//                name = @"Backup Data";
                icon = @"\uf019";
                break;
            }
            case MENU_PATCH_DATA: {
                name = @"Patch Data";
                icon = @"\uf019";
                break;
            }
            case MENU_ABOUT: {
                name = @"About";
                icon = @"\uf05a";
                break;
            }
            case MENU_LOGOUT: {
                name = @"Logout";
                icon = @"\uf011";
                break;
            }
        }
        if(name != nil) {
            NSMutableDictionary *menu = NSMutableDictionary.alloc.init;
            menu[@"ID"] = [NSString stringWithFormat:@"%d", x];
            icon = nil;
            if(icon == nil) {
                icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", @"Menu", [name stringByReplacingOccurrencesOfString:@" " withString:@""]]];
                if([name isEqualToString:@"Patch Data"]) {
                    icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", @"Menu", @"BackupData"]];
                }
            }
            if(icon != nil) {
                menu[@"icon"] = icon;
            }
            menu[@"name"] = name;
            [menus addObject:menu];
        }
    }
    return menus;
}

+ (NSArray<NSDictionary *> *)modulePages:(NSManagedObjectContext *)db {
    NSMutableArray *pages = NSMutableArray.alloc.init;
    for(int x = 1, isAttendance = NO; x <= MODULE_FORMS + 1; x++) {
        NSString *name;
        NSString *icon;
        if(x < MODULE_FORMS + 1) {
            if([Get isModuleEnabled:db moduleID:x]) {
                switch(x) {
                    case MODULE_ATTENDANCE: {
                        isAttendance = YES;
                        name = @"Home";
                        icon = @"\uf015";
                        break;
                    }
                    case MODULE_VISITS: {
                        name = @"Visits";
                        icon = @"\uf073";
                        break;
                    }
                    case MODULE_EXPENSE: {
                        name = @"Expense";
                        icon = @"\uf155";
                        break;
                    }
                    case MODULE_INVENTORY: {
                        name = @"Inventory";
                        icon = @"\uf494";
                        break;
                    }
                    case MODULE_FORMS: {
                        name = @"Forms";
                        icon = @"\uf07c";
                        break;
                    }
                }
            }
        }
        if(x == MODULE_FORMS + 1 && isAttendance) {
            name = @"History";
            icon = @"\uf252";
        }
        if(name != nil) {
            NSMutableDictionary *page = NSMutableDictionary.alloc.init;
            page[@"ID"] = [NSString stringWithFormat:@"%d", x];
            page[@"viewController"] = [NSString stringWithFormat:@"%@%@", @"vc", name];
            icon = nil;
            page[@"icon"] = icon != nil ? icon : [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", @"Page", name]];
            if([name isEqualToString:@"Visits"]) {
                name = [Get conventionName:db conventionID:CONVENTION_VISITS];
            }
            if([name isEqualToString:@"Forms"]) {
                name = @"Entries";
            }
            page[@"name"] = name;
            [pages addObject:page];
        }
    }
    return pages;
}

+ (NSArray<Employees *> *)employeeIDs:(NSManagedObjectContext *)db teamID:(int64_t)teamID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"teamID == %lld", teamID]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    return [self execute:db entity:@"Employees" predicates:predicates];
}

+ (NSArray<Patches *> *)patches:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isDone == %@", @NO]];
    return [self execute:db entity:@"Patches" predicates:predicates];
}

+ (NSArray<Patches *> *)syncPatches:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isDone == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self execute:db entity:@"Patches" predicates:predicates];
}

+ (NSArray<Alerts *> *)syncAlerts:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self execute:db entity:@"Alerts" predicates:predicates];
}

+ (NSArray<Announcements *> *)announcements:(NSManagedObjectContext *)db searchFilter:(NSString *)searchFilter isScheduled:(BOOL)isScheduled {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    if(searchFilter.length > 0) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"subject CONTAINS[cd] %@ OR message CONTAINS[cd] %@", searchFilter.lowercaseString, searchFilter.lowercaseString]];
    }
    NSDate *currentDate = NSDate.date;
    [predicates addObject:[NSPredicate predicateWithFormat:isScheduled? @"scheduledDate < %@ OR (scheduledDate == %@ AND scheduledTime <= %@)" : @"scheduledDate > %@ OR (scheduledDate == %@ AND scheduledTime > %@)", [Time getFormattedDate:DATE_FORMAT date:currentDate], [Time getFormattedDate:DATE_FORMAT date:currentDate], [Time getFormattedDate:TIME_FORMAT date:currentDate]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"scheduledDate" ascending:NO]];
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"scheduledTime" ascending:NO]];
    return [self execute:db entity:@"Announcements" predicates:predicates sortDescriptors:sortDescriptors];
}

+ (NSArray<AnnouncementSeen *> *)syncAnnouncementSeen:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self execute:db entity:@"AnnouncementSeen" predicates:predicates];
}

+ (NSArray<Stores *> *)stores:(NSManagedObjectContext *)db searchFilter:(NSString *)searchFilter {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    BOOL settingStoreDisplayLongName = [Get isSettingEnabled:db settingID:SETTING_STORE_DISPLAY_LONG_NAME teamID:[Get teamID:db employeeID:[Get userID:db]]];
    if(searchFilter.length > 0) {
        if(settingStoreDisplayLongName) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchFilter]];
        }
        else {
            [predicates addObject:[NSPredicate predicateWithFormat:@"shortName CONTAINS[cd] %@", searchFilter]];
        }
    }
    [predicates addObject:[NSPredicate predicateWithFormat:@"%@.length > 0", settingStoreDisplayLongName ? @"name" : @"shortName"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:settingStoreDisplayLongName ? @"name" : @"shortName" ascending:YES]];
    return [self execute:db entity:@"Stores" predicates:predicates sortDescriptors:sortDescriptors];
}

+ (NSArray<Stores *> *)syncStores:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    return [self execute:db entity:@"Stores" predicates:predicates];
}

+ (NSArray<Stores *> *)updateStores:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isUpdate == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isWebUpdate == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    return [self execute:db entity:@"Stores" predicates:predicates];
}

+ (NSArray<StoreContacts *> *)storeContacts:(NSManagedObjectContext *)db storeID:(int64_t)storeID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"storeID == %lld", storeID]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"name" ascending:YES]];
    return [self execute:db entity:@"StoreContacts" predicates:predicates sortDescriptors:sortDescriptors];
}

+ (NSArray<StoreContacts *> *)syncStoreContacts:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    return [self execute:db entity:@"StoreContacts" predicates:predicates];
}

+ (NSArray<StoreContacts *> *)updateStoreContacts:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"designation.length > 0"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"email.length > 0"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"birthdate.length > 0"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isUpdate == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isWebUpdate == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    return [self execute:db entity:@"StoreContacts" predicates:predicates];
}

+ (NSArray<ScheduleTimes *> *)scheduleTimes:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"timeIn" ascending:YES]];
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"timeOut" ascending:YES]];
    return [self execute:db entity:@"ScheduleTimes" predicates:predicates sortDescriptors:sortDescriptors];
}

+ (NSArray<Schedules *> *)syncSchedules:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self execute:db entity:@"Schedules" predicates:predicates];
}

+ (NSArray<Schedules *> *)updateSchedules:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", [Get userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isFromWeb == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    return [self execute:db entity:@"Schedules" predicates:predicates];
}

+ (NSArray<TimeIn *> *)timeIn:(NSManagedObjectContext *)db date:(NSString *)date {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"date <= %@", date]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"date" ascending:NO]];
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"time" ascending:NO]];
    return [self execute:db entity:@"TimeIn" predicates:predicates sortDescriptors:sortDescriptors];
}

+ (NSArray<TimeIn *> *)syncTimeIn:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self execute:db entity:@"TimeIn" predicates:predicates];
}

+ (NSArray<TimeIn *> *)uploadTimeInPhoto:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isPhotoUpload == %@", @NO]];
    return [self execute:db entity:@"TimeIn" predicates:predicates];
}

+ (NSArray<TimeOut *> *)syncTimeOut:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self execute:db entity:@"TimeOut" predicates:predicates];
}

+ (NSArray<TimeOut *> *)uploadTimeOutPhoto:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isPhotoUpload == %@", @NO]];
    return [self execute:db entity:@"TimeOut" predicates:predicates];
}

+ (NSArray<TimeOut *> *)uploadTimeOutSignature:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"signature.length > 0"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSignatureUpload == %@", @NO]];
    return [self execute:db entity:@"TimeOut" predicates:predicates];
}

+ (NSArray<BreakTypes *> *)breakTypes:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"name" ascending:YES]];
    return [self execute:db entity:@"BreakTypes" predicates:predicates sortDescriptors:sortDescriptors];
}

+ (NSArray<BreakIn *> *)breakIn:(NSManagedObjectContext *)db timeInID:(int64_t)timeInID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"timeInID == %ld", timeInID]];
    return [self execute:db entity:@"BreakIn" predicates:predicates];
}

+ (NSArray<BreakIn *> *)syncBreakIn:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self execute:db entity:@"BreakIn" predicates:predicates];
}

+ (NSArray<BreakOut *> *)syncBreakOut:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self execute:db entity:@"BreakOut" predicates:predicates];
}

+ (NSArray<OvertimeReasons *> *)overtimeReasons:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"name" ascending:YES]];
    return [self execute:db entity:@"OvertimeReasons" predicates:predicates sortDescriptors:sortDescriptors];
}

+ (NSArray<Overtime *> *)syncOvertime:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self execute:db entity:@"Overtime" predicates:predicates];
}

+ (NSArray<Tracking *> *)syncTracking:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self execute:db entity:@"Tracking" predicates:predicates];
}

+ (NSArray<NSDictionary *> *)activities:(NSManagedObjectContext *)db date:(NSString *)date {
    NSMutableArray *activities = NSMutableArray.alloc.init;
    int64_t employeeID = [Get userID:db];
    int64_t teamID = [Get teamID:db employeeID:employeeID];
    NSString *displayTimeFormat = [Get settingTimeFormat:db teamID:teamID];
    NSString *conventionTimeIn = [Get conventionName:db conventionID:CONVENTION_TIME_IN];
    NSString *conventionTimeOut = [Get conventionName:db conventionID:CONVENTION_TIME_OUT];
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"date == %@", date]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", employeeID]];
    for(TimeIn *timeIn in [self execute:db entity:@"TimeIn" predicates:predicates sortDescriptors:nil]) {
        NSMutableDictionary *activity = NSMutableDictionary.alloc.init;
        activity[@"Event"] = conventionTimeIn;
        activity[@"Time"] = [Time formatTime:displayTimeFormat time:timeIn.time];
        activity[@"Sort"] = [NSString stringWithFormat:@"%@ %@", timeIn.date, timeIn.time];
        [activities addObject:activity];
        TimeOut *timeOut = [Get timeOut:db timeInID:timeIn.timeInID];
        if(timeOut != nil) {
            NSMutableDictionary *activity = NSMutableDictionary.alloc.init;
            activity[@"Event"] = conventionTimeOut;
            activity[@"Time"] = [Time formatTime:displayTimeFormat time:timeOut.time];
            activity[@"Sort"] = [NSString stringWithFormat:@"%@ %@", timeOut.date, timeOut.time];
            [activities addObject:activity];
        }
        NSMutableArray *predicates = NSMutableArray.alloc.init;
        [predicates addObject:[NSPredicate predicateWithFormat:@"date == %@", date]];
        [predicates addObject:[NSPredicate predicateWithFormat:@"timeInID == %lld", timeIn.timeInID]];
        for(BreakIn *breakIn in [self execute:db entity:@"BreakIn" predicates:predicates sortDescriptors:nil]) {
            BreakTypes *breakType = [Get breakType:db breakTypeID:breakIn.breakTypeID];
            BreakOut *breakOut = [Get breakOut:db breakInID:breakIn.breakInID];
            NSMutableDictionary *activity = NSMutableDictionary.alloc.init;
            activity[@"Event"] = [NSString stringWithFormat:@"%@\n(%@)", breakType.name, [Time secondsToDHMS:[[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", breakOut.date, breakOut.time]] timeIntervalSinceDate:[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", breakIn.date, breakIn.time]]]]];
            activity[@"Time"] = [NSString stringWithFormat:@"%@ - %@", [Time formatTime:displayTimeFormat time:breakIn.time], [Time formatTime:displayTimeFormat time:breakOut.time]];
            activity[@"Sort"] = [NSString stringWithFormat:@"%@ %@", breakIn.date, breakIn.time];
            [activities addObject:activity];
        }
        for(CheckIn *checkIn in [self execute:db entity:@"CheckIn" predicates:predicates sortDescriptors:nil]) {
            Visits *visit = [Get visit:db visitID:checkIn.visitID];
            CheckOut *checkOut = [Get checkOut:db checkInID:checkIn.checkInID];
            NSMutableDictionary *activity = NSMutableDictionary.alloc.init;
            activity[@"Event"] = [NSString stringWithFormat:@"%@%@", visit.name, visit.isCheckOut ? [NSString stringWithFormat:@"\n(%@)", [Time secondsToDHMS:[[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", checkOut.date, checkOut.time]] timeIntervalSinceDate:[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", checkIn.date, checkIn.time]]]]] : @""];
            activity[@"Time"] = [NSString stringWithFormat:@"%@ - %@", [Time formatTime:displayTimeFormat time:checkIn.time], visit.isCheckOut ? [Time formatTime:displayTimeFormat time:checkOut.time] : @"NO OUT"];
            activity[@"Sort"] = [NSString stringWithFormat:@"%@ %@", checkIn.date, checkIn.time];
            [activities addObject:activity];
        }
    }
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"Sort" ascending:YES]];
    return [activities sortedArrayUsingDescriptors:sortDescriptors];
}

+ (NSArray<Photos *> *)visitPhotos:(NSManagedObjectContext *)db visitID:(int64_t)visitID {
    NSMutableArray<Photos *> *photos = NSMutableArray.alloc.init;
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    for(VisitPhotos *visitPhoto in [self execute:db entity:@"VisitPhotos" predicates:predicates]) {
        NSMutableArray *predicates = NSMutableArray.alloc.init;
        [predicates addObject:[NSPredicate predicateWithFormat:@"photoID == %ld", visitPhoto.photoID]];
        [predicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @NO]];
        [photos addObjectsFromArray:[self execute:db entity:@"Photos" predicates:predicates]];
    }
    return photos;
}

+ (NSArray<Photos *> *)uploadVisitPhotos:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isUpload == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @NO]];
    return [self execute:db entity:@"Photos" predicates:predicates];
}

+ (NSArray<Visits *> *)visits:(NSManagedObjectContext *)db date:(NSString *)date isNoCheckOutOnly:(BOOL)isNoCheckOutOnly {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    if(isNoCheckOutOnly) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"isCheckOut == %@", @NO]];
    }
    [predicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"%@ BETWEEN {startDate, endDate}", date]];
    return [self execute:db entity:@"Visits" predicates:predicates];
}

+ (NSArray<Visits *> *)syncVisits:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @NO]];
    return [self execute:db entity:@"Visits" predicates:predicates];
}

+ (NSArray<Visits *> *)updateVisits:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"storeID.length > 0"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isUpdate == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isWebUpdate == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @NO]];
    return [self execute:db entity:@"Visits" predicates:predicates];
}

+ (NSArray<Visits *> *)deleteVisits:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isWebDelete == %@", @NO]];
    return [self execute:db entity:@"Visits" predicates:predicates];
}

+ (NSArray<VisitInventories *> *)visitInventories:(NSManagedObjectContext *)db visitID:(int64_t)visitID {
    return nil;
//    NSMutableArray<VisitInventories *> *visitInventories = [NSMutableArray.alloc initWithArray:[self execute:db entity:@"VisitInventories"]];
//    if(visitInventories.count == 0) {
//        Sequences *sequence = [Get sequence:db];
//        for(int x = 1; x <= 5; x++) {
//            VisitInventories *visitInventory = [NSEntityDescription insertNewObjectForEntityForName:@"VisitInventories" inManagedObjectContext:db];
//            sequence.visitInventories += 1;
//            visitInventory.name = [NSString stringWithFormat:@"Visit Inventory %lld", sequence.visitInventories];
//            visitInventory.visitInventoryID = sequence.visitInventories;
//            visitInventory.visitID = visitID;
//            visitInventory.isActive = YES;
//            [visitInventories addObject:visitInventory];
//        }
//    }
//    NSMutableArray *predicates = NSMutableArray.alloc.init;
//    [predicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
//    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
//    return [self execute:db entity:@"VisitInventories" predicates:predicates];
}

+ (NSArray<VisitForms *> *)visitForms:(NSManagedObjectContext *)db visitID:(int64_t)visitID {
    return nil;
//    NSMutableArray<VisitForms *> *visitForms = [NSMutableArray.alloc initWithArray:[self execute:db entity:@"VisitForms"]];
//    if(visitForms.count == 0) {
//        Sequences *sequence = [Get sequence:db];
//        for(int x = 1; x <= 5; x++) {
//            VisitForms *visitForm = [NSEntityDescription insertNewObjectForEntityForName:@"VisitForms" inManagedObjectContext:db];
//            sequence.visitForms += 1;
//            visitForm.name = [NSString stringWithFormat:@"Visit Form %lld", sequence.visitForms];
//            visitForm.visitFormID = sequence.visitForms;
//            visitForm.visitID = visitID;
//            visitForm.isActive = YES;
//            [visitForms addObject:visitForm];
//        }
//    }
//    NSMutableArray *predicates = NSMutableArray.alloc.init;
//    [predicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
//    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
//    return [self execute:db entity:@"VisitForms" predicates:predicates];
}

+ (NSArray<CheckIn *> *)syncCheckIn:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self execute:db entity:@"CheckIn" predicates:predicates];
}

+ (NSArray<CheckIn *> *)uploadCheckInPhoto:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isPhotoUpload == %@", @NO]];
    return [self execute:db entity:@"CheckIn" predicates:predicates];
}

+ (NSArray<CheckOut *> *)syncCheckOut:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self execute:db entity:@"CheckOut" predicates:predicates];
}

+ (NSArray<CheckOut *> *)uploadCheckOutPhoto:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isPhotoUpload == %@", @NO]];
    return [self execute:db entity:@"CheckOut" predicates:predicates];
}

+ (NSArray<ExpenseTypeCategories *> *)expenseTypeCategories:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    return [self execute:db entity:@"ExpenseTypeCategories" predicates:predicates];
}

+ (NSArray<ExpenseTypes *> *)expenseTypes:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    return [self execute:db entity:@"ExpenseTypes" predicates:predicates];
}

+ (NSArray<NSMutableDictionary *> *)expenseItems:(NSManagedObjectContext *)db startDate:(NSString *)startDate endDate:(NSString *)endDate {
    NSDate *start = [Time getDateFromString:DATE_FORMAT string:startDate];
    NSDate *end = [Time getDateFromString:DATE_FORMAT string:endDate];
    NSMutableArray<NSMutableDictionary *> *expenseItems = NSMutableArray.alloc.init;
    for(int x = [end timeIntervalSinceDate:start] / 60 / 60 / 24; x >= 0; x--) {
        NSString *date = [Time getFormattedDate:DATE_FORMAT date:[start dateByAddingTimeInterval:60 * 60 * 24 * x]];
        if([Get expenseTodayCount:db date:date withoutDeleted:YES] > 0) {
            double totalAmount = 0;
            NSArray<Expense *> *items = [Load expense:db date:date];
            for(Expense *expense in items) {
                totalAmount += expense.amount;
            }
            NSMutableDictionary *expenseItem = NSMutableDictionary.alloc.init;
            expenseItem[@"Date"] = date;
            expenseItem[@"TotalAmount"] = [NSString stringWithFormat:@"%.02f", totalAmount];
            expenseItem[@"Hidden"] = @YES;
            [expenseItems addObject:expenseItem];
        }
    }
    return expenseItems;
}

+ (NSMutableArray<Expense *> *)expense:(NSManagedObjectContext *)db date:(NSString *)date {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"date == %@", date]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @NO]];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"time" ascending:NO]];
    return [self execute:db entity:@"Expense" predicates:predicates sortDescriptors:sortDescriptors];
}

+ (NSArray<ExpenseReports *> *)expenseReports:(NSManagedObjectContext *)db searchFilter:(NSString *)searchFilter {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    if(searchFilter.length > 0) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchFilter.lowercaseString]];
    }
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"date" ascending:NO]];
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"time" ascending:NO]];
    NSMutableArray<ExpenseReports *> *reports = [NSMutableArray.alloc initWithArray:[self execute:db entity:@"ExpenseReports" predicates:predicates sortDescriptors:sortDescriptors]];
    if(reports.count == 0) {
        ExpenseReports *report1 = [NSEntityDescription insertNewObjectForEntityForName:@"ExpenseReports" inManagedObjectContext:db];
        report1.expenseReportID = [Get sequenceID:db entity:@"ExpenseReports" attribute:@"expenseReportID"];;
        report1.syncBatchID = [Get syncBatch:db].syncBatchID;
        report1.employeeID = [Get userID:db];
        report1.name = @"Expense Report 1";
        NSDate *currentDate = NSDate.date;
        report1.date = [Time getFormattedDate:DATE_FORMAT date:currentDate];
        report1.time = [Time getFormattedDate:TIME_FORMAT date:currentDate];
        report1.isDelete = NO;
        report1.isSync = NO;
        report1.isSubmit = NO;
        report1.isUpdate = NO;
        report1.isWebSubmit = NO;
        [reports addObject:report1];
    }
    return reports;
}

+ (NSArray<Expense *> *)syncExpenses:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @NO]];
    return [self execute:db entity:@"Expense" predicates:predicates];
}

+ (NSArray<Expense *> *)updateExpenses:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isUpdate == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isWebUpdate == %@", @NO]];
    return [self execute:db entity:@"Expense" predicates:predicates];
}

+ (NSArray<Expense *> *)deleteExpenses:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isWebDelete == %@", @NO]];
    return [self execute:db entity:@"Expense" predicates:predicates];
}

+ (NSArray<Inventories *> *)inventories:(NSManagedObjectContext *)db date:(NSString *)date {
    return nil;
//    NSMutableArray<Inventories *> *inventories = [NSMutableArray.alloc initWithArray:[self execute:db entity:@"Inventories"]];
//    if(inventories.count == 0) {
//        for(int x = 1; x <= 5; x++) {
//            Inventories *inventory = [NSEntityDescription insertNewObjectForEntityForName:@"Inventories" inManagedObjectContext:db];
//            inventory.inventoryID = x;
//            inventory.name = [NSString stringWithFormat:@"Inventory %d", x];
//            [inventories addObject:inventory];
//        }
//    }
//    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
//    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"inventoryID" ascending:YES]];
//    return [self execute:db entity:@"Inventories" predicates:nil sortDescriptors:sortDescriptors];
}

+ (NSArray<Forms *> *)forms:(NSManagedObjectContext *)db date:(NSString *)date {
    return nil;
//    NSMutableArray<Forms *> *forms = [NSMutableArray.alloc initWithArray:[self execute:db entity:@"Forms"]];
//    if(forms.count == 0) {
//        for(int x = 1; x <= 5; x++) {
//            Forms *form = [NSEntityDescription insertNewObjectForEntityForName:@"Forms" inManagedObjectContext:db];
//            form.formID = x;
//            form.name = [NSString stringWithFormat:@"Form %d", x];
//            [forms addObject:form];
//        }
//    }
//    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
//    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"formID" ascending:YES]];
//    return [self execute:db entity:@"Forms" predicates:nil sortDescriptors:sortDescriptors];
}

+ (NSArray *)execute:(NSManagedObjectContext *)db entity:(NSString *)entity {
    return [self execute:db entity:entity predicates:nil sortDescriptors:nil];
}

+ (NSArray *)execute:(NSManagedObjectContext *)db entity:(NSString *)entity predicates:(NSArray<NSPredicate *> *)predicates {
    return [self execute:db entity:entity predicates:predicates sortDescriptors:nil];
}

+ (NSArray *)execute:(NSManagedObjectContext *)db entity:(NSString *)entity predicates:(NSArray<NSPredicate *> *)predicates sortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    fetchRequest.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:predicates];
    fetchRequest.sortDescriptors = sortDescriptors;
    NSError *error = nil;
    NSArray *data = [db executeFetchRequest:fetchRequest error:&error];
    if(error != nil) {
        NSLog(@"error: load execute - %@", error.localizedDescription);
    }
    return data;
}

@end
