#import "MainViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Load.h"
#import "Update.h"
#import "File.h"
#import "View.h"
#import "Time.h"
#import "MessageDialogViewController.h"
#import "AboutViewController.h"
#import "AnnouncementsViewController.h"
#import "AnnouncementDetailsViewController.h"
#import "StoresViewController.h"
#import "OvertimeFormViewController.h"
#import "HomeViewController.h"
#import "VisitsViewController.h"
#import "VisitDetailsViewController.h"
#import "ExpenseViewController.h"
#import "InventoryViewController.h"
#import "FormsViewController.h"
#import "HistoryViewController.h"

@interface MainViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) CATransition *transition;
@property (strong, nonatomic) DrawerViewController *vcDrawer;
@property (strong, nonatomic) UIPageViewController *pvcMain;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *pages;
@property (strong, nonatomic) NSMutableArray<ViewController *> *viewControllers;
@property (strong, nonatomic) Stores *store;
@property (strong, nonatomic) ScheduleTimes *scheduleTime;
@property (strong, nonatomic) UIImage *photo, *signature;
@property (strong, nonatomic) NSString *photoFilename, *signatureFilename;
@property (strong, nonatomic) NSDate *currentDate;
@property (nonatomic) long currentPage, nextPage, syncDataCount;
@property (nonatomic) float syncDataCountFontSize;
@property (nonatomic) BOOL viewWillAppear, isLoading, isGPSRequest, isCameraRequest, proceedWithoutGPS, isTimingIn, isTimingOut;

@end

@implementation MainViewController

