#import "AttendanceSummaryViewController.h"
#import "App.h"
#import "Image.h"
#import "View.h"
#import "Time.h"

@interface AttendanceSummaryViewController()

@property (nonatomic) BOOL viewWillAppear;

@end

@implementation AttendanceSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    self.lTimeIn.text = [NSString stringWithFormat:@"%@ %@", self.timeIn.date, self.timeIn.time];
    if(self.timeOut != nil) {
        self.lTimeOut.text = [NSString stringWithFormat:@"%@ %@", self.timeOut.date, self.timeOut.time];
        self.btnAddSignature.hidden = YES;
        self.ivSignature.image = [Image fromDocument:self.timeOut.signature];
        self.ivSignature.hidden = NO;
        self.btnEditSignature.hidden = YES;
        self.btnCancel.hidden = YES;
        self.btnTimeOut.hidden = YES;
    }
    else {
        self.lTimeOut.text = [Time formatDate:[NSString stringWithFormat:@"%@ %@", DATE_FORMAT, TIME_FORMAT] date:self.timeOutPreview];
        self.btnAddSignature.hidden = NO;
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
        return;
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
