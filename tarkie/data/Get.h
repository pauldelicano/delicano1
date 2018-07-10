#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Sequences+CoreDataClass.h"

#import "Device+CoreDataClass.h"
#import "Company+CoreDataClass.h"
#import "Modules+CoreDataClass.h"
#import "Users+CoreDataClass.h"
#import "Employees+CoreDataClass.h"
#import "Settings+CoreDataClass.h"
#import "SettingsTeams+CoreDataClass.h"
#import "Conventions+CoreDataClass.h"
#import "AlertTypes+CoreDataClass.h"
#import "TimeSecurity+CoreDataClass.h"
#import "SyncBatch+CoreDataClass.h"
#import "Announcements+CoreDataClass.h"
#import "AnnouncementSeen+CoreDataClass.h"

#import "Stores+CoreDataClass.h"
#import "StoreContacts+CoreDataClass.h"

#import "ScheduleTimes+CoreDataClass.h"
#import "Schedules+CoreDataClass.h"
#import "TimeIn+CoreDataClass.h"
#import "TimeOut+CoreDataClass.h"
#import "BreakTypes+CoreDataClass.h"
#import "OvertimeReasons+CoreDataClass.h"

#import "Visits+CoreDataClass.h"
#import "Photos+CoreDataClass.h"
#import "VisitInventories+CoreDataClass.h"
#import "VisitForms+CoreDataClass.h"
#import "VisitPhotos+CoreDataClass.h"
#import "CheckIn+CoreDataClass.h"
#import "CheckOut+CoreDataClass.h"

#import "GPS+CoreDataClass.h"

@interface Get : NSObject

+ (Sequences *)sequence:(NSManagedObjectContext *)db;

//COMPANY
+ (Device *)device:(NSManagedObjectContext *)db;
+ (NSString *)apiKey:(NSManagedObjectContext *)db;
+ (Company *)company:(NSManagedObjectContext *)db;
+ (Modules *)module:(NSManagedObjectContext *)db moduleID:(long)moduleID;
+ (BOOL)isModuleEnabled:(NSManagedObjectContext *)db moduleID:(long)moduleID;
+ (Users *)user:(NSManagedObjectContext *)db;
+ (long)userID:(NSManagedObjectContext *)db;
+ (Employees *)employee:(NSManagedObjectContext *)db employeeID:(long)employeeID;
+ (Settings *)setting:(NSManagedObjectContext *)db settingID:(long)settingID;
+ (SettingsTeams *)settingTeam:(NSManagedObjectContext *)db settingID:(long)settingID teamID:(long)teamID;
+ (BOOL)isSettingEnabled:(NSManagedObjectContext *)db settingID:(long)settingID teamID:(long)teamID;
+ (Conventions *)convention:(NSManagedObjectContext *)db conventionID:(long)conventionID;
+ (NSString *)conventionName:(NSManagedObjectContext *)db conventionID:(long)conventionID;
+ (AlertTypes *)alertType:(NSManagedObjectContext *)db alertTypeID:(long)alertTypeID;
+ (TimeSecurity *)timeSecurity:(NSManagedObjectContext *)db;
+ (SyncBatch *)syncBatch:(NSManagedObjectContext *)db;
+ (NSString *)syncBatchID:(NSManagedObjectContext *)db;
+ (Announcements *)announcement:(NSManagedObjectContext *)db announcementID:(long)announcementID;
+ (AnnouncementSeen *)announcementSeen:(NSManagedObjectContext *)db announcementID:(long)announcementID;
+ (long)unSeenAnnouncementsCount:(NSManagedObjectContext *)db;
+ (long)syncAnnouncementSeenCount:(NSManagedObjectContext *)db;

//STORES
+ (Stores *)store:(NSManagedObjectContext *)db storeID:(long)storeID;
+ (Stores *)store:(NSManagedObjectContext *)db webStoreID:(long)webStoreID;
+ (long)syncStoresCount:(NSManagedObjectContext *)db;
+ (StoreContacts *)storeContact:(NSManagedObjectContext *)db storeContactID:(long)storeContactID;
+ (StoreContacts *)storeContact:(NSManagedObjectContext *)db webStoreContactID:(long)webStoreContactID;
+ (long)syncStoreContactsCount:(NSManagedObjectContext *)db;

