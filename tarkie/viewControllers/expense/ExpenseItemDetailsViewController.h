#import "ViewController.h"
#import "Expense+CoreDataClass.h"
#import "LayoutConstraint.h"
#import "TextField.h"
#import "TextView.h"
#import "ScrollView.h"
#import "MainViewController.h"
#import "StoresViewController.h"
#import "ListDialogViewController.h"
#import "CameraViewController.h"

@protocol ExpenseItemDetailsDelegate
@optional

- (void)onExpenseItemDetailsSave:(NSInteger)section expense:(Expense *)expense;

@end

@interface ExpenseItemDetailsViewController : ViewController<TextFieldDelegate, StoresDelegate, ListDelegate, CameraDelegate>

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;

@property (weak, nonatomic) IBOutlet UILabel *lStore;
@property (weak, nonatomic) IBOutlet TextField *tfStore;
@property (weak, nonatomic) IBOutlet UIButton *btnStore;

@property (weak, nonatomic) IBOutlet TextField *tfExpenseType;
@property (weak, nonatomic) IBOutlet UIButton *btnExpenseType;
@property (weak, nonatomic) IBOutlet UILabel *lDateCreated;
@property (weak, nonatomic) IBOutlet UIButton *btnPhoto;
@property (weak, nonatomic) IBOutlet LayoutConstraint *btnPhotoLeading;
@property (weak, nonatomic) IBOutlet LayoutConstraint *btnPhotoHeight;

@property (weak, nonatomic) IBOutlet TextField *tfRate;
@property (weak, nonatomic) IBOutlet LayoutConstraint *vRateHeight;

@property (weak, nonatomic) IBOutlet UISwitch *swIsKilometer;
@property (weak, nonatomic) IBOutlet LayoutConstraint *vIsKilometerHeight;

@property (weak, nonatomic) IBOutlet TextField *tfLiters;
@property (weak, nonatomic) IBOutlet LayoutConstraint *vLitersHeight;

@property (weak, nonatomic) IBOutlet TextField *tfPrice;
@property (weak, nonatomic) IBOutlet LayoutConstraint *vPriceHeight;

@property (weak, nonatomic) IBOutlet UILabel *lStart;
@property (weak, nonatomic) IBOutlet TextField *tfStart;
@property (weak, nonatomic) IBOutlet UIButton *btnStartPhoto;
@property (weak, nonatomic) IBOutlet LayoutConstraint *vStartHeight;

@property (weak, nonatomic) IBOutlet TextField *tfEnd;
@property (weak, nonatomic) IBOutlet UIButton *btnEndPhoto;
@property (weak, nonatomic) IBOutlet LayoutConstraint *vEndHeight;

@property (weak, nonatomic) IBOutlet TextField *tfAmount;

@property (weak, nonatomic) IBOutlet UISwitch *swWithOR;
@property (weak, nonatomic) IBOutlet LayoutConstraint *vWithORHeight;

@property (weak, nonatomic) IBOutlet UISwitch *swIsReimbursable;

@property (weak, nonatomic) IBOutlet TextField *tfOrigin;

@property (weak, nonatomic) IBOutlet TextField *tfDestination;

@property (weak, nonatomic) IBOutlet TextView *tfNotes;

@property (assign) id <ExpenseItemDetailsDelegate> delegate;
@property (strong, nonatomic) MainViewController *main;
@property (nonatomic) NSInteger section;
@property (strong, nonatomic) Expense *expense;

@end
