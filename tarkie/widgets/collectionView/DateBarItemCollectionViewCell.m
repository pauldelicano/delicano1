#import "DateBarItemCollectionViewCell.h"

@implementation DateBarItemCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.lDate.textColor = self.textColor;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.contentView.backgroundColor = selected ? self.selectedBackgroundColor : UIColor.clearColor;
}

@end
