#import "Time.h"
#include <sys/sysctl.h>

@implementation Time

+ (NSDate *)getDateFromString:(NSString *)string {
    return [self getDateFromString:[NSString stringWithFormat:@"%@ %@", DATE_FORMAT, TIME_FORMAT] string:string];
}

+ (NSDate *)getDateFromString:(NSString *)format string:(NSString *)string {
    NSDateFormatter *dateFormatter = NSDateFormatter.alloc.init;
    dateFormatter.dateFormat = format;
    return [dateFormatter dateFromString:string];
}

+ (NSString *)getFormattedDate:(NSString *)format date:(NSDate *)date {
    NSDateFormatter *dateFormatter = NSDateFormatter.alloc.init;
    dateFormatter.locale = [NSLocale.alloc initWithLocaleIdentifier:@"en_US_POSIX"];
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

+ (NSDate *)dateRemoveSeconds:(NSDate *)date {
    return [NSDate dateWithTimeIntervalSinceReferenceDate:floor([date timeIntervalSinceReferenceDate] / 60.0) * 60.0];
}

+ (NSString *)secondsToDHMS:(NSTimeInterval)totalSeconds {
    if(totalSeconds < 1) {
        return @"0s";
    }
    int days = totalSeconds / 86400;
    totalSeconds -= days * 86400;
    int hours = totalSeconds / 3600;
    totalSeconds -= hours * 3600;
    int minutes = totalSeconds / 60;
    totalSeconds -= minutes * 60;
    int seconds = totalSeconds;
    return [[NSString stringWithFormat:@"%@%@%@%@", days > 0 ? [NSString stringWithFormat:@" %dd", days] : @"", hours > 0 ? [NSString stringWithFormat:@" %dh", hours] : @"", minutes > 0 ? [NSString stringWithFormat:@" %dm", minutes] : @"", seconds > 0 ? [NSString stringWithFormat:@" %ds", seconds] : @""] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (time_t)getUptime {
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    time_t now;
    time_t uptime = -1;
    (void)time(&now);
    if(sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
        uptime = now - boottime.tv_sec;
    }
    return uptime;
}

@end
