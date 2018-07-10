#import "SignatureView.h"

@implementation SignatureView

- (instancetype)init {
    return [self initialize:[super init]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initialize:[super initWithCoder:aDecoder]];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initialize:[super initWithFrame:frame]];
}

- (instancetype)initialize:(SignatureView *)instance {
    self.multipleTouchEnabled = NO;
    self.path = UIBezierPath.bezierPath;
    self.path.lineWidth = 2;
    return instance;
}

- (void)drawRect:(CGRect)rect {
    self.path.lineCapStyle = kCGLineCapRound;
    [self.path stroke];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches.allObjects objectAtIndex:0];
    [self.path moveToPoint:[touch locationInView:self]];
    [self.path addLineToPoint:[touch locationInView:self]];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches.allObjects objectAtIndex:0];
    [self.path addLineToPoint:[touch locationInView:self]];
    [self setNeedsDisplay];
}

- (void)clear {
    self.path = UIBezierPath.bezierPath;
    self.path.lineWidth = 2;
    [self setNeedsDisplay];
}

@end
