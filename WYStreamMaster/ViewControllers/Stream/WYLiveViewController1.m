//
//  WYLiveViewController.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/10.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYLiveViewController1.h"
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
#import "YTChatModel.h"
#import "WYLiveEndViewController.h"
#import "YTBetRankingView.h"
// 直播通知重试次数
static NSInteger kLiveNotifyRetryCount = 0;
static NSInteger kLiveNotifyRetryMaxCount = 3;

@interface WYLiveViewController1 ()
<
WYStreamingSessionManagerDelegate,
WYAnchorInfoViewDelegate,
ZegoLivePublisherDelegate,
FUAPIDemoBarDelegate,
ZegoRoomDelegate,
YTBetRankingViewDelegate
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

@property (nonatomic, strong) NSTimer *pauseTimers;

@property (nonatomic, assign) NSInteger startLiveTime;
@property (nonatomic, assign) NSInteger liveDurationTime;
// 直播结束截取图片
@property (nonatomic, strong) UIImage *liveEndImage;
@property (nonatomic, copy) NSString *flvStr;

@property (strong, nonatomic) YTBetRankingView *betRankingView;
@property (strong, nonatomic) YTBetRankingView *primaryBetRankingView;
// 送礼之星
@property (strong, nonatomic) IBOutlet UIButton *giftStarButton;
// 投注之星
@property (strong, nonatomic) IBOutlet UIButton *betStarButton;
@property (strong, nonatomic) IBOutlet UILabel *giftStarLabel;
@property (strong, nonatomic) IBOutlet UILabel *betStarLabel;
// 投注之星介绍
@property (strong, nonatomic)  UILabel *questionMarkLabel;

@end

@implementation WYLiveViewController1
- (instancetype)init
{
    if (self = [super init]) {
        [self crateWebSocket];
    }
    return self;
}
- (void)dealloc{
    WYLog(@"%@ dealloc !!!",NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[WYFaceRendererManager sharedInstance] stopTimer];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
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
    self.edgesForExtendedLayout = UIRectEdgeTop;
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverNoticeCustomAttachment:) name:WYServerNoticeAttachment_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReachabilityDidChangeNotification:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverNoticeFinishStream) name:WYNotificationWSConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketReConnectFailed) name:WYNotificationReConnectFailed object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWSDisConnect) name:WYNotificationWSDisConnect object:nil];
    [self setupSubView];
    
    [self prepareForCameraSetting];
//    [self crateWebSocket];
    [[ZegoHelper api] setRoomDelegate:self];
    self.startLiveTime = [self getCurrentTime];
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
    if (![[[NIMSDK sharedSDK] loginManager] isLogined]) {
        [self uploadFileSaveLog:@"NIM NoLogined"];
        [MBProgressHUD showError:@"系统消息：您的账号在别处登录，您已经被踢出直播间，无法收到聊天及礼物消息，需要杀掉进程重新登录" toView:self.view];
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:WYNotificationAgainStartLive object:nil];

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
                [[NSNotificationCenter defaultCenter] postNotificationName:WYNotificationAgainStartLive object:nil];
//                [weakSelf roomDisConnect];
            }
        }else{
        }
        
    } failure:^(id responseObject, NSError *error) {
//        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_server_request_errer_tip"] toView:weakSelf.view];
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
//        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_server_request_errer_tip"] toView:weakSelf.view];
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

// 上传日志
- (void)uploadFileSaveLog:(NSString *)fileLog
{
    NSString *currentTimes = [[self class] getCurrentTimes];
    NSString *fileContent = [NSString stringWithFormat:@"%@%@", fileLog,currentTimes];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", fileContent]];
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSData *fileData = [fileContent dataUsingEncoding:NSUTF8StringEncoding];
    [fileManager createFileAtPath:filePath contents:fileData attributes:nil];
//    NSString *requestUrl = @"http://172.16.2.183:8090/event-platform-admin/file/saveLog";
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"uploadfile"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"anchorId"];
//    [paramsDic setObject:filePath forKey:@"iconFile"];
//    [self.networkManager POST:requestUrl needCache:YES parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
//        if (requestType == WYRequestTypeSuccess) {
//            NSLog(@"");
//        } else {
//            NSLog(@"");
//        }
//    } failure:^(id responseObject, NSError *error) {
//        [MBProgressHUD showError:[WYCommonUtils acquireCurrentLocalizedText:@"wy_photo_upload_errer_tip"] toView:self.view];
//    }];
    [self.networkManager POST:requestUrl formFileName:@"file" fileName:filePath fileData:fileData mimeType:@"txt" parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        if (requestType == WYRequestTypeSuccess) {
            NSLog(@"");
        } else {
            NSLog(@"");
        }
    } failure:^(id responseObject, NSError *error) {
    }];
}

