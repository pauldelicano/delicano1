#import "CustomCollectionViewCell.h"
#import "Image.h"
#import "View.h"
#import "TextField.h"
#import "TextView.h"

@implementation CustomCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self scaleView:self];
}

- (void)scaleView:(UIView *)view {
    [View scaleViewSize:view];
    if([view isKindOfClass:UILabel.class]) {
        [View scaleFontSize:view];
        return;
    }
    if([view isKindOfClass:UIButton.class]) {
        [View scaleFontSize:((UIButton *)view).titleLabel];
        [(UIButton *)view setBackgroundImage:[Image fromColor:[UIColor colorNamed:@"BlackTransSixty"]] forState:UIControlStateHighlighted];
        return;
    }
    if([view isKindOfClass:TextField.class]) {
        [View scaleFontSize:view];
        return;
    }
    if([view isKindOfClass:TextView.class]) {
        [View scaleFontSize:view];
        return;
    }
    for(int x = 0; x < view.subviews.count; x++) {
        [self scaleView:view.subviews[x]];
    }
}

@end
