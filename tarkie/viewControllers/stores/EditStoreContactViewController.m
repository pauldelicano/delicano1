#import "EditStoreContactViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Update.h"
#import "View.h"
#import "Time.h"

@interface EditStoreContactViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation EditStoreContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.vStatusBar.backgroundColor = THEME_PRI_DARK;
        self.vNavBar.backgroundColor = THEME_PRI;
        [self.btnSave setTitleColor:THEME_PRI forState:UIControlStateNormal];
        self.tfStoreContactName.highlightedBorderColor = THEME_SEC;
        self.tfDesignation.highlightedBorderColor = THEME_SEC;
        self.tfEmail.highlightedBorderColor = THEME_SEC;
        self.tfMobileNumber.highlightedBorderColor = THEME_SEC;
        self.tfLandlineNumber.highlightedBorderColor = THEME_SEC;
        self.tfBirthdate.highlightedBorderColor = THEME_SEC;
        self.tfRemarks.highlightedBorderColor = THEME_SEC;
        [View setCornerRadiusByHeight:self.btnSave cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfStoreContactName cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfDesignation cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfEmail cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfMobileNumber cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfLandlineNumber cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfBirthdate cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfRemarks cornerRadius:0.125];
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    self.lName.text = [NSString stringWithFormat:@"%@ Contact", self.storeContact.storeContactID != 0 ? @"Edit" : @"Add"];
    self.tfStoreContactName.text = self.storeContact.name;
    self.tfDesignation.text = self.storeContact.designation;
    self.tfEmail.text = self.storeContact.email;
    self.tfMobileNumber.text = self.storeContact.mobileNumber;
    self.tfLandlineNumber.text = self.storeContact.landlineNumber;
    self.tfBirthdate.text = [Time formatDate:self.app.settingDisplayDateFormat date:self.storeContact.birthdate];
    self.tfRemarks.text = self.storeContact.remarks;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    if(self.storeContact == nil) {
        self.storeContact = [NSEntityDescription insertNewObjectForEntityForName:@"StoreContacts" inManagedObjectContext:self.app.db];
        self.storeContact.storeContactID = [Get sequenceID:self.app.db entity:@"StoreContacts" attribute:@"storeContactID"] + 1;
        self.storeContact.isFromWeb = NO;
        self.storeContact.isSync = NO;
        self.storeContact.isUpdate = NO;
    }
    else {
        self.storeContact.isUpdate = YES;
    }
    self.storeContact.storeID = self.store.storeID;
    self.storeContact.employeeID = self.store.employeeID;
    self.storeContact.name = self.tfStoreContactName.text;
    self.storeContact.designation = self.tfDesignation.text;
    self.storeContact.email = self.tfEmail.text;
    self.storeContact.mobileNumber = self.tfMobileNumber.text;
    self.storeContact.landlineNumber = self.tfLandlineNumber.text;
    self.storeContact.birthdate = self.tfBirthdate.text;
    self.storeContact.remarks = self.tfRemarks.text;
    self.storeContact.isActive = YES;
    self.storeContact.isWebUpdate = NO;
    if([Update save:self.app.db]) {
        [self.navigationController popViewControllerAnimated:NO];
        [self.delegate onEditStoreContactSave:self.storeContact];
    }
}

@end
