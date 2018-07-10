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
    SETTING_1,
    SETTING_2
} Setting;

@end
