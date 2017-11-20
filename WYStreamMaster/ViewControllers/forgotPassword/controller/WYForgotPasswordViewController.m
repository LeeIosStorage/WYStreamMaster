//
//  Forgot password Forgot password WYForgotPasswordViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/25.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYForgotPasswordViewController.h"

@interface WYForgotPasswordViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *nicknameField;
@property (strong, nonatomic) IBOutlet UITextField *mailboxField;
@property (strong, nonatomic) IBOutlet UIButton *backLoginButton;

@end

@implementation WYForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    UITapGestureRecognizer *tapGestureView =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureView)];
    [self.view addGestureRecognizer:tapGestureView];
    self.nicknameField.delegate = self;
    
    NSMutableAttributedString *backLoginAttributedString = [[NSMutableAttributedString alloc] initWithString:self.backLoginButton.titleLabel.text];
    [backLoginAttributedString addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(10, 2)];
    
    self.backLoginButton.titleLabel.attributedText = backLoginAttributedString;
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - event
- (IBAction)backLogin:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)applyAction:(UIButton *)sender {
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"forgot_password"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:self.mailboxField.text forKey:@"email"];
    [paramsDic setObject:self.nicknameField.text forKey:@"user_name"];
    
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUD];
        
        if (requestType == WYRequestTypeSuccess) {
//            [YTToast showSuccess:@"申请成功"];
//            [MBProgressHUD showSuccess:@"申请成功" toView:weakSelf.view];
        }else{
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_server_request_errer_tip"] toView:weakSelf.view];
    }];
}

- (void)tapGestureView
{
    [self.nicknameField resignFirstResponder];
    [self.mailboxField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.nicknameField) {
        NSString *fieldText = self.nicknameField.text;
        if ([fieldText length] >= 10) {
            return NO;
        }
    }
    return YES;
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
