//
//  WYIncomeRewardViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/10/13.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYIncomeRewardViewController.h"
#import "WYIncomeRecordHeaderView.h"
@interface WYIncomeRewardViewController () <UITableViewDataSource, UITableViewDelegate, WYIncomeRecordHeaderViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) WYIncomeRecordHeaderView *headerView;
@property (nonatomic, strong) UIImageView *effectImgView;

@end

@implementation WYIncomeRewardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"分成奖励";
    [self setupView];

    // Do any additional setup after loading the view from its nib.
}
#pragma mark - setup
- (void)setupView
{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setTitle:@"筛选" forState:UIControlStateNormal];    
//    [self setRightButton:rightButton];
    [rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.rightButton = rightButton;

//    [self.homePageTable registerNib:[UINib nibWithNibName:kIncomeRecordTableViewCell bundle:nil] forCellReuseIdentifier:kIncomeRecordTableViewCell];
    
    [self.view addSubview:self.headerView];
    self.headerView.hidden = YES;
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view);
        make.leading.right.trailing.equalTo(self.view);
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
//    if (!self.itemView) {
//        self.itemView = [[YTItemView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30.f)  Items:self.itemArray];
//        self.itemView.backgroundColor = [UIColor whiteColor];
//        WEAKSELF
//        self.itemView.itemSeletedBlock = ^(NSInteger item){
//            weakSelf.cellStyle = item;
//            [weakSelf.homePageTable reloadData];
//        };
//    }
//    
//    [itemBgView addSubview:_itemView];
    
    return itemBgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Getters
- (WYIncomeRecordHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = (WYIncomeRecordHeaderView *)[[NSBundle mainBundle] loadNibNamed:@"WYIncomeRecordHeaderView" owner:self options:nil].lastObject;
        _headerView.delegate = self;
        
    }
    return _headerView;
}

#pragma mark - WYIncomeRecordHeaderViewDelegate
- (void)clickCurrencyButtonDelegate:(NSString *)currencyString
{
//    [self.rightButton setTitle:currencyString forState:UIControlStateNormal];
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
