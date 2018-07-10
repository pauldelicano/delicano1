#import "CustomViewController.h"
#import "Image.h"
#import "View.h"
#import "TextField.h"
#import "TextView.h"

@interface CustomViewController()

@property (strong, nonatomic) NSMutableArray<TextField *> *textfields;
@property (strong, nonatomic) NSMutableArray<TextView *> *textviews;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@end

@implementation CustomViewController

static UIScrollView *vScroll;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textfields = NSMutableArray.alloc.init;
    self.textviews = NSMutableArray.alloc.init;
    self.tapGesture = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(hideKeyboard)];
    [self.tapGesture setCancelsTouchesInView:NO];
    [self scaleView:self.view];
    vScroll = nil;
    if((self.textfields.count > 0 || self.textviews.count > 0) && [self.view.subviews.lastObject isKindOfClass:UIScrollView.class] && ![self.view.subviews.lastObject isKindOfClass:UITableView.class]) {
        vScroll = self.view.subviews.lastObject;
    }
    [self keyboardWillHide:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view layoutIfNeeded];
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
        [View scaleFontSize:((UIButton *)view).titleLabel];
        [(UIButton *)view setBackgroundImage:[Image fromColor:[UIColor colorNamed:@"BlackTransSixty"]] forState:UIControlStateHighlighted];
        return;
    }
    if([view isKindOfClass:TextField.class]) {
        [View scaleFontSize:view];
        [self.textfields addObject:(TextField *)view];
        return;
    }
    if([view isKindOfClass:TextView.class]) {
        [View scaleFontSize:view];
        [self.textviews addObject:(TextView *)view];
        return;
    }
    for(int x = 0; x < view.subviews.count; x++) {
        [self scaleView:view.subviews[x]];
    }
}

- (void)onRefresh {
    
}

- (void)hideKeyboard {
    for(int x = 0; x < self.textfields.count; x++) {
        [self.textfields[x] endEditing:YES];
    }
    for(int x = 0; x < self.textviews.count; x++) {
        [self.textviews[x] endEditing:YES];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification {
    [self.view addGestureRecognizer:self.tapGesture];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    if(vScroll != nil) {
        CGFloat keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        CGRect parent = self.view.frame;
        parent.size.height -= keyboardHeight;
        CGRect view = CGRectZero;
        for(int x = 0; view.origin.y == 0 && x < self.textfields.count; x++) {
            if(self.textfields[x].isFirstResponder) {
                view = self.textfields[x].frame;
                keyboardHeight += self.textfields[x].layoutMargins.bottom;
                break;
            }
        }
        for(int x = 0; view.origin.y == 0 && x < self.textviews.count; x++) {
            if(self.textviews[x].isFirstResponder) {
                view = self.textviews[x].frame;
                keyboardHeight += self.textviews[x].layoutMargins.bottom;
                break;
            }
        }
        if(!CGRectContainsPoint(parent, view.origin)) {
            UIEdgeInsets contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
            vScroll.contentInset = contentInset;
            vScroll.scrollIndicatorInsets = contentInset;
            [vScroll scrollRectToVisible:view animated:YES];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self.view removeGestureRecognizer:self.tapGesture];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    if(vScroll != nil) {
        vScroll.contentInset = UIEdgeInsetsZero;
        vScroll.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
}

@end
