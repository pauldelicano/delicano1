#import "HomeViewController.h"
#import <CoreText/CTStringAttributes.h>
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Load.h"
#import "Update.h"
#import "File.h"
#import "View.h"
#import "Time.h"
#import "HomeTableViewCell.h"
#import "MessageDialogViewController.h"
#import "MainViewController.h"
#import "ExpenseViewController.h"
#import "ExpenseItemsViewController.h"
#import "VisitDetailsViewController.h"

@interface HomeViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) MainViewController *main;
@property (strong, nonatomic) NSMutableArray<Visits *> *visits;
@property (strong, nonatomic) NSMutableArray<Forms *> *forms;
@property (strong, nonatomic) NSMutableArray<Inventories *> *inventories;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) BOOL viewWillAppear, visitsLoaded, formsLoaded, inventoryLoaded;

@end

@implementation HomeViewController

static MessageDialogViewController *vcMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.main = (MainViewController *)self.parentViewController.parentViewController;
    UIView *vFooter = UIView.alloc.init;
    self.tvVisits.tableFooterView = vFooter;
    self.tvForms.tableFooterView = vFooter;
    self.tvInventory.tableFooterView = vFooter;
    self.visits = NSMutableArray.alloc.init;
    self.forms = NSMutableArray.alloc.init;
    self.inventories = NSMutableArray.alloc.init;
    self.visitsLoaded = NO;
    self.formsLoaded = NO;
    self.inventoryLoaded = NO;
    self.ivCompanyLogo.image = nil;
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.btnAttendance.backgroundColor = THEME_PRI;
        self.btnVisits.backgroundColor = THEME_SEC;
        self.vVisitsHeader.backgroundColor = THEME_PRI;
        self.vFormsHeader.backgroundColor = THEME_PRI;
        self.vInventoryHeader.backgroundColor = THEME_PRI;
        [View setCornerRadiusByWidth:self.lTimeAttendance.superview cornerRadius:0.025];
        [View setCornerRadiusByWidth:self.vVisits cornerRadius:0.025];
        [View setCornerRadiusByWidth:self.vForms cornerRadius:0.025];
        [View setCornerRadiusByWidth:self.vInventory cornerRadius:0.025];
        [View setCornerRadiusByHeight:self.btnAttendance cornerRadius:1];
        [View setCornerRadiusByHeight:self.btnVisits cornerRadius:0.2];
        [View setCornerRadiusByHeight:self.btnExpense cornerRadius:1];
    }
    [self onRefresh];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.vContent.frame.size.height < self.vScroll.frame.size.height) {
        CGFloat inset = self.vScroll.frame.size.height - self.vContent.frame.size.height;
        self.vScroll.contentInset = UIEdgeInsetsMake(inset * 0.4, 0, inset * 0.6, 0);
    }
    else {
        self.vScroll.contentInset = UIEdgeInsetsZero;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)onRefresh {
    [super onRefresh];
    [self.btnVisits setTitle:[NSString stringWithFormat:@"NEW %@", self.app.conventionVisits.uppercaseString] forState:UIControlStateNormal];
    [self.btnExpense setTitle:self.app.settingDisplayCurrencySymbol forState:UIControlStateNormal];
    [self.visits removeAllObjects];
    [self.forms removeAllObjects];
    [self.inventories removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [File saveImageFromURL:[File cachesPath:[NSString stringWithFormat:@"COMPANY_LOGO_%lld%@", self.app.company.companyID, @".png"]] url:self.app.company.logoURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ivCompanyLogo.image = image;
        });
    });
    NSString *currentDate = [Time getFormattedDate:DATE_FORMAT date:NSDate.date];
    if(self.app.moduleVisits) {
        [self.visits addObjectsFromArray:[Load visits:self.app.db date:currentDate isNoCheckOutOnly:YES]];
    }
    if(self.app.moduleForms) {
        [self.forms addObjectsFromArray:[Load forms:self.app.db date:currentDate]];
    }
    if(self.app.moduleInventory) {
        [self.inventories addObjectsFromArray:[Load inventories:self.app.db date:currentDate]];
    }
    self.visitsLoaded = self.visits.count == 0;
    self.formsLoaded = self.forms.count == 0;
    self.inventoryLoaded = self.inventories.count == 0;
    [self.tvVisits reloadData];
    [self.tvForms reloadData];
    [self.tvInventory reloadData];
    [self updateHome];
}

