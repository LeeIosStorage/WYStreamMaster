//
//  MainTabViewController.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/10.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "MainTabViewController.h"
#import "WYLiveViewController.h"
#import "UIImageView+WebCache.h"
#import "WYStreamingConfig.h"
#import "WYSocketManager.h"
#import "WYGiftRecordView.h"
#import "WYCustomActionSheet.h"
#import "WYGameModel.h"
#import "WYDataMemoryManager.h"
#import <PgyUpdate/PgyUpdateManager.h>
#import "WYSettingViewController.h"

@interface MainTabViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate
>

@property (copy, nonatomic) NSString *roomNameTitle;
@property (copy, nonatomic) NSString *roomNoticeTitle;
@property (copy, nonatomic) NSString *gameCategory;
@property (copy, nonatomic) NSString *gameCategoryId;
@property (copy, nonatomic) NSString *roomType;

@property (nonatomic, strong) NSMutableArray *gameListArray;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *headContainerView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *nickNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *roomNumLabel;

@property (nonatomic, weak) IBOutlet UILabel *roomNameTipLabel;
@property (nonatomic, weak) IBOutlet UILabel *roomNoticeTipLabel;
@property (nonatomic, weak) IBOutlet UITextField *roomNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *roomNoticeTextField;
@property (nonatomic, weak) IBOutlet UILabel *gameNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *gameChooseButton;
@property (nonatomic, weak) IBOutlet UILabel *roomTypeLabel;
@property (nonatomic, weak) IBOutlet UIView *gameChooseContainerView;

@property (nonatomic, weak) IBOutlet UIView *vipRoomPasswordView;
@property (nonatomic, weak) IBOutlet UITextField *vipRoomPasswordTextField;

@property (nonatomic, weak) IBOutlet UIView *codeRateView;

@property (nonatomic, weak) IBOutlet UIButton *startLiveButton;
@property (nonatomic, weak) IBOutlet UILabel *startLiveTipLabel;

@property (nonatomic, strong) WYGiftRecordView *giftRecordView;

@end

@implementation MainTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[WYDataMemoryManager sharedInstance] login];
    
    [self setupSubview];
    [self checkAppUpdate];
    
    [self refreshHeadViewShow];
    
    [self refreshGameList];
    
    //判断是否开启麦克风权限
    if (![WYCommonUtils checkMicrophonePermissionStatus]) {
        [WYCommonUtils requsetMicrophonePermission];
    }
    if (![WYCommonUtils userCaptureIsAuthorization]) {
        [WYCommonUtils requsetCameraMediaPermission];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Server
- (void)refreshGameList{
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"gameList"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    
    WEAKSELF
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:[WYGameModel class] success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
//        [MBProgressHUD hideHUD];
        
        if (requestType == WYRequestTypeSuccess) {
            weakSelf.gameListArray = [[NSMutableArray alloc] init];
            if ([dataObject isKindOfClass:[NSArray class]]) {
                [weakSelf.gameListArray addObjectsFromArray:dataObject];
            }
        }else{
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
//        [MBProgressHUD hideHUD];
        [MBProgressHUD showAlertMessage:[WYCommonUtils showServerErrorLocalizedText] toView:weakSelf.view];
    }];
}

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
    if ([self.roomType integerValue] == 1) {
        [paramsDic setObject:self.vipRoomPasswordTextField.text forKey:@"password"];
    }
    
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
- (void)setupSubview{
    
    self.gameListArray = [[NSMutableArray alloc] init];
    
    UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    [self.view addGestureRecognizer:gestureRecongnizer];
    
    [self.startLiveButton addTarget:self action:@selector(startLiveAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.avatarImageView.layer.cornerRadius = 33;
    self.avatarImageView.layer.masksToBounds = YES;
    [self.avatarImageView.layer setBorderWidth:1];
    [self.avatarImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    self.tableView.scrollEnabled = NO;
    
    [WYStreamingConfig sharedConfig].videoQuality = VideoQualitySuperDefinition;
    [self setStreamingKpbsUIWith:[WYStreamingConfig sharedConfig].videoQuality + 1];
    
    self.roomNameTipLabel.text = [WYCommonUtils acquireCurrentLocalizedText:@"房间名称"];
    self.roomNoticeTipLabel.text = [WYCommonUtils acquireCurrentLocalizedText:@"公告"];
    self.startLiveTipLabel.text = [WYCommonUtils acquireCurrentLocalizedText:@"开始直播"];
    
    NSString *placeholder = [WYCommonUtils acquireCurrentLocalizedText:@"给自己取一个闪亮的房间名字吧！"];
    self.roomNameTextField.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[UIFont systemFontOfSize:12] color:UIColorHex(0xbcbbbb)];
    
    placeholder = [WYCommonUtils acquireCurrentLocalizedText:@"在此输入房间公告(不必填)"];
    self.roomNoticeTextField.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[UIFont systemFontOfSize:12] color:UIColorHex(0xbcbbbb)];
    
    placeholder = @"输入房间密码";
    self.vipRoomPasswordTextField.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[UIFont systemFontOfSize:12] color:UIColorHex(0xbcbbbb)];
    
    
    self.roomNameTextField.text = [WYLoginUserManager roomNameTitle];
    self.roomNoticeTextField.text = [WYLoginUserManager roomNoticeTitle];
    
    NSString *gameNameText = [WYLoginUserManager gameCategory];
    if (gameNameText.length == 0) {
        gameNameText = [WYCommonUtils acquireCurrentLocalizedText:@"选择直播的游戏"];
    }
    self.gameNameLabel.text = gameNameText;
    
    self.gameCategory = [WYLoginUserManager gameCategory];
    self.gameCategoryId = [WYLoginUserManager gameCategoryId];
    
    self.roomType = @"0";
    self.roomTypeLabel.text = [WYCommonUtils acquireCurrentLocalizedText:@"普通房间"];
    
    [self refreshHeadViewHeight];
    
    //测试时用
#ifdef DEBUG
    [self changeServerOperate];
#else
//    [self changeServerOperate];
#endif

}

