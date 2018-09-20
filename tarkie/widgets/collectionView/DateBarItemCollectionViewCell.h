#import "CollectionViewCell.h"

@interface DateBarItemCollectionViewCell : CollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *lDate;
@property (weak, nonatomic) IBOutlet UILabel *lDay;

@property (strong, nonatomic) UIColor *selectedBackgroundColor;
@property (strong, nonatomic) UIColor *textColor;

@end
