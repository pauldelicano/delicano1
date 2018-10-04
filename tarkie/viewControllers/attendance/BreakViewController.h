#import "ViewController.h"
#import "BreakIn+CoreDataClass.h"
#import "ScrollView.h"

@protocol BreakDelegate
@optional

- (void)onBreakCancel;
- (void)onBreakDone:(BreakIn *)breakIn;

@end

@interface BreakViewController : ViewController

@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UILabel *lDuration;
@property (weak, nonatomic) IBOutlet UILabel *lRemaining;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@property (assign) id <BreakDelegate> delegate;
@property (strong, nonatomic) BreakIn *breakIn;

@end
