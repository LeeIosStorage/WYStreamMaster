//
//  WYIncomeRecordViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/28.
//  Copyright © 2017年 Leejun. All rights reserved.
//
#define TableHeader_Height 260
#define Header_Image_Height SCREEN_WIDTH
#define NAVBAR_CHANGE_POINT 60

#define TOP_BG_HIDE 64.f
#define RATE 5
#import "WYIncomeRecordViewController.h"
#import "YTItemView.h"
#import "WYCustomAlertView.h"
#import "WYIncomeRecordTableViewCell.h"
#import "WYIncomeRecordHeaderView.h"
#import "WYIncomeRewardViewController.h"
#import "WYTodayProfitModel.h"
#import "WYContributionListModel.h"
#import "WYContributionInformationModel.h"
typedef NS_ENUM(NSInteger, ContributionCellStyle) {
    ContributionCellStyleWeek = 0,
    ContributionCellStyleMonth,
    ContributionCellStyleTotal,
};

static NSString *const kIncomeRecordTableViewCell = @"WYIncomeRecordTableViewCell";

@interface WYIncomeRecordViewController () <UITableViewDataSource, UITableViewDelegate, WYIncomeRecordHeaderViewDelegate>
@property (strong, nonatomic) UIScrollView          *headerScroll;
@property (strong, nonatomic) NSArray               *itemArray;
@property (assign, nonatomic) ContributionCellStyle cellStyle;
@property (copy, nonatomic) NSString                *checkUserId;
@property (assign, nonatomic) BOOL                  isAnchor;
@property (strong, nonatomic) YTItemView            *itemView;
@property (strong, nonatomic) UIButton              *addManagerButton;
@property (strong, nonatomic) WYCustomAlertView     *alerView;

@property (strong, nonatomic) UITableView           *homePageTable;
@property (assign, nonatomic) SInt64                commentNextCursor;
@property (assign, nonatomic) BOOL                  commentCanLoadMore;
@property (assign, nonatomic) int                   totalCommentNum;
@property (strong, nonatomic) NSMutableArray        *commentLists;
// 选择收益货币VIEW
@property (strong, nonatomic) WYIncomeRecordHeaderView *headerView;
@property (nonatomic, strong) UIImageView *effectImgView;
///空view
@property (nonatomic, strong) UIView *emptyNoticeView;
@property (strong, nonatomic) IBOutlet UIImageView *incomeHeaderView;
@property (nonatomic, strong) WYTodayProfitModel *todayProfitModel;
// 分成系数
@property (strong, nonatomic) IBOutlet UILabel *dividedLabel;
// 分成奖励
@property (strong, nonatomic) IBOutlet UILabel *rewardLabel;
// 礼物数量
@property (strong, nonatomic) IBOutlet UILabel *giftNumberLabel;
// 礼物价值
@property (strong, nonatomic) IBOutlet UILabel *giftValueLabel;
// 分成标题
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
// 今日收益
@property (strong, nonatomic) IBOutlet UILabel *todayProfitLabel;

@property (strong, nonatomic) NSMutableArray *weekArray;
@property (strong, nonatomic) NSMutableArray *monthArray;
@property (strong, nonatomic) NSMutableArray *totalArray;

@property (assign, nonatomic) int  publishNextCursor;
@end

@implementation WYIncomeRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"收益记录";
    self.itemArray = @[@"贡献周榜",@"贡献月榜",@"贡献总榜"];
    self.view.backgroundColor = [WYStyleSheet defaultStyleSheet].themeBackgroundColor;
    [self initData];
    [self initSubviews];
    [self getIncomeRecordData];
    [self getTodayIncomeData];
    [self addLiveHallRefreshHeader];
    [self addLiveHallRefreshFooter];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)initData
{
    self.commentLists = [NSMutableArray arrayWithCapacity:0];
    self.weekArray = [NSMutableArray arrayWithCapacity:0];
    self.monthArray = [NSMutableArray arrayWithCapacity:0];
    self.totalArray = [NSMutableArray arrayWithCapacity:0];
}

- (void)reloadUI
{
    [self.homePageTable reloadData];
    //拿完数据看看有米有关注
    //[self setupNavigation];
}

