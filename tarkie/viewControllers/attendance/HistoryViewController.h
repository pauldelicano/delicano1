#import "ViewController.h"
#import "SubPageBarCollectionView.h"

@interface HistoryViewController : ViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, SubPageBarDelegate>

@property (weak, nonatomic) IBOutlet SubPageBarCollectionView *cvSubPageBar;
@property (weak, nonatomic) IBOutlet UIView *vIndicator;

@property (strong, nonatomic) UIPageViewController *pvcHistory;

- (void)onCalendarPick:(NSDate *)date type:(int)type;

@end
