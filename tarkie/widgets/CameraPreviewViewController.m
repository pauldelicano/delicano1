#import "CameraPreviewViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "File.h"
#import "View.h"
#import "MessageDialogViewController.h"
#import "PhotoBarItemCollectionViewCell.h"

@interface CameraPreviewViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSCache *cache;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation CameraPreviewViewController

static MessageDialogViewController *vcMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.cache  = NSCache.alloc.init;
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.vStatusBar.backgroundColor = THEME_PRI_DARK;
        self.vNavBar.backgroundColor = THEME_PRI;
        [self.cvPhotos scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedPhoto inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    self.lName.text = self.photos[self.selectedPhoto].filename;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)delete:(id)sender {
    vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
    vcMessage.subject = @"Delete Photo";
    vcMessage.message = @"Are you sure you want to delete photo?";
    vcMessage.negativeTitle = @"No";
    vcMessage.negativeTarget = ^{
        [View removeChildViewController:vcMessage animated:YES];
    };
    vcMessage.positiveTitle = @"Yes";
    vcMessage.positiveTarget = ^{
        [View removeChildViewController:vcMessage animated:YES];
        [self back:self];
        [self.cameraPreviewDelegate onCameraPreviewDelete:self.photos[self.selectedPhoto]];
    };
    [View addChildViewController:self childViewController:vcMessage animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoBarItemCollectionViewCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    UIImage *image = [self.cache objectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    item.ivPhoto.image = image;
    if(image == nil) {
        CGSize size = [(UICollectionViewFlowLayout *)collectionView.collectionViewLayout itemSize];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [File imageFromDocument:self.photos[indexPath.row].filename];
            UIGraphicsBeginImageContext(size);
            [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
            [self.cache setObject:UIGraphicsGetImageFromCurrentImageContext() forKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                item.ivPhoto.image = [self.cache objectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
            });
        });
    }
    return item;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    for(PhotoBarItemCollectionViewCell *item in [self.cvPhotos visibleCells]) {
        NSIndexPath *indexPath = [self.cvPhotos indexPathForCell:item];
        self.selectedPhoto = indexPath.row;
        [self onRefresh];
    }
}

@end
