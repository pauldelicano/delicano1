#import "ViewController.h"
#import "Company+CoreDataClass.h"
#import "Employees+CoreDataClass.h"

@protocol DrawerDelegate
@optional

- (void)onDrawerMenuSelect:(int)menu;

@end

@interface DrawerViewController : ViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tvDrawer;

typedef enum {
    DRAWER_POSITION_LEFT,
    DRAWER_POSITION_RIGHT
} DrawerPosition;

@property (assign) id <DrawerDelegate> delegate;
@property (nonatomic) DrawerPosition position;

@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *openGesture;
@property (strong, nonatomic) UIPanGestureRecognizer *closeGesture;

@property (strong, nonatomic) Company *company;
@property (strong, nonatomic) Employees *employee;
@property (strong, nonatomic) NSArray<NSDictionary *> *menus;
@property (nonatomic) BOOL isOpen;

- (void)openDrawer;
- (void)closeDrawer;

@end
