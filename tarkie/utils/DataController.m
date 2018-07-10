#import "DataController.h"

@implementation DataController

- (id)initWithDatabaseName:(NSString *)dbName {
    self = super.init;
    self.db = [NSManagedObjectContext.alloc initWithConcurrencyType:NSMainQueueConcurrencyType];
    NSPersistentStoreCoordinator *psc = [NSPersistentStoreCoordinator.alloc initWithManagedObjectModel:[NSManagedObjectModel.alloc initWithContentsOfURL:[NSBundle.mainBundle URLForResource:@"DataModel" withExtension:@"momd"]]];
    NSError *error = nil;
    [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[[NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject URLByAppendingPathComponent:dbName] options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil] error:&error];
    self.db.persistentStoreCoordinator = psc;
    return self;
}

@end
