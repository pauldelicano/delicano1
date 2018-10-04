#import "Get.h"
#import "App.h"
#import "Time.h"

@implementation Get

+ (int64_t)sequenceID:(NSManagedObjectContext *)db entity:(NSString *)entity attribute:(NSString *)attribute {
    int64_t ID = 0;
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:attribute ascending:NO]];
    NSManagedObject *managedObject = [self execute:db entity:entity predicates:nil sortDescriptors:sortDescriptors];
    if([managedObject isKindOfClass:GPS.class]) {
        ID = ((GPS *)managedObject).gpsID;
    }
    if([managedObject isKindOfClass:Stores.class]) {
        ID = ((Stores *)managedObject).storeID;
    }
    if([managedObject isKindOfClass:StoreContacts.class]) {
        ID = ((StoreContacts *)managedObject).storeContactID;
    }
    if([managedObject isKindOfClass:Schedules.class]) {
        ID = ((Schedules *)managedObject).scheduleID;
    }
    if([managedObject isKindOfClass:TimeIn.class]) {
        ID = ((TimeIn *)managedObject).timeInID;
    }
    if([managedObject isKindOfClass:TimeOut.class]) {
        ID = ((TimeOut *)managedObject).timeOutID;
    }
    if([managedObject isKindOfClass:BreakIn.class]) {
        ID = ((BreakIn *)managedObject).breakInID;
    }
    if([managedObject isKindOfClass:BreakOut.class]) {
        ID = ((BreakOut *)managedObject).breakOutID;
    }
    if([managedObject isKindOfClass:Overtime.class]) {
        ID = ((Overtime *)managedObject).overtimeID;
    }
    if([managedObject isKindOfClass:Tracking.class]) {
        ID = ((Tracking *)managedObject).trackingID;
    }
    if([managedObject isKindOfClass:Alerts.class]) {
        ID = ((Alerts *)managedObject).alertID;
    }
    if([managedObject isKindOfClass:Photos.class]) {
        ID = ((Photos *)managedObject).photoID;
    }
    if([managedObject isKindOfClass:Visits.class]) {
        ID = ((Visits *)managedObject).visitID;
    }
    if([managedObject isKindOfClass:VisitPhotos.class]) {
        ID = ((VisitPhotos *)managedObject).visitPhotoID;
    }
    if([managedObject isKindOfClass:VisitInventories.class]) {
        ID = ((VisitInventories *)managedObject).visitInventoryID;
    }
    if([managedObject isKindOfClass:VisitForms.class]) {
        ID = ((VisitForms *)managedObject).visitFormID;
    }
    if([managedObject isKindOfClass:CheckIn.class]) {
        ID = ((CheckIn *)managedObject).checkInID;
    }
    if([managedObject isKindOfClass:CheckOut.class]) {
        ID = ((CheckOut *)managedObject).checkOutID;
    }
    return ID;
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

+ (Modules *)module:(NSManagedObjectContext *)db moduleID:(int64_t)moduleID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"moduleID == %ld", moduleID]];
    return [self execute:db entity:@"Modules" predicates:predicates];
}

+ (BOOL)isModuleEnabled:(NSManagedObjectContext *)db moduleID:(int64_t)moduleID {
    if(moduleID == 3 || moduleID == 4 || moduleID == 5) {
        return NO;//paul
    }
    return [self module:db moduleID:moduleID].isEnabled;
}

+ (Users *)user:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isLogout == %@", @NO]];
    return [self execute:db entity:@"Users" predicates:predicates];
}

+ (int64_t)userID:(NSManagedObjectContext *)db {
    return [self user:db].userID;
}

+ (Employees *)employee:(NSManagedObjectContext *)db employeeID:(int64_t)employeeID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", employeeID]];
    return [self execute:db entity:@"Employees" predicates:predicates];
}

+ (int64_t)teamID:(NSManagedObjectContext *)db employeeID:(int64_t)employeeID {
    return [self employee:db employeeID:employeeID].teamID;
}

+ (Settings *)setting:(NSManagedObjectContext *)db settingID:(int64_t)settingID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"settingID == %ld", settingID]];
    return [self execute:db entity:@"Settings" predicates:predicates];
}

