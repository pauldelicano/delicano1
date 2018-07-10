#import <UIKit/UIKit.h>

@protocol TextViewDelegate
@optional

- (void)onTextViewTextChanged:(NSString *)text;

@end

@interface TextView : UITextView<UITextViewDelegate>

@property (assign) id <TextViewDelegate> textViewDelegate;
@property (strong, nonatomic) NSString *placeholder;
@property (strong, nonatomic) NSString *value;
@property (strong, nonatomic) UIColor *highlightedBorderColor;

@end
