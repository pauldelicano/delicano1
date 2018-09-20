#import "LayoutConstraint.h"

@interface LayoutConstraint()

@end

@implementation LayoutConstraint

- (void)awakeFromNib {
    [super awakeFromNib];
    self.constant = (self.constant / 568) * UIScreen.mainScreen.bounds.size.height;
}

@end
