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
    POST_IMAGE,
    POST_FILE
} HTTP;

+ (NSDictionary *)get:(NSString *)url params:(NSDictionary *)params timeout:(int)timeout;
+ (NSDictionary *)post:(NSString *)url params:(NSDictionary *)params timeout:(int)timeout;
+ (NSDictionary *)postImage:(NSString *)url params:(NSDictionary *)params image:(NSString *)image timeout:(int)timeout;
+ (NSDictionary *)postFile:(NSString *)url params:(NSDictionary *)params file:(NSString *)file timeout:(int)timeout;

@end
