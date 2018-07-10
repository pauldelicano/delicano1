#import "PhotoBarCollectionView.h"
#import "PhotoBarItemCollectionViewCell.h"

@interface PhotoBarCollectionView()

@property (strong, nonatomic) NSMutableArray<UIImage *> *gallery;
@property (strong, nonatomic) NSCache *cache;

@end

@implementation PhotoBarCollectionView

- (instancetype)init {
    return [self initialize:[super init]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initialize:[super initWithCoder:aDecoder]];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initialize:[super initWithFrame:frame]];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    return [self initialize:[super initWithFrame:frame collectionViewLayout:layout]];
}

- (instancetype)initialize:(PhotoBarCollectionView *)instance {
    instance.delegate = self;
    instance.dataSource = self;
    self.gallery = NSMutableArray.alloc.init;
    self.cache = NSCache.alloc.init;
    return instance;
}

- (void)setPhotos:(NSArray<UIImage *> *)photos {
    [self.gallery removeAllObjects];
    [self.gallery addObjectsFromArray:photos];
    [self.gallery addObject:UIImage.alloc.init];
}

- (void)reloadData {
    [super reloadData];
    if(self.gallery.count > 0) {
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.gallery.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.gallery.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == self.gallery.count - 1) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"button" forIndexPath:indexPath];
    }
    PhotoBarItemCollectionViewCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    UIImage *image = [self.cache objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
    item.ivPhoto.image = image;
    if(image == nil) {
        CGSize size = [self collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = self.gallery[indexPath.row];
            UIGraphicsBeginImageContext(size);
            [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
            [self.cache setObject:UIGraphicsGetImageFromCurrentImageContext() forKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                item.ivPhoto.image = [self.cache objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
            });
        });
    }
    return item;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = collectionView.frame.size;
    CGFloat height = size.height - ((25.0f / 568) * UIScreen.mainScreen.bounds.size.height);
    size.width = height;
    size.height = height;
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == self.gallery.count - 1) {
        [self.photoBarDelegate onPhotoBarAdd];
        return;
    }
    [self.photoBarDelegate onPhotoBarPreview:indexPath.row];
}

@end
