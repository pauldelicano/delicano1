#import <UIKit/UIKit.h>

@protocol MainPageBarDelegate
@optional

- (void)onMainPageBarSelect:(long)page;

@end

@interface MainPageBarCollectionView : UICollectionView<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>

@property (assign) id <MainPageBarDelegate> mainPageBarDelegate;
@property (strong, nonatomic) NSArray<NSDictionary *> *pages;

@end
