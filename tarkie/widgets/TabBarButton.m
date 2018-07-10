#import "TabBarButton.h"

@implementation TabBarButton

- (instancetype)init {
    self = [super init];
    _ivIcon = [[UIImageView alloc] init];
    _ivIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_ivIcon];
    _lTitle = [[UILabel alloc] init];
    _lTitle.backgroundColor = UIColor.clearColor;
    _lTitle.textColor = UIColor.whiteColor;
    _lTitle.textAlignment = NSTextAlignmentCenter;
    _lTitle.font = [UIFont fontWithName:@"Helvetica" size:10];
    [self addSubview:_lTitle];
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if(self.subviews.count != 0) {
        int width = frame.size.width;
        int height = frame.size.height;
        _ivIcon.frame = CGRectMake(0, height * 0.2, width, height * 0.4);
        _lTitle.frame = CGRectMake(0, height * 0.55, width, height * 0.30);
    }
}

- (void)setIcon:(UIImage *)icon {
    _ivIcon.image = icon;
}

- (void)setTitle:(NSString *)title {
    _lTitle.text = title;
}

- (void)setIsSelected:(BOOL)isSelected {
    self.backgroundColor = isSelected ? [UIColor colorNamed:@"BlackTransThirty"] : nil;
}

@end
