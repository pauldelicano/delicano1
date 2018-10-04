#import "BreakViewController.h"
#import "BreakIn+CoreDataClass.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Update.h"
#import "View.h"
#import "Time.h"
#import "MessageDialogViewController.h"

@interface BreakViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) BreakTypes *breakType;
@property (strong, nonatomic) NSDate *breakOutDate;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) NSTimeInterval remaining;
@property (nonatomic) BOOL viewDidAppear;

@end

@implementation BreakViewController

static MessageDialogViewController *vcMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    UIVisualEffectView *blur = [UIVisualEffectView.alloc initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blur.frame = self.view.bounds;
    blur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:blur];
    [self.view sendSubviewToBack:blur];
    self.viewDidAppear = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if(self.vContent.frame.size.height < self.vScroll.frame.size.height) {
        CGFloat inset = self.vScroll.frame.size.height - self.vContent.frame.size.height;
        self.vScroll.contentInset = UIEdgeInsetsMake(inset * 0.5, 0, inset * 0.5, 0);
    }
    else {
        self.vScroll.contentInset = UIEdgeInsetsZero;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.viewDidAppear) {
        self.viewDidAppear = YES;
        self.btnDone.backgroundColor = THEME_SEC;
        [View setCornerRadiusByHeight:self.btnClose cornerRadius:1];
        [View setCornerRadiusByHeight:self.btnDone cornerRadius:0.2];
        [self onRefresh];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopTimer];
}

- (void)onRefresh {
    [super onRefresh];
    self.breakType = [Get breakType:self.app.db breakTypeID:self.breakIn.breakTypeID];
    self.breakOutDate = [[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", self.breakIn.date, self.breakIn.time]] dateByAddingTimeInterval:self.breakType.duration * 60];
    self.lName.text = self.breakType.name;
    self.lDuration.text = [NSString stringWithFormat:@"You are currently on\n%@. (%lld mins)", self.breakType.name, self.breakType.duration];
    [self updateRemainingTime];
    [self.vContent layoutIfNeeded];
    if(self.vContent.frame.size.height < self.vScroll.frame.size.height) {
        CGFloat inset = self.vScroll.frame.size.height - self.vContent.frame.size.height;
        self.vScroll.contentInset = UIEdgeInsetsMake(inset * 0.5, 0, inset * 0.5, 0);
    }
    else {
        self.vScroll.contentInset = UIEdgeInsetsZero;
    }
}

- (void)updateRemainingTime {
    if(self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:^{
            [self updateRemainingTime];
        } selector:@selector(invoke) userInfo:nil repeats:YES];
    }
    self.remaining = [self.breakOutDate timeIntervalSinceDate:NSDate.date];
    if(self.remaining < 1) {
        [self stopTimer];
        NSLog(@"alert: ALERT_TYPE_EXCESSIVE_BREAK");
        [Update alertSave:self.app.dbAlerts alertTypeID:ALERT_TYPE_EXCESSIVE_BREAK gpsID:[Update gpsSave:self.app.dbTracking location:self.app.location] value:nil];
        NSMutableDictionary *userInfo = NSMutableDictionary.alloc.init;
        [userInfo setObject:@"BREAK" forKey:@"NOTIFICATION_TYPE"];
        [userInfo setObject:[NSString stringWithFormat:@"%lld", self.breakIn.breakInID] forKey:@"NOTIFICATION_ID"];
        UNMutableNotificationContent *objNotificationContent = UNMutableNotificationContent.alloc.init;
        objNotificationContent.title = @"Excessive Break Alert";
        objNotificationContent.body = @"Ack, you may have forgotten the time! Hurry up and end your break asap.";
        objNotificationContent.sound = [UNNotificationSound soundNamed:@"Announcement.m4a"];
        objNotificationContent.userInfo = userInfo;
        [self.app.userNotificationCenter addNotificationRequest:[UNNotificationRequest requestWithIdentifier:[userInfo objectForKey:@"NOTIFICATION_ID"] content:objNotificationContent trigger:[UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO]] withCompletionHandler:^(NSError * _Nullable error) {
            if(error) {
                NSLog(@"error: break addNotificationRequest - %@", error.localizedDescription);
                return;
            }
        }];
    }
    self.lRemaining.text = [NSString stringWithFormat:@"%@ left", [Time secondsToHoursMinutes:self.remaining]];
}

- (void)stopTimer {
    if(self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (IBAction)closeBreak:(id)sender {
    [self.delegate onBreakCancel];
}

- (IBAction)done:(id)sender {
    vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
    vcMessage.subject = @"End Break";
    vcMessage.message = @"Do you really want to end your break?";
    vcMessage.negativeTitle = @"Cancel";
    vcMessage.negativeTarget = ^{
        [View removeChildViewController:vcMessage animated:YES];
    };
    vcMessage.positiveTitle = @"Yes";
    vcMessage.positiveTarget = ^{
        [View removeChildViewController:vcMessage animated:YES];
        [View removeChildViewController:self animated:YES];
        [self.delegate onBreakDone:self.breakIn];
    };
    [View addChildViewController:self childViewController:vcMessage animated:YES];
}

@end
