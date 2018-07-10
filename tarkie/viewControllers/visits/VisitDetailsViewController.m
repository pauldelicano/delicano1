#import "VisitDetailsViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Load.h"
#import "Update.h"
#import "Image.h"
#import "View.h"
#import "Time.h"
#import "HomeTableViewCell.h"
#import "MessageDialogViewController.h"

@interface VisitDetailsViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSMutableArray<VisitInventories *> *inventories;
@property (strong, nonatomic) NSMutableArray<VisitForms *> *forms;
@property (strong, nonatomic) NSMutableArray<Photos *> *photos;
@property (strong, nonatomic) NSMutableArray<UIImage *> *images;
@property (nonatomic) UIEdgeInsets vInventoryLayoutMargins, vFormsLayoutMargins;
@property (strong, nonatomic) Stores *store;
@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) NSString *photoFilename, *visitStatus, *visitNotes, *conventionStores, *conventionVisits, *conventionInvoice, *conventionDeliveries;
@property (strong, nonatomic) NSDate *currentDate;
@property (nonatomic) long userID;
@property (nonatomic) BOOL viewWillAppear, isInventory, isForms, inventoryLoaded, formsLoaded, isCheckingIn, isCheckingOut;

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
    self.userID = [Get userID:self.app.db];
    self.store = nil;
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
        [View setCornerRadiusByHeight:self.btnInventory cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.btnForms cornerRadius:0.3];
        [View setCornerRadiusByWidth:self.tfNotes cornerRadius:0.025];
        self.vInventoryLayoutMargins = self.vInventory.layoutMargins;
        self.vFormsLayoutMargins = self.vForms.layoutMargins;
        [self onRefresh];
        [self applicationDidBecomeActive];
    }
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.vScroll.contentSize = CGSizeMake(self.vScroll.frame.size.width, self.vContent.frame.size.height);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)onRefresh {
    [super onRefresh];
    self.conventionStores = [Get conventionName:self.app.db conventionID:CONVENTION_STORES];
    self.conventionVisits = [Get conventionName:self.app.db conventionID:CONVENTION_VISITS];
    self.conventionInvoice = [Get conventionName:self.app.db conventionID:CONVENTION_INVOICE];
    self.conventionDeliveries = [Get conventionName:self.app.db conventionID:CONVENTION_DELIVERIES];
    [self.inventories removeAllObjects];
    [self.forms removeAllObjects];
    [self.photos removeAllObjects];
    [self.images removeAllObjects];
    self.isInventory = [Get isModuleEnabled:self.app.db moduleID:MODULE_INVENTORY];
    self.isForms = [Get isModuleEnabled:self.app.db moduleID:MODULE_FORMS];
    if(self.isInventory) {
        [self.inventories addObjectsFromArray:[Load visitInventories:self.app.db visitID:self.visit.visitID]];
    }
    if(self.isForms) {
        [self.forms addObjectsFromArray:[Load visitForms:self.app.db visitID:self.visit.visitID]];
    }
    [self.photos addObjectsFromArray:[Load visitPhotos:self.app.db visitID:self.visit.visitID]];
    for(int x = 0; x < self.photos.count; x++) {
        [self.images addObject:[Image fromDocument:self.photos[x].filename]];
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
    if(self.visit.storeID != 0) {
        self.lName.text = self.conventionVisits;
        Stores *store = [Get store:self.app.db storeID:self.visit.storeID];
        self.lStoreName.text = store.name;
        self.lStoreAddress.text = store.address.length > 0 ? store.address : @"No address";
    }
    else {
        self.lName.text = self.visit.name;
        self.lStoreName.text = [NSString stringWithFormat:@"%@ Name", self.conventionStores];
        self.lStoreAddress.text = @"Address";
    }
    if(self.isInventory) {
        self.vInventory.hidden = NO;
        self.vInventory.layoutMargins = self.vInventoryLayoutMargins;
        self.vInventoryHeight.active = NO;
        self.tvInventoryHeight.constant = self.tvInventory.contentSize.height;
    }
    else {
        self.vInventory.hidden = YES;
        self.vInventory.layoutMargins = UIEdgeInsetsZero;
        self.vInventoryHeight.active = YES;
        self.tvInventoryHeight.constant = 0;
    }
    if(self.isForms) {
        self.vForms.hidden = NO;
        self.vForms.layoutMargins = self.vFormsLayoutMargins;
        self.vFormsHeight.active = NO;
        self.tvFormsHeight.constant = self.tvForms.contentSize.height;
    }
    else {
        self.vForms.hidden = YES;
        self.vForms.layoutMargins = UIEdgeInsetsZero;
        self.vFormsHeight.active = YES;
        self.tvFormsHeight.constant = 0;
    }
    self.lInvoice.text = self.conventionInvoice;
    self.lDeliveries.text = self.conventionDeliveries;
    self.lInvoiceValue.text = self.visit.invoice.length > 0 ? self.visit.invoice : @"N/A";
    self.lDeliveriesValue.text = [NSString stringWithFormat:@"P%.02f", [self.visit.deliveries floatValue]];
    self.tfNotes.value = self.visit.notes;
    [self.view layoutIfNeeded];
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    if(self.store.storeID != 0) {
        self.visit.name = self.store.name;
        self.visit.storeID = self.store.storeID;
    }
    NSString *notes = self.tfNotes.text;
    if([notes isEqualToString:self.tfNotes.placeholder]) {
        notes = @"";
    }
    self.visit.notes = notes;
    if(self.visit.isSync) {
        self.visit.isUpdate = YES;
        self.visit.isWebUpdate = NO;
    }
    if([Update save:self.app.db]) {
        [self back:self];
    }
}

- (IBAction)editStore:(id)sender {
    StoresViewController *vcStores = [self.storyboard instantiateViewControllerWithIdentifier:@"vcStores"];
    vcStores.delegate = self;
    vcStores.action = STORE_ACTION_SELECT;
    [self.navigationController pushViewController:vcStores animated:YES];
}

- (IBAction)checkIn:(id)sender {
    [self checkIn];
}

- (IBAction)checkOut:(id)sender {
    [self checkOut];
}

- (IBAction)addInventory:(id)sender {
    NSLog(@"paul: addInventory");
}

- (IBAction)addForms:(id)sender {
    NSLog(@"paul: addForms");
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
    self.lStoreName.text = self.store.name;
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
    CameraViewController *vcCamera = [self.storyboard instantiateViewControllerWithIdentifier:@"vcCamera"];
    vcCamera.cameraDelegate = self;
    vcCamera.action = CAMERA_ACTION_VISIT_PHOTOS;
    vcCamera.isRearCamera = YES;
    [self.navigationController pushViewController:vcCamera animated:NO];
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
            NSString *filename = [NSString stringWithFormat:@"%ld-%.0f%@", self.userID, [currentDate timeIntervalSince1970], @".png"];
            if([Image saveFromImage:[Image documentPath:filename] image:image] != nil) {
                Sequences *sequence = [Get sequence:self.app.db];
                Photos *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:self.app.db];
                sequence.photos += 1;
                photo.photoID = sequence.photos;
                photo.employeeID = self.userID;
                photo.date = [Time formatDate:DATE_FORMAT date:currentDate];
                photo.time = [Time formatDate:TIME_FORMAT date:currentDate];
                photo.filename = filename;
                photo.syncBatchID = [Get syncBatchID:self.app.db];
                photo.isSignature = NO;
                photo.isUpload = NO;
                photo.isDelete = NO;
                VisitPhotos *visitPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"VisitPhotos" inManagedObjectContext:self.app.db];
                sequence.visitPhotos += 1;
                visitPhoto.visitPhotoID = sequence.visitPhotos;
                visitPhoto.visitID = self.visit.visitID;
                visitPhoto.photoID = photo.photoID;
                if(![Update save:self.app.db]) {
                    [Image deleteFromDocument:filename];
                    break;
                }
                [self.photos addObject:photo];
                [self.images insertObject:[Image fromDocument:photo.filename] atIndex:[self.photos indexOfObject:photo]];
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
        if([Image deleteFromDocument:image.filename]) {
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
    if(![Get isTimeIn:self.app.db]) {
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
    if([self.main gpsRequest]) {
        self.isCheckingIn = YES;
        return;
    }
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
        self.photoFilename = [NSString stringWithFormat:@"%ld-%.0f%@", self.userID, [NSDate.date timeIntervalSince1970], @".png"];
        if([Image saveFromImage:[Image documentPath:self.photoFilename] image:self.photo] == nil) {
            self.photo = nil;
            self.photoFilename = nil;
            self.isCheckingIn = YES;
            [self applicationDidBecomeActive];
            return;
        }
    }
    self.currentDate = NSDate.date;
    NSString *date = [Time formatDate:DATE_FORMAT date:self.currentDate];
    NSString *time = [Time formatDate:TIME_FORMAT date:self.currentDate];
    NSString *syncBatchID = [Get syncBatchID:self.app.db];
    Sequences *sequence = [Get sequence:self.app.db];
    GPS *gps = [NSEntityDescription insertNewObjectForEntityForName:@"GPS" inManagedObjectContext:self.app.db];
    sequence.gps += 1;
    gps.gpsID = sequence.gps;
    gps.date = [Time formatDate:DATE_FORMAT date:self.app.location.timestamp];
    gps.time = [Time formatDate:TIME_FORMAT date:self.app.location.timestamp];
    gps.latitude = self.app.location.coordinate.latitude;
    gps.longitude = self.app.location.coordinate.longitude;
    CheckIn *checkIn = [NSEntityDescription insertNewObjectForEntityForName:@"CheckIn" inManagedObjectContext:self.app.db];
    sequence.checkIn += 1;
    checkIn.checkInID = sequence.checkIn;
    checkIn.timeInID = [Get timeIn:self.app.db].timeInID;
    checkIn.visitID = self.visit.visitID;
    checkIn.date = date;
    checkIn.time = time;
    checkIn.gpsID = gps.gpsID;
    checkIn.photo = self.photoFilename;
    checkIn.syncBatchID = syncBatchID;
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
    if([self.main gpsRequest]) {
        self.isCheckingOut = YES;
        return;
    }
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
        self.photoFilename = [NSString stringWithFormat:@"%ld-%.0f%@", self.userID, [NSDate.date timeIntervalSince1970], @".png"];
        if([Image saveFromImage:[Image documentPath:self.photoFilename] image:self.photo] == nil) {
            self.photo = nil;
            self.photoFilename = nil;
            self.isCheckingOut = YES;
            [self applicationDidBecomeActive];
            return;
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
    NSString *date = [Time formatDate:DATE_FORMAT date:self.currentDate];
    NSString *time = [Time formatDate:TIME_FORMAT date:self.currentDate];
    NSString *syncBatchID = [Get syncBatchID:self.app.db];
    Sequences *sequence = [Get sequence:self.app.db];
    GPS *gps = [NSEntityDescription insertNewObjectForEntityForName:@"GPS" inManagedObjectContext:self.app.db];
    sequence.gps += 1;
    gps.gpsID = sequence.gps;
    gps.date = [Time formatDate:DATE_FORMAT date:self.app.location.timestamp];
    gps.time = [Time formatDate:TIME_FORMAT date:self.app.location.timestamp];
    gps.latitude = self.app.location.coordinate.latitude;
    gps.longitude = self.app.location.coordinate.longitude;
    CheckOut *checkOut = [NSEntityDescription insertNewObjectForEntityForName:@"CheckOut" inManagedObjectContext:self.app.db];
    sequence.checkOut += 1;
    checkOut.checkOutID = sequence.checkOut;
    checkOut.checkInID = [Get checkIn:self.app.db timeInID:[Get timeIn:self.app.db].timeInID].checkInID;
    checkOut.date = date;
    checkOut.time = time;
    checkOut.gpsID = gps.gpsID;
    checkOut.photo = self.photoFilename;
    checkOut.syncBatchID = syncBatchID;
    checkOut.isSync = NO;
    checkOut.isPhotoUpload = NO;
    checkOut.isPhotoDelete = NO;
    self.visit.status = self.visitStatus;
    if(self.visitNotes.length > 0) {
        self.visit.notes = self.visitNotes;
    }
    self.visit.isCheckOut = YES;
    if([Update save:self.app.db]) {
        self.tfNotes.text = self.visit.notes;
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
        [self.btnCheckIn setTitle:[NSString stringWithFormat:@"IN - %@", [Get checkIn:self.app.db visitID:self.visit.visitID].time] forState:UIControlStateNormal];
        self.btnCheckIn.backgroundColor = [UIColor colorNamed:@"Grey700"];
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
            [self.btnCheckOut setTitle:[NSString stringWithFormat:@"OUT - %@", [Get checkOut:self.app.db checkInID:[Get checkIn:self.app.db visitID:self.visit.visitID].checkInID].time] forState:UIControlStateNormal];
            self.btnCheckOut.backgroundColor = [UIColor colorNamed:@"Grey600"];
        }
        else {
            [self.btnCheckOut setTitle:@"Check-Out" forState:UIControlStateNormal];
            self.btnCheckOut.backgroundColor = THEME_SEC;
        }
    }
    else {
        [self.btnCheckOut setTitle:@"Check-Out" forState:UIControlStateNormal];
        self.btnCheckOut.backgroundColor = [UIColor colorNamed:@"Grey700"];
    }
}

@end
