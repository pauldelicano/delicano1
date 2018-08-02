#import "DropDownDialogViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "View.h"
#import "Time.h"
#import "HomeTableViewCell.h"
#import "VisitDetailsViewController.h"

@interface DropDownDialogViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) id item;
@property (nonatomic) UIEdgeInsets tfNotesLayoutMargins;
@property (nonatomic) BOOL viewDidAppear;

@end

@implementation DropDownDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.tvItems.tableFooterView = UIView.alloc.init;
    self.tvItemsHeight.constant = self.tfDropDown.frame.size.height * 5;
    self.viewDidAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.viewDidAppear) {
        self.viewDidAppear = YES;
        self.tfNotes.highlightedBorderColor = THEME_SEC;
        self.btnPositive.backgroundColor = THEME_SEC;
        [self.btnDropDown setTitleColor:THEME_SEC forState:UIControlStateNormal];
        [View setCornerRadiusByWidth:self.lMessage.superview cornerRadius:0.025];
        [View setCornerRadiusByHeight:self.tfDropDown cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.btnDropDown cornerRadius:0.3];
        [View setCornerRadiusByWidth:self.tfNotes cornerRadius:0.025];
        [View setCornerRadiusByHeight:self.btnNegative cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.btnPositive cornerRadius:0.3];
        CALayer *layer = self.tvItems.layer;
        layer.borderColor = [UIColor colorNamed:@"BlackTransThirty"].CGColor;
        layer.borderWidth = (1.0f / 568) * UIScreen.mainScreen.bounds.size.height;
        self.tfNotesLayoutMargins = self.tfNotes.layoutMargins;
        self.tfNotes.layoutMargins = UIEdgeInsetsZero;
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    switch(self.type) {
        case DROP_DOWN_TYPE_STORE: {
            self.lMessage.text = @"Select Store".uppercaseString;
            break;
        }
        case DROP_DOWN_TYPE_SCHEDULE: {
            self.lMessage.text = @"Select Schedule".uppercaseString;
            self.tvItems.hidden = YES;
            break;
        }
        case DROP_DOWN_TYPE_CHECK_OUT_STATUS: {
            Visits *visit = ((VisitDetailsViewController *)self.parent).visit;
            NSString *message = [NSString stringWithFormat:@"%@%@%@", @"You are checking-out at\n", visit.name, @"\nPlease choose the status\nof your visit:"];
            NSMutableAttributedString *attributedText = [NSMutableAttributedString.alloc initWithString:message];
            NSRange range = NSMakeRange(24, visit.name.length);
            [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size:self.lMessage.font.pointSize] range:range];
            NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.alloc.init;
            paragraphStyle.alignment = NSTextAlignmentCenter;
            paragraphStyle.lineHeightMultiple = 1.5;
            paragraphStyle.lineSpacing = 6;
            [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
            self.lMessage.attributedText = attributedText;
            self.tfNotes.placeholder = @"Tap to add notes...";
            self.tfNotes.value = visit.notes;
            [self tableView:self.tvItems didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            self.tvItems.hidden = YES;
            break;
        }
    }
    if([self.tfDropDown.text isEqualToString:@"Item 1"]) {
        self.tfDropDown.text = nil;
    }
    if(self.tvItemsHeight.constant > self.tvItems.contentSize.height) {
        self.tvItemsHeight.constant = self.tvItems.contentSize.height;
    }
}

- (IBAction)dropDownButton:(id)sender {
    switch(self.type) {
        case DROP_DOWN_TYPE_STORE: {
            StoresViewController *vcStores = [self.storyboard instantiateViewControllerWithIdentifier:@"vcStores"];
            vcStores.delegate = self;
            vcStores.action = STORE_ACTION_SELECT;
            [self.parent.navigationController pushViewController:vcStores animated:YES];
            break;
        }
        case DROP_DOWN_TYPE_SCHEDULE: {
            self.tvItems.hidden = !self.tvItems.hidden;
            break;
        }
        case DROP_DOWN_TYPE_CHECK_OUT_STATUS: {
            self.tvItems.hidden = !self.tvItems.hidden;
            break;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    switch(self.type) {
        case DROP_DOWN_TYPE_STORE: {
            break;
        }
        case DROP_DOWN_TYPE_SCHEDULE: {
            ScheduleTimes *scheduleTime = (ScheduleTimes *)self.items[indexPath.row];
            item.lName.text = [NSString stringWithFormat:@"%@ - %@", [Time formatTime:self.app.settingDisplayTimeFormat time:scheduleTime.timeIn], [Time formatTime:self.app.settingDisplayTimeFormat time:scheduleTime.timeOut]];
            break;
        }
        case DROP_DOWN_TYPE_CHECK_OUT_STATUS: {
            item.lName.text = (NSString *)self.items[indexPath.row];
            break;
        }
    }
    return item;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch(self.type) {
        case DROP_DOWN_TYPE_STORE: {
            break;
        }
        case DROP_DOWN_TYPE_SCHEDULE: {
            ScheduleTimes *scheduleTime = (ScheduleTimes *)self.items[indexPath.row];
            self.tfDropDown.text = [NSString stringWithFormat:@"%@ - %@", [Time formatTime:self.app.settingDisplayTimeFormat time:scheduleTime.timeIn], [Time formatTime:self.app.settingDisplayTimeFormat time:scheduleTime.timeOut]];
            self.item = scheduleTime;
            self.tvItems.hidden = !self.tvItems.hidden;
            break;
        }
        case DROP_DOWN_TYPE_CHECK_OUT_STATUS: {
            Visits *visit = ((VisitDetailsViewController *)self.parent).visit;
            NSString *visitStatus = (NSString *)self.items[indexPath.row];
            self.tfDropDown.text = visitStatus;
            self.item = nil;
            if(visit.notes.length == 0 && (([visitStatus isEqualToString:@"Completed"] && self.app.settingVisitsNotesForCompleted) || ([visitStatus isEqualToString:@"Not Completed"] && self.app.settingVisitsNotesForNotCompleted) || ([visitStatus isEqualToString:@"Canceled"] && self.app.settingVisitsNotesForCanceled))) {
                self.tfNotes.value = @"";
                self.tfNotesHeight.constant = self.tfDropDown.frame.size.height * 2;
                self.tfNotes.layoutMargins = self.tfNotesLayoutMargins;
            }
            else {
                self.tfNotesHeight.constant = 0;
                self.tfNotes.layoutMargins = UIEdgeInsetsZero;
            }
            if(![visitStatus isEqualToString:@"Select Status"]) {
                NSMutableDictionary *visit = NSMutableDictionary.alloc.init;
                [visit setObject:visitStatus forKey:@"visitStatus"];
                self.item = visit;
            }
            self.tvItems.hidden = !self.tvItems.hidden;
            break;
        }
    }
}


- (IBAction)negativeButton:(id)sender {
    [View removeView:self.view animated:YES];
    [self.delegate onDropDownCancel:self.type action:self.action];
    self.item = nil;
}

- (IBAction)positiveButton:(id)sender {
    if(self.item != nil) {
        switch(self.type) {
            case DROP_DOWN_TYPE_STORE: {
                break;
            }
            case DROP_DOWN_TYPE_SCHEDULE: {
                break;
            }
            case DROP_DOWN_TYPE_CHECK_OUT_STATUS: {
                NSString *visitStatus = self.tfDropDown.text;
                if([visitStatus isEqualToString:@"Completed"]) {
                    visitStatus = @"completed";
                }
                if([visitStatus isEqualToString:@"Not Completed"]) {
                    visitStatus = @"incomplete";
                }
                if([visitStatus isEqualToString:@"Canceled"]) {
                    visitStatus = @"cancelled";
                }
                if(visitStatus.length == 0) {
                    return;
                }
                [self.item setObject:visitStatus forKey:@"visitStatus"];
                if(([visitStatus isEqualToString:@"completed"] && self.app.settingVisitsNotesForCompleted) || ([visitStatus isEqualToString:@"incomplete"] && self.app.settingVisitsNotesForNotCompleted) || ([visitStatus isEqualToString:@"cancelled"] && self.app.settingVisitsNotesForCanceled)) {
                    NSString *notes = self.tfNotes.text;
                    if([notes isEqualToString:self.tfNotes.placeholder]) {
                        notes = @"";
                    }
                    if(notes.length == 0) {
                        return;
                    }
                    [self.item setObject:notes forKey:@"visitNotes"];
                }
                break;
            }
        }
        [View removeView:self.view animated:YES];
        [self.delegate onDropDownSelect:self.type action:self.action item:self.item];
        self.item = nil;
    }
}

- (void)onStoresSelect:(Stores *)store {
    self.tfDropDown.text = self.app.settingStoreDisplayLongName ? store.name : store.shortName;
    self.item = store;
}

@end
