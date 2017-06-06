//
//  WYLiveViewController.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/10.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYLiveViewController.h"
#import "WYStreamingSessionManager.h"
#import <BlocksKit/BlocksKit+UIKit.h>
#import "WYAnchorInfoView.h"
#import "WYContributionListView.h"
#import "WYAnchorManageView.h"
#import "WYGiftModel.h"
#import "WYBetTopView.h"
#import "WYGiftHistoryView.h"
#import "WYLoginManager.h"
#import "WYLiveGameResultView.h"
#import "WYServerNoticeAttachment.h"
#import "WYFaceRendererManager.h"

// 直播通知重试次数
static NSInteger kLiveNotifyRetryCount = 0;
static NSInteger kLiveNotifyRetryMaxCount = 3;

@interface WYLiveViewController ()
<
WYStreamingSessionManagerDelegate,
WYAnchorInfoViewDelegate
>
{
    
}

@property (nonatomic, strong) WYStreamingSessionManager *streamingSessionManager;

@property (nonatomic, strong) PLMediaStreamingSession *plSession;

@property (nonatomic, strong) UIImageView *liveBgImageView;

@property (nonatomic, weak) IBOutlet UIView *contentContainerView;
@property (nonatomic, weak) IBOutlet UIButton *expandChatButton;
@property (nonatomic, weak) IBOutlet UIButton *betTopButton;
@property (nonatomic, weak) IBOutlet UIButton *giftHistoryButton;
@property (nonatomic, weak) IBOutlet UILabel *betTopTipLabel;
@property (nonatomic, weak) IBOutlet UILabel *giftHistoryTipLabel;


@property (nonatomic, strong) WYAnchorInfoView *anchorInfoView;

@property (nonatomic, strong) WYAnchorManageView *anchorManageView;//主播管理View

@property (strong, nonatomic) WYContributionListView *contributionListView;//贡献榜

@property (strong, nonatomic) WYBetTopView *betTopView;//押注排行

@property (strong, nonatomic) WYGiftHistoryView *giftHistoryView;//礼物历史

@property (strong, nonatomic) WYLiveGameResultView *liveGameResultView;//游戏结果

@end

@implementation WYLiveViewController

- (void)dealloc{
    WYLog(@"%@ dealloc !!!",NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[WYFaceRendererManager sharedInstance] stopTimer];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverNoticeCustomAttachment:) name:WYServerNoticeAttachment_Notification object:nil];
    
    [self setupSubView];
    
    [self prepareForCameraSetting];
    
    //开始检测人脸礼物动效
    [[WYFaceRendererManager sharedInstance] stopTimer];
    [[WYFaceRendererManager sharedInstance] startTimer];
    
    YTGiftAttachment *giftModel = [[YTGiftAttachment alloc] init];
    giftModel.giftID = [NSString stringWithFormat:@"%d",2];
    giftModel.senderID = @"10010";
    [[WYFaceRendererManager sharedInstance] addGiftModel:giftModel];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Server
- (void)notifiyLive{
    
    WYLog(@"notifiyLive Count = %d",(int)kLiveNotifyRetryCount);
    WEAKSELF
    [weakSelf retryNotifyLive];
}

// 直播通知失败后重连处理 共三次，间隔时间分别是 2s 4s 6s
- (void)retryNotifyLive
{
    kLiveNotifyRetryCount ++;
    if (kLiveNotifyRetryCount > kLiveNotifyRetryMaxCount) {
        return;
    }
    WEAKSELF
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kLiveNotifyRetryCount*2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf notifiyLive];
    });
}

- (void)closeLive{
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"anchor_on_off"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"anchor_user_code"];
    [paramsDic setObject:@"0" forKey:@"anchor_status"];
    [paramsDic setObject:[WYLoginUserManager gameCategoryId] forKey:@"game_type"];
    [paramsDic setObject:[WYLoginUserManager roomId] forKey:@"room_id_pk"];
    [paramsDic setObject:[NSNumber numberWithInt:0] forKey:@"room_type"];
    
    WEAKSELF
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        
        if (requestType == WYRequestTypeSuccess) {
            
        }else{
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_server_request_errer_tip"] toView:weakSelf.view];
    }];
}


