#import "VisitDetailsViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Load.h"
#import "Update.h"
#import "File.h"
#import "View.h"
#import "Time.h"
#import "HomeTableViewCell.h"
#import "MessageDialogViewController.h"

@interface VisitDetailsViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) CheckIn *visitCheckIn;
@property (strong, nonatomic) CheckOut *visitCheckOut;
@property (strong, nonatomic) NSMutableArray<VisitInventories *> *inventories;
@property (strong, nonatomic) NSMutableArray<VisitForms *> *forms;
@property (strong, nonatomic) NSMutableArray<Photos *> *photos;
@property (strong, nonatomic) NSMutableArray<UIImage *> *images;
@property (strong, nonatomic) Stores *store;
@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) NSString *photoFilename, *visitStatus, *visitNotes;
@property (strong, nonatomic) NSDate *currentDate;
@property (nonatomic) BOOL viewWillAppear, inventoryLoaded, formsLoaded, isCheckingIn, isCheckingOut;

@end

@implementation VisitDetailsViewController

static MessageDialogViewController *vcMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    UIView *vFooter = UIView.alloc.init;
    self.tvInventory.tableFooterView = vFooter;
    self.tvForms.tableFooterView = vFooter;
    self.cvPhotos.photoBarDelegate = self;
    self.tfNotes.placeholder = @"Tap to add notes...";
    self.inventories = NSMutableArray.alloc.init;
    self.forms = NSMutableArray.alloc.init;
    self.photos = NSMutableArray.alloc.init;
    self.images = NSMutableArray.alloc.init;
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.vStatusBar.backgroundColor = THEME_PRI_DARK;
        self.vNavBar.backgroundColor = THEME_PRI;
        [self.btnSave setTitleColor:THEME_PRI forState:UIControlStateNormal];
        self.btnCheckIn.backgroundColor = THEME_SEC;
        self.btnInventory.backgroundColor = THEME_SEC;
        self.btnForms.backgroundColor = THEME_SEC;
        self.lDeliveriesValue.textColor = THEME_PRI;
        self.tfNotes.highlightedBorderColor = THEME_SEC;
        self.lInventoryBorder.backgroundColor = THEME_SEC;
        self.lFormsBorder.backgroundColor = THEME_SEC;
        self.lPhotosBorder.backgroundColor = THEME_SEC;
        self.lNotesBorder.backgroundColor = THEME_SEC;
        [View setCornerRadiusByHeight:self.btnSave cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.btnInventory cornerRadius:0.2];
        [View setCornerRadiusByHeight:self.btnForms cornerRadius:0.2];
        [View setCornerRadiusByHeight:self.tfNotes cornerRadius:0.125];
        [self onRefresh];
        [self applicationDidBecomeActive];
    }
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)onRefresh {
    [super onRefresh];
    [self.inventories removeAllObjects];
    [self.forms removeAllObjects];
    [self.photos removeAllObjects];
    [self.images removeAllObjects];
    self.store = [Get store:self.app.db storeID:self.visit.storeID];
    self.visitCheckIn = [Get checkIn:self.app.db visitID:self.visit.visitID];
    self.visitCheckOut = [Get checkOut:self.app.db checkInID:self.visitCheckIn.checkInID];
    if(self.app.moduleInventory) {
        [self.inventories addObjectsFromArray:[Load visitInventories:self.app.db visitID:self.visit.visitID]];
    }
    if(self.app.moduleForms) {
        [self.forms addObjectsFromArray:[Load visitForms:self.app.db visitID:self.visit.visitID]];
    }
    [self.photos addObjectsFromArray:[Load visitPhotos:self.app.db visitID:self.visit.visitID]];
    for(int x = 0; x < self.photos.count; x++) {
        [self.images addObject:[File imageFromDocument:self.photos[x].filename]];
    }
    self.cvPhotos.photos = self.images;
    [self.tvInventory reloadData];
    [self.tvForms reloadData];
    [self.cvPhotos reloadData];
    [self updateVisitDetails];
    [self updateCheckIn];
    [self updateCheckOut];
}