- (void)updateHome {
    if(!self.main.isTimeIn) {
        [self.btnAttendance setTitle:@"Time In" forState:UIControlStateNormal];
        self.vVisitsHeader.backgroundColor = [Color colorNamed:@"Grey600"];
        self.vFormsHeader.backgroundColor = [Color colorNamed:@"Grey600"];
        self.vInventoryHeader.backgroundColor = [Color colorNamed:@"Grey600"];
    }
    else {
        [self.btnAttendance setTitle:@"Time Out" forState:UIControlStateNormal];
        self.vVisitsHeader.backgroundColor = THEME_PRI;
        self.vFormsHeader.backgroundColor = THEME_PRI;
        self.vInventoryHeader.backgroundColor = THEME_PRI;
    }
    if(self.app.moduleAttendance && !(self.app.moduleVisits || self.app.moduleForms || self.app.moduleInventory)) {
        self.vAttendance.hidden = NO;
        self.vAttendanceHeight.active = NO;
        if(self.timer == nil) {
            UIFont *font = self.lTimeAttendance.font;
            font = [font fontWithSize:font.pointSize * 0.45];
            [self updateDisplayTime:font];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:^{
                [self updateDisplayTime:font];
            } selector:@selector(invoke) userInfo:nil repeats:YES];
        }
    }
    else {
        self.vAttendance.hidden = YES;
        self.vAttendanceHeight.active = YES;
        if(self.timer != nil) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
    if(self.app.moduleVisits) {
        self.vVisits.hidden = NO;
        self.vVisitsHeight.active = NO;
        self.tvVisitsHeight.constant = self.tvVisits.contentSize.height;
    }
    else {
        self.vVisits.hidden = YES;
        self.vVisitsHeight.active = YES;
        self.tvVisitsHeight.constant = 0;
    }
    if(self.forms.count > 0) {
        self.vForms.hidden = NO;
        self.vFormsHeight.active = NO;
        self.tvFormsHeight.constant = self.tvForms.contentSize.height;
    }
    else {
        self.vForms.hidden = YES;
        self.vFormsHeight.active = YES;
        self.tvFormsHeight.constant = 0;
    }
    if(self.inventories.count > 0) {
        self.vInventory.hidden = NO;
        self.vInventoryHeight.active = NO;
        self.tvInventoryHeight.constant = self.tvInventory.contentSize.height;
    }
    else {
        self.vInventory.hidden = YES;
        self.vInventoryHeight.active = YES;
        self.tvInventoryHeight.constant = 0;
    }
    if(self.app.moduleExpense) {
        self.btnExpense.hidden = NO;
    }
    else {
        self.btnExpense.hidden = YES;
    }
    if(self.vContent.frame.size.height < self.vScroll.frame.size.height) {
        CGFloat inset = self.vScroll.frame.size.height - self.vContent.frame.size.height;
        self.vScroll.contentInset = UIEdgeInsetsMake(inset * 0.4, 0, inset * 0.6, 0);
    }
    else {
        self.vScroll.contentInset = UIEdgeInsetsZero;
    }
}

- (IBAction)timeInOut:(id)sender {
    [self.main onDrawerMenuSelect:MENU_TIME_IN_OUT];
}

- (IBAction)addVisit:(id)sender {
    if(!self.app.settingVisitsAdd) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"Not Allowed";
        vcMessage.message = [NSString stringWithFormat:@"You are not allowed to add new %@.", self.app.conventionVisits.lowercaseString];
        vcMessage.positiveTitle = @"OK";
        vcMessage.positiveTarget = ^{
            [View removeChildViewController:vcMessage animated:YES];
        };
        [View addChildViewController:self.main childViewController:vcMessage animated:YES];
        return;
    }
    vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
    vcMessage.subject = [NSString stringWithFormat:@"Add %@", self.app.conventionVisits];
    vcMessage.message = [NSString stringWithFormat:@"Are you sure you want to add new %@?", self.app.conventionVisits];
    vcMessage.negativeTitle = @"No";
    vcMessage.negativeTarget = ^{
        [View removeChildViewController:vcMessage animated:YES];
    };
    vcMessage.positiveTitle = @"Yes";
    vcMessage.positiveTarget = ^{
        Visits *visit = [NSEntityDescription insertNewObjectForEntityForName:@"Visits" inManagedObjectContext:self.app.db];
        visit.visitID = [Get sequenceID:self.app.db entity:@"Visits" attribute:@"visitID"] + 1;
        visit.syncBatchID = self.app.syncBatchID;
        visit.employeeID = self.app.employee.employeeID;
        visit.webVisitID = 0;
        visit.storeID = 0;
        NSDate *currentDate = NSDate.date;
        NSString *date = [Time getFormattedDate:DATE_FORMAT date:currentDate];
        NSString *time = [Time getFormattedDate:TIME_FORMAT date:currentDate];
        visit.name = [NSString stringWithFormat:@"New %@ %ld", self.app.conventionVisits, [Get visitTodayCount:self.app.db date:date] + 1];
        visit.createdDate = date;
        visit.createdTime = time;
        visit.startDate = date;
        visit.endDate = date;
        visit.notes = @"";
        visit.isCheckOut = NO;
        visit.isCheckIn = NO;
        visit.isFromWeb = NO;
        visit.isSync = NO;
        visit.isUpdate = NO;
        visit.isWebUpdate = NO;
        visit.isDelete = NO;
        visit.isWebDelete = NO;
        if([Update save:self.app.db]) {
            [View removeChildViewController:vcMessage animated:YES];
            [self onRefresh];
            [self.main updateSyncDataCount];
        }
    };
    [View addChildViewController:self.main childViewController:vcMessage animated:YES];
}

