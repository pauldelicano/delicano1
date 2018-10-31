#import "Process.h"
#import "Get.h"
#import "Load.h"
#import "Rx.h"
#import "Tx.h"
#import "File.h"
#import "Time.h"

@implementation Process

- (void)setIsCanceled:(BOOL)isCanceled {
    [Rx isCanceled:isCanceled];
    [Tx isCanceled:isCanceled];
}

- (void)authorize:(NSManagedObjectContext *)db params:(NSMutableDictionary *)params {
    self.count = 2;
    if(![Tx authorize:db params:params delegate:self.delegate] || self.isCanceled) {
        return;
    }
    if(![Rx company:db delegate:self.delegate] || self.isCanceled) {
        return;
    }
}

- (void)login:(NSManagedObjectContext *)db params:(NSMutableDictionary *)params  {
    self.count = 2;
    if(![Tx login:db params:params delegate:self.delegate] || self.isCanceled) {
        return;
    }
    if(![Rx employees:db delegate:self.delegate] || self.isCanceled) {
        return;
    }
}

- (void)timeSecurity:(NSManagedObjectContext *)db {
    self.count = 1;
    if(![Rx serverTime:db delegate:self.delegate] || self.isCanceled) {
        return;
    }
}

- (void)updateMasterFile:(NSManagedObjectContext *)db isAttendance:(BOOL)isAttendance isVisits:(BOOL)isVisits isExpense:(BOOL)isExpense isInventory:(BOOL)isInventory isForms:(BOOL)isForms {
    self.count = 8 + (isAttendance ? 4 : 0) + (isVisits ? 1 : 0) + (isExpense ? 1 : 0) + (isInventory ? 0 : 0) + (isForms ? 0 : 0);
    if(![Rx company:db delegate:self.delegate] || self.isCanceled) {
        return;
    }
    if(![Rx employees:db delegate:self.delegate] || self.isCanceled) {
        return;
    }
    if(![Rx settings:db delegate:self.delegate] || self.isCanceled) {
        return;
    }
    if(![Rx conventions:db delegate:self.delegate] || self.isCanceled) {
        return;
    }
    if(![Rx announcements:db delegate:self.delegate] || self.isCanceled) {
        return;
    }
    if(![Rx stores:db delegate:self.delegate] || self.isCanceled) {
        return;
    }
    if(![Rx storeContacts:db delegate:self.delegate] || self.isCanceled) {
        return;
    }
//    if(![Rx storeCustomFields:db delegate:self.delegate] || self.isCanceled) {
//        return;
//    }
//    if(![Rx storeCustomFieldsPages:db delegate:self.delegate] || self.isCanceled) {
//        return;
//    }
    if(isAttendance) {
        if(![Rx scheduleTimes:db delegate:self.delegate] || self.isCanceled) {
            return;
        }
        if(![Rx schedules:db isToday:NO delegate:self.delegate] || self.isCanceled) {
            return;
        }
        if(![Rx breakTypes:db delegate:self.delegate] || self.isCanceled) {
            return;
        }
        if(![Rx overtimeReasons:db delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    if(isVisits) {
        if(![Rx visits:db delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    if(isExpense) {
        if(![Rx expenseTypeCategories:db delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    if(isInventory) {
//        if(![Rx inventories:db delegate:self.delegate] || self.isCanceled) {
//            return;
//        }
//        if(![Rx inventoryBrands:db delegate:self.delegate] || self.isCanceled) {
//            return;
//        }
//        if(![Rx inventoryCategories:db delegate:self.delegate] || self.isCanceled) {
//            return;
//        }
//        if(![Rx inventoryDiscounts:db delegate:self.delegate] || self.isCanceled) {
//            return;
//        }
//        if(![Rx inventoryFacingItems:db delegate:self.delegate] || self.isCanceled) {
//            return;
//        }
//        if(![Rx inventoryOrders:db delegate:self.delegate] || self.isCanceled) {
//            return;
//        }
//        if(![Rx inventoryPlanoGramTypes:db delegate:self.delegate] || self.isCanceled) {
//            return;
//        }
//        if(![Rx inventoryPlanoGramItems:db delegate:self.delegate] || self.isCanceled) {
//            return;
//        }
//        if(![Rx inventoryPullOutReasons:db delegate:self.delegate] || self.isCanceled) {
//            return;
//        }
//        if(![Rx inventoryReasons:db delegate:self.delegate] || self.isCanceled) {
//            return;
//        }
//        if(![Rx inventoryStoreAssign:db delegate:self.delegate] || self.isCanceled) {
//            return;
//        }
//        if(![Rx inventorySubBrands:db delegate:self.delegate] || self.isCanceled) {
//            return;
//        }
//        if(![Rx inventoryUOMs:db delegate:self.delegate] || self.isCanceled) {
//            return;
//        }
    }
    if(isForms) {
//        if(![Rx forms:db delegate:self.delegate] || self.isCanceled) {
//            return;
//        }
//        if(![Rx formFields:db delegate:self.delegate] || self.isCanceled) {
//            return;
//        }
    }
    if(![Rx syncBatchID:db delegate:self.delegate] || self.isCanceled) {
        return;
    }
}

- (void)syncData:(NSManagedObjectContext *)db {
    self.count = 1 + [Get syncTotalCount:db];
    for(AnnouncementSeen *syncAnnouncementSeen in [Load syncAnnouncementSeen:db]) {
        if(![Tx syncAnnouncementSeen:db announcementSeen:syncAnnouncementSeen delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(Stores *syncStore in [Load syncStores:db]) {
        if(![Tx syncStore:db store:syncStore delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(Stores *updateStore in [Load updateStores:db]) {
        if(![Tx updateStore:db store:updateStore delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(StoreContacts *syncStoreContact in [Load syncStoreContacts:db]) {
        if(![Tx syncStoreContact:db storeContact:syncStoreContact delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(StoreContacts *updateStoreContact in [Load updateStoreContacts:db]) {
        if(![Tx updateStoreContact:db storeContact:updateStoreContact delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    if(![Rx schedules:db isToday:YES delegate:self.delegate] || self.isCanceled) {
        return;
    }
    for(Schedules *syncSchedule in [Load syncSchedules:db]) {
        if(![Tx syncSchedule:db schedule:syncSchedule delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(Schedules *updateSchedule in [Load updateSchedules:db]) {
        if(![Tx updateSchedule:db schedule:updateSchedule delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(TimeIn *syncTimeIn in [Load syncTimeIn:db]) {
        if(![Tx syncTimeIn:db timeIn:syncTimeIn delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(TimeIn *uploadTimeInPhoto in [Load uploadTimeInPhoto:db]) {
        if(![Tx uploadTimeInPhoto:db timeIn:uploadTimeInPhoto delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(TimeOut *syncTimeOut in [Load syncTimeOut:db]) {
        if(![Tx syncTimeOut:db timeOut:syncTimeOut delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(TimeOut *uploadTimeOutPhoto in [Load uploadTimeOutPhoto:db]) {
        if(![Tx uploadTimeOutPhoto:db timeOut:uploadTimeOutPhoto delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(TimeOut *uploadTimeOutSignature in [Load uploadTimeOutSignature:db]) {
        if(![Tx uploadTimeOutSignature:db timeOut:uploadTimeOutSignature delegate:self.delegate]) {
            return;
        }
    }
    for(BreakIn *syncBreakIn in [Load syncBreakIn:db]) {
        if(![Tx syncBreakIn:db breakIn:syncBreakIn delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(BreakOut *syncBreakOut in [Load syncBreakOut:db]) {
        if(![Tx syncBreakOut:db breakOut:syncBreakOut delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(Overtime *syncOvertime in [Load syncOvertime:db]) {
        if(![Tx syncOvertime:db overtime:syncOvertime delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(Tracking *syncTracking in [Load syncTracking:db]) {
        if(![Tx syncTracking:db tracking:syncTracking delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(Alerts *syncAlert in [Load syncAlerts:db]) {
        if(![Tx syncAlert:db alert:syncAlert delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(Photos *uploadVisitPhoto in [Load uploadVisitPhotos:db]) {
        if(![Tx uploadVisitPhoto:db photo:uploadVisitPhoto delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(Visits *syncVisit in [Load syncVisits:db]) {
        if(![Tx syncVisit:db visit:syncVisit delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(Visits *updateVisit in [Load updateVisits:db]) {
        if(![Tx updateVisit:db visit:updateVisit delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(Visits *deleteVisit in [Load deleteVisits:db]) {
        if(![Tx deleteVisit:db visit:deleteVisit delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(CheckIn *syncCheckIn in [Load syncCheckIn:db]) {
        if(![Tx syncCheckIn:db checkIn:syncCheckIn delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(CheckIn *uploadCheckInPhoto in [Load uploadCheckInPhoto:db]) {
        if(![Tx uploadCheckInPhoto:db checkIn:uploadCheckInPhoto delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(CheckOut *syncCheckOut in [Load syncCheckOut:db]) {
        if(![Tx syncCheckOut:db checkOut:syncCheckOut delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(CheckOut *uploadCheckOutPhoto in [Load uploadCheckOutPhoto:db]) {
        if(![Tx uploadCheckOutPhoto:db checkOut:uploadCheckOutPhoto delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(Expense *syncExpense in [Load syncExpenses:db]) {
        if(![Tx syncExpenses:db expense:syncExpense delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(Expense *updateExpense in [Load updateExpenses:db]) {
        if(![Tx updateExpenses:db expense:updateExpense delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
    for(Expense *deleteExpense in [Load deleteExpenses:db]) {
        if(![Tx deleteExpenses:db expense:deleteExpense delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
}

- (void)sendBackupData:(NSManagedObjectContext *)db {
    self.count = 1;
    if(![Tx sendBackupData:db delegate:self.delegate] || self.isCanceled) {
        return;
    }
}

- (void)patch:(NSManagedObjectContext *)db {
    self.count = 1;
    if(![Rx patches:db delegate:self.delegate] || self.isCanceled) {
        return;
    }
}

- (void)syncPatch:(NSManagedObjectContext *)db {
    self.count = [Get syncPatchesCount:db];
    for(Patches *syncPatch in [Load syncPatches:db]) {
        if(![Tx patchData:db patch:syncPatch delegate:self.delegate] || self.isCanceled) {
            return;
        }
    }
}

@end
