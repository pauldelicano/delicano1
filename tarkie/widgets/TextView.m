#import "TextView.h"
#import "Color.h"

@interface TextView()

@property (strong, nonatomic) UIColor *placeholderColor, *valueColor, *defaultBorderColor;

@end

@implementation TextView

- (instancetype)init {
    return [self initialize:[super init]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initialize:[super initWithCoder:aDecoder]];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initialize:[super initWithFrame:frame]];
}

- (instancetype)initialize:(TextView *)instance {
    instance.delegate = self;
    self.placeholderColor = [Color colorNamed:@"Grey500"];
    self.valueColor = [Color colorNamed:@"Grey800"];
    self.defaultBorderColor = [Color colorNamed:@"Grey200"];
    self.layer.borderWidth = (1.0f / 568) * UIScreen.mainScreen.bounds.size.height;
    self.layer.borderColor = self.defaultBorderColor.CGColor;
    CGFloat inset = (12.0f / 568) * UIScreen.mainScreen.bounds.size.height;
    self.textContainer.lineFragmentPadding = 0;
    self.textContainerInset = UIEdgeInsetsMake(inset, inset, inset, inset);
    return instance;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setValue:(NSString *)value {
    if(value.length == 0) {
        self.text = self.placeholder;
        self.textColor = self.placeholderColor;
    }
    else {
        self.text = value;
        self.textColor = self.valueColor;
    }
}

- (void)textViewDidBeginEditing:(TextView *)textView {
    if([textView.text isEqualToString:self.placeholder]) {
        textView.text = @"";
        textView.textColor = self.valueColor;
    }
    textView.layer.borderColor = self.highlightedBorderColor.CGColor;
}

- (void)textViewDidEndEditing:(TextView *)textView {
    if(textView.text.length == 0) {
        textView.text = self.placeholder;
        textView.textColor = self.placeholderColor;
    }
    textView.layer.borderColor = self.defaultBorderColor.CGColor;
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [self endEditing:YES];
    }
    return YES;
}

@end