+ (int64_t)settingID:(NSManagedObjectContext *)db settingName:(NSString *)settingName {
    int64_t settingID = 0;
    if([settingName isEqualToString:@"setGen-003-01"]) {
        settingID = SETTING_DISPLAY_CURRENCY;
    }
    if([settingName isEqualToString:@"setGen-003-02"]) {
        settingID = SETTING_DISPLAY_DATE_FORMAT;
    }
    if([settingName isEqualToString:@"setGen-003-03"]) {
        settingID = SETTING_DISPLAY_TIME_FORMAT;
    }
    if([settingName isEqualToString:@"setGen-003-04"]) {
        settingID = SETTING_DISPLAY_DISTANCE_UOM;
    }
    if([settingName isEqualToString:@"setGen-001-01"]) {
        settingID = SETTING_LOCATION_TRACKING;
    }
    if([settingName isEqualToString:@"setGen-001-02"]) {
        settingID = SETTING_LOCATION_GPS_TRACKING;
    }
    if([settingName isEqualToString:@"setGen-001-07"]) {
        settingID = SETTING_LOCATION_GPS_TRACKING_INTERVAL;
    }
    if([settingName isEqualToString:@"setGen-001-03"]) {
        settingID = SETTING_LOCATION_GEO_TAGGING;
    }
    if([settingName isEqualToString:@"setGen-001-04"]) {
        settingID = SETTING_LOCATION_ALERTS;
    }
    if([settingName isEqualToString:@"setGen-002-01"]) {
        settingID = SETTING_STORE_ADD;
    }
    if([settingName isEqualToString:@"setGen-002-02"]) {
        settingID = SETTING_STORE_EDIT;
    }
    if([settingName isEqualToString:@"setGen-002-03"]) {
        settingID = SETTING_STORE_DISPLAY_LONG_NAME;
    }
    if([settingName isEqualToString:@"SetAtt-001-01"]) {
        settingID = SETTING_ATTENDANCE_STORE;
    }
    if([settingName isEqualToString:@"SetAtt-001-07"]) {
        settingID = SETTING_ATTENDANCE_SCHEDULE;
    }
    if([settingName isEqualToString:@"SetAtt-001-02"]) {
        settingID = SETTING_ATTENDANCE_MULTIPLE_TIME_IN_OUT;
    }
    if([settingName isEqualToString:@"SetAtt-001-03"]) {
        settingID = SETTING_ATTENDANCE_TIME_IN_PHOTO;
    }
    if([settingName isEqualToString:@"SetAtt-001-04"]) {
        settingID = SETTING_ATTENDANCE_TIME_OUT_PHOTO;
    }
    if([settingName isEqualToString:@"SetAtt-001-06"]) {
        settingID = SETTING_ATTENDANCE_TIME_OUT_SIGNATURE;
    }
    if([settingName isEqualToString:@"SetAtt-001-05"]) {
        settingID = SETTING_ATTENDANCE_ODOMETER_PHOTO;
    }
    if([settingName isEqualToString:@"SetAtt-002-01"]) {
        settingID = SETTING_ATTENDANCE_ADD_EDIT_LEAVES;
    }
    if([settingName isEqualToString:@"SetAtt-002-02"]) {
        settingID = SETTING_ATTENDANCE_ADD_EDIT_REST_DAYS;
    }
    if([settingName isEqualToString:@"SetAtt-004-03"]) {
        settingID = SETTING_ATTENDANCE_GRACE_PERIOD;
    }
    if([settingName isEqualToString:@"SetAtt-004-02"]) {
        settingID = SETTING_ATTENDANCE_GRACE_PERIOD_DURATION;
    }
    if([settingName isEqualToString:@"SetAtt-004-01"]) {
        settingID = SETTING_ATTENDANCE_OVERTIME_MINIMUM_DURATION;
    }
    if([settingName isEqualToString:@"SetAtt-003-02"]) {
        settingID = SETTING_ATTENDANCE_NOTIFICATION_LATE_OPENING;
    }
    if([settingName isEqualToString:@"SetAtt-003-01"]) {
        settingID = SETTING_ATTENDANCE_NOTIFICATION_TIME_OUT;
    }
    if([settingName isEqualToString:@"SetIti-001-01"]) {
        settingID = SETTING_VISITS_ADD;
    }
    if([settingName isEqualToString:@"SetIti-001-06"]) {
        settingID = SETTING_VISITS_EDIT_AFTER_CHECK_OUT;
    }
    if([settingName isEqualToString:@"SetIti-001-02"]) {
        settingID = SETTING_VISITS_RESCHEDULE;
    }
    if([settingName isEqualToString:@"SetIti-001-03"]) {
        settingID = SETTING_VISITS_DELETE;
    }
    if([settingName isEqualToString:@"SetIti-001-10"]) {
        settingID = SETTING_VISITS_INVOICE;
    }
    if([settingName isEqualToString:@"SetIti-001-11"]) {
        settingID = SETTING_VISITS_DELIVERIES;
    }
    if([settingName isEqualToString:@"SetIti-001-05"]) {
        settingID = SETTING_VISITS_NOTES;
    }
    if([settingName isEqualToString:@"SetIti-001-09"]) {
        settingID = SETTING_VISITS_NOTES_FOR_COMPLETED;
    }
    if([settingName isEqualToString:@"SetIti-001-07"]) {
        settingID = SETTING_VISITS_NOTES_FOR_NOT_COMPLETED;
    }
    if([settingName isEqualToString:@"SetIti-001-08"]) {
        settingID = SETTING_VISITS_NOTES_FOR_CANCELED;
    }
    if([settingName isEqualToString:@"SetIti-001-13"]) {
        settingID = SETTING_VISITS_NOTES_AS_ADDRESS;
    }
    if([settingName isEqualToString:@"SetIti-001-04"]) {
        settingID = SETTING_VISITS_PARALLEL_CHECK_IN_OUT;
    }
    if([settingName isEqualToString:@"SetIti-002-01"]) {
        settingID = SETTING_VISITS_CHECK_IN_PHOTO;
    }
    if([settingName isEqualToString:@"SetIti-002-02"]) {
        settingID = SETTING_VISITS_CHECK_OUT_PHOTO;
    }
    if([settingName isEqualToString:@"SetIti-001-12"]) {
        settingID = SETTING_VISITS_SMS_SENDING;
    }
    if([settingName isEqualToString:@"SetIti-002-03"]) {
        settingID = SETTING_VISITS_AUTO_PUBLISH_PHOTOS;
    }
    if([settingName isEqualToString:@"setGen-001-05"]) {
        settingID = SETTING_VISITS_ALERT_NO_CHECK_OUT;
    }
    if([settingName isEqualToString:@"setGen-001-08"]) {
        settingID = SETTING_VISITS_ALERT_NO_CHECK_OUT_DISTANCE;
    }
    if([settingName isEqualToString:@"setGen-001-06"]) {
        settingID = SETTING_VISIT_ALERT_NO_MOVEMENT;
    }
    if([settingName isEqualToString:@"setGen-001-09"]) {
        settingID = SETTING_VISIT_ALERT_NO_MOVEMENT_DURATION;
    }
    if([settingName isEqualToString:@"setGen-001-10"]) {
        settingID = SETTING_VISIT_ALERT_OVERSTAYING;
    }
    if([settingName isEqualToString:@"setGen-001-11"]) {
        settingID = SETTING_VISIT_ALERT_OVERSTAYING_DURATION;
    }
    if([settingName isEqualToString:@"SetExp-001-01"]) {
        settingID = SETTING_EXPENSE_NOTES;
    }
    if([settingName isEqualToString:@"SetExp-001-02"]) {
        settingID = SETTING_EXPENSE_ORIGIN_DESTINATION;
    }
    if([settingName isEqualToString:@"SetExp-001-03"]) {
        settingID = SETTING_EXPENSE_COST_PER_LITER;
    }
    if([settingName isEqualToString:@"setInv-000-09"]) {
        settingID = SETTING_INVENTORY_TRACKING_V2;
    }
    if([settingName isEqualToString:@"setInv-000-01"]) {
        settingID = SETTING_INVENTORY_TRACKING_V1;
    }
    if([settingName isEqualToString:@"setInv-000-02"]) {
        settingID = SETTING_INVENTORY_TRADE_CHECK;
    }
    if([settingName isEqualToString:@"setInv-000-03"]) {
        settingID = SETTING_INVENTORY_SALES_AND_OFFTAKE;
    }
    if([settingName isEqualToString:@"setInv-000-10"]) {
        settingID = SETTING_INVENTORY_ORDERS;
    }
    if([settingName isEqualToString:@"setInv-000-04"]) {
        settingID = SETTING_INVENTORY_DELIVERIES;
    }
    if([settingName isEqualToString:@"setInv-000-11"]) {
        settingID = SETTING_INVENTORY_ADJUSTMENTS;
    }
    if([settingName isEqualToString:@"setInv-000-05"]) {
        settingID = SETTING_INVENTORY_PHYSICAL_COUNT;
    }
    if([settingName isEqualToString:@"setInv-001-01"]) {
        settingID = SETTING_INVENTORY_PHYSICAL_COUNT_THEORETICAL;
    }
    if([settingName isEqualToString:@"setInv-000-06"]) {
        settingID = SETTING_INVENTORY_PULL_OUTS;
    }
    if([settingName isEqualToString:@"setInv-000-07"]) {
        settingID = SETTING_INVENTORY_RETURNS;
    }
    if([settingName isEqualToString:@"setInv-000-08"]) {
        settingID = SETTING_INVENTORY_STOCKS_ON_HAND;
    }
    return settingID;
}

