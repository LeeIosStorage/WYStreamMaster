//
//  WYIncomeRewardViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/10/13.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYIncomeRewardViewController.h"
#import "WYIncomeRewardHeaderView.h"
#import "WYRewardModel.h"
#import "WYIncomeRewardTableViewCell.h"
static NSString *const kIncomeRewardTableViewCell = @"WYIncomeRewardTableViewCell";

@interface WYIncomeRewardViewController () <UITableViewDataSource, UITableViewDelegate, WYIncomeRewardHeaderViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) WYIncomeRewardHeaderView *headerView;
@property (nonatomic, strong) UIImageView *effectImgView;
@property (strong, nonatomic) IBOutlet UILabel *DividedLabel;
@property (strong, nonatomic) IBOutlet UILabel *dividedAmountLabel;
@property (nonatomic, strong) WYRewardModel *rewardModel;
@property (nonatomic, strong) NSMutableArray *dayArray;

@end

@implementation WYIncomeRewardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"分成奖励";
    [self setupView];
    [self setupData];
    [self getMonthIncomeRecordData];
    [self getIncomeRecordData:@"3"];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - setup
- (void)setupView
{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setTitle:@"筛选" forState:UIControlStateNormal];    
    [rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    [self setRightButton:rightButton];

    [self.tableview registerNib:[UINib nibWithNibName:kIncomeRewardTableViewCell bundle:nil] forCellReuseIdentifier:kIncomeRewardTableViewCell];
    
    [self.view addSubview:self.headerView];
    self.headerView.hidden = YES;
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view);
        make.leading.right.trailing.equalTo(self.view);
        make.height.mas_offset(60);
    }];
    
    UIImageView *effectImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, kScreenHeight - 60)];
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

- (void)setupData
{
    self.rewardModel = [[WYRewardModel alloc] init];
    self.dayArray = [NSMutableArray array];
}

#pragma mark -
#pragma mark - Server
- (void)getIncomeRecordData:(NSString *)type
{
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"last_month"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"anchor_user_code"];
    [paramsDic setObject:self.currencyType forKey:@"currency"];
    [paramsDic setObject:type forKey:@"type"];
    
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:[WYRewardModel class] success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUD];
        if (requestType == WYRequestTypeSuccess) {
            WYRewardModel *rewardModel = (WYRewardModel *)dataObject;
            weakSelf.rewardModel = rewardModel;
            [weakSelf.dayArray addObjectsFromArray:rewardModel.gift_number_value];
            [weakSelf updateRewardView];
            [weakSelf.tableview reloadData];
        }else{
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_failure_tip"] toView:weakSelf.view];
    }];
}

- (void)getMonthIncomeRecordData
{
    self.DividedLabel.text = [NSString stringWithFormat:@"近一个月分成奖励(%@)", self.currencyType];
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"last_month"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"anchor_user_code"];
    [paramsDic setObject:self.currencyType forKey:@"currency"];
    [paramsDic setObject:@"3" forKey:@"type"];
    
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:[WYRewardModel class] success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUD];
        if (requestType == WYRequestTypeSuccess) {
            WYRewardModel *rewardModel = (WYRewardModel *)dataObject;
            weakSelf.rewardModel = rewardModel;
            [weakSelf updateRewardView];
        }else{
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_failure_tip"] toView:weakSelf.view];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - event
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

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dayArray.count;
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WYIncomeRewardTableViewCell";
    WYIncomeRewardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[WYIncomeRewardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *dict = self.dayArray[indexPath.row];
    [cell updateCellData:dict row:indexPath.row];
    return cell;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *itemBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 100.0f)];
//    UILabel *rewardLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 20)];
//    rewardLabel.text = @"近一个月分成奖励";
//    rewardLabel.font = [UIFont systemFontOfSize:12.0];
//    rewardLabel.textColor = [UIColor colorWithHexString:@"999999"];
//    [rewardLabel setTextAlignment:NSTextAlignmentCenter];
//    UILabel *rewardAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, kScreenWidth, 30)];
//    rewardAmountLabel.text = @"1298";
//    rewardAmountLabel.font = [UIFont systemFontOfSize:36.0];
//    rewardAmountLabel.textColor = [UIColor colorWithHexString:@"FF5A00"];
//    [rewardAmountLabel setTextAlignment:NSTextAlignmentCenter];
//    [itemBgView addSubview:rewardLabel];
//    [itemBgView addSubview:rewardAmountLabel];
//    return itemBgView;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Getters
- (WYIncomeRewardHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = (WYIncomeRewardHeaderView *)[[NSBundle mainBundle] loadNibNamed:@"WYIncomeRewardHeaderView" owner:self options:nil].lastObject;
        _headerView.delegate = self;
        
    }
    return _headerView;
}

- (void)updateRewardView
{
    NSString *monthValue = [NSString stringWithFormat:@"%@", self.rewardModel.month[@"month_value"]];
    if ([monthValue length] > 0 && ![monthValue isEqualToString:@"<null>"]) {
        self.dividedAmountLabel.text = monthValue;
    } else {
        self.dividedAmountLabel.text = @"0";
    }
}

#pragma mark - WYIncomeRecordHeaderViewDelegate
- (void)clickCurrencyButtonDelegate:(NSString *)currencyString
{
    self.headerView.hidden = YES;
    self.effectImgView.hidden = YES;
    if ([currencyString isEqualToString:@"本周"]) {
        self.DividedLabel.text = [NSString stringWithFormat:@"一周分成奖励(%@)", self.currencyType];
        [self getIncomeRecordData:@"1"];
    } else if ([currencyString isEqualToString:@"本月"]) {
        self.DividedLabel.text = [NSString stringWithFormat:@"本月分成奖励(%@)", self.currencyType];
        [self getIncomeRecordData:@"2"];
    } else if ([currencyString isEqualToString:@"近一月"]) {
        self.DividedLabel.text = [NSString stringWithFormat:@"近一个月分成奖励(%@)", self.currencyType];
        [self getIncomeRecordData:@"3"];
    } else if ([currencyString isEqualToString:@"近三月"]) {
        self.DividedLabel.text = [NSString stringWithFormat:@"近三个月分成奖励(%@)", self.currencyType];
        [self getIncomeRecordData:@"4"];
    }
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