- (void)changeServerOperate{
    UIButton *serverButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [serverButton setTitle:@"切换服务器" forState:UIControlStateNormal];
    [serverButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [serverButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [serverButton addTarget:self action:@selector(changeServerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:serverButton];
    [serverButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.view).offset(-10);
    }];
}
- (void)changeServerAction{
    WYSettingViewController *setVc = [[WYSettingViewController alloc] init];
    [self.navigationController pushViewController:setVc animated:YES];
}

- (void)checkAppUpdate
{
    [[PgyUpdateManager sharedPgyManager] startManagerWithAppId:kPGYAppId];
    [[PgyUpdateManager sharedPgyManager] checkUpdate];
}

- (void)refreshHeadViewShow{
    
    NSURL *avatarUrl = [NSURL URLWithString:[WYLoginUserManager avatar]];
    [WYCommonUtils setImageWithURL:avatarUrl setImageView:self.avatarImageView placeholderImage:@"wy_common_placehoder_image"];
    
    self.nickNameLabel.text = [WYLoginUserManager nickname];
    self.roomNumLabel.text = [WYLoginUserManager roomId];
}

- (void)refreshHeadViewHeight{
    
    if ([self.roomType intValue] == 1) {
        self.headContainerView.height = 123 + 222 + 33;
        self.vipRoomPasswordView.hidden = NO;
    }else{
        self.headContainerView.height = 123 + 167 - 55;//-55为去掉游戏选择的view
        self.vipRoomPasswordView.hidden = YES;
    }
    self.headContainerView.width = SCREEN_WIDTH;
    self.tableView.tableHeaderView = self.headContainerView;
    [self.tableView reloadData];
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [self.roomNameTextField resignFirstResponder];
    [self.roomNoticeTextField resignFirstResponder];
    [self.vipRoomPasswordTextField resignFirstResponder];
}

- (void)setStreamingKpbsUIWith:(NSInteger)index{
    for (id subView in self.codeRateView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = subView;
            button.selected = NO;
            if (index == button.tag) {
                button.selected = YES;
            }
        }
    }
}

- (void)toCreateLiveRoom{
    
    
    self.roomNameTitle = self.roomNameTextField.text;
    self.roomNoticeTitle = self.roomNoticeTextField.text;
    
    if ([self.roomNameTitle length] == 0) {
        [MBProgressHUD showError:[WYCommonUtils acquireCurrentLocalizedText:@"给自己取一个闪亮的房间名字吧！"]];
        return;
    }
//    if ([self.gameCategory length] == 0 || [self.gameCategoryId length] == 0) {
//        [MBProgressHUD showError:[WYCommonUtils acquireCurrentLocalizedText:@"选择直播的游戏"]];
//        return;
//    }
    if ([self.roomType intValue] == 1 && self.vipRoomPasswordTextField.text.length == 0) {
        [MBProgressHUD showError:@"请为VIP房间设置密码"];
        return;
    }
    
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

//    WYLiveViewController *liveVc = [[WYLiveViewController alloc] init];
//    liveVc.streamURL = [WYLoginUserManager anchorPushUrl];
//    [self.navigationController pushViewController:liveVc animated:YES];
}

