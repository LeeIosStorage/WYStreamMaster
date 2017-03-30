//
//  WYContributionListView.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/22.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYContributionListView.h"
#import "WYGiftContributionModel.h"

@interface WYContributionListView ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) NSMutableArray *grossContributionList;
@property (nonatomic, strong) NSMutableDictionary *mutRecordDic;

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) NSInteger selectedSegmentIndex;

@property (nonatomic, strong) UITableView *tableView;

@property (strong, nonatomic) WYNetWorkManager  *networkManager;

@end

@implementation WYContributionListView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark -
#pragma mark - Private Methods
- (void)setup{
    
    self.grossContributionList = [[NSMutableArray alloc] init];
    self.mutRecordDic = [[NSMutableDictionary alloc] init];
    _selectedSegmentIndex = 1;
    [self.segmentedControl setSelectedSegmentIndex:_selectedSegmentIndex];
    [self refreshGiftRecordListWithIndex:_selectedSegmentIndex];
    
    UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    [self addGestureRecognizer:gestureRecongnizer];
    
    
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effe = [[UIVisualEffectView alloc]initWithEffect:blur];
    effe.frame = CGRectMake(0, 0 , self.width,self.height);
    [effe setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self insertSubview:effe atIndex:0];
    
    
    [self addSubview:self.segmentedControl];
    [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(40);
        make.left.equalTo(self).offset(50);
        make.right.equalTo(self).offset(-50);
        make.height.mas_equalTo(31);
    }];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.segmentedControl.mas_bottom).offset(50);
        make.bottom.equalTo(self).offset(-50);
    }];
    
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [self onBgClick];
}

#pragma mark -
#pragma mark - Server
- (void)refreshGiftRecordListWithIndex:(NSInteger)index{
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"gift_ranking"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"anchorId"];
    
    WEAKSELF
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
//        NSLog(@"error:%@ data:%@",message,dataObject);
        
        if (requestType == WYRequestTypeSuccess) {
            
            weakSelf.grossContributionList = [[NSMutableArray alloc] init];
            
            weakSelf.mutRecordDic = [[NSMutableDictionary alloc] init];
            
            NSMutableArray *weekArray = [NSMutableArray array];
            for (NSDictionary *dic in [dataObject objectForKey:@"week"]) {
                //dictionaryWithPlistString
                WYGiftContributionModel *giftContributionModel = [[WYGiftContributionModel alloc] init];
                [giftContributionModel modelSetWithDictionary:dic];
                [weekArray addObject:giftContributionModel];
            }
            [weakSelf.mutRecordDic setObject:weekArray forKey:@"0"];
            
            NSMutableArray *monthArray = [NSMutableArray array];
            for (NSDictionary *dic in [dataObject objectForKey:@"month"]) {
                //dictionaryWithPlistString
                WYGiftContributionModel *giftContributionModel = [[WYGiftContributionModel alloc] init];
                [giftContributionModel modelSetWithDictionary:dic];
                [monthArray addObject:giftContributionModel];
            }
            [weakSelf.mutRecordDic setObject:monthArray forKey:@"1"];
            
            NSMutableArray *totalArray = [NSMutableArray array];
            for (NSDictionary *dic in [dataObject objectForKey:@"total"]) {
                //dictionaryWithPlistString
                WYGiftContributionModel *giftContributionModel = [[WYGiftContributionModel alloc] init];
                [giftContributionModel modelSetWithDictionary:dic];
                [totalArray addObject:giftContributionModel];
            }
            [weakSelf.mutRecordDic setObject:totalArray forKey:@"2"];
            
            
            [weakSelf segmentedControlAction:weakSelf.segmentedControl];
            
        }else{
            [MBProgressHUD showError:message toView:nil];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD showAlertMessage:@"请求失败，请检查您的网络设置后重试" toView:nil];
    }];
    
}

#pragma mark -
#pragma mark - Button Clicked
- (void)onBgClick
{
    [self endEditing:YES];
    [self hide];
}

-(void)segmentedControlAction:(UISegmentedControl *)sender{
    _selectedSegmentIndex = sender.selectedSegmentIndex;
    self.grossContributionList = [NSMutableArray arrayWithArray:[self.mutRecordDic objectForKey:[NSString stringWithFormat:@"%d",(int)_selectedSegmentIndex]]];
    [self.tableView reloadData];
}

- (void)show
{
    if (![self superview] || self.hidden) {
        [UIView animateWithDuration:0.3f animations:^{
            [[UIApplication sharedApplication].keyWindow addSubview:self];
            [self setHidden:NO];
        }];
    }
}

