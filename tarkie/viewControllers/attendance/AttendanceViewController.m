#import "AttendanceViewController.h"
#import "AppDelegate.h"
#import "Get.h"
#import "Load.h"
#import "File.h"
#import "View.h"
#import "Time.h"
#import "MessageDialogViewController.h"
#import "AttendanceItemTableViewCell.h"
#import "AttendanceSummaryViewController.h"

@interface AttendanceViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSMutableArray<TimeIn *> *timeInList;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation AttendanceViewController

static MessageDialogViewController *vcMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.tvAttendance.tableFooterView = UIView.alloc.init;
    self.timeInList = NSMutableArray.alloc.init;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.viewWillAppear = YES;
    [self onRefresh];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.viewWillAppear = NO;
}

- (void)onRefresh {
    [super onRefresh];
    if(self.viewWillAppear) {
        self.lTimeIn.text = self.app.conventionTimeIn;
        self.lTimeOut.text = self.app.conventionTimeOut;
        [self.timeInList removeAllObjects];
        [self.timeInList addObjectsFromArray:[Load timeIn:self.app.db date:[Time getFormattedDate:DATE_FORMAT date:self.selectedDate]]];
        [self.tvAttendance reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timeInList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttendanceItemTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    TimeIn *timeIn = self.timeInList[indexPath.row];
    item.lDate.text = [Time formatDate:self.app.settingDisplayDateFormat date:timeIn.date];
    item.lTimeIn.text = [Time formatTime:self.app.settingDisplayTimeFormat time:timeIn.time];
    TimeOut *timeOut = [Get timeOut:self.app.db timeInID:timeIn.timeInID];
    item.lTimeOut.text = timeOut != nil ? [Time formatTime:self.app.settingDisplayTimeFormat time:timeOut.time] : @"NO OUT";
    Schedules *schedule = [Get schedule:self.app.db scheduleID:timeIn.scheduleID];
    item.lSchedule.text = [NSString stringWithFormat:@"%@\n%@", [Time formatTime:self.app.settingDisplayTimeFormat time:schedule.timeIn], [Time formatTime:self.app.settingDisplayTimeFormat time:schedule.timeOut]];
    [item layoutIfNeeded];
    return item;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TimeIn *timeIn = self.timeInList[indexPath.row];
    TimeOut *timeOut = [Get timeOut:self.app.db timeInID:timeIn.timeInID];
    if(timeOut == nil) {
        [View showAlert:self.main.navigationController.view message:[NSString stringWithFormat:@"Please %@ first.", self.app.conventionTimeOut.lowercaseString] duration:2];
        return;
    }
    AttendanceSummaryViewController *vcAttendanceSummary = [self.storyboard instantiateViewControllerWithIdentifier:@"vcAttendanceSummary"];
    vcAttendanceSummary.timeIn = [NSString stringWithFormat:@"%@ %@", [Time formatDate:self.app.settingDisplayDateFormat date:timeIn.date], [Time formatTime:self.app.settingDisplayTimeFormat time:timeIn.time]];
    vcAttendanceSummary.timeOut = [NSString stringWithFormat:@"%@ %@", [Time formatDate:self.app.settingDisplayDateFormat date:timeOut.date], [Time formatTime:self.app.settingDisplayTimeFormat time:timeOut.time]];
    vcAttendanceSummary.workHours = [[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", timeOut.date, timeOut.time]] timeIntervalSinceDate:[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", timeIn.date, timeIn.time]]];
    vcAttendanceSummary.breakHours = 0;
    for(BreakIn *breakIn in [Load breakIn:self.app.db timeInID:timeIn.timeInID]) {
        BreakOut *breakOut = [Get breakOut:self.app.db breakInID:breakIn.breakInID];
        vcAttendanceSummary.breakHours += [[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", breakOut.date, breakOut.time]] timeIntervalSinceDate:[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", breakIn.date, breakIn.time]]];
    }
    vcAttendanceSummary.signature = [File imageFromDocument:timeOut.signature];
    vcAttendanceSummary.isHistory = YES;
    [self.navigationController pushViewController:vcAttendanceSummary animated:YES];
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    _selectedDate = selectedDate;
    [self onRefresh];
}

@end
