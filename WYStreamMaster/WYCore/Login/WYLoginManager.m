//
//  WYLoginManager.m
//  AnyScreen
//
//  Created by zurich on 16/8/17.
//  Copyright © 2016年 xindawn. All rights reserved.
//

#import "WYLoginManager.h"
#import "WYNavigationController.h"
#import "WYLiveViewController.h"
#import "WYLiveViewController1.h"
@interface WYLoginManager ()

@property (copy, nonatomic) WYLoginSuccessBlock         loginSuccessBlock;
@property (copy, nonatomic) WYLoginFailureBlock         loginFailureBlock;
@property (copy, nonatomic) WYLoginCancelBlock          loginCancelBlock;
@property (strong, nonatomic) WYLoginViewController     *loginViewController;

@end

@implementation WYLoginManager

+ (instancetype)sharedManager
{
    static id sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        [[[NIMSDK sharedSDK] loginManager] addDelegate:self];
    }
    return self;
}

- (void)showLoginViewControllerFromViewController:(UIViewController *)fromViewController
                                 showCancelButton:(BOOL)showCancel
                                          success:(WYLoginSuccessBlock)success
                                          failure:(WYLoginFailureBlock)failure
                                           cancel:(WYLoginCancelBlock)cancel
{
    if (!fromViewController) {
        cancel();
        return;
    }
    if (![fromViewController isKindOfClass:[UIViewController class]]) {
        cancel();
        return;
    }
    
    self.isShowLogin = YES;
    self.loginSuccessBlock = success;
    self.loginFailureBlock = failure;
    self.loginCancelBlock = cancel;
    
    WYLoginViewController *viewController = [[WYLoginViewController alloc] init];
    viewController.hidesBottomBarWhenPushed = YES;
    [fromViewController.navigationController pushViewController:viewController animated:YES];
    
    self.loginViewController = viewController;
    self.loginViewController.showCancelButton = showCancel;
    
    WS(weakSelf)
    viewController.loginSuccessBlock = ^(void) {
        [weakSelf didLoginSuccess];
        [weakSelf.loginViewController.navigationController popViewControllerAnimated:YES];
    };
    
    viewController.loginCancelBlock = ^{
        weakSelf.isShowLogin = NO;
        [weakSelf doCancel];
        [weakSelf.loginViewController.navigationController setNavigationBarHidden:NO animated:NO];
        [weakSelf.loginViewController.navigationController popViewControllerAnimated:YES];
    };
}

- (void)showLoginViewControllerFromWindow:(UIWindow *)window
                         showCancelButton:(BOOL)showCancel
                                  success:(WYLoginSuccessBlock)success
                                  failure:(WYLoginFailureBlock)failure
                                   cancel:(WYLoginCancelBlock)cancel
{
    self.loginSuccessBlock = success;
    self.loginFailureBlock = failure;
    self.loginCancelBlock = cancel;
    self.isShowLogin = YES;
    WYLoginViewController *viewController = [[WYLoginViewController alloc] init];
    self.loginViewController = viewController;
    self.loginViewController.showCancelButton = showCancel;
    WEAKSELF
    viewController.loginSuccessBlock = ^(void) {
        weakSelf.isShowLogin = NO;
        [weakSelf didLoginSuccess];
    };
    
    viewController.loginCancelBlock = ^{
        weakSelf.isShowLogin = NO;
    };
    
    WYNavigationController *loginNavigationController = [[WYNavigationController alloc] initWithRootViewController:viewController];
    
    window.rootViewController = loginNavigationController;
}

- (BOOL)currentControllerIsLoginViewController:(UIWindow*)window
{
    if(!window || !self.loginViewController){
        return NO;
    }
    
    if(![window.rootViewController isKindOfClass:[WYNavigationController class]]){
        return NO;
    }
    
    WYNavigationController *navigationController = (WYNavigationController *)window.rootViewController;
    
    if(self.loginViewController == [navigationController.viewControllers objectAtIndex:0]){
        return YES;
    }
    return NO;
}

#pragma mark 
#pragma mark - Chat Service Login

- (void)loginNIMService
{
    WEAKSELF
    //先登出，再登录,几率性登录不上的问题可能出现在这里
    if ([[NIMSDK sharedSDK].loginManager isLogined]) {
        [[NIMSDK sharedSDK].loginManager logout:^(NSError * _Nullable error) {
            NSLog(@"退出登录云信==%@",error);
            [weakSelf normalLoginNIMService];
        }];
    } else {
        [self normalLoginNIMService];
    }
    
}

