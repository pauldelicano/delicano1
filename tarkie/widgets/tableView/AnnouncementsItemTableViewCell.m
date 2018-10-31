#import "AnnouncementsItemTableViewCell.h"
#import "View.h"

@implementation AnnouncementsItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [View setCornerRadiusByHeight:self.ivPhoto cornerRadius:1];
}

@end
