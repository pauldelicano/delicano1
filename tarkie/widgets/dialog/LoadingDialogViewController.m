#import "LoadingDialogViewController.h"
#import "AppDelegate.h"
#import "App.h"
#import "Get.h"
#import "Load.h"
#import "Update.h"
#import "Image.h"
#import "View.h"
#import "Time.h"

@interface LoadingDialogViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) Process *process;
@property (strong, nonatomic) NSString *loadingMessage;
@property (nonatomic) long progress, maxProgress, userID;
@property (nonatomic) BOOL viewDidAppear;

@end

@implementation LoadingDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.process = Process.alloc.init;
    self.process.delegate = self;
    self.userID = [Get userID:self.app.db];
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
            [self.process authorize:self.app.db params:self.params];
            break;
        }
        case LOADING_ACTION_LOGIN: {
            self.loadingMessage = @"Logging in... Please wait.";
            [self.process login:self.app.db params:self.params];
            break;
        }
        case LOADING_ACTION_TIME_SECURITY: {
            self.loadingMessage = @"Getting server time... Please wait.";
            [self.process timeSecurity:self.app.db];
            break;
        }
        case LOADING_ACTION_UPDATE_MASTER_FILE: {
            self.loadingMessage = @"Updating master file... Please wait.";
            [self.process updateMasterFile:self.app.db isAttendance:[Get isModuleEnabled:self.app.db moduleID:MODULE_ATTENDANCE] isVisits:[Get isModuleEnabled:self.app.db moduleID:MODULE_VISITS] isExpense:[Get isModuleEnabled:self.app.db moduleID:MODULE_EXPENSE] isInventory:[Get isModuleEnabled:self.app.db moduleID:MODULE_INVENTORY] isForms:[Get isModuleEnabled:self.app.db moduleID:MODULE_FORMS]];
            break;
        }
        case LOADING_ACTION_SYNC_DATA: {
            self.loadingMessage = @"Syncing data... Please wait.";
            [self.process syncData:self.app.db];
            break;
        }
        case LOADING_ACTION_UPDATE_SCHEDULE: {
            self.loadingMessage = @"Syncing data... Please wait.";
            [self.process getSchedule:self.app.db];
            break;
        }
        case LOADING_ACTION_SEND_BACKUP_DATA: {
            self.loadingMessage = @"Sending backup data... Please wait.";
            [self.process sendBackupData:self.app.db];
            break;
        }
    }
    self.progress = 0;
    self.pvProgress.self.progress = self.progress;
    self.maxProgress = [self.process tasksCount];
    self.lMessage.text = self.loadingMessage;
    [self.process start];
}