- (void)initSubviews
{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setTitle:@"CNY" forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"income_record_down"] forState:UIControlStateNormal];
    [rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0,0,0,10)];
    [rightButton setImageEdgeInsets:UIEdgeInsetsMake(0,50,0,0)];
    [self setRightButton:rightButton];
    // 点击收益
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureIncomeHeaderView:)];
    [self.incomeHeaderView addGestureRecognizer:tapGesture];
    
    WEAKSELF
    [self.view addSubview:self.homePageTable];
    [self initHeaderImageView];
    
    [self.homePageTable registerNib:[UINib nibWithNibName:kIncomeRecordTableViewCell bundle:nil] forCellReuseIdentifier:kIncomeRecordTableViewCell];
    
    [self.homePageTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view).offset(240);
        make.leading.bottom.trailing.equalTo(weakSelf.view);
    }];
    
    // 添加管理员
    self.addManagerButton.hidden = YES;
    [self.view addSubview:_addManagerButton];
    [self.addManagerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.view);
        make.centerX.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(50, 25));
    }];
    
    [self.view addSubview:self.headerView];
    self.headerView.hidden = YES;
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view);
        make.leading.right.trailing.equalTo(weakSelf.view);
        make.height.mas_offset(110);
    }];
    
    UIImageView *effectImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 110, kScreenWidth, kScreenHeight - 110)];
    effectImgView.contentMode = UIViewContentModeScaleAspectFill;
    effectImgView.userInteractionEnabled = YES;
    effectImgView.backgroundColor = [UIColor blackColor];
    effectImgView.alpha = 0.4;
    [self.view addSubview:effectImgView];

    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = CGRectMake(0, 0, effectImgView.frame.size.width, effectImgView.frame.size.height);
    [effectImgView addSubview:effectView];
    self.effectImgView = effectImgView;
    self.effectImgView.hidden = YES;
    
}

#pragma mark - Refresh
- (void)addLiveHallRefreshHeader
{
    self.homePageTable.mj_header = [WYRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestMessageInfo)];
}
    
- (void)requestMessageInfo{
    if ([self.homePageTable.mj_header isRefreshing]) {
        self.publishNextCursor = 1;
        if (self.cellStyle == ContributionCellStyleWeek) {
            self.weekArray = [NSMutableArray array];
        } else if (self.cellStyle == ContributionCellStyleMonth) {
            self.monthArray = [NSMutableArray array];
        } else if (self.cellStyle == ContributionCellStyleTotal) {
            self.totalArray = [NSMutableArray array];
        }
        [self getIncomeRecordData];
    }
}
    
- (void)addLiveHallRefreshFooter{
    self.homePageTable.mj_footer = [WYRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestMessageInfoFoot)];
}
    
- (void)requestMessageInfoFoot{
    if ([self.homePageTable.mj_footer isRefreshing]) {
        self.publishNextCursor ++;
        [self getIncomeRecordData];
    }
}
    
- (void)initHeaderImageView
{
    
}

- (void)showMessage
{
//    YTMessageViewController *ytMessVc = [[YTMessageViewController alloc]init];
//    ytMessVc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:ytMessVc animated:YES];
}

- (void)showMore
{
    
}

- (void)showNoticeEditeController
{
    
}

#pragma mark -
#pragma mark - Server
- (void)getIncomeRecordData
{
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"giftRanking"];
    
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"anchor_user_code"];
    [paramsDic setObject:self.rightButton.titleLabel.text forKey:@"currency"];
    
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:[WYContributionListModel class] success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUD];
        [weakSelf.homePageTable.mj_footer endRefreshing];
        [weakSelf.homePageTable.mj_header endRefreshing];
        if (requestType == WYRequestTypeSuccess) {
            WYContributionListModel *contributionListModel = (WYContributionListModel *)dataObject;
            NSArray *weekArr = [NSArray modelArrayWithClass:[WYContributionInformationModel class] json:contributionListModel.week];
            [weakSelf.weekArray addObjectsFromArray:weekArr];
            NSArray *monthArr = [NSArray modelArrayWithClass:[WYContributionInformationModel class] json:contributionListModel.month];
            [weakSelf.monthArray addObjectsFromArray:monthArr];
            NSArray *totalArr = [NSArray modelArrayWithClass:[WYContributionInformationModel class] json:contributionListModel.total];
            [weakSelf.totalArray addObjectsFromArray:totalArr];
            
            if (weekArr.count < 10 && monthArr.count < 10 && totalArr.count < 10) {
                [weakSelf.homePageTable.mj_footer setHidden:YES];
            }else{
                [weakSelf.homePageTable.mj_footer setHidden:NO];
            }
        }else{
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [weakSelf.homePageTable.mj_footer endRefreshing];
        [weakSelf.homePageTable.mj_header endRefreshing];
        [MBProgressHUD hideHUD];
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_failure_tip"] toView:weakSelf.view];
    }];
}

- (void)getTodayIncomeData
{
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"gift_income"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"anchor_user_code"];
    [paramsDic setObject:self.rightButton.titleLabel.text forKey:@"currency"];
    
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:[WYTodayProfitModel class] success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUD];
        
        if (requestType == WYRequestTypeSuccess) {
            weakSelf.todayProfitModel = (WYTodayProfitModel *)dataObject;
            [weakSelf updateHeaderView:weakSelf.todayProfitModel];
        }else{
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_failure_tip"] toView:weakSelf.view];
    }];
}

