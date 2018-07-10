#import "HomeViewController.h"
#import <CoreText/CTStringAttributes.h>
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Load.h"
#import "Update.h"
#import "Image.h"
#import "View.h"
#import "Time.h"
#import "HomeTableViewCell.h"
#import "MessageDialogViewController.h"
#import "MainViewController.h"
#import "VisitDetailsViewController.h"

@interface HomeViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) MainViewController *main;
@property (strong, nonatomic) NSMutableArray<Visits *> *visits;
@property (strong, nonatomic) NSMutableArray<Forms *> *forms;
@property (strong, nonatomic) NSMutableArray<Inventories *> *inventories;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) UIEdgeInsets vAttendanceLayoutMargins, vVisitsLayoutMargins, vFormsLayoutMargins, vInventoryLayoutMargins;
@property (strong, nonatomic) NSString *conventionVisits;
@property (nonatomic) long userID;
@property (nonatomic) BOOL viewDidAppear, isAttendance, isVisits, isExpense, isForms, isInventory, visitsLoaded, formsLoaded, inventoryLoaded, isTimeIn;

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
    self.userID = [Get userID:self.app.db];
    self.viewDidAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.viewDidAppear) {
        self.viewDidAppear = YES;
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
        [View setCornerRadiusByHeight:self.btnVisits cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.btnExpense cornerRadius:1];
        self.vAttendanceLayoutMargins = self.vAttendance.layoutMargins;
        self.vVisitsLayoutMargins = self.vVisits.layoutMargins;
        self.vFormsLayoutMargins = self.vForms.layoutMargins;
        self.vInventoryLayoutMargins = self.vInventory.layoutMargins;
    }
    [self onRefresh];
}

