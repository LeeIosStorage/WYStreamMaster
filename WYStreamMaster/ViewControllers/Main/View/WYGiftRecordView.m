//
//  WYGiftRecordView.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/17.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYGiftRecordView.h"
#import "UIColor+Hex.h"
#import "WYGiftRecordModel.h"

@interface WYGiftRecordView ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) NSMutableArray *giftRecordList;
@property (nonatomic, strong) NSMutableDictionary *mutRecordDic;

@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) NSInteger selectedSegmentIndex;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *sectionHeadView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UILabel *totalPriceLabel;

@property (strong, nonatomic) WYNetWorkManager  *networkManager;

@end

@implementation WYGiftRecordView

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
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.bgColor = [UIColor colorWithHexString:@"5A535A" withAlpha:0.8];
    
    self.giftRecordList = [[NSMutableArray alloc] init];
    self.mutRecordDic = [[NSMutableDictionary alloc] init];
    _selectedSegmentIndex = 1;
    [self.segmentedControl setSelectedSegmentIndex:_selectedSegmentIndex];
    [self refreshGiftRecordListWithIndex:_selectedSegmentIndex];
    
    
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(145);
        make.size.mas_equalTo(CGSizeMake(274, 297));
    }];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        
        CGRect bounds = CGRectMake(0, 0, 274, 297);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(15, 15)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = bounds;
        maskLayer.path = maskPath.CGPath;
        self.containerView.layer.mask = maskLayer;
        
//        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//        UIVisualEffectView *effe = [[UIVisualEffectView alloc]initWithEffect:blur];
////        effe.contentView.backgroundColor = [UIColor colorWithHexString:@"5A535A" withAlpha:0.2];
//        effe.frame = CGRectMake(0, 0 , self.containerView.width,self.containerView.height);
//        [effe setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//        [self.containerView insertSubview:effe atIndex:0];
        
        
    }
    
    [self addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.right.equalTo(self.containerView.mas_right);
        make.bottom.equalTo(self.containerView.mas_top).offset(-10);
    }];
    
    UIImageView *blurImageView = [[UIImageView alloc] init];
    blurImageView.image = [UIImage imageNamed:@"wy_gift_box_blur_bg"];
    [self.containerView addSubview:blurImageView];
    [blurImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView);
    }];
    
    [self.containerView addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView);
    }];
    
    
    [self.containerView addSubview:self.segmentedControl];
    [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.containerView);
        make.height.mas_equalTo(31);
    }];
    
    [self.containerView addSubview:self.sectionHeadView];
    [self.sectionHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.containerView);
        make.top.equalTo(self.segmentedControl.mas_bottom);
        make.height.mas_equalTo(45);
    }];
    
    [self.containerView addSubview:self.footerView];
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(10);
        make.right.equalTo(self.containerView).offset(-10);
        make.bottom.equalTo(self.containerView);
        make.height.mas_equalTo(30);
    }];
    
    [self.containerView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(0);
        make.right.equalTo(self.containerView).offset(0);
        make.top.equalTo(self.sectionHeadView.mas_bottom);
        make.bottom.equalTo(self.footerView.mas_top);
    }];
    
}

