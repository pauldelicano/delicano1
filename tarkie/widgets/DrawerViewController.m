#import "DrawerViewController.h"
#import "Image.h"
#import "View.h"
#import "DrawerHeaderTableViewCell.h"
#import "DrawerItemTableViewCell.h"

@interface DrawerViewController()

@property (strong, nonatomic) UIView *vScreen;
@property (nonatomic) float originX;
@property (nonatomic) BOOL viewDidAppear, isOpening, isClosing;

@end

@implementation DrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.openGesture = [UIScreenEdgePanGestureRecognizer.alloc initWithTarget:self action:@selector(openDrawer)];
    self.closeGesture = [UIPanGestureRecognizer.alloc initWithTarget:self action:@selector(closeDrawer)];
    self.openGesture.edges = self.position == DRAWER_POSITION_LEFT ? UIRectEdgeLeft : UIRectEdgeRight;
    self.tvDrawer.tableFooterView = UIView.alloc.init;
    if(self.parent != nil) {
        [self.parent.view addGestureRecognizer:self.openGesture];
    }
    self.viewDidAppear = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect frame = self.tvDrawer.frame;
    frame.size.width = frame.size.width * 0.85;
    self.tvDrawer.frame = frame;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.viewDidAppear) {
        self.viewDidAppear = YES;
        self.vScreen = UIView.alloc.init;
        CGRect frame = self.view.frame;
        frame.origin.y = self.tvDrawer.frame.origin.y;
        self.vScreen.frame = frame;
        self.vScreen.backgroundColor = UIColor.blackColor;
        self.vScreen.alpha = 0;
        self.vScreen.hidden = YES;
        [self.parent.view addSubview:self.vScreen];
        [self.parent.view bringSubviewToFront:self.view];
        self.originX = self.position == DRAWER_POSITION_LEFT ? 0 - self.view.frame.size.width : self.view.frame.size.width;
        frame = self.view.frame;
        frame.origin.x = self.originX;
        self.view.frame = frame;
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    [self.tvDrawer reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menus.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DrawerHeaderTableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"header"];
    header.vBackground.backgroundColor = self.headerBackgroundColor;
    header.ivEmployeePhoto.image = [Image saveFromURL:[Image cachesPath:[NSString stringWithFormat:@"EMPLOYEE_PHOTO_%lld%@", self.employee.employeeID, @".png"]] url:self.employee.photoURL];
    header.ivCompanyLogo.image = [Image saveFromURL:[Image cachesPath:[NSString stringWithFormat:@"COMPANY_LOGO_%lld%@", self.company.companyID, @".png"]] url:self.company.logoURL];
    header.lName.text = [NSString stringWithFormat:@"%@ %@", self.employee.firstName, self.employee.lastName];
    header.lDescription.text = self.employee.employeeNumber;
    CALayer *layer = header.ivEmployeePhoto.layer;
    layer.borderColor = UIColor.whiteColor.CGColor;
    layer.borderWidth = (1.0f / 568) * UIScreen.mainScreen.bounds.size.height;
    layer = header.ivCompanyLogo.layer;
    layer.borderColor = UIColor.whiteColor.CGColor;
    layer.borderWidth = (1.0f / 568) * UIScreen.mainScreen.bounds.size.height;
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DrawerItemTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    NSDictionary *menu = self.menus[indexPath.row];
    id icon = [menu objectForKey:@"icon"];
    if([icon isKindOfClass:UIImage.class]) {
        item.ivIcon.alpha = 1;
        item.lIcon.alpha = 0;
        item.ivIcon.image = icon;
    }
    if([icon isKindOfClass:NSString.class]) {
        item.ivIcon.alpha = 0;
        item.lIcon.alpha = 1;
        item.lIcon.text = icon;
    }
    item.lName.text = [menu objectForKey:@"name"];
    return item;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate onDrawerMenuSelect:[[self.menus[indexPath.row] objectForKey:@"ID"] intValue]];
}

- (void)openDrawer {
    if(!self.isOpening) {
        self.isOpening = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.vScreen.hidden = NO;
            self.vScreen.alpha = 0.8;
            CGRect frame = self.view.frame;
            frame.origin.x = self.position == DRAWER_POSITION_LEFT ? 0 : self.view.frame.size.width - self.tvDrawer.frame.size.width;
            self.view.frame = frame;
        } completion:^(BOOL finished) {
            [self.parent.view addGestureRecognizer:self.closeGesture];
            self.isOpening = NO;
        }];
    }
}

- (void)closeDrawer {
    if(!self.isClosing) {
        self.isClosing = YES;
        [UIView animateWithDuration:0.25 animations:^{
            self.vScreen.alpha = 0;
            CGRect frame = self.view.frame;
            frame.origin.x = self.originX;
            self.view.frame = frame;
        } completion:^(BOOL finished) {
            self.vScreen.hidden = YES;
            [self.parent.view removeGestureRecognizer:self.closeGesture];
            self.isClosing = NO;
        }];
    }
}

@end
