#import "ViewController.h"
#import "SignatureView.h"

@protocol AddSignatureDelegate
@optional

- (void)onAddSignatureSave:(UIImage *)image;

@end

@interface AddSignatureViewController : ViewController

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet UIButton *btnClear;
@property (weak, nonatomic) IBOutlet SignatureView *vSignature;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;

@property (assign) id <AddSignatureDelegate> delegate;

@end