#pragma mark -
#pragma mark - Server
- (void)refreshGiftRecordListWithIndex:(NSInteger)index{
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"gift_num_ranking"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"anchorId"];
    
    WEAKSELF
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
//        NSLog(@"error:%@ data:%@",message,dataObject);
        
        if (requestType == WYRequestTypeSuccess) {
            
            weakSelf.giftRecordList = [[NSMutableArray alloc] init];
            
            weakSelf.mutRecordDic = [[NSMutableDictionary alloc] init];
            NSMutableArray *dayArray = [NSMutableArray array];
            for (NSDictionary *dic in [dataObject objectForKey:@"day"]) {
                //dictionaryWithPlistString
                WYGiftRecordModel *giftRecordModel = [[WYGiftRecordModel alloc] init];
                [giftRecordModel modelSetWithDictionary:dic];
                [dayArray addObject:giftRecordModel];
            }
            [weakSelf.mutRecordDic setObject:dayArray forKey:@"0"];
            
            NSMutableArray *weekArray = [NSMutableArray array];
            for (NSDictionary *dic in [dataObject objectForKey:@"week"]) {
                //dictionaryWithPlistString
                WYGiftRecordModel *giftRecordModel = [[WYGiftRecordModel alloc] init];
                [giftRecordModel modelSetWithDictionary:dic];
                [weekArray addObject:giftRecordModel];
            }
            [weakSelf.mutRecordDic setObject:weekArray forKey:@"1"];
            
            NSMutableArray *monthArray = [NSMutableArray array];
            for (NSDictionary *dic in [dataObject objectForKey:@"month"]) {
                //dictionaryWithPlistString
                WYGiftRecordModel *giftRecordModel = [[WYGiftRecordModel alloc] init];
                [giftRecordModel modelSetWithDictionary:dic];
                [monthArray addObject:giftRecordModel];
            }
            [weakSelf.mutRecordDic setObject:monthArray forKey:@"2"];
            
            
            [weakSelf segmentedControlAction:weakSelf.segmentedControl];
//            weakSelf.giftRecordList = [weakSelf.mutRecordDic objectForKey:[NSString stringWithFormat:@"%d",(int)_selectedSegmentIndex]];
//            
//            [weakSelf.tableView reloadData];
            
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
    self.giftRecordList = [NSMutableArray arrayWithArray:[self.mutRecordDic objectForKey:[NSString stringWithFormat:@"%d",(int)_selectedSegmentIndex]]];
    [self.tableView reloadData];
    
    int totalPrice = 0;
    for (WYGiftRecordModel *model in self.giftRecordList) {
        totalPrice += [model.giftPrice intValue];
    }
    
    self.totalPriceLabel.text = [NSString stringWithFormat:@"%d",totalPrice];
}

- (void)show
{
    if (![self superview] || self.hidden) {
        [self refreshGiftRecordListWithIndex:_selectedSegmentIndex];
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
    return _giftRecordList.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 45;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    
//    return self.sectionHeadView;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

static int typeLabel_tag = 201, numLabel_tag = 202, priceLabel_tag = 203;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *typeLabel = [[UILabel alloc] init];
        typeLabel.text = @"--";
        typeLabel.textAlignment = NSTextAlignmentCenter;
        typeLabel.textColor = [UIColor colorWithHexString:@"FFB82F"];
        typeLabel.font = [UIFont systemFontOfSize:12];
        typeLabel.tag = typeLabel_tag;
        [cell.contentView addSubview:typeLabel];
        [typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView).offset(5);
            make.top.bottom.equalTo(cell.contentView);
            make.width.equalTo(cell.contentView.mas_width).multipliedBy(1.0f/3.0f);
        }];
        
        UILabel *numLabel = [[UILabel alloc] init];
        numLabel.text = @"--";
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.textColor = [UIColor colorWithHexString:@"FFB82F"];
        numLabel.font = [UIFont systemFontOfSize:12];
        numLabel.tag = numLabel_tag;
        [cell.contentView addSubview:numLabel];
        [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(cell.contentView);
            make.centerX.equalTo(cell.contentView.mas_centerX);
            make.width.equalTo(cell.contentView.mas_width).multipliedBy(1.0f/3.0f);
        }];
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.text = @"--";
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.textColor = [UIColor colorWithHexString:@"FFB82F"];
        priceLabel.font = [UIFont systemFontOfSize:12];
        priceLabel.tag = priceLabel_tag;
        [cell.contentView addSubview:priceLabel];
        [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.contentView).offset(-5);
            make.top.bottom.equalTo(cell.contentView);
            make.width.equalTo(cell.contentView.mas_width).multipliedBy(1.0f/3.0f);
        }];
        
        UIImageView *bottomLineImageView = [[UIImageView alloc] init];
        bottomLineImageView.backgroundColor = [UIColor colorWithHex:0 withAlpha:0.2];
        [cell.contentView addSubview:bottomLineImageView];
        [bottomLineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView).offset(26);
            make.right.equalTo(cell.contentView).offset(-26);
            make.bottom.equalTo(cell.contentView);
            make.height.mas_equalTo(0.5);
        }];
    }
    
    UILabel *typeLabel = [cell.contentView viewWithTag:typeLabel_tag];
    UILabel *numLabel = [cell.contentView viewWithTag:numLabel_tag];
    UILabel *priceLabel = [cell.contentView viewWithTag:priceLabel_tag];
    WYGiftRecordModel *giftRecordModel = [self.giftRecordList objectAtIndex:indexPath.row];
    typeLabel.text = giftRecordModel.giftName;
    numLabel.text = giftRecordModel.giftNumber;
    priceLabel.text = giftRecordModel.giftPrice;
    
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

- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _closeButton.tintColor = [UIColor whiteColor];
        [_closeButton setImage:[UIImage imageNamed:@"wy_gift_box_close_icon"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(onBgClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _closeButton;
}

- (UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}

- (UIImageView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.image = [UIImage imageNamed:@"wy_gift_box_bg"];
    }
    return _bgImageView;
}

- (UISegmentedControl *)segmentedControl{
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"当天",@"本周",@"本月", nil]];
        _segmentedControl.layer.masksToBounds = YES;
        _segmentedControl.layer.cornerRadius = 15;
        [_segmentedControl.layer setBorderWidth:1];
        [_segmentedControl.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor whiteColor]};
        NSDictionary *selectedAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"333333"]};
        [_segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [_segmentedControl setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
        _segmentedControl.tintColor = [UIColor whiteColor];
        _segmentedControl.backgroundColor = [UIColor colorWithHexString:@"5A535A"];
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

- (UIView *)sectionHeadView{
    if (!_sectionHeadView) {
        _sectionHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 254, 45)];
//        _sectionHeadView.backgroundColor = _bgColor;
        
        UILabel *typeLabel = [[UILabel alloc] init];
        typeLabel.text = @"种类";
        typeLabel.textAlignment = NSTextAlignmentCenter;
        typeLabel.textColor = [UIColor whiteColor];
        typeLabel.font = [UIFont systemFontOfSize:12];
        [_sectionHeadView addSubview:typeLabel];
        [typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_sectionHeadView).offset(5);
            make.top.bottom.equalTo(_sectionHeadView);
            make.width.equalTo(_sectionHeadView.mas_width).multipliedBy(1.0f/3.0f);
        }];
        
        UILabel *numLabel = [[UILabel alloc] init];
        numLabel.text = @"数量";
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.textColor = [UIColor whiteColor];
        numLabel.font = [UIFont systemFontOfSize:12];
        [_sectionHeadView addSubview:numLabel];
        [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_sectionHeadView);
            make.centerX.equalTo(_sectionHeadView.mas_centerX);
            make.width.equalTo(_sectionHeadView.mas_width).multipliedBy(1.0f/3.0f);
        }];
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.text = @"价格";
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.textColor = [UIColor whiteColor];
        priceLabel.font = [UIFont systemFontOfSize:12];
        [_sectionHeadView addSubview:priceLabel];
        [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_sectionHeadView).offset(-5);
            make.top.bottom.equalTo(_sectionHeadView);
            make.width.equalTo(_sectionHeadView.mas_width).multipliedBy(1.0f/3.0f);
        }];
        
        UIImageView *bottomLineImageView = [[UIImageView alloc] init];
        bottomLineImageView.backgroundColor = [UIColor colorWithHex:0 withAlpha:0.2];
        [_sectionHeadView addSubview:bottomLineImageView];
        [bottomLineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_sectionHeadView).offset(26);
            make.right.equalTo(_sectionHeadView).offset(-26);
            make.bottom.equalTo(_sectionHeadView);
            make.height.mas_equalTo(0.5);
        }];
    }
    return _sectionHeadView;
}

- (UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = [UIColor clearColor];
        
        UILabel *typeLabel = [[UILabel alloc] init];
        typeLabel.text = @"总计";
        typeLabel.textAlignment = NSTextAlignmentCenter;
        typeLabel.textColor = [UIColor whiteColor];
        typeLabel.font = [UIFont systemFontOfSize:12];
        [_footerView addSubview:typeLabel];
        [typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(_footerView);
            make.width.equalTo(_footerView.mas_width).multipliedBy(1.0f/3.0f);
        }];
        
        _totalPriceLabel = [[UILabel alloc] init];
        _totalPriceLabel.text = @"--";
        _totalPriceLabel.textAlignment = NSTextAlignmentCenter;
        _totalPriceLabel.textColor = [UIColor whiteColor];
        _totalPriceLabel.font = [UIFont systemFontOfSize:12];
        [_footerView addSubview:_totalPriceLabel];
        [_totalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.bottom.equalTo(_footerView);
            make.width.equalTo(_footerView.mas_width).multipliedBy(1.0f/3.0f);
        }];
    }
    return _footerView;
}

@end
