#import "Update.h"
#import "Get.h"

@implementation Update

+ (BOOL)usersLogout:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isLogout == %@", @NO]];
    NSArray<Users *> *result = [self execute:db entity:@"Users" predicates:predicates];
    for(int x = 0; x < result.count; x++) {
        result[x].isLogout = YES;
    }
    return [self save:db];
}

+ (void)employeesDeactivate:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    NSArray<Employees *> *result = [self execute:db entity:@"Employees" predicates:predicates];
    for(int x = 0; x < result.count; x++) {
        result[x].isActive = NO;
    }
}

+ (void)announcementsDeactivate:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    NSArray<Announcements *> *result = [self execute:db entity:@"Announcements" predicates:predicates];
    for(int x = 0; x < result.count; x++) {
        result[x].isActive = NO;
    }
}

+ (void)storesDeactivate:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isFromTask == %@", @NO]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isTag == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    NSArray<Stores *> *result = [self execute:db entity:@"Stores" predicates:predicates];
    for(int x = 0; x < result.count; x++) {
        result[x].isTag = NO;
        result[x].isActive = NO;
    }
}

+ (void)storeContactsDeactivate:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    NSArray<StoreContacts *> *result = [self execute:db entity:@"StoreContacts" predicates:predicates];
    for(int x = 0; x < result.count; x++) {
        result[x].isActive = NO;
    }
}

+ (void)scheduleTimesDeactivate:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    NSArray<ScheduleTimes *> *result = [self execute:db entity:@"ScheduleTimes" predicates:predicates];
    for(int x = 0; x < result.count; x++) {
        result[x].isActive = NO;
    }
}

+ (void)schedulesDeactivate:(NSManagedObjectContext *)db {
    NSMutableArray *predicates = NSMutableArray.alloc.init;
    [predicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    NSArray<Schedules *> *result = [self execute:db entity:@"Schedules" predicates:predicates];
    for(int x = 0; x < result.count; x++) {
        result[x].isActive = NO;
    }
}

+ (NSArray *)execute:(NSManagedObjectContext *)db entity:(NSString *)entity predicates:(NSArray<NSPredicate *> *)predicates  {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    fetchRequest.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:predicates];
    NSError *error = nil;
    NSArray *data = [db executeFetchRequest:fetchRequest error:&error];
    if(error != nil) {
        NSLog(@"error: update execute - %@", error.localizedDescription);
    }
    return data;
}

+ (BOOL)save:(NSManagedObjectContext *)db {
    NSError *error = nil;
    if(![db save:&error]) {
        if(error != nil) {
            NSLog(@"error: update save - %@", error.localizedDescription);
        }
        [db rollback];
        return NO;
    }
    return YES;
}

@end
