#import "CameraViewController.h"
#import "AppDelegate.h"
#import "Get.h"
#import "Time.h"

@interface CameraViewController()

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.imagePicker = UIImagePickerController.alloc.init;
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.cameraDevice = !self.isRearCamera ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
    self.imagePicker.view.frame = self.view.bounds;
    [self.view addSubview:self.imagePicker.view];
    [self addChildViewController:self.imagePicker];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self.navigationController popViewControllerAnimated:NO];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGSize size = CGSizeMake(UIScreen.mainScreen.bounds.size.width, image.size.height * (UIScreen.mainScreen.bounds.size.width / image.size.width));
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    CGFloat margin = (6.0f / 568) * UIScreen.mainScreen.bounds.size.height;
    Employees *employee = [Get employee:self.app.db employeeID:self.app.userID];
    NSString *timestamp = [NSString stringWithFormat:@"%@\n%@ %@\n%@", [Time getFormattedDate:[NSString stringWithFormat:@"%@ %@", self.app.settingDisplayDateFormat, self.app.settingDisplayTimeFormat] date:NSDate.date], employee.firstName, employee.lastName, [Get company:self.app.db].name];
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