- (void)onRefresh {
    [super onRefresh];
    self.conventionVisits = [Get conventionName:self.app.db conventionID:CONVENTION_VISITS];
    [self.btnVisits setTitle:[NSString stringWithFormat:@"New %@", self.conventionVisits] forState:UIControlStateNormal];
    [self.visits removeAllObjects];
    [self.forms removeAllObjects];
    [self.inventories removeAllObjects];
    Company *company = [Get company:self.app.db];
    self.ivCompanyLogo.image = [Image saveFromURL:[Image cachesPath:[NSString stringWithFormat:@"COMPANY_LOGO_%lld%@", company.companyID, @".png"]] url:company.logoURL];
    self.isTimeIn = [Get isTimeIn:self.app.db];
    self.isAttendance = [Get isModuleEnabled:self.app.db moduleID:MODULE_ATTENDANCE];
    self.isVisits = [Get isModuleEnabled:self.app.db moduleID:MODULE_VISITS];
    self.isExpense = [Get isModuleEnabled:self.app.db moduleID:MODULE_EXPENSE];
    self.isInventory = [Get isModuleEnabled:self.app.db moduleID:MODULE_INVENTORY];
    self.isForms = [Get isModuleEnabled:self.app.db moduleID:MODULE_FORMS];
    NSDate *currentDate = NSDate.date;
    if(self.isVisits) {
        [self.visits addObjectsFromArray:[Load visits:self.app.db date:currentDate isNoCheckOutOnly:YES]];
    }
    if(self.isForms) {
        [self.forms addObjectsFromArray:[Load forms:self.app.db date:currentDate]];
    }
    if(self.isInventory) {
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
    if(!self.isTimeIn) {
        [self.btnAttendance setTitle:@"Time In" forState:UIControlStateNormal];
        self.vVisitsHeader.backgroundColor = [UIColor colorNamed:@"Grey600"];
        self.vFormsHeader.backgroundColor = [UIColor colorNamed:@"Grey600"];
        self.vInventoryHeader.backgroundColor = [UIColor colorNamed:@"Grey600"];
    }
    else {
        [self.btnAttendance setTitle:@"Time Out" forState:UIControlStateNormal];
        self.vVisitsHeader.backgroundColor = THEME_PRI;
        self.vFormsHeader.backgroundColor = THEME_PRI;
        self.vInventoryHeader.backgroundColor = THEME_PRI;
    }
    if(self.isAttendance && !(self.isVisits || self.isForms || self.isInventory)) {
        self.vAttendance.hidden = NO;
        self.vAttendance.layoutMargins = self.vAttendanceLayoutMargins;
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
        self.vAttendance.layoutMargins = UIEdgeInsetsZero;
        self.vAttendanceHeight.active = YES;
        if(self.timer != nil) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
    if(self.isVisits) {
        self.vVisits.hidden = NO;
        self.vVisits.layoutMargins = self.vVisitsLayoutMargins;
        self.vVisitsHeight.active = NO;
        self.tvVisitsHeight.constant = self.tvVisits.contentSize.height;
    }
    else {
        self.vVisits.hidden = YES;
        self.vVisits.layoutMargins = UIEdgeInsetsZero;
        self.vVisitsHeight.active = YES;
        self.tvVisitsHeight.constant = 0;
    }
    if(self.forms.count > 0) {
        self.vForms.hidden = NO;
        self.vForms.layoutMargins = self.vFormsLayoutMargins;
        self.vFormsHeight.active = NO;
        self.tvFormsHeight.constant = self.tvForms.contentSize.height;
    }
    else {
        self.vForms.hidden = YES;
        self.vForms.layoutMargins = UIEdgeInsetsZero;
        self.vFormsHeight.active = YES;
        self.tvFormsHeight.constant = 0;
    }
    if(self.inventories.count > 0) {
        self.vInventory.hidden = NO;
        self.vInventory.layoutMargins = self.vInventoryLayoutMargins;
        self.vInventoryHeight.active = NO;
        self.tvInventoryHeight.constant = self.tvInventory.contentSize.height;
    }
    else {
        self.vInventory.hidden = YES;
        self.vInventory.layoutMargins = UIEdgeInsetsZero;
        self.vInventoryHeight.active = YES;
        self.tvInventoryHeight.constant = 0;
    }
    if(self.isExpense) {
        self.btnExpense.hidden = NO;
    }
    else {
        self.btnExpense.hidden = YES;
    }
    [self.view layoutIfNeeded];
    self.vScroll.contentSize = CGSizeMake(self.vScroll.frame.size.width, self.vContent.frame.size.height);
    if(self.vContent.frame.size.height < self.vScroll.frame.size.height) {
        CGFloat inset = self.vScroll.frame.size.height - self.vContent.frame.size.height - self.vContent.layoutMargins.top - self.vContent.layoutMargins.bottom;
        self.vScroll.contentInset = UIEdgeInsetsMake(inset * 0.3, 0, inset * 0.7, 0);
    }
    else {
        self.vScroll.contentInset = UIEdgeInsetsZero;
    }
}

- (IBAction)timeInOut:(id)sender {
    [self.main onDrawerMenuSelect:MENU_TIME_IN_OUT];
}

- (IBAction)addVisit:(id)sender {
    vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
    vcMessage.subject = [NSString stringWithFormat:@"Add %@", self.conventionVisits];
    vcMessage.message = [NSString stringWithFormat:@"Are you sure you want to add new %@?", self.conventionVisits];
    vcMessage.negativeTitle = @"No";
    vcMessage.negativeTarget = ^{
        [View removeView:vcMessage.view animated:YES];
    };
    vcMessage.positiveTitle = @"Yes";
    vcMessage.positiveTarget = ^{
        Sequences *sequence = [Get sequence:self.app.db];
        Visits *visit = [NSEntityDescription insertNewObjectForEntityForName:@"Visits" inManagedObjectContext:self.app.db];
        sequence.visits += 1;
        visit.visitID = sequence.visits;
        visit.webVisitID = 0;
        visit.storeID = 0;
        visit.name = [NSString stringWithFormat:@"New %@ %lld", self.conventionVisits, sequence.visits];
        visit.employeeID = self.userID;
        visit.syncBatchID = [Get syncBatchID:self.app.db];
        NSDate *currentDate = NSDate.date;
        visit.createdDate = [Time formatDate:DATE_FORMAT date:currentDate];
        visit.createdTime = [Time formatDate:TIME_FORMAT date:currentDate];
        visit.startDate = [Time formatDate:DATE_FORMAT date:currentDate];
        visit.endDate = [Time formatDate:DATE_FORMAT date:currentDate];
        visit.notes = @"";
        visit.isCheckOut = NO;
        visit.isCheckIn = NO;
        visit.isSync = NO;
        visit.isUpdate = NO;
        visit.isWebUpdate = NO;
        visit.isDelete = NO;
        visit.isWebDelete = NO;
        if([Update save:self.app.db]) {
            [View removeView:vcMessage.view animated:YES];
            [self onRefresh];
            [self.main updateSyncDataCount];
        }
    };
    [View addSubview:self.main.view subview:vcMessage.view animated:YES];
}

- (IBAction)addExpense:(id)sender {
    NSLog(@"paul: addExpense");
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
    if(tableView == self.tvVisits) {
        Visits *visit = self.visits[indexPath.row];
        Stores *store = [Get store:self.app.db storeID:visit.storeID];
        item.lName.text = visit.name;
        item.lName.textColor = !visit.isCheckIn ? [UIColor colorNamed:@"Grey800"] : THEME_SEC;
        item.lDetails.text = store.address.length > 0 ? store.address : @"No address";
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
    return item;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
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
    NSString *displayTime = [Time formatDate:@"h:mm a" date:currentDate];
    NSMutableAttributedString *attributedText = [NSMutableAttributedString.alloc initWithString:displayTime];
    if(displayTime.length >= 3) {
        NSRange range = NSMakeRange(displayTime.length - 3, 3);
        [attributedText addAttribute:NSFontAttributeName value:font range:range];
        [attributedText addAttribute:(NSString *)kCTSuperscriptAttributeName value:@"1" range:range];
    }
    self.lTimeAttendance.attributedText = attributedText;
    self.lDateAttendance.text = [Time formatDate:@"EEEE, MMM d, YYYY" date:currentDate];
}

@end
