#import "DrawerHeaderTableViewCell.h"
#import "View.h"

@implementation DrawerHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [View setCornerRadiusByHeight:self.ivEmployeePhoto cornerRadius:1];
    [View setCornerRadiusByWidth:self.ivCompanyLogo cornerRadius:0.025];
}

@end
