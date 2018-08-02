#import "LoginViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Image.h"
#import "View.h"
#import "MessageDialogViewController.h"

@interface LoginViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) Company *company;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation LoginViewController

static MessageDialogViewController *vcMessage;
static LoadingDialogViewController *vcLoading;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.tfUsername.highlightedBorderColor = THEME_SEC;
        self.tfPassword.highlightedBorderColor = THEME_SEC;
        self.btnLogin.backgroundColor = THEME_SEC;
        [View setCornerRadiusByWidth:self.btnLogin.superview cornerRadius:0.025];
        [View setCornerRadiusByHeight:self.tfUsername cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfPassword cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.btnLogin cornerRadius:0.3];
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    self.company = [Get company:self.app.db];
    self.ivCompanyLogo.image = [Image saveFromURL:[Image cachesPath:[NSString stringWithFormat:@"COMPANY_LOGO_%lld%@", self.company.companyID, @".png"]] url:self.company.logoURL];
}

- (IBAction)login:(id)sender {
    NSString *username = self.tfUsername.text;
    NSString *password = self.tfPassword.text;
    username = username.length == 0 ? @"018-450" : username;//paul
    password = password.length == 0 ? @"12341234" : password;//paul
    if(username.length == 0 || password.length == 0) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"Login";
        vcMessage.message = @"Please input username and password.";
        vcMessage.positiveTitle = @"OK";
        vcMessage.positiveTarget = ^{
            [View removeView:vcMessage.view animated:YES];
        };
        [View addSubview:self.view subview:vcMessage.view animated:YES];
        return;
    }
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:self.app.db] forKey:@"api_key"];
    [params setObject:username forKey:@"employee_number"];
    [params setObject:password forKey:@"password"];
    vcLoading = [self.storyboard instantiateViewControllerWithIdentifier:@"vcLoading"];
    vcLoading.delegate = self;
    vcLoading.action = LOADING_ACTION_LOGIN;
    vcLoading.params = params;
    [View addSubview:self.view subview:vcLoading.view animated:YES];
}

- (void)onLoadingUpdate:(int)action {
    
}

- (void)onLoadingFinish:(int)action result:(NSString *)result {
    switch(action) {
        case LOADING_ACTION_LOGIN: {
            if(![result isEqualToString:@"ok"]) {
                vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
                vcMessage.subject = @"Login";
                vcMessage.message = [NSString stringWithFormat:@"%@ %@", @"Failed to login.", result];
                vcMessage.positiveTitle = @"OK";
                vcMessage.positiveTarget = ^{
                    [View removeView:vcMessage.view animated:YES];
                };
                [View addSubview:self.view subview:vcMessage.view animated:NO];
                break;
            }
            vcLoading = [self.storyboard instantiateViewControllerWithIdentifier:@"vcLoading"];
            vcLoading.delegate = self;
            vcLoading.action = LOADING_ACTION_TIME_SECURITY;
            [View addSubview:self.view subview:vcLoading.view animated:NO];
            break;
        }
        case LOADING_ACTION_TIME_SECURITY: {
            vcLoading = [self.storyboard instantiateViewControllerWithIdentifier:@"vcLoading"];
            vcLoading.delegate = self;
            vcLoading.action = LOADING_ACTION_UPDATE_MASTER_FILE;
            [View addSubview:self.view subview:vcLoading.view animated:NO];
            break;
        }
        case LOADING_ACTION_UPDATE_MASTER_FILE: {
            [self.navigationController popViewControllerAnimated:NO];
            break;
        }
    }
}

@end
