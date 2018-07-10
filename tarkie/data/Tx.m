#import "Tx.h"
#import "Http.h"

@implementation Tx

+ (NSURLSessionDataTask *)authorize:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"authorization-request";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)login:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"login";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)syncAnnouncementSeen:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"add-announcement-seen";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)syncStore:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"add-store";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)updateStore:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"edit-store";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)syncStoreContact:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"add-store-contact-person";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)updateStoreContact:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"edit-store-contact-person";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)syncSchedule:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"add-schedule";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)updateSchedule:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"edit-schedule";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)syncTimeIn:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"time-in";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)uploadTimeInPhoto:(id)delegate params:(NSDictionary *)params file:(NSString *)file {
    NSString *action = @"upload-time-in-photo";
    return [Http postFile:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_FILES, action] params:params file:file timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)syncTimeOut:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"time-out";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)uploadTimeOutPhoto:(id)delegate params:(NSDictionary *)params file:(NSString *)file {
    NSString *action = @"upload-time-out-photo";
    return [Http postFile:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_FILES, action] params:params file:file timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)uploadTimeOutSignature:(id)delegate params:(NSDictionary *)params file:(NSString *)file {
    NSString *action = @"upload-signature-photo";
    return [Http postFile:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_FILES, action] params:params file:file timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)syncVisit:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"add-itinerary-visit";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)updateVisit:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"edit-itinerary-visit";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)deleteVisit:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"delete-itinerary-visit";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)uploadVisitPhoto:(id)delegate params:(NSDictionary *)params file:(NSString *)file {
    NSString *action = @"upload-form-photo";
    return [Http postFile:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_FILES, action] params:params file:file timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)syncCheckIn:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"check-in";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)uploadCheckInPhoto:(id)delegate params:(NSDictionary *)params file:(NSString *)file {
    NSString *action = @"upload-check-in-out-photo";
    return [Http postFile:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_FILES, action] params:params file:file timeout:HTTP_TIMEOUT_RX];
}

+ (NSURLSessionDataTask *)syncCheckOut:(id)delegate params:(NSDictionary *)params {
    NSString *action = @"check-out";
    return [Http post:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_API, action] params:params timeout:HTTP_TIMEOUT_TX];
}

+ (NSURLSessionDataTask *)uploadCheckOutPhoto:(id)delegate params:(NSDictionary *)params file:(NSString *)file {
    NSString *action = @"upload-check-in-out-photo";
    return [Http postFile:delegate action:action url:[NSString stringWithFormat:@"%@%@", WEB_FILES, action] params:params file:file timeout:HTTP_TIMEOUT_RX];
}

@end
