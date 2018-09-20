#import "Color.h"

@implementation Color

+ (UIColor *)colorNamed:(NSString *)color {
    if(@available(iOS 11.0, *)) {
        return [UIColor colorNamed:color];
    }
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    if([color isEqualToString:@"ThemePri.sevie"]) {
        red = 0.118;
        green = 0.533;
        blue = 0.898;
        alpha = 1;
    }
    if([color isEqualToString:@"ThemePri.timsie"]) {
        red = 0;
        green = 0.592;
        blue = 0.655;
        alpha = 1;
    }
    if([color isEqualToString:@"ThemeSec.sevie"]) {
        red = 0.298;
        green = 0.686;
        blue = 0.314;
        alpha = 1;
    }
    if([color isEqualToString:@"ThemeSec.timsie"]) {
        red = 0.545;
        green = 0.765;
        blue = 0.29;
        alpha = 1;
    }
    if([color isEqualToString:@"ThemePriDark.sevie"]) {
        red = 0.098;
        green = 0.463;
        blue = 0.824;
        alpha = 1;
    }
    if([color isEqualToString:@"ThemePriDark.timsie"]) {
        red = 0;
        green = 0.514;
        blue = 0.561;
        alpha = 1;
    }
    if([color isEqualToString:@"BlackTransThirty"]) {
        red = 0;
        green = 0;
        blue = 0;
        alpha = 0.3;
    }
    if([color isEqualToString:@"BlackTransSixty"]) {
        red = 0;
        green = 0;
        blue = 0;
        alpha = 0.6;
    }
    if([color isEqualToString:@"Grey200"]) {
        red = 0.933;
        green = 0.933;
        blue = 0.933;
        alpha = 1;
    }
    if([color isEqualToString:@"Grey500"]) {
        red = 0.620;
        green = 0.620;
        blue = 0.620;
        alpha = 1;
    }
    if([color isEqualToString:@"Grey600"]) {
        red = 0.459;
        green = 0.459;
        blue = 0.459;
        alpha = 1;
    }
    if([color isEqualToString:@"Grey700"]) {
        red = 0.380;
        green = 0.380;
        blue = 0.380;
        alpha = 1;
    }
    if([color isEqualToString:@"Grey800"]) {
        red = 0.259;
        green = 0.259;
        blue = 0.259;
        alpha = 1;
    }
    if([color isEqualToString:@"Red700"]) {
        red = 0.827;
        green = 0.184;
        blue = 0.184;
        alpha = 1;
    }
    if([color isEqualToString:@"WhiteTransSixty"]) {
        red = 1;
        green = 1;
        blue = 1;
        alpha = 0.6;
    }
    if([color isEqualToString:@"Yellow100"]) {
        red = 1;
        green = 0.976;
        blue = 0.769;
        alpha = 1;
    }
    if([color isEqualToString:@"Yellow800"]) {
        red = 0.976;
        green = 0.659;
        blue = 0.145;
        alpha = 1;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
