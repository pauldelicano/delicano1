#import "ViewController.h"
#import "ScrollView.h"

@interface MessageDialogViewController : ViewController

@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet UILabel *lSubject;
@property (weak, nonatomic) IBOutlet UILabel *lMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnNegative;
@property (weak, nonatomic) IBOutlet UIButton *btnPositive;

@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSAttributedString *attributedMessage;
@property (strong, nonatomic) NSString *negativeTitle;
@property (strong, nonatomic) id negativeTarget;
@property (strong, nonatomic) NSString *positiveTitle;
@property (strong, nonatomic) id positiveTarget;

@end
