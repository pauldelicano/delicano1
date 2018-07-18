#import "MainViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Load.h"
#import "Update.h"
#import "Image.h"
#import "View.h"
#import "Time.h"
#import "MessageDialogViewController.h"
#import "AnnouncementsViewController.h"
#import "AnnouncementDetailsViewController.h"
#import "StoresViewController.h"
#import "HomeViewController.h"
#import "VisitsViewController.h"
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
@property (strong, nonatomic) NSMutableArray<CustomViewController *> *viewControllers;
@property (strong, nonatomic) Employees *employee;
@property (strong, nonatomic) Stores *store;
@property (strong, nonatomic) ScheduleTimes *scheduleTime;
@property (strong, nonatomic) UIImage *photo, *signature;
@property (strong, nonatomic) NSString *photoFilename, *signatureFilename;
@property (strong, nonatomic) NSDate *currentDate;
@property (nonatomic) long syncDataCount;
@property (nonatomic) BOOL viewWillAppear, isLoading, isGPSRequest, isCameraRequest, proceedWithoutGPS, isTimingIn, isTimingOut;

@end

@implementation MainViewController

static MessageDialogViewController *vcSystemMessage, *vcMessage;
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
    self.viewWillAppear = NO;
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
        self.vcDrawer = [self.storyboard instantiateViewControllerWithIdentifier:@"vcDrawer"];
        self.vcDrawer.delegate = self;
        self.vcDrawer.parent = self;
        self.vcDrawer.position = DRAWER_POSITION_LEFT;
        self.vcDrawer.headerBackgroundColor = THEME_PRI;
        [self.view addSubview:self.vcDrawer.view];
        [self addChildViewController:self.vcDrawer];
        self.pvcMain = [self.storyboard instantiateViewControllerWithIdentifier:@"pvcMain"];
        self.pvcMain.view.frame = self.vContent.bounds;
        [self.vContent addSubview:self.pvcMain.view];
        [self addChildViewController:self.pvcMain];
        [self.view bringSubviewToFront:self.vcDrawer.view];
        [self onRefresh];
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
    self.employee = [Get employee:self.app.db employeeID:[Get userID:self.app.db]];
    self.vcDrawer.company = [Get company:self.app.db];
    self.vcDrawer.employee = self.employee;
    self.vcDrawer.menus = [Load drawerMenus:self.app.db];
    [self.vcDrawer onRefresh];
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
        [self.app.userNotificationCenter addNotificationRequest:[UNNotificationRequest requestWithIdentifier:[userInfo objectForKey:@"NOTIFICATION_ID"] content:objNotificationContent trigger:[UNTimeIntervalNotificationTrigger triggerWithTimeInterval:[[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", announcements[x].scheduledDate, announcements[x].scheduledTime]] timeIntervalSinceDate:NSDate.date] repeats:NO]] withCompletionHandler:^(NSError * _Nullable error) {
            if(error) {
                NSLog(@"error: main addNotificationRequest - %@", error.localizedDescription);
                return;
            }
            [notificationRequestIdentifiers addObject:[userInfo objectForKey:@"NOTIFICATION_ID"]];
        }];
    }
    [self updateTimeInOut];
    [self updateUnSeenAnnouncementsCount];
    [self updateSyncDataCount];
}

- (void)updateTimeInOut {
    self.isTimeIn = [Get isTimeIn:self.app.db];
    NSString *name = !self.isTimeIn ? @"Time In" : @"Time Out";
    NSString *icon = !self.isTimeIn ? @"\uf185" : @"\uf186";
    icon = nil;
    [self.vcDrawer.menus[MENU_TIME_IN_OUT - 1] setValue:icon == nil ? [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", @"Menu", [name stringByReplacingOccurrencesOfString:@" " withString:@""]]] : icon forKey:@"icon"];
    if([name isEqualToString:@"Time In"]) {
        name = [Get conventionName:self.app.db conventionID:CONVENTION_TIME_IN];
    }
    if([name isEqualToString:@"Time Out"]) {
        name = [Get conventionName:self.app.db conventionID:CONVENTION_TIME_OUT];
    }
    [self.vcDrawer.menus[MENU_TIME_IN_OUT - 1] setValue:name forKey:@"name"];
    [self.vcDrawer onRefresh];
}

- (void)updateUnSeenAnnouncementsCount {
    long unSeenAnnouncementsCount = [Get unSeenAnnouncementsCount:self.app.db];
    self.lNavBarButtonsHomeAnnouncementsCount.text = [NSString stringWithFormat:@"%ld", unSeenAnnouncementsCount];
    self.lNavBarButtonsHomeAnnouncementsCount.hidden = unSeenAnnouncementsCount == 0;
    CGFloat pointSize = self.lNavBarButtonsHomeAnnouncementsCount.font.pointSize;
    for(int x = 0; x > 1 && x < self.lNavBarButtonsHomeAnnouncementsCount.text.length; x++) {
        pointSize *= 0.8;
    }
    self.lNavBarButtonsHomeAnnouncementsCount.font = [UIFont fontWithName:self.lNavBarButtonsHomeAnnouncementsCount.font.fontName size:pointSize];
    [self.lNavBarButtonsHomeAnnouncementsCount setNeedsLayout];
    [self.lNavBarButtonsHomeAnnouncementsCount layoutIfNeeded];
    [View setCornerRadiusByHeight:self.lNavBarButtonsHomeAnnouncementsCount cornerRadius:1];
}

- (void)updateSyncDataCount {
    self.self.syncDataCount = [Get syncTotalCount:self.app.db];
    self.lNavBarButtonsHomeSyncCount.text = [NSString stringWithFormat:@"%ld", self.syncDataCount];
    self.lNavBarButtonsHomeSyncCount.hidden = self.self.syncDataCount == 0;
    CGFloat pointSize = self.lNavBarButtonsHomeSyncCount.font.pointSize;
    for(int x = 0; x > 1 && x < self.lNavBarButtonsHomeSyncCount.text.length; x++) {
        pointSize *= 0.8;
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
        vcAnnouncementDetails.announcement = [Get announcement:self.app.db announcementID:[[userInfo objectForKey:@"NOTIFICATION_ID"] longLongValue]];
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
        LoadingDialogViewController *vcLoading = [self.storyboard instantiateViewControllerWithIdentifier:@"vcLoading"];
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

- (void)onDrawerMenuSelect:(int)menu {
    [self.vcDrawer closeDrawer];
    switch(menu) {
        case MENU_TIME_IN_OUT: {
            if(!self.isTimeIn) {
                [self timeIn];
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
            break;
        }
        case MENU_BREAKS: {
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
                LoadingDialogViewController *vcLoading = [self.storyboard instantiateViewControllerWithIdentifier:@"vcLoading"];
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
                LoadingDialogViewController *vcLoading = [self.storyboard instantiateViewControllerWithIdentifier:@"vcLoading"];
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
            break;
        }
        case MENU_LOGOUT: {
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

- (void)onPageBarSelect:(int)page {
    [self.pvcMain setViewControllers:@[self.viewControllers[page]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.vNavBarButtonsHome.hidden = ![self.viewControllers[page] isKindOfClass:HomeViewController.class];
    self.vNavBarButtonsVisits.hidden = ![self.viewControllers[page] isKindOfClass:VisitsViewController.class];
    self.vNavBarButtonsExpense.hidden = ![self.viewControllers[page] isKindOfClass:ExpenseViewController.class];
    self.vNavBarButtonsInventory.hidden = ![self.viewControllers[page] isKindOfClass:InventoryViewController.class];
    self.vNavBarButtonsForms.hidden = ![self.viewControllers[page] isKindOfClass:FormsViewController.class];
    self.vNavBarButtonsHistory.hidden = ![self.viewControllers[page] isKindOfClass:HistoryViewController.class];
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
            if(![result isEqualToString:@"ok"]) {
                vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
                vcMessage.subject = @"Time Security";
                vcMessage.message = [NSString stringWithFormat:@"%@ %@", @"Failed to get server time.", result];
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
            vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
            vcMessage.subject = @"Update Master File";
            vcMessage.message = [result isEqualToString:@"ok"] ? @"Update master file successful." : [NSString stringWithFormat:@"%@ %@", @"Failed to update master file.", result];
            vcMessage.positiveTitle = @"OK";
            vcMessage.positiveTarget = ^{
                [View removeView:vcMessage.view animated:YES];
                self.isLoading = NO;
                [self applicationDidBecomeActive];
            };
            [View addSubview:self.view subview:vcMessage.view animated:NO];
            [self onRefresh];
            break;
        }
        case LOADING_ACTION_SYNC_DATA: {
            vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
            vcMessage.subject = @"Sync Data";
            vcMessage.message = [result isEqualToString:@"ok"] ? @"Sync data successful." : [NSString stringWithFormat:@"%@ %@", @"Failed to sync data.", result];
            vcMessage.positiveTitle = @"OK";
            vcMessage.positiveTarget = ^{
                [View removeView:vcMessage.view animated:YES];
                self.isLoading = NO;
                [self applicationDidBecomeActive];
            };
            [View addSubview:self.view subview:vcMessage.view animated:NO];
            [self onRefresh];
            break;
        }
        case LOADING_ACTION_SEND_BACKUP_DATA: {
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
    double interval = fabs([newServer timeIntervalSinceDate:NSDate.date]);
    NSLog(@"info: timeSecurity - %f sec, %@ - %@", interval, NSDate.date, newServer);
    if(timeSecurity == nil || interval > 60) {
        vcSystemMessage = [self.storyboard instantiateViewControllerWithIdentifier: @"vcMessage"];
        vcSystemMessage.subject = @"Time Security";
        vcSystemMessage.message = @"Device and server time do not match.";
        vcSystemMessage.positiveTitle = @"Validate";
        vcSystemMessage.positiveTarget = ^{
            [View removeView:vcSystemMessage.view animated:YES];
            LoadingDialogViewController *vcLoading = [self.storyboard instantiateViewControllerWithIdentifier:@"vcLoading"];
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
        vcSystemMessage.subject = @"Location Access";
        vcSystemMessage.message = @"Please enable location services and allow location access to always.";
        vcSystemMessage.negativeTitle = @"Cancel";
        vcSystemMessage.negativeTarget = ^{
            if(!self.isTimeIn) {
                self.isGPSRequest = NO;
                [self applicationDidBecomeActive];
            }
            else {
                [UIApplication.sharedApplication performSelector:@selector(suspend)];
            }
        };
        vcSystemMessage.positiveTitle = @"OK";
        vcSystemMessage.positiveTarget = ^{
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"App-Prefs:root=Privacy&path=LOCATION"] options:@{} completionHandler:nil];
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
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        vcSystemMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcSystemMessage.subject = @"Camera Access";
        vcSystemMessage.message = @"Device has no camera.";
        vcSystemMessage.positiveTitle = @"OK";
        vcSystemMessage.positiveTarget = ^{
            self.isCameraRequest = NO;
            [self applicationDidBecomeActive];
        };
        [View addSubview:self.app.window subview:vcSystemMessage.view animated:YES];
        self.isCameraRequest = YES;
        return YES;
    }
    self.isCameraRequest = NO;
    return NO;
}

- (void)timeIn {
    if([self gpsRequest]) {
        self.isTimingIn = YES;
        return;
    }
    if(self.app.location == nil && !self.proceedWithoutGPS) {
        [self.app startUpdatingLocation];
        NoGPSDialogViewController *vcNoGPS = [self.storyboard instantiateViewControllerWithIdentifier: @"vcNoGPS"];
        vcNoGPS.delegate = self;
        [View addSubview:self.view subview:vcNoGPS.view animated:YES];
        return;
    }
    if(self.store == nil) {
        DropDownDialogViewController *vcDropDown = [self.storyboard instantiateViewControllerWithIdentifier:@"vcDropDown"];
        vcDropDown.delegate = self;
        vcDropDown.parent = self;
        vcDropDown.type = DROP_DOWN_TYPE_STORE;
        vcDropDown.action = DROP_DOWN_ACTION_TIME_IN;
        [View addSubview:self.view subview:vcDropDown.view animated:YES];
        [self addChildViewController:vcDropDown];
        return;
    }
    if(self.scheduleTime == nil) {
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
        self.photoFilename = [NSString stringWithFormat:@"%lld-%.0f%@", self.employee.employeeID, [NSDate.date timeIntervalSince1970], @".png"];
        if([Image saveFromImage:[Image documentPath:self.photoFilename] image:self.photo] == nil) {
            self.photo = nil;
            self.photoFilename = nil;
            self.isTimingIn = YES;
            [self applicationDidBecomeActive];
            return;
        }
    }
    if(self.currentDate == nil) {
        self.currentDate = NSDate.date;
    }
    NSString *date = [Time formatDate:DATE_FORMAT date:self.currentDate];
    NSString *time = [Time formatDate:TIME_FORMAT date:self.currentDate];
    NSString *syncBatchID = [Get syncBatchID:self.app.db];
    Sequences *sequence = [Get sequence:self.app.db];
    GPS *gps;
    if(!self.proceedWithoutGPS) {
        gps = [NSEntityDescription insertNewObjectForEntityForName:@"GPS" inManagedObjectContext:self.app.db];
        sequence.gps += 1;
        gps.gpsID = sequence.gps;
        gps.date = [Time formatDate:DATE_FORMAT date:self.app.location.timestamp];
        gps.time = [Time formatDate:TIME_FORMAT date:self.app.location.timestamp];
        gps.latitude = self.app.location.coordinate.latitude;
        gps.longitude = self.app.location.coordinate.longitude;
    }
    Schedules *schedule = [Get schedule:self.app.db webScheduleID:0 scheduleDate:date];
    if(schedule == nil) {
        schedule = [NSEntityDescription insertNewObjectForEntityForName:@"Schedules" inManagedObjectContext:self.app.db];
        sequence.schedules += 1;
        schedule.scheduleID = sequence.schedules;
        schedule.employeeID = self.employee.employeeID;
        schedule.date = date;
        schedule.time = time;
        schedule.scheduleDate = date;
        schedule.isFromWeb = NO;
        schedule.isActive = YES;
        schedule.isSync = NO;
    }
    schedule.syncBatchID = syncBatchID;
    schedule.timeIn = self.scheduleTime.timeIn;
    schedule.timeOut = self.scheduleTime.timeIn;
    TimeIn *timeIn = [NSEntityDescription insertNewObjectForEntityForName:@"TimeIn" inManagedObjectContext:self.app.db];
    sequence.timeIn += 1;
    timeIn.timeInID = sequence.timeIn;
    timeIn.date = date;
    timeIn.time = time;
    timeIn.employeeID = self.employee.employeeID;
    timeIn.gpsID = gps.gpsID;
    timeIn.storeID = self.store.storeID;
    timeIn.scheduleID = schedule.scheduleID;
    timeIn.photo = self.photoFilename;
    timeIn.syncBatchID = syncBatchID;
    timeIn.batteryLevel = [NSString stringWithFormat:@"%f", UIDevice.currentDevice.batteryLevel];
    timeIn.isSync = NO;
    timeIn.isPhotoUpload = NO;
    timeIn.isPhotoExists = NO;
    timeIn.isPhotoDelete = NO;
    if([Update save:self.app.db]) {
        [self cancelTimeIn];
        [self updateTimeInOut];
        [self.app startUpdatingLocation];
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
    if(self.store == nil) {
        DropDownDialogViewController *vcDropDown = [self.storyboard instantiateViewControllerWithIdentifier:@"vcDropDown"];
        vcDropDown.delegate = self;
        vcDropDown.parent = self;
        vcDropDown.type = DROP_DOWN_TYPE_STORE;
        vcDropDown.action = DROP_DOWN_ACTION_TIME_OUT;
        [View addSubview:self.view subview:vcDropDown.view animated:YES];
        [self addChildViewController:vcDropDown];
        [vcDropDown onStoresSelect:[Get store:self.app.db storeID:[Get timeIn:self.app.db].storeID]];
        return;
    }
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
        self.photoFilename = [NSString stringWithFormat:@"%lld-%.0f%@", self.employee.employeeID, [NSDate.date timeIntervalSince1970], @".png"];
        if([Image saveFromImage:[Image documentPath:self.photoFilename] image:self.photo] == nil) {
            self.photo = nil;
            self.photoFilename = nil;
            self.isTimingOut = YES;
            [self applicationDidBecomeActive];
            return;
        }
    }
    if(self.currentDate == nil) {
        self.currentDate = NSDate.date;
    }
    if(self.signature == nil) {
        AttendanceSummaryViewController *vcAttendanceSummary = [self.storyboard instantiateViewControllerWithIdentifier:@"vcAttendanceSummary"];
        vcAttendanceSummary.delegate = self;
        vcAttendanceSummary.timeIn = [Get timeIn:self.app.db];
        vcAttendanceSummary.timeOutPreview = self.currentDate;
        [self.navigationController pushViewController:vcAttendanceSummary animated:YES];
        return;
    }
    if(self.signatureFilename == nil) {
        self.signatureFilename = [NSString stringWithFormat:@"%lld-%.0f%@", self.employee.employeeID, [NSDate.date timeIntervalSince1970], @".png"];
        if([Image saveFromImage:[Image documentPath:self.signatureFilename] image:self.signature] == nil) {
            self.signature = nil;
            self.signatureFilename = nil;
            self.isTimingOut = YES;
            [self applicationDidBecomeActive];
            return;
        }
    }
    NSString *date = [Time formatDate:DATE_FORMAT date:self.currentDate];
    NSString *time = [Time formatDate:TIME_FORMAT date:self.currentDate];
    NSString *syncBatchID = [Get syncBatchID:self.app.db];
    Sequences *sequence = [Get sequence:self.app.db];
    GPS *gps = [NSEntityDescription insertNewObjectForEntityForName:@"GPS" inManagedObjectContext:self.app.db];
    sequence.gps += 1;
    gps.gpsID = sequence.gps;
    gps.date = [Time formatDate:DATE_FORMAT date:self.app.location.timestamp];
    gps.time = [Time formatDate:TIME_FORMAT date:self.app.location.timestamp];
    gps.latitude = self.app.location.coordinate.latitude;
    gps.longitude = self.app.location.coordinate.longitude;
    TimeOut *timeOut = [NSEntityDescription insertNewObjectForEntityForName:@"TimeOut" inManagedObjectContext:self.app.db];
    sequence.timeOut += 1;
    timeOut.timeOutID = sequence.timeOut;
    timeOut.timeInID = [Get timeIn:self.app.db].timeInID;
    timeOut.date = date;
    timeOut.time = time;
    timeOut.employeeID = self.employee.employeeID;
    timeOut.gpsID = gps.gpsID;
    timeOut.storeID = self.store.storeID;
    timeOut.photo = self.photoFilename;
    timeOut.signature = self.signatureFilename;
    timeOut.syncBatchID = syncBatchID;
    timeOut.isSync = NO;
    timeOut.isPhotoUpload = NO;
    timeOut.isPhotoExists = NO;
    timeOut.isPhotoDelete = NO;
    timeOut.isSignatureUpload = NO;
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
