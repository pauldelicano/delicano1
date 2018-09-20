#import <UIKit/UIKit.h>

@protocol PageBarDelegate
@optional

- (void)onPageBarSelect:(long)page;

@end

@interface PageBarCollectionView : UICollectionView<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>

@property (assign) id <PageBarDelegate> pageBarDelegate;
@property (strong, nonatomic) NSArray<NSDictionary *> *pages;

@end
