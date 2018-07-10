#import "CustomTableViewCell.h"

@interface StoreContactsHeaderTableViewCell : CustomTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UILabel *lAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;

@end