- (IBAction)addExpense:(id)sender {
    if(!self.main.isTimeIn) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = [NSString stringWithFormat:@"%@ Required", self.app.conventionTimeIn];
        vcMessage.message = [NSString stringWithFormat:@"Please %@ first before creating new reports. To %@, please tap on Menu or slide to the right and select '%@'", self.app.conventionTimeIn.lowercaseString, self.app.conventionTimeIn.lowercaseString, self.app.conventionTimeIn];
        vcMessage.positiveTitle = @"OK";
        vcMessage.positiveTarget = ^{
            vcMessage.view.alpha = 1;
            [UIView animateWithDuration:0.25 animations:^{
                vcMessage.view.alpha = 0;
            } completion:^(BOOL finished) {
                [vcMessage.view removeFromSuperview];
                [vcMessage removeFromParentViewController];
                [self.main.vcDrawer openDrawer];
            }];
        };
        [View addChildViewController:self.main childViewController:vcMessage animated:YES];
        return;
    }
    Expense *expense = [NSEntityDescription insertNewObjectForEntityForName:@"Expense" inManagedObjectContext:self.app.db];
    expense.expenseID = [Get sequenceID:self.app.db entity:@"Expense" attribute:@"expenseID"] + 1;
    expense.syncBatchID = self.app.syncBatchID;
    expense.employeeID = self.app.employee.employeeID;
    expense.timeInID = [Get timeIn:self.app.db].timeInID;
    NSDate *currentDate = NSDate.date;
    NSString *date = [Time getFormattedDate:DATE_FORMAT date:currentDate];
    NSString *time = [Time getFormattedDate:TIME_FORMAT date:currentDate];
    expense.name = [NSString stringWithFormat:@"Expense %ld", [Get expenseTodayCount:self.app.db date:date withoutDeleted:NO] + 1];
    expense.date = date;
    expense.time = time;
    expense.gpsID = [Update gpsSave:self.app.dbTracking dbAlerts:self.app.dbAlerts location:self.app.location];
    expense.amount = 0;
    expense.isReimbursable = YES;
    expense.isSubmit = NO;
    expense.isSync = NO;
    expense.isUpdate = NO;
    expense.isWebUpdate = NO;
    expense.isDelete = NO;
    expense.isWebDelete = NO;
    if([Update save:self.app.db]) {
        for(ViewController *mainViewController in self.main.viewControllers) {
            if([mainViewController isKindOfClass:ExpenseViewController.class]) {
                for(ViewController *expenseViewController in ((ExpenseViewController *)mainViewController).viewControllers) {
                    if([expenseViewController isKindOfClass:ExpenseItemsViewController.class]) {
                        [expenseViewController onRefresh];
                        break;
                    }
                }
            }
        }
        [self.main updateSyncDataCount];
        [View showAlert:self.main.navigationController.view message:[NSString stringWithFormat:@"%@ has been added. You may enter more details later.", expense.name] duration:2];
    }
}