static MessageDialogViewController *vcSystemMessage, *vcMessage;
static LoadingDialogViewController *vcLoading;
static NSMutableArray<NSString *> *notificationRequestIdentifiers;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.transition = CATransition.animation;
    self.transition.duration = 0.5;
    self.transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    self.transition.type = kCATransitionMoveIn;
    self.transition.subtype = kCATransitionFromRight;
    self.cvPageBar.pageBarDelegate = self;
    self.pages = NSMutableArray.alloc.init;
    self.viewControllers = NSMutableArray.alloc.init;
    notificationRequestIdentifiers = NSMutableArray.alloc.init;
    for(int x = 0; x < self.childViewControllers.count; x++) {
        if([self.childViewControllers[x] isKindOfClass:UIPageViewController.class]) {
            self.pvcMain = self.childViewControllers[x];
            self.pvcMain.dataSource = self;
            self.pvcMain.delegate = self;
            for(UIView *view in self.pvcMain.view.subviews) {
                if([view isKindOfClass:UIScrollView.class]) {
                    ((UIScrollView *)view).delegate = self;
                }
            }
        }
        if([self.childViewControllers[x] isKindOfClass:DrawerViewController.class]) {
            self.vcDrawer = self.childViewControllers[x];
            self.vcDrawer.delegate = self;
            self.vcDrawer.position = DRAWER_POSITION_LEFT;
        }
    }
    self.viewWillAppear = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if(self.viewWillAppear && self.vcDrawer != nil && !self.vcDrawer.isOpen && self.vcDrawer.view.superview.frame.origin.x == 0) {
        self.vcDrawer.isOpen = YES;
        [self.vcDrawer closeDrawer];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.vStatusBar.backgroundColor = THEME_PRI_DARK;
        self.vNavBar.backgroundColor = THEME_PRI;
        self.cvPageBar.backgroundColor = THEME_PRI;
        self.vBottomBar.backgroundColor = THEME_PRI;
        [self.btnNavBarButtonsVisitsAddVisit setTitleColor:THEME_PRI forState:UIControlStateNormal];
        [self.btnNavBarButtonsExpenseNewReport setTitleColor:THEME_PRI forState:UIControlStateNormal];
        [self.btnNavBarButtonsFormsSelect setTitleColor:THEME_PRI forState:UIControlStateNormal];
        [View setCornerRadiusByHeight:self.lNavBarButtonsHomeSyncCount cornerRadius:1];
        [View setCornerRadiusByHeight:self.btnNavBarButtonsVisitsAddVisit cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.btnNavBarButtonsExpenseNewReport cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.btnNavBarButtonsFormsSelect cornerRadius:0.3];
        self.syncDataCountFontSize = self.lNavBarButtonsHomeSyncCount.font.pointSize;
        [self onRefresh];
        [self updateTimeInOut];
        [self applicationDidBecomeActive];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willPresentNotification:) name:@"UserNotificationCenterWillPresentNotification" object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didReceiveNotificationResponse:) name:@"UserNotificationCenterDidReceiveNotificationResponse" object:nil];
    }
    [self updateUnSeenAnnouncementsCount];
    [self updateSyncDataCount];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)onRefresh {
    [super onRefresh];
    self.app.apiKey = [Get apiKey:self.app.db];
    self.app.syncBatchID = [Get syncBatch:self.app.db].syncBatchID;
    self.app.company = [Get company:self.app.db];
    self.app.employee = [Get employee:self.app.db employeeID:[Get userID:self.app.db]];

    self.app.settingDisplayCurrencySymbol = [Get settingCurrencySymbol:self.app.db teamID:self.app.employee.teamID];
    self.app.settingDisplayDateFormat = [Get settingDateFormat:self.app.db teamID:self.app.employee.teamID];
    self.app.settingDisplayTimeFormat = [Get settingTimeFormat:self.app.db teamID:self.app.employee.teamID];
    self.app.settingDisplayDistanceUOM = [Get settingTeam:self.app.db settingID:SETTING_DISPLAY_DISTANCE_UOM teamID:self.app.employee.teamID].value;

    self.app.settingLocationTracking = [Get isSettingEnabled:self.app.db settingID:SETTING_LOCATION_TRACKING teamID:self.app.employee.teamID];
    self.app.settingLocationGPSTracking = [Get isSettingEnabled:self.app.db settingID:SETTING_LOCATION_GPS_TRACKING teamID:self.app.employee.teamID];
    self.app.settingLocationGPSTrackingInterval = [Get settingTeam:self.app.db settingID:SETTING_LOCATION_GPS_TRACKING_INTERVAL teamID:self.app.employee.teamID].value.intValue;
    self.app.settingLocationGeoTagging = [Get isSettingEnabled:self.app.db settingID:SETTING_LOCATION_GEO_TAGGING teamID:self.app.employee.teamID];
    self.app.settingLocationAlerts = [Get isSettingEnabled:self.app.db settingID:SETTING_LOCATION_ALERTS teamID:self.app.employee.teamID];

    self.app.settingStoreAdd = [Get isSettingEnabled:self.app.db settingID:SETTING_STORE_ADD teamID:self.app.employee.teamID];
    self.app.settingStoreEdit = [Get isSettingEnabled:self.app.db settingID:SETTING_STORE_EDIT teamID:self.app.employee.teamID];
    self.app.settingStoreDisplayLongName = [Get isSettingEnabled:self.app.db settingID:SETTING_STORE_DISPLAY_LONG_NAME teamID:self.app.employee.teamID];

    self.app.settingAttendanceStore = [Get isSettingEnabled:self.app.db settingID:SETTING_ATTENDANCE_STORE teamID:self.app.employee.teamID];
    self.app.settingAttendanceSchedule = [Get isSettingEnabled:self.app.db settingID:SETTING_ATTENDANCE_SCHEDULE teamID:self.app.employee.teamID];
    self.app.settingAttendanceMultipleTimeInOut = [Get isSettingEnabled:self.app.db settingID:SETTING_ATTENDANCE_MULTIPLE_TIME_IN_OUT teamID:self.app.employee.teamID];
    self.app.settingAttendanceTimeInPhoto = [Get isSettingEnabled:self.app.db settingID:SETTING_ATTENDANCE_TIME_IN_PHOTO teamID:self.app.employee.teamID];
    self.app.settingAttendanceTimeOutPhoto = [Get isSettingEnabled:self.app.db settingID:SETTING_ATTENDANCE_TIME_OUT_PHOTO teamID:self.app.employee.teamID];
    self.app.settingAttendanceTimeOutSignature = [Get isSettingEnabled:self.app.db settingID:SETTING_ATTENDANCE_TIME_OUT_SIGNATURE teamID:self.app.employee.teamID];
    self.app.settingAttendanceOdometerPhoto = [Get isSettingEnabled:self.app.db settingID:SETTING_ATTENDANCE_ODOMETER_PHOTO teamID:self.app.employee.teamID];
    self.app.settingAttendanceAddEditLeaves = [Get isSettingEnabled:self.app.db settingID:SETTING_ATTENDANCE_ADD_EDIT_LEAVES teamID:self.app.employee.teamID];
    self.app.settingAttendanceAddEditRestDays = [Get isSettingEnabled:self.app.db settingID:SETTING_ATTENDANCE_ADD_EDIT_REST_DAYS teamID:self.app.employee.teamID];
    self.app.settingAttendanceGracePeriod = [Get isSettingEnabled:self.app.db settingID:SETTING_ATTENDANCE_GRACE_PERIOD teamID:self.app.employee.teamID];
    self.app.settingAttendanceGracePeriodDuration = [Get settingTeam:self.app.db settingID:SETTING_ATTENDANCE_GRACE_PERIOD_DURATION teamID:self.app.employee.teamID].value.intValue;
    self.app.settingAttendanceOvertimeMinimumDuration = [Get settingTeam:self.app.db settingID:SETTING_ATTENDANCE_OVERTIME_MINIMUM_DURATION teamID:self.app.employee.teamID].value.intValue;
    self.app.settingAttendanceNotificationLateOpening = [Get isSettingEnabled:self.app.db settingID:SETTING_ATTENDANCE_NOTIFICATION_LATE_OPENING teamID:self.app.employee.teamID];
    self.app.settingAttendanceNotificationTimeOut = [Get isSettingEnabled:self.app.db settingID:SETTING_ATTENDANCE_NOTIFICATION_TIME_OUT teamID:self.app.employee.teamID];

    self.app.settingVisitsAdd = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_ADD teamID:self.app.employee.teamID];
    self.app.settingVisitsEditAfterCheckOut = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_EDIT_AFTER_CHECK_OUT teamID:self.app.employee.teamID];
    self.app.settingVisitsReschedule = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_RESCHEDULE teamID:self.app.employee.teamID];
    self.app.settingVisitsDelete = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_DELETE teamID:self.app.employee.teamID];
    self.app.settingVisitsInvoice = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_INVOICE teamID:self.app.employee.teamID];
    self.app.settingVisitsDeliveries = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_DELIVERIES teamID:self.app.employee.teamID];
    self.app.settingVisitsNotes = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_NOTES teamID:self.app.employee.teamID];
    self.app.settingVisitsNotesForCompleted = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_NOTES_FOR_COMPLETED teamID:self.app.employee.teamID];
    self.app.settingVisitsNotesForNotCompleted = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_NOTES_FOR_COMPLETED teamID:self.app.employee.teamID];
    self.app.settingVisitsNotesForCanceled = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_NOTES_FOR_CANCELED teamID:self.app.employee.teamID];
    self.app.settingVisitsNotesAsAddress = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_NOTES_AS_ADDRESS teamID:self.app.employee.teamID];
    self.app.settingVisitsParallelCheckInOut = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_PARALLEL_CHECK_IN_OUT teamID:self.app.employee.teamID];
    self.app.settingVisitsCheckInPhoto = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_CHECK_IN_PHOTO teamID:self.app.employee.teamID];
    self.app.settingVisitsCheckOutPhoto = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_CHECK_OUT_PHOTO teamID:self.app.employee.teamID];
    self.app.settingVisitsSMSSending = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_SMS_SENDING teamID:self.app.employee.teamID];
    self.app.settingVisitAutoPublishPhotos = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_AUTO_PUBLISH_PHOTOS teamID:self.app.employee.teamID];
    self.app.settingVisitsAlertNoCheckOut = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_ALERT_NO_CHECK_OUT teamID:self.app.employee.teamID];
    self.app.settingVisitsAlertNoCheckOutDistance = [Get settingTeam:self.app.db settingID:SETTING_VISITS_ALERT_NO_CHECK_OUT_DISTANCE teamID:self.app.employee.teamID].value.intValue;
    self.app.settingVisitsAlertNoMovement = [Get isSettingEnabled:self.app.db settingID:SETTING_VISIT_ALERT_NO_MOVEMENT teamID:self.app.employee.teamID];
    self.app.settingVisitsAlertNoMovementDuration = [Get settingTeam:self.app.db settingID:SETTING_VISIT_ALERT_NO_MOVEMENT_DURATION teamID:self.app.employee.teamID].value.intValue;
    self.app.settingVisitsAlertOverstaying = [Get isSettingEnabled:self.app.db settingID:SETTING_VISIT_ALERT_OVERSTAYING teamID:self.app.employee.teamID];
    self.app.settingVisitsAlertOverstayingDuration = [Get settingTeam:self.app.db settingID:SETTING_VISIT_ALERT_OVERSTAYING_DURATION teamID:self.app.employee.teamID].value.intValue;

    self.app.settingExpenseNotes = [Get isSettingEnabled:self.app.db settingID:SETTING_EXPENSE_NOTES teamID:self.app.employee.teamID];
    self.app.settingExpenseOriginDestination = [Get isSettingEnabled:self.app.db settingID:SETTING_EXPENSE_ORIGIN_DESTINATION teamID:self.app.employee.teamID];
    self.app.settingExpenseCostPerLiter = [Get settingTeam:self.app.db settingID:SETTING_EXPENSE_COST_PER_LITER teamID:self.app.employee.teamID].value.intValue;

    self.app.settingInventoryTrackingV2 = [Get isSettingEnabled:self.app.db settingID:SETTING_INVENTORY_TRACKING_V2 teamID:self.app.employee.teamID];
    self.app.settingInventoryTrackingV1 = [Get isSettingEnabled:self.app.db settingID:SETTING_INVENTORY_TRACKING_V1 teamID:self.app.employee.teamID];
    self.app.settingInventoryTradeCheck = [Get isSettingEnabled:self.app.db settingID:SETTING_INVENTORY_TRADE_CHECK teamID:self.app.employee.teamID];
    self.app.settingInventorySalesAndOfftake = [Get isSettingEnabled:self.app.db settingID:SETTING_INVENTORY_SALES_AND_OFFTAKE teamID:self.app.employee.teamID];
    self.app.settingInventoryOrders = [Get isSettingEnabled:self.app.db settingID:SETTING_INVENTORY_ORDERS teamID:self.app.employee.teamID];
    self.app.settingInventoryDeliveries = [Get isSettingEnabled:self.app.db settingID:SETTING_VISITS_DELIVERIES teamID:self.app.employee.teamID];
    self.app.settingInventoryAdjustments = [Get isSettingEnabled:self.app.db settingID:SETTING_INVENTORY_ADJUSTMENTS teamID:self.app.employee.teamID];
    self.app.settingInventoryPhysicalCount = [Get isSettingEnabled:self.app.db settingID:SETTING_INVENTORY_PHYSICAL_COUNT teamID:self.app.employee.teamID];
    self.app.setttingInventoryPhysicalCountTheoretical = [Get isSettingEnabled:self.app.db settingID:SETTING_INVENTORY_PHYSICAL_COUNT_THEORETICAL teamID:self.app.employee.teamID];
    self.app.settingInventoryPullOuts = [Get isSettingEnabled:self.app.db settingID:SETTING_INVENTORY_PULL_OUTS teamID:self.app.employee.teamID];
    self.app.settingInventoryReturns = [Get isSettingEnabled:self.app.db settingID:SETTING_INVENTORY_RETURNS teamID:self.app.employee.teamID];
    self.app.settingInventoryStocksOnHand = [Get isSettingEnabled:self.app.db settingID:SETTING_INVENTORY_STOCKS_ON_HAND teamID:self.app.employee.teamID];

    self.app.conventionEmployees = [Get conventionName:self.app.db conventionID:CONVENTION_EMPLOYEES];
    self.app.conventionStores = [Get conventionName:self.app.db conventionID:CONVENTION_STORES];
    self.app.conventionTimeIn = [Get conventionName:self.app.db conventionID:CONVENTION_TIME_IN];
    self.app.conventionTimeOut = [Get conventionName:self.app.db conventionID:CONVENTION_TIME_OUT];
    self.app.conventionVisits = [Get conventionName:self.app.db conventionID:CONVENTION_VISITS];
    self.app.conventionTeams = [Get conventionName:self.app.db conventionID:CONVENTION_TEAMS];
    self.app.conventionInvoice = [Get conventionName:self.app.db conventionID:CONVENTION_INVOICE];
    self.app.conventionDeliveries = [Get conventionName:self.app.db conventionID:CONVENTION_DELIVERIES];
    self.app.conventionReturns = [Get conventionName:self.app.db conventionID:CONVENTION_RETURNS];
    self.app.conventionSales = [Get conventionName:self.app.db conventionID:CONVENTION_SALES];

    self.app.moduleAttendance = [Get isModuleEnabled:self.app.db moduleID:MODULE_ATTENDANCE];
    self.app.moduleVisits = [Get isModuleEnabled:self.app.db moduleID:MODULE_VISITS];
    self.app.moduleExpense = [Get isModuleEnabled:self.app.db moduleID:MODULE_EXPENSE];
    self.app.moduleInventory = [Get isModuleEnabled:self.app.db moduleID:MODULE_INVENTORY];
    self.app.moduleForms = [Get isModuleEnabled:self.app.db moduleID:MODULE_FORMS];

    self.vcDrawer.company = self.app.company;
    self.vcDrawer.employee = self.app.employee;
    self.vcDrawer.menus = [Load drawerMenus:self.app.db];

    [self.pages removeAllObjects];
    [self.viewControllers removeAllObjects];
    [self.pages addObjectsFromArray:[Load modulePages:self.app.db]];
    for(int x = 0; x < self.pages.count; x++) {
        [self.viewControllers addObject:[self.storyboard instantiateViewControllerWithIdentifier:[self.pages[x] objectForKey:@"viewController"]]];
    }

    self.cvPageBar.pages = self.pages;
    [self.cvPageBar reloadData];

    [self.app.userNotificationCenter removePendingNotificationRequestsWithIdentifiers:notificationRequestIdentifiers];
    [notificationRequestIdentifiers removeAllObjects];
    NSArray<Announcements *> *announcements = [Load announcements:self.app.db searchFilter:nil isScheduled:NO];
    for(int x = 0; x < announcements.count; x++) {
        NSMutableDictionary *userInfo = NSMutableDictionary.alloc.init;
        [userInfo setObject:@"ANNOUNCEMENT" forKey:@"NOTIFICATION_TYPE"];
        [userInfo setObject:[NSString stringWithFormat:@"%lld", announcements[x].announcementID] forKey:@"NOTIFICATION_ID"];
        UNMutableNotificationContent *objNotificationContent = UNMutableNotificationContent.alloc.init;
        objNotificationContent.title = announcements[x].subject;
        objNotificationContent.body = announcements[x].message;
        objNotificationContent.sound = [UNNotificationSound soundNamed:@"Announcement.m4a"];
        objNotificationContent.userInfo = userInfo;
        [self.app.userNotificationCenter addNotificationRequest:[UNNotificationRequest requestWithIdentifier:[userInfo objectForKey:@"NOTIFICATION_ID"] content:objNotificationContent trigger:[UNTimeIntervalNotificationTrigger triggerWithTimeInterval:[[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", announcements[x].scheduledDate, announcements[x].scheduledTime]] timeIntervalSinceNow] repeats:NO]] withCompletionHandler:^(NSError * _Nullable error) {
            if(error) {
                NSLog(@"error: main addNotificationRequest - %@", error.localizedDescription);
                return;
            }
            [notificationRequestIdentifiers addObject:[userInfo objectForKey:@"NOTIFICATION_ID"]];
        }];
    }
}

- (void)updateTimeInOut {
    self.isTimeIn = [Get isTimeIn:self.app.db];
    NSString *name = !self.isTimeIn ? @"Time In" : @"Time Out";
    NSString *icon = !self.isTimeIn ? @"\uf185" : @"\uf186";
    icon = nil;
    [self.vcDrawer.menus[MENU_TIME_IN_OUT - 1] setValue:icon == nil ? [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", @"Menu", [name stringByReplacingOccurrencesOfString:@" " withString:@""]]] : icon forKey:@"icon"];
    if([name isEqualToString:@"Time In"]) {
        name = self.app.conventionTimeIn;
    }
    if([name isEqualToString:@"Time Out"]) {
        name = self.app.conventionTimeOut;
    }
    [self.vcDrawer.menus[MENU_TIME_IN_OUT - 1] setValue:name forKey:@"name"];
    [self.vcDrawer onRefresh];
    TimeIn *timeIn = [Get timeIn:self.app.db];
    if(timeIn != nil && timeIn.isOvertime) {
        Schedules *schedule = [Get schedule:self.app.db scheduleID:timeIn.scheduleID];
        TimeOut *timeOut = [Get timeOut:self.app.db timeInID:timeIn.timeInID];
        NSDate *scheduleTimeIn = [Time getDateFromString:[NSString stringWithFormat:@"%@ %@", schedule.scheduleDate, schedule.timeIn]];
        NSDate *scheduleTimeOut = [Time getDateFromString:[NSString stringWithFormat:@"%@ %@", schedule.scheduleDate, schedule.timeOut]];
        NSDate *actualTimeIn = [Time dateRemoveSeconds:[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", timeIn.date, timeIn.time]]];
        NSDate *actualTimeOut = [Time dateRemoveSeconds:[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", timeOut.date, timeOut.time]]];
        if([scheduleTimeOut timeIntervalSinceDate:scheduleTimeIn] < 0) {
            scheduleTimeOut = [scheduleTimeOut dateByAddingTimeInterval:60 * 60 * 24];
        }
        NSTimeInterval scheduleHours = [scheduleTimeOut timeIntervalSinceDate:scheduleTimeIn];
        NSTimeInterval workHours = [actualTimeOut timeIntervalSinceDate:actualTimeIn];
        OvertimeFormViewController *vcOvertimeForm = [self.storyboard instantiateViewControllerWithIdentifier:@"vcOvertimeForm"];
        vcOvertimeForm.timeInID = timeIn.timeInID;
        vcOvertimeForm.date = [Time formatDate:self.app.settingDisplayDateFormat date:timeIn.date];
        vcOvertimeForm.schedule = [NSString stringWithFormat:@"%@ - %@", [Time formatTime:self.app.settingDisplayTimeFormat time:schedule.timeIn], [Time formatTime:self.app.settingDisplayTimeFormat time:schedule.timeOut]];
        vcOvertimeForm.timeIn = [Time formatTime:self.app.settingDisplayTimeFormat time:timeIn.time];
        vcOvertimeForm.timeOut = [Time formatTime:self.app.settingDisplayTimeFormat time:timeOut.time];
        vcOvertimeForm.scheduleHours = scheduleHours;
        vcOvertimeForm.workHours = workHours;
        [self.navigationController pushViewController:vcOvertimeForm animated:YES];
    }
}

- (void)updateUnSeenAnnouncementsCount {
    long unSeenAnnouncementsCount = [Get unSeenAnnouncementsCount:self.app.db];
    self.lNavBarButtonsHomeAnnouncementsCount.text = [NSString stringWithFormat:@"%ld", unSeenAnnouncementsCount];
    self.lNavBarButtonsHomeAnnouncementsCount.hidden = unSeenAnnouncementsCount == 0;
    CGFloat pointSize = self.syncDataCountFontSize;
    for(int x = 0; x < self.lNavBarButtonsHomeAnnouncementsCount.text.length; x++) {
        if(x > 1) {
            pointSize *= 0.7;
        }
    }
    self.lNavBarButtonsHomeAnnouncementsCount.font = [UIFont fontWithName:self.lNavBarButtonsHomeAnnouncementsCount.font.fontName size:pointSize];
    [self.lNavBarButtonsHomeAnnouncementsCount setNeedsLayout];
    [self.lNavBarButtonsHomeAnnouncementsCount layoutIfNeeded];
    [View setCornerRadiusByHeight:self.lNavBarButtonsHomeAnnouncementsCount cornerRadius:1];
}

- (void)updateSyncDataCount {
    self.syncDataCount = [Get syncTotalCount:self.app.db];
    self.lNavBarButtonsHomeSyncCount.text = [NSString stringWithFormat:@"%ld", self.syncDataCount];
    self.lNavBarButtonsHomeSyncCount.hidden = self.syncDataCount == 0;
    CGFloat pointSize = self.syncDataCountFontSize;
    for(int x = 0; x < self.lNavBarButtonsHomeSyncCount.text.length; x++) {
        if(x > 1) {
            pointSize *= 0.7;
        }
    }
    self.lNavBarButtonsHomeSyncCount.font = [UIFont fontWithName:self.lNavBarButtonsHomeSyncCount.font.fontName size:pointSize];
    [self.lNavBarButtonsHomeSyncCount setNeedsLayout];
    [self.lNavBarButtonsHomeSyncCount layoutIfNeeded];
    [View setCornerRadiusByHeight:self.lNavBarButtonsHomeSyncCount cornerRadius:1];
}

- (BOOL)applicationDidBecomeActive {
    [View removeView:vcSystemMessage.view animated:YES];
    if(self.isLoading) {
        return NO;
    }
    if([self timeSecurity]) {
        return NO;
    }
    if(self.isGPSRequest) {
        if([self gpsRequest]) {
            return NO;
        }
    }
    if(self.isCameraRequest) {
        if([self cameraRequest]) {
            return NO;
        }
    }
    if(self.isTimeIn) {
        if([self gpsRequest]) {
            return NO;
        }
        [self.app startUpdatingLocation];
    }
    else {
        [self.app stopUpdatingLocation];
    }
    if(self.isTimingIn) {
        self.isTimingIn = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.125 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self timeIn];
        });
    }
    if(self.isTimingOut) {
        self.isTimingOut = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.125 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self timeOut];
        });
    }
    return YES;
}

- (void)willPresentNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if([[userInfo objectForKey:@"NOTIFICATION_TYPE"] isEqualToString:@"ANNOUNCEMENT"]) {
        [self updateUnSeenAnnouncementsCount];
    }
}

- (void)didReceiveNotificationResponse:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if([[userInfo objectForKey:@"NOTIFICATION_TYPE"] isEqualToString:@"ANNOUNCEMENT"]) {
        AnnouncementDetailsViewController *vcAnnouncementDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"vcAnnouncementDetails"];
        vcAnnouncementDetails.announcement = [Get announcement:self.app.db announcementID:[[userInfo objectForKey:@"NOTIFICATION_ID"] intValue]];
        [self.navigationController pushViewController:vcAnnouncementDetails animated:YES];
    }
}

