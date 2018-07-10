#import "NoGPSDialogViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "View.h"
#import "MessageDialogViewController.h"

@interface NoGPSDialogViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) long count;
@property (nonatomic) BOOL viewDidAppear;

@end

@implementation NoGPSDialogViewController

static MessageDialogViewController *vcMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.viewDidAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.viewDidAppear) {
        self.viewDidAppear = YES;
        self.lSubject.textColor = THEME_PRI;
        self.lTimer.textColor = THEME_PRI;
        [View setCornerRadiusByWidth:self.lSubject.superview cornerRadius:0.025];
        self.count = 10;
        [self onRefresh];
        [self startTimer];
        [self spin];
    }
}

- (void)onRefresh {
    [super onRefresh];
    if(self.count == 0) {
        [self stopTimer];
        [View removeView:self.view animated:YES];
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"No GPS Signal";
        vcMessage.message = @"Unfortunately, your device is still unable to get GPS signal.";
        vcMessage.negativeTitle = @"Proceed";
        vcMessage.negativeTarget = ^{
            [View removeView:vcMessage.view animated:YES];
            [self.delegate onNoGPSProceed];
        };
        vcMessage.positiveTitle = @"Retry";
        vcMessage.positiveTarget = ^{
            [View removeView:vcMessage.view animated:YES];
            NoGPSDialogViewController *vcNoGPS = [self.storyboard instantiateViewControllerWithIdentifier: @"vcNoGPS"];
            vcNoGPS.delegate = self.delegate;
            [View addSubview:vcMessage.view.superview subview:vcNoGPS.view animated:YES];
        };
        [View addSubview:self.view.superview subview:vcMessage.view animated:YES];
    }
    if(self.count >= 0) {
        self.lTimer.text = [NSString stringWithFormat:@"%ld", self.count];
        self.count--;
    }
    if(self.app.location != nil) {
        [self stopTimer];
        [View removeView:vcMessage.view animated:YES];
        [View removeView:self.view animated:YES];
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"GPS Acquired";
        vcMessage.message = @"GPS has been acquired, do you want to use this coordinates?";
        vcMessage.negativeTitle = @"Cancel";
        vcMessage.negativeTarget = ^{
            [View removeView:vcMessage.view animated:YES];
            [self.delegate onNoGPSCancel];
        };
        vcMessage.positiveTitle = @"Yes";
        vcMessage.positiveTarget = ^{
            [View removeView:vcMessage.view animated:YES];
            [self.delegate onNoGPSAcquired];
        };
        [View addSubview:self.view.superview subview:vcMessage.view animated:YES];
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