- (void)hide
{
    if ([self superview]) {
        [UIView animateWithDuration:0.3f animations:^{
            [self setHidden:YES];
            [self endEditing:YES];
        }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _grossContributionList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 37;
}

static int medalImageView_tag = 201, nameLabel_tag = 202, priceLabel_tag = 203;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        
        UIImageView *medalImageView = [[UIImageView alloc] init];
        [cell.contentView addSubview:medalImageView];
        medalImageView.tag = medalImageView_tag;
        [medalImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView).offset(70);
            make.centerY.equalTo(cell.contentView);
            make.size.mas_equalTo(CGSizeMake(25, 25));
        }];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.text = @"--";
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont systemFontOfSize:10];
        nameLabel.tag = nameLabel_tag;
        nameLabel.shadowOffset = CGSizeMake(1, 1);
        nameLabel.shadowColor = [UIColor colorWithHex:0 withAlpha:0.4];
        [cell.contentView addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(medalImageView.mas_right).offset(10);
            make.top.bottom.equalTo(cell.contentView);
            make.right.equalTo(cell.contentView.mas_centerX);
        }];
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.text = @"--";
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.textColor = [UIColor whiteColor];
        priceLabel.font = [UIFont systemFontOfSize:10];
        priceLabel.tag = priceLabel_tag;
        priceLabel.shadowOffset = CGSizeMake(1, 1);
        priceLabel.shadowColor = [UIColor colorWithHex:0 withAlpha:0.4];
        [cell.contentView addSubview:priceLabel];
        [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView.mas_centerX);
            make.top.bottom.equalTo(cell.contentView);
            make.width.mas_equalTo(110);
        }];
        
    }
    
    UIImageView *medalImageView = [cell.contentView viewWithTag:medalImageView_tag];
    UILabel *nameLabel = [cell.contentView viewWithTag:nameLabel_tag];
    UILabel *priceLabel = [cell.contentView viewWithTag:priceLabel_tag];
    
    WYGiftContributionModel *contributionInfo = [self.grossContributionList objectAtIndex:indexPath.row];
    
    NSString *nickName = contributionInfo.nickName;
    if (nickName.length == 0) {
        nickName = @"--";
    }
    nameLabel.text = nickName;
    
    priceLabel.text = [WYCommonUtils planMaxNumberToString:contributionInfo.giftTotalValue];

    medalImageView.hidden = YES;
    if (indexPath.row == 0) {
        medalImageView.hidden = NO;
        medalImageView.image = [UIImage imageNamed:@"wy_rank_medal_1"];
        nameLabel.textColor = [UIColor colorWithHexString:@"fc1776"];
        nameLabel.font = [UIFont boldSystemFontOfSize:13];//[UIFont fontWithName:@"Helvetica-Bold" size:13.f]
        priceLabel.textColor = [UIColor colorWithHexString:@"fc1776"];
        priceLabel.font = [UIFont boldSystemFontOfSize:13];
        
    }else if (indexPath.row == 1){
        medalImageView.hidden = NO;
        medalImageView.image = [UIImage imageNamed:@"wy_rank_medal_2"];
        nameLabel.textColor = [UIColor colorWithHexString:@"ffc800"];
        nameLabel.font = [UIFont boldSystemFontOfSize:13];
        priceLabel.textColor = [UIColor colorWithHexString:@"ffc800"];
        priceLabel.font = [UIFont boldSystemFontOfSize:13];
        
    }else if (indexPath.row == 2){
        medalImageView.hidden = NO;
        medalImageView.image = [UIImage imageNamed:@"wy_rank_medal_3"];
        nameLabel.textColor = [UIColor colorWithHexString:@"3ec1ff"];
        nameLabel.font = [UIFont boldSystemFontOfSize:13];
        priceLabel.textColor = [UIColor colorWithHexString:@"3ec1ff"];
        priceLabel.font = [UIFont boldSystemFontOfSize:13];
        
    }else{
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont systemFontOfSize:13];
        priceLabel.textColor = [UIColor whiteColor];
        priceLabel.font = [UIFont systemFontOfSize:13];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    //    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

#pragma mark -
#pragma mark - Getters and Setters
- (WYNetWorkManager *)networkManager
{
    if (!_networkManager) {
        _networkManager = [[WYNetWorkManager alloc] init];
    }
    return _networkManager;
}
- (UISegmentedControl *)segmentedControl{
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"贡献周榜",@"贡献月榜",@"贡献总榜", nil]];
        _segmentedControl.layer.masksToBounds = YES;
        _segmentedControl.layer.cornerRadius = 15;
        [_segmentedControl.layer setBorderWidth:1];
        [_segmentedControl.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor whiteColor]};
        NSDictionary *selectedAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"333333"]};
        [_segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [_segmentedControl setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
        _segmentedControl.tintColor = [UIColor whiteColor];
//        _segmentedControl.backgroundColor = [UIColor colorWithHexString:@"5A535A"];
        _segmentedControl.selectedSegmentIndex = 1;
        [_segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _tableView;
}

@end
