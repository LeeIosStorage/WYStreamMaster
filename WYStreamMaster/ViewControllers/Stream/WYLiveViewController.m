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
#import "WYGiftRecordView.h"
#import "ZegoAVManager.h"
#import <FUAPIDemoBar/FUAPIDemoBar.h>
#import "FUManager.h"
#import "AFNetworkReachabilityManager.h"
#import "WYSocketManager.h"
// 直播通知重试次数
static NSInteger kLiveNotifyRetryCount = 0;
static NSInteger kLiveNotifyRetryMaxCount = 3;

@interface WYLiveViewController ()
<
WYStreamingSessionManagerDelegate,
WYAnchorInfoViewDelegate,
ZegoLivePublisherDelegate,
FUAPIDemoBarDelegate,
ZegoRoomDelegate
>
{
    
}

@property (nonatomic, strong) WYStreamingSessionManager *streamingSessionManager;

@property (nonatomic, strong) PLMediaStreamingSession *plSession;

@property (nonatomic, strong) UIImageView *liveBgImageView;

@property (nonatomic, strong) UIView *liveContainerView;
@property (nonatomic, strong) UIView *preView;
@property (nonatomic, strong) UIImageView *videoView;
@property (nonatomic, strong) NSTimer *previewTimer;

@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIView *contentContainerView;
@property (nonatomic, weak) IBOutlet UIButton *expandChatButton;
@property (nonatomic, weak) IBOutlet UIButton *betTopButton;
@property (nonatomic, weak) IBOutlet UIButton *giftHistoryButton;
@property (nonatomic, weak) IBOutlet UILabel *betTopTipLabel;
@property (nonatomic, weak) IBOutlet UILabel *giftHistoryTipLabel;


@property (nonatomic, strong) WYAnchorInfoView *anchorInfoView;

@property (nonatomic, strong) WYAnchorManageView *anchorManageView;//主播管理View

@property (strong, nonatomic) WYContributionListView *contributionListView;//贡献榜
@property (nonatomic, strong) WYGiftRecordView *giftRecordView;

@property (strong, nonatomic) WYBetTopView *betTopView;//押注排行

@property (strong, nonatomic) WYGiftHistoryView *giftHistoryView;//礼物历史

@property (strong, nonatomic) WYLiveGameResultView *liveGameResultView;//游戏结果

@property (nonatomic, strong) UIButton *demoBtn ;
@property (nonatomic, strong) FUAPIDemoBar *demoBar ;
@property (nonatomic, assign) NSInteger qualityNoGood;

@property (nonatomic ,strong) NSTimer *pauseTimers;

@end

@implementation WYLiveViewController

- (void)dealloc{
    WYLog(@"%@ dealloc !!!",NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[WYFaceRendererManager sharedInstance] stopTimer];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    if (self.isShowFaceUnity) {
//        [self.view addSubview:self.demoBtn];
//        [self.view addSubview:self.demoBar];
//        
//        [[FUManager shareManager] setUpFaceunity];
//        [FUManager shareManager].isShown = YES ;
//        
//    }
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReachabilityDidChangeNotification:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverNoticeFinishStream) name:WYNotificationWSConnect object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWSDisConnect) name:WYNotificationWSDisConnect object:nil];

    
    [self setupSubView];
    
    [self prepareForCameraSetting];
    [self crateWebSocket];
    [[ZegoHelper api] setRoomDelegate:self];
    //开始检测人脸礼物动效
//    [[WYFaceRendererManager sharedInstance] stopTimer];
//    [[WYFaceRendererManager sharedInstance] startTimer];
//    
//    
//    for (int i = 39; i < 47; i ++) {
//        YTGiftAttachment *giftModel = [[YTGiftAttachment alloc] init];
//        giftModel.giftID = [NSString stringWithFormat:@"%d",i];
//        giftModel.senderID = @"10010";
//        [[WYFaceRendererManager sharedInstance] addGiftModel:giftModel];
//    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Server
- (void)anchorDetail{
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"anchor_detail"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"anchor_user_code"];
    [paramsDic setObject:@"CNY" forKey:@"currency"];
    
    WEAKSELF
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        
        if (requestType == WYRequestTypeSuccess) {
            NSArray *dataArray = (NSArray *)dataObject;
            NSDictionary *dic = dataArray[0];
            NSString *anchorStatus = [NSString stringWithFormat:@"%@", dic[@"anchor_status"]];
            if ([anchorStatus isEqualToString:@"0"]) {
                [weakSelf roomDisConnect];
            }
        }else{
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_server_request_errer_tip"] toView:weakSelf.view];
    }];
}

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
    [self stopTimer];
    // 关闭长连接
    [[WYSocketManager sharedInstance] SRWebSocketClose];
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"anchor_on_off"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"anchor_user_code"];
    [paramsDic setObject:@"0" forKey:@"anchor_status"];
