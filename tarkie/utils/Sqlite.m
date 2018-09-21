#import "Sqlite.h"
#import "File.h"

@implementation Sqlite

- (id)init {
    return self;
}

- (BOOL)openConnection {
    BOOL result = NO;
    if(sqlite3_open([File documentPath:@"tarkie.db"].UTF8String, &_database) == SQLITE_OK) {
        result = YES;
    }
    return result;
}

- (void)closeConnection {
    sqlite3_close(_database);
}

- (BOOL)executeQuery:(NSString *)query {
    BOOL result = NO;
    if(sqlite3_exec(_database, query.UTF8String, NULL, NULL, NULL) == SQLITE_OK) {
        result = YES;
    }
    else {
        const char *error = sqlite3_errmsg(_database);
        NSLog(@"paul: sqlite - %s", error);
        [File saveTextToBackup:[NSString stringWithFormat:@"SQLITE%s", error]];
    }
    return result;
}

@end
