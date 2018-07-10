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
            if([name isEqualToString:@"Stores"]) {
                name = [Get conventionName:db conventionID:CONVENTION_STORES];
            }
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
            [page setObject:name forKey:@"name"];
            [pages addObject:page];
        }
    }
    return pages;
}

+ (NSArray<Employees *> *)employeeIDs:(NSManagedObjectContext *)db teamID:(long)teamID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Employees"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"teamID == %lld", teamID]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<Announcements *> *)announcements:(NSManagedObjectContext *)db searchFilter:(NSString *)searchFilter isScheduled:(BOOL)isScheduled {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Announcements"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    if(searchFilter.length > 0) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"subject CONTAINS[cd] %@ OR message CONTAINS[cd] %@", searchFilter.lowercaseString, searchFilter.lowercaseString]];
    }
    NSDate *currentDate = NSDate.date;
    [subpredicates addObject:[NSPredicate predicateWithFormat:isScheduled? @"scheduledDate < %@ OR (scheduledDate == %@ AND scheduledTime <= %@)" : @"scheduledDate > %@ OR (scheduledDate == %@ AND scheduledTime > %@)", [Time formatDate:DATE_FORMAT date:currentDate], [Time formatDate:DATE_FORMAT date:currentDate], [Time formatDate:TIME_FORMAT date:currentDate]]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"scheduledDate" ascending:NO]];
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"scheduledTime" ascending:NO]];
    request.sortDescriptors = sortDescriptors;
    return [self fetch:db request:request];
}

+ (NSArray<AnnouncementSeen *> *)syncAnnouncementSeen:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AnnouncementSeen"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<Stores *> *)stores:(NSManagedObjectContext *)db searchFilter:(NSString *)searchFilter {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Stores"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    if(searchFilter.length > 0) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchFilter.lowercaseString]];
    }
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"name" ascending:YES]];
    request.sortDescriptors = sortDescriptors;
    return [self fetch:db request:request];
}

+ (NSArray<Stores *> *)syncStores:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Stores"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<Stores *> *)updateStores:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Stores"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isUpdate == %@", @YES]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isWebUpdate == %@", @NO]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<StoreContacts *> *)storeContacts:(NSManagedObjectContext *)db storeID:(long)storeID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"StoreContacts"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"storeID == %lld", storeID]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"name" ascending:YES]];
    request.sortDescriptors = sortDescriptors;
    return [self fetch:db request:request];
}

+ (NSArray<StoreContacts *> *)syncStoreContacts:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"StoreContacts"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<StoreContacts *> *)updateStoreContacts:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"StoreContacts"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"designation.length > 0"]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"email.length > 0"]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"birthdate.length > 0"]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isUpdate == %@", @YES]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isWebUpdate == %@", @NO]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<ScheduleTimes *> *)scheduleTimes:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ScheduleTimes"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"timeIn" ascending:YES]];
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"timeOut" ascending:YES]];
    request.sortDescriptors = sortDescriptors;
    return [self fetch:db request:request];
}

+ (NSArray<Schedules *> *)syncSchedules:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Schedules"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", [Get userID:db]]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<Schedules *> *)updateSchedules:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Schedules"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", [Get userID:db]]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isFromWeb == %@", @NO]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<TimeIn *> *)syncTimeIn:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimeIn"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<TimeIn *> *)uploadTimeInPhoto:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimeIn"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0"]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isPhotoUpload == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<TimeOut *> *)syncTimeOut:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimeOut"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<TimeOut *> *)uploadTimeOutPhoto:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimeOut"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0"]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isPhotoUpload == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<TimeOut *> *)uploadTimeOutSignature:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimeOut"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"signature.length > 0"]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSignatureUpload == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<Photos *> *)visitPhotos:(NSManagedObjectContext *)db visitID:(long)visitID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VisitPhotos"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    NSArray<VisitPhotos *> *visitPhotos = [self fetch:db request:request];
    NSMutableArray<Photos *> *photos = NSMutableArray.alloc.init;
    for(int x = 0 ; x < visitPhotos.count; x++) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photos"];
        NSMutableArray *subpredicates = NSMutableArray.alloc.init;
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"photoID == %ld", visitPhotos[x].photoID]];
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @NO]];
        request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
        [photos addObjectsFromArray:[self fetch:db request:request]];
    }
    return photos;
}

+ (NSArray<Photos *> *)uploadVisitPhotos:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VisitPhotos"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    NSArray<VisitPhotos *> *visitPhotos = [self fetch:db request:request];
    NSMutableArray<Photos *> *photos = NSMutableArray.alloc.init;
    for(int x = 0 ; x < visitPhotos.count; x++) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photos"];
        NSMutableArray *subpredicates = NSMutableArray.alloc.init;
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"photoID == %ld", visitPhotos[x].photoID]];
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"isUpload == %@", @NO]];
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @NO]];
        request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
        [photos addObjectsFromArray:[self fetch:db request:request]];
    }
    return photos;
}

+ (NSArray<Visits *> *)visits:(NSManagedObjectContext *)db date:(NSDate *)date isNoCheckOutOnly:(BOOL)isNoCheckOutOnly {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Visits"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"%@ BETWEEN {startDate, endDate}", [Time formatDate:DATE_FORMAT date:date]]];
    if(isNoCheckOutOnly) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"isCheckOut == %@", @NO]];
    }
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<Visits *> *)syncVisits:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Visits"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<Visits *> *)updateVisits:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Visits"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"storeID.length > 0"]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isUpdate == %@", @YES]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isWebUpdate == %@", @NO]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<Visits *> *)deleteVisits:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Visits"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isDelete == %@", @YES]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isWebDelete == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<VisitInventories *> *)visitInventories:(NSManagedObjectContext *)db visitID:(long)visitID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VisitInventories"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<VisitForms *> *)visitForms:(NSManagedObjectContext *)db visitID:(long)visitID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VisitForms"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<CheckIn *> *)syncCheckIn:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CheckIn"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<CheckIn *> *)uploadCheckInPhoto:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CheckIn"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0"]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isPhotoUpload == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<CheckOut *> *)syncCheckOut:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CheckOut"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<CheckOut *> *)uploadCheckOutPhoto:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CheckOut"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"photo.length > 0"]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isPhotoUpload == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    return [self fetch:db request:request];
}

+ (NSArray<Inventories *> *)inventories:(NSManagedObjectContext *)db date:(NSDate *)date {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Inventories"];
    return [self fetch:db request:request];
}

+ (NSArray<Forms *> *)forms:(NSManagedObjectContext *)db date:(NSDate *)date {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Forms"];
    return [self fetch:db request:request];
}

+ (NSArray *)fetch:(NSManagedObjectContext *)db request:(NSFetchRequest *)request {
    NSError *error = nil;
    NSArray *data = [db executeFetchRequest:request error:&error];
    if(error != nil) {
        NSLog(@"error: load fetch - %@", error.localizedDescription);
    }
    return data;
}

@end
