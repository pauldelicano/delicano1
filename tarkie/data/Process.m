#import "Process.h"
#import "Employees+CoreDataClass.h"
#import "Get.h"
#import "Load.h"
#import "Rx.h"
#import "Tx.h"
#import "Image.h"
#import "Time.h"

@interface Process()

@property (strong, nonatomic) NSMutableArray<NSURLSessionDataTask *> *tasks;
@property (nonatomic) long count;

@end

@implementation Process

- (instancetype)init {
    self.tasks = NSMutableArray.alloc.init;
    return super.init;
}

- (void)authorize:(NSManagedObjectContext *)db params:(NSMutableDictionary *)params {
    [self.tasks addObject:[Tx authorize:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
}

- (void)getCompany:(NSManagedObjectContext *)db {
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [self.tasks addObject:[Rx company:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
}

- (void)login:(NSManagedObjectContext *)db params:(NSMutableDictionary *)params  {
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [self.tasks addObject:[Tx login:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
}

- (void)getEmployees:(NSManagedObjectContext *)db {
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [self.tasks addObject:[Rx employees:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
}

- (void)timeSecurity:(NSManagedObjectContext *)db {
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [self.tasks addObject:[Rx serverTime:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
}

- (void)updateMasterFile:(NSManagedObjectContext *)db isAttendance:(BOOL)isAttendance isVisits:(BOOL)isVisits isExpense:(BOOL)isExpense isInventory:(BOOL)isInventory isForms:(BOOL)isForms {
    NSString *apiKey = [Get apiKey:db];
    Employees *employee = [Get employee:db employeeID:[Get userID:db]];
    NSString *employeeID = [NSString stringWithFormat:@"%lld", employee.employeeID];
    NSString *teamID = [NSString stringWithFormat:@"%lld", employee.teamID];
    NSDate *currentDate = NSDate.date;
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;

    [params removeAllObjects];
    [params setObject:apiKey forKey:@"api_key"];
    [self.tasks addObject:[Rx company:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];

    [params removeAllObjects];
    [params setObject:apiKey forKey:@"api_key"];
    [self.tasks addObject:[Rx employees:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];

    [params removeAllObjects];
    [params setObject:apiKey forKey:@"api_key"];
    [self.tasks addObject:[Rx settings:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];

    [params removeAllObjects];
    [params setObject:apiKey forKey:@"api_key"];
    [self.tasks addObject:[Rx conventions:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];

    [params removeAllObjects];
    [params setObject:apiKey forKey:@"api_key"];
    [self.tasks addObject:[Rx alertTypes:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];

    [params removeAllObjects];
    [params setObject:apiKey forKey:@"api_key"];
    [params setObject:teamID forKey:@"team_id"];
    [self.tasks addObject:[Rx announcements:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];

    [params removeAllObjects];
    [params setObject:apiKey forKey:@"api_key"];
    [params setObject:employeeID forKey:@"employee_id"];
    [self.tasks addObject:[Rx stores:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    
    [params removeAllObjects];
    [params setObject:apiKey forKey:@"api_key"];
    [self.tasks addObject:[Rx storeContacts:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];

//    [params removeAllObjects];
//    [params setObject:apiKey forKey:@"api_key"];
//    [params setObject:@"" forKey:@"sync_date"];
//    [params setObject:@"" forKey:@"limit"];
//    [params setObject:@"" forKey:@"offset"];
//    [self.tasks addObject:[Rx storeCustomFields:self.delegate params:params]];

//    [params removeAllObjects];
//    [params setObject:apiKey forKey:@"api_key"];
//    [params setObject:@"" forKey:@"sync_date"];
//    [self.tasks addObject:[Rx storeCustomFieldsPages:self.delegate params:params]];

    if(isAttendance) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [self.tasks addObject:[Rx scheduleTimes:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];

        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:employeeID forKey:@"employee_id"];
        [params setObject:[Time formatDate:DATE_FORMAT date:currentDate] forKey:@"start_date"];
        [params setObject:[Time formatDate:DATE_FORMAT date:[currentDate dateByAddingTimeInterval:60 * 60 * 24 * 15]] forKey:@"end_date"];
        [self.tasks addObject:[Rx schedules:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];

        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [self.tasks addObject:[Rx breakTypes:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];

        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [self.tasks addObject:[Rx overtimeReasons:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }
    if(isVisits) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:employeeID forKey:@"employee_id"];
        [params setObject:[Time formatDate:DATE_FORMAT date:[currentDate dateByAddingTimeInterval:60 * 60 * 24 * -15]] forKey:@"start_date"];
        [params setObject:[Time formatDate:DATE_FORMAT date:[currentDate dateByAddingTimeInterval:60 * 60 * 24 * 15]] forKey:@"end_date"];
        [params setObject:@"yes" forKey:@"get_deleted"];
        [params setObject:@"pending" forKey:@"status"];
        [self.tasks addObject:[Rx visits:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }
    if(isExpense) {
//        [self.tasks addObject:[Rx expenseTypes:self.delegate params:params]];
//        [self.tasks addObject:[Rx expenseTypeCategories:self.delegate params:params]];
    }
    if(isInventory) {
//        [self.tasks addObject:[Rx inventories:self.delegate params:params]];
//        [self.tasks addObject:[Rx inventoryBrands:self.delegate params:params]];
//        [self.tasks addObject:[Rx inventoryCategories:self.delegate params:params]];
//        [self.tasks addObject:[Rx inventoryDiscounts:self.delegate params:params]];
//        [self.tasks addObject:[Rx inventoryFacingItems:self.delegate params:params]];
//        [self.tasks addObject:[Rx inventoryOrders:self.delegate params:params]];
//        [self.tasks addObject:[Rx inventoryPlanoGramTypes:self.delegate params:params]];
//        [self.tasks addObject:[Rx inventoryPlanoGramItems:self.delegate params:params]];
//        [self.tasks addObject:[Rx inventoryPullOutReasons:self.delegate params:params]];
//        [self.tasks addObject:[Rx inventoryReasons:self.delegate params:params]];
//        [self.tasks addObject:[Rx inventoryStoreAssign:self.delegate params:params]];
//        [self.tasks addObject:[Rx inventorySubBrands:self.delegate params:params]];
//        [self.tasks addObject:[Rx inventoryUOMs:self.delegate params:params]];
    }
    if(isForms) {
//        [self.tasks addObject:[Rx forms:self.delegate params:params]];
//        [self.tasks addObject:[Rx formFields:self.delegate params:params]];
    }
}

- (void)syncData:(NSManagedObjectContext *)db {
    NSString *apiKey = [Get apiKey:db];
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;

    NSArray<AnnouncementSeen *> *syncAnnouncementSeen = [Load syncAnnouncementSeen:db];
    for(int x = 0; x < syncAnnouncementSeen.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncAnnouncementSeen[x].announcementID] forKey:@"announcement_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", [Get announcement:db announcementID:syncAnnouncementSeen[x].announcementID].employeeID] forKey:@"employee_id"];
        [params setObject:syncAnnouncementSeen[x].date forKey:@"date_seen"];
        [params setObject:syncAnnouncementSeen[x].time forKey:@"time_seen"];
        [self.tasks addObject:[Tx syncAnnouncementSeen:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }

    NSArray<Stores *> *syncStores = [Load syncStores:db];
    for(int x = 0; x < syncStores.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncStores[x].storeID] forKey:@"local_record_id"];
        [params setObject:syncStores[x].syncBatchID forKey:@"sync_batch_id"];
        [params setObject:syncStores[x].name forKey:@"store_name"];
        [params setObject:syncStores[x].contactNumber forKey:@"contact_number"];
        [params setObject:syncStores[x].email forKey:@"email"];
        [params setObject:syncStores[x].address forKey:@"address"];
        NSMutableArray *employeeIDs = NSMutableArray.alloc.init;
        if([syncStores[x].shareWith isEqualToString:@"my-team"]) {
            long teamID = [Get employee:db employeeID:syncStores[x].employeeID].teamID;
            NSArray<Employees *> *employees = [Load employeeIDs:db teamID:teamID];
            for(int x = 0; x < employees.count; x++) {
                [employeeIDs addObject:[NSString stringWithFormat:@"%lld", employees[x].employeeID]];
            }
            [params setObject:[NSArray.alloc initWithObjects:[NSString stringWithFormat:@"%ld", teamID], nil] forKey:@"team"];
        }
        else {
            [employeeIDs addObject:[NSString stringWithFormat:@"%lld", syncStores[x].employeeID]];
        }
        [params setObject:employeeIDs forKey:@"employee"];
        [self.tasks addObject:[Tx syncStore:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }

    NSArray<Stores *> *updateStores = [Load updateStores:db];
    for(int x = 0; x < updateStores.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", updateStores[x].webStoreID] forKey:@"store_id"];
        [params setObject:updateStores[x].name forKey:@"store_name"];
        [params setObject:updateStores[x].contactNumber forKey:@"contact_number"];
        [params setObject:updateStores[x].email forKey:@"email"];
        [params setObject:updateStores[x].address forKey:@"address"];
        NSMutableArray *employeeIDs = NSMutableArray.alloc.init;
        if([updateStores[x].shareWith isEqualToString:@"my-team"]) {
            long teamID = [Get employee:db employeeID:updateStores[x].employeeID].teamID;
            NSArray<Employees *> *employees = [Load employeeIDs:db teamID:teamID];
            for(int x = 0; x < employees.count; x++) {
                [employeeIDs addObject:[NSString stringWithFormat:@"%lld", employees[x].employeeID]];
            }
            [params setObject:[NSArray.alloc initWithObjects:[NSString stringWithFormat:@"%ld", teamID], nil] forKey:@"team"];
        }
        else {
            [employeeIDs addObject:[NSString stringWithFormat:@"%lld", updateStores[x].employeeID]];
        }
        [params setObject:employeeIDs forKey:@"employee"];
        [self.tasks addObject:[Tx updateStore:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }

    NSArray<StoreContacts *> *syncStoreContacts = [Load syncStoreContacts:db];
    for(int x = 0; x < syncStoreContacts.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncStoreContacts[x].storeContactID] forKey:@"local_record_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", [Get store:db storeID:syncStoreContacts[x].storeID].webStoreID] forKey:@"store_id"];
        [params setObject:syncStoreContacts[x].name forKey:@"name"];
        [params setObject:syncStoreContacts[x].designation forKey:@"designation"];
        [params setObject:syncStoreContacts[x].email forKey:@"email"];
        [params setObject:syncStoreContacts[x].mobileNumber forKey:@"mobile"];
        [params setObject:syncStoreContacts[x].landlineNumber forKey:@"telephone"];
        [params setObject:syncStoreContacts[x].birthdate forKey:@"birthdate"];
        [params setObject:syncStoreContacts[x].remarks forKey:@"remarks"];
        [self.tasks addObject:[Tx syncStoreContact:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }

    NSArray<StoreContacts *> *updateStoreContacts = [Load updateStoreContacts:db];
    for(int x = 0; x < updateStoreContacts.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", updateStoreContacts[x].webStoreContactID] forKey:@"contact_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", [Get store:db storeID:updateStoreContacts[x].storeID].webStoreID] forKey:@"store_id"];
        [params setObject:updateStoreContacts[x].name forKey:@"name"];
        [params setObject:updateStoreContacts[x].designation forKey:@"designation"];
        [params setObject:updateStoreContacts[x].email forKey:@"email"];
        [params setObject:updateStoreContacts[x].mobileNumber forKey:@"mobile"];
        [params setObject:updateStoreContacts[x].landlineNumber forKey:@"telephone"];
        [params setObject:updateStoreContacts[x].birthdate forKey:@"birthdate"];
        [params setObject:updateStoreContacts[x].remarks forKey:@"remarks"];
        [self.tasks addObject:[Tx updateStoreContact:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }

    NSArray<Schedules *> *syncSchedules = [Load syncSchedules:db];
    for(int x = 0; x < syncSchedules.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncSchedules[x].scheduleID] forKey:@"local_record_id"];
        [params setObject:syncSchedules[x].syncBatchID forKey:@"sync_batch_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncSchedules[x].employeeID] forKey:@"employee_id"];
        [params setObject:syncSchedules[x].scheduleDate forKey:@"date"];
        [params setObject:syncSchedules[x].timeIn forKey:@"time_in"];
        [params setObject:syncSchedules[x].timeOut forKey:@"time_out"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncSchedules[x].shiftTypeID] forKey:@"shift_type_id"];
        [params setObject:[NSString stringWithFormat:@"%d", YES] forKey:@"from_app"];
        [params setObject:[NSString stringWithFormat:@"%d", syncSchedules[x].isDayOff] forKey:@"is_day_off"];
        [self.tasks addObject:[Tx syncSchedule:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }
    
    NSArray<Schedules *> *updateSchedules = [Load updateSchedules:db];
    for(int x = 0; x < updateSchedules.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", updateSchedules[x].scheduleID] forKey:@"local_record_id"];
        [params setObject:updateSchedules[x].syncBatchID forKey:@"sync_batch_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", updateSchedules[x].employeeID] forKey:@"employee_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", updateSchedules[x].webScheduleID] forKey:@"schedule_id"];
        [params setObject:updateSchedules[x].scheduleDate forKey:@"date"];
        [params setObject:updateSchedules[x].timeIn forKey:@"time_in"];
        [params setObject:updateSchedules[x].timeOut forKey:@"time_out"];
        [params setObject:[NSString stringWithFormat:@"%lld", updateSchedules[x].shiftTypeID] forKey:@"shift_type_id"];
        [params setObject:[NSString stringWithFormat:@"%d", YES] forKey:@"from_app"];
        [params setObject:[NSString stringWithFormat:@"%d", updateSchedules[x].isDayOff] forKey:@"is_day_off"];
        [self.tasks addObject:[Tx updateSchedule:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }

    NSArray<TimeIn *> *syncTimeIn = [Load syncTimeIn:db];
    for(int x = 0; x < syncTimeIn.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncTimeIn[x].timeInID] forKey:@"local_record_id"];
        [params setObject:syncTimeIn[x].syncBatchID forKey:@"sync_batch_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncTimeIn[x].employeeID] forKey:@"employee_id"];
        [params setObject:syncTimeIn[x].date forKey:@"date_in"];
        [params setObject:syncTimeIn[x].time forKey:@"time_in"];
        GPS *gps = [Get gps:db gpsID:syncTimeIn[x].gpsID];
        [params setObject:gps.date forKey:@"gps_date"];
        [params setObject:gps.time forKey:@"gps_time"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.latitude] forKey:@"latitude"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.longitude] forKey:@"longitude"];
        [params setObject:[NSString stringWithFormat:@"%d", gps.isValid] forKey:@"is_valid"];
        [params setObject:[NSString stringWithFormat:@"%lld", [Get store:db storeID:syncTimeIn[x].storeID].webStoreID] forKey:@"store_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", [Get schedule:db scheduleID:syncTimeIn[x].scheduleID].webScheduleID] forKey:@"schedule_id"];
        [params setObject:syncTimeIn[x].batteryLevel forKey:@"batery_level"];
        [self.tasks addObject:[Tx syncTimeIn:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }

    NSArray<TimeIn *> *uploadTimeInPhoto = [Load uploadTimeInPhoto:db];
    for(int x = 0; x < uploadTimeInPhoto.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", uploadTimeInPhoto[x].timeInID] forKey:@"local_record_id"];
        [params setObject:uploadTimeInPhoto[x].syncBatchID forKey:@"sync_batch_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", uploadTimeInPhoto[x].employeeID] forKey:@"employee_id"];
        [self.tasks addObject:[Tx uploadTimeInPhoto:self.delegate params:[NSDictionary.alloc initWithDictionary:params] file:uploadTimeInPhoto[x].photo]];
    }

    NSArray<TimeOut *> *syncTimeOut = [Load syncTimeOut:db];
    for(int x = 0; x < syncTimeOut.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncTimeOut[x].timeOutID] forKey:@"local_record_id"];
        [params setObject:syncTimeOut[x].syncBatchID forKey:@"sync_batch_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncTimeOut[x].timeInID] forKey:@"local_record_id_in"];
        [params setObject:[Get timeIn:db timeInID:syncTimeOut[x].timeInID].syncBatchID forKey:@"sync_batch_id_in"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncTimeOut[x].employeeID] forKey:@"employee_id"];
        [params setObject:syncTimeOut[x].date forKey:@"date_out"];
        [params setObject:syncTimeOut[x].time forKey:@"time_out"];
        GPS *gps = [Get gps:db gpsID:syncTimeOut[x].gpsID];
        [params setObject:gps.date forKey:@"gps_date"];
        [params setObject:gps.time forKey:@"gps_time"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.latitude] forKey:@"latitude"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.longitude] forKey:@"longitude"];
        [params setObject:[NSString stringWithFormat:@"%d", gps.isValid] forKey:@"is_valid"];
        [params setObject:[NSString stringWithFormat:@"%lld", [Get store:db storeID:syncTimeOut[x].storeID].webStoreID] forKey:@"store_id"];
        [self.tasks addObject:[Tx syncTimeOut:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }

    NSArray<TimeOut *> *uploadTimeOutPhoto = [Load uploadTimeOutPhoto:db];
    for(int x = 0; x < uploadTimeOutPhoto.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", uploadTimeOutPhoto[x].timeOutID] forKey:@"local_record_id"];
        [params setObject:uploadTimeOutPhoto[x].syncBatchID forKey:@"sync_batch_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", uploadTimeOutPhoto[x].employeeID] forKey:@"employee_id"];
        [self.tasks addObject:[Tx uploadTimeOutPhoto:self.delegate params:[NSDictionary.alloc initWithDictionary:params] file:uploadTimeOutPhoto[x].photo]];
    }

    NSArray<TimeOut *> *uploadTimeOutSignature = [Load uploadTimeOutSignature:db];
    for(int x = 0; x < uploadTimeOutSignature.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", uploadTimeOutSignature[x].timeOutID] forKey:@"local_record_id"];
        [params setObject:uploadTimeOutSignature[x].syncBatchID forKey:@"sync_batch_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", uploadTimeOutSignature[x].employeeID] forKey:@"employee_id"];
        [self.tasks addObject:[Tx uploadTimeOutSignature:self.delegate params:[NSDictionary.alloc initWithDictionary:params] file:uploadTimeOutSignature[x].signature]];
    }
    
    NSArray<Photos *> *uploadVisitPhotos = [Load uploadVisitPhotos:db];
    for(int x = 0; x < uploadVisitPhotos.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", uploadVisitPhotos[x].photoID] forKey:@"local_record_id"];
        [params setObject:uploadVisitPhotos[x].syncBatchID forKey:@"sync_batch_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", uploadVisitPhotos[x].employeeID] forKey:@"employee_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", [Get employee:db employeeID:uploadVisitPhotos[x].employeeID].teamID] forKey:@"team_id"];
        [params setObject:uploadVisitPhotos[x].date forKey:@"date_created"];
        [params setObject:uploadVisitPhotos[x].time forKey:@"time_created"];
        [params setObject:[NSString stringWithFormat:@"%d", uploadVisitPhotos[x].isSignature] forKey:@"is_signature"];
        [self.tasks addObject:[Tx uploadVisitPhoto:self.delegate params:[NSDictionary.alloc initWithDictionary:params] file:uploadVisitPhotos[x].filename]];
    }

    NSArray<Visits *> *syncVisits = [Load syncVisits:db];
    for(int x = 0; x < syncVisits.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncVisits[x].visitID] forKey:@"local_record_id"];
        [params setObject:syncVisits[x].syncBatchID forKey:@"sync_batch_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncVisits[x].employeeID] forKey:@"employee_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncVisits[x].employeeID] forKey:@"created_by"];
        [params setObject:syncVisits[x].createdDate forKey:@"date_created"];
        [params setObject:syncVisits[x].createdTime forKey:@"time_created"];
        [params setObject:syncVisits[x].startDate forKey:@"start_date"];
        [params setObject:syncVisits[x].endDate forKey:@"end_date"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncVisits[x].webVisitID] forKey:@"itinerary_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", [Get store:db storeID:syncVisits[x].storeID].webStoreID] forKey:@"store_id"];
        [params setObject:syncVisits[x].notes forKey:@"notes"];
        NSArray<Photos *> *visitPhotos = [Load visitPhotos:db visitID:syncVisits[x].visitID];
        NSMutableArray *webPhotoIDs = NSMutableArray.alloc.init;
        for(int x = 0; x < visitPhotos.count; x++) {
            [webPhotoIDs addObject:[NSString stringWithFormat:@"%lld", visitPhotos[x].webPhotoID]];
        }
        [params setObject:webPhotoIDs forKey:@"photos"];
        //    paramsObj.put("forms", formArray);
        //    paramsObj.put("entries", entryArray);
        //    paramsObj.put("inventory", inventoryArray);
        [self.tasks addObject:[Tx syncVisit:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }

    NSArray<Visits *> *updateVisits = [Load updateVisits:db];
    for(int x = 0; x < updateVisits.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", updateVisits[x].employeeID] forKey:@"employee_id"];
        [params setObject:updateVisits[x].startDate forKey:@"start_date"];
        [params setObject:updateVisits[x].endDate forKey:@"end_date"];
        [params setObject:[NSString stringWithFormat:@"%lld", updateVisits[x].webVisitID] forKey:@"itinerary_id"];
        [params setObject:[NSString stringWithFormat:@"%lld", [Get store:db storeID:updateVisits[x].storeID].webStoreID] forKey:@"store_id"];
        [params setObject:updateVisits[x].notes forKey:@"notes"];
        NSArray<Photos *> *visitPhotos = [Load visitPhotos:db visitID:updateVisits[x].visitID];
        NSMutableArray *webPhotoIDs = NSMutableArray.alloc.init;
        for(int x = 0; x < visitPhotos.count; x++) {
            [webPhotoIDs addObject:[NSString stringWithFormat:@"%lld", visitPhotos[x].webPhotoID]];
        }
        [params setObject:webPhotoIDs forKey:@"photos"];
        //    paramsObj.put("forms", formArray);
        //    paramsObj.put("entries", entryArray);
        //    paramsObj.put("inventory", inventoryArray);
        [self.tasks addObject:[Tx updateVisit:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }

    NSArray<Visits *> *deleteVisits = [Load deleteVisits:db];
    NSMutableArray<NSString *> *visitIDs = NSMutableArray.alloc.init;
    for(int x = 0; x < deleteVisits.count; x++) {
        [visitIDs addObject:[NSString stringWithFormat:@"%lld", deleteVisits[x].webVisitID]];
    }
    if(visitIDs.count > 0) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:visitIDs forKey:@"itinerary_id"];
        [self.tasks addObject:[Tx deleteVisit:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }

    NSArray<CheckIn *> *syncCheckIn = [Load syncCheckIn:db];
    for(int x = 0; x < syncCheckIn.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncCheckIn[x].checkInID] forKey:@"local_record_id"];
        [params setObject:syncCheckIn[x].syncBatchID forKey:@"sync_batch_id"];
        Visits *visit = [Get visit:db visitID:[Get checkIn:db checkInID:syncCheckIn[x].checkInID].visitID];
        [params setObject:[NSString stringWithFormat:@"%lld", visit.employeeID] forKey:@"employee_id"];
        [params setObject:syncCheckIn[x].date forKey:@"date_in"];
        [params setObject:syncCheckIn[x].time forKey:@"time_in"];
        [params setObject:[NSString stringWithFormat:@"%lld", visit.webVisitID] forKey:@"itinerary_id"];
        GPS *gps = [Get gps:db gpsID:syncCheckIn[x].gpsID];
        [params setObject:gps.date forKey:@"gps_date"];
        [params setObject:gps.time forKey:@"gps_time"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.latitude] forKey:@"latitude"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.longitude] forKey:@"longitude"];
        [params setObject:[NSString stringWithFormat:@"%d", gps.isValid] forKey:@"is_valid"];
        [self.tasks addObject:[Tx syncCheckIn:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }

    NSArray<CheckIn *> *uploadCheckInPhoto = [Load uploadCheckInPhoto:db];
    for(int x = 0; x < uploadCheckInPhoto.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", [Get visit:db visitID:uploadCheckInPhoto[x].visitID].webVisitID] forKey:@"itinerary_id"];
        [params setObject:@"check-in" forKey:@"type"];
        [self.tasks addObject:[Tx uploadCheckInPhoto:self.delegate params:[NSDictionary.alloc initWithDictionary:params] file:uploadCheckInPhoto[x].photo]];
    }

    NSArray<CheckOut *> *syncCheckOut = [Load syncCheckOut:db];
    for(int x = 0; x < syncCheckOut.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", syncCheckOut[x].checkOutID] forKey:@"local_record_id"];
        [params setObject:syncCheckOut[x].syncBatchID forKey:@"sync_batch_id"];
        Visits *visit = [Get visit:db visitID:[Get checkIn:db checkInID:syncCheckOut[x].checkInID].visitID];
        [params setObject:[NSString stringWithFormat:@"%lld", visit.employeeID] forKey:@"employee_id"];
        [params setObject:syncCheckOut[x].date forKey:@"date_out"];
        [params setObject:syncCheckOut[x].time forKey:@"time_out"];
        [params setObject:[NSString stringWithFormat:@"%lld", visit.webVisitID] forKey:@"itinerary_id"];
        GPS *gps = [Get gps:db gpsID:syncCheckOut[x].gpsID];
        [params setObject:gps.date forKey:@"gps_date"];
        [params setObject:gps.time forKey:@"gps_time"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.latitude] forKey:@"latitude"];
        [params setObject:[NSString stringWithFormat:@"%f", gps.longitude] forKey:@"longitude"];
        [params setObject:[NSString stringWithFormat:@"%d", gps.isValid] forKey:@"is_valid"];
        [params setObject:visit.status forKey:@"status"];
        [self.tasks addObject:[Tx syncCheckOut:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
    }

    NSArray<CheckOut *> *uploadCheckOutPhoto = [Load uploadCheckOutPhoto:db];
    for(int x = 0; x < uploadCheckOutPhoto.count; x++) {
        [params removeAllObjects];
        [params setObject:apiKey forKey:@"api_key"];
        [params setObject:[NSString stringWithFormat:@"%lld", [Get visit:db visitID:[Get checkIn:db checkInID:uploadCheckOutPhoto[x].checkInID].visitID].webVisitID] forKey:@"itinerary_id"];
        [params setObject:@"check-out" forKey:@"type"];
        [self.tasks addObject:[Tx uploadCheckOutPhoto:self.delegate params:[NSDictionary.alloc initWithDictionary:params] file:uploadCheckOutPhoto[x].photo]];
    }
}

- (void)getSchedule:(NSManagedObjectContext *)db {
    NSMutableDictionary *params = NSMutableDictionary.alloc.init;
    [params setObject:[Get apiKey:db] forKey:@"api_key"];
    [params setObject:[NSString stringWithFormat:@"%ld", [Get userID:db]] forKey:@"employee_id"];
    NSDate *currentDate = NSDate.date;
    [params setObject:[Time formatDate:DATE_FORMAT date:currentDate] forKey:@"start_date"];
    [params setObject:[Time formatDate:DATE_FORMAT date:currentDate] forKey:@"end_date"];
    [self.tasks addObject:[Rx schedules:self.delegate params:[NSDictionary.alloc initWithDictionary:params]]];
}

- (void)sendBackupData:(NSManagedObjectContext *)db {
    
}

- (void)start {
    self.count = 0;
    if(self.tasks.count > 0) {
        [[self.tasks objectAtIndex:self.count] resume];
    }
}

- (void)next {
    self.count++;
    if(self.count < self.tasks.count) {
        [[self.tasks objectAtIndex:self.count] resume];
    }
}

- (long)tasksCount {
    return self.tasks.count;
}

@end
