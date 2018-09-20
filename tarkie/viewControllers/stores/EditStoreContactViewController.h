#import "ViewController.h"
#import "Stores+CoreDataClass.h"
#import "StoreContacts+CoreDataClass.h"
#import "ScrollView.h"
#import "TextField.h"
#import "TextView.h"

@protocol EditStoreContactDelegate
@optional

- (void)onEditStoreContactSave:(StoreContacts *)storeContact;

@end

@interface EditStoreContactViewController : ViewController

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet TextField *tfStoreContactName;
@property (weak, nonatomic) IBOutlet TextField *tfDesignation;
@property (weak, nonatomic) IBOutlet TextField *tfEmail;
@property (weak, nonatomic) IBOutlet TextField *tfMobileNumber;
@property (weak, nonatomic) IBOutlet TextField *tfLandlineNumber;
@property (weak, nonatomic) IBOutlet TextField *tfBirthdate;
@property (weak, nonatomic) IBOutlet TextView *tfRemarks;

@property (assign) id <EditStoreContactDelegate> delegate;
@property (strong, nonatomic) Stores *store;
@property (strong, nonatomic) StoreContacts *storeContact;

@end
