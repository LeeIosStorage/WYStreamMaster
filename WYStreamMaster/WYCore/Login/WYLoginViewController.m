//
//  WYLoginViewController.m
//  WYRecordMaster
//
//  Created by zurich on 16/8/17.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#define LOGIN_TIP_SHOW_IDENTIFIER @"WYLoginViewController_tip"
//与YTLoginUserType类型保持一致
#define Weichat_Login_Type @"5"
#define QQ_Login_Type @"3"
#define WeiBo_Login_Type @"4"

#import "WYLoginViewController.h"
#import "WYNetWorkManager.h"
#import "WYLoginModel.h"
#import "WYLoginUserManager.h"
#import "WYImageCodeView.h"
#import "NSString+Value.h"
//#import "WYRegisterViewController.h"
#import "WYSettingConfig.h"
#import "MBProgressHUD+WYTools.h"
//#import "WYWebViewController.h"

#import "WYShareManager.h"
#import "AppDelegate.h"
#import "YTQuickLoginViewController.h"
#import "WYRegisterViewController.h"

#import "UIButton+YTLoginButton.h"
#import "WYCommonUtils.h"
#import "UINavigationBar+Awesome.h"
#import "WYLoginManager.h"


@interface WYLoginViewController () <UITextFieldDelegate,WYImageCodeViewDelegate,SettingConfigChangeD>
{
    BOOL _phoneLoginType;
    WYImageCodeView *_imageCodeView;
    int _waitSmsSecond;
    
}
@property (nonatomic, assign) BOOL bViewDisappear;

@property (nonatomic, strong) NSString *loginAccountTextFieldText;


@property (nonatomic, weak) IBOutlet UIImageView *loginLogoImageView;

@property (nonatomic, weak) IBOutlet UIView *loginContainerView;
@property (nonatomic, weak) IBOutlet UIView *accountContainerView;
@property (nonatomic, weak) IBOutlet UITextField *loginAccountTextField;
@property (nonatomic, weak) IBOutlet UIView *passwordContainerView;
@property (nonatomic, weak) IBOutlet UITextField *loginPasswordTextField;
@property (nonatomic, weak) IBOutlet UIView *msgCodeContainerView;
@property (nonatomic, weak) IBOutlet UITextField *loginMsgCodeTextField;
@property (nonatomic, weak) IBOutlet UIButton *changeLoginButton;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *sendCodeButton;

@property (nonatomic, weak) IBOutlet UIView *loginTipView;

@property (nonatomic, weak) IBOutlet UIView *thirdContainerView;
@property (nonatomic, weak) IBOutlet UIButton *qqLoginButton;
@property (nonatomic, weak) IBOutlet UIButton *weixinLoginButton;
@property (nonatomic, weak) IBOutlet UIButton *weiboLoginButton;

@property (nonatomic, weak) IBOutlet UIButton       *cancelButton;
@property (strong, nonatomic) NSMutableArray        *thirdLoginArray;



@end

@implementation WYLoginViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [WYSettingConfig staticInstance].settingDelegater = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _bViewDisappear = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextChaneg:) name:UITextFieldTextDidChangeNotification object:nil];
    [WYSettingConfig staticInstance].settingDelegater = self;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
//    [self.navigationController setNavigationBarHidden:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _bViewDisappear = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
//    [self.navigationController setNavigationBarHidden:NO];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib. counting stars
    //self.edgesForExtendedLayout = UIRectEdgeTop;
    
    [self initViewUI];
    //init subviews
    [self initSubviews];
    
    
    [self setupLoginContainerView];
    [self refreshViewUI];
    
    self.cancelButton.hidden = !self.showCancelButton;
    

    //[self.navigationController.navigationBar lt_reset];
   
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        NSArray *list=self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView=(UIImageView *)obj;
                NSArray *list2=imageView.subviews;
                for (id obj2 in list2) {
                    if ([obj2 isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView2=(UIImageView *)obj2;
                        imageView2.hidden=YES;
                    }
                }
            }
        }
    }
    
    // 强制设为竖屏
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger:UIInterfaceOrientationLandscapeLeft]
                                forKey:@"orientation"];
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger:UIInterfaceOrientationPortrait]
                                forKey:@"orientation"];
    
    self.title = [WYCommonUtils acquireCurrentLocalizedText:@"wy_login"];

}