//ATTENDANCE
+ (ScheduleTimes *)scheduleTime:(NSManagedObjectContext *)db scheduleTimeID:(long)scheduleTimeID;
+ (Schedules *)schedule:(NSManagedObjectContext *)db scheduleID:(long)scheduleID;
+ (Schedules *)schedule:(NSManagedObjectContext *)db webScheduleID:(long)webScheduleID scheduleDate:(NSString *)scheduleDate;
+ (long)syncSchedulesCount:(NSManagedObjectContext *)db;
+ (TimeIn *)timeIn:(NSManagedObjectContext *)db;
+ (TimeIn *)timeIn:(NSManagedObjectContext *)db timeInID:(long)timeInID;
+ (BOOL)isTimeIn:(NSManagedObjectContext *)db;
+ (long)syncTimeInCount:(NSManagedObjectContext *)db;
+ (long)uploadTimeInPhotoCount:(NSManagedObjectContext *)db;
+ (TimeOut *)timeOut:(NSManagedObjectContext *)db timeInID:(long)timeInID;
+ (TimeOut *)timeOut:(NSManagedObjectContext *)db timeOutID:(long)timeOutID;
+ (BOOL)isTimeOut:(NSManagedObjectContext *)db timeInID:(long)timeInID;
+ (long)syncTimeOutCount:(NSManagedObjectContext *)db;
+ (long)uploadTimeOutPhotoCount:(NSManagedObjectContext *)db;
+ (long)uploadTimeOutSignatureCount:(NSManagedObjectContext *)db;
+ (BreakTypes *)breakType:(NSManagedObjectContext *)db breakTypeID:(long)breakTypeID;
+ (OvertimeReasons *)overtimeReason:(NSManagedObjectContext *)db overtimeReasonID:(long)overtimeReasonID;

//VISITS
+ (Photos *)photo:(NSManagedObjectContext *)db photoID:(long)photoID;
+ (long)uploadVisitPhotosCount:(NSManagedObjectContext *)db;
+ (Visits *)visit:(NSManagedObjectContext *)db visitID:(long)visitID;
+ (Visits *)visit:(NSManagedObjectContext *)db webVisitID:(long)webVisitID;
+ (long)syncVisitsCount:(NSManagedObjectContext *)db;
+ (VisitInventories *)visitInventory:(NSManagedObjectContext *)db visitID:(long)visitID inventoryID:(long)inventoryID;
+ (VisitForms *)visitForm:(NSManagedObjectContext *)db visitID:(long)visitID formID:(long)formID;
+ (CheckIn *)checkIn:(NSManagedObjectContext *)db timeInID:(long)timeInID;
+ (CheckIn *)checkIn:(NSManagedObjectContext *)db visitID:(long)visitID;
+ (CheckIn *)checkIn:(NSManagedObjectContext *)db checkInID:(long)checkInID;
+ (BOOL)isCheckIn:(NSManagedObjectContext *)db timeInID:(long)timeInID;
+ (long)syncCheckInCount:(NSManagedObjectContext *)db;
+ (long)uploadCheckInPhotoCount:(NSManagedObjectContext *)db;
+ (CheckOut *)checkOut:(NSManagedObjectContext *)db checkInID:(long)checkInID;
+ (CheckOut *)checkOut:(NSManagedObjectContext *)db checkOutID:(long)checkOutID;
+ (BOOL)isCheckOut:(NSManagedObjectContext *)db checkInID:(long)checkInID;
+ (long)syncCheckOutCount:(NSManagedObjectContext *)db;
+ (long)uploadCheckOutPhotoCount:(NSManagedObjectContext *)db;

//EXPENSE


//INVENTORY


//FORMS

+ (GPS *)gps:(NSManagedObjectContext *)db gpsID:(long)gpsID;
+ (long)syncTotalCount:(NSManagedObjectContext *)db;

@end
