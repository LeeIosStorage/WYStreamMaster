//
//  WYSuperViewController.m
//  WYTelevision
//
//  Created by zurich on 16/8/23.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "WYSuperViewController.h"
#import "WYLoginManager.h"
#import "NSString+Value.h"
#import "UINavigationBar+Awesome.h"
@interface WYSuperViewController ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UILabel *customTitleLabel;
@property (strong, nonatomic) UIBarButtonItem *rightBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *leftBarButtonItem;
@property (strong, nonatomic) WYNetWorkManager           *networkManager;
@property (nonatomic, strong) UIPanGestureRecognizer *popRecognizer;

@property (copy, nonatomic) NSString *pageName;
@property (copy, nonatomic) UIViewController *cartVC;
//仅适用于登录相关页面
@property (strong, nonatomic) UIView                *loginTipsView;
@property (strong, nonatomic) UILabel               *tipsLabel;


@end

@implementation WYSuperViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

  
 }

-(void)setDisablePan:(BOOL)disablePan
{
 
    _popRecognizer.enabled = !disablePan;
    _disablePan = disablePan;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //背景色
    self.view.backgroundColor = [WYStyleSheet defaultStyleSheet].themeBackgroundColor;
    
    // 设置页面的布局从导航条下方开始，而不是从坐标0，0点开始
    self.edgesForExtendedLayout = UIRectEdgeNone;
//    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];


//    [self.navigationController.navigationBar lt_setBackgroundColor:[WYStyleSheet defaultStyleSheet].themeColor];
//    [self.navigationController.navigationBar setBarTintColor:[WYStyleSheet defaultStyleSheet].themeColor];
    
//    [self.navigationController.navigationBar lt_setBackgroundImage:[UIImage imageNamed:@"wy_navbar_bg"]];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"333333"],NSForegroundColorAttributeName,[WYStyleSheet defaultStyleSheet].navTitleFont,NSFontAttributeName,nil];
    
    if (self.navigationController.viewControllers.firstObject != self) {
        self.navigationItem.leftBarButtonItem = [self leftBarButtonItem];
    }
    
    [self initTipsView];
}

- (void)needTapGestureRecognizer
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self dismissTipsView];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
  
}

- (void)initTipsView
{
    [self.view addSubview:self.loginTipsView];
    [self.loginTipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).and.offset(64);
        make.height.mas_equalTo(@20);
    }];
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.loginTipsView);
    }];
    self.loginTipsView.hidden = YES;
}

#pragma mark
#pragma mark - Error Tip

- (void)verificatCodeErrorShowWithString:(NSString *)verificatCode
{
    if (verificatCode.length != 6) {
        self.verificatCodeError.hidden = NO;
        [self setLoginTips:@"请输入6位数字验证码"];
        return;
    }
}

- (void)accountErrorShowWithString:(NSString *)accountString
{
    if (accountString.length == 0) {
        self.accountError.hidden = NO;
        [self setLoginTips:@"请输入正确的手机号码"];
        return;
    }
    
    if (![accountString isValidatePhone]) {
        self.accountError.hidden = NO;
        [self setLoginTips:@"请输入正确的手机号码"];
        return;
    }
}

- (void)nameErrorShowWithString:(NSString *)nameString
{
    if (nameString.length == 0 && nameString.length <= 16) {
        self.accountError.hidden = NO;
        [self setLoginTips:@"请输入符合规则的昵称"];
        return;
    }
}

- (void)passwordErrorShowWithString:(NSString *)passwordString
{
    if (passwordString.length == 0 || passwordString.length < 6) {
        self.passwordError.hidden = NO;
        [self setLoginTips:@"请输入6-20位英文或数字的密码"];
        return;
    }
}

- (void)setLoginTips:(NSString *)tips
{
    WEAKSELF
    if (self.loginTipsView.isHidden) {
        [UIView animateWithDuration:1.f animations:^{
            self.loginTipsView.hidden = NO;
            self.loginTipsView.alpha = 1.f;
        } completion:^(BOOL finished) {
            if (finished) {
                [weakSelf performSelector:@selector(dismissTipsView) withObject:nil afterDelay:2.f];
            }
        }];
//        [UIView transitionWithView:self.loginTipsView duration:1.f options:UIViewAnimationOptionTransitionCurlUp animations:^{
//            
//        } completion:^(BOOL finished) {
//            if (finished) {
//                [weakSelf performSelector:@selector(dismissTipsView) withObject:nil afterDelay:2.f];
//            }
//        }];
    }
    
    self.tipsLabel.text = tips;
}

- (void)dismissTipsView
{
    WEAKSELF
    [UIView animateWithDuration:1.f animations:^{
        weakSelf.loginTipsView.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            weakSelf.loginTipsView.hidden = YES;
            weakSelf.tipsLabel.text = @"";
        }
    }];
//    [UIView transitionWithView:self.loginTipsView duration:1.f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//        self.loginTipsView.alpha = 0;
//    } completion:^(BOOL finished) {
//        if (finished) {
//            self.loginTipsView.hidden = YES;
//            self.tipsLabel.text = @"";
//        }
//    }];
}


#pragma mark 
#pragma mark - Public Method

- (void)viewTapped
{
    if ([YYTextKeyboardManager defaultManager].keyboardVisible) {
        [self.view endEditing:YES];
    }
}

- (UIBarButtonItem *)leftBarButtonItem
{
    if (!self.backImage) {
        self.backImage = [UIImage imageNamed:@"common_back"];
    }
    UIImage *backButtonImage = [UIImage imageNamed:@"common_back"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, backButtonImage.size.width, backButtonImage.size.height);

    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    return backBarButtonItem;
}

- (void)setRightButton:(UIButton *)rightButton
{
    rightButton.frame = CGRectMake(0, 0, 60, 30);
    [rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.rightBarButtonItem = rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    _rightButton = rightButton;
}

- (void)rightButtonClicked:(id)sender
{
    
}

- (void)refreshViewWithObject:(id )object
{
    
}

- (void)setNavgationBackgroundWithColor:(UIColor *)backgroundColor
{
    self.navigationController.navigationBar.translucent=YES;
    UIColor *color = backgroundColor;
    CGRect rect = CGRectMake(0, 0,SCREEN_WIDTH,64);;
 
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:(UIBarMetricsDefault)];
    self.navigationController.navigationBar.clipsToBounds=YES;
}

- (void)doBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (WYNetWorkManager *)networkManager
{
    if (!_networkManager) {
        _networkManager = [[WYNetWorkManager alloc] init];
    }
    return _networkManager;
}

#pragma mark
#pragma mark - 子类可重写

- (NSString *)pageName
{
    return self.title;
}

#pragma mark
#pragma mark - 旋转屏幕相关 子类可重写（把控制权交给子类VC处理）

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


#pragma mark -
#pragma mark - StausBar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}


#pragma mark
#pragma mark - Getter

- (UIView *)loginTipsView
{
    if (!_loginTipsView) {
        _loginTipsView = [[UIView alloc] init];
        _loginTipsView.backgroundColor = [UIColor colorWithHexString:@"FF3566"];
        self.tipsLabel = [[UILabel alloc] init];
        self.tipsLabel.textColor = [UIColor whiteColor];
        self.tipsLabel.font = [UIFont systemFontOfSize:13.f];
        self.tipsLabel.textAlignment = NSTextAlignmentCenter;
        [_loginTipsView addSubview:_tipsLabel];
    }
    return _loginTipsView;
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
