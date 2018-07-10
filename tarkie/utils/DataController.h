#import <CoreData/CoreData.h>

@interface DataController : NSObject

@property (strong, nonatomic) NSManagedObjectContext *db;

- (instancetype)initWithDatabaseName:(NSString *)dbName;

@end
