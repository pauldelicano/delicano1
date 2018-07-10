#import <Foundation/Foundation.h>

@interface Time : NSObject

#define DATE_FORMAT @"yyyy-MM-dd"
#define TIME_FORMAT @"HH:mm:ss"

+ (NSDate *)getDateFromString:(NSString *)string;
+ (NSString *)formatDate:(NSString *)format date:(NSDate *)date;

@end
