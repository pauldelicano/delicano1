#import "ViewController.h"
#import "ScrollView.h"
#import "TextField.h"
#import "LoadingDialogViewController.h"

@interface LoginViewController : ViewController<LoadingDelegate>

@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet UIImageView *ivCompanyLogo;
@property (weak, nonatomic) IBOutlet TextField *tfUsername;
@property (weak, nonatomic) IBOutlet TextField *tfPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@end
