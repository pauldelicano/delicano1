#import "CameraViewController.h"
#import "Time.h"

@interface CameraViewController()

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    NSString *timestamp = [Time formatDate:@"MMM d, yyyy h:mm:ss a" date:NSDate.date];
    UIFont *timestampFont = [UIFont fontWithName:@"ProximaNova-Regular" size:(30.0f / 568) * UIScreen.mainScreen.bounds.size.height];
    CGSize timestampSize = [timestamp sizeWithAttributes:@{NSFontAttributeName:timestampFont}];
    CGFloat margin = (24.0f / 568) * UIScreen.mainScreen.bounds.size.height;
    [timestamp drawInRect:CGRectMake(margin, image.size.height - timestampSize.height - margin, timestampSize.width, timestampSize.height) withAttributes:@{NSFontAttributeName:timestampFont, NSForegroundColorAttributeName:UIColor.whiteColor}];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.cameraDelegate onCameraCapture:self.action image:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.navigationController popViewControllerAnimated:NO];
    [self.cameraDelegate onCameraCancel:self.action];
}

@end
