#import "ViewController.h"
#import "ScrollView.h"

@protocol NoGPSDelegate
@optional

- (void)onNoGPSCancel;
- (void)onNoGPSAcquired;
- (void)onNoGPSProceed;

@end

@interface NoGPSDialogViewController : ViewController

@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet UILabel *lSubject;
@property (weak, nonatomic) IBOutlet UILabel *lSpinner;
@property (weak, nonatomic) IBOutlet UILabel *lTimer;

@property (assign) id <NoGPSDelegate> delegate;

@end
