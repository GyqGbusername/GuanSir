//
//  HTTPTOOL.m
//  asdsadasd
//
//  Created by dllo on 15/11/13.
//  Copyright © 2015年 GYQ. All rights reserved.
//

#import "HTTPTOOL.h"
#import <AFNetworking.h>

@implementation HTTPTOOL


+ (void)GETWithURL:(NSString *)url withBody:(NSDictionary *)body withHttpHead:(NSDictionary *)head responseStyle:(responseStyle)style withSuccess:(void(^)(id result))success withFail:(void(^)(id result))fail {
    
    NSString *url_string = [NSString stringWithString:url];
    /* 创建一个网络请求管理 */
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    /* 添加请求头 */
    if (head) {
        for (NSString *key in head) {
            [manager.requestSerializer setValue:head[key] forHTTPHeaderField:key];
        }
    }
    /* 判断返回数据类型 */
    switch (style) {
        case DATA: {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        }
        case JSON: {
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        }
        case XML: {
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        }
    }
    /* 设置请求接受的数据类型 */
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil]];
    
    //本地缓存设置，沙盒路径设置
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *pathString = path.lastObject;
    NSString *pathLast =[NSString stringWithFormat:@"/Caches/com.hackemist.get.default/%lu.text", (unsigned long)[url_string hash]];
    
    //创建字符串文件存储路径
    NSString *PathName =[pathString stringByAppendingString:pathLast];
    
    //第一次进入判断有没有文件夹，如果没有就创建一个
    NSString * textPath = [pathString stringByAppendingFormat:@"/Caches/com.hackemist.get.default"];
    if (![[NSFileManager defaultManager]fileExistsAtPath:textPath]) {
        
        [[NSFileManager defaultManager]createDirectoryAtPath:textPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //设BOOL值 判断解析后的数据是数组还是字典
    __block  BOOL isClass = NO;
    

    /* get请求 */
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            isClass = YES;
        } else{
            isClass = NO;
        }
        [responseObject writeToFile:PathName atomically:YES];
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        NSString * cachePath = PathName;
        if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
            //从本地读缓存文件
            id responseObject = nil;
            if (isClass) {
                responseObject = [NSMutableArray arrayWithContentsOfFile:cachePath];
            } else {
                responseObject = [NSMutableDictionary dictionaryWithContentsOfFile:cachePath];
            }
            success(responseObject);
        }

    }];
}

+ (void)POSTWithURL:(NSString *)url withBody:(id)body withBodyStyle:(bodyStyle)bodyStyle withHttpHead:(NSDictionary *)head responseStyle:(responseStyle)style withSuccess:(void (^)(id))success withFail:(void (^)(NSError *))fail {
    NSString *url_string = [NSString stringWithString:url];
    /* 创建http请求管理者 */
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    /* 处理body类型 */
    switch (bodyStyle) {
        case stringStyle: {
            break;
        }
        case JSONStyle: {
            
            break;
        }
    }
    
    
    /* 添加请求头 */
    if (head) {
        for (NSString *key in head) {
            [manager.requestSerializer setValue:head[key] forHTTPHeaderField:key];
        }
    }
    /* 判断返回数据类型 */
    switch (style) {
        case DATA: {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        }
        case JSON: {
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        }
        case XML: {
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        }
            
        default:
            break;
    }
    /* 设置请求接受的数据类型 */
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil]];
    //本地缓存设置，沙盒路径设置
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *pathString = path.lastObject;
    NSString *pathLast =[NSString stringWithFormat:@"/Caches/com.hackemist.post.default/%lu.text", (unsigned long)[url_string hash]];
    
    //创建字符串文件存储路径
    NSString *PathName =[pathString stringByAppendingString:pathLast];
    
    //第一次进入判断有没有文件夹，如果没有就创建一个
    NSString * textPath = [pathString stringByAppendingFormat:@"/Caches/com.hackemist.post.default"];
    if (![[NSFileManager defaultManager]fileExistsAtPath:textPath]) {
        
        [[NSFileManager defaultManager]createDirectoryAtPath:textPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //设BOOL值 判断解析后的数据是数组还是字典
    __block  BOOL isClass = NO;
    
    
    /* POST请求 */
    [manager POST:url parameters:body constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            isClass = YES;
        } else{
            isClass = NO;
        }
        [responseObject writeToFile:PathName atomically:YES];
        success(responseObject);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString * cachePath = PathName;
        if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
            //从本地读缓存文件
            id responseObject = nil;
            if (isClass) {
                responseObject = [NSMutableArray arrayWithContentsOfFile:cachePath];
            } else {
                responseObject = [NSMutableDictionary dictionaryWithContentsOfFile:cachePath];
            }
            success(responseObject);
        }

    }];
 
}




@end