- (IBAction)drawer:(id)sender {
    [self.vcDrawer openDrawer];
}

- (IBAction)homeAnnouncements:(id)sender {
    AnnouncementsViewController *vcAnnouncements = [self.storyboard instantiateViewControllerWithIdentifier:@"vcAnnouncements"];
    [self.navigationController pushViewController:vcAnnouncements animated:YES];
}

- (IBAction)homeSync:(id)sender {
    if(self.syncDataCount == 0) {
        return;
    }
    vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
    vcMessage.subject = @"Sync Data";
    vcMessage.message = [NSString stringWithFormat:@"You have %ld unsaved transaction. Do you want to send it to the server now?", self.syncDataCount];
    vcMessage.negativeTitle = @"Cancel";
    vcMessage.negativeTarget = ^{
        [View removeView:vcMessage.view animated:YES];
    };
    vcMessage.positiveTitle = @"Yes";
    vcMessage.positiveTarget = ^{
        [View removeView:vcMessage.view animated:YES];
        vcLoading = [self.storyboard instantiateViewControllerWithIdentifier:@"vcLoading"];
        vcLoading.delegate = self;
        vcLoading.action = LOADING_ACTION_SYNC_DATA;
        [View addSubview:self.view subview:vcLoading.view animated:YES];
        self.isLoading = YES;
    };
    [View addSubview:self.view subview:vcMessage.view animated:YES];
}

