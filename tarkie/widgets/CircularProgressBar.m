#import "CircularProgressBar.h"
#import "Color.h"

@interface CircularProgressBar()

@end

@implementation CircularProgressBar

- (instancetype)init {
    return [self initialize:[super init]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initialize:[super initWithCoder:aDecoder]];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initialize:[super initWithFrame:frame]];
}

- (instancetype)initialize:(CircularProgressBar *)instance {
    return instance;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGFloat startAngle = M_PI * 1.5;
    CGFloat endAngle = startAngle + (M_PI * 2);
    CGFloat lineWidth = (2.5f / 568) * UIScreen.mainScreen.bounds.size.height;

    UIBezierPath *path = UIBezierPath.bezierPath;
    path.lineWidth = lineWidth;
    [path addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2) radius:(rect.size.width - lineWidth) / 2 startAngle:startAngle endAngle:(endAngle - startAngle) + startAngle clockwise:YES];
    [[Color colorNamed:@"BlackTransThirty"] setStroke];
    [path stroke];

    path = UIBezierPath.bezierPath;
    path.lineWidth = lineWidth;
    [path addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2) radius:(rect.size.width - lineWidth) / 2 startAngle:startAngle endAngle:((endAngle - startAngle) * self.progress) + startAngle clockwise:YES];
    [self.progressTintColor setStroke];
    [path stroke];
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    self.text = [NSString stringWithFormat:@"%d%%", (int)floor(self.progress * 100)];
}

@end
