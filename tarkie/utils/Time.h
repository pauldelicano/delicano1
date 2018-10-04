#import <Foundation/Foundation.h>

@interface Time : NSObject

#define DATE_FORMAT @"yyyy-MM-dd"
#define TIME_FORMAT @"HH:mm:ss"

+ (NSDate *)getDateFromString:(NSString *)string;
+ (NSDate *)getDateFromString:(NSString *)format string:(NSString *)string;
+ (NSString *)getFormattedDate:(NSString *)format date:(NSDate *)date;
+ (NSString *)formatDate:(NSString *)format date:(NSString *)date;
+ (NSString *)formatTime:(NSString *)format time:(NSString *)time;
+ (NSDate *)dateRemoveSeconds:(NSDate *)date;
+ (NSString *)secondsToHoursMinutes:(NSTimeInterval)seconds;
+ (time_t)getUptime;

@end
