#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>
#import "Company+CoreDataClass.h"
#import "Employees+CoreDataClass.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSManagedObjectContext *db, *dbTracking, *dbAlerts;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLAuthorizationStatus authorizationStatus;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) UNUserNotificationCenter *userNotificationCenter;
@property (strong, nonatomic) NSString *apiKey, *syncBatchID, *settingDisplayDateFormat, *settingDisplayTimeFormat, *settingDisplayCurrencyCode, *settingDisplayCurrencySymbol, *settingDisplayDistanceUOM, *conventionEmployees, *conventionStores, *conventionTimeIn, *conventionTimeOut, *conventionVisits, *conventionTeams, *conventionInvoice, *conventionDeliveries, *conventionReturns, *conventionSales;
@property (nonatomic) Company *company;
@property (nonatomic) Employees *employee;
@property (nonatomic) long settingLocationGPSTrackingInterval, settingAttendanceGracePeriodDuration, settingAttendanceOvertimeMinimumDuration, settingVisitsAlertNoCheckOutDistance, settingVisitsAlertNoMovementDuration, settingVisitsAlertOverstayingDuration, settingExpenseCostPerLiter;
@property (nonatomic) BOOL settingStoreAdd, settingStoreEdit, settingStoreDisplayLongName, settingLocationTracking, settingLocationGPSTracking, settingLocationGeoTagging, settingLocationAlerts, settingAttendanceStore, settingAttendanceSchedule, settingAttendanceMultipleTimeInOut, settingAttendanceTimeInPhoto, settingAttendanceTimeOutPhoto, settingAttendanceTimeOutSignature, settingAttendanceOdometerPhoto, settingAttendanceAddEditLeaves, settingAttendanceAddEditRestDays, settingAttendanceGracePeriod, settingAttendanceNotificationLateOpening, settingAttendanceNotificationTimeOut, settingVisitsAdd, settingVisitsEditAfterCheckOut, settingVisitsReschedule, settingVisitsDelete, settingVisitsInvoice, settingVisitsDeliveries, settingVisitsNotes, settingVisitsNotesForCompleted, settingVisitsNotesForNotCompleted, settingVisitsNotesForCanceled, settingVisitsNotesAsAddress, settingVisitsParallelCheckInOut, settingVisitsCheckInPhoto, settingVisitsCheckOutPhoto, settingVisitsSMSSending, settingVisitAutoPublishPhotos, settingVisitsAlertNoCheckOut, settingVisitsAlertNoMovement, settingVisitsAlertOverstaying, settingExpenseNotes, settingExpenseOriginDestination, settingInventoryTrackingV2, settingInventoryTrackingV1, settingInventoryTradeCheck, settingInventorySalesAndOfftake, settingInventoryOrders, settingInventoryDeliveries, settingInventoryAdjustments, settingInventoryPhysicalCount, setttingInventoryPhysicalCountTheoretical, settingInventoryPullOuts, settingInventoryReturns, settingInventoryStocksOnHand, moduleAttendance, moduleVisits, moduleExpense, moduleInventory, moduleForms;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
