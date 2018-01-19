//
//  WYHomePageViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/27.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYHomePageViewController.h"
#import "WYLiveSetViewController.h"
#import "WYAnchorApplyViewController.h"
#import "WYHelpViewController.h"
#import "WYMessageViewController.h"
#import "WYIncomeRecordViewController.h"
#import "WYSpaceViewController.h"
#import "WYLiveViewController.h"
#import "WYLoginUserManager.h"
#import "WYLoginManager.h"
#import "WYLiveViewController1.h"
#import "HHCountdowLabel.h"
@interface WYHomePageViewController ()
@property (copy, nonatomic) NSString *roomNameTitle;
@property (copy, nonatomic) NSString *roomNoticeTitle;
@property (copy, nonatomic) NSString *gameCategory;
@property (copy, nonatomic) NSString *gameCategoryId;
@property (copy, nonatomic) NSString *roomType;
@property (strong, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;
@property (strong, nonatomic) IBOutlet UILabel *startLabel;

@property (strong, nonatomic) IBOutlet HHCountdowLabel *startLiveLabel;
@property (strong, nonatomic) IBOutlet UIButton *startLiveButton;
// 我的消息
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
// 收益记录按钮
@property (strong, nonatomic) IBOutlet UIButton *profitRecordButton;
// 帮助中心
@property (strong, nonatomic) IBOutlet UIButton *helpCenterButton;
// 直播设置
@property (strong, nonatomic) IBOutlet UIButton *liveSetButton;
// 我的空间
@property (strong, nonatomic) IBOutlet UIButton *mySpaceButton;

@property (strong, nonatomic) IBOutlet UILabel *remarksLabel;
@end

@implementation WYHomePageViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupView];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    //判断是否开启麦克风权限
    if (![WYCommonUtils checkMicrophonePermissionStatus]) {
        [WYCommonUtils requsetMicrophonePermission];
    }
    if (![WYCommonUtils userCaptureIsAuthorization]) {
        [WYCommonUtils requsetCameraMediaPermission];
    }

    // Do any additional setup after loading the view from its nib.
}


#pragma mark - setupView
- (void)setupView
{
    NSString *auditStatu = [NSString stringWithFormat:@"%@", [WYLoginManager sharedManager].loginModel.audit_statu];
    if ([auditStatu isEqualToString:@"0"]) {
        self.startLiveLabel.text = @"提交\n申请";
        self.remarksLabel.text = @"您未提交主播申请!";
    } else if ([auditStatu isEqualToString:@"1"]) {
        self.startLiveButton.backgroundColor = [UIColor grayColor];
        self.startLabel.backgroundColor = [UIColor grayColor];
        self.startLabel.alpha = 0.3;
        self.startLiveButton.alpha = 0.1;
        self.startLiveLabel.alpha = 0.5;
        self.startLiveLabel.backgroundColor = [UIColor grayColor];
        self.startLiveLabel.text = @"等待\n审核";
        self.remarksLabel.text = @"您的申请还未通过请留意邮箱或新消息提醒";
    } else if ([auditStatu isEqualToString:@"3"]) {
        self.startLiveLabel.text = @"重新\n审核";
        self.remarksLabel.text = @"十分抱歉!您的申请没有通过。请完善信息后重新申请!";
    } else if ([auditStatu isEqualToString:@"2"]) {
        self.startLiveLabel.text = @"开启\n直播";
        self.remarksLabel.text = @"粉丝们都等不及了赶快开启直播吧";
        
//        HHCountdowLabel *countLabel = [[HHCountdowLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
//        countLabel.center = self.view.center;
//        countLabel.font = [UIFont boldSystemFontOfSize:18];
//        countLabel.textColor = [UIColor blueColor];
//        countLabel.count = 5; //不设置的话，默认是3
//        [self.view addSubview:countLabel];
        
        [self.startLiveLabel startCount];
    } else {
        self.startLiveLabel.text = @"提交\n申请";
        self.remarksLabel.text = @"您未提交主播申请!";
    }
    NSURL *avatarUrl = [NSURL URLWithString:[WYLoginUserManager avatar]];
    [WYCommonUtils setImageWithURL:avatarUrl setImageView:self.headerImageView placeholderImage:@"common_headImage"];
    self.nicknameLabel.text = [WYLoginUserManager nickname];
    self.mySpaceButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    self.mySpaceButton.imageEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 0);
}
#pragma mark - event
- (IBAction)clickMessageButton:(UIButton *)sender {
    WYMessageViewController *messageVC = [[WYMessageViewController alloc] init];
    [self.navigationController pushViewController:messageVC animated:YES];
}

- (IBAction)clickStartLiveButton:(UIButton *)sender {
    NSString *auditStatu = [WYLoginManager sharedManager].loginModel.audit_statu;
    if ([auditStatu isEqualToString:@"2"]) {
        [self toCreateLiveRoom];
        
    } else if ([auditStatu isEqualToString:@"0"]) {
//        [self toCreateLiveRoom];

        WYAnchorApplyViewController *anchorApplyVC = [[WYAnchorApplyViewController alloc] init];
        [self.navigationController pushViewController:anchorApplyVC animated:YES];
    } else if ([auditStatu isEqualToString:@"1"]) {
//        [self toCreateLiveRoom];
//        WYAnchorApplyViewController *anchorApplyVC = [[WYAnchorApplyViewController alloc] init];
//        [self.navigationController pushViewController:anchorApplyVC animated:YES];
    } else {
//        [self toCreateLiveRoom];
        WYAnchorApplyViewController *anchorApplyVC = [[WYAnchorApplyViewController alloc] init];
        [self.navigationController pushViewController:anchorApplyVC animated:YES];
    }
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
    NSString *auditStatu = [NSString stringWithFormat:@"%@", [WYLoginManager sharedManager].loginModel.audit_statu];
    if ([auditStatu isEqualToString:@"2"]) {
        WYSpaceViewController *spaceVC = [[WYSpaceViewController alloc] init];
        [self.navigationController pushViewController:spaceVC animated:YES];
    } else {
//        WYSpaceViewController *spaceVC = [[WYSpaceViewController alloc] init];
//        [self.navigationController pushViewController:spaceVC animated:YES];
    }
    
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
            
            WYLiveViewController1 *liveVc = [[WYLiveViewController1 alloc] init];
//            liveVc.isShowFaceUnity = YES;
            liveVc.streamURL = [WYLoginUserManager anchorPushUrl];
            [self.navigationController pushViewController:liveVc animated:YES];
            
        }else{
            [MBProgressHUD showError:message toView:weakSelf.view];
            WYLiveViewController1 *liveVc = [[WYLiveViewController1 alloc] init];
            //            liveVc.isShowFaceUnity = YES;
            liveVc.streamURL = [WYLoginUserManager anchorPushUrl];
            [self.navigationController pushViewController:liveVc animated:YES];
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

- (void)startLive
{
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
