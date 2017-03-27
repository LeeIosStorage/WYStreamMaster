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

@interface MainTabViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (copy, nonatomic) NSString *roomNameTitle;
@property (copy, nonatomic) NSString *gameCategory;
@property (copy, nonatomic) NSString *gameCategoryId;

@property (nonatomic, strong) NSMutableArray *gameListArray;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *headContainerView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *nickNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *roomNumLabel;
@property (nonatomic, weak) IBOutlet UITextField *roomNameTextField;
@property (nonatomic, weak) IBOutlet UILabel *gameNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *gameChooseButton;
@property (nonatomic, weak) IBOutlet UIView *gameChooseContainerView;

@property (nonatomic, weak) IBOutlet UIView *codeRateView;

@property (nonatomic, weak) IBOutlet UIButton *startLiveButton;

@property (nonatomic, strong) WYGiftRecordView *giftRecordView;

@end

@implementation MainTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    
    self.gameListArray = [[NSMutableArray alloc] init];
    self.gameListArray = @[@"真人牛牛",@"真人德扑",@"VIP"];
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
    
    
    [self setStreamingKpbsUIWith:[WYStreamingConfig sharedConfig].videoQuality + 1];
    
    NSString *placeholder = @"给自己取一个闪亮的房间名字吧！";
    self.roomNameTextField.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[UIFont systemFontOfSize:12] color:UIColorHex(0xcacaca)];
    
    self.roomNameTextField.text = [WYLoginUserManager roomNameTitle];
    NSString *gameNameText = [WYLoginUserManager gameCategory];
    if (gameNameText.length == 0) {
        gameNameText = @"请选择直播的游戏";
    }
    self.gameNameLabel.text = gameNameText;
    
    self.gameCategory = [WYLoginUserManager gameCategory];
    self.gameCategoryId = [WYLoginUserManager gameCategoryId];
    
    self.headContainerView.width = SCREEN_WIDTH;
    self.headContainerView.height = 123 + 112 + 60;
    self.tableView.tableHeaderView = self.headContainerView;
    [self.tableView reloadData];
    
}

- (void)refreshHeadViewShow{
    
    NSURL *avatarUrl = [NSURL URLWithString:@"https://imgsa.baidu.com/baike/c0%3Dbaike180%2C5%2C5%2C180%2C60/sign=e6c6c4a53ddbb6fd3156ed74684dc07d/b64543a98226cffca90bcfecbd014a90f603ea4f.jpg"];
    [WYCommonUtils setImageWithURL:avatarUrl setImageView:self.avatarImageView placeholderImage:@""];
    
    self.nickNameLabel.text = [WYLoginUserManager nickname];
    self.roomNumLabel.text = [WYLoginUserManager roomId];
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [self.roomNameTextField resignFirstResponder];
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
    
    if ([self.roomNameTitle length] == 0) {
        [MBProgressHUD showError:@"给自己取一个闪亮的房间名字吧！"];
        return;
    }
    if ([self.gameCategory length] == 0 || [self.gameCategoryId length] == 0) {
        [MBProgressHUD showError:@"请选择直播的游戏"];
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
    [WYLoginUserManager setGameCategory:self.gameCategory];
    [WYLoginUserManager setGameCategoryId:self.gameCategoryId];
    
    [self startLive];
}

- (void)startLive{
    
    WYLiveViewController *liveVc = [[WYLiveViewController alloc] init];
    [self.navigationController pushViewController:liveVc animated:YES];
}

#pragma mark -
#pragma mark - Button Clicked
- (void)startLiveAction:(id)sender{
    [self toCreateLiveRoom];
}

- (IBAction)giftListAction:(id)sender{
    
    [self.giftRecordView show];
    
//    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"loginout",@"type",nil];
//    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:NULL];
//    NSString *string = [[ NSString alloc ] initWithData :data encoding : NSUTF8StringEncoding];
//    [[WYSocketManager sharedInstance] sendData:string];
    
}

- (IBAction)gameChooseAction:(id)sender{
    
    NSArray *otherButtonTitles = self.gameListArray;
    WEAKSELF
    WYCustomActionSheet *actionSheet = [[WYCustomActionSheet alloc] initWithTitle:@"选择直播的游戏" actionBlock:^(NSInteger buttonIndex) {
        if (buttonIndex >= otherButtonTitles.count) {
            return;
        }
        NSString *gameInfo = [self.gameListArray objectAtIndex:buttonIndex];
        weakSelf.gameCategory = gameInfo;
        weakSelf.gameCategoryId = gameInfo;
        weakSelf.gameNameLabel.text = weakSelf.gameCategory;
        
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:otherButtonTitles];
    [actionSheet showInView:self.view];
}

- (IBAction)codeRateAction:(id)sender{
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    [self setStreamingKpbsUIWith:tag];
    [WYStreamingConfig sharedConfig].videoQuality = tag-1;
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
