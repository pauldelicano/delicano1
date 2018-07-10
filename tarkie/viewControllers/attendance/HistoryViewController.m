#import "HistoryViewController.h"

@interface HistoryViewController()

@property (nonatomic) BOOL viewDidAppear;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewDidAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.viewDidAppear) {
        self.viewDidAppear = YES;
    }
    [self onRefresh];
}

- (void)onRefresh {
    [super onRefresh];
}

@end
