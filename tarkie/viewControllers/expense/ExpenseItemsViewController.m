#import "ExpenseItemsViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Load.h"
#import "Update.h"
#import "View.h"
#import "Time.h"
#import "ExpenseItemsHeaderTableViewCell.h"
#import "ExpenseItemsItemTableViewCell.h"
#import "MessageDialogViewController.h"


@interface ExpenseItemsViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSMutableArray<NSMutableDictionary *> *expenseItems;
@property (strong, nonatomic) NSDate *startDate, *endDate;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation ExpenseItemsViewController

static MessageDialogViewController *vcMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.tvExpenseItems.tableFooterView = UIView.alloc.init;
    self.tvExpenseItems.estimatedSectionHeaderHeight = 46;
    self.expenseItems = NSMutableArray.alloc.init;
    NSDate *currentDate = NSDate.date;
    self.startDate = [currentDate dateByAddingTimeInterval:60 * 60 * 24 * -30];
    self.endDate = [currentDate dateByAddingTimeInterval:60 * 60 * 24 * 30];
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        NSString *start = [Time getFormattedDate:self.app.settingDisplayDateFormat date:self.startDate];
        NSRange startRange = NSMakeRange(0, start.length);
        NSMutableAttributedString *startAttributed = [NSMutableAttributedString.alloc initWithString:start];
        [startAttributed addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:startRange];
        [startAttributed addAttribute:NSForegroundColorAttributeName value:THEME_PRI range:startRange];
        [self.btnStartDate setAttributedTitle:startAttributed forState:UIControlStateNormal];
        NSString *end = [Time getFormattedDate:self.app.settingDisplayDateFormat date:self.endDate];
        NSRange endRange = NSMakeRange(0, end.length);
        NSMutableAttributedString *endAttributed = [NSMutableAttributedString.alloc initWithString:end];
        [endAttributed addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:endRange];
        [endAttributed addAttribute:NSForegroundColorAttributeName value:THEME_PRI range:endRange];
        [self.btnEndDate setAttributedTitle:endAttributed forState:UIControlStateNormal];
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    [self.expenseItems removeAllObjects];
    [self.expenseItems addObjectsFromArray:[Load expenseItems:self.app.db startDate:[Time getFormattedDate:DATE_FORMAT date:self.startDate] endDate:[Time getFormattedDate:DATE_FORMAT date:self.endDate]]];
    [self.tvExpenseItems reloadData];
}

- (void)onCalendarPick:(NSDate *)date type:(int)type {
    switch(type) {
        case CALENDAR_TYPE_START_DATE: {
            self.startDate = date;
            break;
        }
        case CALENDAR_TYPE_END_DATE: {
            self.endDate = date;
            break;
        }
    }
    [self onRefresh];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.expenseItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray<Expense *> *)self.expenseItems[section][@"Items"]).count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.expenseItems[indexPath.section][@"Hidden"] boolValue] ? 0 : UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ExpenseItemsHeaderTableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"header"];
    NSString *date = self.expenseItems[section][@"Date"];
    BOOL isExpenseItemTagged = [Get isExpenseItemTagged:self.app.db date:date];
    header.lDate.textColor = isExpenseItemTagged ? THEME_SEC : [Color colorNamed:@"Grey800"];
    header.lTotaAmount.textColor = isExpenseItemTagged ? THEME_SEC : [Color colorNamed:@"Grey800"];
    header.lDate.text = [Time formatDate:self.app.settingDisplayDateFormat date:date];
    header.lTotaAmount.text = [NSString stringWithFormat:@"%@ %@", self.app.settingDisplayCurrencyCode, self.expenseItems[section][@"TotalAmount"]];
    header.contentView.tag = section;
    [header.contentView addGestureRecognizer:[UITapGestureRecognizer.alloc initWithTarget:self action:@selector(toggleSection:)]];
    [header.contentView layoutIfNeeded];
    return header.contentView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExpenseItemsItemTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    [item.longPressGesture addTarget:self action:@selector(onLongPress:)];
    NSArray<Expense *> *items = self.expenseItems[indexPath.section][@"Items"];
    item.lName.text = items[indexPath.row].name;
    item.lName.textColor = items[indexPath.row].isUpdate ? [Color colorNamed:@"Grey800"] : [Color colorNamed:@"Red700"];
    item.lTime.text = [Time formatTime:self.app.settingDisplayTimeFormat time:items[indexPath.row].time];
    item.lAmount.text = [NSString stringWithFormat:@"%@ %.02f", self.app.settingDisplayCurrencyCode, items[indexPath.row].amount];
    [item layoutIfNeeded];
    return item;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ExpenseItemDetailsViewController *vcExpenseItemDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"vcExpenseItemDetails"];
    vcExpenseItemDetails.main = self.main;
    vcExpenseItemDetails.delegate = self;
    vcExpenseItemDetails.section = indexPath.section;
    vcExpenseItemDetails.expense = ((NSArray *)self.expenseItems[indexPath.section][@"Items"])[indexPath.row];
    [self.navigationController pushViewController:vcExpenseItemDetails animated:YES];
}

