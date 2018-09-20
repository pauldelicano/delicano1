#import "ViewController.h"
#import "Stores+CoreDataClass.h"
#import "EditStoreViewController.h"
#import "EditStoreContactViewController.h"

@protocol StoreContactsDelegate
@optional

- (void)onStoreContactsEditStoreSave:(Stores *)store;

@end

@interface StoreContactsViewController : ViewController<EditStoreDelegate, EditStoreContactDelegate>

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UITableView *tvStoreContacts;

@property (assign) id <StoreContactsDelegate> delegate;
@property (strong, nonatomic) Stores *store;

@end
