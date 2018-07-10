#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol ProcessDelegate
@optional

- (void)onProcessResult:(NSString *)action params:(NSDictionary *)params result:(NSDictionary *)result;

@end

@interface Process : NSObject<NSURLSessionDelegate>

@property (assign) id<ProcessDelegate> delegate;

- (void)authorize:(NSManagedObjectContext *)db params:(NSMutableDictionary *)params;
- (void)getCompany:(NSManagedObjectContext *)db;
- (void)login:(NSManagedObjectContext *)db params:(NSMutableDictionary *)params;
- (void)getEmployees:(NSManagedObjectContext *)db;
- (void)timeSecurity:(NSManagedObjectContext *)db;
- (void)updateMasterFile:(NSManagedObjectContext *)db isAttendance:(BOOL)isAttendance isVisits:(BOOL)isVisits isExpense:(BOOL)isExpense isInventory:(BOOL)isInventory isForms:(BOOL)isForms;
- (void)syncData:(NSManagedObjectContext *)db;
- (void)getSchedule:(NSManagedObjectContext *)db;
- (void)sendBackupData:(NSManagedObjectContext *)db;
- (void)start;
- (void)next;
- (long)tasksCount;

@end
