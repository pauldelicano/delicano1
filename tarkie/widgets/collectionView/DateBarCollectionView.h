#import <UIKit/UIKit.h>

@protocol DateBarDelegate
@optional

- (void)onDateBarSelect:(NSDate *)date;

@end

@interface DateBarCollectionView : UICollectionView<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>

@property (assign) id <DateBarDelegate> dateBarDelegate;
@property (strong, nonatomic) NSMutableArray<NSDate *> *dates;
@property (strong, nonatomic) UIColor *selectedBackgroundColor;
@property (strong, nonatomic) UIColor *textColor;

@end
