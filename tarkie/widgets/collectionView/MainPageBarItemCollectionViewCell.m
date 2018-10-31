#import "MainPageBarItemCollectionViewCell.h"
#import "Color.h"

@implementation MainPageBarItemCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.contentView.backgroundColor = selected ? [Color colorNamed:@"BlackTransThirty"] : UIColor.clearColor;
}

@end
