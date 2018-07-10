#import "MessageDialogViewController.h"
#import "App.h"
#import "View.h"

@interface MessageDialogViewController()

@property (nonatomic) BOOL viewDidAppear;

@end

@implementation MessageDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewDidAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.viewDidAppear) {
        self.viewDidAppear = YES;
        self.lSubject.textColor = THEME_PRI;
        self.btnPositive.backgroundColor = THEME_SEC;
        [View setCornerRadiusByWidth:self.lSubject.superview cornerRadius:0.025];
        [View setCornerRadiusByHeight:self.btnNegative cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.btnPositive cornerRadius:0.3];
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    self.lSubject.text = self.subject;
    self.lMessage.text = self.message;
    if(self.negativeTitle != nil) {
        [self.btnNegative setTitle:self.negativeTitle forState:UIControlStateNormal];
        if(self.negativeTarget != nil) {
            [self.btnNegative addTarget:self.negativeTarget action:@selector(invoke) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else {
        [self.btnNegative removeFromSuperview];
    }
    if(self.positiveTitle != nil) {
        [self.btnPositive setTitle:self.positiveTitle forState:UIControlStateNormal];
        if(self.positiveTarget != nil) {
            [self.btnPositive addTarget:self.positiveTarget action:@selector(invoke) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

@end
