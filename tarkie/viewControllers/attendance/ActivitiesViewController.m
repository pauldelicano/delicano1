#import "ActivitiesViewController.h"
#import "AppDelegate.h"
#import "Load.h"
#import "Time.h"
#import "ActivitiesItemTableViewCell.h"

@interface ActivitiesViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *activities;
@property (nonatomic) BOOL viewWillAppear;

@end

@implementation ActivitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.tvActivities.tableFooterView = UIView.alloc.init;
    self.activities = NSMutableArray.alloc.init;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.viewWillAppear = YES;
    [self onRefresh];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.viewWillAppear = NO;
}

- (void)onRefresh {
    [super onRefresh];
    if(self.viewWillAppear) {
        [self.activities removeAllObjects];
        [self.activities addObjectsFromArray:[Load activities:self.app.db date:[Time getFormattedDate:DATE_FORMAT date:self.selectedDate]]];
        [self.tvActivities reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActivitiesItemTableViewCell *item = [tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    item.lEvent.text = self.activities[indexPath.row][@"Event"];
    item.lTime.text = self.activities[indexPath.row][@"Time"];
    [item layoutIfNeeded];
    return item;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    _selectedDate = selectedDate;
    [self onRefresh];
}

@end
