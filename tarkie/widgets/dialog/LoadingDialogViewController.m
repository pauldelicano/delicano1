#import "LoadingDialogViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "View.h"

@interface LoadingDialogViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) Process *process;
@property (strong, nonatomic) NSString *loadingMessage;
@property (nonatomic) long progress;
@property (nonatomic) BOOL viewDidAppear;

@end

@implementation LoadingDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.process = Process.alloc.init;
    self.process.delegate = self;
    self.viewDidAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.viewDidAppear) {
        self.viewDidAppear = YES;
        self.pvProgress.self.progressTintColor = THEME_SEC;
        [View setCornerRadiusByWidth:self.lMessage.superview cornerRadius:0.025];
        [View setCornerRadiusByHeight:self.pvProgress cornerRadius:1];
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    switch(self.action) {
        case LOADING_ACTION_AUTHORIZE: {
            self.loadingMessage = @"Authorizing device... Please wait.";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.process authorize:self.app.db params:self.params];
            });
            break;
        }
        case LOADING_ACTION_LOGIN: {
            self.loadingMessage = @"Logging in... Please wait.";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.process login:self.app.db params:self.params];
            });
            break;
        }
        case LOADING_ACTION_TIME_SECURITY: {
            self.loadingMessage = @"Getting server time... Please wait.";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.process timeSecurity:self.app.db];
            });
            break;
        }
        case LOADING_ACTION_UPDATE_MASTER_FILE: {
            self.loadingMessage = @"Updating master file... Please wait.";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.process updateMasterFile:self.app.db isAttendance:[Get isModuleEnabled:self.app.db moduleID:MODULE_ATTENDANCE] isVisits:[Get isModuleEnabled:self.app.db moduleID:MODULE_VISITS] isExpense:[Get isModuleEnabled:self.app.db moduleID:MODULE_EXPENSE] isInventory:[Get isModuleEnabled:self.app.db moduleID:MODULE_INVENTORY] isForms:[Get isModuleEnabled:self.app.db moduleID:MODULE_FORMS]];
            });
            break;
        }
        case LOADING_ACTION_SYNC_DATA: {
            self.loadingMessage = @"Syncing data... Please wait.";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.process syncData:self.app.db];
            });
            break;
        }
        case LOADING_ACTION_SEND_BACKUP_DATA: {
            self.loadingMessage = @"Sending backup data... Please wait.";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.process sendBackupData:self.app.db];
            });
            break;
        }
    }
    self.progress = 0;
    self.pvProgress.progress = self.progress;
    self.lMessage.text = self.loadingMessage;
}

- (void)onProcessResult:(NSString *)result {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progress++;
        self.pvProgress.progress = self.process.count > 0 ? (float)self.progress / (float)self.process.count : 0;
        if([result isEqualToString:@"ok"]) {
            [self.delegate onLoadingUpdate:self.action];
        }
        if(self.progress >= self.process.count || ![result isEqualToString:@"ok"]) {
            [View removeView:self.view animated:NO];
            [self.delegate onLoadingFinish:self.action result:result];
        }
    });
}

@end