- (IBAction)visitsDate:(id)sender {
    NSLog(@"paul: visitsDate");
}

- (IBAction)visitsAddVisit:(id)sender {
    NSLog(@"paul: visitsAddVisit");
}

- (IBAction)expenseNewReport:(id)sender {
    NSLog(@"paul: expenseNewReport");
}

- (IBAction)formsSearch:(id)sender {
    NSLog(@"paul: formsSearch");
}

- (IBAction)formsSelect:(id)sender {
    NSLog(@"paul: formsSelect");
}

- (IBAction)historyDate:(id)sender {
    NSLog(@"paul: historyDate");
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if(self.currentPage == 0) {
        return nil;
    }
    return self.viewControllers[self.currentPage - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if(self.currentPage == self.viewControllers.count - 1) {
        return nil;
    }
    return self.viewControllers[self.currentPage + 1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<ViewController *> *)pendingViewControllers {
    self.nextPage = [self.viewControllers indexOfObject:pendingViewControllers.lastObject];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if(finished && completed) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.nextPage inSection:0];
        [self.cvPageBar selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionLeft];
        [self.cvPageBar collectionView:self.cvPageBar didSelectItemAtIndexPath:indexPath];
    }
}

- (void)onPageBarSelect:(long)page {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.currentPage = page;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.pvcMain setViewControllers:@[self.viewControllers[self.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            self.vNavBarButtonsHome.hidden = ![self.viewControllers[self.currentPage] isKindOfClass:HomeViewController.class];
            self.vNavBarButtonsVisits.hidden = ![self.viewControllers[self.currentPage] isKindOfClass:VisitsViewController.class];
            self.vNavBarButtonsExpense.hidden = ![self.viewControllers[self.currentPage] isKindOfClass:ExpenseViewController.class];
            self.vNavBarButtonsInventory.hidden = ![self.viewControllers[self.currentPage] isKindOfClass:InventoryViewController.class];
            self.vNavBarButtonsForms.hidden = ![self.viewControllers[self.currentPage] isKindOfClass:FormsViewController.class];
            self.vNavBarButtonsHistory.hidden = ![self.viewControllers[self.currentPage] isKindOfClass:HistoryViewController.class];
        });
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
    else if(self.currentPage == self.viewControllers.count - 1 && scrollView.contentOffset.x > scrollView.bounds.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if(self.currentPage == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width) {
        *targetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
    else if(self.currentPage == self.viewControllers.count - 1 && scrollView.contentOffset.x >= scrollView.bounds.size.width) {
        *targetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
}

- (void)onDrawerMenuSelect:(int)menu {
    [self.vcDrawer closeDrawer];
    switch(menu) {
        case MENU_TIME_IN_OUT: {
            if(!self.isTimeIn) {
                [self timeIn];
            }
            else {
                if([Get isCheckIn:self.app.db]) {
                    CheckIn *checkIn = [Get checkIn:self.app.db];
                    Visits *visit = [Get visit:self.app.db visitID:checkIn.visitID];
                    NSString *visitDate = [Time formatDate:self.app.settingDisplayDateFormat date:checkIn.date];
                    NSString *message = [NSString stringWithFormat:@"You are currently checked-in at %@ on %@. Please check-out first to continue.", visit.name, visitDate];
                    NSMutableAttributedString *attributedText = [NSMutableAttributedString.alloc initWithString:message];
                    vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
                    NSRange range = NSMakeRange(32, visit.name.length);
                    [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size:self.lNavBarButtonsHistoryDate.font.pointSize] range:range];
                    range = NSMakeRange(36 + visit.name.length, visitDate.length);
                    [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size:self.lNavBarButtonsHistoryDate.font.pointSize] range:range];
                    vcMessage.subject = @"Currently Checked-in";
                    vcMessage.attributedMessage = attributedText;
                    vcMessage.negativeTitle = @"Cancel";
                    vcMessage.negativeTarget = ^{
                        [View removeView:vcMessage.view animated:YES];
                    };
                    vcMessage.positiveTitle = @"View";
                    vcMessage.positiveTarget = ^{
                        [View removeView:vcMessage.view animated:YES];
                        VisitDetailsViewController *vcVisitDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"vcVisitDetails"];
                        vcVisitDetails.main = self;
                        vcVisitDetails.visit = visit;
                        [self.navigationController pushViewController:vcVisitDetails animated:YES];
                    };
                    [View addSubview:self.view subview:vcMessage.view animated:YES];
                }
                else {
                    vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
                    vcMessage.subject = @"Confirm Time Out";
                    vcMessage.message = @"Do you want to time out?";
                    vcMessage.negativeTitle = @"Cancel";
                    vcMessage.negativeTarget = ^{
                        [View removeView:vcMessage.view animated:YES];
                    };
                    vcMessage.positiveTitle = @"Yes";
                    vcMessage.positiveTarget = ^{
                        [View removeView:vcMessage.view animated:YES];
                        [self timeOut];
                    };
                    [View addSubview:self.view subview:vcMessage.view animated:YES];
                }
            }
            break;
        }
        case MENU_BREAKS: {
            UITextField *tfTest = UITextField.alloc.init;
            [self.view addSubview:tfTest];
            [tfTest becomeFirstResponder];
            break;
        }
        case MENU_STORES: {
            StoresViewController *vcStores = [self.storyboard instantiateViewControllerWithIdentifier:@"vcStores"];
            vcStores.action = STORE_ACTION_CONTACTS;
            [self.navigationController pushViewController:vcStores animated:YES];
            break;
        }
        case MENU_UPDATE_MASTER_FILE: {
            vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
            vcMessage.subject = @"Update Master File";
            vcMessage.message = @"Do you want to download the latest master file?";
            vcMessage.negativeTitle = @"Cancel";
            vcMessage.negativeTarget = ^{
                [View removeView:vcMessage.view animated:YES];
            };
            vcMessage.positiveTitle = @"Yes";
            vcMessage.positiveTarget = ^{
                [View removeView:vcMessage.view animated:YES];
                vcLoading = [self.storyboard instantiateViewControllerWithIdentifier:@"vcLoading"];
                vcLoading.delegate = self;
                vcLoading.action = LOADING_ACTION_UPDATE_MASTER_FILE;
                [View addSubview:self.view subview:vcLoading.view animated:YES];
                self.isLoading = YES;
            };
            [View addSubview:self.view subview:vcMessage.view animated:YES];
            break;
        }
        case MENU_SEND_BACKUP_DATA: {
            vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
            vcMessage.subject = @"Send Backup Data";
            vcMessage.message = @"Do you want to send backup data?";
            vcMessage.negativeTitle = @"Cancel";
            vcMessage.negativeTarget = ^{
                [View removeView:vcMessage.view animated:YES];
            };
            vcMessage.positiveTitle = @"Yes";
            vcMessage.positiveTarget = ^{
                [View removeView:vcMessage.view animated:YES];
                vcLoading = [self.storyboard instantiateViewControllerWithIdentifier:@"vcLoading"];
                vcLoading.delegate = self;
                vcLoading.action = LOADING_ACTION_SEND_BACKUP_DATA;
                [View addSubview:self.view subview:vcLoading.view animated:YES];
                self.isLoading = YES;
            };
            [View addSubview:self.view subview:vcMessage.view animated:YES];
            break;
        }
        case MENU_BACKUP_DATA: {
            vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
            vcMessage.subject = @"Backup Data";
            vcMessage.message = @"Backup your data to your storage. This data will be restored once you clear data/uninstall your app. Are you sure you want to backup your data?";
            vcMessage.negativeTitle = @"Cancel";
            vcMessage.negativeTarget = ^{
                [View removeView:vcMessage.view animated:YES];
            };
            vcMessage.positiveTitle = @"Yes";
            vcMessage.positiveTarget = ^{
                [View removeView:vcMessage.view animated:YES];
            };
            [View addSubview:self.view subview:vcMessage.view animated:YES];
            break;
        }
        case MENU_ABOUT: {
            [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"vcAbout"] animated:YES];
            break;
        }
        case MENU_LOGOUT: {
            if(self.isTimeIn) {
                vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
                vcMessage.subject = @"Unable to Logout";
                vcMessage.message = [NSString stringWithFormat:@"Sorry you cannnot Logout yet. Please %@ first to proceed.", self.app.conventionTimeOut];
                vcMessage.positiveTitle = @"OK";
                vcMessage.positiveTarget = ^{
                    [View removeView:vcMessage.view animated:YES];
                };
                [View addSubview:self.view subview:vcMessage.view animated:YES];
                return;
            }
            vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
            vcMessage.subject = @"Confirm Logout";
            vcMessage.message = @"Are you sure you want to logout?";
            vcMessage.negativeTitle = @"Cancel";
            vcMessage.negativeTarget = ^{
                [View removeView:vcMessage.view animated:YES];
            };
            vcMessage.positiveTitle = @"Yes";
            vcMessage.positiveTarget = ^{
                [View removeView:vcMessage.view animated:YES];
                [Update usersLogout:self.app.db];
                [self.navigationController popViewControllerAnimated:NO];
            };
            [View addSubview:self.view subview:vcMessage.view animated:YES];
            break;
        }
    }
}

