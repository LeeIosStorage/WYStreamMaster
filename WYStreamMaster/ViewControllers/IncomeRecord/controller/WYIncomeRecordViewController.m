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
typedef NS_ENUM(NSInteger, HomePageCellStyle) {
    HomePageCellStyleMessage = 0,
    HomePageCellStyleFans,
    HomePageCellStyleContribution,
    HomePageCellStyleRoomManager,
    HomePageCellStyleMemberMute,
};

static NSString *const kIncomeRecordTableViewCell = @"WYIncomeRecordTableViewCell";

@interface WYIncomeRecordViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UIScrollView          *headerScroll;
@property (strong, nonatomic) NSArray               *itemArray;
@property (assign, nonatomic) HomePageCellStyle     cellStyle;
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
//@property (strong, nonatomic) YTHomePageUserView    *userView;

///空view
@property (nonatomic, strong) UIView *emptyNoticeView;

@end

@implementation WYIncomeRecordViewController

- (instancetype)initWithCheckUserId:(NSString *)checkUserId isAnchor:(BOOL )isAnchor
{
    if (self = [super init]) {
        self.isAnchor = isAnchor;
        self.checkUserId = checkUserId;
        if (isAnchor) {
            self.cellStyle = HomePageCellStyleMessage;
            self.itemArray = @[@"动态",@"粉丝",@"贡献榜"];

            
        } else {
            self.cellStyle = HomePageCellStyleFans;
            self.itemArray = @[@"粉丝"];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"收益记录";
    self.itemArray = @[@"贡献周榜",@"贡献月榜",@"贡献总榜"];
    self.view.backgroundColor = [WYStyleSheet defaultStyleSheet].themeBackgroundColor;
    [self initData];
    [self initSubviews];
    
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
//    [self getHomePageData];
}

- (void)reloadUI
{

    
    [self.homePageTable reloadData];
    //拿完数据看看有米有关注
    //[self setupNavigation];
}

- (void)initSubviews
{
    WEAKSELF
    
    [self.view addSubview:self.homePageTable];
    [self initHeaderImageView];
    
    [self.homePageTable registerNib:[UINib nibWithNibName:kIncomeRecordTableViewCell bundle:nil] forCellReuseIdentifier:kIncomeRecordTableViewCell];
    
    [self.homePageTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view).offset(200);
        make.leading.bottom.trailing.equalTo(weakSelf.view);
    }];
    
    
    //添加管理员
    self.addManagerButton.hidden = YES;
    [self.view addSubview:_addManagerButton];
    [self.addManagerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.view);
        make.centerX.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(50, 25));
    }];
}

- (void)initHeaderImageView
{
    WEAKSELF
    
    
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
    }else {
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
    if (self.cellStyle == HomePageCellStyleRoomManager) {
        return 10;
//        return self.homePageModel.managers.count;
    } else if (self.cellStyle == HomePageCellStyleContribution) {
        return 10;
//        return self.homePageModel.contributionRanks.count;
    } else if (self.cellStyle == HomePageCellStyleFans) {
        return 10;
//        return self.homePageModel.fansModel.fansList.count;
    } else if (self.cellStyle == HomePageCellStyleMessage) {
        return 10;
//        return  self.commentLists.count;
    }
    return 10;
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WYIncomeRecordTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
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
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
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
//            self.title = self.homePageModel.infoModel.userNickName;
            [self setNeedsStatusBarAppearanceUpdate];
            
        } else {
            self.title = @"";
            [self setNeedsStatusBarAppearanceUpdate];
        }
    } else if (scrollView == self.headerScroll) {
        
    }
}


#pragma mark
#pragma mark - Action
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

- (void)setCellStyle:(HomePageCellStyle)cellStyle
{
    WEAKSELF
    
    [self.homePageTable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view).offset(200);
        make.leading.bottom.trailing.equalTo(weakSelf.view);
    }];
    
    switch (cellStyle) {
        case HomePageCellStyleMessage:
        {
            
        }
            break;
        case HomePageCellStyleFans:
        {
            self.addManagerButton.hidden = YES;
            
        }
            break;
        case HomePageCellStyleContribution:
        {
            self.addManagerButton.hidden = YES;
            
        }
            break;
        case HomePageCellStyleRoomManager:
        {
            
        }
            break;
        default:
            break;
    }
    _cellStyle = cellStyle;
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
