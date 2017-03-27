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
#import "YTRoomView.h"
#import "WYContributionListView.h"
#import "WYAnchorManageView.h"
#import "WYGiftModel.h"
#import "WYBetTopView.h"
#import "WYGiftHistoryView.h"

// 直播通知重试次数
static NSInteger kLiveNotifyRetryCount = 0;
static NSInteger kLiveNotifyRetryMaxCount = 3;

@interface WYLiveViewController ()
<
WYStreamingSessionManagerDelegate,
WYAnchorInfoViewDelegate
>
{
    PLMediaStreamingSession *_plSession;
}

@property (nonatomic, strong) WYStreamingSessionManager *streamingSessionManager;

@property (nonatomic, weak) IBOutlet UIView *contentContainerView;
@property (nonatomic, weak) IBOutlet UIButton *expandChatButton;
@property (nonatomic, weak) IBOutlet UIButton *betTopButton;
@property (nonatomic, weak) IBOutlet UIButton *giftHistoryButton;


@property (nonatomic, strong) WYAnchorInfoView *anchorInfoView;

@property (nonatomic, strong) WYAnchorManageView *anchorManageView;//主播管理View

@property (strong, nonatomic) YTRoomView *roomView;//chatView

@property (strong, nonatomic) WYContributionListView *contributionListView;//贡献榜

@property (strong, nonatomic) WYBetTopView *betTopView;//押注排行

@property (strong, nonatomic) WYGiftHistoryView *giftHistoryView;//礼物历史

@end

@implementation WYLiveViewController

- (void)dealloc{
    WYLog(@"%@ dealloc !!!",NSStringFromClass([self class]));
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
    
    [self setupSubView];
    
    [self prepareForCameraSetting];
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
    
}

#pragma mark -
#pragma mark - Private Methods
- (void)setupSubView{
    
    self.betTopButton.layer.cornerRadius = 20;
    self.betTopButton.layer.masksToBounds = YES;
    [self.betTopButton.layer setBorderWidth:0.5];
    [self.betTopButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    self.giftHistoryButton.layer.cornerRadius = 20;
    self.giftHistoryButton.layer.masksToBounds = YES;
    [self.giftHistoryButton.layer setBorderWidth:0.5];
    [self.giftHistoryButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    //直播信息
    [self.contentContainerView addSubview:self.anchorInfoView];
    [self.anchorInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentContainerView).offset(10);
        make.top.equalTo(self.contentContainerView).offset(22);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(66);
    }];
    
    [self.anchorInfoView updateAnchorInfoWith:nil];
    
    [self initRoomView];
}

- (void)initRoomView
{
    self.expandChatButton.selected = NO;
    
    [self.view addSubview:self.roomView];
    [self.roomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentContainerView).offset(-70);
        make.left.equalTo(self.contentContainerView).offset(15);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-kRoomChatViewCustomWidth, 150));
    }];
    [self.roomView roomViewPrepare];
}

- (void)prepareForCameraSetting
{
    NSURL *streamURL = [NSURL URLWithString:@"rtmp://pili-publish.kaisaiba.com/xklive/xklive1?e=1489570947&token=f5P2MSZgPXSzb_ieKdgc35qvQTg145JYXWP8B0Ch:PMIGqyr7WLF9wK4ECHLNwRoFvhs="];
    self.streamingSessionManager = [[WYStreamingSessionManager alloc] initWithStreamURL:streamURL];
    _streamingSessionManager.delegate = self;
    _plSession = [self.streamingSessionManager streamingSession];
    
    UIView *previewView = _plSession.previewView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view insertSubview:previewView atIndex:0];
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

#pragma mark -
#pragma mark - Button Clicked
- (IBAction)doBackAction:(id)sender{
    
    WEAKSELF
    UIAlertView *alertView = [UIAlertView bk_showAlertViewWithTitle:@"确定要停止直播吗？" message:nil cancelButtonTitle:@"再想想" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
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

static int tempCount = 0;
- (IBAction)changeCameraAction:(id)sender{
    
//    [self.roomView sendMessageWithText:@"你的谢腾飞，尬舞尬起来啊，我牛牛就问你怕不怕，我屮艸芔茻赢了1000万"];
    
    tempCount++;
    
    WYGiftModel *gifModel = [[WYGiftModel alloc] init];
    
    gifModel.giftId = @"1";
    gifModel.name = @"礼物1";
    int type = tempCount%3;
    if (type == 1) {
        gifModel.giftId = @"2";
        gifModel.name = @"礼物2";
    }else if (type == 2){
        gifModel.giftId = @"3";
        gifModel.name = @"礼物3";
    }
    
    gifModel.sender = [WYLoginUserManager nickname];
    gifModel.clickNumber = 10;
    gifModel.noFrameIcon = @"http://imgsa.baidu.com/baike/c0%3Dbaike180%2C5%2C5%2C180%2C60/sign=e6c6c4a53ddbb6fd3156ed74684dc07d/b64543a98226cffca90bcfecbd014a90f603ea4f.jpg";
    [self.roomView.chatroomControl sendMessageWithGift:gifModel];
    
    return;
    [_plSession toggleCamera];
//    [_plSession getScreenshotWithCompletionHandler:^(UIImage * _Nullable image) {
//        UIImage *screenshotImage = image;
//    }];
}

//押注排行榜
- (IBAction)betTopAction:(id)sender{
    [self.betTopView show:self.contentContainerView];
    [self.betTopView updateBetTopData];
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
