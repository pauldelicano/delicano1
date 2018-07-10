#import "CustomTableViewCell.h"

@interface StoreContactsItemTableViewCell : CustomTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UILabel *lDesignation;
@property (weak, nonatomic) IBOutlet UILabel *lEmail;
@property (weak, nonatomic) IBOutlet UILabel *lBirthdate;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;

@end
