#import "CustomViewController.h"

@protocol CameraDelegate
@optional

- (void)onCameraCancel:(int)action;
- (void)onCameraCapture:(int)action image:(UIImage *)image;

@end

@interface CameraViewController : CustomViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

typedef enum {
    CAMERA_ACTION_TIME_IN,
    CAMERA_ACTION_TIME_OUT,
    CAMERA_ACTION_CHECK_IN,
    CAMERA_ACTION_CHECK_OUT,
    CAMERA_ACTION_VISIT_PHOTOS
} CameraAction;

@property (assign) id <CameraDelegate> cameraDelegate;
@property (nonatomic) CameraAction action;
@property (nonatomic) BOOL isRearCamera;

@end
