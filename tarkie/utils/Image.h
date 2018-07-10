#import <UIKit/UIKit.h>

@interface Image : NSObject

+ (NSString *)cachesPath:(NSString *)filename;
+ (NSString *)documentPath:(NSString *)filename;
+ (BOOL)deleteFromCaches:(NSString *)filename;
+ (BOOL)deleteFromDocument:(NSString *)filename;
+ (UIImage *)fromColor:(UIColor *)color;
+ (UIImage *)fromCaches:(NSString *)filename;
+ (UIImage *)fromDocument:(NSString *)filename;
+ (UIImage *)saveFromImage:(NSString *)path image:(UIImage *)image;
+ (UIImage *)saveFromURL:(NSString *)path url:(NSString *)url;

@end
