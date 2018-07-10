#import "AddSignatureViewController.h"
#import "App.h"
#import "View.h"

@interface AddSignatureViewController()

@property (nonatomic) BOOL viewWillAppear;

@end

@implementation AddSignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.viewWillAppear) {
        self.viewWillAppear = YES;
        self.vStatusBar.backgroundColor = THEME_PRI_DARK;
        self.vNavBar.backgroundColor = THEME_PRI;
        [self.btnClear setTitleColor:THEME_SEC forState:UIControlStateNormal];
        self.btnSave.backgroundColor = THEME_SEC;
        [View setCornerRadiusByHeight:self.btnClear cornerRadius:0.3];
        CALayer *layer = self.btnClear.layer;
        layer.borderColor = THEME_SEC.CGColor;
        layer.borderWidth = (1.0f / 568) * UIScreen.mainScreen.bounds.size.height;
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clear:(id)sender {
    [self.vSignature clear];
}

- (IBAction)cancel:(id)sender {
    [self back:self];
}

- (IBAction)save:(id)sender {
    self.vSignature.backgroundColor = UIColor.clearColor;
    UIGraphicsBeginImageContext(self.vSignature.bounds.size);
    [self.vSignature.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *signature = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.vSignature.backgroundColor = [UIColor colorNamed:@"Yellow100"];
    if(UIImagePNGRepresentation(signature).length > 1062) {
        [self back:self];
        [self.delegate onAddSignatureSave:signature];
    }
}

@end
