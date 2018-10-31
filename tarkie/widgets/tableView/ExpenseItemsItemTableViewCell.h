#import "TableViewCell.h"

@interface ExpenseItemsItemTableViewCell : TableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UILabel *lTime;
@property (weak, nonatomic) IBOutlet UILabel *lAmount;

@end
