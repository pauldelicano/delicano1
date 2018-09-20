#import "StoresViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Load.h"
#import "View.h"
#import "HomeTableViewCell.h"

@interface StoresViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSMutableArray<Stores *> *stores;
@property (strong, nonatomic) NSMutableArray<NSMutableArray<Stores *> *> *storesSectioned;
@property (strong, nonatomic) NSCharacterSet *validChars;
@property (strong, nonatomic) NSString *searchFilter;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation StoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.tvStores.tableFooterView = UIView.alloc.init;
    self.tvStores.estimatedSectionHeaderHeight = 28;
    self.tfSearch.textFieldDelegate = self;
    self.stores = NSMutableArray.alloc.init;
    self.storesSectioned = NSMutableArray.alloc.init;
    self.validChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz"];
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
        self.tfSearch.highlightedBorderColor = THEME_SEC;
        [View setCornerRadiusByHeight:self.btnAdd cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.tfSearch cornerRadius:0.3];
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    self.lName.text = self.app.conventionStores;
    [self.stores removeAllObjects];
    [self.storesSectioned removeAllObjects];
    [self.stores addObjectsFromArray:[Load stores:self.app.db searchFilter:self.searchFilter]];
    NSString *alphabet = @"#";
    NSMutableArray<Stores *> *rows = NSMutableArray.alloc.init;
    for(int x = 0; x < self.stores.count; x++) {
        if((self.app.settingStoreDisplayLongName ? self.stores[x].name : self.stores[x].shortName).length > 0) {
            NSString *letter = [self.app.settingStoreDisplayLongName ? self.stores[x].name : self.stores[x].shortName substringToIndex:1].lowercaseString;
            if([letter rangeOfCharacterFromSet:self.validChars].location == NSNotFound) {
                letter = @"#";
            }
            if(![letter isEqualToString:alphabet]) {
                [self.storesSectioned addObject:rows];
                rows = NSMutableArray.alloc.init;
            }
            [rows addObject:self.stores[x]];
            alphabet = letter;
        }
    }
    if(rows.count > 0) {
        [self.storesSectioned addObject:rows];
    }
    [self.tvStores reloadData];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)add:(id)sender {
    EditStoreViewController *vcEditStore = [self.storyboard instantiateViewControllerWithIdentifier:@"vcEditStore"];
    vcEditStore.delegate = self;
    [self.navigationController pushViewController:vcEditStore animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.storesSectioned.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.storesSectioned[section].count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HomeTableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"header"];
    Stores *store = self.storesSectioned[section].firstObject;
    NSString *letter = [self.app.settingStoreDisplayLongName ? store.name : store.shortName substringToIndex:1].lowercaseString;
    if([letter rangeOfCharacterFromSet:self.validChars].location == NSNotFound) {
        letter = @"#";
    }
    header.lName.text = letter.uppercaseString;
    header.lName.textColor = THEME_SEC;
    header.contentView.subviews[2].backgroundColor = THEME_SEC;
    return header.contentView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    Stores *store = self.storesSectioned[indexPath.section][indexPath.row];
    item.lName.text = self.app.settingStoreDisplayLongName ? store.name : store.shortName;
    return item;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch(self.action) {
        case STORE_ACTION_CONTACTS: {
            StoreContactsViewController *vcStoreContacts = [self.storyboard instantiateViewControllerWithIdentifier:@"vcStoreContacts"];
            vcStoreContacts.delegate = self;
            vcStoreContacts.store = self.storesSectioned[indexPath.section][indexPath.row];
            [self.navigationController pushViewController:vcStoreContacts animated:YES];
            break;
        }
        case STORE_ACTION_SELECT: {
            [self back:self];
            [self.delegate onStoresSelect:self.storesSectioned[indexPath.section][indexPath.row]];
            break;
        }
    }
}

- (void)onTextFieldTextChanged:(NSString *)text {
    self.searchFilter = text;
    [self onRefresh];
}

- (void)onEditStoreSave:(Stores *)store {
    [self onRefresh];
}

- (void)onStoreContactsEditStoreSave:(Stores *)store {
    [self onRefresh];
}

@end
