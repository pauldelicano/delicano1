#import "CustomViewController.h"
#import "Process.h"

@protocol LoadingDelegate
@optional

- (void)onLoadingUpdate:(int)action;
- (void)onLoadingFinish:(int)action result:(NSString *)result;

@end

@interface LoadingDialogViewController : CustomViewController<ProcessDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lMessage;
@property (weak, nonatomic) IBOutlet UIProgressView *pvProgress;

typedef enum {
    LOADING_ACTION_AUTHORIZE,
    LOADING_ACTION_LOGIN,
    LOADING_ACTION_TIME_SECURITY,
    LOADING_ACTION_UPDATE_MASTER_FILE,
    LOADING_ACTION_SYNC_DATA,
    LOADING_ACTION_SEND_BACKUP_DATA
} LoadingAction;

@property (assign) id <LoadingDelegate> delegate;
@property (nonatomic) LoadingAction action;
@property (strong, nonatomic) NSMutableDictionary *params;

@end