- (void)onLongPress:(UILongPressGestureRecognizer *)longPressGesture {
    if(longPressGesture.state == UIGestureRecognizerStateBegan) {
        longPressGesture.state = UIGestureRecognizerStateEnded;
        NSIndexPath *indexPath = [self.tvExpenseItems indexPathForCell:(ExpenseItemsItemTableViewCell *)longPressGesture.view];
        Expense *expense = ((NSMutableArray *)self.expenseItems[indexPath.section][@"Items"])[indexPath.row];
        if(expense.isSubmit) {
            [View showAlert:self.main.view message:@"Expense has already been submitted" duration:2];
            return;
        }
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"Delete Expense?";
        vcMessage.message = @"Are you sure you want to delete this expense?";
        vcMessage.negativeTitle = @"No";
        vcMessage.negativeTarget = ^{
            [View removeChildViewController:vcMessage animated:YES];
        };
        vcMessage.positiveTitle = @"Yes";
        vcMessage.positiveTarget = ^{
            [View removeChildViewController:vcMessage animated:YES];
            [self onExpenseItemDetailsDelete:indexPath.section expense:expense];
        };
        [View addChildViewController:self.main childViewController:vcMessage animated:YES];
    }
}

- (void)onExpenseItemDetailsDelete:(NSInteger)section expense:(Expense *)expense {
    expense.isDelete = YES;
    if([Update save:self.app.db]) {
        NSMutableDictionary *expenseItem = [Load expenseItems:self.app.db startDate:expense.date endDate:expense.date].lastObject;
        if(expenseItem != nil) {
            [self.expenseItems[section][@"Items"] removeObject:expense];
            expenseItem[@"Items"] = self.expenseItems[section][@"Items"];
            expenseItem[@"Hidden"] = self.expenseItems[section][@"Hidden"];
            self.expenseItems[section] = expenseItem;
        }
        else {
            [self.expenseItems removeObjectAtIndex:section];
            [self.tvExpenseItems deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
        }
        [self.tvExpenseItems reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)onExpenseItemDetailsSave:(NSInteger)section expense:(Expense *)expense {
    NSMutableDictionary *expenseItem = [Load expenseItems:self.app.db startDate:expense.date endDate:expense.date].lastObject;
    expenseItem[@"Items"] = self.expenseItems[section][@"Items"];
    expenseItem[@"Hidden"] = self.expenseItems[section][@"Hidden"];
    self.expenseItems[section] = expenseItem;
    [self.tvExpenseItems reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)startDate:(id)sender {
    
}

- (IBAction)endDate:(id)sender {
    
}

- (void)toggleSection:(UITapGestureRecognizer *)gesture {
    NSUInteger section = gesture.view.tag;
    self.expenseItems[section][@"Hidden"] = [NSNumber numberWithBool:![self.expenseItems[section][@"Hidden"] boolValue]];
    if(((NSMutableArray *)self.expenseItems[section][@"Items"]).count == 0) {
        self.expenseItems[section][@"Items"] = [NSMutableArray.alloc initWithArray:[Load expense:self.app.db date:self.expenseItems[section][@"Date"]]];
    }
    [self.tvExpenseItems reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
}

@end
