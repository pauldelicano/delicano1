#import "ExpenseReportDetailsViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "View.h"

@interface ExpenseReportDetailsViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation ExpenseReportDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.vStatusBar.backgroundColor = THEME_PRI_DARK;
        self.vNavBar.backgroundColor = THEME_PRI;
        [self.btnSave setTitleColor:THEME_PRI forState:UIControlStateNormal];
        [View setCornerRadiusByHeight:self.btnSave cornerRadius:0.3];
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    self.lName.text = self.expenseReport.name;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    
}

@end