- (UIStatusBarStyle )preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)initSubviews
{
    self.passwordError.hidden = YES;
    self.accountError.hidden = YES;
    self.loginButton.canClicked = NO;
    
    self.loginAccountTextField.text = [WYLoginUserManager account];
    self.loginPasswordTextField.text = [WYLoginUserManager password];
    [self stringFormatWithPhone:self.loginAccountTextField.text];
}

- (void)initViewUI {
    _phoneLoginType = YES;
    NSString *placeholder = [WYCommonUtils acquireCurrentLocalizedText:@"wy_login_account_placeholder"];
    self.loginAccountTextField.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[WYStyleSheet currentStyleSheet].subheadLabelFont color:UIColorHex(0xcacaca)];
    
    placeholder = @"请输入6位短信验证码";
    self.loginMsgCodeTextField.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[WYStyleSheet currentStyleSheet].subheadLabelFont color:UIColorHex(0xcacaca)];
    
    placeholder = [WYCommonUtils acquireCurrentLocalizedText:@"wy_login_password_placeholder"];
    self.loginPasswordTextField.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[WYStyleSheet currentStyleSheet].subheadLabelFont color:UIColorHex(0xcacaca)];
    
    self.accountContainerView.layer.cornerRadius = 3.0;
    self.accountContainerView.layer.masksToBounds = YES;
    
    self.passwordContainerView.layer.cornerRadius = 3.0;
    self.passwordContainerView.layer.masksToBounds = YES;
    
    self.loginButton.layer.cornerRadius = 3.0;
    self.loginButton.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    [self.view addGestureRecognizer:gestureRecongnizer];
    
}

- (void)setupLoginContainerView{
    CGFloat offsetTop = 217;
    WS(weakSelf);
    [self.loginContainerView removeFromSuperview];
    [self.view addSubview:self.loginContainerView];
    [self.loginContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).offset(offsetTop);
        make.height.mas_offset(295);
    }];
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [self textFieldResignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - request
- (void)userLoginRequest{
    
    [MBProgressHUD showMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_log_in"]];
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"login"];
    
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    
    [paramsDic setObject:_loginAccountTextFieldText forKey:@"user_name"];
    [paramsDic setObject:[NSNumber numberWithInt:0] forKey:@"logintype"];
    
    NSString *password = [self.loginPasswordTextField.text md5String];
    [paramsDic setObject:password forKey:@"password"];
    
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:[WYLoginModel class] success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUD];
        
        if (requestType == WYRequestTypeSuccess) {
            
            WYLoginModel *loginModel = (WYLoginModel *)dataObject;
            
//            loginModel.chatRoomId = @"8276185";
            
            [WYLoginUserManager updateUserDataWithLoginModel:loginModel];
            
            [WYLoginUserManager setPassword:weakSelf.loginPasswordTextField.text];
            [WYLoginUserManager setAccount:weakSelf.loginAccountTextField.text];
            
            weakSelf.loginSuccessBlock();
            [MBProgressHUD showSuccess:@"登录成功" toView:weakSelf.view];
            
        }else{
            
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_server_request_errer_tip"] toView:weakSelf.view];
    }];
}

- (void)sendMsgCode:(NSString *)imageCode{
    
    [MBProgressHUD showMessage:@"请求中..." toView:self.view];
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"sendSMSCode"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[NSNumber numberWithInt:4] forKey:@"type"];
    [paramsDic setObject:_loginAccountTextFieldText forKey:@"mobile"];
    if (imageCode) {
        [paramsDic setObject:imageCode forKey:@"code"];
    }
    
    [[WYSettingConfig staticInstance] addLoginTimer];
    _sendCodeButton.enabled = NO;
    
    WS(weakSelf);
    [self.networkManager GET:requestUrl needCache:NO  parameters:paramsDic responseClass:nil success:^(NSInteger statusCode, NSString *message, id dataObject) {
        WYLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUDForView:weakSelf.view];
        
        if (statusCode == 0) {
            [MBProgressHUD showSuccess:@"验证码发送成功" toView:weakSelf.view];
            [_imageCodeView dismissView];
        }else if (statusCode == -2){
            [weakSelf removeCurrentTimer];
            [weakSelf showImageCodeView];
        }else{
            if (statusCode == 6) {
                [_imageCodeView showAnimationWithError];
            }else{
                [_imageCodeView dismissView];
            }
            [weakSelf removeCurrentTimer];
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [weakSelf removeCurrentTimer];
        [MBProgressHUD hideHUDForView:weakSelf.view];
        [MBProgressHUD showAlertMessage:@"连接失败，请检查您的网络设置后重试" toView:weakSelf.view];
    }];
}

