//
//  YTLoginRegistPublic.m
//  WYTelevision
//
//  Created by zurich on 2016/12/16.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTLoginRegistPublic.h"
#import "UIButton+YTCodeVerify.h"
#import "WYImageCodeView.h"
//#import "WYRegisterViewController.h"
//#import "YTInputAccountViewController.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
@interface YTLoginRegistPublic ()<WYImageCodeViewDelegate>
{
    WYImageCodeView   *_imageCodeView;
}

@property (strong, nonatomic) UIView            *sourceView;
@property (strong, nonatomic) WYNetWorkManager  *networkManager;
//@property (strong, nonatomic) WYImageCodeView   *imageCodeView;

@property (copy, nonatomic) NSString            *accoutString;
@property (strong, nonatomic) UIButton          *verifyCodeButton;
@property (assign, nonatomic) LoginRegistPublicType loginRegistPublicType;
@end

@implementation YTLoginRegistPublic

+ (YTLoginRegistPublic *)loginRegistPublicWithType:(LoginRegistPublicType )type
{
    YTLoginRegistPublic *loginRegistPublic = [[YTLoginRegistPublic alloc] init];
    loginRegistPublic.loginRegistPublicType = type;
    return loginRegistPublic;
}

- (instancetype)initWithType:(LoginRegistPublicType )type
{
    if (self = [super init]) {
        self.loginRegistPublicType = type;
    }
    return self;
}

- (void)setServerCode:(NSString *)serverCode
{
    _serverCode = serverCode;
    [self sendSMSCodeWithCode:_serverCode];
}

- (void)sendMsgCode:(NSString *)imageCode mobile:(NSString *)mobile fromView:(UIView *)fromView verifyCodeButton:(UIButton *)verifyCodeButton
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [MBProgressHUD showAlertMessage:@"连接失败，请检查您的网络设置后重试" toView:fromView];
        return;
    }
    
    self.sourceView = fromView;
    self.accoutString = mobile;
    if (!self.verifyCodeButton) {
        self.verifyCodeButton = verifyCodeButton;
    }
    
    if (self.loginRegistPublicType == LoginRegistPublicTypeGetPassword || self.loginRegistPublicType == LoginRegistPublicTypeRegist) {
        [self showImageCodeView];
    } else {
        [self sendSMSCodeWithCode:nil];
    }
}

- (void)sendSMSCodeWithCode:(NSString *)code
{

    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"sendSMSCode"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[NSNumber numberWithInt:self.loginRegistPublicType] forKey:@"type"];
    [paramsDic setObject:self.accoutString forKey:@"mobile"];
    if (code) {
        [paramsDic setObject:code forKey:@"code"];
    }
    
    WEAKSELF;
    [self.networkManager GET:requestUrl needCache:NO  parameters:paramsDic responseClass:nil success:^(WYRequestType statusCode, NSString *message, id dataObject) {
        WYLog(@"error:%@ data:%@",message,dataObject);
        //[MBProgressHUD hideHUDForView:weakSelf.sourceView];
        
        if (statusCode == WYRequestTypeSuccess || statusCode == WYRequestTypeCodeIsSend) {
            if (statusCode == WYRequestTypeCodeIsSend) {
                [MBProgressHUD showAlertMessage:message toView:weakSelf.sourceView];
                return ;
            }
            self.verifyCodeButton.backgroundColor = [UIColor colorWithHexString:@"2E3E4A"];
            [self.verifyCodeButton setTitleColor:[UIColor colorWithHexString:@"7A92AD"] forState:UIControlStateNormal];
            [MBProgressHUD showSuccess:@"验证码发送成功" toView:weakSelf.sourceView];
            self.verifyCodeButton.startCodeVerigyTime = YES;
            if (weakSelf.sendCodeSuccessBlock) {
                weakSelf.sendCodeSuccessBlock();
            }
            
            [_imageCodeView dismissView];
        } else {
            if (statusCode == WYRequestTypeNeedImageCode){
                [weakSelf showImageCodeView];
            } else if (statusCode == WYRequestTypeIsRegist) {
                [_imageCodeView dismissView];
                [weakSelf isRegistToLogin];
            } else if (statusCode == WYRequestTypeIsNotRegist) {
                [_imageCodeView dismissView];
                [weakSelf notRegistAction];
            } else {
                if (statusCode == WYRequestTypeVerificatCodeFailed) {
                    [_imageCodeView showAnimationWithError];
                } else {
                    [_imageCodeView dismissView];
                }
            }
            
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.sourceView];
        [MBProgressHUD showAlertMessage:@"连接失败，请检查您的网络设置后重试" toView:weakSelf.sourceView];
        //[MBProgressHUD showError:@"请求失败" toView:weakSelf.sourceView];
    }];
}

- (void)getServerCode
{
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"checkCode_server"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];

    [paramsDic setObject:self.accoutString forKey:@"phone"];
    
    WEAKSELF;
    [self.networkManager GET:requestUrl needCache:NO  parameters:paramsDic responseClass:nil success:^(WYRequestType statusCode, NSString *message, id dataObject) {
        
        if (statusCode == WYRequestTypeSuccess) {
            [weakSelf sendSMSCodeWithCode:nil];
        }
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.sourceView];
        [MBProgressHUD showError:@"请求失败" toView:weakSelf.sourceView];
    }];
}

- (void)showImageCodeView
{
    _imageCodeView = [[WYImageCodeView alloc] init:nil];
    _imageCodeView.telephone = self.accoutString;
    _imageCodeView.delegate = (id)[self.sourceView nextResponder];
    [_imageCodeView show];
}

#pragma mark
#pragma mark - Action

- (void)isRegistToLogin
{
//    WYSuperViewController *sourceVC = (WYSuperViewController *)[self.sourceView nextResponder];
//    if ([sourceVC isKindOfClass:[WYRegisterViewController class]]) {
//        [((WYRegisterViewController *)sourceVC) showIsRegist];
//    }
   // [sourceVC.navigationController popToViewController:[sourceVC getNavigationStackControllerWithIndex:1] animated:YES];
}

- (void)notRegistAction
{
//    WYSuperViewController *sourceVC = (WYSuperViewController *)[self.sourceView nextResponder];
//    if ([sourceVC isKindOfClass:[YTInputAccountViewController class]]) {
//        [((YTInputAccountViewController *)sourceVC) showNotRegist];
//    }
}

#pragma mark
#pragma mark - WYImageCodeViewDelegate

-(void)affirmImageCodeViewWithCode:(NSString *)codeText
{
    [self sendMsgCode:codeText mobile:self.accoutString fromView:self.sourceView verifyCodeButton:self.verifyCodeButton];
}

- (WYNetWorkManager *)networkManager
{
    if (!_networkManager) {
        _networkManager = [[WYNetWorkManager alloc] init];
    }
    return _networkManager;
}

//- (WYImageCodeView *)imageCodeView
//{
//    _imageCodeView = [[WYImageCodeView alloc] init:nil];
//    _imageCodeView.telephone = self.accoutString;
//    _imageCodeView.delegate = self;
//    return _imageCodeView;
//}


@end
