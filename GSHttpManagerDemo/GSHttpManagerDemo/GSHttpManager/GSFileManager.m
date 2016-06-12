//
//  GSFileManager.m
//  GSHttpManagerDemo
//
//  Created by 关宇琼 on 16/6/9.
//  Copyright © 2016年 GuanSir. All rights reserved.
//

#import "GSFileManager.h"



#define gs_CacheFileName  @"GSCache"

#define gs_FileManager  [NSFileManager defaultManager]

/**
 *  获取类的名字变作字符串
 */

#define gs_GetClass_Name(vc)      [NSString stringWithUTF8String:object_getClassName(vc)]


static inline NSString* cachePathForKey(NSString* directory, NSString* key) {
    
    key = [key stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    return [directory stringByAppendingPathComponent:key];
    
}


@interface GSFileManager () {
    
    dispatch_queue_t _cacheInfoQueue; /* 缓存队列 */
    
    dispatch_queue_t _frozenCacheInfoQueue;   /* 失效计时队列 */
    
    dispatch_queue_t _diskQueue;    /* 当前队列 */
    
    NSMutableDictionary* _cacheInfo; /* 缓存信息 */
    
    NSString* _directory; /* 目录 */
    
    BOOL _needsSave;
}

@property(nonatomic,copy) NSDictionary* frozenCacheInfo;

@property (nonatomic, copy) NSString *paths;

@end

@implementation GSFileManager

+ (instancetype)currentCache {
    
    return [self globalCache];
    
}

+ (instancetype)globalCache {
    
    static id instance;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[[self class] alloc] init];
        
    });
    
    return instance;
    
}


- (instancetype)init
{
        
    NSString* cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    
    NSString* oldCachesDirectory = [[[cachesDirectory stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]] stringByAppendingPathComponent:@"GSCache"] copy];
    
    if([gs_FileManager fileExistsAtPath:oldCachesDirectory]) {     /* 判断是否存在旧的缓存文件夹 */
        
        [gs_FileManager removeItemAtPath:oldCachesDirectory error:NULL]; /* 移除旧的缓存 */
        
    }
    
    cachesDirectory = [[[cachesDirectory stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"GSCache"] copy]; /* bundleIdentifier 获取工程的工程名拼接GS.GSHttpManagerDemo/GSCache */
    
    return [self initWithCacheDirectory:cachesDirectory];
    
}

/**
 *  自定义创建
 *
 *  @param cacheDirectory cache path str
 *
 *  @return instance
 */

- (instancetype)initWithCacheDirectory:(NSString*)cacheDirectory {
    
    if((self = [super init])) {
        /**
         *  队列创建
         *
         *  @param "com.gs.gscache.info" 队列标识符
         *
         *  @param DISPATCH_QUEUE_SERIAL 创建顺序执行队列
         *
         *  @param DISPATCH_QUEUE_CONCURRENT 创建同时执行队列
         *
         *  @return 队列
         */
        _cacheInfoQueue = dispatch_queue_create("com.gs.gscache.info", DISPATCH_QUEUE_SERIAL);
        
        dispatch_queue_t priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0); /* @param priority 优先级 */
        
        dispatch_set_target_queue(priority, _cacheInfoQueue);
        
        _frozenCacheInfoQueue = dispatch_queue_create("com.gs.gscache.info.frozen", DISPATCH_QUEUE_SERIAL);
        priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_set_target_queue(priority, _frozenCacheInfoQueue);
        
        _diskQueue = dispatch_queue_create("com.gs.gscache.disk", DISPATCH_QUEUE_CONCURRENT);
        priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_set_target_queue(priority, _diskQueue);
        
        /* DISPATCH_QUEUE_PRIORITY_HIGH :优先级最高，在default,和low之前执行
         * DISPATCH_QUEUE_PRIORITY_DEFAULT 默认优先级，在low之前，在high之后
         * DISPATCH_QUEUE_PRIORITY_LOW 在high和default后执行
         * DISPATCH_QUEUE_PRIORITY_BACKGROUND:提交到这个队列的任务会在high优先级的任务和已经提交到background队列的执行完后执行。
         */
        
        _directory = cacheDirectory;
        
        _cacheInfo = [[NSDictionary dictionaryWithContentsOfFile:cachePathForKey(_directory, @"GSCache.plist")] mutableCopy];
        
        if(!_cacheInfo) {
            
            _cacheInfo = [[NSMutableDictionary alloc] init];
            
        }
        /* 按照路径创建文件夹 */
        [gs_FileManager createDirectoryAtPath:_directory withIntermediateDirectories:YES attributes:nil error:NULL];
        
        NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
        
        NSMutableArray* removedKeys = [[NSMutableArray alloc] init];
        
        for(NSString* key in _cacheInfo) {
            
            if([_cacheInfo[key] timeIntervalSinceReferenceDate] <= now) {
                
                [[NSFileManager defaultManager] removeItemAtPath:cachePathForKey(_directory, key) error:NULL];
                
                [removedKeys addObject:key];
                
            }
            
        }
        
        [_cacheInfo removeObjectsForKeys:removedKeys];
        
        self.frozenCacheInfo = _cacheInfo;
        
        [self setDefaultTimeoutInterval:86400];
    }
    
    return self;
}


/**
 *  创建目录
 *
 *  @return 返回创建结果
 */

