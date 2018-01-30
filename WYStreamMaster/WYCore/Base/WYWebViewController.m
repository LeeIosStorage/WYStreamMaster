//
//  WYWebViewController.m
//  WYTelevision
//
//  Created by zurich on 16/9/10.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "WYWebViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"


@interface WYWebViewController ()<UIWebViewDelegate,NJKWebViewProgressDelegate>

@property (strong, nonatomic) NJKWebViewProgress *progressProxy;
@property (strong, nonatomic) NJKWebViewProgressView *webProgressView;
@property (strong, nonatomic) NSURL *URL;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) UIWebView *webView;

/* 需要重新登录(我要当主播，注册成功之后) */
@property (assign, nonatomic) BOOL shouldReLogin;

@end

@implementation WYWebViewController

- (instancetype)initWithURL:(NSURL *)url
{
    if (self = [super init]) {
        self.URL = url;
        // 对网址进行userid token拼接处理
        NSMutableString *urlString = [NSMutableString string];
        [urlString appendString:[url absoluteString]];
        if ([urlString containsString:@"?"]) {
            if ([WYLoginUserManager userID]) {
                [urlString appendString:[NSString stringWithFormat:@"&userId=%@",[WYLoginUserManager userID]]];
            }
        } else {
            if ([WYLoginUserManager userID]) {
                [urlString appendString:[NSString stringWithFormat:@"?userId=%@",[WYLoginUserManager userID]]];
            }
        }
        
        if ([WYLoginUserManager authToken]) {
            [urlString appendString:[NSString stringWithFormat:@"&token=%@",[WYLoginUserManager authToken]]];
        }
        self.canShare = YES;
//        self.urlString = [url absoluteString];
        self.urlString = urlString;
    }
    return self;
}

