#import "View.h"
#import "Color.h"

@implementation View

+ (void)addChildViewController:(UIViewController *)parentViewController childViewController:(UIViewController *)childViewController animated:(BOOL)animated {
    [parentViewController addChildViewController:childViewController];
    [parentViewController.view addSubview:childViewController.view];
    [parentViewController.view bringSubviewToFront:childViewController.view];
    childViewController.view.alpha = 0;
    [UIView animateWithDuration:animated ? 0.25 : 0.125 animations:^{
        childViewController.view.alpha = 1;
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

+ (void)showAlert:(UIView *)view message:(NSString *)message duration:(CGFloat)duration {
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Regular" size:(12.0f / 568) * UIScreen.mainScreen.bounds.size.height];
    CGRect textFrame = [message boundingRectWithSize:CGSizeMake(view.frame.size.width - (font.pointSize * 4), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    UILabel *alert = [UILabel.alloc initWithFrame:CGRectMake(font.pointSize, font.pointSize, view.frame.size.width - (font.pointSize * 4), textFrame.size.height)];
    alert.text = message;
    alert.font = font;
    alert.textColor = UIColor.whiteColor;
    alert.textAlignment = NSTextAlignmentCenter;
    alert.numberOfLines = 0;
    alert.lineBreakMode = NSLineBreakByWordWrapping;
    UIView *container = [UIView.alloc initWithFrame:CGRectMake(font.pointSize, view.frame.size.height - textFrame.size.height - (font.pointSize * 7), view.frame.size.width - (font.pointSize * 2), textFrame.size.height + (font.pointSize * 2))];
    container.backgroundColor = [Color colorNamed:@"BlackTransSixty"];
    container.layer.cornerRadius = container.frame.size.height * 0.5;
    container.clipsToBounds = YES;
    [container addSubview:alert];
    [view addSubview:container];
    container.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        container.alpha = 1;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        container.alpha = 1;
        [UIView animateWithDuration:0.5 animations:^{
            container.alpha = 0;
        } completion:^(BOOL finished) {
            [container removeFromSuperview];
        }];
    });
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
