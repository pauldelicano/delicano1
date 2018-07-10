#import <UIKit/UIKit.h>

@interface View : NSObject

+ (void)addSubview:(UIView *)view subview:(UIView *)subview animated:(BOOL)animated;
+ (void)removeView:(UIView *)view animated:(BOOL)animated;
+ (void)scaleFontSize:(id)view;
+ (void)scaleViewSize:(UIView *)view;
+ (void)setCornerRadiusByWidth:(UIView *)view cornerRadius:(CGFloat)cornerRadius;
+ (void)setCornerRadiusByHeight:(UIView *)view cornerRadius:(CGFloat)cornerRadius;

@end