#pragma mark -
#pragma mark - Button Clicked
- (void)startLiveAction:(id)sender{
    [self gestureRecognizer:nil];
    [self toCreateLiveRoom];
}

- (IBAction)giftListAction:(id)sender{
    [self gestureRecognizer:nil];
    
    [self.giftRecordView show];
    
//    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"loginout",@"type",nil];
//    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:NULL];
//    NSString *string = [[ NSString alloc ] initWithData :data encoding : NSUTF8StringEncoding];
//    [[WYSocketManager sharedInstance] sendData:string];
    
}

- (IBAction)gameChooseAction:(id)sender{
    [self gestureRecognizer:nil];
    
    NSMutableArray *otherButtonTitles = [NSMutableArray array];
    for (WYGameModel *gameModel in self.gameListArray) {
        [otherButtonTitles addObject:gameModel.gameName];
    }
    WEAKSELF
    WYCustomActionSheet *actionSheet = [[WYCustomActionSheet alloc] initWithTitle:[WYCommonUtils acquireCurrentLocalizedText:@"选择直播的游戏"] actionBlock:^(NSInteger buttonIndex) {
        if (buttonIndex >= otherButtonTitles.count) {
            return;
        }
        WYGameModel *gameModel = [self.gameListArray objectAtIndex:buttonIndex];
        weakSelf.gameCategory = gameModel.gameName;
        weakSelf.gameCategoryId = gameModel.gameId;
        weakSelf.gameNameLabel.text = weakSelf.gameCategory;
        
    } cancelButtonTitle:[WYCommonUtils acquireCurrentLocalizedText:@"wy_cancel"] destructiveButtonTitle:nil otherButtonTitles:otherButtonTitles];
    [actionSheet showInView:self.view];
}

- (IBAction)roomTypeAction:(id)sender{
    [self gestureRecognizer:nil];
    
    NSMutableArray *otherButtonTitles = [NSMutableArray array];
    [otherButtonTitles addObject:@"普通房间"];
    [otherButtonTitles addObject:@"VIP房间"];
    WEAKSELF
    WYCustomActionSheet *actionSheet = [[WYCustomActionSheet alloc] initWithTitle:@"选择直播房间类型" actionBlock:^(NSInteger buttonIndex) {
        if (buttonIndex >= otherButtonTitles.count) {
            return;
        }
        NSString *roomType = [otherButtonTitles objectAtIndex:buttonIndex];
        weakSelf.roomTypeLabel.text = roomType;
        if (buttonIndex == 0) {
            weakSelf.roomType = @"0";
        }else if (buttonIndex == 1){
            weakSelf.roomType = @"1";
        }
        [weakSelf refreshHeadViewHeight];
        
    } cancelButtonTitle:[WYCommonUtils acquireCurrentLocalizedText:@"wy_cancel"] destructiveButtonTitle:nil otherButtonTitles:otherButtonTitles];
    [actionSheet showInView:self.view];
}

- (IBAction)codeRateAction:(id)sender{
    [self gestureRecognizer:nil];
    
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    [self setStreamingKpbsUIWith:tag];
    [WYStreamingConfig sharedConfig].videoQuality = tag-1;
}

#pragma mark -
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *oldString = [textField.text copy];
    NSString *newString = [oldString stringByReplacingCharactersInRange:range withString:string];
    
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    
    if (!string.length && range.length > 0) {
        return YES;
    }
    
    
    if (textField == _roomNameTextField && textField.markedTextRange == nil) {
        if (newString.length > 10 && textField.text.length >= 10) {
            return NO;
        }
    }else if (textField == _roomNoticeTextField && textField.markedTextRange == nil){
        if (newString.length > 20 && textField.text.length >= 20) {
            return NO;
        }
    }else if (textField == _vipRoomPasswordTextField && textField.markedTextRange == nil){
        if (newString.length > 10 && textField.text.length >= 10) {
            return NO;
        }
    }
    return YES;
}

#pragma mark -
#pragma mark - Getters and Setters
- (WYGiftRecordView *)giftRecordView{
    if (!_giftRecordView) {
        _giftRecordView = [[WYGiftRecordView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _giftRecordView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

@end
