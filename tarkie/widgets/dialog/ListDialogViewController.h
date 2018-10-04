#import "ViewController.h"
#import "LayoutConstraint.h"

@protocol ListDelegate
@optional

- (void)onListSelect:(int)type item:(id)item;

@end

@interface ListDialogViewController : ViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tvItems;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet LayoutConstraint *tvItemsHeight;

typedef enum {
    LIST_TYPE_BREAK,
    LIST_TYPE_MAP
} ListType;

@property (assign) id <ListDelegate> delegate;
@property (nonatomic) ListType type;
@property (strong, nonatomic) NSArray *items;

@end
