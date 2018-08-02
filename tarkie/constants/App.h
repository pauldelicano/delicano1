#import <Foundation/Foundation.h>

@interface App : NSObject

#define API_KEY @"V0gu1964h5j762s7WiG52i45CMg1s9Xo8dbX565P20m3w7U7CA"

#ifdef FLAVOR_SEVIE
    #define APP_LOGO [UIImage imageNamed:@"AppLogo.sevie"]
    #define APP_NAME @"Sevie"
    #define THEME_PRI [UIColor colorNamed:@"ThemePri.sevie"]
    #define THEME_SEC [UIColor colorNamed:@"ThemeSec.sevie"]
    #define THEME_PRI_DARK [UIColor colorNamed:@"ThemePriDark.sevie"]
#elif FLAVOR_TIMSIE
    #define APP_LOGO [UIImage imageNamed:@"AppLogo.timsie"]
    #define APP_NAME @"Timsie"
    #define THEME_PRI [UIColor colorNamed:@"ThemePri.timsie"]
    #define THEME_SEC [UIColor colorNamed:@"ThemeSec.timsie"]
    #define THEME_PRI_DARK [UIColor colorNamed:@"ThemePriDark.timsie"]
#endif

typedef enum {
    //COMPANY
    //code = setGen-003-01, name = Currency", value = string: php, implemented
    SETTING_DISPLAY_CURRENCY = 1565,
    //code = setGen-003-02, name = Date Format", value = number: id,  implemented
    SETTING_DISPLAY_DATE_FORMAT = 1566,
    //code = setGen-003-03, name = Time Format", value = string: 12/24, implemented
    SETTING_DISPLAY_TIME_FORMAT = 1567,
    //code = setGen-003-04, name = Distance UOM", value = number: id, pending
    SETTING_DISPLAY_DISTANCE_UOM = 1568,
    
    //LOCATION
    //code = setGen-001-01, name = Route Tracking, value = yes/no, pending
    SETTING_LOCATION_TRACKING = 39,
    //code = setGen-001-02, name = GPS Interval, value = yes/no, pending
    SETTING_LOCATION_GPS_TRACKING = 41,
    //code = setGen-001-07, name = GPS Interval Minutes", value = minutes, pending
    SETTING_LOCATION_GPS_TRACKING_INTERVAL = 102,
    //code = setGen-001-03, name = Geo Tagging, value = yes/no, pending
    SETTING_LOCATION_GEO_TAGGING = 40,
    //code = setGen-001-04, name = Location-related Alerts, value = yes/no, pending
    SETTING_LOCATION_ALERTS = 42,

    //STORES
    //code = setGen-002-01, name = Allow Employee to Add Store/Clients in App?, value = yes/no, implemented
    SETTING_STORE_ADD = 61,
    //code = setGen-002-02, name = Allow Employee to Edit Store/Clients in App?, value = yes/no, implemented
    SETTING_STORE_EDIT = 62,
    //code = setGen-002-03, name = Use Store/Client Long Name in App?, value = yes/no, implemented
    SETTING_STORE_DISPLAY_LONG_NAME = 378,

    //ATTENDANCE
    //code = SetAtt-001-01, name = Allow Employee to Select Store upon Start Day/End Day?, value = yes/no, implemented
    SETTING_ATTENDANCE_STORE = 3,
    //code = SetAtt-001-07, name = Allow Employee to Select Schedule?, value = yes/no, implemented
    SETTING_ATTENDANCE_SCHEDULE = 171,
    //code = SetAtt-001-02, name = Allow Multiple Start Day?, value = yes/no, implemented
    SETTING_ATTENDANCE_MULTIPLE_TIME_IN_OUT = 6,
    //code = SetAtt-001-03, name = Require Photo at Start Day?, value = yes/no, implemented
    SETTING_ATTENDANCE_TIME_IN_PHOTO = 4,
    //code = SetAtt-001-04, name = Require Photo at End Day?, value = yes/no, implemented
    SETTING_ATTENDANCE_TIME_OUT_PHOTO = 5,
    //code = SetAtt-001-06, name = Require Signature at End Day?, value = yes/no, implemented
    SETTING_ATTENDANCE_TIME_OUT_SIGNATURE = 8,
    //code = SetAtt-001-05, name = Require Odometer at Start and End Day?, value = yes/no, implemented
    SETTING_ATTENDANCE_ODOMETER_PHOTO = 7,
    //code = SetAtt-002-01, name = Allow Employee to add / edit Leaves in app?, value = yes/no, pending
    SETTING_ATTENDANCE_ADD_EDIT_LEAVES = 22,
    //code = SetAtt-002-02, name = Allow Employee to add / edit Rest Days in app?, value = yes/no, pending
    SETTING_ATTENDANCE_ADD_EDIT_REST_DAYS = 23,
    //code = SetAtt-004-03, name = Set Grace Period Per Teams, value = yes/no, pending
    SETTING_ATTENDANCE_GRACE_PERIOD = 1574,
    //code = SetAtt-004-02, name = Set Grace Period", value = minutes, pending
    SETTING_ATTENDANCE_GRACE_PERIOD_DURATION = 1573,
    //code = SetAtt-004-01, name = Set Mininum Overtime", value = hours, pending
    SETTING_ATTENDANCE_OVERTIME_MINIMUM_DURATION = 1572,
    //code = SetAtt-003-02, name = Email Late Opening Notification, value = yes/no, pending
    SETTING_ATTENDANCE_NOTIFICATION_LATE_OPENING = 9,
    //code = SetAtt-003-01, name = Set End Day Alarm, value = yes/no, pending
    SETTING_ATTENDANCE_NOTIFICATION_TIME_OUT = 10,

    //VISITS
    //code = SetIti-001-01, name = Allow Employee to Add Visits in App?, value = yes/no, implemented
    SETTING_VISITS_ADD = 27,
    //code = SetIti-001-06, name = Do not Allow Changes to Visit After Check-out?, value = yes/no, implemented
    SETTING_VISITS_EDIT_AFTER_CHECK_OUT = 58,
    //code = SetIti-001-02, name = Allow Employee to Reschedule Visits in App?, value = yes/no
    SETTING_VISITS_RESCHEDULE = 28,
    //code = SetIti-001-03, name = Allow Employee to Delete Visits in App?, value = yes/no, implemented
    SETTING_VISITS_DELETE = 55,
    //code = SetIti-001-10, name = Show Invoice Number in App, value = yes/no, implemented
    SETTING_VISITS_INVOICE = 1576,
    //code = SetIti-001-11, name = Show Delivery Fee in App, value = yes/no, implemented
    SETTING_VISITS_DELIVERIES = 1577,
    //code = SetIti-001-05, name = Require 'General' Notes?, value = yes/no, implemented
    SETTING_VISITS_NOTES = 57,
    //code = SetIti-001-09, name = Require Remarks for Completed Visits?, value = yes/no, implemented
    SETTING_VISITS_NOTES_FOR_COMPLETED = 1575,
    //code = SetIti-001-07, name = Require Remarks for Not Completed Visits?, value = yes/no, implemented
    SETTING_VISITS_NOTES_FOR_NOT_COMPLETED = 31,
    //code = SetIti-001-08, name = Require Remarks for Cancelled Visits?, value = yes/no, implemented
    SETTING_VISITS_NOTES_FOR_CANCELED = 208,
    //code = SetIti-001-13, name = Show Notes instead of Address in App, value = yes/no, implemented
    SETTING_VISITS_NOTES_AS_ADDRESS = 1579,
    //code = SetIti-001-04, name = Allow Employee to Parallel Check-in/Check-out?, value = yes/no, implemented
    SETTING_VISITS_PARALLEL_CHECK_IN_OUT = 56,
    //code = SetIti-002-01, name = Require Check-in Photo?, value = yes/no, implemented
    SETTING_VISITS_CHECK_IN_PHOTO = 29,
    //code = SetIti-002-02, name = Require Check-out Photo?, value = yes/no, implemented
    SETTING_VISITS_CHECK_OUT_PHOTO = 30,
    //code = SetIti-001-12, name = Use SMS Sending, value = yes/no
    SETTING_VISITS_SMS_SENDING = 1578,
    //code = SetIti-002-03, name = Auto-Publish Photos in Feed?, value = yes/no
    SETTING_VISITS_AUTO_PUBLISH_PHOTOS = 59,
    //code = setGen-001-05, name = Activate Check-out Reminder, value = yes/no
    SETTING_VISITS_ALERT_NO_CHECK_OUT = 43,
    //code = setGen-001-08, name = Checkout Reminders Meter", value = meters
    SETTING_VISITS_ALERT_NO_CHECK_OUT_DISTANCE = 1570,
    //code = setGen-001-06, name = No Movement Outside of a Visit, value = yes/no
    SETTING_VISIT_ALERT_NO_MOVEMENT = 44,
    //code = setGen-001-09, name = No Movement Minutes", value = minutes
    SETTING_VISIT_ALERT_NO_MOVEMENT_DURATION = 1571,
    //code = setGen-001-10, name = Overstaying in Visit, value = yes/no
    SETTING_VISIT_ALERT_OVERSTAYING = 1564,
    //code = setGen-001-11, name = Overstaying in Visit Hours", value = hours
    SETTING_VISIT_ALERT_OVERSTAYING_DURATION = 1569,

    //EXPENSE
    //code = SetExp-001-01, name = Require Notes?, value = yes/no
    SETTING_EXPENSE_NOTES = 1,
    //code = SetExp-001-02, name = Require Origin and Destination Fields?, value = yes/no
    SETTING_EXPENSE_ORIGIN_DESTINATION = 2,
    //code = SetExp-001-03, name = Cost Per Liter", value = number
    SETTING_EXPENSE_COST_PER_LITER = 26,

    //INVENTORY
    //code = setInv-000-09, name = Inventory Tracking V2, value = yes/no
    SETTING_INVENTORY_TRACKING_V2 = 1580,
    //code = setInv-000-01, name = Inventory Tracking V1 & Expiration Tracking, value = yes/no
    SETTING_INVENTORY_TRACKING_V1 = 662,
    //code = setInv-000-02, name = Trade Check, value = yes/no
    SETTING_INVENTORY_TRADE_CHECK = 663,
    //code = setInv-000-03, name = Sales & Offtake, value = yes/no
    SETTING_INVENTORY_SALES_AND_OFFTAKE = 664,
    //code = setInv-000-10, name = Orders
    SETTING_INVENTORY_ORDERS = 1581,
    //code = setInv-000-04, name = Deliveries
    SETTING_INVENTORY_DELIVERIES = 1582,
    //code = setInv-000-11, name = Adjustments
    SETTING_INVENTORY_ADJUSTMENTS = 1583,
    //code = setInv-000-05, name = Physical Count
    SETTING_INVENTORY_PHYSICAL_COUNT = 1584,
    //code = setInv-001-01, name = Show theoretical count
    SETTING_INVENTORY_PHYSICAL_COUNT_THEORETICAL = 1585,
    //code = setInv-000-06, name = Pull-Outs
    SETTING_INVENTORY_PULL_OUTS = 1588,
    //code = setInv-000-07, name = Customer Return
    SETTING_INVENTORY_RETURNS = 1587,
    //code = setInv-000-08, name = Stocks On-hand
    SETTING_INVENTORY_STOCKS_ON_HAND = 1586
} Setting;

typedef enum {
    CONVENTION_EMPLOYEES = 1,
    CONVENTION_STORES = 2,
    CONVENTION_TIME_IN = 3,
    CONVENTION_TIME_OUT = 4,
    CONVENTION_VISITS = 5,
    CONVENTION_TEAMS = 6,
    CONVENTION_INVOICE = 7,
    CONVENTION_DELIVERIES = 8,
    CONVENTION_RETURNS = 9,
    CONVENTION_SALES = 10
} Convention;

typedef enum {
    MENU_TIME_IN_OUT = 1,
    MENU_BREAKS = 2,
    MENU_STORES = 3,
    MENU_UPDATE_MASTER_FILE = 4,
    MENU_SEND_BACKUP_DATA = 5,
    MENU_BACKUP_DATA = 6,
    MENU_ABOUT = 7,
    MENU_LOGOUT = 8
} Menu;

typedef enum {
    MODULE_ATTENDANCE = 1,
    MODULE_VISITS = 2,
    MODULE_EXPENSE = 3,
    MODULE_INVENTORY = 4,
    MODULE_FORMS = 5
} Module;

@end
