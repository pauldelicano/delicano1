#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Rx : NSObject

+ (BOOL)patches:(NSManagedObjectContext *)db delegate:(id)delegate;

//COMPANY
+ (BOOL)company:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)employees:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)settings:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)conventions:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)serverTime:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)syncBatchID:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)announcements:(NSManagedObjectContext *)db delegate:(id)delegate;

//STORE
+ (BOOL)stores:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)storeContacts:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)storeCustomFields:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)storeCustomFieldsPages:(NSManagedObjectContext *)db delegate:(id)delegate;

//ATTENDANCE
+ (BOOL)scheduleTimes:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)schedules:(NSManagedObjectContext *)db isToday:(BOOL)isToday delegate:(id)delegate;
+ (BOOL)breakTypes:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)overtimeReasons:(NSManagedObjectContext *)db delegate:(id)delegate;

//VISITS
+ (BOOL)visits:(NSManagedObjectContext *)db delegate:(id)delegate;

//EXPENSE
+ (BOOL)expenseTypeCategories:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (NSString *)expenseTypes:(NSManagedObjectContext *)db expenseTypeCategoryID:(int64_t)expenseTypeCategoryID delegate:(id)delegate;

//INVENTORY
+ (BOOL)inventories:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)inventoryBrands:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)inventoryCategories:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)inventoryDiscounts:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)inventoryFacingItems:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)inventoryOrders:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)inventoryPlanoGramTypes:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)inventoryPlanoGramItems:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)inventoryPullOutReasons:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)inventoryReasons:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)inventoryStoreAssign:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)inventorySubBrands:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)inventoryUOMs:(NSManagedObjectContext *)db delegate:(id)delegate;

//FORMS
+ (BOOL)forms:(NSManagedObjectContext *)db delegate:(id)delegate;
+ (BOOL)formFields:(NSManagedObjectContext *)db delegate:(id)delegate;

+ (void)isCanceled:(BOOL)canceled;

@end
