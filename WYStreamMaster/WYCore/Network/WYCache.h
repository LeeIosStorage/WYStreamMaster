//
//  WYCache.h
//  WYRecordMaster
//
//  Created by zurich on 16/8/18.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TMCache/TMCache.h>

@interface WYCache : NSObject
+ (NSInteger)TMCacheSize;

+ (void)objectForKey:(NSString *)key block:(TMCacheObjectBlock)block;

+ (void)removeObjectForKey:(NSString *)key block:(TMCacheObjectBlock)block;

+ (void)trimToDate:(NSDate *)date block:(TMCacheBlock)block;

+ (void)removeAllObjects:(TMCacheBlock)block;

+ (id)objectForKey:(NSString *)key;

+ (void)removeObjectForKey:(NSString *)key;

+ (void)trimToDate:(NSDate *)date;

+ (void)removeAllObjects;

+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key;

+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(TMCacheObjectBlock)block;


@end
