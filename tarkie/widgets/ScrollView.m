#import "ScrollView.h"

@interface ScrollView()

@property (nonatomic) CGFloat insetTop, insetBottom;

@end

@implementation ScrollView

- (instancetype)init {
    return [self initialize:[super init]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initialize:[super initWithCoder:aDecoder]];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initialize:[super initWithFrame:frame]];
}

- (instancetype)initialize:(ScrollView *)instance {
    return instance;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if(newWindow == nil) {
        [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardDidHideNotification object:nil];
        return;
    }
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.insetTop = self.contentInset.top;
    self.insetBottom = self.contentInset.bottom;
}

- (void)keyboardDidShow:(NSNotification *)notification {
    UIEdgeInsets contentInset = UIEdgeInsetsMake(self.insetTop, 0, self.insetBottom + [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height, 0);
    [UIView animateWithDuration:0.125 animations:^{
        self.contentInset = contentInset;
        self.scrollIndicatorInsets = contentInset;
    } completion:^(BOOL finished) {
        [self scrollToFirstResponder:self];
    }];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    UIEdgeInsets contentInset = UIEdgeInsetsMake(self.insetTop, 0, self.insetBottom, 0);
    [UIView animateWithDuration:0.125 animations:^{
        self.contentInset = contentInset;
        self.scrollIndicatorInsets = contentInset;
    }];
}

- (BOOL)scrollToFirstResponder:(UIView *)view {
    if(view.isFirstResponder) {
        [self scrollRectToVisible:view.frame animated:YES];
        return YES;
    }
    for(UIView *subview in view.subviews) {
        if([self scrollToFirstResponder:subview]) {
            return YES;
        }
    }
    return NO;
}

@end
