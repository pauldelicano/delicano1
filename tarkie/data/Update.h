#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@interface Update : NSObject

+ (BOOL)usersLogout:(NSManagedObjectContext *)db;
+ (void)employeesDeactivate:(NSManagedObjectContext *)db;
+ (int64_t)gpsSave:(NSManagedObjectContext *)db dbAlerts:(NSManagedObjectContext *)dbAlerts location:(CLLocation *)location;
+ (BOOL)alertSave:(NSManagedObjectContext *)db alertTypeID:(int64_t)alertTypeID gpsID:(int64_t)gpsID value:(NSString *)value;
+ (void)announcementsDeactivate:(NSManagedObjectContext *)db;

//STORES
+ (void)storesDeactivate:(NSManagedObjectContext *)db;
+ (void)storeContactsDeactivate:(NSManagedObjectContext *)db;

//ATTENDANCE
+ (void)scheduleTimesDeactivate:(NSManagedObjectContext *)db;
+ (void)schedulesDeactivate:(NSManagedObjectContext *)db;
+ (void)breakTypesDeactivate:(NSManagedObjectContext *)db;
+ (void)overtimeReasonsDeactivate:(NSManagedObjectContext *)db;

//VISITS


//EXPENSE
+ (void)expenseTypeCategoriesDeactivate:(NSManagedObjectContext *)db;
+ (void)expenseTypesDeactivate:(NSManagedObjectContext *)db expenseTypeCategoryID:(int64_t)expenseTypeCategoryID;


//INVENTORY


//FORMS


+ (BOOL)save:(NSManagedObjectContext *)db;

@end
