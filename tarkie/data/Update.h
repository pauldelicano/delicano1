#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@interface Update : NSObject

//COMPANY
+ (BOOL)usersLogout:(NSManagedObjectContext *)db;
+ (void)employeesDeactivate:(NSManagedObjectContext *)db;
+ (void)announcementsDeactivate:(NSManagedObjectContext *)db;

//STORES
+ (void)storesDeactivate:(NSManagedObjectContext *)db;
+ (void)storeContactsDeactivate:(NSManagedObjectContext *)db;

//ATTENDANCE
+ (void)scheduleTimesDeactivate:(NSManagedObjectContext *)db;
+ (void)schedulesDeactivate:(NSManagedObjectContext *)db;
+ (void)overtimeReasonsDeactivate:(NSManagedObjectContext *)db;

//VISITS


//EXPENSE


//INVENTORY


//FORMS

+ (int64_t)gpsSave:(NSManagedObjectContext *)db location:(CLLocation *)location;

+ (BOOL)save:(NSManagedObjectContext *)db;

@end
