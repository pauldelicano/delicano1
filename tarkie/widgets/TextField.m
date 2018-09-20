#import "TextField.h"
#import "Color.h"

@interface TextField()

@property (strong, nonatomic) UIColor *defaultBorderColor;

@end

@implementation TextField

- (instancetype)init {
    return [self initialize:[super init]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initialize:[super initWithCoder:aDecoder]];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initialize:[super initWithFrame:frame]];
}

- (instancetype)initialize:(TextField *)instance {
    instance.delegate = self;
    self.defaultBorderColor = [Color colorNamed:@"Grey200"];
    self.layer.borderWidth = (1.0f / 568) * UIScreen.mainScreen.bounds.size.height;
    self.layer.borderColor = self.defaultBorderColor.CGColor;
    return instance;
}

- (void)textFieldDidBeginEditing:(TextField *)textField {
    textField.layer.borderColor = self.highlightedBorderColor.CGColor;
}

- (void)textFieldDidEndEditing:(TextField *)textField {
    textField.layer.borderColor = self.defaultBorderColor.CGColor;
}

- (BOOL)textFieldShouldReturn:(TextField *)textField {
    [textField endEditing:YES];
    return YES;
}

- (BOOL)textField:(TextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self.textFieldDelegate onTextFieldTextChanged:[textField.text stringByReplacingCharactersInRange:range withString:string]];
    return YES;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGFloat inset = (12.0f / 568) * UIScreen.mainScreen.bounds.size.height;
    return CGRectInset(bounds, inset, inset);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGFloat inset = (12.0f / 568) * UIScreen.mainScreen.bounds.size.height;
    return CGRectInset(bounds, inset, inset);
}

@end
