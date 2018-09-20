#import "ViewController.h"
#import "File.h"
#import "View.h"
#import "Color.h"
#import "TextField.h"
#import "TextView.h"

@interface ViewController()

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tapGesture = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(hideKeyboard)];
    [self.tapGesture setCancelsTouchesInView:NO];
    [self scaleView:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    [self.view addGestureRecognizer:self.tapGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view layoutIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.view removeGestureRecognizer:self.tapGesture];
}

- (void)scaleView:(UIView *)view {
    if([view isKindOfClass:UITableView.class] || [view isKindOfClass:UICollectionView.class]) {
        return;
    }
    [View scaleViewSize:view];
    if([view isKindOfClass:UILabel.class]) {
        [View scaleFontSize:view];
        return;
    }
    if([view isKindOfClass:UIButton.class]) {
        ((UIButton *)view).imageView.contentMode = UIViewContentModeScaleAspectFit;
        [View scaleFontSize:((UIButton *)view).titleLabel];
        [(UIButton *)view setBackgroundImage:[File imageFromColor:[Color colorNamed:@"BlackTransSixty"]] forState:UIControlStateHighlighted];
        return;
    }
    if([view isKindOfClass:TextField.class]) {
        [View scaleFontSize:view];
        return;
    }
    if([view isKindOfClass:TextView.class]) {
        [View scaleFontSize:view];
        return;
    }
    for(UIView *subview in view.subviews) {
        [self scaleView:subview];
    }
}

- (void)onRefresh {
    
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

@end
