#import "ViewController.h"

@protocol CameraDelegate
@optional

- (void)onCameraCancel:(int)action;
- (void)onCameraCapture:(int)action image:(UIImage *)image;

@end

@interface CameraViewController : ViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

typedef enum {
    CAMERA_ACTION_TIME_IN,
    CAMERA_ACTION_TIME_OUT,
    CAMERA_ACTION_CHECK_IN,
    CAMERA_ACTION_CHECK_OUT,
    CAMERA_ACTION_VISIT_PHOTOS,
    CAMERA_ACTION_EXPENSE,
    CAMERA_ACTION_EXPENSE_START,
    CAMERA_ACTION_EXPENSE_END
} CameraAction;

@property (assign) id <CameraDelegate> cameraDelegate;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic) CameraAction action;
@property (nonatomic) BOOL isRearCamera;

@end
