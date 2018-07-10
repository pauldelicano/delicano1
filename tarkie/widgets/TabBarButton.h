#import <UIKit/UIKit.h>

@interface TabBarButton : UIButton

@property (strong, nonatomic) UIImageView *ivIcon;
@property (strong, nonatomic) UILabel *lTitle;

- (void)setIcon:(UIImage *)icon;
- (void)setTitle:(NSString *)title;
- (void)setIsSelected:(BOOL)isSelected;

@end
