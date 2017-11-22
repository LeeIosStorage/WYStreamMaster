//
//  FZMCCacheManager.h
//  Pods
//
//  Created by 李灿 on 16/11/04.
//
//

#import <Foundation/Foundation.h>

@interface ZYZCMCCacheManager : NSObject
// 计算单个文件大小
+ (float)fileCacheSizeAtPath:(NSString *)filePath;

// 计算指定文件夹的缓存大小
+ (float)folderCacheSizeAtPath:(NSString *)filePath;

// 计算Documents文件夹的缓存大小
+ (float)documentsCacheSizeAtPath;

// 计算cache文件夹的缓存大小
+ (float)cacheSizeAtPath;

// 计算卡片文件夹的缓存大小
+ (float)cardCacheSizePath;

// 删除指定文件缓存
+ (void)removeFileCache:(NSString *)filePath;

// 删除指定文件夹缓存
+ (void)removefolderFileCache:(NSString *)filePath;

// 删除Documents文件夹缓存
+ (void)removeDocumentsFileCache;

// 删除cache文件夹缓存
+ (void)removeCacheFileCache;

// 删除卡片文件夹缓存
+ (void)removeCardCacheFileCache;

// 删除所有网络缓存
+ (void)removeCache;

// 序列化文件
+ (BOOL)archiverCacheData:(NSMutableArray *)dataArray path:(NSString *)path;
// 反序列化文件
+ (NSMutableArray *)unarchiverCachePath:(NSString *)path;
//// 解压文件
//+ (NSArray *)unzipArchive:(NSString *)path pathType:(NSString *)pathType screen:(NSString *)screen;
//// 压缩文件,返回yes表示压缩成功，no表示失败，如压缩多个文件需多次调用
//+ (BOOL)zipArchive:(NSString *)createPath filePath:(NSString *)filePath newFileName:(NSString *)newFileName;
@end
