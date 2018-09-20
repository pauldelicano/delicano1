#import "ViewController.h"
#import "Announcements+CoreDataClass.h"
#import "ScrollView.h"

@interface AnnouncementDetailsViewController : ViewController

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lSubject;
@property (weak, nonatomic) IBOutlet UILabel *lDetails;
@property (weak, nonatomic) IBOutlet UILabel *lMessage;

@property (strong, nonatomic) Announcements *announcement;

@end