- (void)updateVisitDetails {
    if(self.store.storeID != 0) {
        self.lName.text = self.app.conventionVisits;
        self.lStoreName.text = self.app.settingStoreDisplayLongName ? self.store.name : self.store.shortName;
        self.lStoreAddress.text = self.store.address.length > 0 ? self.store.address : @"No address";
    }
    else {
        self.lName.text = self.visit.name;
        self.lStoreName.text = [NSString stringWithFormat:@"%@ Name", self.app.conventionStores];
        self.lStoreAddress.text = @"Address";
    }
    if(self.app.moduleInventory) {
        self.vInventory.hidden = NO;
        self.vInventoryHeight.active = NO;
        self.tvInventoryHeight.constant = self.tvInventory.contentSize.height;
    }
    else {
        self.vInventory.hidden = YES;
        self.vInventoryHeight.active = YES;
        self.tvInventoryHeight.constant = 0;
    }
    if(self.app.moduleForms) {
        self.vForms.hidden = NO;
        self.vFormsHeight.active = NO;
        self.tvFormsHeight.constant = self.tvForms.contentSize.height;
    }
    else {
        self.vForms.hidden = YES;
        self.vFormsHeight.active = YES;
        self.tvFormsHeight.constant = 0;
    }
    if(self.app.settingVisitsInvoice) {
        self.lInvoice.text = self.app.conventionInvoice;
        self.lInvoiceValue.text = self.visit.invoice.length > 0 ? self.visit.invoice : @"N/A";
    }
    else {
        self.lInvoice.text = nil;
        self.lInvoiceValue.text = nil;
    }
    if(self.app.settingVisitsDeliveries) {
        self.lDeliveries.text = self.app.conventionDeliveries;
        self.lDeliveriesValue.text = [NSString stringWithFormat:@"%@%.02f", self.app.settingDisplayCurrencySymbol, [self.visit.deliveries floatValue]];
    }
    else {
        self.lDeliveries.text = nil;
        self.lDeliveriesValue.text = nil;
    }
    self.tfNotes.value = self.visit.notes;
    if(!self.visit.isCheckOut || (self.visit.isCheckOut && self.app.settingVisitsEditAfterCheckOut)) {
        self.btnSave.hidden = NO;
        self.tfNotes.editable = YES;
    }
    else {
        self.btnSave.hidden = YES;
        if([self.tfNotes.text isEqualToString:self.tfNotes.placeholder]) {
            self.tfNotes.text  = nil;
        }
        self.tfNotes.editable = NO;
    }
    [self.vContent layoutIfNeeded];
}

- (void)applicationDidBecomeActive {
    if(![self.main applicationDidBecomeActive]) {
        return;
    }
    if(self.isCheckingIn) {
        self.isCheckingIn = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.125 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self checkIn];
        });
    }
    if(self.isCheckingOut) {
        self.isCheckingOut = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.125 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self checkOut];
        });
    }
}

- (IBAction)back:(id)sender {
    NSString *notes = self.tfNotes.text;
    if([notes isEqualToString:self.tfNotes.placeholder]) {
        notes = @"";
    }
    if(self.visit.storeID != self.store.storeID || ![self.visit.notes isEqualToString:notes]) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"Save Changes?";
        vcMessage.message = @"Do you want to save changes?";
        vcMessage.negativeTitle = @"Discard";
        vcMessage.negativeTarget = ^{
            [View removeView:vcMessage.view animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        };
        vcMessage.positiveTitle = @"Save";
        vcMessage.positiveTarget = ^{
            [View removeView:vcMessage.view animated:YES];
            [self.btnSave sendActionsForControlEvents:UIControlEventTouchUpInside];
        };
        [View addSubview:self.view subview:vcMessage.view animated:YES];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    if(self.store.storeID == 0) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = [NSString stringWithFormat:@"%@ is Required", self.app.conventionStores];
        vcMessage.message = [NSString stringWithFormat:@"Please select %@ first to continue.", self.app.conventionStores.lowercaseString];
        vcMessage.positiveTitle = @"OK";
        vcMessage.positiveTarget = ^{
            [View removeView:vcMessage.view animated:YES];
        };
        [View addSubview:self.view subview:vcMessage.view animated:YES];
        return;
    }
    NSString *notes = self.tfNotes.text;
    if([notes isEqualToString:self.tfNotes.placeholder]) {
        notes = @"";
    }
    if(notes.length == 0 && self.app.settingVisitsNotes) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"Notes is Required";
        vcMessage.message = @"Please input notes.";
        vcMessage.positiveTitle = @"OK";
        vcMessage.positiveTarget = ^{
            [View removeView:vcMessage.view animated:YES];
        };
        [View addSubview:self.view subview:vcMessage.view animated:YES];
        return;
    }
    self.visit.name = self.app.settingStoreDisplayLongName ? self.store.name : self.store.shortName;
    self.visit.storeID = self.store.storeID;
    self.visit.notes = notes;
    if(self.visit.isSync) {
        self.visit.isUpdate = YES;
        self.visit.isWebUpdate = NO;
    }
    if([Update save:self.app.db]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)openMap:(id)sender {
    if(self.store.storeID == 0) {
        return;
    }
    if(self.store.latitude != 0 && self.store.longitude != 0) {
        [self openMapFromCoordinates:self.store.latitude longitude:self.store.longitude];
        return;
    }
    if(self.store.address.length > 0) {
        [self openMapFromAddress:self.store.address];
        return;
    }
}

