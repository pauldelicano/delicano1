#import "ViewController.h"
#import "ExpenseReports+CoreDataClass.h"
#import "ScrollView.h"

@interface ExpenseReportDetailsViewController : ViewController

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;

@property (strong, nonatomic) ExpenseReports *expenseReport;

@end
