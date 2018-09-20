#import "ViewController.h"
#import "ScrollView.h"
#import "TextField.h"
#import "LoadingDialogViewController.h"

@interface AuthorizationViewController : ViewController<LoadingDelegate>

@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet UIImageView *ivAppLogo;
@property (weak, nonatomic) IBOutlet TextField *tfAuthorizationCode;
@property (weak, nonatomic) IBOutlet UIButton *btnAuthorize;

@end