//    [paramsDic setObject:[WYLoginUserManager gameCategoryId] forKey:@"game_type"];
    if ([WYLoginUserManager roomId].length > 0) {
        [paramsDic setObject:[WYLoginUserManager roomId] forKey:@"room_id_pk"];
    }
//    [paramsDic setObject:[NSNumber numberWithInt:0] forKey:@"room_type"];
    
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
- (void)crateWebSocket
{
    NSString *webSocketString = [NSString stringWithFormat:@"ws://www.legend8888.com/chat_room/ws.do?userCode=%@&anchor_user_code=%@&game_type=%zd&device=1", [WYLoginUserManager userID], [WYLoginUserManager userID], [WYLoginUserManager liveGameType]];
    [[WYSocketManager sharedInstance] initSocketURL:[NSURL URLWithString:webSocketString]];
}

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
    
    [self.view addSubview:self.liveContainerView];
    [self.view insertSubview:self.liveContainerView aboveSubview:self.liveBgImageView];
    [self.liveContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    

    if ([WYLoginUserManager liveGameType] == LiveGameTypeSlots){
        self.liveGameResultView.hidden = YES;
        [self.contentContainerView removeFromSuperview];
        [self.view addSubview:self.contentContainerView];
        [self.contentContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-12);
        }];
        
        [self.view insertSubview:self.contentContainerView belowSubview:self.backButton];
    }
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
    // 设置屏幕长亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    kAUVoiceIOProperty_VoiceProcessingEnableAGC;
    
    //即构科技推流
    [self addPreview];
//    [self addExternalCaptureView];
    
    /*********************七牛推流
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
    
    [self.streamingSessionManager startStream];
    ********************/
}

- (void)addPreview
{
    self.preView = [[UIView alloc] init];
    [self.liveContainerView addSubview:self.preView];
    [self.liveContainerView sendSubviewToBack:self.preView];
    
    [self.preView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.liveContainerView);
    }];
    
    [[ZegoHelper api] setPublisherDelegate:self];
    [ZegoHelper setAnchorConfig:self.preView];
}

- (void)addExternalCaptureView
{
    if (self.videoView)
    {
        [self.videoView removeFromSuperview];
        self.videoView = nil;
    }
    
    if (self.previewTimer)
    {
        [self.previewTimer invalidate];
        self.previewTimer = nil;
    }
    
    _videoView = [[UIImageView alloc] init];
    self.videoView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.preView addSubview:self.videoView];
    self.videoView.frame = self.preView.bounds;
    
    //timer
    self.previewTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60 target:self selector:@selector(handlePreview) userInfo:nil repeats:YES];
}

- (void)removeExternalCaptureView
{
    [self.previewTimer invalidate];
    self.previewTimer = nil;
    
    if (self.videoView)
    {
        [self.videoView removeFromSuperview];
        self.videoView = nil;
        [self.preView setNeedsLayout];
    }
}

- (void)handlePreview
{
//    WYLog(@"handlePreview-------------------------------------");
    VideoCaptureFactoryDemo *demo = [ZegoHelper getVideoCaptureFactory];
    if (demo)
    {
        UIImage *image = [demo getCaptureDevice].videoImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.videoView.image = image;
        });
    }
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
    
    if (serverNoticeAttachment.anchorStatus == 0 || [WYLoginUserManager liveGameType] == LiveGameTypeSlots) {
        //不处理游戏状态
        return;
    }
    
    NSString *gameStatusTipText = nil;
    if (gameStatus == 1) {
        gameStatusTipText = [WYCommonUtils acquireCurrentLocalizedText:@"等待玩家下注"];
    }else if (gameStatus == 2){
        gameStatusTipText = [WYCommonUtils acquireCurrentLocalizedText:@"正在发牌 等待游戏结果"];
    }
    
    if (gameStatusTipText.length > 0) {
        [MBProgressHUD showBottomMessage:gameStatusTipText toView:self.liveGameResultView];
    }
}

