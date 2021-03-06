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
@property (nonatomic) CGFloat notesHeight;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation DropDownDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.tvItems.tableFooterView = UIView.alloc.init;
    self.notesHeight = self.tfNotesHeight.constant;
    self.tfNotesHeight.constant = 0;
    self.viewWillAppear = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if(self.vContent.frame.size.height < self.vScroll.frame.size.height) {
        CGFloat inset = self.vScroll.frame.size.height - self.vContent.frame.size.height;
        self.vScroll.contentInset = UIEdgeInsetsMake(inset * 0.5, 0, inset * 0.5, 0);
    }
    else {
        self.vScroll.contentInset = UIEdgeInsetsZero;
    }
    if(self.tvItemsHeight.constant > self.tvItems.contentSize.height) {
        self.tvItemsHeight.constant = self.tvItems.contentSize.height;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.tfNotes.highlightedBorderColor = THEME_SEC;
        self.btnPositive.backgroundColor = THEME_SEC;
        [self.btnDropDown setTitleColor:THEME_SEC forState:UIControlStateNormal];
        [View setCornerRadiusByWidth:self.lSubject.superview cornerRadius:0.075];
        [View setCornerRadiusByHeight:self.tfDropDown cornerRadius:0.3];
        [View setCornerRadiusByHeight:self.btnDropDown cornerRadius:0.3];
        [View setCornerRadiusByWidth:self.tfNotes cornerRadius:0.125];
        [View setCornerRadiusByHeight:self.btnNegative cornerRadius:0.2];
        [View setCornerRadiusByHeight:self.btnPositive cornerRadius:0.2];
        CALayer *layer = self.tvItems.layer;
        layer.borderColor = [Color colorNamed:@"Grey500"].CGColor;
        layer.borderWidth = (0.5f / 568) * UIScreen.mainScreen.bounds.size.height;
        [self onRefresh];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.tvItemsHeight.constant > self.tvItems.contentSize.height) {
        self.tvItemsHeight.constant = self.tvItems.contentSize.height;
    }
}

- (void)onRefresh {
    [super onRefresh];
    switch(self.type) {
        case DROP_DOWN_TYPE_STORE: {
            self.lSubject.text = @"Select Store".uppercaseString;
            break;
        }
        case DROP_DOWN_TYPE_SCHEDULE: {
            self.lSubject.text = @"Select Schedule".uppercaseString;
            break;
        }
        case DROP_DOWN_TYPE_CHECK_OUT_STATUS: {
            Visits *visit = ((VisitDetailsViewController *)self.parent).visit;
            NSString *message = [NSString stringWithFormat:@"%@%@%@", @"You are checking-out at\n", visit.name, @"\nPlease choose the status\nof your visit:"];
            NSMutableAttributedString *attributedText = [NSMutableAttributedString.alloc initWithString:message];
            NSRange range = NSMakeRange(24, visit.name.length);
            [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size:self.lSubject.font.pointSize] range:range];
            NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.alloc.init;
            paragraphStyle.alignment = NSTextAlignmentCenter;
            paragraphStyle.lineHeightMultiple = 1.5;
            paragraphStyle.lineSpacing = 6;
            [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
            self.lSubject.attributedText = attributedText;
            self.tfNotes.placeholder = @"Tap to add notes...";
            self.tfNotes.value = visit.notes;
            [self tableView:self.tvItems didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            break;
        }
    }
    self.tvItems.hidden = YES;
    if([self.tfDropDown.text isEqualToString:@"Item 1"]) {
        self.tfDropDown.text = nil;
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
    [item layoutIfNeeded];
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
                self.tfNotesHeight.constant = self.notesHeight;
            }
            else {
                self.tfNotesHeight.constant = 0;
            }
            if(![visitStatus isEqualToString:@"Select Status"]) {
                NSMutableDictionary *visit = NSMutableDictionary.alloc.init;
                visit[@"visitStatus"] = visitStatus;
                self.item = visit;
            }
            self.tvItems.hidden = !self.tvItems.hidden;
            break;
        }
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

- (IBAction)negativeButton:(id)sender {
    [View removeChildViewController:self animated:YES];
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
                self.item[@"visitStatus"] = visitStatus;
                if(([visitStatus isEqualToString:@"completed"] && self.app.settingVisitsNotesForCompleted) || ([visitStatus isEqualToString:@"incomplete"] && self.app.settingVisitsNotesForNotCompleted) || ([visitStatus isEqualToString:@"cancelled"] && self.app.settingVisitsNotesForCanceled)) {
                    NSString *notes = self.tfNotes.text;
                    if([notes isEqualToString:self.tfNotes.placeholder]) {
                        notes = @"";
                    }
                    if(notes.length == 0) {
                        return;
                    }
                    self.item[@"visitNotes"] = notes;
                }
                break;
            }
        }
        [View removeChildViewController:self animated:YES];
        [self.delegate onDropDownSelect:self.type action:self.action item:self.item];
        self.item = nil;
    }
}

- (void)onStoresSelect:(Stores *)store {
    self.tfDropDown.text = self.app.settingStoreDisplayLongName ? store.name : store.shortName;
    self.item = store;
}

@end