#pragma mark - emptyNoticeView
- (UIView *)emptyNoticeView {
    if (!_emptyNoticeView) {
        _emptyNoticeView = [[UIView alloc] init];
        _emptyNoticeView.frame = CGRectMake(0, 0, kScreenWidth, 150);
        
        UIImageView *emptyImageView = [[UIImageView alloc] init];
        emptyImageView.image = [UIImage imageNamed:@"common_empty_icon"];
        emptyImageView.userInteractionEnabled = NO;
        emptyImageView.frame = CGRectMake(0, 15, 120, 120);
        emptyImageView.centerX = _emptyNoticeView.centerX;
        
        [_emptyNoticeView addSubview:emptyImageView];
    }
    
    return  _emptyNoticeView;
}

- (void)checkAndShowEmptyNoticeView:(NSArray *)listArray{
    if (listArray.count > 0) {
        self.homePageTable.tableFooterView = nil;
        self.emptyNoticeView.hidden = YES;
    } else {
        self.homePageTable.tableFooterView = self.emptyNoticeView;
        self.emptyNoticeView.hidden = NO;
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.cellStyle == ContributionCellStyleWeek) {
        return self.weekArray.count;
    } else if (self.cellStyle == ContributionCellStyleMonth) {
        return self.monthArray.count;
    } else if (self.cellStyle == ContributionCellStyleTotal) {
        return self.totalArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WYIncomeRecordTableViewCell";
    WYIncomeRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[WYIncomeRecordTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    WYContributionInformationModel *model;
    if (self.cellStyle == ContributionCellStyleWeek) {
        model = self.weekArray[indexPath.row];
    } else if (self.cellStyle == ContributionCellStyleMonth) {
        model = self.monthArray[indexPath.row];
    } else if (self.cellStyle == ContributionCellStyleTotal) {
        model = self.totalArray[indexPath.row];
    }
    [cell updateCellData:model];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *itemBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 35.f)];
    itemBgView.backgroundColor = [UIColor whiteColor];
    if (!self.itemView) {
        self.itemView = [[YTItemView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30.f)  Items:self.itemArray];
        self.itemView.backgroundColor = [UIColor whiteColor];
        WEAKSELF
        self.itemView.itemSeletedBlock = ^(NSInteger item){
            weakSelf.cellStyle = item;
            [weakSelf.homePageTable reloadData];
        };
    }
    
    [itemBgView addSubview:_itemView];
    
    return itemBgView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 240)];
    footerView.backgroundColor = [WYStyleSheet defaultStyleSheet].themeBackgroundColor;
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}



#pragma mark
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.homePageTable) {
        
        UIColor * color = [WYStyleSheet defaultStyleSheet].themeColor;
        CGFloat offsetY = scrollView.contentOffset.y;
        
        if (offsetY > NAVBAR_CHANGE_POINT) {
            CGFloat alpha = MIN(1, 1 - ((NAVBAR_CHANGE_POINT + 64 - offsetY) / 64));
            [self setNeedsStatusBarAppearanceUpdate];
            
        } else {
            [self setNeedsStatusBarAppearanceUpdate];
        }
    } else if (scrollView == self.headerScroll) {
        
    }
}


#pragma mark
#pragma mark - Action
- (void)rightButtonClicked:(id)sender
{
    UIButton *rightButton = (UIButton *)sender;
    rightButton.selected = !rightButton.selected;
    if (rightButton.selected) {
        self.headerView.hidden = NO;
        self.effectImgView.hidden = NO;
    } else {
        self.headerView.hidden = YES;
        self.effectImgView.hidden = YES;
    }
}

- (void)tapGestureIncomeHeaderView:(UITapGestureRecognizer *)sender
{
    WYIncomeRewardViewController *incomeRewardVC = [[WYIncomeRewardViewController alloc] init];
    incomeRewardVC.currencyType = self.rightButton.titleLabel.text;
    [self.navigationController pushViewController:incomeRewardVC animated:YES];
}

- (void)showAddManagerView
{
    //    if(!self.addManagerView) {
    //        self.addManagerView = [[NSBundle mainBundle] loadNibNamed:@"YTAddManagerView" owner:self options:nil].lastObject;
    //    }
    
//    self.addManagerView = [[NSBundle mainBundle] loadNibNamed:@"YTAddManagerView" owner:self options:nil].lastObject;
//    self.alerView = [[WYCustomAlertView alloc] initWithCustomAlertSize:self.addManagerView.size];
//    [self.alerView showWithView:_addManagerView];
//    WEAKSELF
//    [UIView animateWithDuration:0.25 animations:^{
//        [weakSelf.alerView.showView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.centerY.mas_equalTo(-100);
//        }];
//    }];
//    
//    [self.addManagerView.inputUserIdTF becomeFirstResponder];
//    
//    [self.addManagerView.toAddButton addTarget:self action:@selector(toAddManager) forControlEvents:UIControlEventTouchUpInside];
}

