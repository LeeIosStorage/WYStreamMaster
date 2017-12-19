//
//  ZYZCPlayViewController.m
//  ios_zhongyouzhongchou
//
//  Created by mac on 16/5/2.
//  Copyright © 2016年 liuliang. All rights reserved.
//

#import "ZYZCPlayViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ZYZCPlayViewController ()<UIAlertViewDelegate >

@end

@implementation ZYZCPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    监听网络状态
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkChange:) name:@"NetworkChange"  object:nil];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
////    self.navigationController.navigationBar.hidden = YES;
//    self.tabBarController.tabBar.hidden = YES;
//    
//    NSLog(@"%@",NSStringFromCGRect(self.videoBounds));
//}
//
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    
////    self.navigationController.navigationBar.hidden = NO;
//    self.tabBarController.tabBar.hidden = NO;
//}

- (void)setUrlString:(NSString *)urlString
{
    if (_urlString != urlString) {
        _urlString  = urlString;
        
//        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//url只支持英文和少数其它字符，因此对url中非标准字符需要进行编码，这个编码方*****能不完善，因此使用下面的方法编码。
//        NSString *newUrlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *netUrl = [NSURL URLWithString:urlString];
        AVPlayer *player = [AVPlayer playerWithURL:netUrl];
        self.player = player;
        [player play];
    }
    
}

#pragma mark --- 网络状态发生改变
-(void)networkChange:(NSNotification *)notify
{
    NSNumber *number=notify.object;
    //无wifi状态
    if (![number isEqual:@2]) {
        //停止播放
        if(self.player)
        {
            [self.player pause];
        }
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"【流量使用提示】" message:@"当前网络无Wi-Fi,继续播放可能会被运营商收取流量费用" delegate:self cancelButtonTitle:@"停止播放" otherButtonTitles:@"继续播放", nil];
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        
        self.player=nil;
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else if (buttonIndex==1) {
        if(self.player)
        {
            [self.player play];
        }
    }
}

-(void)dealloc
{
//    NSLog(@"dealloc:%@",self.class);
    //移除所有通知监控
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
