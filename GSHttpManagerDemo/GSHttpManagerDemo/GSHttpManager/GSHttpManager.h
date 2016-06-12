//
//  GSHttpManager.h
//  GSHttpManagerDemo
//
//  Created by 关宇琼 on 16/6/8.
//  Copyright © 2016年 GuanSir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AFNetworking.h>
#import "GSFileManager.h"


/**
 *     Reachability单利
 */

#define  gs_ReachabilityManager  [AFNetworkReachabilityManager sharedManager]

#define gs_HttpManager [GSHttpManager currentManager]


@interface GSHttpManager : NSObject


+ (instancetype)currentManager;

/**
 *  判断网络
 */
- (void)httpManagerGSNetworkReachabilityManage;

/**
 *  POST
 */
- (void)httpManagerPostParameter:(NSDictionary *)param toHttpUrlStr:(NSString *)urlStr isCacheorNot:(BOOL)isCache  targetViewController:(UIViewController *)viewController andUrlFunctionName:(NSString *)urlName success:(void(^)(id result))success orFail:(void(^)(NSError *error))fail;

/**
 *  GET
 */
- (void)httpManagerGetFromHttpUrlStr:(NSString *)urlStr withParameter:(NSDictionary *)param isCacheorNot:(BOOL)isCache  targetViewController:(UIViewController *)viewController andUrlFunctionName:(NSString *)urlName success:(void(^)(id result))success orFail:(void(^)(NSError *error))fail;

@end