- (void)normalLoginNIMService
{
    NIMAutoLoginData *loginData = [[NIMAutoLoginData alloc] init];
    loginData.account = [WYLoginUserManager nimAccountID];
    loginData.token = [WYLoginUserManager authToken];//[WYLoginUserManager userID]
    
    WEAKSELF
    [[[NIMSDK sharedSDK] loginManager] login:loginData.account token:loginData.token completion:^(NSError * _Nullable error) {
        NSLog(@"登录云信==%@",error);
        if (error.code == 302) {
            WYLog(@"302 error 云信账号密码错误");
        }
        if (!error) {
            [weakSelf toReEnterRoom];
        }
    }];
}


- (void)toReEnterRoom
{
    WYSuperViewController *sourceViewController = [WYCommonUtils getCurrentVC];
    if ([sourceViewController isKindOfClass:[WYLiveViewController1 class]]) {
        WYLiveViewController1 *liveRoomVC = (WYLiveViewController1 *)sourceViewController;
        //先退出原游客登录的直播间，改变NIMMember信息 -- bugly #448,此处调用liveroomvc有风险
        [liveRoomVC.roomView.chatroomControl exitRoom];
        [liveRoomVC.roomView.chatroomControl reEnterRoom];
    }
}

//- (void)autoLoginNIMService
//{
//    NIMAutoLoginData *autoLogindData = [[NIMAutoLoginData alloc] init];
//    autoLogindData.token = [WYLoginUserManager authToken];
//    autoLogindData.account = [WYLoginUserManager account];
//    [[[NIMSDK sharedSDK] loginManager] autoLogin:autoLogindData];
//}


- (void)loginOut
{
    
}

- (void)autoLogin
{
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"login"];
    
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    
    [paramsDic setObject:[WYLoginUserManager account] forKey:@"username"];
    [paramsDic setObject:[NSNumber numberWithInt:2] forKey:@"source"];
    if (![WYLoginUserManager password]) {
        return;
    }
    [paramsDic setObject:[WYLoginUserManager password] forKey:@"password"];
    [paramsDic setObject:[NSNumber numberWithInt:1] forKey:@"type"];

     WYNetWorkManager *networkManager = [[WYNetWorkManager alloc] init];
    [networkManager GET:requestUrl needCache:NO  parameters:paramsDic responseClass:[WYLoginModel class] success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"APP 自动登录 error:%@ data:%@",message,dataObject);
        
        if (requestType == 0) {
            WYLoginModel *loginModel = (WYLoginModel *)dataObject;

            [WYLoginUserManager updateUserDataWithLoginModel:loginModel];
            
        }else{
            
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUD];
    }];
}

#pragma mark
#pragma mark - NIMLoginManager Login

- (void)onKick:(NIMKickReason)code clientType:(NIMLoginClientType)clientType
{
    //判断用户token失效，当多端登录时会回调此方法
    if (code == NIMKickReasonByClient) {
        [MBProgressHUD showError:@"您的账号已经在其他客户端登录!"];
        //TODO:
        
    }
}

/**
 *  登录回调
 *
 *  @param step 登录步骤
 *  @discussion 这个回调主要用于客户端UI的刷新
 */
- (void)onLogin:(NIMLoginStep)step
{
    if (step == NIMLoginStepLinkFailed) {
        NSLog(@"登录云信服务器失败");
    }
    
    if (step == NIMLoginStepLinkOK) {
        NSLog(@"----------登录云信服务器成功--------");
    }
}

/**
 *  自动登录失败回调
 *
 *  @param error 失败原因
 *  @discussion 自动重连不需要上层开发关心，但是如果发生一些需要上层开发处理的错误，SDK 会通过这个方法回调
 *              用户需要处理的情况包括：AppKey 未被设置，参数错误，密码错误，多端登录冲突，账号被封禁，操作过于频繁等
 */
- (void)onAutoLoginFailed:(NSError *)error
{
    WYLog(@"自动登录回调error === %@",error);
}

#pragma mark - Private Method

- (void)didLoginSuccess {
    if (self.loginSuccessBlock) {
        [self loginNIMService];
        self.loginSuccessBlock();
        self.isShowLogin = NO;
    }
}

- (void)loginSuccessAction
{
    //正常重新登录也去登录云信
    [self loginNIMService];
}

- (void)doCancel
{
    if (self.loginCancelBlock) {
        self.loginCancelBlock();
    }
}

@end
