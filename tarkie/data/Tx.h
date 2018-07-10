#import <Foundation/Foundation.h>

@interface Tx : NSObject

//COMPANY
+ (NSURLSessionDataTask *)authorize:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)login:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)syncAnnouncementSeen:(id)delegate params:(NSDictionary *)params;

//STORE
+ (NSURLSessionDataTask *)syncStore:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)updateStore:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)syncStoreContact:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)updateStoreContact:(id)delegate params:(NSDictionary *)params;

//ATTENDANCE
+ (NSURLSessionDataTask *)syncSchedule:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)updateSchedule:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)syncTimeIn:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)uploadTimeInPhoto:(id)delegate params:(NSDictionary *)params file:(NSString *)file;
+ (NSURLSessionDataTask *)syncTimeOut:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)uploadTimeOutPhoto:(id)delegate params:(NSDictionary *)params file:(NSString *)file;
+ (NSURLSessionDataTask *)uploadTimeOutSignature:(id)delegate params:(NSDictionary *)params file:(NSString *)file;

//VISITS
+ (NSURLSessionDataTask *)syncVisit:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)updateVisit:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)deleteVisit:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)uploadVisitPhoto:(id)delegate params:(NSDictionary *)params file:(NSString *)file;
+ (NSURLSessionDataTask *)syncCheckIn:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)uploadCheckInPhoto:(id)delegate params:(NSDictionary *)params file:(NSString *)file;
+ (NSURLSessionDataTask *)syncCheckOut:(id)delegate params:(NSDictionary *)params;
+ (NSURLSessionDataTask *)uploadCheckOutPhoto:(id)delegate params:(NSDictionary *)params file:(NSString *)file;

//EXPENSE


//INVENTORY


//FORMS


@end
