#import "ViewController.h"
#import "TimeIn+CoreDataClass.h"
#import "ScrollView.h"
#import "TextView.h"

@interface OvertimeFormViewController : ViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet UILabel *lDate;
@property (weak, nonatomic) IBOutlet UILabel *lSchedule;
@property (weak, nonatomic) IBOutlet UILabel *lTimeInLabel;
@property (weak, nonatomic) IBOutlet UILabel *lTimeIn;
@property (weak, nonatomic) IBOutlet UILabel *lTimeOutLabel;
@property (weak, nonatomic) IBOutlet UILabel *lTimeOut;
@property (weak, nonatomic) IBOutlet UILabel *lTotalHours;
@property (weak, nonatomic) IBOutlet UILabel *lHoursEligibleForOT;
@property (weak, nonatomic) IBOutlet UITableView *tvOvertimeReasons;
@property (weak, nonatomic) IBOutlet TextView *tfRemarks;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tvOvertimeReasonsHeight;

@property (strong, nonatomic) NSString *date, *schedule, *timeIn, *timeOut;
@property (nonatomic) NSTimeInterval scheduleHours, workHours;
@property (nonatomic) int64_t timeInID;

@end
