//
//  GSFileManager.h
//  GSHttpManagerDemo
//
//  Created by 关宇琼 on 16/6/9.
//  Copyright © 2016年 GuanSir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if DEBUG
#	define CHECK_FOR_GSCACHE_PLIST() if([key isEqualToString:@"GSCache.plist"]) { \
NSLog(@"GSCache.plist is a reserved key and can not be modified."); \
return; }
#else
#	define CHECK_FOR_GSCACHE_PLIST() if([key isEqualToString:@"GSCache.plist"]) return;
#endif

#define gs_CurrentFileManager [GSFileManager currentCache]


typedef NS_ENUM(NSUInteger, SandBoxPath) {
    
    Library_Caches,
    
    Documents,
    
};


@interface GSFileManager : NSObject


@property(nonatomic) NSTimeInterval defaultTimeoutInterval; // Default is 1 day


+ (BOOL)createCacheDirWithFileName:(NSString *)fileName andSandBoxPath:(SandBoxPath)sbPath;/* 创建目录 */

+ (BOOL)createFile:(NSString *)path withFileName:(NSString *)fileName;/* 创建文件 */



+ (instancetype)currentCache;/* 当前的单利实力对象 */

- (instancetype)initWithCacheDirectory:(NSString*)cacheDirectory;/* 自定义目录创建 */
/**
 *  清除缓存
 */
- (void)clearCache;

- (id<NSCoding>)objectForKey:(NSString*)key;

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString*)key;

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;



@end
