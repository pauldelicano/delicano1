#import "Load.h"
#import "App.h"
#import "Get.h"
#import "Time.h"

@implementation Load

+ (NSArray<NSDictionary *> *)drawerMenus:(NSManagedObjectContext *)db {
    NSMutableArray *menus = NSMutableArray.alloc.init;
    for(int x = 1; x <= MENU_LOGOUT; x++) {
        NSString *name;
        NSString *icon;
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
            [menu setObject:[NSString stringWithFormat:@"%d", x] forKey:@"ID"];
            icon = nil;
            [menu setObject:icon == nil ? [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", @"Menu", [name stringByReplacingOccurrencesOfString:@" " withString:@""]]] : icon forKey:@"icon"];
            [menu setObject:name forKey:@"name"];
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
            [page setObject:[NSString stringWithFormat:@"%d", x] forKey:@"ID"];
            [page setObject:[NSString stringWithFormat:@"%@%@", @"vc", name] forKey:@"viewController"];
            icon = nil;
            [page setObject:icon == nil ? [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", @"Page", name]] : icon forKey:@"icon"];
            if([name isEqualToString:@"Visits"]) {
                name = [Get conventionName:db conventionID:CONVENTION_VISITS];
            }
            if([name isEqualToString:@"Forms"]) {
                name = @"Entries";
            }
            [page setObject:name forKey:@"name"];
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

+ (NSArray<Photos *> *)visitPhotos:(NSManagedObjectContext *)db visitID:(int64_t)visitID {
    NSMutableArray<Photos *> *photos = NSMutableArray.alloc.init;
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    NSArray<VisitPhotos *> *visitPhotos = [self execute:db entity:@"VisitPhotos" predicates:predicates];
    for(int x = 0 ; x < visitPhotos.count; x++) {
        NSMutableArray *predicates = NSMutableArray.alloc.init;
        [predicates addObject:[NSPredicate predicateWithFormat:@"photoID == %ld", visitPhotos[x].photoID]];
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

+ (NSArray<Visits *> *)visits:(NSManagedObjectContext *)db date:(NSDate *)date isNoCheckOutOnly:(BOOL)isNoCheckOutOnly {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    if(isNoCheckOutOnly) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"isCheckOut == %@", @NO]];
    }
    [predicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"%@ BETWEEN {startDate, endDate}", [Time getFormattedDate:DATE_FORMAT date:date]]];
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

+ (NSArray<Inventories *> *)inventories:(NSManagedObjectContext *)db date:(NSDate *)date {
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

+ (NSArray<Forms *> *)forms:(NSManagedObjectContext *)db date:(NSDate *)date {
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

+ (NSArray<Tracking *> *)syncTracking:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self execute:db entity:@"Tracking" predicates:predicates];
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
