#import "EditStoreViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Update.h"
#import "View.h"

@interface EditStoreViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation EditStoreViewController

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
        self.tfStoreName.highlightedBorderColor = THEME_SEC;
        self.tfContactNumber.highlightedBorderColor = THEME_SEC;
        self.tfEmail.highlightedBorderColor = THEME_SEC;
        self.tfAddress.highlightedBorderColor = THEME_SEC;
        [View setCornerRadiusByHeight:self.btnSave cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfStoreName cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfContactNumber cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfEmail cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfAddress cornerRadius:0.125];
        [View setCornerRadiusByHeight:self.lShareWithMeIcon cornerRadius:0.4];
        [View setCornerRadiusByHeight:self.lShareWithMyTeamIcon cornerRadius:0.4];
        CALayer *layer = self.lShareWithMeIcon.layer;
        layer.borderColor = [Color colorNamed:@"Grey500"].CGColor;
        layer.borderWidth = (1.0f / 568) * UIScreen.mainScreen.bounds.size.height;
        layer = self.lShareWithMyTeamIcon.layer;
        layer.borderColor = [Color colorNamed:@"Grey500"].CGColor;
        layer.borderWidth = (1.0f / 568) * UIScreen.mainScreen.bounds.size.height;
        [self onRefresh];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)onRefresh {
    [super onRefresh];
    self.lName.text = [NSString stringWithFormat:@"%@ %@", self.store.storeID != 0 ? @"Edit" : @"Add", self.app.conventionStores];
    self.lStoreName.text = [NSString stringWithFormat:@"%@ %@", self.app.conventionStores, @" Name"];
    if(self.store != nil) {
        self.tfStoreName.text = self.app.settingStoreDisplayLongName ? self.store.name : self.store.shortName;
        self.tfContactNumber.text = self.store.contactNumber;
        self.tfEmail.text = self.store.email;
        self.tfAddress.value = self.store.address;
        self.lShareWithMeIcon.text = [self.store.shareWith isEqualToString:@"me"] ? @"" : nil;
        self.lShareWithMyTeamIcon.text = [self.store.shareWith isEqualToString:@"my-team"] ? @"" : nil;
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    if(self.store == nil) {
        Sequences *sequence = [Get sequence:self.app.db];
        self.store = [NSEntityDescription insertNewObjectForEntityForName:@"Stores" inManagedObjectContext:self.app.db];
        sequence.stores += 1;
        self.store.storeID = sequence.stores;
        self.store.syncBatchID = self.app.syncBatchID;
        self.store.isFromWeb = NO;
        self.store.isSync = NO;
        self.store.isUpdate = NO;
    }
    else {
        self.store.isUpdate = YES;
    }
    self.store.employeeID = self.app.employee.employeeID;
    self.store.name = self.tfStoreName.text;
    self.store.shortName = self.tfStoreName.text;
    self.store.contactNumber = self.tfContactNumber.text;
    self.store.email = self.tfEmail.text;
    self.store.address = self.tfAddress.text;
    self.store.shareWith = [self.lShareWithMeIcon.text isEqualToString:@""] ? @"me" : @"my-team";
    self.store.isTag = YES;
    self.store.isActive = YES;
    self.store.isWebUpdate = NO;
    if([Update save:self.app.db]) {
        [self.navigationController popViewControllerAnimated:NO];
        [self.delegate onEditStoreSave:self.store];
    }
}

- (IBAction)shareWithMe:(id)sender {
    self.lShareWithMeIcon.text = @"";
    self.lShareWithMyTeamIcon.text = nil;
}

- (IBAction)shareWithMyTeam:(id)sender {
    self.lShareWithMeIcon.text = nil;
    self.lShareWithMyTeamIcon.text = @"";
}

@end
