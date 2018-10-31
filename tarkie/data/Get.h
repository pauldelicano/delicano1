#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Device+CoreDataClass.h"
#import "Company+CoreDataClass.h"
#import "Modules+CoreDataClass.h"
#import "Users+CoreDataClass.h"
#import "Employees+CoreDataClass.h"
#import "Settings+CoreDataClass.h"
#import "SettingsTeams+CoreDataClass.h"
#import "Conventions+CoreDataClass.h"
#import "TimeSecurity+CoreDataClass.h"
#import "SyncBatch+CoreDataClass.h"
#import "Patches+CoreDataClass.h"
#import "GPS+CoreDataClass.h"
#import "Alerts+CoreDataClass.h"
#import "Announcements+CoreDataClass.h"
#import "AnnouncementSeen+CoreDataClass.h"

#import "Stores+CoreDataClass.h"
#import "StoreContacts+CoreDataClass.h"

#import "ScheduleTimes+CoreDataClass.h"
#import "Schedules+CoreDataClass.h"
#import "TimeIn+CoreDataClass.h"
#import "TimeOut+CoreDataClass.h"
#import "BreakTypes+CoreDataClass.h"
#import "BreakIn+CoreDataClass.h"
#import "BreakOut+CoreDataClass.h"
#import "OvertimeReasons+CoreDataClass.h"
#import "Overtime+CoreDataClass.h"
#import "Tracking+CoreDataClass.h"

#import "Photos+CoreDataClass.h"
#import "Visits+CoreDataClass.h"
#import "VisitInventories+CoreDataClass.h"
#import "VisitForms+CoreDataClass.h"
#import "VisitPhotos+CoreDataClass.h"
#import "CheckIn+CoreDataClass.h"
#import "CheckOut+CoreDataClass.h"

#import "ExpenseTypes+CoreDataClass.h"
#import "ExpenseTypeCategories+CoreDataClass.h"
#import "Expense+CoreDataClass.h"
#import "ExpenseDefault+CoreDataClass.h"
#import "ExpenseFuelConsumption+CoreDataClass.h"
#import "ExpenseFuelPurchase+CoreDataClass.h"
#import "ExpenseReports+CoreDataClass.h"

@interface Get : NSObject

+ (int64_t)sequenceID:(NSManagedObjectContext *)db entity:(NSString *)entity attribute:(NSString *)attribute;

+ (Device *)device:(NSManagedObjectContext *)db;
+ (NSString *)apiKey:(NSManagedObjectContext *)db;
+ (Company *)company:(NSManagedObjectContext *)db;
+ (Modules *)module:(NSManagedObjectContext *)db moduleID:(int64_t)moduleID;
+ (BOOL)isModuleEnabled:(NSManagedObjectContext *)db moduleID:(int64_t)moduleID;
+ (Users *)user:(NSManagedObjectContext *)db;
+ (int64_t)userID:(NSManagedObjectContext *)db;
+ (Employees *)employee:(NSManagedObjectContext *)db employeeID:(int64_t)employeeID;
+ (int64_t)teamID:(NSManagedObjectContext *)db employeeID:(int64_t)employeeID;
+ (Settings *)setting:(NSManagedObjectContext *)db settingID:(int64_t)settingID;
+ (int64_t)settingID:(NSManagedObjectContext *)db settingName:(NSString *)settingName;
+ (SettingsTeams *)settingTeam:(NSManagedObjectContext *)db settingID:(int64_t)settingID teamID:(int64_t)teamID;
+ (BOOL)isSettingEnabled:(NSManagedObjectContext *)db settingID:(int64_t)settingID teamID:(int64_t)teamID;
+ (NSString *)settingCurrencyCode:(NSManagedObjectContext *)db teamID:(int64_t)teamID;
+ (NSString *)settingCurrencySymbol:(NSManagedObjectContext *)db teamID:(int64_t)teamID;
+ (NSString *)settingDateFormat:(NSManagedObjectContext *)db teamID:(int64_t)teamID;
+ (NSString *)settingTimeFormat:(NSManagedObjectContext *)db teamID:(int64_t)teamID;
+ (Conventions *)convention:(NSManagedObjectContext *)db conventionID:(int64_t)conventionID;
+ (NSString *)conventionName:(NSManagedObjectContext *)db conventionID:(int64_t)conventionID;
+ (TimeSecurity *)timeSecurity:(NSManagedObjectContext *)db;
+ (SyncBatch *)syncBatch:(NSManagedObjectContext *)db;
+ (Patches *)patch:(NSManagedObjectContext *)db patchID:(int64_t)patchID;
+ (long)syncPatchesCount:(NSManagedObjectContext *)db;
+ (GPS *)gps:(NSManagedObjectContext *)db gpsID:(int64_t)gpsID;
+ (Alerts *)alert:(NSManagedObjectContext *)db alertTypeID:(int64_t)alertTypeID;
+ (long)syncAlertsCount:(NSManagedObjectContext *)db;
+ (Announcements *)announcement:(NSManagedObjectContext *)db announcementID:(int64_t)announcementID;
+ (AnnouncementSeen *)announcementSeen:(NSManagedObjectContext *)db announcementID:(int64_t)announcementID;
+ (long)unSeenAnnouncementsCount:(NSManagedObjectContext *)db;
+ (long)syncAnnouncementSeenCount:(NSManagedObjectContext *)db;

