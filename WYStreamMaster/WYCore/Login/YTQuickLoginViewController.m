//
//  YTQuickLoginViewController.m
//  WYTelevision
//
//  Created by zurich on 2016/12/13.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTQuickLoginViewController.h"
#import "WYWebViewController.h"
#import "WYSettingConfig.h"
#import "WYLoginModel.h"
#import "WYImageCodeView.h"
#import "UINavigationBar+Awesome.h"
#import "NSString+Value.h"
#import "UIButton+YTLoginButton.h"
#import "UIButton+YTCodeVerify.h"
#import "YTLoginRegistPublic.h"
#import "WYLoginManager.h"
#import "WYCommonUtils.h"
#import "AppDelegate.h"

#define kUserProtocolURL         @"http://www.yuerlive.cn/mobile/liveagreement"

@interface YTQuickLoginViewController ()<SettingConfigChangeD>

@property (weak, nonatomic) IBOutlet UILabel *verificatCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *countryCodeTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *verificatCodeTF;
@property (strong, nonatomic) WYImageCodeView *imageCodeView;
@property (assign, nonatomic) int waitSmsSecond;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *getSMSCodeButton;
@property (strong, nonatomic) YTLoginRegistPublic *loginRegistPublic;
@end

@implementation YTQuickLoginViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        //[self setProtocol];
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    [self.navigationController setNavigationBarHidden:YES];
    
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

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.phoneTF becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"快捷登录";

    NSString *placeholder = @"请输入手机号码";
    self.phoneTF.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[WYStyleSheet currentStyleSheet].subheadLabelFont color:UIColorHex(0x3A5374)];
    
    placeholder = @"请输入验证码";
    self.verificatCodeTF.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[WYStyleSheet currentStyleSheet].subheadLabelFont color:UIColorHex(0x3A5374)];
    
    self.waitSmsSecond = [[WYSettingConfig staticInstance] getLoginSecond];
    self.loginButton.canClicked = NO;
    
    self.loginRegistPublic =  [[YTLoginRegistPublic alloc] initWithType:LoginRegistPublicTypeQuickLogin];
    [self needTapGestureRecognizer];
    
    self.getSMSCodeButton.layer.masksToBounds = YES;
    self.getSMSCodeButton.layer.cornerRadius = 3.f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextChaneg:) name:UITextFieldTextDidChangeNotification object:nil];
    
    self.navigationItem.leftBarButtonItem = [self leftBarButtonItem];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)backAction:(id)sender
{
    [super doBack];
}

- (void)checkTextChaneg:(NSNotification *)notif
{
    UITextField *textField = notif.object;
    if (self.phoneTF == textField) {
        NSString *oldText = [self.phoneTF.text copy];
        [self stringFormatWithPhone:oldText];
    }
}

