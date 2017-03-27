//
//  WYAPIGenerate.m
//  WYRecordMaster
//
//  Created by zurich on 16/8/18.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "WYAPIGenerate.h"

//因为path的不规律，暂时只发现了v4是有规律的，那么我们假设是有规律的好不啦



const NSString* defaultHttpsNetworkHost =  @"";
const NSString* defaultHttpsNetworkHostTest = @"";

static NSString* const apiFileName = @"NetWorkConfig";
static NSString* const apiFileExtension = @"json";

@interface WYAPIGenerate ()
{
    NSDictionary * cachedDictionary;
}

@end

@implementation WYAPIGenerate

+ (NSDictionary *)apiDictionary
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:apiFileName ofType:apiFileExtension];
    if (!filePath) {
        WYLog(@"________API Json文件格式错误,请校验 ！！！！！！！");
    }
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    return dic;
}

+ (WYAPIGenerate *)sharedInstance
{
    static WYAPIGenerate *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(& onceToken,^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSString *)defaultProtocol {
    if (!_defaultProtocol) {
        return @"http";
    }
    return _defaultProtocol;
}

- (NSString *)baseURL{
    const NSString *host = self.netWorkHost;
    //    host = defaultNetworkPreRelease;
    return [NSString stringWithFormat:@"%@://%@",self.defaultProtocol,host];
}

- (NSString *)baseImgUrl{
    return IMG_URL;
}

- (NSString*)API:(NSString*)apiName
{
    if (!apiName || apiName.length == 0) {
        return nil;
    }
    NSDictionary* configDict = nil;
    if (!cachedDictionary) {
        configDict = [[self class] apiDictionary];
    }
    else {
        configDict = cachedDictionary;
    }
    //self.isTestMode = NO;
    NSDictionary *dic = [configDict objectForKey:apiName];
    NSString* apiProtocol = nil;
    const NSString *host   = self.netWorkHost;
    
    apiProtocol=[dic objectForKey:@"protocol"] ? [dic objectForKey:@"protocol"]:@"http";
    if ([apiProtocol isEqual:@"http"]) {
        host = self.netWorkHost;
    }
    
#ifdef DEBUG
    if (!host) {
        host = defaultNetworkHostTest;
    }
#else
    if (!host) {
        host = defaultNetworkHost;
    }
    
#endif
    
//    host = defaultNetworkPreRelease;
    
    //拼接url
    //拼接主机地址
    NSString *apiUrl = [NSString stringWithFormat:@"%@://%@",apiProtocol,host];
    ///拼接路径
    NSString *version = dic[@"version"];
    if (version && ![version isEqual:[NSNull null]]) {
        apiUrl = [apiUrl stringByAppendingFormat:@"/%@",version];
    }
    
    NSString *control = dic[@"control"];
    if (control && ![control isEqual:[NSNull null]]) {
        apiUrl = [apiUrl stringByAppendingFormat:@"/%@", control];
    }
    
    NSString *action = dic[@"action"];
    if (action && ![action isEqual:[NSNull null]]) {
        apiUrl = [apiUrl stringByAppendingFormat:@"/%@", action];
    }
    
    apiUrl = [apiUrl stringByAppendingString:@"?"];
    
    return apiUrl;
    
}




@end