- (IBAction)editStore:(id)sender {
    if(!self.visit.isCheckOut || (self.visit.isCheckOut && self.app.settingVisitsEditAfterCheckOut)) {
        StoresViewController *vcStores = [self.storyboard instantiateViewControllerWithIdentifier:@"vcStores"];
        vcStores.delegate = self;
        vcStores.action = STORE_ACTION_SELECT;
        [self.navigationController pushViewController:vcStores animated:YES];
        return;
    }
    vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
    vcMessage.subject = [NSString stringWithFormat:@"Cannot Edit %@", self.app.conventionStores];
    vcMessage.message = [NSString stringWithFormat:@"You have checked-out already. You cannot edit %@ anymore.", self.app.conventionStores.lowercaseString];
    vcMessage.positiveTitle = @"OK";
    vcMessage.positiveTarget = ^{
        [View removeView:vcMessage.view animated:YES];
    };
    [View addSubview:self.view subview:vcMessage.view animated:YES];
}

- (IBAction)checkIn:(id)sender {
    [self checkIn];
}

- (IBAction)checkOut:(id)sender {
    [self checkOut];
}

- (IBAction)addInventory:(id)sender {
    if(!self.visit.isCheckOut || (self.visit.isCheckOut && self.app.settingVisitsEditAfterCheckOut)) {
        NSLog(@"paul: addInventory");
        return;
    }
    vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
    vcMessage.subject = @"Cannot Add Inventory";
    vcMessage.message = @"You have checked-out already. You cannot add inventory anymore.";
    vcMessage.positiveTitle = @"OK";
    vcMessage.positiveTarget = ^{
        [View removeView:vcMessage.view animated:YES];
    };
    [View addSubview:self.view subview:vcMessage.view animated:YES];
}

