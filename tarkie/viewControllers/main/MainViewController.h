#import "CustomViewController.h"
#import "DrawerViewController.h"
#import "PageBarCollectionView.h"
#import "LoadingDialogViewController.h"
#import "NoGPSDialogViewController.h"
#import "DropDownDialogViewController.h"
#import "CameraViewController.h"
#import "AttendanceSummaryViewController.h"

@interface MainViewController : CustomViewController<DrawerDelegate, PageBarDelegate, LoadingDelegate, NoGPSDelegate, DropDownDelegate, CameraDelegate, AttendanceSummaryDelegate>

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet PageBarCollectionView *cvPageBar;
@property (weak, nonatomic) IBOutlet UIView *vBottomBar;

@property (weak, nonatomic) IBOutlet UIView *vNavBarButtonsHome;
@property (weak, nonatomic) IBOutlet UIButton *btnNavBarButtonsHomeAnnouncements;
@property (weak, nonatomic) IBOutlet UILabel *lNavBarButtonsHomeAnnouncementsCount;
@property (weak, nonatomic) IBOutlet UIButton *btnNavBarButtonsHomeSync;
@property (weak, nonatomic) IBOutlet UILabel *lNavBarButtonsHomeSyncCount;

@property (weak, nonatomic) IBOutlet UIView *vNavBarButtonsVisits;
@property (weak, nonatomic) IBOutlet UIButton *btnNavBarButtonsVisitsDate;
@property (weak, nonatomic) IBOutlet UIButton *btnNavBarButtonsVisitsAddVisit;

@property (weak, nonatomic) IBOutlet UIView *vNavBarButtonsExpense;
@property (weak, nonatomic) IBOutlet UIButton *btnNavBarButtonsExpenseNewReport;

@property (weak, nonatomic) IBOutlet UIView *vNavBarButtonsInventory;

@property (weak, nonatomic) IBOutlet UIView *vNavBarButtonsForms;
@property (weak, nonatomic) IBOutlet UIButton *btnNavBarButtonsFormsSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnNavBarButtonsFormsSelect;

@property (weak, nonatomic) IBOutlet UIView *vNavBarButtonsHistory;
@property (weak, nonatomic) IBOutlet UILabel *lNavBarButtonsHistoryDate;
@property (weak, nonatomic) IBOutlet UIButton *btnNavBarButtonsHistoryDate;

@property (nonatomic) BOOL isTimeIn;

- (BOOL)applicationDidBecomeActive;
- (BOOL)gpsRequest;
- (BOOL)cameraRequest;

- (void)updateUnSeenAnnouncementsCount;
- (void)updateSyncDataCount;

@end
