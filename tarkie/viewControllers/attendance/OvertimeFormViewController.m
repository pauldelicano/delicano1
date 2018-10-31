#import "OvertimeFormViewController.h"
#import "Overtime+CoreDataClass.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Load.h"
#import "Update.h"
#import "View.h"
#import "Time.h"
#import "MessageDialogViewController.h"
#import "OvertimeFormTableViewCell.h"

@interface OvertimeFormViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSMutableArray<OvertimeReasons *> *overtimeReasons;
@property (strong, nonatomic) NSMutableArray *overtimeReasonIDs;
@property (nonatomic) BOOL viewWillAppear, overtimeReasonsLoaded;

@end

@implementation OvertimeFormViewController

static MessageDialogViewController *vcMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.tvOvertimeReasons.tableFooterView = UIView.alloc.init;
    self.tfRemarks.placeholder = @"Please input remarks.";
    self.overtimeReasons = NSMutableArray.alloc.init;
    self.overtimeReasonIDs = NSMutableArray.alloc.init;
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.vStatusBar.backgroundColor = THEME_PRI_DARK;
        self.vNavBar.backgroundColor = THEME_PRI;
        [self.btnSave setTitleColor:THEME_PRI forState:UIControlStateNormal];
        self.tfRemarks.highlightedBorderColor = THEME_SEC;
        [View setCornerRadiusByHeight:self.btnSave cornerRadius:0.3];
        [View setCornerRadiusByWidth:self.tfRemarks cornerRadius:0.025];
        self.lTimeInLabel.text = self.app.conventionTimeIn;
        self.lTimeOutLabel.text = self.app.conventionTimeOut;
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    [self.overtimeReasons removeAllObjects];
    [self.overtimeReasonIDs removeAllObjects];
    [self.overtimeReasons addObjectsFromArray:[Load overtimeReasons:self.app.db]];
    [self.tvOvertimeReasons reloadData];
    self.lDate.text = self.date;
    self.lSchedule.text = self.schedule;
    self.lTimeIn.text = self.timeIn;
    self.lTimeOut.text = self.timeOut;
    self.lTotalHours.text = [Time secondsToDHMS:self.workHours];
    self.lHoursEligibleForOT.text = [Time secondsToDHMS:self.workHours - self.scheduleHours];
    [self updateOvertimeForm];
}

- (void)updateOvertimeForm {
    self.tvOvertimeReasonsHeight.constant = self.tvOvertimeReasons.contentSize.height;
    [self.vContent layoutIfNeeded];
}

- (IBAction)back:(id)sender {
    vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
    vcMessage.subject = @"Cancel Overtime";
    vcMessage.message = @"Are you sure you want to cancel overtime?";
    vcMessage.negativeTitle = @"No";
    vcMessage.negativeTarget = ^{
        [View removeChildViewController:vcMessage animated:YES];
    };
    vcMessage.positiveTitle = @"Yes";
    vcMessage.positiveTarget = ^{
        [View removeChildViewController:vcMessage animated:YES];
        TimeIn *timeIn = [Get timeIn:self.app.db timeInID:self.timeInID];
        timeIn.isOvertime = NO;
        if([Update save:self.app.db]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    [View addChildViewController:self childViewController:vcMessage animated:YES];
}

- (IBAction)save:(id)sender {
    if(self.overtimeReasonIDs.count == 0) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"Overtime Reason Required";
        vcMessage.message = @"Please choose reasons.";
        vcMessage.positiveTitle = @"OK";
        vcMessage.positiveTarget = ^{
            [View removeChildViewController:vcMessage animated:YES];
        };
        [View addChildViewController:self childViewController:vcMessage animated:YES];
        return;
    }
    NSString *remarks = self.tfRemarks.text;
    if([remarks isEqualToString:@"Please input remarks."]) {
        remarks = @"";
    }
    if(remarks.length == 0) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"Overtime Remarks Required";
        vcMessage.message = @"Please input remarks.";
        vcMessage.positiveTitle = @"OK";
        vcMessage.positiveTarget = ^{
            [View removeChildViewController:vcMessage animated:YES];
        };
        [View addChildViewController:self childViewController:vcMessage animated:YES];
        return;
    }
    Overtime *overtime = [NSEntityDescription insertNewObjectForEntityForName:@"Overtime" inManagedObjectContext:self.app.db];
    overtime.overtimeID = [Get sequenceID:self.app.db entity:@"Overtime" attribute:@"overtimeID"] + 1;
    overtime.syncBatchID = self.app.syncBatchID;
    overtime.employeeID = self.app.employee.employeeID;
    overtime.timeInID = self.timeInID;
    overtime.overtimeHours = (self.workHours - self.scheduleHours) / 3600;
    overtime.overtimeReasonID = [self.overtimeReasonIDs componentsJoinedByString:@","];
    overtime.remarks = remarks;
    overtime.isSync = NO;
    TimeIn *timeIn = [Get timeIn:self.app.db timeInID:self.timeInID];
    timeIn.isOvertime = NO;
    if([Update save:self.app.db]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.overtimeReasons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OvertimeFormTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    [item.longPressGesture addTarget:self action:@selector(onLongPress:)];
    [View setCornerRadiusByHeight:item.lIcon cornerRadius:0.4];
    item.lIcon.textColor = THEME_SEC;
    CALayer *layer = item.lIcon.layer;
    layer.borderColor = [Color colorNamed:@"Grey500"].CGColor;
    layer.borderWidth = (1.0f / 568) * UIScreen.mainScreen.bounds.size.height;
    item.lIcon.text = nil;
    item.lName.text = self.overtimeReasons[indexPath.row].name;
    if(indexPath.row == self.overtimeReasons.count - 1) {
        self.overtimeReasonsLoaded = YES;
    }
    [item layoutIfNeeded];
    return item;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.overtimeReasonsLoaded) {
        self.overtimeReasonsLoaded = NO;
        [self updateOvertimeForm];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self selectOvertimeReason:indexPath];
}

- (void)onLongPress:(UILongPressGestureRecognizer *)longPressGesture {
    if(longPressGesture.state == UIGestureRecognizerStateBegan) {
        longPressGesture.state = UIGestureRecognizerStateEnded;
        NSIndexPath *indexPath = [self.tvOvertimeReasons indexPathForCell:(OvertimeFormTableViewCell *)longPressGesture.view];
        [self selectOvertimeReason:indexPath];
    }
}

- (void)selectOvertimeReason:(NSIndexPath *)indexPath {
    NSString *overtimeReasonID = [NSString stringWithFormat:@"%lld", self.overtimeReasons[indexPath.row].overtimeReasonID];
    OvertimeFormTableViewCell *item = [self.tvOvertimeReasons cellForRowAtIndexPath:indexPath];
    if([self.overtimeReasonIDs containsObject:overtimeReasonID]) {
        item.lIcon.text = nil;
        [self.overtimeReasonIDs removeObject:overtimeReasonID];
    }
    else {
        item.lIcon.text = @"";
        [self.overtimeReasonIDs addObject:overtimeReasonID];
    }
}

@end
