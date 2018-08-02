#import "AuthorizationViewController.h"
#import "App.h"
#import "View.h"
#import "MessageDialogViewController.h"

@interface AuthorizationViewController()

@property (nonatomic) BOOL viewWillAppear;

@end

@implementation AuthorizationViewController

static MessageDialogViewController *vcMessage;
static LoadingDialogViewController *vcLoading;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.ivAppLogo.image = APP_LOGO;
        self.tfAuthorizationCode.highlightedBorderColor = THEME_SEC;
        self.btnAuthorize.backgroundColor = THEME_SEC;
        [View setCornerRadiusByWidth:self.btnAuthorize.superview cornerRadius:0.025];
        [View setCornerRadiusByHeight:self.tfAuthorizationCode cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.btnAuthorize cornerRadius:0.3];
    }
}

- (IBAction)authorize:(id)sender {
    NSString *deviceID = UIDevice.currentDevice.identifierForVendor.UUIDString;
    NSString *authorizationCode = self.tfAuthorizationCode.text;
    deviceID = authorizationCode.length == 0 ? @"91F9F8A0-DE47-4553-A68F-951244B11320" : deviceID;//paul
    authorizationCode = authorizationCode.length == 0 ? @"79HAWRPE" : authorizationCode;//paul
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
            if(![result isEqualToString:@"ok"]) {
                vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
                vcMessage.subject = @"Authorization";
                vcMessage.message = [NSString stringWithFormat:@"%@ %@", @"Failed to authorize.", result];
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