- (IBAction)addForms:(id)sender {
    if(!self.visit.isCheckOut || (self.visit.isCheckOut && self.app.settingVisitsEditAfterCheckOut)) {
        NSLog(@"paul: addForms");
        return;
    }
    vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
    vcMessage.subject = @"Cannot Add Forms";
    vcMessage.message = @"You have checked-out already. You cannot add forms anymore.";
    vcMessage.positiveTitle = @"OK";
    vcMessage.positiveTarget = ^{
        [View removeView:vcMessage.view animated:YES];
    };
    [View addSubview:self.view subview:vcMessage.view animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tvInventory) {
        return self.inventories.count;
    }
    if(tableView == self.tvForms) {
        return self.forms.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    if(tableView == self.tvInventory) {
        VisitInventories *inventory = self.inventories[indexPath.row];
        item.lName.text = inventory.name;
        if(indexPath.row == self.inventories.count - 1) {
            self.inventoryLoaded = YES;
        }
    }
    if(tableView == self.tvForms) {
        VisitForms *form = self.forms[indexPath.row];
        item.lName.text = form.name;
        if(indexPath.row == self.forms.count - 1) {
            self.formsLoaded = YES;
        }
    }
    return item;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.inventoryLoaded && self.formsLoaded) {
        self.inventoryLoaded = NO;
        self.formsLoaded = NO;
        [self updateVisitDetails];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(tableView == self.tvInventory) {
        
    }
    if(tableView == self.tvForms) {
        
    }
}
- (void)onStoresSelect:(Stores *)stores {
    self.store = stores;
    self.lName.text = @"Visit";
    self.lStoreName.text = self.app.settingStoreDisplayLongName ? self.store.name : self.store.shortName;
    self.lStoreAddress.text = self.store.address.length > 0 ? self.store.address : @"No address";
}

- (void)onPhotoBarPreview:(long)selectedPhoto {
    CameraPreviewViewController *vcCameraPreview = [self.storyboard instantiateViewControllerWithIdentifier:@"vcCameraPreview"];
    vcCameraPreview.cameraPreviewDelegate = self;
    vcCameraPreview.photos = self.photos;
    vcCameraPreview.selectedPhoto = selectedPhoto;
    [self.navigationController pushViewController:vcCameraPreview animated:YES];
}

- (void)onPhotoBarAdd {
    if(!self.visit.isCheckOut || (self.visit.isCheckOut && self.app.settingVisitsEditAfterCheckOut)) {
        CameraViewController *vcCamera = [self.storyboard instantiateViewControllerWithIdentifier:@"vcCamera"];
        vcCamera.cameraDelegate = self;
        vcCamera.action = CAMERA_ACTION_VISIT_PHOTOS;
        vcCamera.isRearCamera = YES;
        [self.navigationController pushViewController:vcCamera animated:NO];
        return;
    }
    vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
    vcMessage.subject = @"Cannot Add Photos";
    vcMessage.message = @"You have checked-out already. You cannot add photos anymore.";
    vcMessage.positiveTitle = @"OK";
    vcMessage.positiveTarget = ^{
        [View removeView:vcMessage.view animated:YES];
    };
    [View addSubview:self.view subview:vcMessage.view animated:YES];
}

- (void)onCameraCapture:(int)type image:(UIImage *)image {
    switch(type) {
        case CAMERA_ACTION_CHECK_IN: {
            self.photo = image;
            [self checkIn];
            break;
        }
        case CAMERA_ACTION_CHECK_OUT: {
            self.photo = image;
            [self checkOut];
            break;
        }
        case CAMERA_ACTION_VISIT_PHOTOS: {
            NSDate *currentDate = NSDate.date;
            NSString *filename = [NSString stringWithFormat:@"%lld-%.0f%@", self.app.employee.employeeID, [currentDate timeIntervalSince1970], @".png"];
            if([File saveImageFromImage:[File documentPath:filename] image:image] != nil) {
                Sequences *sequence = [Get sequence:self.app.db];
                Photos *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:self.app.db];
                sequence.photos += 1;
                photo.photoID = sequence.photos;
                photo.syncBatchID = self.app.syncBatchID;
                photo.employeeID = self.app.employee.employeeID;
                photo.date = [Time getFormattedDate:DATE_FORMAT date:currentDate];
                photo.time = [Time getFormattedDate:TIME_FORMAT date:currentDate];
                photo.filename = filename;
                photo.isSignature = NO;
                photo.isUpload = NO;
                photo.isDelete = NO;
                VisitPhotos *visitPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"VisitPhotos" inManagedObjectContext:self.app.db];
                sequence.visitPhotos += 1;
                visitPhoto.visitPhotoID = sequence.visitPhotos;
                visitPhoto.visitID = self.visit.visitID;
                visitPhoto.photoID = photo.photoID;
                if(![Update save:self.app.db]) {
                    [File deleteFromDocument:filename];
                    break;
                }
                [self.photos addObject:photo];
                [self.images insertObject:[File imageFromDocument:photo.filename] atIndex:[self.photos indexOfObject:photo]];
                self.cvPhotos.photos = self.images;
                [self.cvPhotos reloadData];
            }
            break;
        }
    }
}

- (void)onCameraCancel:(int)action {
    switch(action) {
        case CAMERA_ACTION_CHECK_IN: {
            [self cancelCheckIn];
            break;
        }
        case CAMERA_ACTION_CHECK_OUT: {
            [self cancelCheckOut];
            break;
        }
    }
}

- (void)onCameraPreviewDelete:(Photos *)image {
    image.isDelete = YES;
    if([Update save:self.app.db]) {
        if([File deleteFromDocument:image.filename]) {
            [self.images removeObjectAtIndex:[self.photos indexOfObject:image]];
            [self.photos removeObject:image];
            self.cvPhotos.photos = self.images;
            [self.cvPhotos reloadData];
        }
    }
}

- (void)onDropDownCancel:(int)type action:(int)action {
    switch(action) {
        case DROP_DOWN_ACTION_CHECK_OUT: {
            [self cancelCheckOut];
            break;
        }
    }
}

