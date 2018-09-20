#import "PageBarItemCollectionViewCell.h"
#import "Color.h"

@implementation PageBarItemCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.contentView.backgroundColor = selected ? [Color colorNamed:@"BlackTransThirty"] : UIColor.clearColor;
}

@end
