#import "View.h"

@implementation View

+ (void)addSubview:(UIView *)view subview:(UIView *)subview animated:(BOOL)animated {
    subview.alpha = 0;
    [view addSubview:subview];
    [view bringSubviewToFront:subview];
    [UIView animateWithDuration:animated ? 0.25 : 0.125 animations:^{subview.alpha = 1;} completion:^(BOOL finished) {}];
}

+ (void)removeView:(UIView *)view animated:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.25 : 0.125 animations:^{view.alpha = 0;} completion:^(BOOL finished) {[view removeFromSuperview];}];
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
    CGFloat topMargin = (view.directionalLayoutMargins.top / baseHeight) * height;
    CGFloat leadingMargin = (view.directionalLayoutMargins.leading / baseHeight) * height;
    CGFloat bottomMargin = (view.directionalLayoutMargins.bottom / baseHeight) * height;
    CGFloat trailingMargin = (view.directionalLayoutMargins.trailing / baseHeight) * height;
    view.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(topMargin, leadingMargin, bottomMargin, trailingMargin);
}

+ (void)setCornerRadiusByWidth:(UIView *)view cornerRadius:(CGFloat)cornerRadius {
    view.layer.cornerRadius = view.frame.size.width * 0.5 * cornerRadius;
}

+ (void)setCornerRadiusByHeight:(UIView *)view cornerRadius:(CGFloat)cornerRadius {
    view.layer.cornerRadius = view.frame.size.height * 0.5 * cornerRadius;
}

@end
