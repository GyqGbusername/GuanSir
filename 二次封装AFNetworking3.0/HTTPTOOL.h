//
//  HTTPTOOL.h
//  asdsadasd
//
//  Created by dllo on 15/11/13.
//  Copyright © 2015年 GYQ. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 表示返回数据类型 */
typedef NS_ENUM(NSUInteger, responseStyle) {
    DATA,
    JSON,
    XML,
};

/* POST中表示bodyStyle类型 */
typedef NS_ENUM(NSUInteger, bodyStyle) {
    stringStyle,
    JSONStyle,
};

@interface HTTPTOOL : NSObject

/* @param body : 有的GET参数是和url分开的 */


+ (void)GETWithURL:(NSString *)url withBody:(NSDictionary *)body withHttpHead:(NSDictionary *)head responseStyle:(responseStyle)style withSuccess:(void(^)(id result))success withFail:(void(^)(id result))fail;

+ (void)POSTWithURL:(NSString *)url withBody:(id)body withBodyStyle:(bodyStyle)bodyStyle withHttpHead:(NSDictionary *)head responseStyle:(responseStyle)style withSuccess:(void(^)(id result))success withFail:(void(^)(NSError *error))fail;


@end
