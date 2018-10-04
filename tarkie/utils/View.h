#import <UIKit/UIKit.h>

@interface View : NSObject

+ (void)addChildViewController:(UIViewController *)parentViewController childViewController:(UIViewController *)childViewController animated:(BOOL)animated;
+ (void)removeChildViewController:(UIViewController *)childViewController animated:(BOOL)animated;
+ (void)scaleFontSize:(id)view;
+ (void)scaleViewSize:(UIView *)view;
+ (void)setCornerRadiusByWidth:(UIView *)view cornerRadius:(CGFloat)cornerRadius;
+ (void)setCornerRadiusByHeight:(UIView *)view cornerRadius:(CGFloat)cornerRadius;

@end
