#import "CustomViewController.h"
#import "Announcements+CoreDataClass.h"

@interface AnnouncementDetailsViewController : CustomViewController

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UIScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lSubject;
@property (weak, nonatomic) IBOutlet UILabel *lDetails;
@property (weak, nonatomic) IBOutlet UILabel *lMessage;

@property (strong, nonatomic) Announcements *announcement;

@end
