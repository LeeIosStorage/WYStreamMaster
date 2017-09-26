//
//  WYNewRegisterViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/25.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYRegistersViewController.h"
#import "NSString+Value.h"

@interface WYRegistersViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nicknameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *againPasswordField;
@property (strong, nonatomic) IBOutlet UITextField *mailboxField;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation WYRegistersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - setup
- (void)setupView
{
    [self.passwordField setTextColor:[UIColor whiteColor]];
    [self.passwordField setText:@"请输入密码"];
    
    [self.againPasswordField setTextColor:[UIColor whiteColor]];
    [self.againPasswordField setText:@"请再次输入密码"];
    
    [self.mailboxField setTextColor:[UIColor whiteColor]];
    [self.mailboxField setText:@"请输入个人邮箱"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - network
- (void)userRegisterRequest{
    NSString *accountText = [_nicknameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailText = [_mailboxField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //    NSString *agentText = [_agentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![emailText isValidateEmail]) {
        [MBProgressHUD showError:[WYCommonUtils acquireCurrentLocalizedText:@"wy_validate_email_tip"]];
        return;
    }
    
    [MBProgressHUD showMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_info_submit_ing"]];
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"apply_anchor"];
    
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    
    [paramsDic setObject:accountText forKey:@"nick_name"];
    [paramsDic setObject:emailText forKey:@"email"];
//    [paramsDic setObject:_avatarUrlStr forKey:@"head_icon"];
//    [paramsDic setObject:_sugaoUrlStr forKey:@"low_pic"];
//    [paramsDic setObject:_makeupUrlStr forKey:@"mid_pic"];
//    [paramsDic setObject:_artsUrlStr forKey:@"hig_pic"];
//    if (self.areaCode.length > 0) {
//        [paramsDic setObject:self.areaCode forKey:@"anchor_country"];//channel_code
//    }
    
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUD];
        
        if (requestType == WYRequestTypeSuccess) {
            [MBProgressHUD showSuccess:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_succeed_tip"] toView:weakSelf.view];
            
            [weakSelf performSelector:@selector(rightButtonClicked:) withObject:nil afterDelay:1.0];
        }else{
            
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_failure_tip"] toView:weakSelf.view];
    }];
    
}
#pragma mark - event
- (IBAction)backLogin:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)clickRegisterButton:(UIButton *)sender {
    [self userRegisterRequest];
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
