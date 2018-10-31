#import "ViewController.h"
#import "MainViewController.h"
#import "ExpenseItemDetailsViewController.h"

@interface ExpenseItemsViewController : ViewController<UITableViewDataSource, UITableViewDelegate, ExpenseItemDetailsDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnStartDate;
@property (weak, nonatomic) IBOutlet UIButton *btnEndDate;
@property (weak, nonatomic) IBOutlet UITableView *tvExpenseItems;

@property (strong, nonatomic) MainViewController *main;

@end
