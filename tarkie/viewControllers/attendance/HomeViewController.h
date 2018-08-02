#import "CustomViewController.h"

@interface HomeViewController : CustomViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet UIImageView *ivCompanyLogo;
@property (weak, nonatomic) IBOutlet UIView *vAttendance;
@property (weak, nonatomic) IBOutlet UILabel *lTimeAttendance;
@property (weak, nonatomic) IBOutlet UILabel *lDateAttendance;
@property (weak, nonatomic) IBOutlet UIButton *btnAttendance;
@property (weak, nonatomic) IBOutlet UIView *vVisits;
@property (weak, nonatomic) IBOutlet UIView *vVisitsHeader;
@property (weak, nonatomic) IBOutlet UITableView *tvVisits;
@property (weak, nonatomic) IBOutlet UIButton *btnVisits;
@property (weak, nonatomic) IBOutlet UIView *vForms;
@property (weak, nonatomic) IBOutlet UIView *vFormsHeader;
@property (weak, nonatomic) IBOutlet UITableView *tvForms;
@property (weak, nonatomic) IBOutlet UIView *vInventory;
@property (weak, nonatomic) IBOutlet UIView *vInventoryHeader;
@property (weak, nonatomic) IBOutlet UITableView *tvInventory;
@property (weak, nonatomic) IBOutlet UIButton *btnExpense;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vAttendanceHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vVisitsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tvVisitsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnVisitsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vFormsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tvFormsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vInventoryHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tvInventoryHeight;

@end
