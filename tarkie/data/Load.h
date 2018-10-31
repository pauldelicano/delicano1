#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "Employees+CoreDataClass.h"
#import "Patches+CoreDataClass.h"
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
#import "CheckIn+CoreDataClass.h"
#import "CheckOut+CoreDataClass.h"

#import "ExpenseTypeCategories+CoreDataClass.h"
#import "ExpenseTypes+CoreDataClass.h"
#import "Expense+CoreDataClass.h"
#import "ExpenseReports+CoreDataClass.h"

#import "Inventories+CoreDataClass.h"

#import "Forms+CoreDataClass.h"

@interface Load : NSObject

+ (NSArray<NSDictionary *> *)drawerMenus:(NSManagedObjectContext *)db;
+ (NSArray<NSDictionary *> *)modulePages:(NSManagedObjectContext *)db;
+ (NSArray<Employees *> *)employeeIDs:(NSManagedObjectContext *)db teamID:(int64_t)teamID;
+ (NSArray<Patches *> *)patches:(NSManagedObjectContext *)db;
+ (NSArray<Patches *> *)syncPatches:(NSManagedObjectContext *)db;
+ (NSArray<Alerts *> *)syncAlerts:(NSManagedObjectContext *)db;
+ (NSArray<Announcements *> *)announcements:(NSManagedObjectContext *)db searchFilter:(NSString *)searchFilter isScheduled:(BOOL)isScheduled;
+ (NSArray<AnnouncementSeen *> *)syncAnnouncementSeen:(NSManagedObjectContext *)db;

//STORES
+ (NSArray<Stores *> *)stores:(NSManagedObjectContext *)db searchFilter:(NSString *)searchFilter;
+ (NSArray<Stores *> *)syncStores:(NSManagedObjectContext *)db;
+ (NSArray<Stores *> *)updateStores:(NSManagedObjectContext *)db;
+ (NSArray<StoreContacts *> *)storeContacts:(NSManagedObjectContext *)db storeID:(int64_t)storeID;
+ (NSArray<StoreContacts *> *)syncStoreContacts:(NSManagedObjectContext *)db;
+ (NSArray<StoreContacts *> *)updateStoreContacts:(NSManagedObjectContext *)db;

//ATTENDANCE
+ (NSArray<ScheduleTimes *> *)scheduleTimes:(NSManagedObjectContext *)db;
+ (NSArray<Schedules *> *)syncSchedules:(NSManagedObjectContext *)db;
+ (NSArray<Schedules *> *)updateSchedules:(NSManagedObjectContext *)db;
+ (NSArray<TimeIn *> *)timeIn:(NSManagedObjectContext *)db date:(NSString *)date;
+ (NSArray<TimeIn *> *)syncTimeIn:(NSManagedObjectContext *)db;
+ (NSArray<TimeIn *> *)uploadTimeInPhoto:(NSManagedObjectContext *)db;
+ (NSArray<TimeOut *> *)syncTimeOut:(NSManagedObjectContext *)db;
+ (NSArray<TimeOut *> *)uploadTimeOutPhoto:(NSManagedObjectContext *)db;
+ (NSArray<TimeOut *> *)uploadTimeOutSignature:(NSManagedObjectContext *)db;
+ (NSArray<BreakTypes *> *)breakTypes:(NSManagedObjectContext *)db;
+ (NSArray<BreakIn *> *)breakIn:(NSManagedObjectContext *)db timeInID:(int64_t)timeInID;
+ (NSArray<BreakIn *> *)syncBreakIn:(NSManagedObjectContext *)db;
+ (NSArray<BreakOut *> *)syncBreakOut:(NSManagedObjectContext *)db;
+ (NSArray<OvertimeReasons *> *)overtimeReasons:(NSManagedObjectContext *)db;
+ (NSArray<Overtime *> *)syncOvertime:(NSManagedObjectContext *)db;
+ (NSArray<Tracking *> *)syncTracking:(NSManagedObjectContext *)db;
+ (NSArray<NSDictionary *> *)activities:(NSManagedObjectContext *)db date:(NSString *)date;

//VISITS
+ (NSArray<Photos *> *)visitPhotos:(NSManagedObjectContext *)db visitID:(int64_t)visitID;
+ (NSArray<Photos *> *)uploadVisitPhotos:(NSManagedObjectContext *)db;
+ (NSArray<Visits *> *)visits:(NSManagedObjectContext *)db date:(NSString *)date isNoCheckOutOnly:(BOOL)isNoCheckOutOnly;
+ (NSArray<Visits *> *)syncVisits:(NSManagedObjectContext *)db;
+ (NSArray<Visits *> *)updateVisits:(NSManagedObjectContext *)db;
+ (NSArray<Visits *> *)deleteVisits:(NSManagedObjectContext *)db;
+ (NSArray<VisitInventories *> *)visitInventories:(NSManagedObjectContext *)db visitID:(int64_t)visitID;
+ (NSArray<VisitForms *> *)visitForms:(NSManagedObjectContext *)db visitID:(int64_t)visitID;
+ (NSArray<CheckIn *> *)syncCheckIn:(NSManagedObjectContext *)db;
+ (NSArray<CheckIn *> *)uploadCheckInPhoto:(NSManagedObjectContext *)db;
+ (NSArray<CheckOut *> *)syncCheckOut:(NSManagedObjectContext *)db;
+ (NSArray<CheckOut *> *)uploadCheckOutPhoto:(NSManagedObjectContext *)db;

//EXPENSE
+ (NSArray<ExpenseTypeCategories *> *)expenseTypeCategories:(NSManagedObjectContext *)db;
+ (NSArray<ExpenseTypes *> *)expenseTypes:(NSManagedObjectContext *)db;
+ (NSArray<NSMutableDictionary *> *)expenseItems:(NSManagedObjectContext *)db startDate:(NSString *)startDate endDate:(NSString *)endDate;
+ (NSArray<Expense *> *)expense:(NSManagedObjectContext *)db date:(NSString *)date;
+ (NSArray<ExpenseReports *> *)expenseReports:(NSManagedObjectContext *)db searchFilter:(NSString *)searchFilter;
+ (NSArray<Expense *> *)syncExpenses:(NSManagedObjectContext *)db;
+ (NSArray<Expense *> *)updateExpenses:(NSManagedObjectContext *)db;
+ (NSArray<Expense *> *)deleteExpenses:(NSManagedObjectContext *)db;

//INVENTORY
+ (NSArray<Inventories *> *)inventories:(NSManagedObjectContext *)db date:(NSString *)date;

//FORMS
+ (NSArray<Forms *> *)forms:(NSManagedObjectContext *)db date:(NSString *)date;

@end
