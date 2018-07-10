#import "CustomTableViewCell.h"

@interface DrawerHeaderTableViewCell : CustomTableViewCell

@property (weak, nonatomic) IBOutlet UIView *vBackground;
@property (weak, nonatomic) IBOutlet UIImageView *ivEmployeePhoto;
@property (weak, nonatomic) IBOutlet UIImageView *ivCompanyLogo;
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UILabel *lDescription;

@end
