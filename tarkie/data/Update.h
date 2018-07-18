#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

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

//VISITS


//EXPENSE


//INVENTORY


//FORMS


+ (BOOL)save:(NSManagedObjectContext *)db;

@end
