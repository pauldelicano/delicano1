#import <Foundation/Foundation.h>

@interface Rx : NSObject

//COMPANY
+ (NSURLSessionDataTask *)company:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)employees:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)settings:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)conventions:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)alertTypes:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)serverTime:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)syncBatchID:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)announcements:(id)delegate params:(NSDictionary *)params;

//STORE
+ (NSURLSessionDataTask *)stores:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)storeContacts:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)storeCustomFields:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)storeCustomFieldsPages:(id)delegate params:(NSDictionary *)params;

//ATTENDANCE
+ (NSURLSessionDataTask *)scheduleTimes:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)schedules:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)breakTypes:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)overtimeReasons:(id)delegate params:(NSDictionary *)params;

//VISITS
+ (NSURLSessionDataTask *)visits:(id)delegate params:(NSDictionary *)params;

//EXPENSE
+ (NSURLSessionDataTask *)expenseTypeCategories:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)expenseTypes:(id)delegate params:(NSDictionary *)params;

//INVENTORY
+ (NSURLSessionDataTask *)inventories:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)inventoryBrands:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)inventoryCategories:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)inventoryDiscounts:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)inventoryFacingItems:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)inventoryOrders:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)inventoryPlanoGramTypes:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)inventoryPlanoGramItems:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)inventoryPullOutReasons:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)inventoryReasons:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)inventoryStoreAssign:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)inventorySubBrands:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)inventoryUOMs:(id)delegate params:(NSDictionary *)params;

//FORMS
+ (NSURLSessionDataTask *)forms:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)formFields:(id)delegate params:(NSDictionary *)params;

@end
