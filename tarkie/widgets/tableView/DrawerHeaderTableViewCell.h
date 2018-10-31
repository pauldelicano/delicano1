#import "TableViewCell.h"

@interface DrawerHeaderTableViewCell : TableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ivEmployeePhoto;
@property (weak, nonatomic) IBOutlet UIImageView *ivCompanyLogo;
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UILabel *lDescription;

@end
