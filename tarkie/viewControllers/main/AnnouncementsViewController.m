#import "AnnouncementsViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Load.h"
#import "File.h"
#import "View.h"
#import "Time.h"
#import "AnnouncementsItemTableViewCell.h"
#import "AnnouncementDetailsViewController.h"

@interface AnnouncementsViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSMutableArray<Announcements*> *announcements;
@property (strong, nonatomic) NSString *searchFilter;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation AnnouncementsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.tvAnnouncements.tableFooterView = UIView.alloc.init;
    self.tfSearch.textFieldDelegate = self;
    self.announcements = NSMutableArray.alloc.init;
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.vStatusBar.backgroundColor = THEME_PRI_DARK;
        self.vNavBar.backgroundColor = THEME_PRI;
        self.tfSearch.highlightedBorderColor = THEME_SEC;
        [View setCornerRadiusByHeight:self.tfSearch cornerRadius:0.3];
    }
    [self onRefresh];
}

- (void)onRefresh {
    [super onRefresh];
    [self.announcements removeAllObjects];
    [self.announcements addObjectsFromArray:[Load announcements:self.app.db searchFilter:self.searchFilter isScheduled:YES]];
    [self.tvAnnouncements reloadData];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.announcements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AnnouncementsItemTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    Announcements *announcement = self.announcements[indexPath.row];
    Employees *createdBy = [Get employee:self.app.db employeeID:announcement.createdByID];
    item.ivPhoto.image = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [File saveImageFromURL:[File cachesPath:[NSString stringWithFormat:@"EMPLOYEE_PHOTO_%lld%@", createdBy.employeeID, @".png"]] url:createdBy.photoURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            item.ivPhoto.image = image;
        });
    });
    item.lName.font = [UIFont fontWithName:!announcement.isSeen ? @"ProximaNova-Semibold" : @"ProximaNova-Regular" size:item.lName.font.pointSize];
    item.lName.text = announcement.subject;
    item.lDetails.text = [NSString stringWithFormat:@"%@ %@ | %@ | %@", createdBy.firstName, createdBy.lastName, [Time formatTime:self.app.settingDisplayTimeFormat time:announcement.scheduledTime], [Time formatDate:self.app.settingDisplayDateFormat date:announcement.scheduledDate]];
    [item layoutIfNeeded];
    return item;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AnnouncementDetailsViewController *vcAnnouncementDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"vcAnnouncementDetails"];
    vcAnnouncementDetails.announcement = self.announcements[indexPath.row];
    [self.navigationController pushViewController:vcAnnouncementDetails animated:YES];
}

- (void)onTextFieldTextChanged:(UITextField *)textfield text:(NSString *)text {
    self.searchFilter = text;
    [self onRefresh];
}

@end
