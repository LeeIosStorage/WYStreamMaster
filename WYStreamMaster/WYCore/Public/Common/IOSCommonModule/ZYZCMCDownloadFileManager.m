//
//  DownloadFile.m
//  Pods
//
//  Created by 李灿 on 16/11/04.
//
//

#import "ZYZCMCDownloadFileManager.h"
#import "AFNetworking.h"

@implementation ZYZCMCDownloadFileManager

#pragma mark FileUtils
/**
 * 返回本地APIjson文件路径
 */
+ (NSString *)APIJSONPath{
    //这里要返回一个是文件的位置路径
    NSString * path;
   path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@""];
    if ([ZYZCMCDownloadFileManager fileExist:path]) {
        return path;
    }else{//没有json文件路径,返回app内文件路径
        path = [[NSBundle mainBundle] pathForResource:@"" ofType:nil];
        return path;
    }
}

- (BOOL)isExistedWithFileUrl:(NSURL *)fileUrl {
    NSString *urlPath=[NSString stringWithFormat:@"%@/Documents%@",NSHomeDirectory(),fileUrl.path];
    
    if ([self is_file_exist:urlPath]) {
        return YES;
    }
    return NO;
}

+ (BOOL)fileExist:(NSString *)filePath{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    return [file_manager fileExistsAtPath:filePath];
}
// 判断文件是否存在
- (BOOL)is_file_exist:(NSString *)fileName
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    return [file_manager fileExistsAtPath:fileName];
}

+ (BOOL)fileRemove:(NSString *)filePath{
    if (!filePath) {
        return YES;
    }
    else
    {
       NSFileManager *file_manager = [NSFileManager defaultManager];
        if ([file_manager fileExistsAtPath:filePath]) {
            return [file_manager removeItemAtPath:filePath error:nil];
        }
        else
        {
            return YES;
        }
    }
   
    
}

@end
