#import "ViewController.h"
#import "Photos+CoreDataClass.h"

@protocol CameraPreviewDelegate
@optional

- (void)onCameraPreviewDelete:(Photos *)image;

@end

@interface CameraPreviewViewController : ViewController<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UICollectionView *cvPhotos;

@property (assign) id <CameraPreviewDelegate> cameraPreviewDelegate;
@property (strong, nonatomic) NSArray<Photos *> *photos;
@property (nonatomic) long selectedPhoto;

@end