+ (SettingsTeams *)settingTeam:(NSManagedObjectContext *)db settingID:(int64_t)settingID teamID:(int64_t)teamID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"settingID == %ld", settingID]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"teamID == %ld", teamID]];
    return [self execute:db entity:@"SettingsTeams" predicates:predicates];
}

+ (BOOL)isSettingEnabled:(NSManagedObjectContext *)db settingID:(int64_t)settingID  teamID:(int64_t)teamID {
    return [[self settingTeam:db settingID:settingID teamID:teamID].value isEqualToString:@"yes"];
}

+ (NSString *)settingCurrencySymbol:(NSManagedObjectContext *)db teamID:(int64_t)teamID {
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

+ (NSString *)settingDateFormat:(NSManagedObjectContext *)db teamID:(int64_t)teamID {
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

+ (NSString *)settingTimeFormat:(NSManagedObjectContext *)db teamID:(int64_t)teamID {
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

+ (Conventions *)convention:(NSManagedObjectContext *)db conventionID:(int64_t)conventionID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"conventionID == %ld", conventionID]];
    return [self execute:db entity:@"Conventions" predicates:predicates];
}

+ (NSString *)conventionName:(NSManagedObjectContext *)db conventionID:(int64_t)conventionID {
    return [self convention:db conventionID:conventionID].value.capitalizedString;
}