- (void)onProcessResult:(NSString *)action params:(NSDictionary *)params result:(NSDictionary *)result {
    NSLog(@"paul: %@", action);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progress++;
        self.pvProgress.self.progress = self.maxProgress > 0 ? (float)self.progress / (float)self.maxProgress : 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.75 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            NSDictionary *init = [[result objectForKey:@"init"] lastObject];
            NSString *status = [init objectForKey:@"status"];
            NSString *message = nil;
            if([status isEqualToString:@"error"]) {
                message = [init objectForKey:@"message"];
            }
            if(message == nil) {
                NSArray<NSDictionary *> *data = [result objectForKey:@"data"];
                if(data != nil) {
                    if([action isEqualToString:@"authorization-request"]) {
                        NSString *deviceID = [self.params objectForKey:@"tablet_id"];
                        Device *device = [Get device:self.app.db];
                        if(device == nil) {
                            device = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:self.app.db];
                        }
                        device.deviceID = deviceID;
                        device.authorizationCode = [self.params objectForKey:@"authorization_code"];
                        device.apiKey = [data.lastObject objectForKey:@"api_key"];
                        SyncBatch *syncBatch = [Get syncBatch:self.app.db];
                        if(syncBatch == nil) {
                            syncBatch = [NSEntityDescription insertNewObjectForEntityForName:@"SyncBatch" inManagedObjectContext:self.app.db];
                        }
                        syncBatch.syncBatchID = [[data.lastObject objectForKey:@"sync_batch_id"] stringValue];
                        NSDate *currentDate = NSDate.date;
                        syncBatch.date = [Time formatDate:DATE_FORMAT date:currentDate];
                        syncBatch.time = [Time formatDate:TIME_FORMAT date:currentDate];
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                        if(message == nil) {
                            self.loadingMessage = @"Getting company details... Please wait.";
                            self.params = NSMutableDictionary.alloc.init;
                            [self.params setObject:[Get apiKey:self.app.db] forKey:@"api_key"];
                            [self.process getCompany:self.app.db];
                        }
                    }
                    if([action isEqualToString:@"get-company"]) {
                        Company *company = [Get company:self.app.db];
                        if(company == nil) {
                            company = [NSEntityDescription insertNewObjectForEntityForName:@"Company" inManagedObjectContext:self.app.db];
                        }
                        company.companyID = [[data.lastObject objectForKey:@"company_id"] longLongValue];
                        company.name = [data.lastObject objectForKey:@"company_name"];
                        company.logoURL = [data.lastObject objectForKey:@"company_logo"];
                        NSArray *modules = [data.lastObject objectForKey:@"modules"];
                        for(int x = 1; x <= MODULE_FORMS; x++) {
                            Modules *module = [Get module:self.app.db moduleID:x];
                            if(module == nil) {
                                module = [NSEntityDescription insertNewObjectForEntityForName:@"Modules" inManagedObjectContext:self.app.db];
                                module.moduleID = x;
                            }
                            module.name = nil;
                            module.isEnabled = NO;
                            switch(x) {
                                case MODULE_ATTENDANCE: {
                                    module.name = @"attendance";
                                    break;
                                }
                                case MODULE_VISITS: {
                                    module.name = @"itinerary";
                                    break;
                                }
                                case MODULE_EXPENSE: {
                                    module.name = @"expense";
                                    break;
                                }
                                case MODULE_INVENTORY: {
                                    module.name = @"inventory";
                                    break;
                                }
                                case MODULE_FORMS: {
                                    module.name = @"forms";
                                    break;
                                }
                            }
                            if(module.name != nil) {
                                module.isEnabled = [modules indexOfObject:module.name] != -1;
                            }
                        }
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                        if(message == nil) {
                            [Image deleteFromCaches:[NSString stringWithFormat:@"COMPANY_LOGO_%lld%@", company.companyID, @".png"]];
                        }
                    }
                    if([action isEqualToString:@"login"]) {
                        long userID = [[data.lastObject objectForKey:@"employee_id"] longLongValue];
                        Users *user = [Get user:self.app.db];
                        if(user == nil) {
                            user = [NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:self.app.db];
                        }
                        user.userID = userID;
                        NSDate *currentDate = NSDate.date;
                        user.date = [Time formatDate:DATE_FORMAT date:currentDate];
                        user.time = [Time formatDate:TIME_FORMAT date:currentDate];
                        user.isLogout = NO;
                        Employees *employee = [Get employee:self.app.db employeeID:userID];
                        if(employee == nil) {
                            employee = [NSEntityDescription insertNewObjectForEntityForName:@"Employees" inManagedObjectContext:self.app.db];
                            employee.employeeID = userID;
                        }
                        employee.firstName = [data.lastObject objectForKey:@"firstname"];
                        employee.lastName = [data.lastObject objectForKey:@"lastname"];
                        employee.teamID = [[data.lastObject objectForKey:@"team_id"] longLongValue];
                        employee.employeeNumber = [data.lastObject objectForKey:@"employee_number"];
                        employee.isActive = YES;
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                    if([action isEqualToString:@"get-employee-details"]) {
                        [Update employeesDeactivate:self.app.db];
                        for(int x = 0; x < data.count; x++) {
                            long employeeID = [[data[x] objectForKey:@"employee_id"] longLongValue];
                            Employees *employee = [Get employee:self.app.db employeeID:employeeID];
                            if(employee == nil) {
                                employee = [NSEntityDescription insertNewObjectForEntityForName:@"Employees" inManagedObjectContext:self.app.db];
                                employee.employeeID = employeeID;
                            }
                            employee.firstName = [data[x] objectForKey:@"firstname"];
                            employee.lastName = [data[x] objectForKey:@"lastname"];
                            employee.employeeNumber = [data[x] objectForKey:@"employee_number"];
                            employee.photoURL = [data[x] objectForKey:@"picture_url"];
                            employee.teamID = [[data[x] objectForKey:@"team_id"] longLongValue];
                            employee.storeID = [[data[x] objectForKey:@"store_id"] longLongValue];
                            employee.withLate = [[data[x] objectForKey:@"eligible_for_late"] intValue] == 1;
                            employee.withOvertime = [[data[x] objectForKey:@"eligible_for_ot"] intValue] == 1;
                            employee.isApprover = [[data[x] objectForKey:@"is_approver"] intValue] == 1;
                            employee.isActive = [[data[x] objectForKey:@"is_active"] isEqualToString:@"yes"];
                        }
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                        if(message == nil) {
                            Employees *employee = [Get employee:self.app.db employeeID:self.userID];
                            [Image deleteFromCaches:[NSString stringWithFormat:@"EMPLOYEE_PHOTO_%lld%@", employee.employeeID, @".png"]];
                        }
                    }
                    if([action isEqualToString:@"get-settings"]) {
                        for(int x = 0; x < data.count; x++) {
                            long settingID = [[data[x] objectForKey:@"settings_id"] longLongValue];
                            Settings *setting = [Get setting:self.app.db settingID:settingID];
                            if(setting == nil) {
                                setting = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:self.app.db];
                                setting.settingID = settingID;
                            }
                            setting.name = [data[x] objectForKey:@"settings_code"];
                            NSNumber *teamID = [self.params objectForKey:@"team_id"];
                            SettingsTeams *settingTeam = [Get settingTeam:self.app.db settingID:settingID teamID:teamID.longLongValue];
                            if(settingTeam == nil) {
                                settingTeam = [NSEntityDescription insertNewObjectForEntityForName:@"SettingsTeams" inManagedObjectContext:self.app.db];
                                settingTeam.settingID = settingID;
                                settingTeam.teamID = teamID.longLongValue;
                            }
                            NSString *value = [data[x] objectForKey:@"settings_value"];
                            if(![value isEqualToString:@"no"]) {
                                id team = [data[x] objectForKey:@"team_id"];
                                if(([team isKindOfClass:NSArray.class] && [team indexOfObject:teamID] == -1) || ([team isKindOfClass:NSString.class] && ![team isEqualToString:@"allteams"])) {
                                    value = @"no";
                                }
                            }
                            settingTeam.value = value;
                        }
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                    if([action isEqualToString:@"get-naming-convention"]) {
                        for(int x = 1; x <= CONVENTION_SALES; x++) {
                            Conventions *convention = [Get convention:self.app.db conventionID:x];
                            if(convention == nil) {
                                convention = [NSEntityDescription insertNewObjectForEntityForName:@"Conventions" inManagedObjectContext:self.app.db];
                                convention.conventionID = x;
                            }
                            convention.name = nil;
                            convention.value = nil;
                            switch(x) {
                                case CONVENTION_EMPLOYEES: {
                                    convention.name = @"employees";
                                    convention.value = @"employees";
                                    break;
                                }
                                case CONVENTION_STORES: {
                                    convention.name = @"stores";
                                    convention.value = @"stores";
                                    break;
                                }
                                case CONVENTION_TIME_IN: {
                                    convention.name = @"startday";
                                    convention.value = @"time in";
                                    break;
                                }
                                case CONVENTION_TIME_OUT: {
                                    convention.name = @"endday";
                                    convention.value = @"time out";
                                    break;
                                }
                                case CONVENTION_VISITS: {
                                    convention.name = @"visits";
                                    convention.value = @"visits";
                                    break;
                                }
                                case CONVENTION_TEAMS: {
                                    convention.name = @"teams";
                                    convention.value = @"teams";
                                    break;
                                }
                                case CONVENTION_INVOICE: {
                                    convention.name = @"invoice";
                                    convention.value = @"invoice";
                                    break;
                                }
                                case CONVENTION_DELIVERIES: {
                                    convention.name = @"deliveries";
                                    convention.value = @"deliveries";
                                    break;
                                }
                                case CONVENTION_RETURNS: {
                                    convention.name = @"returns";
                                    convention.value = @"returns";
                                    break;
                                }
                                case CONVENTION_SALES: {
                                    convention.name = @"sales";
                                    convention.value = @"sales";
                                    break;
                                }
                            }
                            if(convention.name != nil) {
                                NSString *value = [data.lastObject objectForKey:convention.name];
                                if(value.length > 0 && ![value isEqualToString:@"keep"]) {
                                    convention.value = value;
                                }
                            }
                            if(![Update save:self.app.db]) {
                                message = @"";
                            }
                        }
                    }
                    if([action isEqualToString:@"get-alert-types"]) {
                        for(int x = 0; x < data.count; x++) {
                            long alertTypeID = [[data[x] objectForKey:@"alert_type_id"] longLongValue];
                            AlertTypes *alertType = [Get alertType:self.app.db alertTypeID:alertTypeID];
                            if(alertType == nil) {
                                alertType = [NSEntityDescription insertNewObjectForEntityForName:@"AlertTypes" inManagedObjectContext:self.app.db];
                                alertType.alertTypeID = alertTypeID;
                            }
                            alertType.name = [data[x] objectForKey:@"alert_type"];
                        }
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                    if([action isEqualToString:@"get-server-time"]) {
                        TimeSecurity *timeSecurity = [Get timeSecurity:self.app.db];
                        if(timeSecurity == nil) {
                            timeSecurity = [NSEntityDescription insertNewObjectForEntityForName:@"TimeSecurity" inManagedObjectContext:self.app.db];
                        }
                        NSDate *server = [Time getDateFromString:[data.lastObject objectForKey:@"date_time"]];
                        timeSecurity.serverDate = [Time formatDate:DATE_FORMAT date:server];
                        timeSecurity.serverTime = [Time formatDate:TIME_FORMAT date:server];
                        timeSecurity.upTime = NSProcessInfo.processInfo.systemUptime;
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                    if([action isEqualToString:@"get-sync-batch-id"]) {  
                        SyncBatch *syncBatch = [Get syncBatch:self.app.db];
                        if(syncBatch == nil) {
                            syncBatch = [NSEntityDescription insertNewObjectForEntityForName:@"SyncBatch" inManagedObjectContext:self.app.db];
                        }
                        syncBatch.syncBatchID = [[data.lastObject objectForKey:@"sync_batch_id"] stringValue];
                        NSDate *currentDate = NSDate.date;
                        syncBatch.date = [Time formatDate:DATE_FORMAT date:currentDate];
                        syncBatch.time = [Time formatDate:TIME_FORMAT date:currentDate];
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                    if([action isEqualToString:@"get-announcements-for-app"]) {
                        [Update announcementsDeactivate:self.app.db];
                        for(int x = 0; x < data.count; x++) {
                            long announcementID = [[data[x] objectForKey:@"announcement_id"] longLongValue];
                            Announcements *announcement = [Get announcement:self.app.db announcementID:announcementID];
                            if(announcement == nil) {
                                announcement = [NSEntityDescription insertNewObjectForEntityForName:@"Announcements" inManagedObjectContext:self.app.db];
                                announcement.announcementID = announcementID;
                                announcement.isSeen = NO;
                                if([[Time getDateFromString:[NSString stringWithFormat:@"%@ %@", [data[x] objectForKey:@"date_to_show"], [data[x] objectForKey:@"time_to_show"]]] earlierDate:NSDate.date]) {
                                    announcement.isSeen = YES;
                                }
                            }
                            else {
                                if(![announcement.subject isEqualToString:[data[x] objectForKey:@"title"]] || ![announcement.message isEqualToString:[data[x] objectForKey:@"body"]] || ![announcement.scheduledDate isEqualToString:[data[x] objectForKey:@"date_to_show"]] || ![announcement.scheduledTime isEqualToString:[data[x] objectForKey:@"time_to_show"]]) {
                                    announcement.isSeen = NO;
                                }
                            }
                            announcement.subject = [data[x] objectForKey:@"title"];
                            announcement.message = [data[x] objectForKey:@"body"];
                            announcement.createdDate = [data[x] objectForKey:@"date_created"];
                            announcement.createdTime = [data[x] objectForKey:@"time_created"];
                            announcement.scheduledDate = [data[x] objectForKey:@"date_to_show"];
                            announcement.scheduledTime = [data[x] objectForKey:@"time_to_show"];
                            announcement.employeeID = [Get userID:self.app.db];
                            announcement.createdByID = [[data[x] objectForKey:@"employee_id"] longLongValue];
                            announcement.isActive = [[data[x] objectForKey:@"is_active"] intValue] == 1;
                        }
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                    if([action isEqualToString:@"get-stores-for-app"]) {
                        [Update storesDeactivate:self.app.db];
                        Sequences *sequence = [Get sequence:self.app.db];
                        for(int x = 0; x < data.count; x++) {
                            long webStoreID = [[data[x] objectForKey:@"store_id"] longLongValue];
                            Stores *store = [Get store:self.app.db webStoreID:webStoreID];
                            if(store == nil) {
                                store = [NSEntityDescription insertNewObjectForEntityForName:@"Stores" inManagedObjectContext:self.app.db];
                                sequence.stores += 1;
                                store.storeID = sequence.stores;
                                store.webStoreID = webStoreID;
                                store.isFromWeb = YES;
                            }
                            store.employeeID = self.userID;
                            store.name = [data[x] objectForKey:@"store_name"];
                            store.shortName = [data[x] objectForKey:@"short_name"];
                            store.contactNumber = [data[x] objectForKey:@"contact_number"];
                            store.email = [data[x] objectForKey:@"email"];
                            store.address = [data[x] objectForKey:@"address"];
                            store.class1ID = [[data[x] objectForKey:@"store_class_1_id"] longLongValue];
                            store.class2ID = [[data[x] objectForKey:@"store_class_2_id"] longLongValue];
                            store.class3ID = [[data[x] objectForKey:@"store_class_3_id"] longLongValue];
                            store.latitude = [[data[x] objectForKey:@"latitude"] doubleValue];
                            store.longitude = [[data[x] objectForKey:@"longitude"] doubleValue];
                            store.geoFenceRadius = [[data[x] objectForKey:@"geo_fence_radius"] longLongValue];
                            store.isTag = YES;
                            store.isActive = [[data[x] objectForKey:@"is_active"] isEqualToString:@"1"];
                            store.isSync = YES;
                            store.isUpdate = YES;
                            store.isWebUpdate = YES;
                        }
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                    if([action isEqualToString:@"get-store-contact-person-for-app"]) {
                        [Update storeContactsDeactivate:self.app.db];
                        Sequences *sequence = [Get sequence:self.app.db];
                        for(int x = 0; x < data.count; x++) {
                            long webStoreContactID = [[data[x] objectForKey:@"contact_id"] longLongValue];
                            StoreContacts *storeContact = [Get storeContact:self.app.db webStoreContactID:webStoreContactID];
                            if(storeContact == nil) {
                                storeContact = [NSEntityDescription insertNewObjectForEntityForName:@"StoreContacts" inManagedObjectContext:self.app.db];
                                sequence.storeContacts += 1;
                                storeContact.storeContactID = sequence.stores;
                                storeContact.webStoreContactID = webStoreContactID;
                                storeContact.employeeID = self.userID;
                                storeContact.isFromWeb = YES;
                            }
                            storeContact.storeID = [[data[x] objectForKey:@"store_id"] longLongValue];
                            storeContact.name = [data[x] objectForKey:@"name"];
                            storeContact.designation = [data[x] objectForKey:@"designation"];
                            storeContact.email = [data[x] objectForKey:@"email"];
                            storeContact.birthdate = [data[x] objectForKey:@"birthdate"];
                            storeContact.mobileNumber = [data[x] objectForKey:@"mobile"];
                            storeContact.landlineNumber = [data[x] objectForKey:@"telephone"];
                            storeContact.remarks = [data[x] objectForKey:@"remarks"];
                            storeContact.isActive = YES;
                            storeContact.isSync = YES;
                            storeContact.isUpdate = YES;
                            storeContact.isWebUpdate = YES;
                        }
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                    if([action isEqualToString:@"get-schedule-time"]) {
                        [Update scheduleTimesDeactivate:self.app.db];
                        for(int x = 0; x < data.count; x++) {
                            long scheduleTimeID = [[data[x] objectForKey:@"time_schedule_id"] longLongValue];
                            ScheduleTimes *scheduleTime = [Get scheduleTime:self.app.db scheduleTimeID:scheduleTimeID];
                            if(scheduleTime == nil) {
                                scheduleTime = [NSEntityDescription insertNewObjectForEntityForName:@"ScheduleTimes" inManagedObjectContext:self.app.db];
                                scheduleTime.scheduleTimeID = scheduleTimeID;
                            }
                            scheduleTime.timeIn = [data[x] objectForKey:@"time_in"];
                            scheduleTime.timeOut = [data[x] objectForKey:@"time_out"];
                            scheduleTime.isActive = [[data[x] objectForKey:@"is_active"] isEqualToString:@"1"];
                        }
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                    if([action isEqualToString:@"get-schedule"]) {
                        if(self.action == LOADING_ACTION_UPDATE_MASTER_FILE) {
                            [Update schedulesDeactivate:self.app.db];
                        }
                        Sequences *sequence = [Get sequence:self.app.db];
                        for(int x = 0; x < data.count; x++) {
                            long webScheduleID = [[data[x] objectForKey:@"schedule_id"] longLongValue];
                            NSString *scheduleDate = [data[x] objectForKey:@"date"];
                            Schedules *schedule = [Get schedule:self.app.db webScheduleID:webScheduleID scheduleDate:scheduleDate];
                            if(schedule == nil) {
                                schedule = [NSEntityDescription insertNewObjectForEntityForName:@"Schedules" inManagedObjectContext:self.app.db];
                                sequence.schedules += 1;
                                schedule.scheduleID = sequence.schedules;
                                NSDate *currentDate = NSDate.date;
                                schedule.date = [Time formatDate:DATE_FORMAT date:currentDate];
                                schedule.time = [Time formatDate:TIME_FORMAT date:currentDate];
                                schedule.employeeID = self.userID;
                                schedule.isFromWeb = YES;
                            }
                            if(self.action == LOADING_ACTION_UPDATE_MASTER_FILE) {
                                schedule.webScheduleID = webScheduleID;
                                schedule.scheduleDate = scheduleDate;
                                schedule.timeIn = [data[x] objectForKey:@"time_in"];
                                schedule.timeOut = [data[x] objectForKey:@"time_out"];
                                schedule.shiftTypeID = [[data[x] objectForKey:@"shift_type_id"] longLongValue];
                                schedule.isDayOff = [[data[x] objectForKey:@"is_day_off"] isEqualToString:@"1"];
                                schedule.isActive = YES;
                            }
                            schedule.isSync = YES;
                        }
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                    if([action isEqualToString:@"get-breaks"]) {
                        for(int x = 0; x < data.count; x++) {
                            long breakTypeID = [[data[x] objectForKey:@"break_id"] longLongValue];
                            BreakTypes *breakType = [Get breakType:self.app.db breakTypeID:breakTypeID];
                            if(breakType == nil) {
                                breakType = [NSEntityDescription insertNewObjectForEntityForName:@"BreakTypes" inManagedObjectContext:self.app.db];
                                breakType.breakTypeID = breakTypeID;
                            }
                            breakType.name = [data[x] objectForKey:@"name"];
                            breakType.duration = [[data[x] objectForKey:@"duration"] longLongValue];
                        }
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                    if([action isEqualToString:@"get-overtime-reasons"]) {
                        for(int x = 0; x < data.count; x++) {
                            long overtimeReasonID = [[data[x] objectForKey:@"overtime_reason_id"] longLongValue];
                            OvertimeReasons *overtimeReason = [Get overtimeReason:self.app.db overtimeReasonID:overtimeReasonID];
                            if(overtimeReason == nil) {
                                overtimeReason = [NSEntityDescription insertNewObjectForEntityForName:@"OvertimeReasons" inManagedObjectContext:self.app.db];
                                overtimeReason.overtimeReasonID = overtimeReasonID;
                            }
                            overtimeReason.name = [data[x] objectForKey:@"name"];
                        }
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                    if([action isEqualToString:@"get-itinerary"]) {
                        Sequences *sequence = [Get sequence:self.app.db];
                        for(int x = 0; x < data.count; x++) {
                            long webVisitID = [[data[x] objectForKey:@"itinerary_id"] longLongValue];
                            Visits *visit = [Get visit:self.app.db webVisitID:webVisitID];
                            if(visit == nil) {
                                visit = [NSEntityDescription insertNewObjectForEntityForName:@"Visits" inManagedObjectContext:self.app.db];
                                sequence.visits += 1;
                                visit.visitID = sequence.visits;
                                visit.webVisitID = webVisitID;
                            }
                            
                            long webStoreID = [[data[x] objectForKey:@"store_id"] longLongValue];
                            Stores *store = [Get store:self.app.db webStoreID:webStoreID];
                            if(store == nil) {
                                store = [NSEntityDescription insertNewObjectForEntityForName:@"Stores" inManagedObjectContext:self.app.db];
                                sequence.stores += 1;
                                store.storeID = sequence.stores;
                                store.webStoreID = webStoreID;
                                store.isFromTask = YES;
                                store.isFromWeb = YES;
                            }
                            store.employeeID = self.userID;
                            store.isTag = YES;
                            store.isActive = YES;
                            store.isSync = YES;
                            store.isUpdate = YES;
                            store.isWebUpdate = YES;
                            store.name = [data[x] objectForKey:@"store_name"];
                            store.shortName = [data[x] objectForKey:@"store_short_name"];
                            store.address = [data[x] objectForKey:@"store_address"];
                            store.contactNumber = [data[x] objectForKey:@"store_contact_number"];
                            store.email = [data[x] objectForKey:@"store_email"];
                            store.latitude = [[data[x] objectForKey:@"store_latitude"] doubleValue];
                            store.longitude = [[data[x] objectForKey:@"store_longitude"] doubleValue];
                            store.geoFenceRadius = [[data[x] objectForKey:@"store_radius"] longLongValue];
                            
                            long employeeID = [[data[x] objectForKey:@"employee_id"] longLongValue];
                            Employees *employee = [Get employee:self.app.db employeeID:employeeID];
                            if(employee == nil) {
                                employee = [NSEntityDescription insertNewObjectForEntityForName:@"Employees" inManagedObjectContext:self.app.db];
                                employee.employeeID = employeeID;
                            }
                            employee.firstName = [data[x] objectForKey:@"employee_firstname"];
                            employee.lastName = [data[x] objectForKey:@"employee_lastname"];
                            
                            visit.storeID = store.storeID;
                            visit.name = store.name;
                            visit.employeeID = employeeID;
                            visit.startDate = [data[x] objectForKey:@"start_date"];
                            visit.endDate = [data[x] objectForKey:@"end_date"];
                            visit.notes = [data[x] objectForKey:@"notes"];
                            visit.status = [data[x] objectForKey:@"status"];
                            visit.invoice = [data[x] objectForKey:@"mapping_code"];
                            visit.deliveries = [data[x] objectForKey:@"delivery_fee"];
                            visit.isDelete = [[data[x] objectForKey:@"is_deleted"] isEqualToString:@"1"];
                            visit.isCheckIn = ![[data[x] objectForKey:@"date_in"] isEqualToString:@"0000-00-00"];
                            visit.isCheckOut = ![[data[x] objectForKey:@"date_out"] isEqualToString:@"0000-00-00"];
                            
                            NSArray *inventories = [data[x] objectForKey:@"inventory"];
                            for(int x = 0; x < inventories.count; x++) {
                                long inventoryID = [[inventories[x] objectForKey:@"inventory_id"] longLongValue];
                                VisitInventories *inventory = [Get visitInventory:self.app.db visitID:visit.visitID inventoryID:inventoryID];
                                if(inventory == nil) {
                                    inventory = [NSEntityDescription insertNewObjectForEntityForName:@"VisitInventories" inManagedObjectContext:self.app.db];
                                    sequence.visitInventories += 1;
                                    inventory.visitInventoryID = sequence.visitInventories;
                                    inventory.visitID = visit.visitID;
                                    inventory.inventoryID = inventoryID;
                                    inventory.isFromWeb = YES;
                                }
                                inventory.name = [inventories[x] objectForKey:@"inventory_type_name"];
                                inventory.isActive = YES;
                            }
                            
                            NSArray<NSDictionary *> *forms = [data[x] objectForKey:@"forms"];
                            for(int x = 0; x < forms.count; x++) {
                                long formID = [[forms[x] objectForKey:@"form_id"] longLongValue];
                                VisitForms *form = [Get visitForm:self.app.db visitID:visit.visitID formID:formID];
                                if(form == nil) {
                                    form = [NSEntityDescription insertNewObjectForEntityForName:@"VisitForms" inManagedObjectContext:self.app.db];
                                    sequence.visitForms += 1;
                                    form.visitFormID = sequence.visitForms;
                                    form.visitID = visit.visitID;
                                    form.formID = formID;
                                    form.isFromWeb = YES;
                                }
                                form.name = [forms[x] objectForKey:@"form_name"];
                                form.isActive = YES;
                            }
                        }
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                    if([action isEqualToString:@"add-store"]) {
                        for(int x = 0; x < data.count; x++) {
                            Stores *store = [Get store:self.app.db storeID:[[params objectForKey:@"local_record_id"] longLongValue]];
                            store.webStoreID = [[data[x] objectForKey:@"store_id"] longLongValue];
                            store.isSync = YES;
                        }
                    }
                    if([action isEqualToString:@"add-store-contact-person"]) {
                        for(int x = 0; x < data.count; x++) {
                            StoreContacts *storeContact = [Get storeContact:self.app.db storeContactID:[[params objectForKey:@"local_record_id"] longLongValue]];
                            storeContact.webStoreContactID = [[data[x] objectForKey:@"contact_id"] longLongValue];
                            storeContact.isSync = YES;
                        }
                    }
                    if([action isEqualToString:@"add-announcement-seen"]) {
                        for(int x = 0; x < data.count; x++) {
                            AnnouncementSeen *announcementSeen = [Get announcementSeen:self.app.db announcementID:[[params objectForKey:@"announcement_id"] longLongValue]];
                            announcementSeen.isSync = YES;
                        }
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                    if([action isEqualToString:@"add-itinerary-visit"]) {
                        for(int x = 0; x < data.count; x++) {
                            Visits *visit = [Get visit:self.app.db visitID:[[params objectForKey:@"local_record_id"] longLongValue]];
                            visit.webVisitID = [[data[x] objectForKey:@"itinerary_id"] longLongValue];
                            visit.isSync = YES;
                        }
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                    if([action isEqualToString:@"upload-form-photo"]) {
                        for(int x = 0; x < data.count; x++) {
                            long photoID = [[params objectForKey:@"local_record_id"] longLongValue];
                            Photos *photo = [Get photo:self.app.db photoID:photoID];
                            photo.webPhotoID = [[data[x] objectForKey:@"photo_id"] longLongValue];
                            photo.isUpload = YES;                            
                        }
                        if(![Update save:self.app.db]) {
                            message = @"";
                        }
                    }
                }
                if([action isEqualToString:@"edit-store"]) {
                    Stores *store = [Get store:self.app.db webStoreID:[[params objectForKey:@"store_id"] longLongValue]];
                    store.isWebUpdate = YES;
                }
                if([action isEqualToString:@"edit-store-contact-person"]) {
                    StoreContacts *storeContact = [Get storeContact:self.app.db webStoreContactID:[[params objectForKey:@"contact_id"] longLongValue]];
                    storeContact.isWebUpdate = YES;
                }
                if([action isEqualToString:@"add-schedule"]) {
                    Schedules *schedule = [Get schedule:self.app.db scheduleID:[[params objectForKey:@"local_record_id"] longLongValue]];
                    schedule.webScheduleID = [[params objectForKey:@"schedule_id"] longLongValue];
                    schedule.isFromWeb = YES;
                    schedule.isSync = YES;
                    if(![Update save:self.app.db]) {
                        message = @"";
                    }
                }
                if([action isEqualToString:@"edit-schedule"]) {
                    Schedules *schedule = [Get schedule:self.app.db scheduleID:[[params objectForKey:@"local_record_id"] longLongValue]];
                    schedule.webScheduleID = [[params objectForKey:@"schedule_id"] longLongValue];
                    schedule.isFromWeb = YES;
                    schedule.isSync = YES;
                    if(![Update save:self.app.db]) {
                        message = @"";
                    }
                }
                if([action isEqualToString:@"time-in"]) {
                    TimeIn *timeIn = [Get timeIn:self.app.db timeInID:[[params objectForKey:@"local_record_id"] longLongValue]];
                    timeIn.isSync = YES;
                    if(![Update save:self.app.db]) {
                        message = @"";
                    }
                }
                if([action isEqualToString:@"upload-time-in-photo"]) {
                    TimeIn *timeIn = [Get timeIn:self.app.db timeInID:[[params objectForKey:@"local_record_id"] longLongValue]];
                    timeIn.isPhotoUpload = YES;
                    if(![Update save:self.app.db]) {
                        message = @"";
                    }
                }
                if([action isEqualToString:@"time-out"]) {
                    TimeOut *timeOut = [Get timeOut:self.app.db timeOutID:[[params objectForKey:@"local_record_id"] longLongValue]];
                    timeOut.isSync = YES;
                    if(![Update save:self.app.db]) {
                        message = @"";
                    }
                }
                if([action isEqualToString:@"upload-time-out-photo"]) {
                    TimeOut *timeOut = [Get timeOut:self.app.db timeOutID:[[params objectForKey:@"local_record_id"] longLongValue]];
                    timeOut.isPhotoUpload = YES;
                    if(![Update save:self.app.db]) {
                        message = @"";
                    }
                }
                if([action isEqualToString:@"upload-signature-photo"]) {
                    TimeOut *timeOut = [Get timeOut:self.app.db timeOutID:[[params objectForKey:@"local_record_id"] longLongValue]];
                    timeOut.isSignatureUpload = YES;
                    if(![Update save:self.app.db]) {
                        message = @"";
                    }
                }
                if([action isEqualToString:@"edit-itinerary-visit"]) {
                    Visits *visit = [Get visit:self.app.db webVisitID:[[params objectForKey:@"itinerary_id"] longLongValue]];
                    visit.isWebUpdate = YES;
                    if(![Update save:self.app.db]) {
                        message = @"";
                    }
                }
                if([action isEqualToString:@"delete-itinerary-visit"]) {
                    NSArray *visitIDs = [params objectForKey:@"itinerary_id"];
                    for(int x = 0; x < visitIDs.count; x++) {
                        Visits *visit = [Get visit:self.app.db webVisitID:[visitIDs[x] longLongValue]];
                        visit.isWebDelete = YES;
                    }
                    if(![Update save:self.app.db]) {
                        message = @"";
                    }
                }
                if([action isEqualToString:@"check-in"]) {
                    CheckIn *checkIn = [Get checkIn:self.app.db checkInID:[[params objectForKey:@"local_record_id"] longLongValue]];
                    checkIn.isSync = YES;
                    if(![Update save:self.app.db]) {
                        message = @"";
                    }
                }
                if([action isEqualToString:@"check-out"]) {
                    CheckOut *checkOut = [Get checkOut:self.app.db checkOutID:[[params objectForKey:@"local_record_id"] longLongValue]];
                    checkOut.isSync = YES;
                    if(![Update save:self.app.db]) {
                        message = @"";
                    }
                }
                if([action isEqualToString:@"upload-check-in-out-photo"]) {
                    Visits *visit = [Get visit:self.app.db webVisitID:[[params objectForKey:@"itinerary_id"] longLongValue]];
                    CheckIn *checkIn = [Get checkIn:self.app.db visitID:visit.visitID];
                    if([[params objectForKey:@"type"] isEqualToString:@"check-in"]) {
                        checkIn.isPhotoUpload = YES;
                    }
                    if([[params objectForKey:@"type"] isEqualToString:@"check-out"]) {
                        CheckOut *checkOut = [Get checkOut:self.app.db checkInID:checkIn.checkInID];
                        checkOut.isPhotoUpload = YES;
                    }
                    if(![Update save:self.app.db]) {
                        message = @"";
                    }
                }
                [self.delegate onLoadingUpdate:self.action];
                [self.process next];
            }
            self.maxProgress = [self.process tasksCount];
            self.lMessage.text = self.loadingMessage;
            self.pvProgress.self.progress = self.maxProgress > 0 ? (float)self.progress / (float)self.maxProgress : self.maxProgress;
            if(self.progress >= self.maxProgress || message != nil) {
                [View removeView:self.view animated:NO];
                [self.delegate onLoadingFinish:self.action params:params result:message != nil ? message : @"ok"];
            }
        });
    });
}

@end
