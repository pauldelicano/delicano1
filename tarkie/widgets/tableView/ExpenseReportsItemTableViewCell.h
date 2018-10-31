#import "TableViewCell.h"

@interface ExpenseReportsItemTableViewCell : TableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UILabel *lAmount;
@property (weak, nonatomic) IBOutlet UILabel *lDate;
@property (weak, nonatomic) IBOutlet UILabel *lStatus;

@end
