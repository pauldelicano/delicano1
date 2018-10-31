#import <UIKit/UIKit.h>

@protocol SubPageBarDelegate
@optional

- (void)onSubPageBarSelect:(long)page;

@end

@interface SubPageBarCollectionView : UICollectionView<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>

@property (assign) id <SubPageBarDelegate> subPageBarDelegate;
@property (strong, nonatomic) NSArray<NSString *> *pages;

@end