//STORES
+ (Stores *)store:(NSManagedObjectContext *)db webStoreID:(int64_t)webStoreID;
+ (Stores *)store:(NSManagedObjectContext *)db storeID:(int64_t)storeID;
+ (long)syncStoresCount:(NSManagedObjectContext *)db;
+ (StoreContacts *)storeContact:(NSManagedObjectContext *)db webStoreContactID:(int64_t)webStoreContactID;
+ (StoreContacts *)storeContact:(NSManagedObjectContext *)db storeContactID:(int64_t)storeContactID;
+ (long)syncStoreContactsCount:(NSManagedObjectContext *)db;

//ATTENDANCE
+ (ScheduleTimes *)scheduleTime:(NSManagedObjectContext *)db scheduleTimeID:(int64_t)scheduleTimeID;
+ (Schedules *)schedule:(NSManagedObjectContext *)db webScheduleID:(int64_t)webScheduleID scheduleDate:(NSString *)scheduleDate;
+ (Schedules *)schedule:(NSManagedObjectContext *)db scheduleID:(int64_t)scheduleID;
+ (long)syncSchedulesCount:(NSManagedObjectContext *)db;
+ (TimeIn *)timeIn:(NSManagedObjectContext *)db;
+ (TimeIn *)timeIn:(NSManagedObjectContext *)db timeInID:(int64_t)timeInID;
+ (BOOL)isTimeIn:(NSManagedObjectContext *)db;
+ (long)timeInCount:(NSManagedObjectContext *)db date:(NSString *)date;
+ (long)syncTimeInCount:(NSManagedObjectContext *)db;
+ (long)uploadTimeInPhotoCount:(NSManagedObjectContext *)db;
+ (TimeOut *)timeOut:(NSManagedObjectContext *)db timeInID:(int64_t)timeInID;
+ (TimeOut *)timeOut:(NSManagedObjectContext *)db timeOutID:(int64_t)timeOutID;
+ (BOOL)isTimeOut:(NSManagedObjectContext *)db timeInID:(int64_t)timeInID;
+ (long)syncTimeOutCount:(NSManagedObjectContext *)db;
+ (long)uploadTimeOutPhotoCount:(NSManagedObjectContext *)db;
+ (long)uploadTimeOutSignatureCount:(NSManagedObjectContext *)db;
+ (BreakTypes *)breakType:(NSManagedObjectContext *)db breakTypeID:(int64_t)breakTypeID;
+ (BreakIn *)breakIn:(NSManagedObjectContext *)db timeInID:(int64_t)timeInID;
+ (BreakIn *)breakIn:(NSManagedObjectContext *)db timeInID:(int64_t)timeInID breakTypeID:(int64_t)breakTypeID;
+ (BreakIn *)breakIn:(NSManagedObjectContext *)db breakInID:(int64_t)breakInID;
+ (long)syncBreakInCount:(NSManagedObjectContext *)db;
+ (BreakOut *)breakOut:(NSManagedObjectContext *)db breakInID:(int64_t)breakInID;
+ (BreakOut *)breakOut:(NSManagedObjectContext *)db breakOutID:(int64_t)breakOutID;
+ (long)syncBreakOutCount:(NSManagedObjectContext *)db;
+ (OvertimeReasons *)overtimeReason:(NSManagedObjectContext *)db overtimeReasonID:(int64_t)overtimeReasonID;
+ (long)syncOvertimeCount:(NSManagedObjectContext *)db;
+ (long)syncTrackingCount:(NSManagedObjectContext *)db;