#pragma mark -
#pragma mark - Private Methods
- (void)crateWebSocket
{
    NSString *webSocketString = [NSString stringWithFormat:@"ws://www.legend8888.com/chat_room/ws.do?userCode=%@&anchor_user_code=%@&game_type=%zd&device=1", [WYLoginUserManager userID], [WYLoginUserManager userID], [WYLoginUserManager liveGameType]];
    [[WYSocketManager sharedInstance] initSocketURL:[NSURL URLWithString:webSocketString]];
    [self uploadFileSaveLog:@"createWebSocket"];
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
    
    [self initView];

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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    [self.view addGestureRecognizer:tap];
}

- (void)initView
{
    self.expandChatButton.selected = NO;
    
    CGFloat height = (250/667.0)*SCREEN_HEIGHT;
    [self.contentContainerView addSubview:self.roomView];
    [self.roomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentContainerView).offset(-180);
        make.left.equalTo(self.contentContainerView).offset(8);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-kRoomChatViewCustomWidth, height));
    }];
    [self.roomView roomViewPrepare];
    
    //    CGFloat height = (250/667.0)*SCREEN_HEIGHT;
    [self.view addSubview:self.betRankingView];
    [self.betRankingView updateBottomViewWithInfo:nil];
    [self.betRankingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(150);
    }];
    
    [self.view addSubview:self.primaryBetRankingView];
    [self.primaryBetRankingView updateBottomViewWithInfo:nil];
    [self.primaryBetRankingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(150);
    }];
    
    [self.view addSubview:self.questionMarkLabel];
    [self.questionMarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).mas_offset(-150);
        make.right.equalTo(self.view).mas_offset(-10);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(50);
    }];
    
}


//- (void)initRoomView
//{
//    self.expandChatButton.selected = NO;
//
//    CGFloat height = (250/667.0)*SCREEN_HEIGHT;
//    [self.contentContainerView addSubview:self.roomView];
//    [self.roomView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.contentContainerView).offset(-55);
//        make.left.equalTo(self.contentContainerView).offset(8);
//        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-kRoomChatViewCustomWidth, height));
//    }];
//    [self.roomView roomViewPrepare];
//}

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
    self.liveDurationTime = [self getCurrentTime] - self.startLiveTime;
    WYLiveEndViewController *liveEndVC = [[WYLiveEndViewController alloc] init:self.liveDurationTime liveEndImage:self.liveEndImage];
    [self.navigationController pushViewController:liveEndVC animated:YES];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"登录直播房间失败，请杀掉进程重试", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
//    [self serverNoticeFinishStream];
    [self.streamingSessionManager destroyStream];
    [self.roomView.chatroomControl exitRoom];
    //通知服务器停止直播了
    [self closeLive];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)socketReConnectFailed
{
    [self serverNoticeFinishStream];
    [[NSNotificationCenter defaultCenter] postNotificationName:WYNotificationAgainStartLive object:nil];
    [self uploadFileSaveLog:@"socketConnectFailed"];
}

- (void)onPublishStateUpdatefailureError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"推流失败，请重新开启直播", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
    self.liveEndImage = [self getImage];
//    self.liveEndImage = [[self class] thumbnailImageForVideo:[NSURL URLWithString:self.flvStr] atTime:0];

    [self uploadFileSaveLog:@"clickCloseButton"];
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

- (void)viewTapped
{
    self.betRankingView.hidden = YES;
    self.primaryBetRankingView.hidden = YES;
    self.giftStarButton.hidden = NO;
    self.betStarButton.hidden = NO;
    self.giftStarLabel.hidden = NO;
    self.betStarLabel.hidden = NO;
    self.questionMarkLabel.hidden = YES;
}



static bool frontCamera = YES;
//static int tempCount = 0;
- (IBAction)changeCameraAction:(id)sender{
    [self.plSession toggleCamera];
    frontCamera = !frontCamera;
    [[ZegoHelper api] setFrontCam:frontCamera];
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
    [self.giftRecordView show];
}

