#import "InventoryViewController.h"

@interface InventoryViewController()

@property (nonatomic) BOOL viewWillAppear;

@end

@implementation InventoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
    }
    [self onRefresh];
}

- (void)onRefresh {
    [super onRefresh];
}

@end
