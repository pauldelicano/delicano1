#import "ViewController.h"
#import "Stores+CoreDataClass.h"
#import "ScrollView.h"
#import "TextField.h"
#import "TextView.h"

@protocol EditStoreDelegate
@optional

- (void)onEditStoreSave:(Stores *)store;

@end

@interface EditStoreViewController : ViewController

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet UILabel *lStoreName;
@property (weak, nonatomic) IBOutlet TextField *tfStoreName;
@property (weak, nonatomic) IBOutlet TextField *tfContactNumber;
@property (weak, nonatomic) IBOutlet TextField *tfEmail;
@property (weak, nonatomic) IBOutlet TextView *tfAddress;
@property (weak, nonatomic) IBOutlet UILabel *lShareWithMeIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnShareWithMe;
@property (weak, nonatomic) IBOutlet UILabel *lShareWithMyTeamIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnShareWithMyTeam;

@property (assign) id <EditStoreDelegate> delegate;
@property (strong, nonatomic) Stores *store;

@end