- (void)onLoadingUpdate:(int)action {
    switch(action) {
        case LOADING_ACTION_SYNC_DATA: {
            [self updateSyncDataCount];
            break;
        }
    }
}

- (void)onLoadingFinish:(int)action result:(NSString *)result {
    switch(action) {
        case LOADING_ACTION_TIME_SECURITY: {
            if(result != nil && ![result isEqualToString:@"ok"]) {
                vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
                vcMessage.subject = @"Validating Date and Time";
                vcMessage.message = @"Failed to validate date and time.";
                vcMessage.positiveTitle = @"OK";
                vcMessage.positiveTarget = ^{
                    [View removeView:vcMessage.view animated:YES];
                    self.isLoading = NO;
                    [self applicationDidBecomeActive];
                };
                [View addSubview:self.view subview:vcMessage.view animated:NO];
                break;
            }
            self.isLoading = NO;
            [self applicationDidBecomeActive];
            break;
        }
        case LOADING_ACTION_UPDATE_MASTER_FILE: {
            if(result != nil) {
                vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
                vcMessage.subject = @"Updating Master File";
                vcMessage.message = [result isEqualToString:@"ok"] ? @"Update master file successful." : @"Failed to update master file.";
                vcMessage.positiveTitle = @"OK";
                vcMessage.positiveTarget = ^{
                    [View removeView:vcMessage.view animated:YES];
                    self.isLoading = NO;
                    [self applicationDidBecomeActive];
                };
                [View addSubview:self.view subview:vcMessage.view animated:NO];
            }
            else {
                self.isLoading = NO;
                [self applicationDidBecomeActive];
            }
            [self onRefresh];
            [self.vcDrawer onRefresh];
            break;
        }
        case LOADING_ACTION_SYNC_DATA: {
            if(result != nil) {
                vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
                vcMessage.subject = @"Syncing Data";
                vcMessage.message = [result isEqualToString:@"ok"] ? @"Sync data successful." : @"Failed to sync data.";
                vcMessage.positiveTitle = @"OK";
                vcMessage.positiveTarget = ^{
                    [View removeView:vcMessage.view animated:YES];
                    self.isLoading = NO;
                    [self applicationDidBecomeActive];
                };
                [View addSubview:self.view subview:vcMessage.view animated:NO];
            }
            else {
                self.isLoading = NO;
                [self applicationDidBecomeActive];
            }
            [self onRefresh];
            break;
        }
        case LOADING_ACTION_SEND_BACKUP_DATA: {
            if(result != nil) {
                vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
                vcMessage.subject = @"Sending Backup Data";
                vcMessage.message = [result isEqualToString:@"ok"] ? @"Send back data successful." : @"Failed to send backup data.";
                vcMessage.positiveTitle = @"OK";
                vcMessage.positiveTarget = ^{
                    [View removeView:vcMessage.view animated:YES];
                    self.isLoading = NO;
                    [self applicationDidBecomeActive];
                };
                [View addSubview:self.view subview:vcMessage.view animated:NO];
            }
            else {
                self.isLoading = NO;
                [self applicationDidBecomeActive];
            }
            [self onRefresh];
            break;
        }
    }
}

