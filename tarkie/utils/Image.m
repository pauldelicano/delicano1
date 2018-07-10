#import "Image.h"

@implementation Image

+ (NSString *)cachesPath:(NSString *)filename {
    return [[NSFileManager.defaultManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].lastObject URLByAppendingPathComponent:filename].path;
}

+ (NSString *)documentPath:(NSString *)filename {
    return [[NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject URLByAppendingPathComponent:filename].path;
}

+ (BOOL)deleteFromCaches:(NSString *)filename {
    return [self deleteFromDirectory:[self cachesPath:filename]];
}

+ (BOOL)deleteFromDocument:(NSString *)filename {
    return [self deleteFromDirectory:[self documentPath:filename]];
}

+ (BOOL)deleteFromDirectory:(NSString *)path {
    if(![NSFileManager.defaultManager fileExistsAtPath:path]) {
        return YES;
    }
    NSError *error = nil;
    BOOL isDeleted = [NSFileManager.defaultManager removeItemAtPath:path error:&error];
    if(error != nil) {
        NSLog(@"error: image deleteFromDirectory - %@", error.localizedDescription);
    }
    return isDeleted;
}

+ (UIImage *)fromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)fromCaches:(NSString *)filename {
    return [UIImage imageWithContentsOfFile:[self cachesPath:filename]];
}

+ (UIImage *)fromDocument:(NSString *)filename {
    return [UIImage imageWithContentsOfFile:[self documentPath:filename]];
}

+ (UIImage *)saveFromImage:(NSString *)path image:(UIImage *)image {
    UIImage *directoryImage = [UIImage imageWithContentsOfFile:path];
    if(directoryImage == nil) {
        NSData *contents;
        if([path.pathExtension.lowercaseString isEqualToString:@"png"]) {
            if(image.imageOrientation != UIImageOrientationUp) {
                UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
                [image drawInRect:(CGRect){0, 0, image.size}];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            contents = UIImagePNGRepresentation(image);
        }
        if(contents != nil && [NSFileManager.defaultManager createFileAtPath:path contents:contents attributes:nil]) {
            directoryImage = [UIImage imageWithContentsOfFile:path];
        }
    }
    return directoryImage;
}

+ (UIImage *)saveFromURL:(NSString *)path url:(NSString *)url {
    UIImage *directoryImage = [UIImage imageWithContentsOfFile:path];
    if(directoryImage == nil) {
        if([NSFileManager.defaultManager createFileAtPath:path contents:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]] attributes:nil]) {
            directoryImage = [UIImage imageWithContentsOfFile:path];
        }
    }
    return directoryImage;
}

@end
