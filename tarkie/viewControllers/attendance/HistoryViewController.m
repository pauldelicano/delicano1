#import "HistoryViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Time.h"
#import "MainViewController.h"
#import "AttendanceViewController.h"
#import "ActivitiesViewController.h"

@interface HistoryViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) MainViewController *main;
@property (strong, nonatomic) NSMutableArray<NSString *> *pages;
@property (strong, nonatomic) NSMutableArray<ViewController *> *viewControllers;
@property (strong, nonatomic) NSDate *selectedDate;
@property (nonatomic) long currentPage, nextPage;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.main = (MainViewController *)self.parentViewController.parentViewController;
    self.cvSubPageBar.subPageBarDelegate = self;
    self.pages = NSMutableArray.alloc.init;
    self.viewControllers = NSMutableArray.alloc.init;
    for(int x = 0; x < self.childViewControllers.count; x++) {
        if([self.childViewControllers[x] isKindOfClass:UIPageViewController.class]) {
            self.pvcHistory = self.childViewControllers[x];
            self.pvcHistory.dataSource = self;
            self.pvcHistory.delegate = self;
            for(UIView *view in self.pvcHistory.view.subviews) {
                if([view isKindOfClass:UIScrollView.class]) {
                    ((UIScrollView *)view).delegate = self;
                }
            }
        }
    }
    self.selectedDate = NSDate.date;
    [self.pages removeAllObjects];
    [self.viewControllers removeAllObjects];
    [self.pages addObject:@"Attendance"];
    [self.pages addObject:@"Activities"];
    for(NSString *page in self.pages) {
        if([page isEqualToString:@"Attendance"]) {
            AttendanceViewController *vcAttendance = [self.storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"vc%@", page]];
            vcAttendance.main = self.main;
            [self.viewControllers addObject:vcAttendance];
        }
        if([page isEqualToString:@"Activities"]) {
            ActivitiesViewController *vcActivities = [self.storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"vc%@", page]];
            vcActivities.main = self.main;
            [self.viewControllers addObject:vcActivities];
        }
    }
    self.cvSubPageBar.pages = self.pages;
    [self.cvSubPageBar reloadData];
    self.viewWillAppear = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if(self.viewWillAppear) {
        CGRect cell = [self.cvSubPageBar cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:0]].frame;
        CGRect frame = self.vIndicator.frame;
        frame.origin.x = cell.origin.x;
        frame.size.width = cell.size.width;
        self.vIndicator.frame = frame;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.vIndicator.backgroundColor = THEME_SEC;
        [self onRefresh];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.currentPage != self.nextPage) {
        self.currentPage = self.nextPage;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentPage inSection:0];
        [self.cvSubPageBar selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionLeft];
        CGRect cell = [self.cvSubPageBar cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:0]].frame;
        CGRect frame = self.vIndicator.frame;
        frame.origin.x = cell.origin.x;
        frame.size.width = cell.size.width;
        self.vIndicator.frame = frame;
        [self.pvcHistory setViewControllers:@[self.viewControllers[self.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
}

- (void)onRefresh {
    [super onRefresh];
    self.main.lNavBarButtonsHistoryDate.text = [Time getFormattedDate:self.app.settingDisplayDateFormat date:self.selectedDate];
    for(ViewController *viewController in self.viewControllers) {
        if([viewController isKindOfClass:AttendanceViewController.class]) {
            ((AttendanceViewController *)viewController).selectedDate = self.selectedDate;

        }
        if([viewController isKindOfClass:ActivitiesViewController.class]) {
            ((ActivitiesViewController *)viewController).selectedDate = self.selectedDate;
        }
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if(self.currentPage == 0) {
        return nil;
    }
    return self.viewControllers[self.currentPage - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if(self.currentPage == self.viewControllers.count - 1) {
        return nil;
    }
    return self.viewControllers[self.currentPage + 1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<ViewController *> *)pendingViewControllers {
    self.nextPage = [self.viewControllers indexOfObject:pendingViewControllers.lastObject];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if(finished) {
        if(completed) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.nextPage inSection:0];
            [self.cvSubPageBar selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionLeft];
            [self.cvSubPageBar collectionView:self.cvSubPageBar didSelectItemAtIndexPath:indexPath];
        }
        else {
            self.nextPage = self.currentPage;
        }
    }
}

- (void)onSubPageBarSelect:(long)page {
    self.currentPage = page;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                CGRect cell = [self.cvSubPageBar cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:0]].frame;
                CGRect frame = self.vIndicator.frame;
                frame.origin.x = cell.origin.x;
                frame.size.width = cell.size.width;
                self.vIndicator.frame = frame;
            }];
            [self.pvcHistory setViewControllers:@[self.viewControllers[self.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        });
    });
}

- (void)onCalendarPick:(NSDate *)date type:(int)type {
    self.selectedDate = date;
    [self onRefresh];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
    else if(self.currentPage == self.viewControllers.count - 1 && scrollView.contentOffset.x > scrollView.bounds.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if(self.currentPage == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width) {
        *targetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
    else if(self.currentPage == self.viewControllers.count - 1 && scrollView.contentOffset.x >= scrollView.bounds.size.width) {
        *targetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
}

@end