- (void)serverNoticeCustomAttachment:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[WYServerNoticeAttachment class]]) {
        WYServerNoticeAttachment *serverNoticeAttachment = notification.object;
        
        if (serverNoticeAttachment.customMessageType == CustomMessageTypeBetRank) {
            [self.anchorInfoView updateAnchorInfoWith:serverNoticeAttachment];
            
            [self.betTopView show:self.contentContainerView];
            [self.betTopView updateBetTopData:serverNoticeAttachment.contentData];
        }else if (serverNoticeAttachment.customMessageType == CustomMessageTypeGameResult){
            [self.liveGameResultView updateWithGameResultInfo:serverNoticeAttachment];
            [self refreshGameResultStatusTip:serverNoticeAttachment];
        }
        
        //是否要结束推流
        if (serverNoticeAttachment.anchorStatus == 2) {
            
            [MBProgressHUD showError:[WYCommonUtils acquireCurrentLocalizedText:@"wy_banned_live_tip"] toView:nil];
            [self serverNoticeFinishStream];
        }
//        if (serverNoticeAttachment.isForClient == 1) {
//            [MBProgressHUD showError:[WYCommonUtils acquireCurrentLocalizedText:@"wy_closed_live_tip"] toView:nil];
//            [self serverNoticeFinishStream];
//        }
    }
}

#pragma mark -
#pragma mark - Private Methods
- (void)setupSubView{
    
    self.betTopTipLabel.text = [WYCommonUtils acquireCurrentLocalizedText:@"押注排名"];
    self.giftHistoryTipLabel.text = [WYCommonUtils acquireCurrentLocalizedText:@"礼物历史"];
    
    self.betTopButton.layer.cornerRadius = 20;
    self.betTopButton.layer.masksToBounds = YES;
    [self.betTopButton.layer setBorderWidth:0.5];
    [self.betTopButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    self.giftHistoryButton.layer.cornerRadius = 20;
    self.giftHistoryButton.layer.masksToBounds = YES;
    [self.giftHistoryButton.layer setBorderWidth:0.5];
    [self.giftHistoryButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    [self.view addSubview:self.liveBgImageView];
    [self.view insertSubview:self.liveBgImageView atIndex:0];
    [self.liveBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    //直播信息
    [self.contentContainerView addSubview:self.anchorInfoView];
    [self.anchorInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentContainerView).offset(10);
        make.top.equalTo(self.contentContainerView).offset(22);
        make.width.mas_equalTo(125);
        make.height.mas_equalTo(40);
    }];
    
    [self.anchorInfoView updateAnchorInfoWith:nil];
    
    [self initRoomView];
    
    [self.view addSubview:self.liveGameResultView];
    [self.liveGameResultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.contentContainerView.mas_bottom);
    }];
    [self.liveGameResultView updateWithGameResultInfo:nil];
}

- (void)initRoomView
{
    self.expandChatButton.selected = NO;
    
    CGFloat height = (250/667.0)*SCREEN_HEIGHT;
    [self.contentContainerView addSubview:self.roomView];
    [self.roomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentContainerView).offset(-55);
        make.left.equalTo(self.contentContainerView).offset(8);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-kRoomChatViewCustomWidth, height));
    }];
    [self.roomView roomViewPrepare];
}

- (void)prepareForCameraSetting
{
    NSURL *streamURL = [NSURL URLWithString:self.streamURL];
    self.streamingSessionManager = [[WYStreamingSessionManager alloc] initWithStreamURL:streamURL];
    _streamingSessionManager.delegate = self;
    self.plSession = [self.streamingSessionManager streamingSession];
    
    //检测网络状态
    [self connectionChangeStreamingAction];
    
    UIView *previewView = self.plSession.previewView;
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.view insertSubview:previewView atIndex:0];
        [self.view insertSubview:previewView aboveSubview:self.liveBgImageView];
        [previewView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(self.view);
//            make.top.equalTo(self.view).offset(40);
//            make.right.equalTo(self.view).offset(-10);
//            make.size.mas_equalTo(CGSizeMake(100, 200));
        }];
    });
    // 设置屏幕长亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self.streamingSessionManager startStream];
    
}

