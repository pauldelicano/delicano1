#import "CustomCollectionViewCell.h"

@interface DateBarItemCollectionViewCell : CustomCollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *lDate;
@property (weak, nonatomic) IBOutlet UILabel *lDay;

@property (strong, nonatomic) UIColor *selectedBackgroundColor;
@property (strong, nonatomic) UIColor *textColor;

@end
