#import "Time.h"

@implementation Time

+ (NSDate *)getDateFromString:(NSString *)string {
    NSDateFormatter *dateFormatter = NSDateFormatter.alloc.init;
    dateFormatter.dateFormat = [NSString stringWithFormat:@"%@ %@", DATE_FORMAT, TIME_FORMAT];
    return [dateFormatter dateFromString:string];
}

+ (NSString *)formatDate:(NSString *)format date:(NSDate *)date {
    NSDateFormatter *dateFormatter = NSDateFormatter.alloc.init;
    dateFormatter.dateFormat = format;
    return [dateFormatter stringFromDate:date];
}

@end
