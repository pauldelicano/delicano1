#import "ViewController.h"
#import "MainViewController.h"

@interface AttendanceViewController : ViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lTimeIn;
@property (weak, nonatomic) IBOutlet UILabel *lTimeOut;
@property (weak, nonatomic) IBOutlet UITableView *tvAttendance;

@property (strong, nonatomic) MainViewController *main;
@property (strong, nonatomic) NSDate *selectedDate;

@end