- (void)onLongPress:(UILongPressGestureRecognizer *)longPressGesture {
    if(longPressGesture.state == UIGestureRecognizerStateBegan) {
        longPressGesture.state = UIGestureRecognizerStateEnded;
        if(longPressGesture.view.superview == self.tvVisits) {
            NSIndexPath *indexPath = [self.tvVisits indexPathForCell:(HomeTableViewCell *)longPressGesture.view];
            if(self.app.settingVisitsDelete) {
                if(self.visits[indexPath.row].isCheckIn || self.visits[indexPath.row].isCheckOut) {
                    vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
                    vcMessage.subject = [NSString stringWithFormat:@"Delete %@", self.app.conventionVisits];
                    vcMessage.message = [NSString stringWithFormat:@"This %@ has already been checked-in. You're not allowed to delete it.", self.app.conventionVisits];
                    vcMessage.positiveTitle = @"OK";
                    vcMessage.positiveTarget = ^{
                        [View removeChildViewController:vcMessage animated:YES];
                    };
                    [View addChildViewController:self.main childViewController:vcMessage animated:YES];
                    return;
                }
                vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
                vcMessage.subject = [NSString stringWithFormat:@"Delete %@", self.app.conventionVisits];
                vcMessage.message = [NSString stringWithFormat:@"Are you sure you want to delete this %@?", self.app.conventionVisits];
                vcMessage.negativeTitle = @"No";
                vcMessage.negativeTarget = ^{
                    [View removeChildViewController:vcMessage animated:YES];
                };
                vcMessage.positiveTitle = @"Yes";
                vcMessage.positiveTarget = ^{
                    self.visits[indexPath.row].isDelete = YES;
                    if([Update save:self.app.db]) {
                        [View removeChildViewController:vcMessage animated:YES];
                        [self onRefresh];
                        [self.main updateSyncDataCount];
                    }
                };
                [View addChildViewController:self.main childViewController:vcMessage animated:YES];
            }
        }
        if(longPressGesture.view.superview == self.tvForms) {
        }
        if(longPressGesture.view.superview == self.tvInventory) {
        }
    }
}

- (void)deleteVisit:(NSIndexPath *)indexPath {
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tvVisits) {
        return self.visits.count;
    }
    if(tableView == self.tvForms) {
        return self.forms.count;
    }
    if(tableView == self.tvInventory) {
        return self.inventories.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    [item.longPressGesture addTarget:self action:@selector(onLongPress:)];
    if(tableView == self.tvVisits) {
        Visits *visit = self.visits[indexPath.row];
        Stores *store = [Get store:self.app.db storeID:visit.storeID];
        item.lName.text = visit.name;
        item.lDetails.text = self.app.settingVisitsNotesAsAddress && visit.notes.length > 0 ? visit.notes : store.storeID != 0 ? store.address.length > 0 ? store.address : @"No address" : nil;
        if(indexPath.row == self.visits.count - 1) {
            self.visitsLoaded = YES;
        }
    }
    if(tableView == self.tvForms) {
        Forms *form = self.forms[indexPath.row];
        item.lName.text = form.name;
        if(indexPath.row == self.forms.count - 1) {
            self.formsLoaded = YES;
        }
    }
    if(tableView == self.tvInventory) {
        Inventories *inventory = self.inventories[indexPath.row];
        item.lName.text = inventory.name;
        if(indexPath.row == self.inventories.count - 1) {
            self.inventoryLoaded = YES;
        }
    }
    [item layoutIfNeeded];
    return item;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.tvVisits) {
        HomeTableViewCell *item = (HomeTableViewCell *)cell;
        item.lName.textColor = !self.visits[indexPath.row].isCheckIn ? [Color colorNamed:@"Grey800"] : THEME_SEC;
    }
    if(self.visitsLoaded && self.formsLoaded && self.inventoryLoaded) {
        self.visitsLoaded = NO;
        self.formsLoaded = NO;
        self.inventoryLoaded = NO;
        [self updateHome];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(tableView == self.tvVisits) {
        VisitDetailsViewController *vcVisitDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"vcVisitDetails"];
        vcVisitDetails.main = self.main;
        vcVisitDetails.visit = self.visits[indexPath.row];
        [self.navigationController pushViewController:vcVisitDetails animated:YES];
    }
    if(tableView == self.tvForms) {
        
    }
    if(tableView == self.tvInventory) {
        
    }
}

- (void)updateDisplayTime:(UIFont *)font {
    NSDate *currentDate = NSDate.date;
    NSString *displayTime = [Time getFormattedDate:@"h:mm a" date:currentDate];
    NSMutableAttributedString *attributedText = [NSMutableAttributedString.alloc initWithString:displayTime];
    if(displayTime.length >= 3) {
        NSRange range = NSMakeRange(displayTime.length - 3, 3);
        [attributedText addAttribute:NSFontAttributeName value:font range:range];
        [attributedText addAttribute:(NSString *)kCTSuperscriptAttributeName value:@"1" range:range];
    }
    self.lTimeAttendance.attributedText = attributedText;
    self.lDateAttendance.text = [Time getFormattedDate:@"EEEE, MMM d, YYYY" date:currentDate];
}

@end
