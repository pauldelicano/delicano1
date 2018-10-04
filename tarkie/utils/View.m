#import "View.h"

@implementation View

+ (void)addChildViewController:(UIViewController *)parentViewController childViewController:(UIViewController *)childViewController animated:(BOOL)animated {
    [parentViewController addChildViewController:childViewController];
    [parentViewController.view addSubview:childViewController.view];
    [parentViewController.view bringSubviewToFront:childViewController.view];
    childViewController.view.alpha = 0;
    [UIView animateWithDuration:animated ? 0.25 : 0.125 animations:^{
        childViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

+ (void)removeChildViewController:(UIViewController *)childViewController animated:(BOOL)animated {
    childViewController.view.alpha = 1;
    [UIView animateWithDuration:animated ? 0.25 : 0.125 animations:^{
        childViewController.view.alpha = 0;
    } completion:^(BOOL finished) {
        [childViewController.view removeFromSuperview];
        [childViewController removeFromParentViewController];
    }];
}

+ (void)scaleFontSize:(id)view {
    UILabel *label = (UILabel *)view;
    label.font = [UIFont fontWithName:label.font.fontName size:(label.font.pointSize / 568) * UIScreen.mainScreen.bounds.size.height];
}

+ (void)scaleViewSize:(UIView *)view {
    CGFloat baseHeight = 568;
    CGFloat height = UIScreen.mainScreen.bounds.size.height;
    if([view isKindOfClass:UIButton.class]) {
        UIButton *button = (UIButton *)view;
        CGFloat topContentEdgeInset = (button.contentEdgeInsets.top / baseHeight) * height;
        CGFloat leftContentEdgeInset = (button.contentEdgeInsets.left / baseHeight) * height;
        CGFloat bottomContentEdgeInset = (button.contentEdgeInsets.bottom / baseHeight) * height;
        CGFloat rightContentEdgeInset = (button.contentEdgeInsets.right / baseHeight) * height;
        button.contentEdgeInsets = UIEdgeInsetsMake(topContentEdgeInset, leftContentEdgeInset, bottomContentEdgeInset, rightContentEdgeInset);
        CGFloat topImageEdgeInset = (button.imageEdgeInsets.top / baseHeight) * height;
        CGFloat leftImageEdgeInset = (button.imageEdgeInsets.left / baseHeight) * height;
        CGFloat bottomImageEdgeInset = (button.imageEdgeInsets.bottom / baseHeight) * height;
        CGFloat rightImageEdgeInset = (button.imageEdgeInsets.right / baseHeight) * height;
        button.imageEdgeInsets = UIEdgeInsetsMake(topImageEdgeInset, leftImageEdgeInset, bottomImageEdgeInset, rightImageEdgeInset);
    }
}

+ (void)setCornerRadiusByWidth:(UIView *)view cornerRadius:(CGFloat)cornerRadius {
    view.layer.cornerRadius = view.frame.size.width * 0.5 * cornerRadius;
}

+ (void)setCornerRadiusByHeight:(UIView *)view cornerRadius:(CGFloat)cornerRadius {
    view.layer.cornerRadius = view.frame.size.height * 0.5 * cornerRadius;
}

@end
