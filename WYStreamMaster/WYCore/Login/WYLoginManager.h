//
//  WYLoginManager.h
//  AnyScreen
//
//  Created by zurich on 16/8/17.
//  Copyright © 2016年 xindawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYLoginViewController.h"

@interface WYLoginManager : NSObject

///防止多次弹框
@property (assign, nonatomic) BOOL isShowLogin;
@property (strong, nonatomic) WYLoginModel  *loginModel;

+ (instancetype)sharedManager;

- (void)showLoginViewControllerFromViewController:(UIViewController *)fromViewController
                                        showCancelButton:(BOOL)showCancel
                                          success:(WYLoginSuccessBlock)success
                                          failure:(WYLoginFailureBlock)failure
                                           cancel:(WYLoginCancelBlock)cancel;

- (void)showLoginViewControllerFromWindow:(UIWindow *)window
                         showCancelButton:(BOOL)showCancel
                                  success:(WYLoginSuccessBlock)success
                                  failure:(WYLoginFailureBlock)failure
                                   cancel:(WYLoginCancelBlock)cancel;

- (BOOL)currentControllerIsLoginViewController:(UIWindow*)window;

//自动登录云信
//- (void)autoLoginNIMService;

- (void)loginNIMService;

- (void)autoLogin;

- (void)didLoginSuccess;
@end