- (void)connectionChangeStreamingAction{
    
//    WEAKSELF
//    self.plSession.monitorNetworkStateEnable = YES;
//    self.plSession.connectionChangeActionCallback = ^(PLNetworkStateTransition transition){
//        if (transition == PLNetworkStateTransitionUnconnectedToWiFi || transition == PLNetworkStateTransitionUnconnectedToWWAN) {
//            [weakSelf.streamingSessionManager stopStream];
//            [weakSelf.streamingSessionManager startStream];
//            
//        }else if (transition == PLNetworkStateTransitionWiFiToUnconnected || transition == PLNetworkStateTransitionWWANToUnconnected){
//            
//        }
//        return YES;
//    };
    
}

- (void)animationChangeChatViewFrame{
    
    CGFloat chatViewHeight = 150;
    if (self.expandChatButton.selected) {
        chatViewHeight = 300;
    }
    
    WEAKSELF
//    [weakSelf.roomView.superview layoutIfNeeded];
    [UIView animateWithDuration:0.35 animations:^{
        [weakSelf.roomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentContainerView).offset(-70);
            make.height.mas_equalTo(chatViewHeight);
        }];
        [weakSelf.roomView.superview layoutIfNeeded];
    }];
}

- (void)refreshGameResultStatusTip:(id)gameResultInfo{
    WYServerNoticeAttachment *serverNoticeAttachment = gameResultInfo;
    NSInteger gameStatus = serverNoticeAttachment.gameStatus;
    
    NSString *gameStatusTipText = nil;
    if (gameStatus == 1) {
        gameStatusTipText = [WYCommonUtils acquireCurrentLocalizedText:@"等待玩家下注"];
        for (int i = 2; i < 6; i ++) {
            YTGiftAttachment *giftModel = [[YTGiftAttachment alloc] init];
            giftModel.giftID = [NSString stringWithFormat:@"%d",i];
            giftModel.senderID = @"10010";
            [[WYFaceRendererManager sharedInstance] addGiftModel:giftModel];
        }
    }else if (gameStatus == 2){
        gameStatusTipText = [WYCommonUtils acquireCurrentLocalizedText:@"正在发牌 等待游戏结果"];
    }
    
    if (gameStatusTipText.length > 0) {
        [MBProgressHUD showBottomMessage:gameStatusTipText toView:self.liveGameResultView];
    }
}