+ (BOOL)createCacheDirWithFileName:(NSString *)fileName andSandBoxPath:(SandBoxPath)sbPath {
    
    NSArray *cacPath = nil;
    
    switch (sbPath) {
            
        case Library_Caches:
            
            cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            
            break;
            
        case Documents:
            
            cacPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
            break;
    }
    
    NSString *cachePath = [cacPath objectAtIndex:0];

    NSString *path = [NSString stringWithFormat:@"%@/%@",cachePath, fileName];
    
    BOOL isDir;
    
    if  (![gs_FileManager fileExistsAtPath:path isDirectory:&isDir]) {//先判断目录是否存在，不存在才创建
        
        BOOL res = [gs_FileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        
        return res;
        
    } else
        
        return NO;
    
}

/**
 *  创建文件
 *
 *  @param path 路径
 *
 *  @param fileName 文件名
 *
 *  @return 创建结果
 */

+ (BOOL)createFile:(NSString *)path withFileName:(NSString *)fileName {
    
    NSString *testPath = [NSString stringWithFormat:@"%@/%@.text", path, fileName];//在传入的路径下创建test.text文件
    
    BOOL res= [gs_FileManager createFileAtPath:testPath contents:nil attributes:nil];

    return res;
}



/**
 *  根据文件名字获取文件路径
 *
 *  @param fileName 文件名
 *
 *  @return 路径(Library caches)
 */

+ (NSString *)getLocalCacheFilePath:(NSString *)fileName {
    
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches"];

    return [NSString stringWithFormat:@"%@/%@",path,fileName];
    
}

/**
 *  根据文件名获取文件路径
 *
 *  @param fileName 文件名
 *
 *  @return 路径(Documents)
 */

+ (NSString *)getLocalDocumentsFilePath:(NSString *)fileName {
    
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents"];
    
    return [NSString stringWithFormat:@"%@/%@",path,fileName];
    
}

/**
 *  获取资源文件路径
 *
 *  @param fileName 文件名字
 *
 *  @return 路径
 */

+ (NSString *)getResourcesFile:(NSString *)fileName {
    
    return [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
}


- (void)clearCache {
    
    dispatch_sync(_cacheInfoQueue, ^{
        
        for(NSString* key in _cacheInfo) {
            
            [gs_FileManager removeItemAtPath:cachePathForKey(_directory, key) error:NULL];
            
        }
        
        [_cacheInfo removeAllObjects];
        
        dispatch_sync(_frozenCacheInfoQueue, ^{
            
            self.frozenCacheInfo = [_cacheInfo copy];
            
        });
        
        [self setNeedsSave];
    });
}


- (NSData *)dataForKey:(NSString*)key {
    
    if([self hasCacheForKey:key]) {
        
        return [NSData dataWithContentsOfFile:cachePathForKey(_directory, key) options:0 error:NULL];
        
    } else {
        
        return nil;
        
    }
}


- (NSDate *)dateForKey:(NSString*)key {
    
    __block NSDate* date = nil;
    
    dispatch_sync(_frozenCacheInfoQueue, ^{
        
        date = (self.frozenCacheInfo)[key];
        
    });
    
    return date;
}


- (BOOL)hasCacheForKey:(NSString*)key {
    
    NSDate* date = [self dateForKey:key];
    
    if(date == nil) return NO;
    
    if([date timeIntervalSinceReferenceDate] < CFAbsoluteTimeGetCurrent()) return NO;
    
    return [gs_FileManager fileExistsAtPath:cachePathForKey(_directory, key)];
    
}

- (void)setData:(NSData*)data forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
    
    CHECK_FOR_GSCACHE_PLIST();
    
    NSString* cachePath = cachePathForKey(_directory, key);
    
    dispatch_async(_diskQueue, ^{
        
        [data writeToFile:cachePath atomically:YES];
        
    });
    
    [self setCacheTimeoutInterval:timeoutInterval forKey:key];
    
}

- (void)setCacheTimeoutInterval:(NSTimeInterval)timeoutInterval forKey:(NSString*)key {
    
    NSDate* date = timeoutInterval > 0 ? [NSDate dateWithTimeIntervalSinceNow:timeoutInterval] : nil;
    
    // Temporarily store in the frozen state for quick reads
    dispatch_sync(_frozenCacheInfoQueue, ^{
        
        NSMutableDictionary* info = [self.frozenCacheInfo mutableCopy];
        
        if(date) {
            
            info[key] = date;
            
        } else {
            
            [info removeObjectForKey:key];
            
        }
        
        self.frozenCacheInfo = info;
        
    });
    
    // Save the final copy (this may be blocked by other operations)
    dispatch_async(_cacheInfoQueue, ^{
        
        if(date) {
            
            _cacheInfo[key] = date;
            
        } else {
            
            [_cacheInfo removeObjectForKey:key];
            
        }
        
        dispatch_sync(_frozenCacheInfoQueue, ^{
            
            self.frozenCacheInfo = [_cacheInfo copy];
            
        });
        
        [self setNeedsSave];
        
    });
    
}

- (void)setNeedsSave {
    
    dispatch_async(_cacheInfoQueue, ^{
        
        if(_needsSave) return;
        
        _needsSave = YES;
        
        double delayInSeconds = 0.5;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        
        dispatch_after(popTime, _cacheInfoQueue, ^(void){
            
            if(!_needsSave) return;
            
            [_cacheInfo writeToFile:cachePathForKey(_directory, @"GSCache.plist") atomically:YES];
            
            _needsSave = NO;
            
        });
        
    });
    
}

#pragma mark -
#pragma mark Object methods

- (id<NSCoding>)objectForKey:(NSString*)key {
    
    if([self hasCacheForKey:key]) {
        
        return [NSKeyedUnarchiver unarchiveObjectWithData:[self dataForKey:key]];
        
    } else {
        
        return nil;
        
    }
    
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString*)key {
    
    [self setObject:anObject forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
    
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
    
    [self setData:[NSKeyedArchiver archivedDataWithRootObject:anObject] forKey:key withTimeoutInterval:timeoutInterval];
    
}



@end
