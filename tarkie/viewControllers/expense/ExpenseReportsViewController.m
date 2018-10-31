#import "ExpenseReportsViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Load.h"
#import "View.h"
#import "Time.h"
#import "ExpenseReportsItemTableViewCell.h"
#import "ExpenseReportDetailsViewController.h"

@interface ExpenseReportsViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSMutableArray<ExpenseReports *> *expenseReports;
@property (strong, nonatomic) NSString *searchFilter;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation ExpenseReportsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.tvExpenseReports.tableFooterView = UIView.alloc.init;
    self.tfSearch.textFieldDelegate = self;
    self.expenseReports = NSMutableArray.alloc.init;
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.tfSearch.highlightedBorderColor = THEME_SEC;
        [View setCornerRadiusByHeight:self.tfSearch cornerRadius:0.3];
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    [self.expenseReports removeAllObjects];
    [self.expenseReports addObjectsFromArray:[Load expenseReports:self.app.db searchFilter:self.searchFilter]];
    [self.tvExpenseReports reloadData];
}

- (void)onTextFieldTextChanged:(UITextField *)textfield text:(NSString *)text {
    self.searchFilter = text;
    [self onRefresh];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.expenseReports.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExpenseReportsItemTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    ExpenseReports *report = self.expenseReports[indexPath.row];
    item.lName.text = report.name;
    item.lAmount.text = [NSString stringWithFormat:@"%@ %.02f", self.app.settingDisplayCurrencyCode, 0.0f];
    item.lDate.text = [Time formatDate:self.app.settingDisplayDateFormat date:report.date];
    item.lStatus.text = report.isSubmit ? @"Submitted" : @"Draft";
    [item layoutIfNeeded];
    return item;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ExpenseReportDetailsViewController *vcExpenseReportDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"vcExpenseReportDetails"];
    vcExpenseReportDetails.expenseReport = self.expenseReports[indexPath.row];
    [self.navigationController pushViewController:vcExpenseReportDetails animated:YES];
}

@end
