#import "ViewController.h"
#import "SubPageBarCollectionView.h"

@interface ExpenseViewController : ViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, SubPageBarDelegate>

@property (weak, nonatomic) IBOutlet SubPageBarCollectionView *cvSubPageBar;
@property (weak, nonatomic) IBOutlet UIView *vIndicator;

@property (strong, nonatomic) NSMutableArray<ViewController *> *viewControllers;

@end
