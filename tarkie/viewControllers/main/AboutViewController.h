#import "ViewController.h"
#import "ScrollView.h"

@interface AboutViewController : ViewController

@property (weak, nonatomic) IBOutlet UIView *vStatus;
@property (weak, nonatomic) IBOutlet UIImageView *ivAbout;
@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet UIImageView *ivLogo;
@property (weak, nonatomic) IBOutlet UILabel *lVersion;
@property (weak, nonatomic) IBOutlet UILabel *lAppURL;
@property (weak, nonatomic) IBOutlet UILabel *lFacebookURL;
@property (weak, nonatomic) IBOutlet UILabel *lAbout;

@end