- (void)removeCurrentTimer{
    [[WYSettingConfig staticInstance] removeLoginTimer];
    _waitSmsSecond = 0;
    [self waitLoginTimer:nil waitSecond:_waitSmsSecond];
}

/*
- (void)socialLoginWithType:(NSInteger)type{
    
    NSString *loginType = @"";
    if (type == 1) {
        loginType = [[NSString alloc]initWithString:UMShareToWechatSession];
        
    }else if (type == 2){
        loginType = [[NSString alloc]initWithString:UMShareToQQ];
        
    }else if (type == 3){
        loginType = [[NSString alloc]initWithString:UMShareToSina];
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.socialLogin = YES;
    
    WS(weakSelf);
    UMSocialSnsPlatform *snsPlatform1 = [UMSocialSnsPlatformManager getSocialPlatformWithName:loginType];
    
    snsPlatform1.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:loginType];
            id profileObject = response.thirdPlatformUserProfile;
            
            
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            if (snsAccount.userName) {
                [info setObject:snsAccount.userName forKey:@"nickname"];
            }
            if (snsAccount.usid) {
                [info setObject:snsAccount.usid forKey:@"openId"];
            }
            if (snsAccount.accessToken) {
                [info setObject:snsAccount.accessToken forKey:@"accessToken"];
            }
            if (snsAccount.iconURL) {
                [info setObject:snsAccount.iconURL forKey:@"icon"];
            }
            if ([profileObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *profileDic = (NSDictionary *)profileObject;
                if ([profileDic objectForKey:@"sex"]) {
                    NSString *sexString = [NSString stringWithFormat:@"%@",profileDic[@"sex"]];
                    if ([sexString isEqualToString:@"1"]) {
                        //男
                        sexString = @"0";
                    } else {
                        sexString = @"1";
                    }
                    [info setObject:sexString forKey:@"sex"];
                }
            } else if ([profileObject isKindOfClass:[WeiboUser class]]) {
                WeiboUser *weiboUser = (WeiboUser *)profileObject;
                if ([weiboUser.gender isEqualToString:@"f"]) {//female
                    [info setObject:@"1" forKey:@"gender"];
                } else {
                    [info setObject:@"0" forKey:@"gender"];
                }
            }
            
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:info];
            if ([loginType isEqualToString:UMShareToSina]) {
                [dic setObject:[NSNumber numberWithInt:3] forKey:@"platform"];
            }else if ([loginType isEqualToString:UMShareToQQ]){
                [dic setObject:[NSNumber numberWithInt:1] forKey:@"platform"];
                
            }else if ([loginType isEqualToString:UMShareToWechatSession]) {
                [dic setObject:[NSNumber numberWithInt:2] forKey:@"platform"];
            }
            WYLog(@"loginWithAccredit response = %@",dic);
            [weakSelf socialAffirmLogin:dic];
            
        }else{
            [[UMSocialDataService defaultDataService] requestSocialAccountWithCompletion:^(UMSocialResponseEntity *accountResponse)
             {
                 if (accountResponse.responseCode != UMSResponseCodeSuccess)
                 {
                     NSString *message = @"授权失败";
                     if (accountResponse.message) {
                         message = accountResponse.message;
                     }
                     [MBProgressHUD showBottomMessage:message toView:weakSelf.view];
                 }
             }];
        }
    });
}

-(void)socialAffirmLogin:(NSDictionary *)info{
    
    if (![info objectForKey:@"openId"]) {
        [MBProgressHUD showBottomMessage:@"授权失败" toView:self.view];
        return;
    }
    
    [MBProgressHUD showMessage:@"请求中..." toView:self.view];
    WS(weakSelf);
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"thirdLogin"];
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:info];
    //    [paramsDic setObject:[info objectForKey:@"openId"] forKey:@"openId"];
    //    [paramsDic setObject:[info objectForKey:@"type"] forKey:@"platform"];
    [paramsDic setObject:[NSNumber numberWithInt:1] forKey:@"source"];
    
    [self.networkManager GET:requestUrl needCache:NO caCheKey:nil parameters:paramsDic responseClass:[WYLoginModel class] success:^(NSInteger statusCode, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUDForView:weakSelf.view];
        
        if (statusCode == 0) {
            [WYLoginUserManager setLoginPlatform:WYLoginUserTypeThirdPart];
            if (dataObject) {
                WYLoginModel *loginModel = (WYLoginModel *)dataObject;
                if (!loginModel.isUp) {
                    loginModel.isUp = @"0";
                }
                [WYLoginUserManager updateUserDataWithLoginModel:loginModel];
                weakSelf.loginSuccessBlock();
                [MBProgressHUD showSuccess:@"登录成功" toView:weakSelf.view];
            } else {
                //TODO:
                //                [MBProgressHUD showSuccess:@"授权成功" toView:weakSelf.view];
                [weakSelf gotoBindPhoneVc:info];
            }
            
        }else{
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view];
        [MBProgressHUD showAlertMessage:@"连接失败，请检查您的网络设置后重试" toView:weakSelf.view];
    }];
}
 */

