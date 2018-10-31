#import "SubPageBarItemCollectionViewCell.h"
#import "Color.h"

@implementation SubPageBarItemCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.lName.font = [UIFont fontWithName:selected ? @"ProximaNova-Semibold" : @"ProximaNova-Regular" size:self.lName.font.pointSize];
}

@end
