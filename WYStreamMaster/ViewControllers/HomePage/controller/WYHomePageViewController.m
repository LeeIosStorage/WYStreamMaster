//
//  WYHomePageViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/27.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYHomePageViewController.h"
#import "WYLiveSetViewController.h"
#import "WYHelpViewController.h"
#import "WYMessageViewController.h"
#import "WYIncomeRecordViewController.h"
#import "WYSpaceViewController.h"
#import "WYLiveViewController.h"
#import "WYLoginUserManager.h"
@interface WYHomePageViewController ()
@property (copy, nonatomic) NSString *roomNameTitle;
@property (copy, nonatomic) NSString *roomNoticeTitle;
@property (copy, nonatomic) NSString *gameCategory;
@property (copy, nonatomic) NSString *gameCategoryId;
@property (copy, nonatomic) NSString *roomType;

@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *profitRecordButton;
@property (strong, nonatomic) IBOutlet UIButton *helpCenterButton;
@property (strong, nonatomic) IBOutlet UIButton *liveSetButton;
@property (strong, nonatomic) IBOutlet UIButton *mySpaceButton;

@end

@implementation WYHomePageViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //判断是否开启麦克风权限
    if (![WYCommonUtils checkMicrophonePermissionStatus]) {
        [WYCommonUtils requsetMicrophonePermission];
    }
    if (![WYCommonUtils userCaptureIsAuthorization]) {
        [WYCommonUtils requsetCameraMediaPermission];
    }

    // Do any additional setup after loading the view from its nib.
}
#pragma mark - event
- (IBAction)clickMessageButton:(UIButton *)sender {
    WYMessageViewController *messageVC = [[WYMessageViewController alloc] init];
    [self.navigationController pushViewController:messageVC animated:YES];
}

- (IBAction)clickStartLiveButton:(UIButton *)sender {
    [self toCreateLiveRoom];

}
- (IBAction)clickLiveSetButton:(UIButton *)sender {
    WYLiveSetViewController *liveSetVC = [[WYLiveSetViewController alloc] init];
    [self.navigationController pushViewController:liveSetVC animated:YES];
}
- (IBAction)clickProfitRecordButton:(id)sender {
    WYIncomeRecordViewController *incomeRecordVC = [[WYIncomeRecordViewController alloc] init];
    [self.navigationController pushViewController:incomeRecordVC animated:YES];
}
- (IBAction)clickHelpCenterButton:(id)sender {
    WYHelpViewController *helpCenterVC = [[WYHelpViewController alloc] init];
    [self.navigationController pushViewController:helpCenterVC animated:YES];
}
- (IBAction)clickSpaceButton:(UIButton *)sender {
    WYSpaceViewController *spaceVC = [[WYSpaceViewController alloc] init];
    [self.navigationController pushViewController:spaceVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - network
- (void)anchorOnLineRequest{
    
    [MBProgressHUD showMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_live_prepare_ing"]];
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"anchor_on_off"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"anchor_user_code"];
    [paramsDic setObject:@"1" forKey:@"anchor_status"];
    if ([WYLoginUserManager roomId].length > 0) {
        [paramsDic setObject:[WYLoginUserManager roomId] forKey:@"room_id_pk"];
    }
    [paramsDic setObject:self.roomType forKey:@"room_type"];
    [paramsDic setObject:self.roomNameTitle forKey:@"anchor_title"];
    if (self.roomNoticeTitle.length > 0) {
        [paramsDic setObject:self.roomNoticeTitle forKey:@"anchor_description"];//房间公告
    }
//    if ([self.roomType integerValue] == 1) {
//        [paramsDic setObject:self.vipRoomPasswordTextField.text forKey:@"password"];
//    }
    
    //测试
    //    [paramsDic setObject:[NSNumber numberWithInt:LiveGameTypeTexasPoker] forKey:@"game_type"];
    
    
    WEAKSELF
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUD];
        
        if (requestType == WYRequestTypeSuccess) {
            
            NSInteger gameType = 0;
            if ([dataObject isKindOfClass:[NSDictionary class]]) {
                gameType = [[dataObject objectForKey:@"game_type"] integerValue];
            }
            [WYLoginUserManager setLiveGameType:gameType];
            
            WYLiveViewController *liveVc = [[WYLiveViewController alloc] init];
            liveVc.isShowFaceUnity = YES;
            liveVc.streamURL = [WYLoginUserManager anchorPushUrl];
            [self.navigationController pushViewController:liveVc animated:YES];
            
        }else{
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showAlertMessage:[WYCommonUtils showServerErrorLocalizedText] toView:weakSelf.view];
    }];
}

#pragma mark -
#pragma mark - Private Methods
- (void)toCreateLiveRoom{
    
    self.roomNameTitle = [WYLoginUserManager roomNameTitle];
    self.roomNoticeTitle = [WYLoginUserManager roomNoticeTitle];
    self.roomType = @"0";

    if ([self.roomNameTitle length] == 0) {
        //        [MBProgressHUD showError:[WYCommonUtils acquireCurrentLocalizedText:@"给自己取一个闪亮的房间名字吧！"]];
        //        return;
    }
    //    if ([self.gameCategory length] == 0 || [self.gameCategoryId length] == 0) {
    //        [MBProgressHUD showError:[WYCommonUtils acquireCurrentLocalizedText:@"选择直播的游戏"]];
    //        return;
    //    }
//    if ([self.roomType intValue] == 1 && self.vipRoomPasswordTextField.text.length == 0) {
//        [MBProgressHUD showError:@"请为VIP房间设置密码"];
//        return;
//    }
    
    if (![WYCommonUtils checkMicrophonePermissionStatus] || ![WYCommonUtils userCaptureIsAuthorization]) {
        // 麦克风未授权
        WEAKSELF
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法访问麦克风或相机" message:@"请前往系统设置->隐私->麦克风/相机 打开权限" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:[WYCommonUtils acquireCurrentLocalizedText:@"wy_affirm"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        [alertController addAction:confirmAction];
        
        [weakSelf presentViewController:alertController animated:YES completion:nil
         ];
        return;
    }
    
    [WYLoginUserManager setRoomNameTitle:self.roomNameTitle];
    [WYLoginUserManager setRoomNoticeTitle:self.roomNoticeTitle];
    [WYLoginUserManager setGameCategory:self.gameCategory];
    [WYLoginUserManager setGameCategoryId:self.gameCategoryId];
    
    [self startLive];
}

- (void)startLive{
    
    [self anchorOnLineRequest];
    
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