#pragma mark - IBAction

- (IBAction)doLogin:(id)sender
{
    [self.loginAccountTextField resignFirstResponder];
    [self.loginPasswordTextField resignFirstResponder];
    [self.loginMsgCodeTextField resignFirstResponder];
    [self userLoginRequest];
}
- (IBAction)changeLoginTypeAction:(id)sender {
    _phoneLoginType = !_phoneLoginType;
    [self refreshViewUI];
    
    [self changeLoginModeWithAnimation:NO];
}
- (IBAction)registerClickAction:(id)sender {
    
//    WYRegisterViewController *registerVc = [[WYRegisterViewController alloc] init];
//    registerVc.vcType = 1;
//    [self.navigationController pushViewController:registerVc animated:YES];
    
}
- (IBAction)thirdLoginAction:(id)sender {
    NSInteger tag = ((UIButton *)sender).tag;
    //[self socialLoginWithType:tag];
}

- (IBAction)forgetPasswordAction:(id)sender
{
//    YTInputAccountViewController *inputAccountVc = [[YTInputAccountViewController alloc] init];
//    [self.navigationController pushViewController:inputAccountVc animated:YES];
}

- (IBAction)getCodeAction:(id)sender {
    [self sendMsgCode:nil];
}
- (IBAction)loginTipAction:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"YES" forKey:LOGIN_TIP_SHOW_IDENTIFIER];
    self.loginTipView.hidden = YES;
}

- (IBAction)cancelLogin:(id)sender
{
    if (self.loginCancelBlock) {
        self.loginCancelBlock();
    }
}

- (IBAction)toQuickLogin:(id)sender
{
    WYRegisterViewController *registerVc = [[WYRegisterViewController alloc] init];
    WYNavigationController *createNav = [[WYNavigationController alloc] initWithRootViewController:registerVc];
    [self presentViewController:createNav animated:YES completion:NULL];
    
//    YTQuickLoginViewController *quickLoginVC = [[YTQuickLoginViewController alloc] initWithNibName:@"YTQuickLoginViewController" bundle:nil];
//    [self.navigationController pushViewController:quickLoginVC animated:YES];
}

#pragma mark - custom
- (void)refreshViewUI{
    
    NSString *changeButtonText = @"使用密码登录";
    UIImage *changeButtonImage = [UIImage imageNamed:@"login_switch_up"];
    if (_phoneLoginType) {
        changeButtonText = @"使用验证码登录";
        changeButtonImage = [UIImage imageNamed:@"login_switch_down"];
    }
    [self.changeLoginButton setTitle:changeButtonText forState:UIControlStateNormal];
    [self.changeLoginButton setImage:changeButtonImage forState:UIControlStateNormal];
    
    [self loginButtonEnabled];
    
}

