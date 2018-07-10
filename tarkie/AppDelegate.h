#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSManagedObjectContext *db, *dbSync, *dbTracking;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLAuthorizationStatus authorizationStatus;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) UNUserNotificationCenter *userNotificationCenter;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
