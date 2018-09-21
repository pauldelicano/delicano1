#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Sqlite : NSObject

@property (nonatomic) sqlite3 *database;

- (BOOL)openConnection;
- (void)closeConnection;

- (BOOL)executeQuery:(NSString *)query;

@end
