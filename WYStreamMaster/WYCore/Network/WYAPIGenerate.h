//
//  WYAPIGenerate.h
//  WYRecordMaster
//
//  Created by zurich on 16/8/18.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString* defaultNetworkHost =  @"69.172.89.201";//线上www.legend8888.com
//static NSString* defaultNetworkHost =  @"172.16.2.182:8000"; //测试服务器
//static NSString* defaultNetworkHost =  @"69.172.89.200:8088"; //预发布

static NSString* defaultNetworkHostTest = @"183.60.106.181:6677";//局域网
static NSString* defaultNetworkPreRelease = @"139.196.180.249:6677";//以后接入testapi
@interface WYAPIGenerate : NSObject

@property (nonatomic)BOOL isTestMode;

@property (copy, nonatomic) NSString *netWorkHost;

/**
 *  设置默认的协议类型
 */
@property (nonatomic, strong) NSString *defaultProtocol;
/**
 *  获取服务器地址
 */
@property (nonatomic, readonly) NSString* baseURL;
/**
 *  获取图片的服务器地址
 */
@property (nonatomic, readonly) NSString* baseImgUrl;

+ (WYAPIGenerate *)sharedInstance;

- (NSString *)API:(NSString *)apiName;

@end