- (void)onDropDownSelect:(int)type action:(int)action item:(id)item {
    switch(type) {
        case DROP_DOWN_TYPE_CHECK_OUT_STATUS: {
            self.visitStatus = [item objectForKey:@"visitStatus"];
            NSString *notes = [item objectForKey:@"visitNotes"];
            if(notes != nil) {
                self.visitNotes = notes;
            }
            break;
        }
    }
    switch(action) {
        case DROP_DOWN_ACTION_CHECK_OUT: {
            [self checkOut];
            break;
        }
    }
}

- (void)checkIn {
    if(self.visit.isCheckIn) {
        return;
    }
    if(!self.main.isTimeIn) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"Time In Required";
        vcMessage.message = @"Please time in first before you check-in";
        vcMessage.positiveTitle = @"OK";
        vcMessage.positiveTarget = ^{
            [View removeView:vcMessage.view animated:YES];
        };
        [View addSubview:self.view subview:vcMessage.view animated:YES];
        return;
    }
    if(!self.app.settingVisitsParallelCheckInOut && [Get isCheckIn:self.app.db]) {
        CheckIn *checkIn = [Get checkIn:self.app.db];
        NSString *visitName = [Get visit:self.app.db visitID:checkIn.visitID].name;
        NSString *visitDate = [Time formatDate:self.app.settingDisplayDateFormat date:checkIn.date];
        NSString *message = [NSString stringWithFormat:@"You are currently checked-in at %@ on %@. Please check-out first to continue.", visitName, visitDate];
        NSMutableAttributedString *attributedText = [NSMutableAttributedString.alloc initWithString:message];
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        NSRange range = NSMakeRange(32, visitName.length);
        [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size:self.lName.font.pointSize] range:range];
        range = NSMakeRange(36 + visitName.length, visitDate.length);
        [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size:self.lName.font.pointSize] range:range];
        vcMessage.subject = @"Currently Checked-in";
        vcMessage.attributedMessage = attributedText;
        vcMessage.positiveTitle = @"OK";
        vcMessage.positiveTarget = ^{
            [View removeView:vcMessage.view animated:YES];
        };
        [View addSubview:self.view subview:vcMessage.view animated:YES];
        return;
    }
    if([self.main gpsRequest]) {
        self.isCheckingIn = YES;
        return;
    }
    if(self.app.settingVisitsCheckInPhoto) {
        if([self.main cameraRequest]) {
            self.isCheckingIn = YES;
            return;
        }
        if(self.photo == nil) {
            CameraViewController *vcCamera = [self.storyboard instantiateViewControllerWithIdentifier:@"vcCamera"];
            vcCamera.cameraDelegate = self;
            vcCamera.action = CAMERA_ACTION_CHECK_IN;
            vcCamera.isRearCamera = NO;
            [self.navigationController pushViewController:vcCamera animated:NO];
            return;
        }
        if(self.photoFilename == nil) {
            self.photoFilename = [NSString stringWithFormat:@"%lld-%.0f%@", self.app.employee.employeeID, [NSDate.date timeIntervalSince1970], @".png"];
            if([File saveImageFromImage:[File documentPath:self.photoFilename] image:self.photo] == nil) {
                self.photo = nil;
                self.photoFilename = nil;
                self.isCheckingIn = YES;
                [self applicationDidBecomeActive];
                return;
            }
        }
    }
    self.currentDate = NSDate.date;
    NSString *date = [Time getFormattedDate:DATE_FORMAT date:self.currentDate];
    NSString *time = [Time getFormattedDate:TIME_FORMAT date:self.currentDate];
    Sequences *sequence = [Get sequence:self.app.db];
    CheckIn *checkIn = [NSEntityDescription insertNewObjectForEntityForName:@"CheckIn" inManagedObjectContext:self.app.db];
    if(self.app.location != nil) {
        int64_t gpsID = [Update gpsSave:self.app.db location:self.app.location];
        if(gpsID != 0) {
            checkIn.gpsID = gpsID;
        }
    }
    sequence.checkIn += 1;
    checkIn.checkInID = sequence.checkIn;
    checkIn.syncBatchID = self.app.syncBatchID;
    checkIn.timeInID = [Get timeIn:self.app.db].timeInID;
    checkIn.visitID = self.visit.visitID;
    checkIn.date = date;
    checkIn.time = time;
    checkIn.photo = self.photoFilename;
    checkIn.isSync = NO;
    checkIn.isPhotoUpload = NO;
    self.visit.isCheckIn = YES;
    if([Update save:self.app.db]) {
        [self cancelCheckIn];
        [self updateCheckIn];
    }
}

