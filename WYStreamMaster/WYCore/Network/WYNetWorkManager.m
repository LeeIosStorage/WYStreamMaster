//
//  WYNetWorkManager.m
//  WYRecordMaster
//
//  Created by zurich on 16/8/18.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "WYNetWorkManager.h"
#import "WYLoginUserManager.h"
#import "WYNetWorkExceptionHandling.h"
#import "WYCache.h"
#import <AFNetworking/AFNetworking.h>
#import <DeviceUtil.h>


#define kCPNetworkRequestStatusOK 0
#define kCPNetworkRequestStatusFailed 1

static NSString *const kUserInfoUID = @"userId";
static NSString *const kUserInfoAuthToken = @"token";

@implementation WYNetWorkManager

+ (instancetype)sharedManager
{
    static WYNetWorkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark --- Public Method

- (void)GET:(NSString *)URLString
  needCache:(BOOL)needCache
 parameters:(id)parameters
responseClass:(Class)classType
    success:(WYRequestSuccessBlock)success
    failure:(WYRequestFailureBlock)failure
{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [securityPolicy setValidatesDomainName:YES];
    manager.securityPolicy = securityPolicy;
    
    
    // app版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"html/json",@"text/plain",[NSString stringWithFormat:@"version/%@",app_Version], nil];
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
//    [self setHttpHeader:manager];
    
    NSString *requestURLString = [self urlStringAddCommonParamForSourceURLString:URLString];
    
    //缓存处理
    if (needCache && URLString && success) {
        id cacheObject = [WYCache objectForKey:URLString];
        if (cacheObject) {
            //model对象
            if (classType) {
                //不是需要的类型，不返回缓存
                if ([cacheObject isKindOfClass:classType]) {
                    success(kCPNetworkRequestStatusOK, nil, cacheObject);
                } else if ([cacheObject isKindOfClass:[NSArray class]]) {
                    //数组对象
                    NSArray *cacheObjestArray = (NSArray *)cacheObject;
                    if (cacheObjestArray && [cacheObjestArray count] > 0) {
                        id modelObject = [cacheObjestArray firstObject];
                        if ([modelObject isKindOfClass:classType]) {
                            success(kCPNetworkRequestStatusOK, nil, cacheObject);
                        }
                    }
                }
            } else {
                success(kCPNetworkRequestStatusOK, nil, cacheObject);
            }//end of if (classType
            
        }//end of if(cacheObject)
    }//end of if (needCache...
    
    [manager GET:requestURLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            //[self handleResponseObject:responseObject];
        }
        NSLog(@"请求url = %@ \n responseObject=%@",task.currentRequest.URL,responseObject);
        
        NSString *message = nil;
        NSInteger status = kCPNetworkRequestStatusFailed;
        id responseDataObject = nil;
        if (responseObject) {
            message = [responseObject objectForKey:@"msg"];
            NSNumber* statusCode = [responseObject objectForKey:@"code"];
            if (statusCode) {
                status = statusCode.integerValue;
            }
            responseDataObject = responseObject[@"data"];
            //此处有两种情况发生，正常的是json，非正常是一个常规string
        }
        
        if (success) {
            if ([WYNetWorkExceptionHandling judgeReuqestStatus:status] && classType && responseObject) {
                if ([responseDataObject isKindOfClass:[NSArray class]]) {
                    
                    NSArray *array = [NSArray modelArrayWithClass:classType json:responseDataObject];

                    if (needCache) {
                        [WYCache setObject:array forKey:URLString];
                    }
                    success(status,message,array);
                } else {
                  
                    NSDictionary *dic = [NSDictionary modelDictionaryWithClass:classType json:responseObject];
                    id model = dic[@"data"];
   

                    if (needCache) {
                        [WYCache setObject:model forKey:URLString];
                    }
                    success(status,message,model);
                }
            } else {
                if (needCache) {
                    [WYCache setObject:responseDataObject forKey:URLString];
                }
                success(status,message,responseDataObject);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(nil, error);
        }
    }];


}

- (void)POST:(NSString *)URLString
   needCache:(BOOL)needCache
  parameters:(id)parameters
