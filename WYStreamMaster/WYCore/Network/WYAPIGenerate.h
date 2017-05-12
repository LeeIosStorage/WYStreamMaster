//
//  WYAPIGenerate.h
//  WYRecordMaster
//
//  Created by zurich on 16/8/18.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* defaultNetworkHost =  @"legend8888.com";//线上103.230.243.174:80 
static NSString* defaultNetworkHostTest = @"172.16.10.27";//局域网
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