- (void)changeLoginModeWithAnimation:(BOOL)animation{
    if (animation) {
        WS(weakSelf);
        self.changeLoginButton.enabled = NO;
        self.msgCodeContainerView.hidden = NO;
        self.passwordContainerView.hidden = NO;
        weakSelf.msgCodeContainerView.alpha = 1.0;
        weakSelf.passwordContainerView.alpha = 1.0;
        CGFloat msgCodeHeight = 0;
        CGFloat passwordHeight = 37;
        if (_phoneLoginType) {
            msgCodeHeight = 37;
            passwordHeight = 0;
        }
        [self.msgCodeContainerView removeFromSuperview];
        [self.loginContainerView addSubview:self.msgCodeContainerView];
        [self.msgCodeContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.accountContainerView.mas_bottom).offset(36);
            make.left.equalTo(weakSelf.loginContainerView).offset(35);
            make.right.equalTo(weakSelf.loginContainerView).offset(-35);
            make.height.mas_offset(msgCodeHeight);
        }];
        [self.passwordContainerView removeFromSuperview];
        [self.loginContainerView addSubview:self.passwordContainerView];
        [self.passwordContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.accountContainerView.mas_bottom).offset(36);
            make.left.equalTo(weakSelf.loginContainerView).offset(35);
            make.right.equalTo(weakSelf.loginContainerView).offset(-35);
            make.height.mas_offset(passwordHeight);
        }];
        [weakSelf.loginContainerView layoutIfNeeded];
        
        [UIView animateWithDuration:0.4 animations:^{
            [weakSelf.msgCodeContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_offset(passwordHeight);
            }];
            [weakSelf.passwordContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_offset(msgCodeHeight);
            }];
            if (_phoneLoginType) {
                weakSelf.msgCodeContainerView.alpha = 0.0;
            }else{
                weakSelf.passwordContainerView.alpha = 0.0;
            }
            [weakSelf.msgCodeContainerView layoutIfNeeded];
            [weakSelf.passwordContainerView layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.changeLoginButton.enabled = YES;
        }];
    }else{
        self.msgCodeContainerView.hidden = NO;
        self.passwordContainerView.hidden = YES;
        if (_phoneLoginType) {
            self.msgCodeContainerView.hidden = YES;
            self.passwordContainerView.hidden = NO;
        }
    }
}