- (void)toAddManager
{
//    [self.addManagerView.inputUserIdTF resignFirstResponder];
//    [self.alerView closeShowView];
//    [self toAddManagerWithUserId:self.addManagerView.inputUserIdTF.text];
}

- (void)refreshViewWithObject:(id)object
{
//    if ([object isKindOfClass:[NSString class]]) {
//        self.homePageModel.infoModel.liveNotice = object;
//        [self.userView updateUserWithInfoModel:self.homePageModel.infoModel];
//    }
}

- (void)moreCommentAction:(id)sender{
    [self showMoreCommentVc:YES];
}

- (void)showMoreCommentVc:(BOOL)needComment{
//    CommentSubmitViewController *submitVc = [[CommentSubmitViewController alloc] init];
//    submitVc.bountyId = self.checkUserId;
//    submitVc.submitType = 7;
//    submitVc.delegate = self;
//    
//    UIButton *customRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [customRightButton setTitle:@"发布" forState:UIControlStateNormal];
//    [customRightButton setTitleColor:[WYStyleSheet currentStyleSheet].normalButtonColor forState:UIControlStateNormal];
//    [customRightButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
//    customRightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    
//    submitVc.rightButton = customRightButton;
//    
//    [self.navigationController pushViewController:submitVc animated:YES];
}


#pragma mark
#pragma mark - Setter

- (void)setCellStyle:(ContributionCellStyle)cellStyle
{
    WEAKSELF
    [self.homePageTable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view).offset(240);
        make.leading.bottom.trailing.equalTo(weakSelf.view);
    }];
    
    switch (cellStyle) {
        case ContributionCellStyleWeek:
        {
            
        }
            break;
        case ContributionCellStyleMonth:
        {
            
        }
            break;
        case ContributionCellStyleTotal:
        {
            
        }
            break;
        default:
            break;
    }
    _cellStyle = cellStyle;
    [self.homePageTable reloadData];
}

#pragma mark
#pragma mark - Getter
- (UITableView *)homePageTable
{
    if (!_homePageTable) {
        _homePageTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_homePageTable setDelegate:self];
        [_homePageTable setDataSource:self];
        _homePageTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.homePageTable.backgroundColor = [UIColor clearColor];
        self.homePageTable.backgroundView = nil;
        
        [self.homePageTable registerNib:[UINib nibWithNibName:kIncomeRecordTableViewCell bundle:nil] forCellReuseIdentifier:kIncomeRecordTableViewCell];
    }
    return _homePageTable;
}

- (UIScrollView *)headerScroll
{
    if (!_headerScroll) {
        _headerScroll = [[UIScrollView alloc] init];
        //_headerScroll.contentSize = CGSizeMake(SCREEN_WIDTH,TableHeader_Height);
        
        _headerScroll.delegate = self;
    }
    return _headerScroll;
}

- (UIButton *)addManagerButton
{
    if (!_addManagerButton) {
        _addManagerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addManagerButton setImage:[UIImage imageNamed:@"editManage"] forState:UIControlStateNormal];
        [_addManagerButton addTarget:self action:@selector(showAddManagerView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addManagerButton;
}

- (WYIncomeRecordHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = (WYIncomeRecordHeaderView *)[[NSBundle mainBundle] loadNibNamed:@"WYIncomeRecordHeaderView" owner:self options:nil].lastObject;
        _headerView.delegate = self;
        
    }
    return _headerView;
}

- (void)updateHeaderView:(WYTodayProfitModel *)todayProfitModel
{
    NSString *anchorValue = todayProfitModel.gift_number_value[@"anchor_get_value"];
    if ([anchorValue length] == 0) {
         anchorValue = @"0";
    }
    self.titleLabel.text = [NSString stringWithFormat:@"今日%@收益", self.rightButton.titleLabel.text];
    self.dividedLabel.text = [NSString stringWithFormat:@"分成系数%@%%", todayProfitModel.anchor[@"cut_ratio"]];
    self.todayProfitLabel.text = [NSString stringWithFormat:@"%@", anchorValue];
    self.rewardLabel.text = [NSString stringWithFormat:@"%@", anchorValue];
    self.giftNumberLabel.text = [NSString stringWithFormat:@"%@", todayProfitModel.gift_number_value[@"gift_number"]];
    self.giftValueLabel.text = [NSString stringWithFormat:@"%@", todayProfitModel.gift_number_value[@"anchor_channel_get_value"]];

}

#pragma mark - WYIncomeRecordHeaderViewDelegate
- (void)clickCurrencyButtonDelegate:(NSString *)currencyString
{
    [self.rightButton setTitle:currencyString forState:UIControlStateNormal];
    [self getTodayIncomeData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
