#import "SubPageBarCollectionView.h"
#import "SubPageBarItemCollectionViewCell.h"

@interface SubPageBarCollectionView()

@property (nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic) BOOL isDrawn;

@end

@implementation SubPageBarCollectionView

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

- (instancetype)initialize:(SubPageBarCollectionView *)instance {
    instance.delegate = self;
    instance.dataSource = self;
    self.isDrawn = NO;
    return instance;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if(!self.isDrawn) {
        self.isDrawn = YES;
        [self selectInitialPage];
    }
}

- (void)reloadData {
    [super reloadData];
    if(self.isDrawn) {
        [self selectInitialPage];
    }
}

- (void)selectInitialPage {
    if(self.pages.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionLeft];
        [self collectionView:self didSelectItemAtIndexPath:indexPath];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pages.count;
}

- (SubPageBarItemCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SubPageBarItemCollectionViewCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    item.selected = indexPath == self.selectedIndexPath;
    item.lName.text = self.pages[indexPath.row];
    return item;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = collectionView.frame.size;
    size.width = size.width / self.pages.count;
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.subPageBarDelegate onSubPageBarSelect:indexPath.row];
    self.selectedIndexPath = indexPath;
}

@end