- (IBAction)changeChatViewFrameAction:(id)sender{
    self.expandChatButton.selected = !self.expandChatButton.selected;
    [self animationChangeChatViewFrame];
}
- (IBAction)clickGiftStar:(UIButton *)sender {
    self.betRankingView.hidden = NO;
    self.questionMarkLabel.text = @"送礼之星记录自主播本次开播开始，所有观看用户的累计送礼排名。";

//    self.primaryBetRankingView.hidden = YES;
    self.giftStarButton.hidden = YES;
    self.betStarButton.hidden = YES;
    self.giftStarLabel.hidden = YES;
    self.betStarLabel.hidden = YES;
}

- (IBAction)clickBetStar:(UIButton *)sender {
    self.primaryBetRankingView.hidden = NO;
//    self.betRankingView.hidden = YES;
    self.questionMarkLabel.text = @"赌神榜记录自主播本次开播开始，所有观看用户中投下重注的玩家。";
    self.giftStarButton.hidden = YES;
    self.betStarButton.hidden = YES;
    self.giftStarLabel.hidden = YES;
    self.betStarLabel.hidden = YES;
}

- (void)clickQuestionMarkButton
{
    self.questionMarkLabel.hidden = NO;
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

- (UILabel *)questionMarkLabel{
    if (!_questionMarkLabel) {
        _questionMarkLabel = [[UILabel alloc] init];
        _questionMarkLabel.text = @"送礼之星记录自主播本次开播开始，所有观看用户的累计送礼排名";
        _questionMarkLabel.numberOfLines = 0;
        _questionMarkLabel.font = [UIFont systemFontOfSize:12.0f];
        _questionMarkLabel.textColor = [UIColor whiteColor];
        _questionMarkLabel.backgroundColor = [UIColor blackColor];
        _questionMarkLabel.alpha = 0.8;
        _questionMarkLabel.hidden = YES;
    }
    return _questionMarkLabel;
}
- (YTBetRankingView *)betRankingView{
    if (!_betRankingView) {
        _betRankingView = (YTBetRankingView *)[[NSBundle mainBundle] loadNibNamed:@"YTBetRankingView" owner:self options:nil].lastObject;
        _betRankingView.betRankingType = BetRankingSeniorType;
        _betRankingView.delegate = self;
        _betRankingView.hidden = YES;
    }
    return _betRankingView;
}

- (YTBetRankingView *)primaryBetRankingView{
    if (!_primaryBetRankingView) {
        _primaryBetRankingView = (YTBetRankingView *)[[NSBundle mainBundle] loadNibNamed:@"YTBetRankingView" owner:self options:nil].lastObject;
        _primaryBetRankingView.betRankingType = BetRankingPrimaryType;
        _primaryBetRankingView.delegate = self;
        _primaryBetRankingView.hidden = YES;
    }
    return _primaryBetRankingView;
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
        _liveGameResultView.hidden = YES;
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

+ (NSString*)getCurrentTimes{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    NSLog(@"currentTimeString =  %@",currentTimeString);
    return currentTimeString;
}

// 获取当前时间
- (NSInteger)getCurrentTime
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    NSInteger currentTime = [timeString integerValue];
    return currentTime;
}

// 从view上截图
- (UIImage *)getImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT), NO, 1.0);  //NO，YES 控制是否透明
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // 生成后的image
    return image;
}

+ (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
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
    [self uploadFileSaveLog:@"onDisconnect"];
    NSLog(@"onDisconnectonDisconnectonDisconnect");
}

- (void)onKickOut:(int)reason roomID:(NSString *)roomID
{
    NSLog(@"onKickOutonKickOutonKickOut");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"您的账号在其他地方登录", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    //    [self serverNoticeFinishStream];
    [self.streamingSessionManager destroyStream];
    [self.roomView.chatroomControl exitRoom];
    [self.navigationController popViewControllerAnimated:YES];
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
        self.flvStr = info[@"flvList"][0];
    }
    else
    {
        [self onPublishStateUpdatefailureError];
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
    WYLog(@"~~~~~~~~~qualityNoGood: %d", quality.quality);
    if (quality.quality == 3) {
        self.qualityNoGood++;
    } else {
        self.qualityNoGood = 0;
    }
    if (self.qualityNoGood == 10) {
        self.qualityNoGood = 0;
        [MBProgressHUD showAlertMessage:@"您的网络不佳" toView:self.view];
        [self uploadFileSaveLog:@"qualityNoGood"];
    }
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