-(void)stringFormatWithPhone:(NSString*)oldText
{
    NSString *newText = @"";
    NSString *tmpText = [oldText stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    if (tmpText.length > 3 && tmpText.length <= 7) {
        [stringWithAddedSpaces appendString:tmpText];
        [stringWithAddedSpaces insertString:@" " atIndex:3];
        newText = stringWithAddedSpaces;
    } else if (tmpText.length > 7){
        [stringWithAddedSpaces appendString:tmpText];
        [stringWithAddedSpaces insertString:@" " atIndex:3];
        [stringWithAddedSpaces insertString:@" " atIndex:8];
        newText = stringWithAddedSpaces;
    } else {
        newText = tmpText;
    }
    self.phoneTF.text = newText;
}

#pragma mark
#pragma mark - WYImageCodeViewDelegate

-(void)affirmImageCodeViewWithCode:(NSString *)codeText
{
    self.loginRegistPublic.serverCode = codeText;
}

#pragma mark
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.loginButton.canClicked = NO;
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.phoneTF) {
        self.accountError.hidden = YES;
    }
    if (textField == self.verificatCodeTF) {
        self.verificatCodeError.hidden = YES;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
//    [self accountErrorShowWithString:self.phoneTF.text];
//    [self verificatCodeErrorShowWithString:self.verificatCodeTF.text];
    if (textField == self.phoneTF) {
        NSString *accountString = [self.phoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        [self accountErrorShowWithString:accountString];
    }

    if (textField == self.verificatCodeTF) {
        [self verificatCodeErrorShowWithString:self.verificatCodeTF.text];
    }
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSUInteger maxLength = 13;
    NSString *oldString = [textField.text copy];
    NSString *newString = [oldString stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.phoneTF) {
        maxLength = 13;
        NSString *accountString = [self.phoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (accountString.length > 0 && self.verificatCodeTF.text.length >= 6) {
            self.loginButton.canClicked = YES;
        } else {
            self.loginButton.canClicked = NO;
        }
    }
    
    if (textField == self.verificatCodeTF) {
        maxLength = 6;
        NSString *accountString = [self.phoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (newString.length >= 6  && accountString.length > 0) {
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
    
    if (textField.markedTextRange == nil) {
        if (newString.length > maxLength && textField.text.length >= maxLength) {
            return NO;
        }
    }
    return YES;
}


#pragma mark
#pragma mark - Action

- (void)resignTextFieldFirstResponder
{
    [self.phoneTF resignFirstResponder];
    [self.verificatCodeTF resignFirstResponder];
}

- (IBAction)toSendVerificatCode
{
    [self.view endEditing:YES];
    NSString *accountString = [self.phoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![accountString isValidatePhone]) {
        [self setLoginTips:@"请输入正确的手机号"];
        return;
    }
    [self.loginRegistPublic sendMsgCode:nil mobile:accountString  fromView:self.view verifyCodeButton:self.getSMSCodeButton];
    //[[YTLoginRegistPublic loginRegistPublicWithType:LoginRegistPublicTypeQuickLogin] sendMsgCode:nil mobile:self.phoneTF.text  fromView:self.view verifyCodeButton:self.getSMSCodeButton];
    //self.getSMSCodeButton.startCodeVerigyTime = YES;
    //[self sendMsgCode:nil];
}

- (IBAction)toQuickLogin
{
    [self.view endEditing:YES];

    NSString *accountString = [self.phoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(![accountString isValidatePhone]) {
        [self setLoginTips:@"请输入正确的手机号"];
        return;
    }
    if (self.verificatCodeTF.text.length <= 0) {
        [self setLoginTips:@"还没有输入验证码哦~"];
        return;
    }
    [self userQuickLoginRequest];
}

- (void)userQuickLoginRequest
{
    [MBProgressHUD showMessage:@"登录中..."];
    
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"login"];
    
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    NSString *accountString = [self.phoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    [paramsDic setObject:accountString forKey:@"username"];
    [paramsDic setObject:[NSNumber numberWithInt:2] forKey:@"source"];
    
    [paramsDic setObject:self.verificatCodeTF.text forKey:@"checkCode"];
    [paramsDic setObject:[NSNumber numberWithInt:2] forKey:@"type"];
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO  parameters:paramsDic responseClass:[WYLoginModel class] success:^(NSInteger statusCode, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUD];
        
        if (statusCode == 0) {
            //[WYLoginUserManager setLoginPlatform:WYLoginUserTypeQucikLogin];
            WYLoginModel *loginModel = (WYLoginModel *)dataObject;
            [WYLoginUserManager updateUserDataWithLoginModel:loginModel];
            [MBProgressHUD showSuccess:@"登录成功" toView:weakSelf.view];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate initTab];
            //[[WYLoginManager sharedManager] didLoginSuccess];
//            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUINotificationKey object:nil];
//            [weakSelf.navigationController popToViewController:[weakSelf getNavigationStackControllerWithIndex:0] animated:YES];
            
        } else {
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"连接失败，请检查您的网络设置后重试" toView:weakSelf.view];
    }];
}

- (IBAction)showUserProtocol:(id)sender
{
    WYWebViewController *webVC = [[WYWebViewController alloc] initWithURLString:kUserProtocolURL];
    [self.navigationController pushViewController:webVC animated:YES];
     
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

@end
