#import "CollectionViewCell.h"
#import "File.h"
#import "View.h"
#import "Color.h"
#import "TextField.h"
#import "TextView.h"

@implementation CollectionViewCell

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
        [(UIButton *)view setBackgroundImage:[File imageFromColor:[Color colorNamed:@"BlackTransSixty"]] forState:UIControlStateHighlighted];
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
    for(UIView *subview in view.subviews) {
        [self scaleView:subview];
    }
}

@end
