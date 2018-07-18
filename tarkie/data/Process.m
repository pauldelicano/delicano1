#import "Process.h"
#import "Get.h"
#import "Load.h"
#import "Rx.h"
#import "Tx.h"
#import "Image.h"
#import "Time.h"

@implementation Process

- (void)authorize:(NSManagedObjectContext *)db params:(NSMutableDictionary *)params {
    self.count = 2;
    if(![Tx authorize:db params:params delegate:self.delegate]) {
        return;
    }
    if(![Rx company:db delegate:self.delegate]) {
        return;
    }
}

- (void)login:(NSManagedObjectContext *)db params:(NSMutableDictionary *)params  {
    self.count = 2;
    if(![Tx login:db params:params delegate:self.delegate]) {
        return;
    }
    if(![Rx employees:db delegate:self.delegate]) {
        return;
    }
}

- (void)timeSecurity:(NSManagedObjectContext *)db {
    self.count = 1;
    if(![Rx serverTime:db delegate:self.delegate]) {
        return;
    }
}

- (void)updateMasterFile:(NSManagedObjectContext *)db isAttendance:(BOOL)isAttendance isVisits:(BOOL)isVisits isExpense:(BOOL)isExpense isInventory:(BOOL)isInventory isForms:(BOOL)isForms {
    self.count = 8 + (isAttendance ? 4 : 0) + (isVisits ? 1 : 0) + (isExpense ? 0 : 0) + (isInventory ? 0 : 0) + (isForms ? 0 : 0);
    if(![Rx company:db delegate:self.delegate]) {
        return;
    }
    if(![Rx employees:db delegate:self.delegate]) {
        return;
    }
    if(![Rx settings:db delegate:self.delegate]) {
        return;
    }
    if(![Rx conventions:db delegate:self.delegate]) {
        return;
    }
    if(![Rx alertTypes:db delegate:self.delegate]) {
        return;
    }
    if(![Rx announcements:db delegate:self.delegate]) {
        return;
    }
    if(![Rx stores:db delegate:self.delegate]) {
        return;
    }
    if(![Rx storeContacts:db delegate:self.delegate]) {
        return;
    }
//    if(![Rx storeCustomFields:db delegate:self.delegate]) {
//        return;
//    }
//    if(![Rx storeCustomFieldsPages:db delegate:self.delegate]) {
//        return;
//    }
    if(isAttendance) {
        if(![Rx scheduleTimes:db delegate:self.delegate]) {
            return;
        }
        if(![Rx schedules:db isToday:NO delegate:self.delegate]) {
            return;
        }
        if(![Rx breakTypes:db delegate:self.delegate]) {
            return;
        }
        if(![Rx overtimeReasons:db delegate:self.delegate]) {
            return;
        }
    }
    if(isVisits) {
        if(![Rx visits:db delegate:self.delegate]) {
            return;
        }
    }
    if(isExpense) {
//        if(![Rx expenseTypes:db delegate:self.delegate]) {
//            return;
//        }
//        if(![Rx expenseTypeCategories:db delegate:self.delegate]) {
//            return;
//        }
    }
    if(isInventory) {
//        if(![Rx inventories:db delegate:self.delegate]) {
//            return;
//        }
//        if(![Rx inventoryBrands:db delegate:self.delegate]) {
//            return;
//        }
//        if(![Rx inventoryCategories:db delegate:self.delegate]) {
//            return;
//        }
//        if(![Rx inventoryDiscounts:db delegate:self.delegate]) {
//            return;
//        }
//        if(![Rx inventoryFacingItems:db delegate:self.delegate]) {
//            return;
//        }
//        if(![Rx inventoryOrders:db delegate:self.delegate]) {
//            return;
//        }
//        if(![Rx inventoryPlanoGramTypes:db delegate:self.delegate]) {
//            return;
//        }
//        if(![Rx inventoryPlanoGramItems:db delegate:self.delegate]) {
//            return;
//        }
//        if(![Rx inventoryPullOutReasons:db delegate:self.delegate]) {
//            return;
//        }
//        if(![Rx inventoryReasons:db delegate:self.delegate]) {
//            return;
//        }
//        if(![Rx inventoryStoreAssign:db delegate:self.delegate]) {
//            return;
//        }
//        if(![Rx inventorySubBrands:db delegate:self.delegate]) {
//            return;
//        }
//        if(![Rx inventoryUOMs:db delegate:self.delegate]) {
//            return;
//        }
    }
    if(isForms) {
//        if(![Rx forms:db delegate:self.delegate]) {
//            return;
//        }
//        if(![Rx formFields:db delegate:self.delegate]) {
//            return;
//        }
    }
}

