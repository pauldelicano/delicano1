#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Patches+CoreDataClass.h"
#import "Alerts+CoreDataClass.h"
#import "AnnouncementSeen+CoreDataClass.h"

#import "Stores+CoreDataClass.h"
#import "StoreContacts+CoreDataClass.h"

#import "Schedules+CoreDataClass.h"
#import "TimeIn+CoreDataClass.h"
#import "TimeOut+CoreDataClass.h"
#import "BreakIn+CoreDataClass.h"
#import "BreakOut+CoreDataClass.h"
#import "Overtime+CoreDataClass.h"
#import "Tracking+CoreDataClass.h"

#import "Photos+CoreDataClass.h"
#import "Visits+CoreDataClass.h"
#import "CheckIn+CoreDataClass.h"
#import "CheckOut+CoreDataClass.h"

@interface Tx : NSObject

+ (BOOL)authorize:(NSManagedObjectContext *)db params:(NSDictionary *)params delegate:(id)delegate;
+ (BOOL)login:(NSManagedObjectContext *)db params:(NSDictionary *)params delegate:(id)delegate;
+ (BOOL)sendBackupData:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)patchData:(NSManagedObjectContext *)db patch:(Patches *)patch delegate:(id)delegate;
+ (BOOL)syncAlert:(NSManagedObjectContext *)db alert:(Alerts *)alert delegate:(id)delegate;
+ (BOOL)syncAnnouncementSeen:(NSManagedObjectContext *)db announcementSeen:(AnnouncementSeen *)announcementSeen delegate:(id)delegate;

//STORE
+ (BOOL)syncStore:(NSManagedObjectContext *)db store:(Stores *)store delegate:(id)delegate;
+ (BOOL)updateStore:(NSManagedObjectContext *)db store:(Stores *)store delegate:(id)delegate;
+ (BOOL)syncStoreContact:(NSManagedObjectContext *)db storeContact:(StoreContacts *)storeContact delegate:(id)delegate;
+ (BOOL)updateStoreContact:(NSManagedObjectContext *)db storeContact:(StoreContacts *)storeContact delegate:(id)delegate;

//ATTENDANCE
+ (BOOL)syncSchedule:(NSManagedObjectContext *)db schedule:(Schedules *)schedule delegate:(id)delegate;
+ (BOOL)updateSchedule:(NSManagedObjectContext *)db schedule:(Schedules *)schedule delegate:(id)delegate;
+ (BOOL)syncTimeIn:(NSManagedObjectContext *)db timeIn:(TimeIn *)timeIn delegate:(id)delegate;
+ (BOOL)uploadTimeInPhoto:(NSManagedObjectContext *)db timeIn:(TimeIn *)timeIn delegate:(id)delegate;
+ (BOOL)syncTimeOut:(NSManagedObjectContext *)db timeOut:(TimeOut *)timeOut delegate:(id)delegate;
+ (BOOL)uploadTimeOutPhoto:(NSManagedObjectContext *)db timeOut:(TimeOut *)timeOut delegate:(id)delegate;
+ (BOOL)uploadTimeOutSignature:(NSManagedObjectContext *)db timeOut:(TimeOut *)timeOut delegate:(id)delegate;
+ (BOOL)syncBreakIn:(NSManagedObjectContext *)db breakIn:(BreakIn *)breakIn delegate:(id)delegate;
+ (BOOL)syncBreakOut:(NSManagedObjectContext *)db breakOut:(BreakOut *)breakOut delegate:(id)delegate;
+ (BOOL)syncOvertime:(NSManagedObjectContext *)db overtime:(Overtime *)overtime delegate:(id)delegate;
+ (BOOL)syncTracking:(NSManagedObjectContext *)db tracking:(Tracking *)tracking delegate:(id)delegate;

//VISITS
+ (BOOL)uploadVisitPhoto:(NSManagedObjectContext *)db photo:(Photos *)photo delegate:(id)delegate;
+ (BOOL)syncVisit:(NSManagedObjectContext *)db visit:(Visits *)visit delegate:(id)delegate;
+ (BOOL)updateVisit:(NSManagedObjectContext *)db visit:(Visits *)visit delegate:(id)delegate;
+ (BOOL)deleteVisit:(NSManagedObjectContext *)db visit:(Visits *)visit delegate:(id)delegate;
+ (BOOL)syncCheckIn:(NSManagedObjectContext *)db checkIn:(CheckIn *)checkIn delegate:(id)delegate;
+ (BOOL)uploadCheckInPhoto:(NSManagedObjectContext *)db checkIn:(CheckIn *)checkIn delegate:(id)delegate;
+ (BOOL)syncCheckOut:(NSManagedObjectContext *)db checkOut:(CheckOut *)checkOut delegate:(id)delegate;
+ (BOOL)uploadCheckOutPhoto:(NSManagedObjectContext *)db checkOut:(CheckOut *)checkOut delegate:(id)delegate;

//EXPENSE


//INVENTORY


//FORMS


+ (void)isCanceled:(BOOL)canceled;

@end
