#import "AboutViewController.h"
#import "App.h"
#import "View.h"

@interface AboutViewController()

@property (strong, nonatomic) NSString *appURL, *facebookURL;
@property (nonatomic) BOOL viewWillAppear, viewDidAppear;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewWillAppear = NO;
    self.ivAbout.image = [UIImage imageNamed:@"About"];
    self.lAbout.text = [self.lAbout.text stringByReplacingOccurrencesOfString:@"Tarkie" withString:APP_NAME];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat ratio = self.ivAbout.image.size.width / self.ivAbout.image.size.height;
    CGRect frame = self.ivAbout.frame;
    if(frame.size.width > frame.size.height) {
        frame.size.height = self.ivAbout.frame.size.width / ratio;
    }
    else {
        frame.size.width = self.ivAbout.frame.size.height * ratio;
    }
    self.ivAbout.frame = frame;
    self.vScroll.contentInset = UIEdgeInsetsMake(0 - self.vStatus.frame.size.height + self.ivAbout.frame.size.height, 0, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.ivLogo.backgroundColor = THEME_PRI;
        [View setCornerRadiusByHeight:self.ivLogo cornerRadius:1];
        [self onRefresh];
    }
}

- (void)onRefresh {
    self.ivLogo.contentMode = UIViewContentModeCenter;
    self.ivLogo.image = [UIImage imageWithCGImage:APP_LOGO_WHITE.CGImage scale:((self.ivLogo.image.scale * (APP_LOGO_WHITE.size.width / self.ivLogo.frame.size.width)) * 1.5) orientation:(self.ivLogo.image.imageOrientation)];
    self.lVersion.text = [NSString stringWithFormat:@"Version %@", [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    if([APP_NAME isEqualToString:@"Sevie"]) {
        self.lAppURL.text = @"";
        self.appURL = @"";
    }
    if([APP_NAME isEqualToString:@"Tarkie"]) {
        self.lAppURL.text = @"itunes.apple.com/us/app/tarkie";
        self.appURL = @"https://itunes.apple.com/us/app/tarkie/id1436957809";
    }
    if([APP_NAME isEqualToString:@"Timsie"]) {
        self.lAppURL.text = @"";
        self.appURL = @"";
    }
    if([UIApplication.sharedApplication canOpenURL:[NSURL URLWithString:@"fb://"]]) {
        if([APP_NAME isEqualToString:@"Sevie"]) {
            self.lFacebookURL.text = @"";
            self.facebookURL = @"";
        }
        if([APP_NAME isEqualToString:@"Tarkie"]) {
            self.lFacebookURL.text = @"www.facebook.com/tarkieapp";
            self.facebookURL = @"fb://profile/830853863618267";
        }
        if([APP_NAME isEqualToString:@"Timsie"]) {
            self.lFacebookURL.text = @"";
            self.facebookURL = @"";
        }
    }
    else {
        if([APP_NAME isEqualToString:@"Sevie"]) {
            self.lFacebookURL.text = @"";
            self.facebookURL = @"";
        }
        if([APP_NAME isEqualToString:@"Tarkie"]) {
            self.lFacebookURL.text = @"www.facebook.com/tarkieapp";
            self.facebookURL = @"https://www.facebook.com/830853863618267";
        }
        if([APP_NAME isEqualToString:@"Timsie"]) {
            self.lFacebookURL.text = @"";
            self.facebookURL = @"";
        }
    }
    self.vScroll.contentInset = UIEdgeInsetsMake(0 - self.vStatus.frame.size.height + self.ivAbout.frame.size.height, 0, 0, 0);
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)web:(id)sender {
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"www.mobileoptima.com"] options:@{} completionHandler:nil];
}

- (IBAction)apple:(id)sender {
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:self.appURL] options:@{} completionHandler:nil];
}

- (IBAction)facebook:(id)sender {
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:self.facebookURL] options:@{} completionHandler:nil];
}

@end
