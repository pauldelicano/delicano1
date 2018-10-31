#import "CameraViewController.h"
#import "AppDelegate.h"
#import "Get.h"
#import "View.h"
#import "Time.h"
#import "MessageDialogViewController.h"

@interface CameraViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@end

@implementation CameraViewController

static MessageDialogViewController *vcMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker = UIImagePickerController.alloc.init;
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.cameraDevice = !self.isRearCamera ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
        self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        self.imagePicker.allowsEditing = NO;
        self.imagePicker.view.frame = self.view.bounds;
        [View addChildViewController:self childViewController:self.imagePicker animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        vcMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"vcMessage"];
        vcMessage.subject = @"Camera Access";
        vcMessage.message = @"Device has no camera.";
        vcMessage.positiveTitle = @"OK";
        vcMessage.positiveTarget = ^{
            [View removeChildViewController:vcMessage animated:NO];
            [self.navigationController popViewControllerAnimated:YES];
            [self.cameraDelegate onCameraCancel:self.action];
        };
        [View addChildViewController:self childViewController:vcMessage animated:YES];
        return;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self.navigationController popViewControllerAnimated:NO];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    CGSize size = CGSizeMake(UIScreen.mainScreen.bounds.size.width, image.size.height * (UIScreen.mainScreen.bounds.size.width / image.size.width));
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    CGFloat margin = (6.0f / 568) * UIScreen.mainScreen.bounds.size.height;
    NSString *timestamp = [NSString stringWithFormat:@"%@\n%@ %@\n%@", [Time getFormattedDate:[NSString stringWithFormat:@"%@ %@", self.app.settingDisplayDateFormat, self.app.settingDisplayTimeFormat] date:NSDate.date], self.app.employee.firstName, self.app.employee.lastName, self.app.company.name];
    UIFont *timestampFont = [UIFont fontWithName:@"ProximaNova-Regular" size:(12.0f / 568) * UIScreen.mainScreen.bounds.size.height];
    CGSize timestampSize = [timestamp sizeWithAttributes:@{NSFontAttributeName:timestampFont}];
    [timestamp drawInRect:CGRectMake(margin, size.height - timestampSize.height - margin, timestampSize.width, timestampSize.height) withAttributes:@{NSFontAttributeName:timestampFont, NSForegroundColorAttributeName:UIColor.whiteColor}];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.cameraDelegate onCameraCapture:self.action image:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.navigationController popViewControllerAnimated:NO];
    [self.cameraDelegate onCameraCancel:self.action];
}

@end