- (void)serverNoticeFinishStream{
    
    [self.streamingSessionManager destroyStream];
    [self.roomView.chatroomControl exitRoom];
    //通知服务器停止直播了
    [self closeLive];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - Button Clicked
- (IBAction)doBackAction:(id)sender{
    
    WEAKSELF
    UIAlertView *alertView = [UIAlertView bk_showAlertViewWithTitle:[WYCommonUtils acquireCurrentLocalizedText:@"确定要停止直播吗？"] message:nil cancelButtonTitle:[WYCommonUtils acquireCurrentLocalizedText:@"再想想"] otherButtonTitles:@[[WYCommonUtils acquireCurrentLocalizedText:@"wy_affirm"]] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            
            [weakSelf.streamingSessionManager destroyStream];
            [weakSelf.roomView.chatroomControl exitRoom];
            //通知服务器停止直播了
            [weakSelf closeLive];
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    [alertView show];
    
}

//static int tempCount = 0;
- (IBAction)changeCameraAction:(id)sender{
    
//    tempCount++;
//    
//    WYGiftModel *gifModel = [[WYGiftModel alloc] init];
//    
//    gifModel.giftId = @"1";
//    gifModel.name = @"礼物礼物礼物礼物1";
//    gifModel.noFrameIcon = kTempNetworkHTTPURL;
//    int type = tempCount%5;
//    if (type == 1) {
//        gifModel.giftId = @"2";
//        gifModel.name = @"礼物礼物礼物礼物礼物2";
//        gifModel.noFrameIcon = @"";
////        [self.roomView sendMessageWithText:@"你的谢腾飞，尬舞尬起来啊，我牛牛就问你怕不怕，我屮艸芔茻赢了1000万"];
////        return;
//    }else if (type == 2){
//        gifModel.giftId = @"3";
//        gifModel.name = @"礼物礼物礼物礼物礼物3";
//        gifModel.noFrameIcon = @"http://103.230.243.174:8888/uploadfile/847336c0-a5c1-48d4-8a12-3a3c9dc49d43.gif";
//    }else if (type == 3){
//        gifModel.giftId = @"4";
//        gifModel.name = @"大茄子";
//        gifModel.noFrameIcon = @"";
//    }else if (type == 4){
//        gifModel.giftId = @"5";
//        gifModel.name = @"5米黄瓜";
//        gifModel.noFrameIcon = @"";
//    }
//    
//    gifModel.sender = [WYLoginUserManager nickname];
//    gifModel.clickNumber = 1;
//    [self.roomView.chatroomControl sendMessageWithGift:gifModel];
//
//    return;
    
    
    [self.plSession toggleCamera];
    
    
//    [_plSession getScreenshotWithCompletionHandler:^(UIImage * _Nullable image) {
//        UIImage *screenshotImage = image;
//    }];
}

//押注排行榜
- (IBAction)betTopAction:(id)sender{
    [self.betTopView show:self.contentContainerView];
//    [self.betTopView updateBetTopData:nil];
}

- (IBAction)giftHistoryAction:(id)sender{
    [self.giftHistoryView show];
}

- (IBAction)contributionAction:(id)sender{
    [self.contributionListView show];
}

- (IBAction)changeChatViewFrameAction:(id)sender{
    
    self.expandChatButton.selected = !self.expandChatButton.selected;
    [self animationChangeChatViewFrame];
}

#pragma mark -
#pragma mark - Getters and Setters
- (WYAnchorInfoView *)anchorInfoView{
    if (!_anchorInfoView) {
        _anchorInfoView = [[WYAnchorInfoView alloc] init];
        _anchorInfoView.delegate = self;
    }
    return _anchorInfoView;
}

- (WYAnchorManageView *)anchorManageView{
    if (!_anchorManageView) {
        _anchorManageView = (WYAnchorManageView *)[[NSBundle mainBundle] loadNibNamed:@"WYAnchorManageView" owner:self options:nil].firstObject;
    }
    return _anchorManageView;
}

- (YTRoomView *)roomView{
    if (!_roomView) {
        _roomView = [[YTRoomView alloc] init];
    }
    return _roomView;
}

- (WYContributionListView *)contributionListView{
    if (!_contributionListView) {
        _contributionListView = [[WYContributionListView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _contributionListView;
}

- (WYBetTopView *)betTopView{
    if (!_betTopView) {
        _betTopView = [[WYBetTopView alloc] init];
    }
    return _betTopView;
}

- (WYGiftHistoryView *)giftHistoryView{
    if (!_giftHistoryView) {
        _giftHistoryView = [[WYGiftHistoryView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _giftHistoryView;
}

- (UIImageView *)liveBgImageView{
    if (!_liveBgImageView) {
        _liveBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wy_live_bg"]];
        _liveBgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _liveBgImageView.clipsToBounds = YES;
    }
    return _liveBgImageView;
}

- (WYLiveGameResultView *)liveGameResultView{
    if (!_liveGameResultView) {
        _liveGameResultView = (WYLiveGameResultView *)[[NSBundle mainBundle] loadNibNamed:@"WYLiveGameResultView" owner:self options:nil].firstObject;
    }
    return _liveGameResultView;
}

#pragma mark -
#pragma mark - WYAnchorInfoViewDelegate
- (void)anchorInfoViewAvatarClicked{
    //主播信息
    [self.anchorManageView show];
}

#pragma mark
#pragma mark - WYStreamingSessionManagerDelegate

- (void)streamingManager:(WYStreamingSessionManager *)manager pushStreamStatusChanged:(PLStreamState)state
{
    if (PLStreamStateConnected == state) {
        // 推流成功后，通知服务器  延迟2s，避免七牛端有延迟，提示主播不在线
        WEAKSELF
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf notifiyLive];
        });
    }
}

@end
