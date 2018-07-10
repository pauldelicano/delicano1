#import "ExpenseViewController.h"

@interface ExpenseViewController()

@property (nonatomic) BOOL viewDidAppear;

@end

@implementation ExpenseViewController

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
