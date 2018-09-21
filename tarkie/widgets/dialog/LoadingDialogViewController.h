#import "ViewController.h"
#import "Process.h"
#import "ScrollView.h"
#import "CircularProgressBar.h"

@protocol LoadingDelegate
@optional

- (void)onLoadingUpdate:(int)action;
- (void)onLoadingFinish:(int)action result:(NSString *)result;

@end

@interface LoadingDialogViewController : ViewController<ProcessDelegate>

@property (weak, nonatomic) IBOutlet ScrollView *vScroll;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet UILabel *lSubject;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet CircularProgressBar *vCircularProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *lProgress;

typedef enum {
    LOADING_ACTION_AUTHORIZE,
    LOADING_ACTION_LOGIN,
    LOADING_ACTION_TIME_SECURITY,
    LOADING_ACTION_UPDATE_MASTER_FILE,
    LOADING_ACTION_GET_PATCH,
    LOADING_ACTION_SYNC_PATCH,
    LOADING_ACTION_SYNC_DATA,
    LOADING_ACTION_SEND_BACKUP_DATA
} LoadingAction;

@property (assign) id <LoadingDelegate> delegate;
@property (nonatomic) LoadingAction action;
@property (strong, nonatomic) NSMutableDictionary *params;

@end
