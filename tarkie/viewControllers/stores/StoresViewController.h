#import "CustomViewController.h"
#import "Stores+CoreDataClass.h"
#import "TextField.h"
#import "EditStoreViewController.h"
#import "StoreContactsViewController.h"

@protocol StoresDelegate
@optional

- (void)onStoresSelect:(Stores *)store;

@end

@interface StoresViewController : CustomViewController<UITableViewDataSource, UITableViewDelegate, TextFieldDelegate, EditStoreDelegate, StoreContactsDelegate>

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet TextField *tfSearch;
@property (weak, nonatomic) IBOutlet UITableView *tvStores;

typedef enum {
    STORE_ACTION_CONTACTS,
    STORE_ACTION_SELECT
} StoreAction;

@property (assign) id <StoresDelegate> delegate;
@property (nonatomic) StoreAction action;

@end
