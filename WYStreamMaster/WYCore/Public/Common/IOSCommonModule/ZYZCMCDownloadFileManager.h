//
//  DownloadFile.h
//  Pods
//
//  Created by 李灿 on 16/11/04.
//
//
#import <Foundation/Foundation.h>
#import "UIProgressView+AFNetworking.h"
typedef void(^Completion)(BOOL isSuccess,NSString *message,NSString *localPath);
@interface ZYZCMCDownloadFileManager : NSObject
// 判断url对应的缓存是否已经存在
- (BOOL)isExistedWithFileUrl:(NSURL *)fileUrl;

+ (NSString *)APIJSONPath;
+ (NSString *)APIJSONDownloadPath;
+(BOOL)fileExist:(NSString *)filePath;
+(BOOL)fileRemove:(NSString *)filePath;


@end
