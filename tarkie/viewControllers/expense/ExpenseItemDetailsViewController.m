#import "ExpenseItemDetailsViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Load.h"
#import "Update.h"
#import "File.h"
#import "View.h"
#import "Time.h"
#import "MessageDialogViewController.h"

@interface ExpenseItemDetailsViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) Stores *store;
@property (strong, nonatomic) ExpenseTypes *expenseType;
@property (strong, nonatomic) NSString *photoFilename, *startPhotoFilename, *endPhotoFilename;
@property (nonatomic) float photoLeading, photoHeight;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation ExpenseItemDetailsViewController

static MessageDialogViewController *vcMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.photoLeading = self.btnPhotoLeading.constant;
    self.photoHeight = self.btnPhotoHeight.constant;
    self.btnPhoto.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.btnStartPhoto.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.btnEndPhoto.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.tfRate.textFieldDelegate = self;
    self.tfLiters.textFieldDelegate = self;
    self.tfPrice.textFieldDelegate = self;
    self.tfStart.textFieldDelegate = self;
    self.tfEnd.textFieldDelegate = self;
    self.store = [Get store:self.app.dbAlerts storeID:self.expense.storeID];
    self.expenseType = [Get expenseType:self.app.db expenseTypeID:self.expense.expenseTypeID];
    self.lStore.text = self.app.conventionStores;
    self.tfStore.placeholder = [NSString stringWithFormat:@"Select %@", self.app.conventionStores];
    self.tfStore.text = self.app.settingStoreDisplayLongName ? self.store.name : self.store.shortName;
    self.tfExpenseType.text = self.expenseType.expenseTypeID != 0 ? self.expenseType.name : self.expense.name;
    self.lDateCreated.text = [NSString stringWithFormat:@"%@ at %@", [Time formatDate:self.app.settingDisplayDateFormat date:self.expense.date], [Time formatTime:self.app.settingDisplayTimeFormat time:self.expense.time]];
    self.tfAmount.text = self.expense.amount > 0 ? [NSString stringWithFormat:@"%.2f", self.expense.amount] : nil;
    self.swIsReimbursable.on = self.expense.isReimbursable;
    self.tfOrigin.text = self.expense.origin;
    self.tfDestination.text = self.expense.destination;
    self.tfNotes.text = self.expense.notes;
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.vStatusBar.backgroundColor = THEME_PRI_DARK;
        self.vNavBar.backgroundColor = THEME_PRI;
        self.tfRate.highlightedBorderColor = THEME_SEC;
        self.tfLiters.highlightedBorderColor = THEME_SEC;
        self.tfPrice.highlightedBorderColor = THEME_SEC;
        self.tfStart.highlightedBorderColor = THEME_SEC;
        self.tfEnd.highlightedBorderColor = THEME_SEC;
        self.tfAmount.highlightedBorderColor = THEME_SEC;
        self.tfOrigin.highlightedBorderColor = THEME_SEC;
        self.tfDestination.highlightedBorderColor = THEME_SEC;
        self.tfNotes.highlightedBorderColor = THEME_SEC;
        [self.btnSave setTitleColor:THEME_PRI forState:UIControlStateNormal];
        [View setCornerRadiusByHeight:self.btnSave cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfStore cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.btnStore cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfExpenseType cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.btnExpenseType cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfRate cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfLiters cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfPrice cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfStart cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfEnd cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfAmount cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfOrigin cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfDestination cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfNotes cornerRadius:0.125];
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    if(self.expenseType.expenseTypeID == 1) {
        self.btnPhotoLeading.constant = 0;
        self.btnPhotoHeight.constant = 0;
        self.vRateHeight.active = NO;
        self.vIsKilometerHeight.active = NO;
        self.vLitersHeight.active = YES;
        self.vPriceHeight.active = YES;
        self.vStartHeight.active = NO;
        self.vEndHeight.active = NO;
        self.vWithORHeight.active = YES;
        self.lStart.text = @"Start Odometer";
        self.tfAmount.userInteractionEnabled = YES;
        self.tfAmount.enabled = NO;
        ExpenseFuelConsumption *expenseFuelConsumption = [Get expenseFuelConsumption:self.app.db expenseID:self.expense.expenseID];
        self.tfRate.text = expenseFuelConsumption.rate > 0 ? [NSString stringWithFormat:@"%.2f", expenseFuelConsumption.rate] : nil;
        self.swIsKilometer.on = expenseFuelConsumption.isKilometer;
        self.tfStart.text = expenseFuelConsumption.start > 0 ? [NSString stringWithFormat:@"%lld", expenseFuelConsumption.start] : nil;
        if(expenseFuelConsumption.startPhoto != nil) {
            [self.btnStartPhoto setTitle:nil forState:UIControlStateNormal];
            [self.btnStartPhoto setImage:[[File imageFromDocument:expenseFuelConsumption.startPhoto] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        }
        else {
            [self.btnStartPhoto setTitle:@"" forState:UIControlStateNormal];
            [self.btnStartPhoto setImage:nil forState:UIControlStateNormal];
        }
        self.tfEnd.text = expenseFuelConsumption.end > 0 ?[NSString stringWithFormat:@"%lld", expenseFuelConsumption.end] : nil;
        if(expenseFuelConsumption.endPhoto != nil) {
            [self.btnEndPhoto setTitle:nil forState:UIControlStateNormal];
            [self.btnEndPhoto setImage:[[File imageFromDocument:expenseFuelConsumption.endPhoto] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        }
        else {
            [self.btnEndPhoto setTitle:@"" forState:UIControlStateNormal];
            [self.btnEndPhoto setImage:nil forState:UIControlStateNormal];
        }
        if(self.tfRate.text.length != 0 && self.tfStart.text.length != 0 && self.tfEnd.text.length != 0 && self.tfEnd.text.longLongValue >= self.tfStart.text.longLongValue) {
                self.tfAmount.text = [NSString stringWithFormat:@"%.2f", (self.tfEnd.text.longLongValue - self.tfStart.text.longLongValue) * [NSString stringWithFormat:@"%.2f", self.tfRate.text.doubleValue].doubleValue];
        }
    }
    else if(self.expenseType.expenseTypeID == 2) {
        self.btnPhotoLeading.constant = self.photoLeading;
        self.btnPhotoHeight.constant = self.photoHeight;
        self.vRateHeight.active = YES;
        self.vIsKilometerHeight.active = YES;
        self.vLitersHeight.active = NO;
        self.vPriceHeight.active = NO;
        self.vStartHeight.active = NO;
        self.vEndHeight.active = YES;
        self.vWithORHeight.active = NO;
        self.lStart.text = @"Odometer";
        self.tfAmount.userInteractionEnabled = NO;
        self.tfAmount.enabled = NO;
        ExpenseFuelPurchase *expenseFuelPurchase = [Get expenseFuelPurchase:self.app.db expenseID:self.expense.expenseID];
        if(expenseFuelPurchase.photo != nil) {
            [self.btnPhoto setTitle:nil forState:UIControlStateNormal];
            [self.btnPhoto setImage:[[File imageFromDocument:expenseFuelPurchase.photo] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        }
        else {
            [self.btnPhoto setTitle:@"" forState:UIControlStateNormal];
            [self.btnPhoto setImage:nil forState:UIControlStateNormal];
        }
        self.tfLiters.text = expenseFuelPurchase.liters > 0 ? [NSString stringWithFormat:@"%.2f", expenseFuelPurchase.liters] : nil;
        self.tfPrice.text = expenseFuelPurchase.price > 0 ? [NSString stringWithFormat:@"%.2f", expenseFuelPurchase.price] : nil;
        self.tfStart.text = expenseFuelPurchase.start > 0 ? [NSString stringWithFormat:@"%lld", expenseFuelPurchase.start] : nil;
        if(expenseFuelPurchase.startPhoto != nil) {
            [self.btnStartPhoto setTitle:nil forState:UIControlStateNormal];
            [self.btnStartPhoto setImage:[[File imageFromDocument:expenseFuelPurchase.startPhoto] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        }
        else {
            [self.btnStartPhoto setTitle:@"" forState:UIControlStateNormal];
            [self.btnStartPhoto setImage:nil forState:UIControlStateNormal];
        }
        self.swWithOR.on = expenseFuelPurchase.withOR;
        self.tfAmount.text = nil;
        if(self.tfLiters.text.length != 0 && self.tfPrice.text.length != 0) {
            self.tfAmount.text = [NSString stringWithFormat:@"%.2f", [NSString stringWithFormat:@"%.2f", self.tfLiters.text.doubleValue].doubleValue * [NSString stringWithFormat:@"%.2f", self.tfPrice.text.doubleValue].doubleValue];
        }
    }
    else {
        self.btnPhotoLeading.constant = self.photoLeading;
        self.btnPhotoHeight.constant = self.photoHeight;
        self.vRateHeight.active = YES;
        self.vIsKilometerHeight.active = YES;
        self.vLitersHeight.active = YES;
        self.vPriceHeight.active = YES;
        self.vStartHeight.active = YES;
        self.vEndHeight.active = YES;
        self.vWithORHeight.active = NO;
        self.tfAmount.userInteractionEnabled = YES;
        self.tfAmount.enabled = YES;
        ExpenseDefault *expenseDefault = [Get expenseDefault:self.app.db expenseID:self.expense.expenseID];
        if(expenseDefault.photo != nil) {
            [self.btnPhoto setTitle:nil forState:UIControlStateNormal];
            [self.btnPhoto setImage:[[File imageFromDocument:expenseDefault.photo] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        }
        else {
            [self.btnPhoto setTitle:@"" forState:UIControlStateNormal];
            [self.btnPhoto setImage:nil forState:UIControlStateNormal];
        }
        self.swWithOR.on = expenseDefault.withOR;
    }
}

- (IBAction)back:(id)sender {
    BOOL isChanged = NO;
    if(!isChanged && self.expense.storeID != 0) {
        isChanged = self.expense.storeID != self.store.storeID;
    }
    if(!isChanged && self.expense.expenseTypeID != 0) {
        isChanged = self.expense.expenseTypeID != self.expenseType.expenseTypeID;
        if(!isChanged) {
            if(self.expense.expenseTypeID == 1) {
                ExpenseFuelConsumption *expenseFuelConsumption = [Get expenseFuelConsumption:self.app.db expenseID:self.expense.expenseID];
                if(!isChanged) {
                    isChanged = expenseFuelConsumption.rate != [NSString stringWithFormat:@"%.2f", self.tfRate.text.doubleValue].doubleValue;
                }
                if(!isChanged) {
                    isChanged = expenseFuelConsumption.isKilometer != self.swIsKilometer.on;
                }
                if(!isChanged) {
                    isChanged = expenseFuelConsumption.start != self.tfStart.text.longLongValue;
                }
                if(!isChanged) {
                    isChanged = self.startPhotoFilename != nil;
                }
                if(!isChanged) {
                    isChanged = expenseFuelConsumption.end != self.tfEnd.text.longLongValue;
                }
                if(!isChanged) {
                    isChanged = self.endPhotoFilename != nil;
                }
            }
            else if(self.expenseType.expenseTypeID == 2) {
                ExpenseFuelPurchase *expenseFuelPurchase = [Get expenseFuelPurchase:self.app.db expenseID:self.expense.expenseID];
                if(!isChanged) {
                    isChanged = self.photoFilename != nil;
                }
                if(!isChanged) {
                    isChanged = expenseFuelPurchase.liters != [NSString stringWithFormat:@"%.2f", self.tfLiters.text.doubleValue].doubleValue;
                }
                if(!isChanged) {
                    isChanged = expenseFuelPurchase.price != [NSString stringWithFormat:@"%.2f", self.tfPrice.text.doubleValue].doubleValue;
                }
                if(!isChanged) {
                    isChanged = expenseFuelPurchase.start != self.tfStart.text.longLongValue;
                }
                if(!isChanged) {
                    isChanged = self.startPhotoFilename != nil;
                }
                if(!isChanged) {
                    isChanged = expenseFuelPurchase.withOR != self.swWithOR.on;
                }
            }
            else {
                ExpenseDefault *expenseDefault = [Get expenseDefault:self.app.db expenseID:self.expense.expenseID];
                if(!isChanged) {
                    isChanged = self.photoFilename != nil;
                }
                if(!isChanged) {
                    isChanged = expenseDefault.withOR != self.swWithOR.on;
                }
            }
        }
    }
    if(!isChanged) {
        isChanged = self.expense.amount != [NSString stringWithFormat:@"%.2f", self.tfAmount.text.doubleValue].doubleValue;
    }
    if(!isChanged) {
        isChanged = self.expense.isReimbursable != self.swIsReimbursable.on;
    }
    if(!isChanged && self.tfOrigin.text.length > 0) {
        isChanged = [self.expense.origin isEqualToString:self.tfOrigin.text];
    }
    if(!isChanged && self.tfDestination.text.length > 0) {
        isChanged = ![self.expense.destination isEqualToString:self.tfDestination.text];
    }
    if(!isChanged && self.tfNotes.text.length > 0) {
        isChanged = ![self.expense.notes isEqualToString:self.tfNotes.text];
    }
    if(isChanged) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"Save Changes?";
        vcMessage.message = @"Do you want to save changes?";
        vcMessage.negativeTitle = @"Discard";
        vcMessage.negativeTarget = ^{
            [View removeChildViewController:vcMessage animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        };
        vcMessage.positiveTitle = @"Save";
        vcMessage.positiveTarget = ^{
            [View removeChildViewController:vcMessage animated:YES];
            [self save:nil];
        };
        [View addChildViewController:self childViewController:vcMessage animated:YES];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    self.expense.storeID = self.store.storeID;
    self.expense.expenseTypeID = self.expenseType.expenseTypeID;
    if(self.expenseType.expenseTypeID != 0) {
        self.expense.name = self.expenseType.name;
    }
    self.expense.amount = [NSString stringWithFormat:@"%.2f", self.tfAmount.text.doubleValue].doubleValue;
    self.expense.isReimbursable = self.swIsReimbursable.on;
    self.expense.origin = self.tfOrigin.text;
    self.expense.destination = self.tfDestination.text;
    self.expense.notes = self.tfNotes.text;
    if(self.expenseType.expenseTypeID == 1) {
        ExpenseFuelConsumption *expenseFuelConsumption = [Get expenseFuelConsumption:self.app.db expenseID:self.expense.expenseID];
        if(expenseFuelConsumption == nil) {
            expenseFuelConsumption = [NSEntityDescription insertNewObjectForEntityForName:@"ExpenseFuelConsumption" inManagedObjectContext:self.app.db];
            expenseFuelConsumption.expenseID = self.expense.expenseID;
        }
        expenseFuelConsumption.rate = [NSString stringWithFormat:@"%.2f", self.tfRate.text.doubleValue].doubleValue;
        expenseFuelConsumption.isKilometer = self.swIsKilometer.on;
        expenseFuelConsumption.start = self.tfStart.text.longLongValue;
        if(self.startPhotoFilename != nil && [File saveImageFromImage:[File documentPath:self.startPhotoFilename] image:self.btnStartPhoto.currentImage] != nil) {
            expenseFuelConsumption.startPhoto = self.startPhotoFilename;
        }
        expenseFuelConsumption.end = self.tfEnd.text.longLongValue;
        if(self.endPhotoFilename != nil && [File saveImageFromImage:[File documentPath:self.endPhotoFilename] image:self.btnEndPhoto.currentImage] != nil) {
            expenseFuelConsumption.endPhoto = self.endPhotoFilename;
        }
        ExpenseFuelPurchase *expenseFuelPurchase = [Get expenseFuelPurchase:self.app.db expenseID:self.expense.expenseID];
        if(expenseFuelPurchase.expenseID != 0) {
            if([File deleteFromDocument:expenseFuelPurchase.photo]) {
                expenseFuelPurchase.photo = nil;
            }
            expenseFuelPurchase.liters = 0;
            expenseFuelPurchase.price = 0;
            expenseFuelPurchase.start = 0;
            if([File deleteFromDocument:expenseFuelPurchase.startPhoto]) {
                expenseFuelPurchase.startPhoto = nil;
            }
            expenseFuelPurchase.withOR = NO;
        }
        ExpenseDefault *expenseDefault = [Get expenseDefault:self.app.db expenseID:self.expense.expenseID];
        if(expenseDefault.expenseID != 0) {
            if([File deleteFromDocument:expenseDefault.photo]) {
                expenseDefault.photo = nil;
            }
            expenseDefault.withOR = NO;
        }
    }
    else if(self.expenseType.expenseTypeID == 2) {
        ExpenseFuelPurchase *expenseFuelPurchase = [Get expenseFuelPurchase:self.app.db expenseID:self.expense.expenseID];
        if(expenseFuelPurchase == nil) {
            expenseFuelPurchase = [NSEntityDescription insertNewObjectForEntityForName:@"ExpenseFuelPurchase" inManagedObjectContext:self.app.db];
            expenseFuelPurchase.expenseID = self.expense.expenseID;
        }
        if(self.photoFilename != nil && [File saveImageFromImage:[File documentPath:self.photoFilename] image:self.btnPhoto.currentImage] != nil) {
            expenseFuelPurchase.photo = self.photoFilename;
        }
        expenseFuelPurchase.liters = [NSString stringWithFormat:@"%.2f", self.tfLiters.text.doubleValue].doubleValue;
        expenseFuelPurchase.price = [NSString stringWithFormat:@"%.2f", self.tfPrice.text.doubleValue].doubleValue;
        expenseFuelPurchase.start = self.tfStart.text.longLongValue;
        if(self.startPhotoFilename != nil && [File saveImageFromImage:[File documentPath:self.startPhotoFilename] image:self.btnStartPhoto.currentImage] != nil) {
            expenseFuelPurchase.startPhoto = self.startPhotoFilename;
        }
        expenseFuelPurchase.withOR = self.swWithOR.on;
        ExpenseFuelConsumption *expenseFuelConsumption = [Get expenseFuelConsumption:self.app.db expenseID:self.expense.expenseID];
        if(expenseFuelConsumption.expenseID != 0) {
            expenseFuelConsumption.rate = 0;
            expenseFuelConsumption.isKilometer = YES;
            expenseFuelConsumption.start = 0;
            if([File deleteFromDocument:expenseFuelConsumption.startPhoto]) {
                expenseFuelConsumption.startPhoto = nil;
            }
            expenseFuelConsumption.end = 0;
            if([File deleteFromDocument:expenseFuelConsumption.endPhoto]) {
                expenseFuelConsumption.endPhoto = nil;
            }
        }
        ExpenseDefault *expenseDefault = [Get expenseDefault:self.app.db expenseID:self.expense.expenseID];
        if(expenseDefault.expenseID != 0) {
            if([File deleteFromDocument:expenseDefault.photo]) {
                expenseDefault.photo = nil;
            }
            expenseDefault.withOR = NO;
        }
    }
    else {
        ExpenseDefault *expenseDefault = [Get expenseDefault:self.app.db expenseID:self.expense.expenseID];
        if(expenseDefault == nil) {
            expenseDefault = [NSEntityDescription insertNewObjectForEntityForName:@"ExpenseDefault" inManagedObjectContext:self.app.db];
            expenseDefault.expenseID = self.expense.expenseID;
        }
        if(self.photoFilename != nil && [File saveImageFromImage:[File documentPath:self.photoFilename] image:self.btnPhoto.currentImage] != nil) {
            expenseDefault.photo = self.photoFilename;
        }
        expenseDefault.withOR = self.swWithOR.on;
        ExpenseFuelConsumption *expenseFuelConsumption = [Get expenseFuelConsumption:self.app.db expenseID:self.expense.expenseID];
        if(expenseFuelConsumption.expenseID != 0) {
            expenseFuelConsumption.rate = 0;
            expenseFuelConsumption.isKilometer = YES;
            expenseFuelConsumption.start = 0;
            if([File deleteFromDocument:expenseFuelConsumption.startPhoto]) {
                expenseFuelConsumption.startPhoto = nil;
            }
            expenseFuelConsumption.end = 0;
            if([File deleteFromDocument:expenseFuelConsumption.endPhoto]) {
                expenseFuelConsumption.endPhoto = nil;
            }
        }
        ExpenseFuelPurchase *expenseFuelPurchase = [Get expenseFuelPurchase:self.app.db expenseID:self.expense.expenseID];
        if(expenseFuelPurchase.expenseID != 0) {
            if([File deleteFromDocument:expenseFuelPurchase.photo]) {
                expenseFuelPurchase.photo = nil;
            }
            expenseFuelPurchase.liters = 0;
            expenseFuelPurchase.price = 0;
            expenseFuelPurchase.start = 0;
            if([File deleteFromDocument:expenseFuelPurchase.startPhoto]) {
                expenseFuelPurchase.startPhoto = nil;
            }
            expenseFuelPurchase.withOR = NO;
        }
    }
    if(self.expense.storeID != 0 && self.expense.expenseTypeID != 0 && self.expense.amount != 0 && self.expense.isSync) {
        self.expense.isUpdate = YES;
        self.expense.isWebUpdate = NO;
    }
    if([Update save:self.app.db]) {
        [self.navigationController popViewControllerAnimated:YES];
        [View showAlert:self.main.navigationController.view message:@"Expense has been successfully saved." duration:2];
        [self.delegate onExpenseItemDetailsSave:self.section expense:self.expense];
    }
}

- (IBAction)store:(id)sender {
    StoresViewController *vcStores = [self.storyboard instantiateViewControllerWithIdentifier:@"vcStores"];
    vcStores.delegate = self;
    vcStores.action = STORE_ACTION_SELECT;
    [self.navigationController pushViewController:vcStores animated:YES];
}

- (IBAction)expenseType:(id)sender {
    ListDialogViewController *vcList = [self.storyboard instantiateViewControllerWithIdentifier:@"vcList"];
    vcList.delegate = self;
    vcList.type = LIST_TYPE_EXPENSE_TYPE;
    vcList.items = [Load expenseTypes:self.app.db];
    [View addChildViewController:self childViewController:vcList animated:YES];
}

- (IBAction)photo:(id)sender {
    if(((UIButton *)sender).currentImage != nil) {
//        return;
    }
    CameraViewController *vcCamera = [self.storyboard instantiateViewControllerWithIdentifier:@"vcCamera"];
    vcCamera.cameraDelegate = self;
    vcCamera.action = CAMERA_ACTION_EXPENSE;
    vcCamera.isRearCamera = YES;
    [self.navigationController pushViewController:vcCamera animated:NO];
}

- (IBAction)startPhoto:(id)sender {
    if(((UIButton *)sender).currentImage != nil) {
//        return;
    }
    CameraViewController *vcCamera = [self.storyboard instantiateViewControllerWithIdentifier:@"vcCamera"];
    vcCamera.cameraDelegate = self;
    vcCamera.action = CAMERA_ACTION_EXPENSE_START;
    vcCamera.isRearCamera = YES;
    [self.navigationController pushViewController:vcCamera animated:NO];
}

- (IBAction)endPhoto:(id)sender {
    if(((UIButton *)sender).currentImage != nil) {
//        return;
    }
    CameraViewController *vcCamera = [self.storyboard instantiateViewControllerWithIdentifier:@"vcCamera"];
    vcCamera.cameraDelegate = self;
    vcCamera.action = CAMERA_ACTION_EXPENSE_END;
    vcCamera.isRearCamera = YES;
    [self.navigationController pushViewController:vcCamera animated:NO];
}

- (void)onTextFieldTextChanged:(UITextField *)textfield text:(NSString *)text {
    if(self.expenseType.expenseTypeID == 1) {
        self.tfAmount.text = nil;
        if(textfield == self.tfRate) {
            if(text.length != 0 && self.tfStart.text.length != 0 && self.tfEnd.text.length != 0 && self.tfStart.text.longLongValue <= self.tfEnd.text.longLongValue) {
                self.tfAmount.text = [NSString stringWithFormat:@"%.2f", (self.tfEnd.text.longLongValue - self.tfStart.text.longLongValue) * [NSString stringWithFormat:@"%.2f", text.doubleValue].doubleValue];
            }
        }
        if(textfield == self.tfStart) {
            if(self.tfRate.text.length != 0 && text.length != 0 && self.tfEnd.text.length != 0 && text.longLongValue <= self.tfEnd.text.longLongValue) {
                self.tfAmount.text = [NSString stringWithFormat:@"%.2f", (self.tfEnd.text.longLongValue - text.longLongValue) * [NSString stringWithFormat:@"%.2f", self.tfRate.text.doubleValue].doubleValue];
            }
        }
        if(textfield == self.tfEnd) {
            if(self.tfRate.text.length != 0 && self.tfStart.text.length != 0 && text.length != 0 && text.longLongValue >= self.tfStart.text.longLongValue) {
                self.tfAmount.text = [NSString stringWithFormat:@"%.2f", (text.longLongValue - self.tfStart.text.longLongValue) * [NSString stringWithFormat:@"%.2f", self.tfRate.text.doubleValue].doubleValue];
            }
        }
    }
    else if(self.expenseType.expenseTypeID == 2) {
        self.tfAmount.text = nil;
        if(textfield == self.tfLiters) {
            if(text.length != 0 && self.tfPrice.text.length != 0) {
                self.tfAmount.text = [NSString stringWithFormat:@"%.2f", [NSString stringWithFormat:@"%.2f", text.doubleValue].doubleValue * [NSString stringWithFormat:@"%.2f", self.tfPrice.text.doubleValue].doubleValue];
            }
        }
        if(textfield == self.tfPrice) {
            if(self.tfLiters.text.length != 0 && text.length != 0) {
                self.tfAmount.text = [NSString stringWithFormat:@"%.2f", [NSString stringWithFormat:@"%.2f", self.tfLiters.text.doubleValue].doubleValue * [NSString stringWithFormat:@"%.2f", text.doubleValue].doubleValue];
            }
        }
    }
}

- (void)onStoresSelect:(Stores *)store {
    self.store = store;
    self.tfStore.text = self.app.settingStoreDisplayLongName ? self.store.name : self.store.shortName;
}

- (void)onListSelect:(int)type item:(id)item {
    switch(type) {
        case LIST_TYPE_EXPENSE_TYPE: {
            self.expenseType = (ExpenseTypes *)item;
            self.tfExpenseType.text = self.expenseType.expenseTypeID != 0 ? self.expenseType.name : self.expense.name;
            [self onRefresh];
            break;
        }
    }
}

- (void)onCameraCancel:(int)action {
    switch(action) {
        case CAMERA_ACTION_EXPENSE: {
            break;
        }
        case CAMERA_ACTION_EXPENSE_START: {
            break;
        }
        case CAMERA_ACTION_EXPENSE_END: {
            break;
        }
    }
}

- (void)onCameraCapture:(int)action image:(UIImage *)image {
    switch(action) {
        case CAMERA_ACTION_EXPENSE: {
            self.photoFilename = [NSString stringWithFormat:@"%lld-%.0f%@", self.app.employee.employeeID, [NSDate.date timeIntervalSince1970], @".png"];
            [self.btnPhoto setTitle:nil forState:UIControlStateNormal];
            [self.btnPhoto setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            break;
        }
        case CAMERA_ACTION_EXPENSE_START: {
            self.startPhotoFilename = [NSString stringWithFormat:@"%lld-%.0f%@", self.app.employee.employeeID, [NSDate.date timeIntervalSince1970], @".png"];
            [self.btnStartPhoto setTitle:nil forState:UIControlStateNormal];
            [self.btnStartPhoto setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            break;
        }
        case CAMERA_ACTION_EXPENSE_END: {
            self.endPhotoFilename = [NSString stringWithFormat:@"%lld-%.0f%@", self.app.employee.employeeID, [NSDate.date timeIntervalSince1970], @".png"];
            [self.btnEndPhoto setTitle:nil forState:UIControlStateNormal];
            [self.btnEndPhoto setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            break;
        }
    }
}

@end
