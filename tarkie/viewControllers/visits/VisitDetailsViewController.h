#import "ViewController.h"
#import "Visits+CoreDataClass.h"
#import "ScrollView.h"
#import "TextView.h"
#import "MainViewController.h"
#import "StoresViewController.h"
#import "PhotoBarCollectionView.h"
#import "CameraPreviewViewController.h"

@interface VisitDetailsViewController : ViewController<UITableViewDataSource, UITableViewDelegate, StoresDelegate, PhotoBarDelegate, CameraDelegate, CameraPreviewDelegate, DropDownDelegate, ListDelegate>

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet UILabel *lStoreName;
@property (weak, nonatomic) IBOutlet UILabel *lStoreAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnEditStore;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckIn;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckOut;
@property (weak, nonatomic) IBOutlet UIView *vInventory;
@property (weak, nonatomic) IBOutlet UIView *lInventoryBorder;
@property (weak, nonatomic) IBOutlet UITableView *tvInventory;
@property (weak, nonatomic) IBOutlet UIButton *btnInventory;
@property (weak, nonatomic) IBOutlet UIView *vForms;
@property (weak, nonatomic) IBOutlet UIView *lFormsBorder;
@property (weak, nonatomic) IBOutlet UITableView *tvForms;
@property (weak, nonatomic) IBOutlet UIButton *btnForms;
@property (weak, nonatomic) IBOutlet UILabel *lInvoice;
@property (weak, nonatomic) IBOutlet UILabel *lInvoiceValue;
@property (weak, nonatomic) IBOutlet UILabel *lDeliveries;
@property (weak, nonatomic) IBOutlet UILabel *lDeliveriesValue;
@property (weak, nonatomic) IBOutlet UIView *lPhotosBorder;
@property (weak, nonatomic) IBOutlet PhotoBarCollectionView *cvPhotos;
@property (weak, nonatomic) IBOutlet UIView *lNotesBorder;
@property (weak, nonatomic) IBOutlet TextView *tfNotes;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vInventoryHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tvInventoryHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vFormsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tvFormsHeight;

@property (strong, nonatomic) MainViewController *main;
@property (strong, nonatomic) Visits *visit;

@end
