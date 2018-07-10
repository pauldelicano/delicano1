#import "PageBarItemCollectionViewCell.h"

@implementation PageBarItemCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.contentView.backgroundColor = selected ? [UIColor colorNamed:@"BlackTransThirty"] : UIColor.clearColor;
}

@end
