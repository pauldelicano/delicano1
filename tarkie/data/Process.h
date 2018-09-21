#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol ProcessDelegate
@optional

- (void)onProcessResult:(NSString *)result;

@end

@interface Process : NSObject<NSURLSessionDelegate>

@property (assign) id<ProcessDelegate> delegate;
@property (nonatomic) long count;
@property (nonatomic) BOOL isCanceled;

- (void)authorize:(NSManagedObjectContext *)db params:(NSMutableDictionary *)params;
- (void)login:(NSManagedObjectContext *)db params:(NSMutableDictionary *)params;
- (void)timeSecurity:(NSManagedObjectContext *)db;
- (void)updateMasterFile:(NSManagedObjectContext *)db isAttendance:(BOOL)isAttendance isVisits:(BOOL)isVisits isExpense:(BOOL)isExpense isInventory:(BOOL)isInventory isForms:(BOOL)isForms;
- (void)patch:(NSManagedObjectContext *)db;
- (void)syncPatch:(NSManagedObjectContext *)db;
- (void)syncData:(NSManagedObjectContext *)db;
- (void)sendBackupData:(NSManagedObjectContext *)db;

@end
