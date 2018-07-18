#import "Update.h"
#import "Get.h"

@implementation Update

+ (BOOL)usersLogout:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isLogout == %@", @NO]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    NSArray<Users *> *result = [self fetch:db request:request];
    for(int x = 0; x < result.count; x++) {
        result[x].isLogout = YES;
    }
    return [self save:db];
}

+ (void)employeesDeactivate:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Employees"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    NSArray<Employees *> *result = [self fetch:db request:request];
    for(int x = 0; x < result.count; x++) {
        result[x].isActive = NO;
    }
}

+ (void)announcementsDeactivate:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Announcements"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    NSArray<Announcements *> *result = [self fetch:db request:request];
    for(int x = 0; x < result.count; x++) {
        result[x].isActive = NO;
    }
}

+ (void)storesDeactivate:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Stores"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isFromTask == %@", @NO]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isTag == %@", @YES]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    NSArray<Stores *> *result = [self fetch:db request:request];
    for(int x = 0; x < result.count; x++) {
        result[x].isTag = NO;
        result[x].isActive = NO;
    }
}

+ (void)storeContactsDeactivate:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"StoreContacts"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    NSArray<StoreContacts *> *result = [self fetch:db request:request];
    for(int x = 0; x < result.count; x++) {
        result[x].isActive = NO;
    }
}

+ (void)scheduleTimesDeactivate:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ScheduleTimes"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    NSArray<ScheduleTimes *> *result = [self fetch:db request:request];
    for(int x = 0; x < result.count; x++) {
        result[x].isActive = NO;
    }
}

+ (void)schedulesDeactivate:(NSManagedObjectContext *)db {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Schedules"];
    NSMutableArray *subpredicates = NSMutableArray.alloc.init;
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeID == %lld", [Get userID:db]]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isActive == %@", @YES]];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"isSync == %@", @YES]];
    request.predicate = [NSCompoundPredicate.alloc initWithType:NSAndPredicateType subpredicates:subpredicates];
    NSArray<Schedules *> *result = [self fetch:db request:request];
    for(int x = 0; x < result.count; x++) {
        result[x].isActive = NO;
    }
}

+ (NSArray *)fetch:(NSManagedObjectContext *)db request:(NSFetchRequest *)request {
    NSError *error = nil;
    NSArray *result = [db executeFetchRequest:request error:&error];
    if(error != nil) {
        NSLog(@"error: update fetch - %@", error.localizedDescription);
    }
    return result;
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
