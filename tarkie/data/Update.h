#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Update : NSObject

//COMPANY
+ (BOOL)usersLogout:(NSManagedObjectContext *)db;
+ (BOOL)employeesDeactivate:(NSManagedObjectContext *)db;
+ (BOOL)announcementsDeactivate:(NSManagedObjectContext *)db;

//STORES
+ (BOOL)storesDeactivate:(NSManagedObjectContext *)db;
+ (BOOL)storeContactsDeactivate:(NSManagedObjectContext *)db;

//ATTENDANCE
+ (BOOL)scheduleTimesDeactivate:(NSManagedObjectContext *)db;
+ (BOOL)schedulesDeactivate:(NSManagedObjectContext *)db;

//VISITS


//EXPENSE


//INVENTORY


//FORMS


+ (BOOL)save:(NSManagedObjectContext *)db;

@end
