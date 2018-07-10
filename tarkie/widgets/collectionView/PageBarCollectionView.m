#import "PageBarCollectionView.h"
#import "PageBarItemCollectionViewCell.h"

@interface PageBarCollectionView()

@property (nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic) BOOL isDrawn;

@end

@implementation PageBarCollectionView

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

- (instancetype)initialize:(PageBarCollectionView *)instance {
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

- (PageBarItemCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PageBarItemCollectionViewCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    item.selected = indexPath == self.selectedIndexPath;
    NSDictionary *page = self.pages[indexPath.row];
    id icon = [page objectForKey:@"icon"];
    if([icon isKindOfClass:UIImage.class]) {
        item.ivIcon.alpha = 1;
        item.lIcon.alpha = 0;
        item.ivIcon.image = icon;
    }
    if([icon isKindOfClass:NSString.class]) {
        item.ivIcon.alpha = 0;
        item.lIcon.alpha = 1;
        item.lIcon.text = icon;
    }
    item.lName.text = [page objectForKey:@"name"];
    return item;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = collectionView.frame.size;
    size.width = size.width / self.pages.count;
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.pageBarDelegate onPageBarSelect:(int)indexPath.row];
    self.selectedIndexPath = indexPath;
}

@end
