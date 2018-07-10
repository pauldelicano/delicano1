#import "CustomViewController.h"
#import "TextField.h"
#import "LoadingDialogViewController.h"

@interface AuthorizationViewController : CustomViewController<LoadingDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *ivAppLogo;
@property (weak, nonatomic) IBOutlet TextField *tfAuthorizationCode;
@property (weak, nonatomic) IBOutlet UIButton *btnAuthorize;

@end
