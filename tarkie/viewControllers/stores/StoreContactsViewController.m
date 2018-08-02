#import "StoreContactsViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Load.h"
#import "View.h"
#import "StoreContactsHeaderTableViewCell.h"
#import "StoreContactsItemTableViewCell.h"
#import "EditStoreViewController.h"
#import "EditStoreContactViewController.h"

@interface StoreContactsViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSMutableArray<StoreContacts *> *storeContacts;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation StoreContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.tvStoreContacts.tableFooterView = UIView.alloc.init;
    self.storeContacts = NSMutableArray.alloc.init;
    self.btnAdd.hidden = !self.app.settingStoreAdd;
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.vStatusBar.backgroundColor = THEME_PRI_DARK;
        self.vNavBar.backgroundColor = THEME_PRI;
        [self.btnAdd setTitleColor:THEME_PRI forState:UIControlStateNormal];
        [View setCornerRadiusByHeight:self.btnAdd cornerRadius:0.3];
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    [self.storeContacts removeAllObjects];
    [self.storeContacts addObjectsFromArray:[Load storeContacts:self.app.db storeID:self.store.storeID]];
    [self.tvStoreContacts reloadData];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)add:(id)sender {
    EditStoreContactViewController *vcEditStoreContact = [self.storyboard instantiateViewControllerWithIdentifier:@"vcEditStoreContact"];
    vcEditStoreContact.delegate = self;
    vcEditStoreContact.store = self.store;
    [self.navigationController pushViewController:vcEditStoreContact animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.storeContacts.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    StoreContactsHeaderTableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"header"];
    header.lName.text = self.app.settingStoreDisplayLongName ? self.store.name : self.store.shortName;
    header.lAddress.text = self.store.address.length > 0 ? self.store.address : @"No address";
    header.btnEdit.hidden = !self.app.settingStoreEdit;
    [header.btnEdit addTarget:self action:@selector(editStore:) forControlEvents:UIControlEventTouchUpInside];
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoreContactsItemTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item"];
    StoreContacts *storeContact = self.storeContacts[indexPath.row];
    item.lName.text = storeContact.name;
    item.lDesignation.text = storeContact.designation;
    item.lEmail.text = storeContact.email;
    item.lBirthdate.text = storeContact.birthdate;
    item.btnEdit.tag = indexPath.row;
    item.btnEdit.hidden = !self.app.settingStoreEdit;
    [item.btnEdit addTarget:self action:@selector(editStoreContact:) forControlEvents:UIControlEventTouchUpInside];
    return item;
}

- (void)editStore:(UIButton *)sender {
    EditStoreViewController *vcEditStore = [self.storyboard instantiateViewControllerWithIdentifier:@"vcEditStore"];
    vcEditStore.delegate = self;
    vcEditStore.store = self.store;
    [self.navigationController pushViewController:vcEditStore animated:YES];
}

- (void)editStoreContact:(UIButton *)sender {
    EditStoreContactViewController *vcEditStoreContact = [self.storyboard instantiateViewControllerWithIdentifier:@"vcEditStoreContact"];
    vcEditStoreContact.delegate = self;
    vcEditStoreContact.store = self.store;
    vcEditStoreContact.storeContact = self.storeContacts[sender.tag];
    [self.navigationController pushViewController:vcEditStoreContact animated:YES];
}

- (void)onEditStoreSave:(Stores *)store {
    self.store = store;
    [self.delegate onStoreContactsEditStoreSave:self.store];
    [self onRefresh];
}

- (void)onEditStoreContactSave:(StoreContacts *)storeContact {
    [self onRefresh];
}

@end
