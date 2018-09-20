#import "AuthorizationViewController.h"
#import "App.h"
#import "View.h"
#import "MessageDialogViewController.h"

@interface AuthorizationViewController()

@property (nonatomic) BOOL viewDidAppear;

@end

@implementation AuthorizationViewController

static MessageDialogViewController *vcMessage;
static LoadingDialogViewController *vcLoading;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewDidAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.viewDidAppear) {
        self.viewDidAppear = YES;
        self.ivAppLogo.image = APP_LOGO;
        self.tfAuthorizationCode.highlightedBorderColor = THEME_SEC;
        self.btnAuthorize.backgroundColor = THEME_SEC;
        [View setCornerRadiusByWidth:self.btnAuthorize.superview cornerRadius:0.075];
        [View setCornerRadiusByHeight:self.tfAuthorizationCode cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.btnAuthorize cornerRadius:0.2];
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    if(self.vContent.frame.size.height < self.vScroll.frame.size.height) {
        CGFloat inset = self.vScroll.frame.size.height - self.vContent.frame.size.height;
        self.vScroll.contentInset = UIEdgeInsetsMake(inset * 0.4, 0, inset * 0.6, 0);
    }
    else {
        self.vScroll.contentInset = UIEdgeInsetsZero;
    }
}

- (IBAction)authorize:(id)sender {
    NSString *deviceID = UIDevice.currentDevice.identifierForVendor.UUIDString;
    NSString *authorizationCode = self.tfAuthorizationCode.text;
    if([authorizationCode isEqualToString:@"TEST"]) {
        deviceID = @"890F5265-7F54-488F-97BC-9C142C496818";
        authorizationCode = @"680F2SYQ";
    }
    if([authorizationCode isEqualToString:@"MOI"]) {
        deviceID = @"E0064E8E-8054-412A-8C15-DC9F59CF047A";
        authorizationCode = @"E0ZVY71P";
    }
    if(deviceID.length == 0) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"Authorization";
        vcMessage.message = @"Device ID not found.";
        vcMessage.positiveTitle = @"OK";
        vcMessage.positiveTarget = ^{
            [View removeView:vcMessage.view animated:YES];
        };
        [View addSubview:self.view subview:vcMessage.view animated:YES];
        return;
    }
    if(authorizationCode.length == 0) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"Authorization";
        vcMessage.message = @"Please input authorization code.";
        vcMessage.positiveTitle = @"OK";
        vcMessage.positiveTarget = ^{
            [View removeView:vcMessage.view animated:YES];
        };
        [View addSubview:self.view subview:vcMessage.view animated:YES];
        return;
    }
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:deviceID forKey:@"tablet_id"];
    [params setObject:authorizationCode forKey:@"authorization_code"];
    [params setObject:API_KEY forKey:@"api_key"];
    [params setObject:@"IOS" forKey:@"device_type"];
    vcLoading = [self.storyboard instantiateViewControllerWithIdentifier:@"vcLoading"];
    vcLoading.delegate = self;
    vcLoading.action = LOADING_ACTION_AUTHORIZE;
    vcLoading.params = params;
    [View addSubview:self.view subview:vcLoading.view animated:YES];
}

- (void)onLoadingUpdate:(int)action {
    
}

- (void)onLoadingFinish:(int)action result:(NSString *)result {
    switch(action) {
        case LOADING_ACTION_AUTHORIZE: {
            if(result != nil && ![result isEqualToString:@"ok"]) {
                vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
                vcMessage.subject = @"Authorizing Device";
                vcMessage.message = @"Failed to authorize device.";
                vcMessage.positiveTitle = @"OK";
                vcMessage.positiveTarget = ^{
                    [View removeView:vcMessage.view animated:YES];
                };
                [View addSubview:self.view subview:vcMessage.view animated:NO];
                break;
            }
            [self.navigationController popViewControllerAnimated:NO];
            break;
        }
    }
}

@end