- (void)cancelCheckIn {
    self.photo = nil;
    self.photoFilename = nil;
    self.currentDate = nil;
}

- (void)checkOut {
    if(!self.visit.isCheckIn || self.visit.isCheckOut) {
        return;
    }
    if(self.store.storeID == 0 && !self.app.settingVisitsEditAfterCheckOut) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"Unfilled Details";
        vcMessage.message = [NSString stringWithFormat:@"Please complete the details of your %@ first.", self.app.conventionStores.lowercaseString];
        vcMessage.positiveTitle = @"OK";
        vcMessage.positiveTarget = ^{
            [View removeView:vcMessage.view animated:YES];
        };
        [View addSubview:self.view subview:vcMessage.view animated:YES];
        return;
    }
    NSString *notes = self.tfNotes.text;
    if([notes isEqualToString:self.tfNotes.placeholder]) {
        notes = @"";
    }
    if(notes.length == 0 && self.app.settingVisitsNotes && !self.app.settingVisitsEditAfterCheckOut) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"Unfilled Details";
        vcMessage.message = @"Please complete the details of your notes first.";
        vcMessage.positiveTitle = @"OK";
        vcMessage.positiveTarget = ^{
            [View removeView:vcMessage.view animated:YES];
        };
        [View addSubview:self.view subview:vcMessage.view animated:YES];
        return;
    }
    if(self.store.storeID != 0) {
        self.visit.name = self.app.settingStoreDisplayLongName ? self.store.name : self.store.shortName;
        self.visit.storeID = self.store.storeID;
    }
    if(notes.length != 0) {
        self.visit.notes = notes;
    }
    if(self.visit.storeID != self.store.storeID || ![self.visit.notes isEqualToString:notes]) {
        if(![Update save:self.app.db]) {
            return;
        }
    }
    if([self.main gpsRequest]) {
        self.isCheckingOut = YES;
        return;
    }
    if(self.app.settingVisitsCheckOutPhoto) {
        if([self.main cameraRequest]) {
            self.isCheckingOut = YES;
            return;
        }
        if(self.photo == nil) {
            CameraViewController *vcCamera = [self.storyboard instantiateViewControllerWithIdentifier:@"vcCamera"];
            vcCamera.cameraDelegate = self;
            vcCamera.action = CAMERA_ACTION_CHECK_OUT;
            vcCamera.isRearCamera = NO;
            [self.navigationController pushViewController:vcCamera animated:NO];
            return;
        }
        if(self.photoFilename == nil) {
            self.photoFilename = [NSString stringWithFormat:@"%lld-%.0f%@", self.app.employee.employeeID, [NSDate.date timeIntervalSince1970], @".png"];
            if([File saveImageFromImage:[File documentPath:self.photoFilename] image:self.photo] == nil) {
                self.photo = nil;
                self.photoFilename = nil;
                self.isCheckingOut = YES;
                [self applicationDidBecomeActive];
                return;
            }
        }
    }
    if(self.visitStatus == nil) {
        DropDownDialogViewController *vcDropDown = [self.storyboard instantiateViewControllerWithIdentifier:@"vcDropDown"];
        vcDropDown.delegate = self;
        vcDropDown.parent = self;
        vcDropDown.type = DROP_DOWN_TYPE_CHECK_OUT_STATUS;
        vcDropDown.action = DROP_DOWN_ACTION_CHECK_OUT;
        NSMutableArray<NSString *> *checkOutStatus = NSMutableArray.alloc.init;
        [checkOutStatus addObject:@"Select Status"];
        [checkOutStatus addObject:@"Completed"];
        [checkOutStatus addObject:@"Not Completed"];
        [checkOutStatus addObject:@"Canceled"];
        vcDropDown.items = checkOutStatus;
        [View addSubview:self.view subview:vcDropDown.view animated:YES];
        [self addChildViewController:vcDropDown];
        return;
    }
    self.currentDate = NSDate.date;
    NSString *date = [Time getFormattedDate:DATE_FORMAT date:self.currentDate];
    NSString *time = [Time getFormattedDate:TIME_FORMAT date:self.currentDate];
    Sequences *sequence = [Get sequence:self.app.db];
    CheckOut *checkOut = [NSEntityDescription insertNewObjectForEntityForName:@"CheckOut" inManagedObjectContext:self.app.db];
    if(self.app.location != nil) {
        int64_t gpsID = [Update gpsSave:self.app.db location:self.app.location];
        if(gpsID != 0) {
            checkOut.gpsID = gpsID;
        }
    }
    sequence.checkOut += 1;
    checkOut.checkOutID = sequence.checkOut;
    checkOut.syncBatchID = self.app.syncBatchID;
    checkOut.checkInID = self.visitCheckIn.checkInID;
    checkOut.date = date;
    checkOut.time = time;
    checkOut.photo = self.photoFilename;
    checkOut.isSync = NO;
    checkOut.isPhotoUpload = NO;
    checkOut.isPhotoDelete = NO;
    if(!self.app.settingVisitsEditAfterCheckOut) {
        self.visit.storeID = self.store.storeID;
    }
    self.visit.status = self.visitStatus;
    if(self.visitNotes.length > 0) {
        self.visit.notes = self.visitNotes;
    }
    self.visit.isCheckOut = YES;
    if([Update save:self.app.db]) {
        self.tfNotes.value = self.visit.notes;
        if(!self.visit.isCheckOut || (self.visit.isCheckOut && self.app.settingVisitsEditAfterCheckOut)) {
            self.btnSave.hidden = NO;
            self.tfNotes.editable = YES;
        }
        else {
            self.btnSave.hidden = YES;
            if([self.tfNotes.text isEqualToString:self.tfNotes.placeholder]) {
                self.tfNotes.text  = nil;
            }
            self.tfNotes.editable = NO;
        }
        [self cancelCheckOut];
        [self updateCheckOut];
    }
}

