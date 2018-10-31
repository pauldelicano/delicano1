#import "ViewController.h"
#import "TextField.h"
#import "MainViewController.h"

@interface ExpenseReportsViewController : ViewController<TextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet TextField *tfSearch;
@property (weak, nonatomic) IBOutlet UITableView *tvExpenseReports;

@property (strong, nonatomic) MainViewController *main;

@end
