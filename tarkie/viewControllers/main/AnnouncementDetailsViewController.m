#import "AnnouncementDetailsViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Update.h"
#import "Image.h"
#import "View.h"
#import "Time.h"

@interface AnnouncementDetailsViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation AnnouncementDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    if(!self.announcement.isSeen) {
        self.announcement.isSeen = YES;
        AnnouncementSeen *announcementSeen = [Get announcementSeen:self.app.db announcementID:self.announcement.announcementID];
        if(announcementSeen == nil) {
            announcementSeen = [NSEntityDescription insertNewObjectForEntityForName:@"AnnouncementSeen" inManagedObjectContext:self.app.db];
            announcementSeen.announcementID = self.announcement.announcementID;
        }
        NSDate *currentDate = NSDate.date;
        announcementSeen.date = [Time getFormattedDate:DATE_FORMAT date:currentDate];
        announcementSeen.time = [Time getFormattedDate:TIME_FORMAT date:currentDate];
        announcementSeen.isSync = NO;
        [Update save:self.app.db];
    }
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.vStatusBar.backgroundColor = THEME_PRI_DARK;
        self.vNavBar.backgroundColor = THEME_PRI;
        [View setCornerRadiusByHeight:self.ivPhoto cornerRadius:1];
        [self onRefresh];
    }
}

- (void)onRefresh {
    self.lName.text = [Time formatDate:self.app.settingDisplayDateFormat date:self.announcement.scheduledDate];
    Employees *createdBy = [Get employee:self.app.db employeeID:self.announcement.createdByID];
    self.ivPhoto.image = [Image saveFromURL:[Image cachesPath:[NSString stringWithFormat:@"EMPLOYEE_PHOTO_%lld%@", createdBy.employeeID, @".png"]] url:createdBy.photoURL];
    self.lSubject.text = self.announcement.subject;
    self.lDetails.text = [NSString stringWithFormat:@"%@ %@ | %@", createdBy.firstName, createdBy.lastName, [Time formatTime:self.app.settingDisplayTimeFormat time:self.announcement.scheduledTime]];
    self.lMessage.text = self.announcement.message;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
