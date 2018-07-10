#import "Http.h"
#import "Process.h"
#import "Image.h"

@implementation Http

+ (NSURLSessionDataTask *)get:(id)delegate action:(NSString *)action url:(NSString *)url params:(NSDictionary *)params timeout:(int)timeout {
    return [self request:delegate action:(NSString *)action url:url params:params file:nil timeout:timeout method:GET];
}

+ (NSURLSessionDataTask *)post:(id)delegate action:(NSString *)action url:(NSString *)url params:(NSDictionary *)params timeout:(int)timeout {
    return [self request:delegate action:(NSString *)action url:url params:params file:nil timeout:timeout method:POST];
}

+ (NSURLSessionDataTask *)postFile:(id)delegate action:(NSString *)action url:(NSString *)url params:(NSDictionary *)params file:(NSString *)file timeout:(int)timeout {
    return [self request:delegate action:(NSString *)action url:url params:params file:file timeout:timeout method:POST_FILE];
}

+ (NSURLSessionDataTask *)request:(id)delegate action:(NSString *)action url:(NSString *)url params:(NSDictionary *)params file:(NSString *)file timeout:(int)timeout method:(HTTP)method {
    __block NSError *error;
    NSData *paramsData;
    if(params != nil) {
        paramsData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    }
    if(error != nil) {
        [delegate onProcessResult:action params:params result:[self createErrorResult:error]];
        return nil;
    }
    NSMutableURLRequest *request = NSMutableURLRequest.alloc.init;
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = timeout;
    [request setValue:@"close" forHTTPHeaderField:@"Connection"];
    switch(method) {
        case GET: {
            url = [NSString stringWithFormat:@"%@%@", url, [self jsonToURL:params]];
            request.HTTPMethod = @"GET";
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
        }
        case POST: {
            request.HTTPMethod = @"POST";
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            if(paramsData != nil) {
                request.HTTPBody = paramsData;
            }
            break;
        }
        case POST_FILE: {
            request.HTTPMethod = @"POST";
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField: @"Content-Type"];
            NSMutableData *body = NSMutableData.data;
            if(paramsData != nil) {
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"params\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:paramsData];
                [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            if(file != nil) {
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"image\"; filename=\"%@\"\r\n", file] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Type: image/png\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:UIImagePNGRepresentation([Image fromDocument:file])];
                [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            request.HTTPBody = body;
        }
    }
    request.URL = [NSURL URLWithString:url];
    NSURLSessionDataTask *sessionDataTask = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:delegate delegateQueue:nil] dataTaskWithRequest:request completionHandler:^(NSData *sessionData, NSURLResponse *sessionResponse, NSError *sessionError) {
        NSLog(@"info: start\n\turl: %@\n\tparams: %@\n\tresponse: %@\nend", url, [NSString.alloc initWithData:paramsData encoding:NSUTF8StringEncoding], [NSString.alloc initWithData:sessionData encoding:NSUTF8StringEncoding]);
        if(sessionError != nil) {
            [delegate onProcessResult:action params:params result:[self createErrorResult:sessionError]];
            return;
        }
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:sessionData options:kNilOptions error:&error];
        if(error != nil) {
            [delegate onProcessResult:action params:params result:[self createErrorResult:error]];
            return;
        }
        [delegate onProcessResult:action params:params result:result];
    }];
    return sessionDataTask;
}

+ (NSString *)jsonToURL:(NSDictionary *)json {
    NSMutableString *url = NSMutableString.alloc.init;
    for(id key in json.allKeys) {
        [url appendString:url.length == 0 ? @"?" : @"&"];
        [url appendString:[NSString stringWithFormat:@"%@=%@", key, [json objectForKey:key]]];
    }
    return [url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLFragmentAllowedCharacterSet];
}

+ (NSDictionary *)createErrorResult:(NSError *)error {
    NSMutableDictionary *initDictionary = NSMutableDictionary.alloc.init;
    [initDictionary setObject:@"error" forKey:@"status"];
    [initDictionary setObject:@"0" forKey:@"recno"];
    [initDictionary setObject:error.localizedDescription forKey:@"message"];
    NSMutableArray *initArray = NSMutableArray.alloc.init;
    [initArray addObject:initDictionary];
    NSMutableDictionary *result = NSMutableDictionary.alloc.init;
    [result setObject:initArray forKey:@"init"];
    return result;
}

@end
