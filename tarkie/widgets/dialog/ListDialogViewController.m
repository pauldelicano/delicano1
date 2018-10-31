#import "ListDialogViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Load.h"
#import "View.h"
#import "Color.h"
#import "HomeTableViewCell.h"
#import "DrawerItemTableViewCell.h"
#import "MessageDialogViewController.h"

@interface ListDialogViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) TimeIn *timeIn;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation ListDialogViewController

static MessageDialogViewController *vcMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.tvItems.tableFooterView = UIView.alloc.init;
    self.tvItems.estimatedSectionHeaderHeight = 48;
    self.timeIn = [Get timeIn:self.app.db];
    self.viewWillAppear = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tvItemsHeight.constant = self.view.frame.size.height;
    if(self.tvItems.contentSize.height < self.tvItemsHeight.constant) {
        self.tvItemsHeight.constant = self.tvItems.contentSize.height;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        [View setCornerRadiusByWidth:self.tvItems cornerRadius:0.075];
        [View setCornerRadiusByHeight:self.btnClose cornerRadius:1];
        [self onRefresh];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tvItemsHeight.constant = self.view.frame.size.height;
}

- (void)onRefresh {
    [super onRefresh];
    switch(self.type) {
        case LIST_TYPE_BREAK: {
            break;
        }
        case LIST_TYPE_MAP: {
            break;
        }
        case LIST_TYPE_EXPENSE_TYPE: {
            break;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DrawerItemTableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"header"];
    header.contentView.subviews[3].backgroundColor = THEME_SEC;
    header.ivIcon.image = nil;
    header.lIcon.text = nil;
    switch(self.type) {
        case LIST_TYPE_BREAK: {
            header.ivIcon.image = [UIImage imageNamed:@"MenuBreaks"];
            header.lName.text = @"BREAKS";
            break;
        }
        case LIST_TYPE_MAP: {
            header.lIcon.text = @"\uf124";
            header.lName.text = @"Open Location";
            break;
        }
        case LIST_TYPE_EXPENSE_TYPE: {
            header.lName.text = @"EXPENSE TYPES";
            break;
        }
    }
    if(header.ivIcon.image == nil && header.lIcon.text == nil) {
        [header.ivIcon removeFromSuperview];
        [header.lIcon removeFromSuperview];
    }
    [header layoutIfNeeded];
    self.tvItems.scrollIndicatorInsets = UIEdgeInsetsMake(header.frame.size.height, 0, 0, 0);
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(self.type) {
        case LIST_TYPE_BREAK: {
            HomeTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item1" forIndexPath:indexPath];
            BreakTypes *breakType = (BreakTypes *)self.items[indexPath.row];
            item.lName.text = breakType.name;
            BreakIn *breakIn = [Get breakIn:self.app.db timeInID:self.timeIn.timeInID breakTypeID:breakType.breakTypeID];
            item.lName.textColor = breakIn != nil ? [Color colorNamed:@"Grey500"] : [Color colorNamed:@"Grey800"];
            if(breakIn != nil) {
                item.lName.textColor = [Color colorNamed:@"Grey500"];
                item.userInteractionEnabled = NO;
            }
            else {
                item.lName.textColor = [Color colorNamed:@"Grey800"];
                item.userInteractionEnabled = YES;
            }
            [item layoutIfNeeded];
            return item;
        }
        case LIST_TYPE_MAP: {
            NSString *mapType = (NSString *)self.items[indexPath.row];
            DrawerItemTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item2" forIndexPath:indexPath];
            item.ivIcon.alpha = 1;
            item.lIcon.alpha = 0;
            if([mapType isEqualToString:@"Maps"]) {
                item.ivIcon.image = [UIImage imageNamed:@"Maps"];
            }
            if([mapType isEqualToString:@"Waze"]) {
                item.ivIcon.image = [UIImage imageNamed:@"Waze"];
            }
            item.lName.text = mapType;
            [item layoutIfNeeded];
            return item;
        }
        case LIST_TYPE_EXPENSE_TYPE: {
            HomeTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item1" forIndexPath:indexPath];
            item.lName.text = ((ExpenseTypes *)self.items[indexPath.row]).name;
            [item layoutIfNeeded];
            return item;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch(self.type) {
        case LIST_TYPE_BREAK: {
            BreakTypes *breakType = (BreakTypes *)self.items[indexPath.row];
            vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
            vcMessage.subject = @"Confirm Break";
            vcMessage.message = [NSString stringWithFormat:@"Do you want to take your %@ now?", breakType.name];
            vcMessage.negativeTitle = @"No";
            vcMessage.negativeTarget = ^{
                [View removeChildViewController:vcMessage animated:YES];
            };
            vcMessage.positiveTitle = @"Yes";
            vcMessage.positiveTarget = ^{
                [View removeChildViewController:vcMessage animated:YES];
                [View removeChildViewController:self animated:YES];
                [self.delegate onListSelect:self.type item:breakType];
            };
            [View addChildViewController:self childViewController:vcMessage animated:YES];
            break;
        }
        case LIST_TYPE_MAP: {
            [View removeChildViewController:self animated:YES];
            [self.delegate onListSelect:self.type item:self.items[indexPath.row]];
            break;
        }
        case LIST_TYPE_EXPENSE_TYPE: {
            [View removeChildViewController:self animated:YES];
            [self.delegate onListSelect:self.type item:self.items[indexPath.row]];
            break;
        }
    }
}

- (IBAction)closeListDialog:(id)sender {
    [View removeChildViewController:self animated:YES];
}

@end
