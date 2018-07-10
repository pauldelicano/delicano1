#import "CustomViewController.h"
#import "TextField.h"
#import "LoadingDialogViewController.h"

@interface LoginViewController : CustomViewController<LoadingDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *ivCompanyLogo;
@property (weak, nonatomic) IBOutlet TextField *tfUsername;
@property (weak, nonatomic) IBOutlet TextField *tfPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@end