- (void)onNoGPSCancel {
    [self cancelTimeIn];
}

- (void)onNoGPSAcquired {
    [self.app.locationManager stopUpdatingLocation];
    [self timeIn];
}

- (void)onNoGPSProceed {
    [self.app.locationManager stopUpdatingLocation];
    self.proceedWithoutGPS = YES;
    [self timeIn];
}

- (void)onDropDownCancel:(int)type action:(int)action {
    switch(action) {
        case DROP_DOWN_ACTION_TIME_IN: {
            [self cancelTimeIn];
            break;
        }
        case DROP_DOWN_ACTION_TIME_OUT: {
            [self cancelTimeOut];
            break;
        }
    }
}

- (void)onDropDownSelect:(int)type action:(int)action item:(id)item {
    switch(type) {
        case DROP_DOWN_TYPE_STORE: {
            self.store = item;
            break;
        }
        case DROP_DOWN_TYPE_SCHEDULE: {
            self.scheduleTime = item;
            break;
        }
    }
    switch(action) {
        case DROP_DOWN_ACTION_TIME_IN: {
            [self timeIn];
            break;
        }
        case DROP_DOWN_ACTION_TIME_OUT: {
            [self timeOut];
            break;
        }
    }
}

- (void)onCameraCancel:(int)action {
    switch(action) {
        case CAMERA_ACTION_TIME_IN: {
            [self cancelTimeIn];
            break;
        }
        case CAMERA_ACTION_TIME_OUT: {
            [self cancelTimeOut];
            break;
        }
    }
}

- (void)onCameraCapture:(int)action image:(UIImage *)image {
    self.photo = image;
    switch(action) {
        case CAMERA_ACTION_TIME_IN: {
            [self timeIn];
            break;
        }
        case CAMERA_ACTION_TIME_OUT: {
            [self timeOut];
            break;
        }
    }
}

- (void)onAttendanceSummaryCancel {
    [self cancelTimeOut];
}

- (void)onAttendanceSummaryTimeOut:(UIImage *)image {
    self.signature = image;
    [self timeOut];
}

- (BOOL)timeSecurity {
    TimeSecurity *timeSecurity = [Get timeSecurity:self.app.db];
    NSDate *server = [Time getDateFromString:[NSString stringWithFormat:@"%@ %@", timeSecurity.serverDate, timeSecurity.serverTime]];
    NSDate *newServer = [server dateByAddingTimeInterval:fabs(timeSecurity.upTime - NSProcessInfo.processInfo.systemUptime)];
    double interval = fabs([newServer timeIntervalSinceNow]);
    NSLog(@"info: timeSecurity - %f sec, %@ - %@", interval, NSDate.date, newServer);
    if(timeSecurity == nil || interval > 60) {
        vcSystemMessage = [self.storyboard instantiateViewControllerWithIdentifier: @"vcMessage"];
        vcSystemMessage.subject = @"Time Security";
        vcSystemMessage.message = @"Device and server time do not match.";
        vcSystemMessage.positiveTitle = @"Validate";
        vcSystemMessage.positiveTarget = ^{
            [View removeView:vcSystemMessage.view animated:YES];
            vcLoading = [self.storyboard instantiateViewControllerWithIdentifier:@"vcLoading"];
            vcLoading.delegate = self;
            vcLoading.action = LOADING_ACTION_TIME_SECURITY;
            [View addSubview:self.view subview:vcLoading.view animated:YES];
            self.isLoading = YES;
        };
        [View addSubview:self.app.window subview:vcSystemMessage.view animated:YES];
        return YES;
    }
    return NO;
}

