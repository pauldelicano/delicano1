#import "CustomViewController.h"

@protocol NoGPSDelegate
@optional

- (void)onNoGPSCancel;
- (void)onNoGPSAcquired;
- (void)onNoGPSProceed;

@end

@interface NoGPSDialogViewController : CustomViewController

@property (weak, nonatomic) IBOutlet UILabel *lSubject;
@property (weak, nonatomic) IBOutlet UILabel *lSpinner;
@property (weak, nonatomic) IBOutlet UILabel *lTimer;

@property (assign) id <NoGPSDelegate> delegate;

@end
