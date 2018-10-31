#import "ViewController.h"
#import "MainViewController.h"

@interface ActivitiesViewController : ViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tvActivities;

@property (strong, nonatomic) MainViewController *main;
@property (strong, nonatomic) NSDate *selectedDate;

@end
