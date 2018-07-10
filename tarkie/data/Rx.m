#import "Rx.h"
#import "Http.h"

@implementation Rx

+ (NSURLSessionDataTask *)company:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-company";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)employees:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-employee-details";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)settings:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-settings";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)conventions:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-naming-convention";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)alertTypes:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-alert-types";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)serverTime:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-server-time";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)syncBatchID:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-sync-batch-id";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)announcements:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-announcements-for-app";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)stores:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-stores-for-app";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)storeContacts:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-store-contact-person-for-app";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)storeCustomFields:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-custom-field-data";//api_key, sync_date
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)storeCustomFieldsPages:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-custom-field-data-count";//api_key, sync_date
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)scheduleTimes:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-schedule-time";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)schedules:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-schedule";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)breakTypes:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-breaks";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)overtimeReasons:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-overtime-reasons";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)visits:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"get-itinerary";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)expenseTypeCategories:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)expenseTypes:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)inventories:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)inventoryBrands:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)inventoryCategories:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)inventoryDiscounts:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)inventoryFacingItems:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)inventoryOrders:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)inventoryPlanoGramTypes:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)inventoryPlanoGramItems:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)inventoryPullOutReasons:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)inventoryReasons:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)inventoryStoreAssign:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)inventorySubBrands:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)inventoryUOMs:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)forms:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)formFields:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"";
    return [Http get:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_RX];
}

@end
