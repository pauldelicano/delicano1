#import <UIKit/UIKit.h>

@interface File : NSObject

+ (NSString *)cachesPath:(NSString *)filename;
+ (NSString *)documentPath:(NSString *)filename;
+ (BOOL)deleteFromCaches:(NSString *)filename;
+ (BOOL)deleteFromDocument:(NSString *)filename;
+ (UIImage *)imageFromColor:(UIColor *)color;
+ (UIImage *)imageFromCaches:(NSString *)filename;
+ (UIImage *)imageFromDocument:(NSString *)filename;
+ (UIImage *)saveImageFromImage:(NSString *)path image:(UIImage *)image;
+ (UIImage *)saveImageFromURL:(NSString *)path url:(NSString *)url;
+ (NSData *)saveDataFromData:(NSString *)path data:(NSData *)data;
+ (BOOL)saveExceptionToBackup:(NSException *)exception;
+ (BOOL)saveTextToBackup:(NSString *)text;

@end
