#import "ViewController.h"
#import "TimeIn+CoreDataClass.h"
#import "TimeOut+CoreDataClass.h"
#import "ScrollView.h"
#import "AddSignatureViewController.h"

@protocol AttendanceSummaryDelegate
@optional

- (void)onAttendanceSummaryCancel;
- (void)onAttendanceSummaryTimeOut:(UIImage *)image;

@end

@interface AttendanceSummaryViewController : ViewController<AddSignatureDelegate>

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet UILabel *lTimeInLabel;
@property (weak, nonatomic) IBOutlet UILabel *lTimeIn;
@property (weak, nonatomic) IBOutlet UILabel *lTimeOutLabel;
@property (weak, nonatomic) IBOutlet UILabel *lTimeOut;
@property (weak, nonatomic) IBOutlet UILabel *lTotalWorkHours;
@property (weak, nonatomic) IBOutlet UILabel *lTotalBreak;
@property (weak, nonatomic) IBOutlet UILabel *lTotalNetWorkHours;
@property (weak, nonatomic) IBOutlet UIButton *btnAddSignature;
@property (weak, nonatomic) IBOutlet UIImageView *ivSignature;
@property (weak, nonatomic) IBOutlet UIButton *btnEditSignature;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnTimeOut;

@property (assign) id <AttendanceSummaryDelegate> delegate;
@property (strong, nonatomic) NSString *timeIn, *timeOut;
@property (strong, nonatomic) UIImage *signature;
@property (nonatomic) NSTimeInterval workHours, breakHours;
@property (nonatomic) BOOL isHistory;

@end
