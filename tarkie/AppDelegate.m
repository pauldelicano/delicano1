#import "AppDelegate.h"

@interface AppDelegate()

@property (strong, nonatomic) NSPersistentStoreCoordinator *psc;
@property (nonatomic) BOOL applicationDidEnterBackground, isUpdatingLocation;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.psc = [self persistentStoreCoordinatorInit:@"tarkie.db"];
    self.db = [self managedObjectContextInit:self.psc];
    self.dbSync = [self managedObjectContextInit:self.psc];
    self.dbTracking = [self managedObjectContextInit:self.psc];
    self.locationManager = [self locationManagerInit:self];
    self.userNotificationCenter = [self userNotificationCenterInit:self];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    self.applicationDidEnterBackground = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.applicationDidEnterBackground = YES;
    if(self.isUpdatingLocation && self.authorizationStatus != kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager stopUpdatingLocation];
    }
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorInit:(NSString *)dbName {
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [NSPersistentStoreCoordinator.alloc initWithManagedObjectModel:[NSManagedObjectModel.alloc initWithContentsOfURL:[NSBundle.mainBundle URLForResource:@"DataModel" withExtension:@"momd"]]];
    NSError *error = nil;
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[[NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject URLByAppendingPathComponent:dbName] options:[NSDictionary dictionaryWithObjectsAndKeys:@(YES), NSMigratePersistentStoresAutomaticallyOption, @(YES), NSInferMappingModelAutomaticallyOption, nil] error:&error];
    if(error != nil) {
        NSLog(@"error: appDelegate persistentStoreCoordinatorInit - %@", error.localizedDescription);
    }
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContextInit:(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext.alloc initWithConcurrencyType:NSMainQueueConcurrencyType];
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    return managedObjectContext;
}

- (CLLocationManager *)locationManagerInit:(id)delegate {
    CLLocationManager *locationManager = CLLocationManager.alloc.init;
    locationManager.delegate = delegate;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.pausesLocationUpdatesAutomatically = NO;
    locationManager.allowsBackgroundLocationUpdates = YES;
    return locationManager;
}

- (UNUserNotificationCenter *)userNotificationCenterInit:(id)delegate {
    UNUserNotificationCenter *userNotificationCenter = UNUserNotificationCenter.currentNotificationCenter;
    userNotificationCenter.delegate = delegate;
    [userNotificationCenter requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error){
        if(error != nil) {
            NSLog(@"error: appDelegate userNotificationCenterInit - %@", error.localizedDescription);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication.sharedApplication registerForRemoteNotifications];
        });
    }];
    return userNotificationCenter;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    self.authorizationStatus = status;
    if(self.isUpdatingLocation) {
        [self startUpdatingLocation];
    }
    if(self.applicationDidEnterBackground && self.isUpdatingLocation && self.authorizationStatus != kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.location = locations.lastObject;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert);
    [NSNotificationCenter.defaultCenter postNotificationName:@"UserNotificationCenterWillPresentNotification" object:nil userInfo:notification.request.content.userInfo];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    completionHandler();
    [NSNotificationCenter.defaultCenter postNotificationName:@"UserNotificationCenterDidReceiveNotificationResponse" object:nil userInfo:response.notification.request.content.userInfo];
}

- (void)startUpdatingLocation {
    [self.locationManager startUpdatingLocation];
    self.isUpdatingLocation = YES;
}

- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
    self.isUpdatingLocation = NO;
}

@end