+ (TimeSecurity *)timeSecurity:(NSManagedObjectContext *)db {
    return [self execute:db entity:@"TimeSecurity"];
}

+ (SyncBatch *)syncBatch:(NSManagedObjectContext *)db {
    return [self execute:db entity:@"SyncBatch"];
}

+ (Patches *)patch:(NSManagedObjectContext *)db patchID:(int64_t)patchID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"patchID == %ld", patchID]];
    return [self execute:db entity:@"Patches" predicates:predicates];
}

+ (long)syncPatchesCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isDone == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self count:db entity:@"Patches" predicates:predicates];
}

+ (GPS *)gps:(NSManagedObjectContext *)db gpsID:(int64_t)gpsID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"gpsID == %ld", gpsID]];
    return [self execute:db entity:@"GPS" predicates:predicates];
}

+ (Alerts *)alert:(NSManagedObjectContext *)db alertTypeID:(int64_t)alertTypeID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    int64_t timeInID = [Get timeIn:db].timeInID;
    if(timeInID != 0) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"timeInID == %ld", timeInID]];
    }
    switch(alertTypeID) {
        case ALERT_TYPE_GPS_ACQUIRED:
        case ALERT_TYPE_NO_GPS_SIGNAL: {
            [predicates addObject:[NSPredicate predicateWithFormat:@"alertTypeID == %ld || alertTypeID == %ld", ALERT_TYPE_GPS_ACQUIRED, ALERT_TYPE_NO_GPS_SIGNAL]];
            break;
        }
        case ALERT_TYPE_INSIDE_GEO_FENCE:
        case ALERT_TYPE_OUTSIDE_GEO_FENCE: {
            [predicates addObject:[NSPredicate predicateWithFormat:@"alertTypeID == %ld || alertTypeID == %ld", ALERT_TYPE_INSIDE_GEO_FENCE, ALERT_TYPE_OUTSIDE_GEO_FENCE]];
            break;
        }
        default: {
            [predicates addObject:[NSPredicate predicateWithFormat:@"alertTypeID == %ld", alertTypeID]];
            break;
        }
    }
    return [self execute:db entity:@"Alerts" predicates:predicates];
}

+ (long)syncAlertsCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self count:db entity:@"Alerts" predicates:predicates];
}