- (void)syncData:(NSManagedObjectContext *)db {
    self.count = 1 + [Get syncTotalCount:db];
    NSArray<AnnouncementSeen *> *syncAnnouncementSeen = [Load syncAnnouncementSeen:db];
    for(int x = 0; x < syncAnnouncementSeen.count; x++) {
        if(![Tx syncAnnouncementSeen:db announcementSeen:syncAnnouncementSeen[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<Stores *> *syncStores = [Load syncStores:db];
    for(int x = 0; x < syncStores.count; x++) {
        if(![Tx syncStore:db store:syncStores[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<Stores *> *updateStores = [Load updateStores:db];
    for(int x = 0; x < updateStores.count; x++) {
        if(![Tx updateStore:db store:updateStores[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<StoreContacts *> *syncStoreContacts = [Load syncStoreContacts:db];
    for(int x = 0; x < syncStoreContacts.count; x++) {
        if(![Tx syncStoreContact:db storeContact:syncStoreContacts[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<StoreContacts *> *updateStoreContacts = [Load updateStoreContacts:db];
    for(int x = 0; x < updateStoreContacts.count; x++) {
        if(![Tx updateStoreContact:db storeContact:updateStoreContacts[x] delegate:self.delegate]) {
            return;
        }
    }
    if(![Rx schedules:db isToday:YES delegate:self.delegate]) {
        return;
    }
    NSArray<Schedules *> *syncSchedules = [Load syncSchedules:db];
    for(int x = 0; x < syncSchedules.count; x++) {
        if(![Tx syncSchedule:db schedule:syncSchedules[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<Schedules *> *updateSchedules = [Load updateSchedules:db];
    for(int x = 0; x < updateSchedules.count; x++) {
        if(![Tx updateSchedule:db schedule:updateSchedules[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<TimeIn *> *syncTimeIn = [Load syncTimeIn:db];
    for(int x = 0; x < syncTimeIn.count; x++) {
        if(![Tx syncTimeIn:db timeIn:syncTimeIn[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<TimeIn *> *uploadTimeInPhoto = [Load uploadTimeInPhoto:db];
    for(int x = 0; x < uploadTimeInPhoto.count; x++) {
        if(![Tx uploadTimeInPhoto:db timeIn:uploadTimeInPhoto[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<TimeOut *> *syncTimeOut = [Load syncTimeOut:db];
    for(int x = 0; x < syncTimeOut.count; x++) {
        if(![Tx syncTimeOut:db timeOut:syncTimeOut[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<TimeOut *> *uploadTimeOutPhoto = [Load uploadTimeOutPhoto:db];
    for(int x = 0; x < uploadTimeOutPhoto.count; x++) {
        if(![Tx uploadTimeOutPhoto:db timeOut:uploadTimeOutPhoto[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<TimeOut *> *uploadTimeOutSignature = [Load uploadTimeOutSignature:db];
    for(int x = 0; x < uploadTimeOutSignature.count; x++) {
        if(![Tx uploadTimeOutSignature:db timeOut:uploadTimeOutSignature[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<Photos *> *uploadVisitPhotos = [Load uploadVisitPhotos:db];
    for(int x = 0; x < uploadVisitPhotos.count; x++) {
        if(![Tx uploadVisitPhoto:db photo:uploadVisitPhotos[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<Visits *> *syncVisits = [Load syncVisits:db];
    for(int x = 0; x < syncVisits.count; x++) {
        if(![Tx syncVisit:db visit:syncVisits[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<Visits *> *updateVisits = [Load updateVisits:db];
    for(int x = 0; x < updateVisits.count; x++) {
        if(![Tx updateVisit:db visit:updateVisits[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<Visits *> *deleteVisits = [Load deleteVisits:db];
    for(int x = 0; x < deleteVisits.count; x++) {
        if(![Tx deleteVisit:db visit:deleteVisits[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<CheckIn *> *syncCheckIn = [Load syncCheckIn:db];
    for(int x = 0; x < syncCheckIn.count; x++) {
        if(![Tx syncCheckIn:db checkIn:syncCheckIn[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<CheckIn *> *uploadCheckInPhoto = [Load uploadCheckInPhoto:db];
    for(int x = 0; x < uploadCheckInPhoto.count; x++) {
        if(![Tx uploadCheckInPhoto:db checkIn:uploadCheckInPhoto[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<CheckOut *> *syncCheckOut = [Load syncCheckOut:db];
    for(int x = 0; x < syncCheckOut.count; x++) {
        if(![Tx syncCheckOut:db checkOut:syncCheckOut[x] delegate:self.delegate]) {
            return;
        }
    }
    NSArray<CheckOut *> *uploadCheckOutPhoto = [Load uploadCheckOutPhoto:db];
    for(int x = 0; x < uploadCheckOutPhoto.count; x++) {
        if(![Tx uploadCheckOutPhoto:db checkOut:uploadCheckOutPhoto[x] delegate:self.delegate]) {
            return;
        }
    }
}

- (void)sendBackupData:(NSManagedObjectContext *)db {
    self.count = 0;
}

@end