- (void)serverNoticeFinishStream{
    
    [self stopPublishing];
    
    [self.streamingSessionManager destroyStream];
    [self.roomView.chatroomControl exitRoom];
    //通知服务器停止直播了
    [self closeLive];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)stopPublishing
{
    [[ZegoHelper api] stopPreview];
    [[ZegoHelper api] setPreviewView:nil];
    [[ZegoHelper api] stopPublishing];
    [[ZegoHelper api] logoutRoom];
    [self removeExternalCaptureView];
}

#pragma mark -
#pragma mark - Button Clicked
- (void)notificationWSDisConnect
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"直播错误，请重新开启", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
//    [self serverNoticeFinishStream];
    [self.streamingSessionManager destroyStream];
    [self.roomView.chatroomControl exitRoom];
    //通知服务器停止直播了
    [self closeLive];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)roomDisConnect
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"直播错误，请重新开启", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [self serverNoticeFinishStream];

}
- (IBAction)doBackAction:(id)sender{
    
    WEAKSELF
    UIAlertView *alertView = [UIAlertView bk_showAlertViewWithTitle:[WYCommonUtils acquireCurrentLocalizedText:@"确定要停止直播吗？"] message:nil cancelButtonTitle:[WYCommonUtils acquireCurrentLocalizedText:@"再想想"] otherButtonTitles:@[[WYCommonUtils acquireCurrentLocalizedText:@"wy_affirm"]] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            
            [weakSelf serverNoticeFinishStream];
            
//            [weakSelf.streamingSessionManager destroyStream];
//            [weakSelf.roomView.chatroomControl exitRoom];
//            //通知服务器停止直播了
//            [weakSelf closeLive];
//            
//            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    [alertView show];
    
}

static bool frontCamera = YES;
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
    
    frontCamera = !frontCamera;
    [[ZegoHelper api] setFrontCam:frontCamera];
    
    
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
//    [self.contributionListView show];
    [self.giftRecordView show];
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

- (WYGiftRecordView *)giftRecordView{
    if (!_giftRecordView) {
        _giftRecordView = [[WYGiftRecordView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _giftRecordView;
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

- (UIView *)liveContainerView{
    if (!_liveContainerView) {
        _liveContainerView = [[UIView alloc] init];
    }
    return _liveContainerView;
}

- (WYLiveGameResultView *)liveGameResultView{
    if (!_liveGameResultView) {
        NSString *nibNamed = @"WYLiveGameResultView";
        if ([WYLoginUserManager liveGameType] == LiveGameTypeTexasPoker || [WYLoginUserManager liveGameType] == LiveGameTypeTaurus) {
            nibNamed = @"WYLiveGameResultView";
        }else if ([WYLoginUserManager liveGameType] == LiveGameTypeTiger){
            nibNamed = @"WYLiveTigerResultView";
        }else if ([WYLoginUserManager liveGameType] == LiveGameTypeBaccarat){
            nibNamed = @"WYLiveBaccaratResultView";
        }else if ([WYLoginUserManager liveGameType] == LiveGameTypeSlots){
            return nil;
        }
        _liveGameResultView = (WYLiveGameResultView *)[[NSBundle mainBundle] loadNibNamed:nibNamed owner:self options:nil].firstObject;
    }
    return _liveGameResultView;
}

-(UIButton *)demoBtn {
    if (!_demoBtn) {
        _demoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _demoBtn.frame  = CGRectMake(self.view.frame.size.width - 130 - 16, 100, 130, 55);
        //        [_demoBtn setImage:[UIImage imageNamed:@"camera_btn_filter_normal"] forState:UIControlStateNormal];
        [_demoBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_demoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_demoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_demoBtn setTitle:@"隐藏 FaceUnity" forState:UIControlStateNormal];
        [_demoBtn setTitle:@"显示 FaceUnity" forState:UIControlStateSelected];
        [_demoBtn addTarget:self action:@selector(showDemoBar) forControlEvents:UIControlEventTouchUpInside];
    }
    return _demoBtn ;
}

-(FUAPIDemoBar *)demoBar{
    if (!_demoBar) {
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 208, self.view.frame.size.width, 208)];
        
        _demoBar.itemsDataSource =  [FUManager shareManager].itemsDataSource;
        _demoBar.filtersDataSource = [FUManager shareManager].filtersDataSource;
        
        _demoBar.selectedItem = [FUManager shareManager].selectedItem;
        _demoBar.selectedFilter = [FUManager shareManager].selectedFilter;
        _demoBar.selectedBlur = [FUManager shareManager].selectedBlur;
        _demoBar.beautyLevel = [FUManager shareManager].beautyLevel;
        _demoBar.thinningLevel = [FUManager shareManager].thinningLevel;
        _demoBar.enlargingLevel = [FUManager shareManager].enlargingLevel;
        _demoBar.faceShapeLevel = [FUManager shareManager].faceShapeLevel;
        _demoBar.faceShape = [FUManager shareManager].faceShape;
        _demoBar.redLevel = [FUManager shareManager].redLevel;
        
        _demoBar.delegate = self;
    }
    return _demoBar ;
}

- (void)syncBeautyParams
{
    [FUManager shareManager].selectedFilter = _demoBar.selectedFilter;
    [FUManager shareManager].selectedBlur = _demoBar.selectedBlur;
    [FUManager shareManager].beautyLevel = _demoBar.beautyLevel;
    [FUManager shareManager].redLevel = _demoBar.redLevel;
    [FUManager shareManager].faceShape = _demoBar.faceShape;
    [FUManager shareManager].faceShapeLevel = _demoBar.faceShapeLevel;
    [FUManager shareManager].thinningLevel = _demoBar.thinningLevel;
    [FUManager shareManager].enlargingLevel = _demoBar.enlargingLevel;
}

#pragma mark -
#pragma mark - WYAnchorInfoViewDelegate
- (void)anchorInfoViewAvatarClicked{
    //主播信息
    [self.anchorManageView show];
}

#pragma mark - FUAPIDemoBarDelegate
- (void)demoBarDidSelectedItem:(NSString *)item {
    NSLog(@"------------- %@ ~",item);
    [[FUManager shareManager] loadItem:item];
}

- (void)demoBarDidSelectedFilter:(NSString *)filter {
    
    [FUManager shareManager].selectedFilter = filter ;
}

- (void)demoBarBeautyParamChanged {
    
    [self syncBeautyParams];
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

#pragma mark - ZegoRoomDelegate
- (void)onDisconnect:(int)errorCode roomID:(NSString *)roomID
{
    [self prepareForCameraSetting];
    NSLog(@"onDisconnectonDisconnectonDisconnect");
}

#pragma mark - ZegoLivePublisherDelegate

- (void)onPublishStateUpdate:(int)stateCode streamID:(NSString *)streamID streamInfo:(NSDictionary *)info
{
    WYLog(@"%s, stream: %@, state: %d", __func__, streamID, stateCode);
    if (stateCode == 0)
    {
        [self.pauseTimers setFireDate:[NSDate date]];
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_live_succeed_tip"] toView:nil];
        NSLog(@"infoinfoinfo%@", info);
    }
    else
    {
        [self notificationWSDisConnect];
    }
}

- (void)onPublishQualityUpdate:(NSString *)streamID quality:(ZegoApiPublishQuality)quality
{
//    UIView *view = self.viewContainersDict[streamID];
//    if (view)
//        [self updateQuality:quality.quality view:view];
//    
//    [self addStaticsInfo:YES stream:streamID fps:quality.fps kbs:quality.kbps];
    NSString *totalString = [NSString stringWithFormat:@"fps %.3f, kbs %.3f",quality.fps, quality.kbps];
    WYLog(@"~~~~~~~~~onPublishQualityUpdate: %@", totalString);
    self.qualityNoGood++;
}

- (void)setReachabilityStatusChangeBlock:(nullable void (^)(AFNetworkReachabilityStatus status))block
{
    NSLog(@"aaaaaaaaaaa");
}

- (void)ReachabilityDidChangeNotification:(NSNotificationCenter *)sender
{
//    [self.pauseTimers setFireDate:[NSDate date]];
}

- (NSTimer *)pauseTimers{
    if (!_pauseTimers) {
        _pauseTimers =  [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(anchorDetail) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_pauseTimers forMode:NSRunLoopCommonModes];
    }
    return _pauseTimers;
}

- (void)stopTimer{
    if (_pauseTimers) {
        [_pauseTimers invalidate];
        _pauseTimers = nil;
    }
}

- (void)liveTimerRunning{
//    NSInteger status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
//    if (status == AFNetworkReachabilityStatusNotReachable) {
//        self.pauseTime++;
//    } else {
//        if (self.pauseTime > 90) {
//            [self prepareForCameraSetting];
//        }
//        self.pauseTime = 0;
//        [self stopTimer];
//    }
}

- (void)onAuxCallback:(void *)pData dataLen:(int *)pDataLen sampleRate:(int *)pSampleRate channelCount:(int *)pChannelCount
{
//    [self auxCallback:pData dataLen:pDataLen sampleRate:pSampleRate channelCount:pChannelCount];
}

@end