- (BOOL)gpsRequest {
    if(self.app.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [self.app.locationManager requestAlwaysAuthorization];
        return YES;
    }
    if(!CLLocationManager.locationServicesEnabled || self.app.authorizationStatus != kCLAuthorizationStatusAuthorizedAlways) {
        vcSystemMessage = [self.storyboard instantiateViewControllerWithIdentifier: @"vcMessage"];
        vcSystemMessage.subject = @"Location Services";
        vcSystemMessage.message = @"Allow location access and select \"Always\".";
        vcSystemMessage.negativeTitle = @"Cancel";
        vcSystemMessage.negativeTarget = ^{
            if(!self.isTimeIn) {
                self.isGPSRequest = NO;
                self.isTimingIn = NO;
                [self applicationDidBecomeActive];
            }
            else {
                [UIApplication.sharedApplication performSelector:@selector(suspend)];
            }
        };
        vcSystemMessage.positiveTitle = @"OK";
        vcSystemMessage.positiveTarget = ^{
//            [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"App-Prefs:root=Privacy&path=LOCATION"] options:@{} completionHandler:nil];
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        };
        [View addSubview:self.app.window subview:vcSystemMessage.view animated:YES];
        self.isGPSRequest = YES;
        return YES;
    }
    self.isGPSRequest = NO;
    return NO;
}

- (BOOL)cameraRequest {
    if([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {}];
        return YES;
    }
    if([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized) {
        vcSystemMessage = [self.storyboard instantiateViewControllerWithIdentifier: @"vcMessage"];
        vcSystemMessage.subject = @"Camera Access";
        vcSystemMessage.message = [NSString stringWithFormat:@"Please allow %@ to access camera.", APP_NAME];
        vcSystemMessage.negativeTitle = @"Cancel";
        vcSystemMessage.negativeTarget = ^{
            self.isCameraRequest = NO;
            [self applicationDidBecomeActive];
        };
        vcSystemMessage.positiveTitle = @"OK";
        vcSystemMessage.positiveTarget = ^{
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        };
        [View addSubview:self.app.window subview:vcSystemMessage.view animated:YES];
        self.isCameraRequest = YES;
        return YES;
    }
    self.isCameraRequest = NO;
    return NO;
}

- (void)timeIn {
    if(!self.app.settingAttendanceMultipleTimeInOut && [Get timeInCount:self.app.db date:[Time getFormattedDate:DATE_FORMAT date:NSDate.date]] > 0) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = [NSString stringWithFormat:@"Already %@", self.app.conventionTimeIn];
        vcMessage.message = [NSString stringWithFormat:@"You've already %@, you're not allowed to %@ anymore.", self.app.conventionTimeIn, self.app.conventionTimeIn];
        vcMessage.positiveTitle = @"OK";
        vcMessage.positiveTarget = ^{
            [View removeView:vcMessage.view animated:YES];
        };
        [View addSubview:self.view subview:vcMessage.view animated:YES];
        return;
    }
    if([self gpsRequest]) {
        self.isTimingIn = YES;
        return;
    }
    if(self.app.location == nil && !self.proceedWithoutGPS) {
        NoGPSDialogViewController *vcNoGPS = [self.storyboard instantiateViewControllerWithIdentifier: @"vcNoGPS"];
        vcNoGPS.delegate = self;
        [View addSubview:self.view subview:vcNoGPS.view animated:YES];
        [self.app startUpdatingLocation];
        return;
    }
    if(self.app.settingAttendanceStore && self.store == nil) {
        DropDownDialogViewController *vcDropDown = [self.storyboard instantiateViewControllerWithIdentifier:@"vcDropDown"];
        vcDropDown.delegate = self;
        vcDropDown.parent = self;
        vcDropDown.type = DROP_DOWN_TYPE_STORE;
        vcDropDown.action = DROP_DOWN_ACTION_TIME_IN;
        [View addSubview:self.view subview:vcDropDown.view animated:YES];
        [self addChildViewController:vcDropDown];
        return;
    }
    if(self.app.settingAttendanceSchedule) {
        Schedules *schedule = [Get schedule:self.app.db webScheduleID:0 scheduleDate:[Time getFormattedDate:DATE_FORMAT date:NSDate.date]];
        if(schedule == nil && self.scheduleTime == nil) {
            DropDownDialogViewController *vcDropDown = [self.storyboard instantiateViewControllerWithIdentifier:@"vcDropDown"];
            vcDropDown.delegate = self;
            vcDropDown.parent = self;
            vcDropDown.type = DROP_DOWN_TYPE_SCHEDULE;
            vcDropDown.action = DROP_DOWN_ACTION_TIME_IN;
            vcDropDown.items = [Load scheduleTimes:self.app.db];
            [View addSubview:self.view subview:vcDropDown.view animated:YES];
            [self addChildViewController:vcDropDown];
            return;
        }
    }
    if(self.app.settingAttendanceTimeInPhoto) {
        if([self cameraRequest]) {
            self.isTimingIn = YES;
            return;
        }
        if(self.photo == nil) {
            CameraViewController *vcCamera = [self.storyboard instantiateViewControllerWithIdentifier:@"vcCamera"];
            vcCamera.cameraDelegate = self;
            vcCamera.action = CAMERA_ACTION_TIME_IN;
            vcCamera.isRearCamera = NO;
            [self.navigationController pushViewController:vcCamera animated:NO];
            return;
        }
        if(self.photoFilename == nil) {
            self.photoFilename = [NSString stringWithFormat:@"%lld-%.0f%@", self.app.employee.employeeID, [NSDate.date timeIntervalSince1970], @".png"];
            if([File saveImageFromImage:[File documentPath:self.photoFilename] image:self.photo] == nil) {
                self.photo = nil;
                self.photoFilename = nil;
                self.isTimingIn = YES;
                [self applicationDidBecomeActive];
                return;
            }
        }
    }
    if(self.currentDate == nil) {
        self.currentDate = NSDate.date;
    }
    NSString *date = [Time getFormattedDate:DATE_FORMAT date:self.currentDate];
    NSString *time = [Time getFormattedDate:TIME_FORMAT date:self.currentDate];
    Sequences *sequence = [Get sequence:self.app.db];
    TimeIn *timeIn = [NSEntityDescription insertNewObjectForEntityForName:@"TimeIn" inManagedObjectContext:self.app.db];
    if(!self.proceedWithoutGPS && self.app.location != nil) {
        int64_t gpsID = [Update gpsSave:self.app.db location:self.app.location];
        if(gpsID != 0) {
            timeIn.gpsID = gpsID;
        }
    }
    if(self.app.settingAttendanceStore) {
        timeIn.storeID = self.store.storeID;
    }
    if(self.app.settingAttendanceSchedule) {
        Schedules *schedule = [Get schedule:self.app.db webScheduleID:0 scheduleDate:date];
        if(schedule == nil) {
            schedule = [NSEntityDescription insertNewObjectForEntityForName:@"Schedules" inManagedObjectContext:self.app.db];
            sequence.schedules += 1;
            schedule.scheduleID = sequence.schedules;
            schedule.syncBatchID = self.app.syncBatchID;
            schedule.employeeID = self.app.employee.employeeID;
            schedule.date = date;
            schedule.time = time;
            schedule.scheduleDate = date;
            schedule.timeIn = self.scheduleTime.timeIn;
            schedule.timeOut = self.scheduleTime.timeOut;
            schedule.isFromWeb = NO;
            schedule.isActive = YES;
            schedule.isSync = NO;
        }
        timeIn.scheduleID = schedule.scheduleID;
    }
    if(self.app.settingAttendanceTimeInPhoto) {
        timeIn.photo = self.photoFilename;
    }
    sequence.timeIn += 1;
    timeIn.timeInID = sequence.timeIn;
    timeIn.syncBatchID = self.app.syncBatchID;
    timeIn.employeeID = self.app.employee.employeeID;
    timeIn.date = date;
    timeIn.time = time;
    timeIn.batteryLevel = [NSString stringWithFormat:@"%f", UIDevice.currentDevice.batteryLevel];
    timeIn.isSync = NO;
    timeIn.isPhotoUpload = NO;
    timeIn.isPhotoExists = NO;
    timeIn.isPhotoDelete = NO;
    timeIn.isOvertime = NO;
    if([Update save:self.app.db]) {
        [self cancelTimeIn];
        [self updateTimeInOut];
        [self.app startUpdatingLocation];
        [self.viewControllers[self.currentPage] onRefresh];
    }
}