- (BOOL)loginButtonEnabled{
    
    NSString *passwordText = [_loginPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *msgCodeText = [_loginMsgCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *accountText = [self removeWhitespaceWithPhone:[_loginAccountTextField text]];
    if (accountText.length > 0) {
        if (_phoneLoginType) {
            if (passwordText.length >= 6) {
                _loginButton.canClicked = YES;
                return YES;
            }
        }else{
            _sendCodeButton.canClicked = YES;
            if (msgCodeText.length >= 6) {
                _loginButton.canClicked = YES;
                return YES;
            }
        }
        _loginButton.canClicked = NO;
        return NO;
    }
    _loginButton.canClicked = NO;
    _sendCodeButton.canClicked = NO;
    return NO;
}

- (void)checkTextChaneg:(NSNotification *)notif
{
    UITextField *textField = notif.object;
    if (_loginAccountTextField == textField) {
        NSString *oldText = [_loginAccountTextField.text copy];
        [self stringFormatWithPhone:oldText];
    }
    [self loginButtonEnabled];
}

-(void)stringFormatWithPhone:(NSString*)oldText{
//    NSString *newText = @"";
//    NSString *tmpText = [oldText stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
//    if (tmpText.length > 3 && tmpText.length <= 7) {
//        [stringWithAddedSpaces appendString:tmpText];
//        [stringWithAddedSpaces insertString:@" " atIndex:3];
//        newText = stringWithAddedSpaces;
//    }else if (tmpText.length > 7){
//        [stringWithAddedSpaces appendString:tmpText];
//        [stringWithAddedSpaces insertString:@" " atIndex:3];
//        [stringWithAddedSpaces insertString:@" " atIndex:8];
//        newText = stringWithAddedSpaces;
//    }else{
//        newText = tmpText;
//    }
//    _loginAccountTextField.text = newText;
    
    _loginAccountTextField.text = oldText;
    _loginAccountTextFieldText = [self removeWhitespaceWithPhone:[_loginAccountTextField text]];
}
-(NSString *)removeWhitespaceWithPhone:(NSString*)string{
//    NSString *tmpText = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}

- (void)textFieldResignFirstResponder{
    [self.loginAccountTextField resignFirstResponder];
    [self.loginPasswordTextField resignFirstResponder];
    [self.loginMsgCodeTextField resignFirstResponder];
}

- (void)showImageCodeView{
    
    [self textFieldResignFirstResponder];
    _imageCodeView = [[WYImageCodeView alloc] init:nil];
    _imageCodeView.telephone = _loginAccountTextFieldText;
    _imageCodeView.delegate = self;
    [_imageCodeView show];
}

- (void)gotoBindPhoneVc:(NSDictionary *)info{
    
    WS(weakSelf);
//    WYBindPhoneViewController *bindPhoneVc = [[WYBindPhoneViewController alloc] init];
//    bindPhoneVc.socialInfo = info;
//    bindPhoneVc.bindSuccessBlock = ^{
//        weakSelf.loginSuccessBlock();
//    };
//    [self.navigationController pushViewController:bindPhoneVc animated:YES];
}

#pragma mark
#pragma mark - Third Login Control

- (void)judgeThirdLoginCount
{
    self.thirdLoginArray = [NSMutableArray arrayWithCapacity:0];
    if ([WXApi isWXAppInstalled]) {
        [self.thirdLoginArray addObject:@{@"type": Weichat_Login_Type, @"image" : [UIImage imageNamed:@"login_wechat"]}];
    }
    if ([QQApiInterface isQQInstalled]) {
        [self.thirdLoginArray addObject:@{@"type": QQ_Login_Type, @"image" : [UIImage imageNamed:@"login_qq"]}];
    }
    if ([WeiboSDK isWeiboAppInstalled]) {
        [self.thirdLoginArray addObject:@{@"type": WeiBo_Login_Type, @"image" : [UIImage imageNamed:@"login_weibo"]}];
    }
}

- (void)arrangeThirdLogin
{
    for (int i = 0; i < self.thirdLoginArray.count; i ++) {
        NSDictionary *dic = self.thirdLoginArray[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = [dic[@"type"] integerValue];
        [button setImage:dic[@"image"] forState:UIControlStateNormal];
        [self.thirdContainerView addSubview:button];
        
    }
    
}

#pragma mark -
#pragma mark - NSNotification


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.loginButton.canClicked = NO;
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    if (textField == self.loginAccountTextField) {
//        self.accountError.hidden = YES;
//    }
//    if (textField == self.loginPasswordTextField) {
//        self.passwordError.hidden = YES;
//    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //    [self accountErrorShowWithString:self.loginAccountTextFieldText];
    //    [self passwordErrorShowWithString:self.loginPasswordTextField.text];
//    if (textField == self.loginAccountTextField) {
//        [self accountErrorShowWithString:self.loginAccountTextFieldText];
//    }
//    if (textField == self.loginPasswordTextField) {
//        [self passwordErrorShowWithString:self.loginPasswordTextField.text];
//    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *oldString = [textField.text copy];
    NSString *newString = [oldString stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.loginAccountTextField) {
        if (newString.length > 30 && self.loginPasswordTextField.text.length >= 6) {
            self.loginButton.canClicked = YES;
        } else {
            self.loginButton.canClicked = NO;
        }
    }
    if (textField == self.loginPasswordTextField) {
        NSString *accountString = self.loginAccountTextField.text;
        if (newString.length >= 6 && accountString.length > 0) {
            self.loginButton.canClicked = YES;
        } else {
            self.loginButton.canClicked = NO;
        }
    }
    
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    
    if (!string.length && range.length > 0) {
        return YES;
    }
    
    
    if (textField == _loginAccountTextField && textField.markedTextRange == nil) {
        if (newString.length > 30 && textField.text.length >= 30) {
            return NO;
        }
    }else if (textField == _loginPasswordTextField && textField.markedTextRange == nil){
        if (newString.length > 20 && textField.text.length >= 20) {
            return NO;
        }
    }else if (textField == _loginMsgCodeTextField && textField.markedTextRange == nil){
        if (newString.length > 6 && textField.text.length >= 6) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - WYImageCodeViewDelegate
-(void)affirmImageCodeViewWithCode:(NSString*)codeText{
    [self sendMsgCode:codeText];
}

#pragma mark - SettingConfigChangeD
- (void)waitLoginTimer:(NSTimer *)aTimer waitSecond:(int)waitSecond{
    _waitSmsSecond = waitSecond;
    if (_waitSmsSecond <= 0) {
        NSString *phoneText = _loginAccountTextFieldText;
        if ([phoneText isPhone]) {
            _sendCodeButton.enabled = YES;
        }
        [_sendCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_sendCodeButton setTitle:@"获取验证码" forState:UIControlStateDisabled];
        return;
    }
    
    [_sendCodeButton setTitle:[NSString stringWithFormat:@"重新获取（%d）",_waitSmsSecond] forState:UIControlStateNormal];
    [_sendCodeButton setTitle:[NSString stringWithFormat:@"重新获取（%d）",_waitSmsSecond] forState:UIControlStateDisabled];
}

#pragma mark
#pragma mark - Getter



#pragma mark
#pragma mark - Super Method(屏幕旋转)

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


@end