+ (Announcements *)announcement:(NSManagedObjectContext *)db announcementID:(int64_t)announcementID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"announcementID == %ld", announcementID]];
    return [self execute:db entity:@"Announcements" predicates:predicates];
}

+ (AnnouncementSeen *)announcementSeen:(NSManagedObjectContext *)db announcementID:(int64_t)announcementID {
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

+ (Stores *)store:(NSManagedObjectContext *)db webStoreID:(int64_t)webStoreID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"webStoreID == %ld", webStoreID]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", [self userID:db]]];
    return [self execute:db entity:@"Stores" predicates:predicates];
}

+ (Stores *)store:(NSManagedObjectContext *)db storeID:(int64_t)storeID {
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

+ (StoreContacts *)storeContact:(NSManagedObjectContext *)db webStoreContactID:(int64_t)webStoreContactID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"webStoreContactID == %ld", webStoreContactID]];
    return [self execute:db entity:@"StoreContacts" predicates:predicates];
}

+ (StoreContacts *)storeContact:(NSManagedObjectContext *)db storeContactID:(int64_t)storeContactID {
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

+ (ScheduleTimes *)scheduleTime:(NSManagedObjectContext *)db scheduleTimeID:(int64_t)scheduleTimeID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"scheduleTimeID == %ld", scheduleTimeID]];
    return [self execute:db entity:@"ScheduleTimes" predicates:predicates];
}

+ (Schedules *)schedule:(NSManagedObjectContext *)db webScheduleID:(int64_t)webScheduleID scheduleDate:(NSString *)scheduleDate {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"webScheduleID == %ld OR scheduleDate == %@", webScheduleID, scheduleDate]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", [self userID:db]]];
    return [self execute:db entity:@"Schedules" predicates:predicates];
}

+ (Schedules *)schedule:(NSManagedObjectContext *)db scheduleID:(int64_t)scheduleID {
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
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", [self userID:db]]];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"timeInID" ascending:NO]];
    return [self execute:db entity:@"TimeIn" predicates:predicates sortDescriptors:sortDescriptors];
}

+ (TimeIn *)timeIn:(NSManagedObjectContext *)db timeInID:(int64_t)timeInID {
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
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", [self userID:db]]];
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

+ (TimeOut *)timeOut:(NSManagedObjectContext *)db timeInID:(int64_t)timeInID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"timeInID == %ld", timeInID]];
    return [self execute:db entity:@"TimeOut" predicates:predicates];
}

+ (TimeOut *)timeOut:(NSManagedObjectContext *)db timeOutID:(int64_t)timeOutID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"timeOutID == %ld", timeOutID]];
    return [self execute:db entity:@"TimeOut" predicates:predicates];
}

+ (BOOL)isTimeOut:(NSManagedObjectContext *)db timeInID:(int64_t)timeInID {
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

+ (BreakTypes *)breakType:(NSManagedObjectContext *)db breakTypeID:(int64_t)breakTypeID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"breakTypeID == %ld", breakTypeID]];
    return [self execute:db entity:@"BreakTypes" predicates:predicates];
}

+ (BreakIn *)breakIn:(NSManagedObjectContext *)db timeInID:(int64_t)timeInID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"timeInID == %ld", timeInID]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isBreakOut == %@", @NO]];
    return [self execute:db entity:@"BreakIn" predicates:predicates];
}

+ (BreakIn *)breakIn:(NSManagedObjectContext *)db timeInID:(int64_t)timeInID breakTypeID:(int64_t)breakTypeID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"timeInID == %ld", timeInID]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"breakTypeID == %ld", breakTypeID]];
    return [self execute:db entity:@"BreakIn" predicates:predicates];
}

+ (BreakIn *)breakIn:(NSManagedObjectContext *)db breakInID:(int64_t)breakInID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"breakInID == %ld", breakInID]];
    return [self execute:db entity:@"BreakIn" predicates:predicates];
}

+ (long)syncBreakInCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self count:db entity:@"BreakIn" predicates:predicates];
}

+ (BreakOut *)breakOut:(NSManagedObjectContext *)db breakInID:(int64_t)breakInID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"breakInID == %ld", breakInID]];
    return [self execute:db entity:@"BreakOut" predicates:predicates];
}

+ (BreakOut *)breakOut:(NSManagedObjectContext *)db breakOutID:(int64_t)breakOutID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"breakOutID == %ld", breakOutID]];
    return [self execute:db entity:@"BreakOut" predicates:predicates];
}

