//
//  WYNetWorkManager.h
//  WYRecordMaster
//
//  Created by zurich on 16/8/18.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYAPIGenerate.h"

typedef NS_ENUM(NSInteger, WYRequestType) {
    WYRequestTypeSuccess = 1,
    WYRequestTypeIsRegist = 2, //已经注册了，直接登录
    WYRequestTypeIsNotRegist = 5, //还没有注册
    WYRequestTypeCodeIsSend = 7, //已经发送1分钟内不能重复
    WYRequestTypeTokenInvalid = -1,//token失效了，没有刷新token机制，调起登录页面
    WYRequestTypeNeedImageCode = -2,//频繁发送验证码，需要图片验证
    WYRequestTypeVerificatCodeFailed = 6,//验证码错误
    WYRequestTypeNotLogin = -4, //未登录
    WYRequestTypeFailed = 404, //主机地址未找到
    WYRequestTypeHostCannotConnection = -1004,//未能连接到服务器
    WYRequestTypeReportDone = -3,//已经举报
    WYRequestTypeAppStorePayFailure = 21007, // 苹果内支付receipt是Sandbox receipt，但却发送至生产系统的验证服务
};

typedef void(^WYRequestSuccessBlock)(WYRequestType requestType,NSString* message,id dataObject);
typedef void(^WYRequestFailureBlock)(id responseObject, NSError * error);

@interface WYNetWorkManager : NSObject

+ (instancetype)sharedManager;

- (void)GET:(NSString *)URLString
  needCache:(BOOL)needCache
 parameters:(id)parameters
responseClass:(Class)classType
    success:(WYRequestSuccessBlock)success
    failure:(WYRequestFailureBlock)failure;

- (void)POST:(NSString *)URLString
   needCache:(BOOL)needCache
  parameters:(id)parameters
responseClass:(Class)classType
     success:(WYRequestSuccessBlock)success
     failure:(WYRequestFailureBlock)failure;

@end
