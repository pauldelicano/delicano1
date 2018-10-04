#import "LoadingDialogViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "View.h"
#import "MessageDialogViewController.h"

@interface LoadingDialogViewController()

@property (strong, nonatomic) UIApplication *application;
@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) Process *process;
@property (strong, nonatomic) NSString *loadingSubject, *loadingMessage;
@property (nonatomic) UIBackgroundTaskIdentifier background;
@property (nonatomic) long progress;
@property (nonatomic) BOOL viewDidAppear;

@end

@implementation LoadingDialogViewController

static MessageDialogViewController *vcMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.application = UIApplication.sharedApplication;
    self.app = (AppDelegate *)self.application.delegate;
    self.process = Process.alloc.init;
    self.process.delegate = self;
    self.process.isCanceled = NO;
    self.viewDidAppear = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if(self.vContent.frame.size.height < self.vScroll.frame.size.height) {
        CGFloat inset = self.vScroll.frame.size.height - self.vContent.frame.size.height;
        self.vScroll.contentInset = UIEdgeInsetsMake(inset * 0.5, 0, inset * 0.5, 0);
    }
    else {
        self.vScroll.contentInset = UIEdgeInsetsZero;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.viewDidAppear) {
        self.viewDidAppear = YES;
        self.lSubject.textColor = THEME_PRI;
        self.vCircularProgressBar.textColor = THEME_PRI;
        self.vCircularProgressBar.progressTintColor = THEME_SEC;
        [View setCornerRadiusByWidth:self.lSubject.superview cornerRadius:0.075];
        [View setCornerRadiusByHeight:self.btnClose cornerRadius:1];
        [self onRefresh];
    }
}

- (void)onRefresh {
    [super onRefresh];
    switch(self.action) {
        case LOADING_ACTION_AUTHORIZE: {
            self.loadingSubject = @"Authorizing Device";
            self.loadingMessage = @"Authorize Device";
            self.background = [self.application beginBackgroundTaskWithExpirationHandler:^{
                [self.application endBackgroundTask:self.background];
                self.background = UIBackgroundTaskInvalid;
            }];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.process authorize:self.app.db params:self.params];
            });
            break;
        }
        case LOADING_ACTION_LOGIN: {
            self.loadingSubject = @"Validating Account";
            self.loadingMessage = @"Validate Account";
            self.background = [self.application beginBackgroundTaskWithExpirationHandler:^{
                [self.application endBackgroundTask:self.background];
                self.background = UIBackgroundTaskInvalid;
            }];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.process login:self.app.db params:self.params];
            });
            break;
        }
        case LOADING_ACTION_TIME_SECURITY: {
            self.loadingSubject = @"Validating Date and Time";
            self.loadingMessage = @"Validate Date and Time";
            self.background = [self.application beginBackgroundTaskWithExpirationHandler:^{
                [self.application endBackgroundTask:self.background];
                self.background = UIBackgroundTaskInvalid;
            }];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.process timeSecurity:self.app.db];
            });
            break;
        }
        case LOADING_ACTION_UPDATE_MASTER_FILE: {
            self.loadingSubject = @"Updating Master File";
            self.loadingMessage = @"Update Master File";
            self.background = [self.application beginBackgroundTaskWithExpirationHandler:^{
                [self.application endBackgroundTask:self.background];
                self.background = UIBackgroundTaskInvalid;
            }];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.process updateMasterFile:self.app.db isAttendance:self.app.moduleAttendance isVisits:self.app.moduleVisits isExpense:self.app.moduleExpense isInventory:self.app.moduleInventory isForms:self.app.moduleForms];
            });
            break;
        }
        case LOADING_ACTION_GET_PATCH: {
            self.loadingSubject = @"Patching Data";
            self.loadingMessage = @"Patch Data";
            self.background = [self.application beginBackgroundTaskWithExpirationHandler:^{
                [self.application endBackgroundTask:self.background];
                self.background = UIBackgroundTaskInvalid;
            }];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.process patch:self.app.db];
            });
            break;
        }
        case LOADING_ACTION_SYNC_PATCH: {
            self.loadingSubject = @"Patching Data";
            self.loadingMessage = @"Patch Data";
            self.background = [self.application beginBackgroundTaskWithExpirationHandler:^{
                [self.application endBackgroundTask:self.background];
                self.background = UIBackgroundTaskInvalid;
            }];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.process syncPatch:self.app.db];
            });
            break;
        }
        case LOADING_ACTION_SYNC_DATA: {
            self.loadingSubject = @"Syncing Data";
            self.loadingMessage = @"Sync Data";
            self.background = [self.application beginBackgroundTaskWithExpirationHandler:^{
                [self.application endBackgroundTask:self.background];
                self.background = UIBackgroundTaskInvalid;
            }];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.process syncData:self.app.db];
            });
            break;
        }
        case LOADING_ACTION_SEND_BACKUP_DATA: {
            self.loadingSubject = @"Sending Backup Data";
            self.loadingMessage = @"Send Backup Data";
            self.background = [self.application beginBackgroundTaskWithExpirationHandler:^{
                [self.application endBackgroundTask:self.background];
                self.background = UIBackgroundTaskInvalid;
            }];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.process sendBackupData:self.app.db];
            });
            break;
        }
    }
    self.lSubject.text = self.loadingSubject;
    self.progress = 0;
    if(self.vContent.frame.size.height < self.vScroll.frame.size.height) {
        CGFloat inset = self.vScroll.frame.size.height - self.vContent.frame.size.height;
        self.vScroll.contentInset = UIEdgeInsetsMake(inset * 0.5, 0, inset * 0.5, 0);
    }
    else {
        self.vScroll.contentInset = UIEdgeInsetsZero;
    }
}

- (IBAction)closeLoadingDialog:(id)sender {
    vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
    vcMessage.subject = self.loadingSubject;
    vcMessage.message = [NSString stringWithFormat:@"Are you sure you want to cancel %@?", self.loadingMessage];
    vcMessage.negativeTitle = @"No";
    vcMessage.negativeTarget = ^{
        [View removeChildViewController:vcMessage animated:YES];
    };
    vcMessage.positiveTitle = @"Yes";
    vcMessage.positiveTarget = ^{
        self.process.isCanceled = YES;
        [View removeChildViewController:vcMessage animated:YES];
        [View removeChildViewController:self animated:NO];
        [self.application endBackgroundTask:self.background];
        self.background = UIBackgroundTaskInvalid;
    };
    [View addChildViewController:self childViewController:vcMessage animated:YES];
}

- (void)onProcessResult:(NSString *)result {
    if(self.process.isCanceled) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progress++;
        self.vCircularProgressBar.progress = self.process.count > 0 ? (float)self.progress / (float)self.process.count : 0;
        [self.vCircularProgressBar setNeedsDisplay];
        self.lProgress.text = [NSString stringWithFormat:@"%ld/%ld", self.progress, self.process.count];
        if([result isEqualToString:@"ok"]) {
            [self.delegate onLoadingUpdate:self.action];
        }
        if(self.progress >= self.process.count || ![result isEqualToString:@"ok"]) {
            [View removeChildViewController:self animated:NO];
            [self.delegate onLoadingFinish:self.action result:result];
            [self.application endBackgroundTask:self.background];
            self.background = UIBackgroundTaskInvalid;
        }
    });
}

@end
