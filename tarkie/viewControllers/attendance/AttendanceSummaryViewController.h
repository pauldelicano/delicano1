#import "CustomViewController.h"
#import "TimeIn+CoreDataClass.h"
#import "TimeOut+CoreDataClass.h"
#import "AddSignatureViewController.h"

@protocol AttendanceSummaryDelegate
@optional

- (void)onAttendanceSummaryCancel;
- (void)onAttendanceSummaryTimeOut:(UIImage *)image;

@end

@interface AttendanceSummaryViewController : CustomViewController<AddSignatureDelegate>

@property (weak, nonatomic) IBOutlet UIView *vStatusBar;
@property (weak, nonatomic) IBOutlet UIView *vNavBar;
@property (weak, nonatomic) IBOutlet UIScrollView *vScroll;
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
@property (strong, nonatomic) TimeIn *timeIn;
@property (strong, nonatomic) TimeOut *timeOut;
@property (strong, nonatomic) NSDate *timeOutPreview;


@end
