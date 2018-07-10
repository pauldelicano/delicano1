#import <UIKit/UIKit.h>

@protocol PhotoBarDelegate
@optional

- (void)onPhotoBarPreview:(long)selectedPhoto;
- (void)onPhotoBarAdd;

@end

@interface PhotoBarCollectionView : UICollectionView<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>

@property (assign) id <PhotoBarDelegate> photoBarDelegate;
@property (strong, nonatomic) NSArray<UIImage *> *photos;

@end
