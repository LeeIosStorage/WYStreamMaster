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

@property (nonatomic, strong) WYGiftRecordView *giftRecordView;

@end

@implementation MainTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[WYDataMemoryManager sharedInstance] login];
    
    [self setupSubview];
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
        [MBProgressHUD showAlertMessage:@"连接失败，请检查您的网络设置后重试" toView:weakSelf.view];
    }];
}

- (void)anchorOnLineRequest{
    
    [MBProgressHUD showMessage:@"直播准备中..."];
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"anchor_on_off"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"anchor_user_code"];
    [paramsDic setObject:@"1" forKey:@"anchor_status"];
    [paramsDic setObject:self.gameCategoryId forKey:@"game_type"];
    [paramsDic setObject:[WYLoginUserManager roomId] forKey:@"room_id_pk"];
    [paramsDic setObject:self.roomType forKey:@"room_type"];
    [paramsDic setObject:self.roomNameTitle forKey:@"anchor_title"];
    if (self.roomNoticeTitle.length > 0) {
        [paramsDic setObject:self.roomNoticeTitle forKey:@"anchor_description"];//房间公告
    }
    if ([self.roomType integerValue] == 1) {
        [paramsDic setObject:self.vipRoomPasswordTextField.text forKey:@"password"];
    }
    
    WEAKSELF
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUD];
        
        if (requestType == WYRequestTypeSuccess) {
            
            WYLiveViewController *liveVc = [[WYLiveViewController alloc] init];
            liveVc.streamURL = [WYLoginUserManager anchorPushUrl];
            [self.navigationController pushViewController:liveVc animated:YES];
            
        }else{
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showAlertMessage:@"请求失败，请检查您的网络设置后重试" toView:weakSelf.view];
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
    
    [WYStreamingConfig sharedConfig].videoQuality = VideoQualityStandardDefinition;
    [self setStreamingKpbsUIWith:[WYStreamingConfig sharedConfig].videoQuality + 1];
    
    NSString *placeholder = @"给自己取一个闪亮的房间名字吧！";
    self.roomNameTextField.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[UIFont systemFontOfSize:12] color:UIColorHex(0xbcbbbb)];
    
    placeholder = @"在此输入房间公告(不必填)";
    self.roomNoticeTextField.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[UIFont systemFontOfSize:12] color:UIColorHex(0xbcbbbb)];
    
    placeholder = @"输入房间密码";
    self.vipRoomPasswordTextField.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[UIFont systemFontOfSize:12] color:UIColorHex(0xbcbbbb)];
    
    
    self.roomNameTextField.text = [WYLoginUserManager roomNameTitle];
    self.roomNoticeTextField.text = [WYLoginUserManager roomNoticeTitle];
    
    NSString *gameNameText = [WYLoginUserManager gameCategory];
    if (gameNameText.length == 0) {
        gameNameText = @"请选择直播的游戏";
    }
    self.gameNameLabel.text = gameNameText;
    
    self.gameCategory = [WYLoginUserManager gameCategory];
    self.gameCategoryId = [WYLoginUserManager gameCategoryId];
    
    self.roomType = @"0";
    self.roomTypeLabel.text = @"普通房间";
    
    [self refreshHeadViewHeight];
    
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
        self.headContainerView.height = 123 + 222;
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
        [MBProgressHUD showError:@"给自己取一个闪亮的房间名字吧！"];
        return;
    }
    if ([self.gameCategory length] == 0 || [self.gameCategoryId length] == 0) {
        [MBProgressHUD showError:@"请选择直播的游戏"];
        return;
    }
    if ([self.roomType intValue] == 1 && self.vipRoomPasswordTextField.text.length == 0) {
        [MBProgressHUD showError:@"请为VIP房间设置密码"];
        return;
    }
    
    if (![WYCommonUtils checkMicrophonePermissionStatus] || ![WYCommonUtils userCaptureIsAuthorization]) {
        // 麦克风未授权
        WEAKSELF
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法访问麦克风或相机" message:@"请前往系统设置->隐私->麦克风/相机 打开权限" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
    WYCustomActionSheet *actionSheet = [[WYCustomActionSheet alloc] initWithTitle:@"选择直播的游戏" actionBlock:^(NSInteger buttonIndex) {
        if (buttonIndex >= otherButtonTitles.count) {
            return;
        }
        WYGameModel *gameModel = [self.gameListArray objectAtIndex:buttonIndex];
        weakSelf.gameCategory = gameModel.gameName;
        weakSelf.gameCategoryId = gameModel.gameId;
        weakSelf.gameNameLabel.text = weakSelf.gameCategory;
        
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:otherButtonTitles];
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
        
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:otherButtonTitles];
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