responseClass:(Class)classType
     success:(WYRequestSuccessBlock)success
     failure:(WYRequestFailureBlock)failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // app版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"html/json",@"text/plain",[NSString stringWithFormat:@"version/%@",app_Version], nil];//kCsagddCheck
    
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *requestURLString = [self urlStringAddCommonParamForSourceURLString:URLString];
    
    //缓存处理
    if (needCache && URLString && success) {
        id cacheObject = [WYCache objectForKey:URLString];
        if (cacheObject) {
            //model对象
            if (classType) {
                //不是需要的类型，不返回缓存
                if ([cacheObject isKindOfClass:[classType class]]) {
                    success(kCPNetworkRequestStatusOK, nil, cacheObject);
                } else if ([cacheObject isKindOfClass:[NSArray class]]) {
                    //数组对象
                    NSArray *cacheObjestArray = (NSArray *)cacheObject;
                    if (cacheObjestArray && [cacheObjestArray count] > 0) {
                        id modelObject = [cacheObjestArray firstObject];
                        if ([modelObject isKindOfClass:[classType class]]) {
                            success(kCPNetworkRequestStatusOK, nil, cacheObject);
                        }
                    }
                }
            } else {
                success(kCPNetworkRequestStatusOK, nil, cacheObject);
            }//end of if (classType
            
        }//end of if(cacheObject)
    }//end of if (needCache...
    
    [manager POST:requestURLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
#if kLogHttpStatus
         NSData *jsondata = [NSJSONSerialization dataWithJSONObject:responseObject options:kNilOptions error:nil];
         NSString *jsonstr = [[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
         NSLog(@"response data:%@", jsonstr);
#endif
         //暂时不知道现在的状态码，先不做判断
//         if ([responseObject isKindOfClass:[NSDictionary class]]) {
//             [self handleResponseObject:responseObject];
//         }
         NSString *message = nil;
         NSInteger status = kCPNetworkRequestStatusFailed;
         id responseDataObject = nil;
         
         if (responseObject) {
             message = [responseObject objectForKey:@"msg"];
             NSNumber* statusCode = [responseObject objectForKey:@"code"];
             if (statusCode) {
                 status = statusCode.integerValue;
             }
             responseDataObject = responseObject[@"data"];
             //此处有两种情况发生，正常的是json，非正常是一个常规string
         }

         
         if ([responseObject[@"code"] intValue] == 0) {
             message = [responseObject objectForKey:@"msg"];
             success(status,message,responseObject);
         } else {
             if (success) {
                 if ([WYNetWorkExceptionHandling judgeReuqestStatus:status]  && classType && responseDataObject) {
                     if ([responseDataObject isKindOfClass:[NSArray class]]) {
                         NSArray *array = [NSArray modelArrayWithClass:[classType class] json:responseObject];

                         if (needCache) {
                             [WYCache setObject:array forKey:URLString];
                         }
                         
                         success(status,message,array);
                     } else {
                         NSDictionary *dic = [NSDictionary modelDictionaryWithClass:classType json:responseObject];
                         id model = dic[@"data"];
                         success(status,message,model);
                     }
                 } else {
                     if (needCache) {
                         [WYCache setObject:responseDataObject forKey:URLString];
                     }
                     success(status,message,responseDataObject);
                 }
             }
         }
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         if (failure) {
             failure(nil, error);
         }
     }];

    
}

- (void)POST:(NSString *)URLString
formFileName:(NSString *)formFileName
    fileName:(NSString *)fileName
    fileData:(NSData *)fileData
    mimeType:(NSString *)mimeType
  parameters:(id )parameters
responseClass:(Class )classType
     success:(WYRequestSuccessBlock)success
     failure:(WYRequestFailureBlock)failure
{
    ///bugly中出现的data为空crash的问题
    if (!fileData) {
        return;
    }
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *requestURLString = [self urlStringAddCommonParamForSourceURLString:URLString];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:requestURLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:fileData name:formFileName fileName:fileName mimeType:mimeType];
    } error:nil];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        NSString *message = nil;
        NSError *parserError = nil;
        NSInteger status = WYRequestTypeFailed;
        id responseDataObject = nil;

        if (responseObject) {
            NSDictionary *jsonValue = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&parserError];
            if (jsonValue) {
                message = [jsonValue objectForKey:@"msg"];
                NSNumber* statusCode = [jsonValue objectForKey:@"code"];
                if (statusCode) {
                    status = statusCode.integerValue;
                }
                responseDataObject = jsonValue[@"data"];
                //此处有两种情况发生，正常的是json，非正常是一个常规string
            }
        }
        if (success) {
            if ([WYNetWorkExceptionHandling judgeReuqestStatus:status] && classType && responseDataObject) {
                if ([responseDataObject isKindOfClass:[NSArray class]]) {
                    
                    NSArray *array = [NSArray modelArrayWithClass:classType json:responseDataObject];
                    
                    
                    success(status,message,array);
                } else {
                    NSDictionary *dic = [NSDictionary modelDictionaryWithClass:classType json:responseObject];
                    
                    id model = dic[@"data"];
                    
                    
                    success(status,message,model);
                }
            } else {
                
                success(status,message,responseDataObject);
            }
        }
    }];
    
    [uploadTask resume];
}

#pragma mark --- Utils Method

-(void)setHttpHeader:(AFHTTPSessionManager*) manger
{
    manger.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"html/json",@"text/plain", nil];
    NSString *deviceType = [DeviceUtil hardwareDescription];
    NSString *deviceSystemName = [UIDevice currentDevice].systemName;
    NSString *deviceSystemVersion = [UIDevice currentDevice].systemVersion;
    
    [[manger requestSerializer] setValue:deviceType forHTTPHeaderField:@"Device-Model"];
    [[manger requestSerializer] setValue:@"iOS" forHTTPHeaderField:@"User-Agent"];

    [[manger requestSerializer] setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]  forHTTPHeaderField:@"App-Version"];
    [[manger requestSerializer] setValue:[NSString  stringWithFormat:@"%@ %@",deviceSystemName,deviceSystemVersion] forHTTPHeaderField:@"Client-OS"];
}

- (NSString *)urlStringAddCommonParamForSourceURLString:(NSString *)urlString {
    if (!urlString) {
        return nil;
    }
    
    NSMutableString *addString = [NSMutableString string];
    
    
    //添加token
    if (![urlString containsString:kUserInfoAuthToken] && [WYLoginUserManager authToken]) {
        [addString appendFormat:@"%@=%@", kUserInfoAuthToken, [WYLoginUserManager authToken]];
    }
//    //添加uid
//    if (![urlString containsString:kUserInfoUID] && [WYLoginUserManager userID]) {
//        [addString appendFormat:@"&%@=%@", kUserInfoUID, [WYLoginUserManager userID]];
//    }
    
    NSString *resultUrlString = [urlString stringByAppendingString:addString];
    return resultUrlString;
}

@end
