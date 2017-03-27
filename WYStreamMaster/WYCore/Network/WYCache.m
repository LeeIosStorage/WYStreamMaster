//
//  WYCache.m
//  WYRecordMaster
//
//  Created by zurich on 16/8/18.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "WYCache.h"

@implementation WYCache

+ (NSInteger)TMCacheSize {
    return [TMCache sharedCache].diskByteCount;
}

+ (void)objectForKey:(NSString *)key block:(TMCacheObjectBlock)block {
    [[TMCache sharedCache] objectForKey:key block:block];
}

+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(TMCacheObjectBlock)block {
    [[TMCache sharedCache] setObject:object forKey:key block:block];
}

+ (void)removeObjectForKey:(NSString *)key block:(TMCacheObjectBlock)block {
    [[TMCache sharedCache] removeObjectForKey:key block:block];
}

+ (void)trimToDate:(NSDate *)date block:(TMCacheBlock)block {
    [[TMCache sharedCache] trimToDate:date block:block];
}

+ (void)removeAllObjects:(TMCacheBlock)block {
    [[TMCache sharedCache] removeAllObjects:block];
}

+ (id)objectForKey:(NSString *)key {
    return [[TMCache sharedCache] objectForKey:key];
}

+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key {
    [[TMCache sharedCache] setObject:object forKey:key];
}

+ (void)removeObjectForKey:(NSString *)key {
    [[TMCache sharedCache] removeObjectForKey:key];
}

+ (void)trimToDate:(NSDate *)date {
    [[TMCache sharedCache] trimToDate:date];
}

+ (void)removeAllObjects {
    [[TMCache sharedCache] removeAllObjects];
}


@end