//VISITS
+ (Photos *)photo:(NSManagedObjectContext *)db photoID:(int64_t)photoID;
+ (long)uploadVisitPhotosCount:(NSManagedObjectContext *)db;
+ (Visits *)visit:(NSManagedObjectContext *)db visitID:(int64_t)visitID;
+ (Visits *)visit:(NSManagedObjectContext *)db webVisitID:(int64_t)webVisitID;
+ (long)visitTodayCount:(NSManagedObjectContext *)db date:(NSString *)date;
+ (long)syncVisitsCount:(NSManagedObjectContext *)db;
+ (VisitInventories *)visitInventory:(NSManagedObjectContext *)db visitID:(int64_t)visitID inventoryID:(int64_t)inventoryID;
+ (VisitForms *)visitForm:(NSManagedObjectContext *)db visitID:(int64_t)visitID formID:(int64_t)formID;
+ (CheckIn *)checkIn:(NSManagedObjectContext *)db;
+ (CheckIn *)checkIn:(NSManagedObjectContext *)db visitID:(int64_t)visitID;
+ (CheckIn *)checkIn:(NSManagedObjectContext *)db checkInID:(int64_t)checkInID;
+ (BOOL)isCheckIn:(NSManagedObjectContext *)db;
+ (long)syncCheckInCount:(NSManagedObjectContext *)db;
+ (long)uploadCheckInPhotoCount:(NSManagedObjectContext *)db;
+ (CheckOut *)checkOut:(NSManagedObjectContext *)db checkInID:(int64_t)checkInID;
+ (long)syncCheckOutCount:(NSManagedObjectContext *)db;
+ (long)uploadCheckOutPhotoCount:(NSManagedObjectContext *)db;

//EXPENSE
+ (long)expenseTypeCategoriesCount:(NSManagedObjectContext *)db;
+ (ExpenseTypeCategories *)expenseTypeCategory:(NSManagedObjectContext *)db expenseTypeCategoryID:(int64_t)expenseTypeCategoryID;
+ (ExpenseTypes *)expenseType:(NSManagedObjectContext *)db expenseTypeID:(int64_t)expenseTypeID;
+ (Expense *)expense:(NSManagedObjectContext *)db expenseID:(int64_t)expenseID;
+ (ExpenseFuelConsumption *)expenseFuelConsumption:(NSManagedObjectContext *)db expenseID:(int64_t)expenseID;
+ (ExpenseFuelPurchase *)expenseFuelPurchase:(NSManagedObjectContext *)db expenseID:(int64_t)expenseID;
+ (ExpenseDefault *)expenseDefault:(NSManagedObjectContext *)db expenseID:(int64_t)expenseID;
+ (long)expenseTodayCount:(NSManagedObjectContext *)db date:(NSString *)date withoutDeleted:(BOOL)withoutDeleted;
+ (long)syncExpenseCount:(NSManagedObjectContext *)db;
+ (long)updateExpenseCount:(NSManagedObjectContext *)db;
+ (long)deleteExpenseCount:(NSManagedObjectContext *)db;
+ (BOOL)isExpenseItemTagged:(NSManagedObjectContext *)db date:(NSString *)date;

//INVENTORY


//FORMS


+ (long)syncTotalCount:(NSManagedObjectContext *)db;

@end
