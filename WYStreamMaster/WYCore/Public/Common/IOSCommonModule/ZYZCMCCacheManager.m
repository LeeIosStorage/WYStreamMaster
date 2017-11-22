//
//  FZMCCacheManager.m
//  Pods
//
//  Created by 李灿 on 16/11/04.
//
//

#import "ZYZCMCCacheManager.h"
@implementation ZYZCMCCacheManager

+ (float)fileCacheSizeAtPath:(NSString*)filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        long long fileSize = [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        return fileSize / (1024.0*1024.0);
    }
    return 0.0;
}

+ (float)folderCacheSizeAtPath:(NSString*)folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [[manager attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize];
    }
    return folderSize/(1024.0*1024.0);
}

+ (float)documentsCacheSizeAtPath
{
    NSString *documentsPath=[NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:documentsPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:documentsPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [documentsPath stringByAppendingPathComponent:fileName];
        folderSize += [[manager attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize];
    }
    return folderSize/(1024.0*1024.0);
}

+ (float)cacheSizeAtPath
{//  使用NSSearchPathForDirectoriesInDomains只能定位Caches目录和Documents目录。
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:cachPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:cachPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [cachPath stringByAppendingPathComponent:fileName];
        folderSize += [[manager attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize];
    }
    return folderSize/(1024.0*1024.0);
}

+ (float)cardCacheSizePath
{
    NSString *documentsPath=[NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:documentsPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:documentsPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [documentsPath stringByAppendingPathComponent:fileName];
        folderSize += [[manager attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize];
    }
    return folderSize/(1024.0*1024.0);
}

+ (void)removeFileCache:(NSString *)filePath
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
}

+ (void)removefolderFileCache:(NSString *)filePath
{
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:filePath];
    for (NSString *file in files) {
        NSError *error;
        NSString *path = [filePath stringByAppendingPathComponent:file];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        }
    }
}

+ (void)removeDocumentsFileCache
{
    NSString *documentsPath=[NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:documentsPath];
    for (NSString *filePath in files) {
        NSError *error;
        NSString *path = [documentsPath stringByAppendingPathComponent:filePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        }
    }
}

+ (void)removeCacheFileCache
{
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
    for (NSString *filePath in files) {
        NSError *error;
        NSString *path = [cachPath stringByAppendingPathComponent:filePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        }
    }
}

+ (void)removeCardCacheFileCache
{
    NSString *documentsPath=[NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:documentsPath];
    for (NSString *filePath in files) {
        NSError *error;
        NSString *path = [documentsPath stringByAppendingPathComponent:filePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        }
    }
//    NSString *documentsPath=[NSString stringWithFormat:@"%@/Documents/cacheCardPath",NSHomeDirectory()];
//    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:documentsPath];
//    for (NSString *filePath in files) {
//        NSError *error;
//        NSString *path = [documentsPath stringByAppendingPathComponent:filePath];
//        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
//        }
//    }
}

+ (void)removeCache
{
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
}


+ (BOOL)archiverCacheData:(NSMutableArray *)dataArray path:(NSString *)path
{
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:dataArray];
    BOOL isArchiveSuccess = [archiveData writeToFile:path atomically:YES];
    return isArchiveSuccess;
}

+ (NSMutableArray *)unarchiverCachePath:(NSString *)path
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
