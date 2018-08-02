#import "AttendanceSummaryViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Image.h"
#import "View.h"
#import "Time.h"

@interface AttendanceSummaryViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation AttendanceSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.vStatusBar.backgroundColor = THEME_PRI_DARK;
        self.vNavBar.backgroundColor = THEME_PRI;
        [self.btnAddSignature setTitleColor:THEME_SEC forState:UIControlStateNormal];
        self.btnTimeOut.backgroundColor = THEME_SEC;
        [View setCornerRadiusByHeight:self.btnAddSignature cornerRadius:0.3];
        [View setCornerRadiusByWidth:self.ivSignature cornerRadius:0.025];
        CALayer *layer = self.btnAddSignature.layer;
        layer.borderColor = THEME_SEC.CGColor;
        layer.borderWidth = (1.0f / 568) * UIScreen.mainScreen.bounds.size.height;
        layer = self.ivSignature.layer;
        layer.borderColor = [UIColor colorNamed:@"Grey800"].CGColor;
        layer.borderWidth = (1.0f / 568) * UIScreen.mainScreen.bounds.size.height;
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    self.lTimeIn.text = [NSString stringWithFormat:@"%@ %@", [Time formatDate:self.app.settingDisplayDateFormat date:self.timeIn.date], [Time formatTime:self.app.settingDisplayTimeFormat time:self.timeIn.time]];
    if(self.timeOut != nil) {
        self.lTimeOut.text = [NSString stringWithFormat:@"%@ %@", [Time formatDate:self.app.settingDisplayDateFormat date:self.timeOut.date], [Time formatTime:self.app.settingDisplayTimeFormat time:self.timeOut.time]];
        self.btnAddSignature.hidden = YES;
        self.ivSignature.image = [Image fromDocument:self.timeOut.signature];
        self.ivSignature.hidden = NO;
        self.btnEditSignature.hidden = YES;
        self.btnCancel.hidden = YES;
        self.btnTimeOut.hidden = YES;
    }
    else {
        self.lTimeOut.text = [Time getFormattedDate:[NSString stringWithFormat:@"%@ %@", self.app.settingDisplayDateFormat, self.app.settingDisplayTimeFormat] date:self.timeOutPreview];
        self.btnAddSignature.hidden = !self.app.settingAttendanceTimeOutSignature;
        self.ivSignature.hidden = YES;
        self.btnEditSignature.hidden = YES;
        self.btnCancel.hidden = NO;
        self.btnTimeOut.hidden = NO;
    }
    self.lTotalWorkHours.text = @"";
    self.lTotalBreak.text = @"";
    self.lTotalNetWorkHours.text = @"";
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    if(self.timeOutPreview != nil) {
        [self.delegate onAttendanceSummaryCancel];
    }
}

- (IBAction)addSignature:(id)sender {
    AddSignatureViewController *vcAddSignature = [self.storyboard instantiateViewControllerWithIdentifier:@"vcAddSignature"];
    vcAddSignature.delegate = self;
    [self.navigationController pushViewController:vcAddSignature animated:YES];
}

- (IBAction)editSignature:(id)sender {
    [self addSignature:self];
}

- (IBAction)cancel:(id)sender {
    [self back:self];
}

- (IBAction)timeOut:(id)sender {
    if(self.ivSignature.image == nil) {
        if(self.app.settingAttendanceTimeOutSignature) {
            return;
        }
        self.ivSignature.image = UIImage.alloc.init;
    }
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate onAttendanceSummaryTimeOut:self.ivSignature.image];
}

- (void)onAddSignatureSave:(UIImage *)image {
    self.ivSignature.image = image;
    self.btnAddSignature.hidden = YES;
    self.ivSignature.hidden = NO;
    self.btnEditSignature.hidden = NO;
}

@end
