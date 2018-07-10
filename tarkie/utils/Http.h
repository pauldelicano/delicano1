#import <UIKit/UIKit.h>

@interface Http : NSObject

#define WEB_HOST @"https://www.app.tarkie.com/"
#define WEB_API @"https://www.app.tarkie.com/API/1.0/"
#define WEB_FILES @"https://www.app.tarkie.com/FILES/1.0/"

#define HTTP_TIMEOUT_RX 300
#define HTTP_TIMEOUT_TX 60

typedef enum {
    GET,
    POST,
    POST_FILE
} HTTP;

+ (NSURLSessionDataTask *)get:(id)delegate action:(NSString *)action url:(NSString *)url params:(NSDictionary *)params timeout:(int)timeout;
+ (NSURLSessionDataTask *)post:(id)delegate action:(NSString *)action url:(NSString *)url params:(NSDictionary *)params timeout:(int)timeout;
+ (NSURLSessionDataTask *)postFile:(id)delegate action:(NSString *)action url:(NSString *)url params:(NSDictionary *)params file:(NSString *)file timeout:(int)timeout;

@end
