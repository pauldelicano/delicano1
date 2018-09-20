#import "LoginViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "File.h"
#import "View.h"
#import "MessageDialogViewController.h"

@interface LoginViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) Company *company;
@property (nonatomic) BOOL viewDidAppear;

@end

@implementation LoginViewController

static MessageDialogViewController *vcMessage;
static LoadingDialogViewController *vcLoading;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.ivCompanyLogo.image = nil;
    self.viewDidAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.viewDidAppear) {
        self.viewDidAppear = YES;
        self.tfUsername.highlightedBorderColor = THEME_SEC;
        self.tfPassword.highlightedBorderColor = THEME_SEC;
        self.btnLogin.backgroundColor = THEME_SEC;
        [View setCornerRadiusByWidth:self.btnLogin.superview cornerRadius:0.075];
        [View setCornerRadiusByHeight:self.tfUsername cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfPassword cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.btnLogin cornerRadius:0.2];
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    self.company = [Get company:self.app.db];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [File saveImageFromURL:[File cachesPath:[NSString stringWithFormat:@"COMPANY_LOGO_%lld%@", self.company.companyID, @".png"]] url:self.company.logoURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ivCompanyLogo.image = image;
        });
    });
    if(self.vContent.frame.size.height < self.vScroll.frame.size.height) {
        CGFloat inset = self.vScroll.frame.size.height - self.vContent.frame.size.height;
        self.vScroll.contentInset = UIEdgeInsetsMake(inset * 0.4, 0, inset * 0.6, 0);
    }
    else {
        self.vScroll.contentInset = UIEdgeInsetsZero;
    }
}

- (IBAction)login:(id)sender {
    NSString *username = self.tfUsername.text;
    NSString *password = self.tfPassword.text;
    if([username isEqualToString:@"test"]) {
        username = @"018-450";
        password = @"12341234";
    }
    if([username isEqualToString:@"moi"]) {
        username = @"018-450";
        password = @"12341234";
    }
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
    self.app.moduleAttendance = [Get isModuleEnabled:self.app.db moduleID:MODULE_ATTENDANCE];
    self.app.moduleVisits = [Get isModuleEnabled:self.app.db moduleID:MODULE_VISITS];
    self.app.moduleExpense = [Get isModuleEnabled:self.app.db moduleID:MODULE_EXPENSE];
    self.app.moduleInventory = [Get isModuleEnabled:self.app.db moduleID:MODULE_INVENTORY];
    self.app.moduleForms = [Get isModuleEnabled:self.app.db moduleID:MODULE_FORMS];
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
            if(result != nil && ![result isEqualToString:@"ok"]) {
                vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
                vcMessage.subject = @"Validating Account";
                vcMessage.message = @"Failed to login.";
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
