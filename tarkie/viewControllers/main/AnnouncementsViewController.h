#import "ViewController.h"
#import "TextField.h"

@interface AnnouncementsViewController : ViewController<UITableViewDataSource, UITableViewDelegate, TextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet TextField *tfSearch;
@property (weak, nonatomic) IBOutlet UITableView *tvAnnouncements;

@end
