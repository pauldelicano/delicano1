#import "TableViewCell.h"

@interface AttendanceItemTableViewCell : TableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lDate;
@property (weak, nonatomic) IBOutlet UILabel *lTimeIn;
@property (weak, nonatomic) IBOutlet UILabel *lTimeOut;
@property (weak, nonatomic) IBOutlet UILabel *lSchedule;

@end
