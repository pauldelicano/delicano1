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
@property (nonatomic) BOOL viewDidAppear;

@end

@implementation ListDialogViewController

static MessageDialogViewController *vcMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.tvItems.tableFooterView = UIView.alloc.init;
    self.tvItems.estimatedSectionHeaderHeight = 48;
    self.timeIn = [Get timeIn:self.app.db];
    self.viewDidAppear = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tvItemsHeight.constant = self.view.frame.size.height;
    if(self.tvItems.contentSize.height < self.tvItemsHeight.constant) {
        self.tvItemsHeight.constant = self.tvItems.contentSize.height;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.viewDidAppear) {
        self.viewDidAppear = YES;
        [View setCornerRadiusByWidth:self.tvItems cornerRadius:0.075];
        [View setCornerRadiusByHeight:self.btnClose cornerRadius:1];
        [self onRefresh];
    }
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
    }
    self.tvItemsHeight.constant = self.view.frame.size.height;
    if(self.tvItems.contentSize.height < self.tvItemsHeight.constant) {
        self.tvItemsHeight.constant = self.tvItems.contentSize.height;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DrawerItemTableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"header"];
    switch(self.type) {
        case LIST_TYPE_BREAK: {
            header.ivIcon.alpha = 1;
            header.lIcon.alpha = 0;
            header.ivIcon.image = [UIImage imageNamed:@"MenuBreaks"];
            header.lName.text = @"BREAKS";
            break;
        }
        case LIST_TYPE_MAP: {
            header.ivIcon.alpha = 0;
            header.lIcon.alpha = 1;
            header.lIcon.text = @"\uf124";
            header.lName.text = @"Open Location";
            break;
        }
    }
    header.contentView.subviews[3].backgroundColor = THEME_SEC;
    self.tvItems.scrollIndicatorInsets = UIEdgeInsetsMake(header.frame.size.height, 0, 0, 0);
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(self.type) {
        case LIST_TYPE_BREAK: {
            HomeTableViewCell *item1 = [tableView dequeueReusableCellWithIdentifier:@"item1" forIndexPath:indexPath];
            BreakTypes *breakType = (BreakTypes *)self.items[indexPath.row];
            item1.lName.text = breakType.name;
            BreakIn *breakIn = [Get breakIn:self.app.db timeInID:self.timeIn.timeInID breakTypeID:breakType.breakTypeID];
            item1.lName.textColor = breakIn != nil ? [Color colorNamed:@"Grey500"] : [Color colorNamed:@"Grey800"];
            if(breakIn != nil) {
                item1.lName.textColor = [Color colorNamed:@"Grey500"];
                [item1 setUserInteractionEnabled:NO];
            }
            else {
                item1.lName.textColor = [Color colorNamed:@"Grey800"];
                [item1 setUserInteractionEnabled:YES];
            }
            return item1;
        }
        case LIST_TYPE_MAP: {
            NSString *mapType = (NSString *)self.items[indexPath.row];
            DrawerItemTableViewCell *item2 = [tableView dequeueReusableCellWithIdentifier:@"item2" forIndexPath:indexPath];
            item2.ivIcon.alpha = 1;
            item2.lIcon.alpha = 0;
            if([mapType isEqualToString:@"Maps"]) {
                item2.ivIcon.image = [UIImage imageNamed:@"Maps"];
            }
            if([mapType isEqualToString:@"Waze"]) {
                item2.ivIcon.image = [UIImage imageNamed:@"Waze"];
            }
            item2.lName.text = mapType;
            return item2;
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
    }
    
}

- (IBAction)closeListDialog:(id)sender {
    [View removeChildViewController:self animated:YES];
}

@end
