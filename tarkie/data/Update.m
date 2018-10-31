#import "Update.h"
#import "App.h"
#import "Get.h"
#import "Time.h"

@implementation Update

+ (BOOL)usersLogout:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isLogout == %@", @NO]];
    for(Users *user in [self execute:db entity:@"Users" predicates:predicates]) {
        user.isLogout = YES;
    }
    return [self save:db];
}

+ (void)employeesDeactivate:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    for(Employees *employee in [self execute:db entity:@"Employees" predicates:predicates]) {
        employee.isActive = NO;
    }
}

+ (int64_t)gpsSave:(NSManagedObjectContext *)db dbAlerts:(NSManagedObjectContext *)dbAlerts location:(CLLocation *)location {
    int64_t gpsID = 0;
    BOOL isValid = NO;
    if(location != nil && location.coordinate.latitude != 0 && location.coordinate.longitude != 0) {
        isValid = fabs([location.timestamp timeIntervalSinceNow]) <= 5;
        GPS *gps = [NSEntityDescription insertNewObjectForEntityForName:@"GPS" inManagedObjectContext:db];
        gps.gpsID = [Get sequenceID:db entity:@"GPS" attribute:@"gpsID"] + 1;;
        gps.date = [Time getFormattedDate:DATE_FORMAT date:location.timestamp];
        gps.time = [Time getFormattedDate:TIME_FORMAT date:location.timestamp];
        gps.latitude = location.coordinate.latitude;
        gps.longitude = location.coordinate.longitude;
        gps.isValid = isValid;
        NSLog(@"gps: %@ %@ %f %f %d", gps.date, gps.time, gps.latitude, gps.longitude, gps.isValid);
        if([self save:db]) {
            gpsID = gps.gpsID;
        }
    }
    if(gpsID == 0 || !isValid) {
        Alerts *alert = [Get alert:dbAlerts alertTypeID:ALERT_TYPE_NO_GPS_SIGNAL];
        if(alert == nil || alert.alertTypeID != ALERT_TYPE_NO_GPS_SIGNAL) {
            NSLog(@"alert: ALERT_TYPE_NO_GPS_SIGNAL");
            [self alertSave:dbAlerts alertTypeID:ALERT_TYPE_NO_GPS_SIGNAL gpsID:gpsID value:nil];
        }
    }
    else {
        Alerts *alert = [Get alert:dbAlerts alertTypeID:ALERT_TYPE_GPS_ACQUIRED];
        if(alert == nil || alert.alertTypeID != ALERT_TYPE_GPS_ACQUIRED) {
            NSLog(@"alert: ALERT_TYPE_GPS_ACQUIRED");
            [self alertSave:dbAlerts alertTypeID:ALERT_TYPE_GPS_ACQUIRED gpsID:gpsID value:nil];
        }
    }
    return gpsID;
}

+ (BOOL)alertSave:(NSManagedObjectContext *)db alertTypeID:(int64_t)alertTypeID gpsID:(int64_t)gpsID value:(NSString *)value {
    Alerts *alert = [NSEntityDescription insertNewObjectForEntityForName:@"Alerts" inManagedObjectContext:db];
    alert.alertID = [Get sequenceID:db entity:@"Alerts" attribute:@"alertID"] + 1;
    alert.syncBatchID = [Get syncBatch:db].syncBatchID;
    alert.employeeID = [Get userID:db];
    alert.timeInID = [Get timeIn:db].timeInID;
    alert.alertTypeID = alertTypeID;
    NSDate *currentDate = NSDate.date;
    alert.date = [Time getFormattedDate:DATE_FORMAT date:currentDate];
    alert.time = [Time getFormattedDate:TIME_FORMAT date:currentDate];
    alert.gpsID = gpsID;
    alert.value = value;
    alert.isSync = NO;
    return [self save:db];
}

+ (void)announcementsDeactivate:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    for(Announcements *announcement in [self execute:db entity:@"Announcements" predicates:predicates]) {
        announcement.isActive = NO;
    }
}

+ (void)storesDeactivate:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isFromTask == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isTag == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    for(Stores *store in [self execute:db entity:@"Stores" predicates:predicates]) {
        store.isTag = NO;
        store.isActive = NO;
    }
}

+ (void)storeContactsDeactivate:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    for(StoreContacts *storeContact in [self execute:db entity:@"StoreContacts" predicates:predicates]) {
        storeContact.isActive = NO;
    }
}

+ (void)scheduleTimesDeactivate:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    for(ScheduleTimes *scheduleTime in [self execute:db entity:@"ScheduleTimes" predicates:predicates]) {
        scheduleTime.isActive = NO;
    }
}

+ (void)schedulesDeactivate:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    for(Schedules *schedule in [self execute:db entity:@"Schedules" predicates:predicates]) {
        schedule.isActive = NO;
    }
}

+ (void)breakTypesDeactivate:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    for(BreakTypes *breakType in [self execute:db entity:@"BreakTypes" predicates:predicates]) {
        breakType.isActive = NO;
    }
}

+ (void)overtimeReasonsDeactivate:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    for(OvertimeReasons *overtimeReason in [self execute:db entity:@"OvertimeReasons" predicates:predicates]) {
        overtimeReason.isActive = NO;
    }
}

+ (void)expenseTypeCategoriesDeactivate:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    for(ExpenseTypeCategories *expenseTypeCategory in [self execute:db entity:@"ExpenseTypeCategories" predicates:predicates]) {
        expenseTypeCategory.isActive = NO;
    }
}

+ (void)expenseTypesDeactivate:(NSManagedObjectContext *)db expenseTypeCategoryID:(int64_t)expenseTypeCategoryID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"expenseTypeCategoryID == %lld", expenseTypeCategoryID]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    for(ExpenseTypes *expenseType in [self execute:db entity:@"ExpenseTypes" predicates:predicates]) {
        expenseType.isActive = NO;
    }
}

+ (NSArray *)execute:(NSManagedObjectContext *)db entity:(NSString *)entity predicates:(NSArray<NSPredicate *> *)predicates  {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    fetchRequest.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:predicates];
    NSError *error = nil;
    NSArray *data = [db executeFetchRequest:fetchRequest error:&error];
    if(error != nil) {
        NSLog(@"error: update execute - %@", error.localizedDescription);
    }
    return data;
}

+ (BOOL)save:(NSManagedObjectContext *)db {
    NSError *error = nil;
    if(![db save:&error]) {
        if(error != nil) {
            NSLog(@"error: update save - %@", error.localizedDescription);
        }
        [db rollback];
        return NO;
    }
    return YES;
}

@end