- (void)cancelTimeIn {
    [self.app stopUpdatingLocation];
    self.app.location = nil;
    self.proceedWithoutGPS = NO;
    self.store = nil;
    self.scheduleTime = nil;
    self.photo = nil;
    self.photoFilename = nil;
    self.currentDate = nil;
}

- (void)timeOut {
    if([self gpsRequest]) {
        self.isTimingOut = YES;
        return;
    }
    TimeIn *timeIn = [Get timeIn:self.app.db];
    if(self.app.settingAttendanceStore && self.store == nil) {
        DropDownDialogViewController *vcDropDown = [self.storyboard instantiateViewControllerWithIdentifier:@"vcDropDown"];
        vcDropDown.delegate = self;
        vcDropDown.parent = self;
        vcDropDown.type = DROP_DOWN_TYPE_STORE;
        vcDropDown.action = DROP_DOWN_ACTION_TIME_OUT;
        [View addSubview:self.view subview:vcDropDown.view animated:YES];
        [self addChildViewController:vcDropDown];
        [vcDropDown onStoresSelect:[Get store:self.app.db storeID:timeIn.storeID]];
        return;
    }
    if(self.app.settingAttendanceTimeOutPhoto) {
        if([self cameraRequest]) {
            self.isTimingOut = YES;
            return;
        }
        if(self.photo == nil) {
            CameraViewController *vcCamera = [self.storyboard instantiateViewControllerWithIdentifier:@"vcCamera"];
            vcCamera.cameraDelegate = self;
            vcCamera.action = CAMERA_ACTION_TIME_OUT;
            vcCamera.isRearCamera = NO;
            [self.navigationController pushViewController:vcCamera animated:NO];
            return;
        }
        if(self.photoFilename == nil) {
            self.photoFilename = [NSString stringWithFormat:@"%lld-%.0f%@", self.app.employee.employeeID, [NSDate.date timeIntervalSince1970], @".png"];
            if([File saveImageFromImage:[File documentPath:self.photoFilename] image:self.photo] == nil) {
                self.photo = nil;
                self.photoFilename = nil;
                self.isTimingOut = YES;
                [self applicationDidBecomeActive];
                return;
            }
        }
    }
    if(self.currentDate == nil) {
        self.currentDate = NSDate.date;
    }
    if(self.signature == nil) {
        AttendanceSummaryViewController *vcAttendanceSummary = [self.storyboard instantiateViewControllerWithIdentifier:@"vcAttendanceSummary"];
        vcAttendanceSummary.delegate = self;
        vcAttendanceSummary.timeIn = [NSString stringWithFormat:@"%@ %@", [Time formatDate:self.app.settingDisplayDateFormat date:timeIn.date], [Time formatTime:self.app.settingDisplayTimeFormat time:timeIn.time]];
        vcAttendanceSummary.timeOut = [Time getFormattedDate:[NSString stringWithFormat:@"%@ %@", self.app.settingDisplayDateFormat, self.app.settingDisplayTimeFormat] date:self.currentDate];
        vcAttendanceSummary.workHours = [[Time dateRemoveSeconds:self.currentDate] timeIntervalSinceDate:[Time dateRemoveSeconds:[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", timeIn.date, timeIn.time]]]];
        vcAttendanceSummary.breakHours = 0;
        vcAttendanceSummary.isHistory = NO;
        [self.navigationController pushViewController:vcAttendanceSummary animated:YES];
        return;
    }
    if(self.app.settingAttendanceTimeOutSignature && self.signatureFilename == nil) {
        self.signatureFilename = [NSString stringWithFormat:@"%lld-%.0f%@", self.app.employee.employeeID, [NSDate.date timeIntervalSince1970], @".png"];
        if([File saveImageFromImage:[File documentPath:self.signatureFilename] image:self.signature] == nil) {
            self.signature = nil;
            self.signatureFilename = nil;
            self.isTimingOut = YES;
            [self applicationDidBecomeActive];
            return;
        }
    }
    NSString *date = [Time getFormattedDate:DATE_FORMAT date:self.currentDate];
    NSString *time = [Time getFormattedDate:TIME_FORMAT date:self.currentDate];
    Sequences *sequence = [Get sequence:self.app.db];
    TimeOut *timeOut = [NSEntityDescription insertNewObjectForEntityForName:@"TimeOut" inManagedObjectContext:self.app.db];
    if(self.app.location != nil) {
        int64_t gpsID = [Update gpsSave:self.app.db location:self.app.location];
        if(gpsID != 0) {
            timeOut.gpsID = gpsID;
        }
    }
    if(self.app.settingAttendanceStore) {
        timeOut.storeID = self.store.storeID;
    }
    if(self.app.settingAttendanceTimeOutPhoto) {
        timeOut.photo = self.photoFilename;
    }
    if(self.app.settingAttendanceTimeOutSignature) {
        timeOut.signature = self.signatureFilename;
    }
    sequence.timeOut += 1;
    timeOut.timeOutID = sequence.timeOut;
    timeOut.syncBatchID = self.app.syncBatchID;
    timeOut.employeeID = self.app.employee.employeeID;
    timeOut.timeInID = timeIn.timeInID;
    timeOut.date = date;
    timeOut.time = time;
    timeOut.isSync = NO;
    timeOut.isPhotoUpload = NO;
    timeOut.isPhotoExists = NO;
    timeOut.isPhotoDelete = NO;
    timeOut.isSignatureUpload = NO;
    if(self.app.employee.withOvertime) {
        Schedules *schedule = [Get schedule:self.app.db scheduleID:timeIn.scheduleID];
        NSDate *scheduleTimeIn = [Time getDateFromString:[NSString stringWithFormat:@"%@ %@", schedule.scheduleDate, schedule.timeIn]];
        NSDate *scheduleTimeOut = [Time getDateFromString:[NSString stringWithFormat:@"%@ %@", schedule.scheduleDate, schedule.timeOut]];
        NSDate *actualTimeIn = [Time dateRemoveSeconds:[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", timeIn.date, timeIn.time]]];
        NSDate *actualTimeOut = [Time dateRemoveSeconds:[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", timeOut.date, timeOut.time]]];
        if([scheduleTimeOut timeIntervalSinceDate:scheduleTimeIn] < 0) {
            scheduleTimeOut = [scheduleTimeOut dateByAddingTimeInterval:60 * 60 * 24];
        }
        if(self.app.settingAttendanceOvertimeMinimumDuration * 60 > [scheduleTimeOut timeIntervalSinceDate:scheduleTimeIn] - [actualTimeOut timeIntervalSinceDate:actualTimeIn]) {
            timeIn.isOvertime = YES;
        }
    }
    if([Update save:self.app.db]) {
        [self cancelTimeOut];
        [self updateTimeInOut];
        [self.app stopUpdatingLocation];
    }
}

- (void)cancelTimeOut {
    self.app.location = nil;
    self.store = nil;
    self.photo = nil;
    self.photoFilename = nil;
    self.signature = nil;
    self.signatureFilename = nil;
    self.currentDate = nil;
}

@end
