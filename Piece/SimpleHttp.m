//
//  SimpleHttp.m
//  Piece
//
//  Created by 金小平 on 15/11/14.
//  Copyright © 2015年 金小平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleHttp.h"
#import <UIKit/UIKit.h>

@implementation SimpleHttp

+ (void)requestLogin:(NSString *)name withPassword:(NSString *)password responseBlock:(void(^)(NSData *data, NSURLResponse *response, NSError *error))block
{
    
    //NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    //NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://127.0.0.1:3000/users/login"]];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *dictionary = @{@"username":name, @"password": password};
    NSError *error = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    request.HTTPBody = bodyData;
    
    if (!error) {
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                    completionHandler:block];
        [dataTask resume];
    }
    
}

+ (void)requestRegister:(NSString *)name withPassword:(NSString *)password
{
    
    //NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    //NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://127.0.0.1:3000/users/register"]];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *dictionary = @{@"username":name, @"password": password};
    NSError *error = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    request.HTTPBody = bodyData;
    
    if (!error) {
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        if (!error) {
                                                            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                            if (dict[@"error"]) {
                                                                NSLog(@"dictionary error : %@", dict[@"error"]);
                                                            } else {
                                                                NSLog(@"%@", dict[@"username"]);
                                                            }
                                                        } else {
                                                            NSLog(@"error : %@", error.description);
                                                        }
                                                    }];
        [dataTask resume];
    }
    
}

+ (void)uploadAvatar: (NSString *)userId avatar:(UIImage *)image
{
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];

    NSString *avatarURL = [NSString stringWithFormat:@"http://127.0.0.1:3000/profile/upload/%@",userId];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:avatarURL]];
    request.HTTPMethod = @"POST";
    
    //NSDictionary *dictionary = @{@"avatar":UIImageJPEGRepresentation(image, 0.25)};
    NSError *error = nil;
    NSData *bodyData;
    //判断图片是不是png格式的文件
    if (UIImagePNGRepresentation(image)) {
        //返回为png图像。
        bodyData = UIImagePNGRepresentation(image);
    }else {
        //返回为JPEG图像。
        bodyData = UIImageJPEGRepresentation(image, 1.0);
    }
    //request.HTTPBody = bodyData;
    
    if (!error) {
        
        NSURLSessionUploadTask *dataTask = [session uploadTaskWithRequest:request fromData:bodyData
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        if (!error) {
                                                            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                            if (dict[@"error"]) {
                                                                NSLog(@"dictionary error : %@", dict[@"error"]);
                                                            } else {
                                                                NSLog(@"%@", dict[@"status"]);
                                                            }
                                                        } else {
                                                            NSLog(@"error : %@", error);
                                                        }
                                                        
                                                    }];
        [dataTask resume];
    }
    
}

+ (void)downloadAvatar: (NSString *)userId responseBlock:(void(^)(NSURL *data, NSURLResponse *response, NSError *error))block
{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // Use a session with a custom configuration
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSString *avatarURL = [NSString stringWithFormat:@"http://127.0.0.1:3000/profile/avatar"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:avatarURL]];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *dictionary = @{@"userId":userId};
    NSError *error = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    request.HTTPBody = bodyData;
    
    if (!error) {
        NSURLSessionDownloadTask *dataTask = [session downloadTaskWithRequest:request
                                                    completionHandler:block];
        [dataTask resume];
    }
    
}

+ (void)uploadAvatar2:(NSString *)userId avatar:(UIImage *)image
{
    
    
    NSDictionary *headers = @{ @"content-type": @"multipart/form-data; boundary=---011000010111000001101001",
                               @"cache-control": @"no-cache"};
    NSArray *parameters = @[ @{ @"name": @"avatar", @"fileName": @"avatar.png" , @"contentType": @"image/png"} ];
    NSString *boundary = @"---011000010111000001101001";
    
    NSError *error;
    NSMutableString *body = [NSMutableString string];
    for (NSDictionary *param in parameters) {
        [body appendFormat:@"--%@\r\n", boundary];
        if (param[@"fileName"]) {
            [body appendFormat:@"Content-Disposition:form-data; name=\"%@\"; filename=\"%@\"\r\n", param[@"name"], param[@"fileName"]];
            [body appendFormat:@"Content-Type: %@\r\n\r\n", param[@"contentType"]];
            NSData *imageData = nil;
            //判断图片是不是png格式的文件
            if (UIImagePNGRepresentation(image)) {
                //返回为png图像。
                imageData = UIImagePNGRepresentation(image);
            }else {
                //返回为JPEG图像。
                imageData = UIImageJPEGRepresentation(image, 1.0);
            }
            [body appendFormat:@"%@", imageData];
            if (error) {
                NSLog(@"%@", error);
            }
        } else {
            [body appendFormat:@"Content-Disposition:form-data; name=\"%@\"\r\n\r\n", param[@"name"]];
            [body appendFormat:@"%@", param[@"value"]];
        }
    }
    [body appendFormat:@"\r\n--%@--\r\n", boundary];
    
    //将body字符串转化为UTF8格式的二进制
    NSData *postData = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *avatarURL = [NSString stringWithFormat:@"http://127.0.0.1:3000/profile/upload/%@",userId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:avatarURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"%@", httpResponse);
                                                    }
                                                }];
    [dataTask resume];
}

+ (void)updateProfile: (NSString *)userId withGender:(NSString *)gender withBirthDay:(NSString *)birthDay withBirthPlace:(NSString *)birthPlace
{
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://127.0.0.1:3000/profile/update"]];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *dictionary = @{@"userId":userId, @"gender":gender, @"birth_day": birthDay, @"birth_place": birthPlace};
    NSError *error = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    request.HTTPBody = bodyData;
    
    if (!error) {
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        if (!error) {
                                                            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                            if (dict[@"error"]) {
                                                                NSLog(@"dictionary error : %@", dict[@"error"]);
                                                            } else {
                                                                NSLog(@"%@", dict[@"username"]);
                                                            }
                                                        } else {
                                                            NSLog(@"error : %@", error.description);
                                                        }
                                                    }];
        [dataTask resume];
    }
}

+ (void)getNote: (NSString *)userId responseBlock:(void(^)(NSData *data, NSURLResponse *response, NSError *error))block
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // Use a session with a custom configuration
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSString *avatarURL = [NSString stringWithFormat:@"http://127.0.0.1:3000/note/note"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:avatarURL]];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *dictionary = @{@"userId":userId};
    NSError *error = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    request.HTTPBody = bodyData;
    
    if (!error) {
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                    completionHandler:block];
        [dataTask resume];
    }
    
}
+ (void)createNote: (NSString *)userId withNote:(NSString *)note
{
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://127.0.0.1:3000/note"]];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *dictionary = @{@"userId":userId, @"note":note};
    NSError *error = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    request.HTTPBody = bodyData;
    
    if (!error) {
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        if (!error) {
                                                            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                            if (dict[@"error"]) {
                                                                NSLog(@"dictionary error : %@", dict[@"error"]);
                                                            } else {
                                                                NSLog(@"%@", dict[@"username"]);
                                                            }
                                                        } else {
                                                            NSLog(@"error : %@", error.description);
                                                        }
                                                    }];
        [dataTask resume];
    }
    
}

@end
