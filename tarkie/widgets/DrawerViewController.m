#import "DrawerViewController.h"
#import "App.h"
#import "File.h"
#import "View.h"
#import "Color.h"
#import "DrawerHeaderTableViewCell.h"
#import "DrawerItemTableViewCell.h"

@interface DrawerViewController()

@property (nonatomic) float edge, originX;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation DrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.openGesture = [UIScreenEdgePanGestureRecognizer.alloc initWithTarget:self action:@selector(openDrawer)];
    self.closeGesture = [UIPanGestureRecognizer.alloc initWithTarget:self action:@selector(closeDrawer)];
    self.tvDrawer.tableFooterView = UIView.alloc.init;
    self.tvDrawer.estimatedSectionHeaderHeight = 144;
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.openGesture.edges = self.position == DRAWER_POSITION_LEFT ? UIRectEdgeLeft : UIRectEdgeRight;
        [self.view.superview.superview addGestureRecognizer:self.openGesture];
        self.edge = (6.0f / 568) * UIScreen.mainScreen.bounds.size.height;
        self.originX = self.position == DRAWER_POSITION_LEFT ? 0 - self.view.frame.size.width : self.view.frame.size.width;
        CGRect frame = self.view.superview.frame;
        frame.origin.x = self.position == DRAWER_POSITION_LEFT ? self.originX + self.edge : self.originX - self.edge;
        self.view.superview.frame = frame;
        frame = self.view.frame;
        frame.origin.x = self.originX;
        frame.size.width = self.view.superview.frame.size.width * 0.8;
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
    header.vBackground.backgroundColor = THEME_PRI;
    header.ivEmployeePhoto.image = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [File saveImageFromURL:[File cachesPath:[NSString stringWithFormat:@"EMPLOYEE_PHOTO_%lld%@", self.employee.employeeID, @".png"]] url:self.employee.photoURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            header.ivEmployeePhoto.image = image;
        });
    });
    header.ivCompanyLogo.image = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [File saveImageFromURL:[File cachesPath:[NSString stringWithFormat:@"COMPANY_LOGO_%lld%@", self.company.companyID, @".png"]] url:self.company.logoURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            header.ivCompanyLogo.image = image;
        });
    });
    header.lName.text = [NSString stringWithFormat:@"%@ %@", self.employee.firstName, self.employee.lastName];
    header.lDescription.text = self.employee.employeeNumber;
    CALayer *layer = header.ivEmployeePhoto.layer;
    layer.borderColor = UIColor.whiteColor.CGColor;
    layer.borderWidth = (2.0f / 568) * UIScreen.mainScreen.bounds.size.height;
    layer = header.ivCompanyLogo.layer;
    layer.borderColor = UIColor.whiteColor.CGColor;
    layer.borderWidth = (2.0f / 568) * UIScreen.mainScreen.bounds.size.height;
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
    if(CGColorGetAlpha(self.view.superview.superview.subviews.lastObject.backgroundColor.CGColor) == CGColorGetAlpha([Color colorNamed:@"BlackTransThirty"].CGColor)) {
        return;
    }
    if(!self.isOpen) {
        self.isOpen = YES;
        CGRect frame = self.view.superview.frame;
        frame.origin.x = 0;
        self.view.superview.frame = frame;
        [UIView animateWithDuration:0.5 animations:^{
            self.view.superview.backgroundColor = [Color colorNamed:@"BlackTransSixty"];
            CGRect frame = self.view.frame;
            frame.origin.x = self.position == DRAWER_POSITION_LEFT ? 0 : self.view.superview.frame.size.width - self.view.frame.size.width;
            self.view.frame = frame;
        } completion:^(BOOL finished) {
            [self.view.superview.superview addGestureRecognizer:self.closeGesture];
        }];
    }
}

- (void)closeDrawer {
    if(self.isOpen) {
        self.isOpen = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.view.superview.backgroundColor = UIColor.clearColor;
            CGRect frame = self.view.frame;
            frame.origin.x = self.originX;
            self.view.frame = frame;
        } completion:^(BOOL finished) {
            CGRect frame = self.view.superview.frame;
            frame.origin.x = self.position == DRAWER_POSITION_LEFT ? self.originX + self.edge : self.originX - self.edge;
            self.view.superview.frame = frame;
            [self.view.superview.superview removeGestureRecognizer:self.closeGesture];
        }];
    }
}

@end
