#import "File.h"
#import "Time.h"

@implementation File

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

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageFromCaches:(NSString *)filename {
    return [UIImage imageWithContentsOfFile:[self cachesPath:filename]];
}

+ (UIImage *)imageFromDocument:(NSString *)filename {
    return [UIImage imageWithContentsOfFile:[self documentPath:filename]];
}

+ (UIImage *)saveImageFromImage:(NSString *)path image:(UIImage *)image {
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

+ (UIImage *)saveImageFromURL:(NSString *)path url:(NSString *)url {
    UIImage *directoryImage = [UIImage imageWithContentsOfFile:path];
    if(directoryImage == nil) {
        if([NSFileManager.defaultManager createFileAtPath:path contents:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]] attributes:nil]) {
            directoryImage = [UIImage imageWithContentsOfFile:path];
        }
    }
    return directoryImage;
}

+ (NSData *)saveDataFromData:(NSString *)path data:(NSData *)data {
    NSData *directoryData = [NSData.alloc initWithContentsOfFile:path];
    if(directoryData == nil) {
        NSData *contents;
        if([path.pathExtension.lowercaseString isEqualToString:@"zip"]) {
            contents = data;
        }
        if(contents != nil && [NSFileManager.defaultManager createFileAtPath:path contents:contents attributes:nil]) {
            directoryData = [NSData.alloc initWithContentsOfFile:path];
        }
    }
    return directoryData;
}

+ (BOOL)saveExceptionToBackup:(NSException *)exception {
    return [self saveTextToBackup:[NSString stringWithFormat:@"EXCEPTION\n\nname: %@\n\nreason: %@\n\nuserInfo: %@\n\ncallStackReturnAddresses: %@\n\ncallStackSymbols: %@", exception.name, exception.reason, exception.userInfo, exception.callStackReturnAddresses, exception.callStackSymbols]];
}

+ (BOOL)saveTextToBackup:(NSString *)text {
    if(![NSFileManager.defaultManager createDirectoryAtPath:[File documentPath:@"Backup"] withIntermediateDirectories:YES attributes:nil error:nil]) {
        return NO;
    }
    NSString *fileName = [Time getFormattedDate:[NSString stringWithFormat:@"%@ %@", DATE_FORMAT, TIME_FORMAT] date:NSDate.date];
    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    fileName = [fileName stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    NSString *file = [File documentPath:[NSString stringWithFormat:@"Backup/%@.txt", fileName]];
    return [NSFileManager.defaultManager createFileAtPath:file contents:[text dataUsingEncoding:NSUnicodeStringEncoding] attributes:nil];
}

@end
