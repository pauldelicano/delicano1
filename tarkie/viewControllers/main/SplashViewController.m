#import "SplashViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"

@interface SplashViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) CATransition *transition;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.transition = CATransition.animation;
    self.transition.duration = 0.25;
    self.transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    self.transition.type = kCATransitionFade;
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.vBackground.backgroundColor = THEME_PRI;
        self.ivAppLogo.image = APP_LOGO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self onRefresh];
        });
        return;
    }
    [self onRefresh];
}

- (void)onRefresh {
    [super onRefresh];
    [self.navigationController.view.layer addAnimation:self.transition forKey:nil];
    if([Get apiKey:self.app.db] == nil) {
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"vcAuthorization"] animated:NO];
        return;
    }
    if([Get userID:self.app.db] == 0) {
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"vcLogin"] animated:NO];
        return;
    }
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"vcMain"] animated:NO];
}

@end