- (void)cancelCheckOut {
    self.photo = nil;
    self.photoFilename = nil;
    self.visitStatus = nil;
    self.visitNotes = nil;
    self.currentDate = nil;
}

- (void)updateCheckIn {
    if(self.visit.isCheckIn) {
        self.visitCheckIn = [Get checkIn:self.app.db visitID:self.visit.visitID];
        [self.btnCheckIn setTitle:[NSString stringWithFormat:@"IN - %@", [Time formatTime:self.app.settingDisplayTimeFormat time:self.visitCheckIn.time]] forState:UIControlStateNormal];
        self.btnCheckIn.backgroundColor = [Color colorNamed:@"Grey700"];
    }
    else {
        [self.btnCheckIn setTitle:@"Check-In" forState:UIControlStateNormal];
        self.btnCheckIn.backgroundColor = THEME_SEC;
    }
    [self updateCheckOut];
}

- (void)updateCheckOut {
    if(self.visit.isCheckIn) {
        if(self.visit.isCheckOut) {
            self.visitCheckOut = [Get checkOut:self.app.db checkInID:self.visitCheckIn.checkInID];
            [self.btnCheckOut setTitle:[NSString stringWithFormat:@"OUT - %@", [Time formatTime:self.app.settingDisplayTimeFormat time:self.visitCheckOut.time]] forState:UIControlStateNormal];
            self.btnCheckOut.backgroundColor = [Color colorNamed:@"Grey600"];
        }
        else {
            [self.btnCheckOut setTitle:@"Check-Out" forState:UIControlStateNormal];
            self.btnCheckOut.backgroundColor = THEME_SEC;
        }
    }
    else {
        [self.btnCheckOut setTitle:@"Check-Out" forState:UIControlStateNormal];
        self.btnCheckOut.backgroundColor = [Color colorNamed:@"Grey700"];
    }
}

- (void)openMapFromAddress:(NSString *)address {
    [CLGeocoder.alloc.init geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        [self openMapFromCoordinates:placemarks.firstObject.location.coordinate.latitude longitude:placemarks.firstObject.location.coordinate.longitude];
    }];
}
- (void)openMapFromCoordinates:(double)latitude longitude:(double)longitude {
    NSString *url;
    if([UIApplication.sharedApplication canOpenURL:[NSURL URLWithString:@"waze://"]]) {
        url = [NSString stringWithFormat:@"waze://?ll=%f,%f&navigate=yes", latitude, longitude];
    }
    else {
        url = [NSString stringWithFormat:@"https://www.waze.com/ul?ll=%f,%f&navigate=yes", latitude, longitude];
    }
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
}

@end
