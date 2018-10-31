#import "NoGPSDialogViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "View.h"
#import "MessageDialogViewController.h"

@interface NoGPSDialogViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) long count;
@property (nonatomic) BOOL viewWillAppear, viewDidAppear;

@end

@implementation NoGPSDialogViewController

static MessageDialogViewController *vcMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.viewWillAppear = NO;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.lSubject.textColor = THEME_PRI;
        self.lTimer.textColor = THEME_PRI;
        [View setCornerRadiusByWidth:self.lSubject.superview cornerRadius:0.075];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];;
    if(!self.viewDidAppear) {
        self.viewDidAppear = YES;
        self.count = 10;
        [self onRefresh];
        [self startTimer];
        [self spin];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopTimer];
}

- (void)onRefresh {
    [super onRefresh];
    if(self.count == 0) {
        [self stopTimer];
        [View removeChildViewController:self animated:YES];
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"No GPS Signal";
        vcMessage.message = @"Unfortunately, your device is still unable to get GPS signal.";
        vcMessage.negativeTitle = @"Proceed";
        vcMessage.negativeTarget = ^{
            [View removeChildViewController:vcMessage animated:YES];
            [self.delegate onNoGPSProceed];
        };
        vcMessage.positiveTitle = @"Retry";
        vcMessage.positiveTarget = ^{
            [View removeChildViewController:vcMessage animated:YES];
            NoGPSDialogViewController *vcNoGPS = [self.storyboard instantiateViewControllerWithIdentifier: @"vcNoGPS"];
            vcNoGPS.delegate = self.delegate;
            [View addChildViewController:vcMessage childViewController:vcNoGPS animated:YES];
        };
        [View addChildViewController:self.parentViewController childViewController:vcMessage animated:YES];
    }
    if(self.count >= 0) {
        self.lTimer.text = [NSString stringWithFormat:@"%ld", self.count];
        self.count--;
    }
    if(self.app.location != nil) {
        [self stopTimer];
        [View removeChildViewController:vcMessage animated:YES];
        [View removeChildViewController:self animated:YES];
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"GPS Acquired";
        vcMessage.message = @"GPS has been acquired, do you want to use this coordinates?";
        vcMessage.negativeTitle = @"Cancel";
        vcMessage.negativeTarget = ^{
            [View removeChildViewController:vcMessage animated:YES];
            [self.delegate onNoGPSCancel];
        };
        vcMessage.positiveTitle = @"Yes";
        vcMessage.positiveTarget = ^{
            [View removeChildViewController:vcMessage animated:YES];
            [self.delegate onNoGPSAcquired];
        };
        [View addChildViewController:self.parentViewController childViewController:vcMessage animated:YES];
    }
}

- (void)startTimer {
    if(self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onRefresh) userInfo:nil repeats:YES];
    }
}

- (void)stopTimer {
    if(self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)spin {
    CGAffineTransform rotate = CGAffineTransformRotate(self.lSpinner.transform, M_PI_2);
    UILabel *spinner = self.lSpinner;
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        spinner.transform = rotate;
    } completion:^(BOOL finished) {
        if(self.count >= 0 && self.timer != nil) {
            [self spin];
        }
    }];
}

@end
