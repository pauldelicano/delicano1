#import "Time.h"

@implementation Time

+ (NSDate *)getDateFromString:(NSString *)string {
    NSDateFormatter *dateFormatter = NSDateFormatter.alloc.init;
    dateFormatter.dateFormat = [NSString stringWithFormat:@"%@ %@", DATE_FORMAT, TIME_FORMAT];
    return [dateFormatter dateFromString:string];
}

+ (NSString *)getFormattedDate:(NSString *)format date:(NSDate *)date {
    NSDateFormatter *dateFormatter = NSDateFormatter.alloc.init;
    dateFormatter.dateFormat = format;
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)formatDate:(NSString *)format date:(NSString *)date {
    NSDateFormatter *dateFormatter = NSDateFormatter.alloc.init;
    dateFormatter.dateFormat = DATE_FORMAT;
    return [self getFormattedDate:format date:[dateFormatter dateFromString:date]];
}

+ (NSString *)formatTime:(NSString *)format time:(NSString *)time {
    NSDateFormatter *dateFormatter = NSDateFormatter.alloc.init;
    dateFormatter.dateFormat = TIME_FORMAT;
    return [self getFormattedDate:format date:[dateFormatter dateFromString:time]];
}

@end
