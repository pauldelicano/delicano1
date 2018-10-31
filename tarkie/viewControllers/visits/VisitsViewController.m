#import "VisitsViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Load.h"
#import "Time.h"
#import "VisitsTableViewCell.h"
#import "MainViewController.h"
#import "VisitDetailsViewController.h"

@interface VisitsViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) MainViewController *main;
@property (strong, nonatomic) NSMutableArray<Visits *> *visits;
@property (strong, nonatomic) NSDate *selectedDate;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation VisitsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.main = (MainViewController *)self.parentViewController.parentViewController;
    self.cvDateBar.dateBarDelegate = self;
    self.tvVisits.tableFooterView = UIView.alloc.init;
    self.visits = NSMutableArray.alloc.init;
    self.selectedDate = nil;
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.cvDateBar.selectedBackgroundColor = THEME_SEC;
        self.cvDateBar.textColor = THEME_PRI;
        self.vBorder.backgroundColor = THEME_SEC;
    }
    [self onRefresh];
}

- (void)onRefresh {
    [super onRefresh];
    if(self.selectedDate == nil) {
        NSMutableArray<NSDate *> *dates = NSMutableArray.alloc.init;
        NSDate *currentDate = NSDate.date;
        for(int x = -5; x < 10; x++) {
            [dates addObject:[currentDate dateByAddingTimeInterval:60 * 60 * 24 * x]];
        }
        self.cvDateBar.dates = dates;
        [self.cvDateBar reloadData];
        return;
    }
    self.lDate.text = [Time getFormattedDate:self.app.settingDisplayDateFormat date:self.selectedDate];
    [self.visits removeAllObjects];
    [self.visits addObjectsFromArray:[Load visits:self.app.db date:[Time getFormattedDate:DATE_FORMAT date:self.selectedDate] isNoCheckOutOnly:NO]];
    [self.tvVisits reloadData];
}

- (void)onDateBarSelect:(NSDate *)date {
    self.selectedDate = date;
    [self onRefresh];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.visits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VisitsTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    Visits *visit = self.visits[indexPath.row];
    item.lName.text = visit.name;
    NSString *checkin = @"NO IN";
    NSString *checkout = @"NO OUT";
    if(visit.isCheckIn) {
        CheckIn *checkIn = [Get checkIn:self.app.db visitID:visit.visitID];
        checkin = [Time formatTime:self.app.settingDisplayTimeFormat time:checkIn.time];
        if(visit.isCheckOut) {
            CheckOut *checkOut = [Get checkOut:self.app.db checkInID:checkIn.checkInID];
            checkout = [Time formatTime:self.app.settingDisplayTimeFormat time:checkOut.time];
        }
    }
    item.lStatus.text = visit.isCheckIn ? [NSString stringWithFormat:@"%@ - %@", checkin, checkout] : @"ACTIVE";
    item.lStatus.textColor = visit.isCheckIn && visit.isCheckOut ? [Color colorNamed:@"ThemeSec.sevie"] : [Color colorNamed:@"Yellow800"];
    [item layoutIfNeeded];
    return item;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    VisitDetailsViewController *vcVisitDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"vcVisitDetails"];
    vcVisitDetails.main = self.main;
    vcVisitDetails.visit = self.visits[indexPath.row];
    [self.navigationController pushViewController:vcVisitDetails animated:YES];
}

@end