- (instancetype)initWithURLString:(NSString *)urlString
{
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

#pragma mark
#pragma mark - View Lifecyle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.webView) {
        [self createWebView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [self leftBarButtonItem];
    
}

- (void)loadURL:(NSURL *)url
{
    // 设置userAgent
    NSString *agent = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserAgent"];
    if (agent == nil) {
        //get the original user-agent of webview
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        NSLog(@"old agent :%@", oldAgent);
        
        //add my info to the new agent
        NSString *newAgent = [oldAgent stringByAppendingFormat:@"YuertvBrowser/%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
        NSLog(@"new agent :%@", newAgent);
        
        //regist the new agent
        NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    }
    
    // 本地html文件测试
//    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"share" ofType:@"html"];
//    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    [self.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:filePath]];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.webProgressView removeFromSuperview];
    
    if (self.shouldReLogin) {
        //调用登录接口
        //[[WYLoginManager sharedManager] autoLogin];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    self.webView = nil;
}

#pragma mark -
#pragma mark Super Methods

- (void)doBack
{
    // 重写返回按钮事件
    if (self.webView.canGoBack) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark
#pragma mark - Private Methods

- (void)createRightBarButton
{
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setImage:[UIImage imageNamed:@"common_forward"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(onWebShareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton = shareButton;
}

- (void)onWebShareButtonClick:(UIButton *)button
{
    //点击分享按钮
//    YTWebShareModel *shareModel = [[YTWebShareModel alloc] init];
//    shareModel.shareTitle = self.title;
//    shareModel.shareWebUrl = self.urlString;
//    
//    WYShareActionSheet *shareAction = [[WYShareActionSheet alloc] init];
//    shareAction.owner = self;
//    shareAction.isVideo = NO;
//    [shareAction shareInfoData:shareModel];
//    [shareAction showShareAction];
}

- (void)createWebView
{
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    self.webView.scalesPageToFit = YES;
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self addProgressView];
    
    
    [self loadURL:self.URL];
}

- (void)addProgressView
{
    self.progressProxy = [[NJKWebViewProgress alloc] init];
    self.webView.delegate = self.progressProxy;
    self.progressProxy.webViewProxyDelegate = self;
    self.progressProxy.progressDelegate = self;
    
    CGRect navBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0,
                                 navBounds.size.height - 2,
                                 navBounds.size.width,
                                 2);
    self.webProgressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    self.webProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.webProgressView.progressBarView.backgroundColor = [WYStyleSheet currentStyleSheet].tabBarSelectedTextColor;
    [self.webProgressView setProgress:0 animated:YES];
    
    [self.navigationController.navigationBar addSubview:self.webProgressView];
}

#pragma mark -
#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestPath = [[request URL] absoluteString];
    self.urlString = requestPath;
/*
    // 跳转到直播
    NSRange liveInfo = [requestPath rangeOfString:@"yuertvopen://live"];
    if (liveInfo.length > 0) {
        NSDictionary *dic = [WYCommonUtils getParamDictFrom:[[request URL] query]];
        WYLog(@"网页跳转到直播dic______  %@",dic);
        NSString *liveId;
        if ([dic isKindOfClass:[NSDictionary class]] && dic[@"objId"]) {
            liveId = dic[@"objId"];
        } else {
            return NO;
        }
        
//        WYLiveRoomViewController *liveroomVC = [[WYLiveRoomViewController alloc] init];
//        liveroomVC.liveId = liveId;
//        
//        [[self navigationController] pushViewController:liveroomVC animated:YES];
    }
    // 跳转到视频
    NSRange videoInfo = [requestPath rangeOfString:@"yuertvopen://live-video"];
 
    if (videoInfo.length > 0) {
//        NSDictionary *dic = [WYCommonUtils getParamDictFrom:[[request URL] query]];
//        WYLog(@"网页跳转到视频dic  %@",dic);
//        NSString *videoId;
//        if ([dic isKindOfClass:[NSDictionary class]] && dic[@"objId"]) {
//            videoId = dic[@"objId"];
//        } else {
//            return NO;
//        }
//        
//        WYVideoDetailViewController *videoVC = [[WYVideoDetailViewController alloc] init];
//        videoVC.videoId = videoId;
//        
//        [[self navigationController] pushViewController:videoVC animated:YES];
    }
    // 跳转到登录页
    NSRange loginInfo = [requestPath rangeOfString:@"yuertvopen://login"];
    if (loginInfo.length > 0) {
        WEAKSELF
//        [[WYLoginManager sharedManager] showLoginViewControllerFromPresentViewController:self showCancelButton:YES success:^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUINotificationKey object:nil];
//            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
//            
//        } failure:^(NSString *errorMessage) {
//            
//        } cancel:^{
//
//        }];
    }
    // 跳转到充值页
    NSRange rechargeInfo = [requestPath rangeOfString:@"yuertvopen://recharge"];
    if (rechargeInfo.length > 0) {
//        YTPayMoldViewController *payMoldVc = [[YTPayMoldViewController alloc] init];
//        payMoldVc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:payMoldVc animated:YES];
    }
    
    // 跳转到上一页
    NSRange closeInfo = [requestPath rangeOfString:@"yuertvopen://close"];
    if (closeInfo.length > 0) {
        [[self navigationController] popViewControllerAnimated:YES];
    }
    // 接收注册的手机号，密码
    NSRange registerInfo = [requestPath rangeOfString:@"yuertvopen://register"];
    if (registerInfo.length > 0) {
        NSDictionary *dic = [WYCommonUtils getParamDictFrom:[[request URL] query]];
//        WYLog(@"网页注册dic  %@",dic);
        NSString *mobile;
        NSString *psw;
        if ([dic isKindOfClass:[NSDictionary class]] && dic[@"mobile"]) {
            mobile = dic[@"mobile"];
        } else {
            return NO;
        }
        if ([dic isKindOfClass:[NSDictionary class]] && dic[@"password"]) {
            psw = dic[@"password"];
        } else {
            return NO;
        }
        //调用登录接口
        [WYLoginUserManager setAccount:mobile];
        [WYLoginUserManager setPassword:psw];

        self.shouldReLogin = YES;
    }
 */

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    WYLog(@"webViewDidStartLoad");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    WYLog(@"webViewDidFinishLoad");
    
    WYLog(@"webView UserAgent = %@", [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]);
 
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    WYLog(@"didFailLoadWithError  %@",error);
}

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [self.webProgressView setProgress:progress animated:YES];
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (self.title) {
        if (self.canShare) {
            [self createRightBarButton];
        }
    }
}

@end
