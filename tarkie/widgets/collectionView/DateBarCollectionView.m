#import "DateBarCollectionView.h"
#import "Time.h"
#import "DateBarItemCollectionViewCell.h"

@interface DateBarCollectionView()

@property (strong, nonatomic) NSMutableArray<NSDate *> *insertDates;
@property (strong, nonatomic) NSMutableArray<NSIndexPath *> *insertIndexPaths;
@property (nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic) int countLeft, countRight;
@property (nonatomic) int isDrawn, isLeft, isRight;

@end

@implementation DateBarCollectionView

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

- (instancetype)initialize:(DateBarCollectionView *)instance {
    instance.delegate = self;
    instance.dataSource = self;
    self.insertDates = NSMutableArray.alloc.init;
    self.insertIndexPaths = NSMutableArray.alloc.init;
    self.selectedIndexPath = nil;
    self.isDrawn = NO;
    return instance;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if(!self.isDrawn) {
        self.isDrawn = YES;
        [self selectInitialDate];
    }
}

- (void)selectInitialDate {
    if(self.dates.count > 5) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
        [self selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionLeft];
        [self collectionView:self didSelectItemAtIndexPath:indexPath];
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(self.selectedIndexPath != nil) {
        if(self.isLeft) {
            self.countLeft++;
        }
        if(self.isRight) {
            self.countRight++;
        }
    }
    return self.dates.count;
}

- (DateBarItemCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DateBarItemCollectionViewCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    item.selectedBackgroundColor = self.selectedBackgroundColor;
    item.textColor = self.textColor;
    item.selected = indexPath == self.selectedIndexPath;
    NSDate *date = self.dates[indexPath.row];
    item.lDate.text = [Time getFormattedDate:@"MMM d" date:date];
    item.lDay.text = [Time getFormattedDate:@"EEE" date:date];
    return item;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.dates[indexPath.row] == self.dates[0] && self.selectedIndexPath != nil) {
        if(self.countLeft == 0) {
            self.isLeft = YES;
            self.isRight = NO;
            self.countRight = 0;
            [self.insertDates removeAllObjects];
            [self.insertIndexPaths removeAllObjects];
            for(int x = 0; x < 5; x++) {
                [self.insertDates addObject:[self.dates[0] dateByAddingTimeInterval:60 * 60 * 24 * (x - 5)]];
                [self.insertIndexPaths addObject:[NSIndexPath indexPathForRow:x inSection:0]];
            }
            [self.insertDates addObjectsFromArray:self.dates];
            [self.dates removeAllObjects];
            [self.dates addObjectsFromArray:self.insertDates];
            [collectionView performBatchUpdates:^{
                [collectionView insertItemsAtIndexPaths:self.insertIndexPaths];
            } completion:^(BOOL finished) {
                [collectionView reloadData];
            }];
        }
        if(self.countLeft == 2) {
            [self selectItemAtIndexPath:[NSIndexPath indexPathForRow:self.insertIndexPaths[0].row + self.insertIndexPaths.count inSection:self.insertIndexPaths[0].section] animated:NO scrollPosition:UICollectionViewScrollPositionLeft];
            self.selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row + self.insertIndexPaths.count inSection:self.selectedIndexPath.section];
            [self selectItemAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            self.isLeft = NO;
            self.countLeft = 0;
        }
    }
    if(self.dates[indexPath.row] == self.dates[self.dates.count - 1]) {
        if(self.countRight == 0) {
            self.isRight = YES;
            self.isLeft = NO;
            self.countLeft = 0;
            long datesCount = self.dates.count;
            [self.insertIndexPaths removeAllObjects];
            for(int x = 1; x < 6; x++) {
                [self.dates addObject:[self.dates[datesCount - 1] dateByAddingTimeInterval:60 * 60 * 24 * x]];
                [self.insertIndexPaths addObject:[NSIndexPath indexPathForRow:datesCount - 1 + x inSection:0]];
            }
            [collectionView performBatchUpdates:^{
                [collectionView insertItemsAtIndexPaths:self.insertIndexPaths];
            } completion:^(BOOL finished) {
                [collectionView reloadData];
            }];
        }
        if(self.countRight == 1) {
            self.isRight = NO;
            self.countRight = 0;
        }
    }
    [cell setNeedsDisplay];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = collectionView.frame.size;
    size.width = size.width / 5;
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.dateBarDelegate onDateBarSelect:self.dates[indexPath.row]];
    self.selectedIndexPath = indexPath;
}

@end