+ (long)syncBreakOutCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self count:db entity:@"BreakOut" predicates:predicates];
}

+ (OvertimeReasons *)overtimeReason:(NSManagedObjectContext *)db overtimeReasonID:(int64_t)overtimeReasonID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"overtimeReasonID == %ld", overtimeReasonID]];
    return [self execute:db entity:@"OvertimeReasons" predicates:predicates];
}

+ (long)syncOvertimeCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self count:db entity:@"Overtime" predicates:predicates];
}

+ (long)syncTrackingCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @NO]];
    return [self count:db entity:@"Tracking" predicates:predicates];
}

+ (Photos *)photo:(NSManagedObjectContext *)db photoID:(int64_t)photoID {
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

+ (Visits *)visit:(NSManagedObjectContext *)db visitID:(int64_t)visitID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    return [self execute:db entity:@"Visits" predicates:predicates];
}

+ (Visits *)visit:(NSManagedObjectContext *)db webVisitID:(int64_t)webVisitID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"webVisitID == %ld", webVisitID]];
    return [self execute:db entity:@"Visits" predicates:predicates];
}

+ (long)visitTodayCount:(NSManagedObjectContext *)db date:(NSString *)date {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [self userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isFromWeb == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"%@ BETWEEN {startDate, endDate}", date]];
    return [self count:db entity:@"Visits" predicates:predicates];
}

+ (long)syncVisitsCount:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"(isSync == %@ AND isDelete == %@) OR (storeID.length > 0 AND isSync == %@ AND isUpdate == %@ AND isWebUpdate == %@ AND isDelete == %@) OR (isSync == %@ AND isDelete == %@ AND isWebDelete = %@)", @NO, @NO, @YES, @YES, @NO, @NO, @YES, @YES, @NO]];
    return [self count:db entity:@"Visits" predicates:predicates];
}

+ (VisitInventories *)visitInventory:(NSManagedObjectContext *)db visitID:(int64_t)visitID inventoryID:(int64_t)inventoryID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"inventoryID == %ld", inventoryID]];
    return [self execute:db entity:@"VisitInventories" predicates:predicates];
}

+ (VisitForms *)visitForm:(NSManagedObjectContext *)db visitID:(int64_t)visitID formID:(int64_t)formID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"formID == %ld", formID]];
    return [self execute:db entity:@"VisitForms" predicates:predicates];
}

+ (CheckIn *)checkIn:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", [self userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isCheckIn == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isCheckOut == %@", @NO]];
    NSMutableArray *sortDescriptors = NSMutableArray.alloc.init;
    [sortDescriptors addObject:[NSSortDescriptor.alloc initWithKey:@"visitID" ascending:YES]];
    Visits *visit = [self execute:db entity:@"Visits" predicates:predicates sortDescriptors:sortDescriptors];
    return [self checkIn:db visitID:visit.visitID];
}

+ (CheckIn *)checkIn:(NSManagedObjectContext *)db visitID:(int64_t)visitID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"visitID == %ld", visitID]];
    return [self execute:db entity:@"CheckIn" predicates:predicates];
}

+ (CheckIn *)checkIn:(NSManagedObjectContext *)db checkInID:(int64_t)checkInID {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"checkInID == %ld", checkInID]];
    return [self execute:db entity:@"CheckIn" predicates:predicates];
}

+ (BOOL)isCheckIn:(NSManagedObjectContext *)db  {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %ld", [self userID:db]]];
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

+ (CheckOut *)checkOut:(NSManagedObjectContext *)db checkInID:(int64_t)checkInID {
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
    return [self syncAnnouncementSeenCount:db] + [self syncStoresCount:db] + [self syncStoreContactsCount:db] + [self syncSchedulesCount:db] + [self syncTimeInCount:db] + [self uploadTimeInPhotoCount:db] + [self syncTimeOutCount:db] + [self uploadTimeOutPhotoCount:db] + [self uploadTimeOutSignatureCount:db] + [self syncBreakInCount:db] + [self syncBreakOutCount:db] + [self syncOvertimeCount:db] + [self syncTrackingCount:db] + [self syncAlertsCount:db] + [self syncVisitsCount:db] + [self uploadVisitPhotosCount:db] + [self syncCheckInCount:db] + [self uploadCheckInPhotoCount:db] + [self syncCheckOutCount:db] + [self uploadCheckOutPhotoCount:db];
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
