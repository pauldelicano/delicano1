#import "ViewController.h"
#import "LayoutConstraint.h"
#import "ScrollView.h"

@interface HomeViewController : ViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
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
@property (weak, nonatomic) IBOutlet LayoutConstraint *vAttendanceHeight;
@property (weak, nonatomic) IBOutlet LayoutConstraint *vVisitsHeight;
@property (weak, nonatomic) IBOutlet LayoutConstraint *tvVisitsHeight;
@property (weak, nonatomic) IBOutlet LayoutConstraint *vFormsHeight;
@property (weak, nonatomic) IBOutlet LayoutConstraint *tvFormsHeight;
@property (weak, nonatomic) IBOutlet LayoutConstraint *vInventoryHeight;
@property (weak, nonatomic) IBOutlet LayoutConstraint *tvInventoryHeight;

@end
