//
//  YTLoginRegistPublic.h
//  WYTelevision
//
//  Created by zurich on 2016/12/16.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LoginRegistPublicType) {
    LoginRegistPublicTypeNone = 0,   //no type if defualt
    LoginRegistPublicTypeRegist = 1,
    LoginRegistPublicTypeGetPassword = 2,
    LoginRegistPublicTypeQuickLogin = 4,
    LoginRegistPublicTypeThirdLoginBindingPhone = 5,
    LoginRegistPublicTypeHtml5Regist = 6,
};

@interface YTLoginRegistPublic : NSObject

@property (copy, nonatomic) NSString *serverCode;
@property (copy, nonatomic) void (^sendCodeSuccessBlock)();

+ (YTLoginRegistPublic *)loginRegistPublicWithType:(LoginRegistPublicType )type;

- (instancetype)initWithType:(LoginRegistPublicType )type;

- (void)sendMsgCode:(NSString *)imageCode mobile:(NSString *)mobile fromView:(UIView *)fromView verifyCodeButton:(UIButton *)verifyCodeButton;

@end
