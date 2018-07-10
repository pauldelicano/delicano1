#import <UIKit/UIKit.h>

@protocol TextFieldDelegate
@optional

- (void)onTextFieldTextChanged:(NSString *)text;

@end

@interface TextField : UITextField<UITextFieldDelegate>

@property (assign) id <TextFieldDelegate> textFieldDelegate;
@property (strong, nonatomic) UIColor *highlightedBorderColor;

@end
