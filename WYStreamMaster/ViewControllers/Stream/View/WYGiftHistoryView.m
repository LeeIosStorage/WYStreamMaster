//
//  WYGiftHistoryView.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/24.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYGiftHistoryView.h"
#import "WYGiftHistoryModel.h"

@interface WYGiftHistoryView ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) NSMutableArray *giftHistoryList;

@property (nonatomic, strong) UIView *contentContainerView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UITableView *tableView;

@property (strong, nonatomic) WYNetWorkManager  *networkManager;

@end

@implementation WYGiftHistoryView

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
    
    self.giftHistoryList = [[NSMutableArray alloc] init];
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    
    UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    [self addGestureRecognizer:gestureRecongnizer];
    
    [self addSubview:self.contentContainerView];
    [self.contentContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(300, 273));
    }];
    
    [self.contentContainerView addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.contentContainerView);
        make.height.mas_equalTo(35);
    }];
    
    [self.contentContainerView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentContainerView);
        make.height.mas_equalTo(62);
    }];
    
    [self.contentContainerView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentContainerView);
        make.top.equalTo(self.topView.mas_bottom);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.top = 15;
    insets.bottom = 15;
    self.tableView.contentInset = insets;
    
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [self onBgClick];
}

- (void)updateGiftHistoryList{
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"get_gift_record"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"rec_user_code"];
    [paramsDic setObject:[NSNumber numberWithInt:1] forKey:@"page"];
    
    WEAKSELF
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:[WYGiftHistoryModel class] success:^(WYRequestType requestType, NSString *message, id dataObject) {
        //        NSLog(@"error:%@ data:%@",message,dataObject);
        
        if (requestType == WYRequestTypeSuccess) {
            
            weakSelf.giftHistoryList = [[NSMutableArray alloc] init];
            if ([dataObject isKindOfClass:[NSArray class]]) {
                [weakSelf.giftHistoryList addObjectsFromArray:dataObject];
            }
            
            [weakSelf.tableView reloadData];
            
        }else{
//            [MBProgressHUD showError:message toView:nil];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_server_request_errer_tip"] toView:nil];
    }];
    
}

#pragma mark -
#pragma mark - Button Clicked
- (void)onBgClick
{
    [self endEditing:YES];
    [self hide];
}

- (void)show
{
    if (![self superview] || self.hidden) {
        [self updateGiftHistoryList];
        
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
    return _giftHistoryList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}
static int userNameLabel_tag = 201, giftImageView_tag = 202,numLabel_tag = 203,timeLabel_tag = 204;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *leftLabel = [[UILabel alloc] init];
        leftLabel.text = @"收到";
        leftLabel.textAlignment = NSTextAlignmentLeft;
        leftLabel.textColor = [UIColor colorWithHexString:@"343434"];
        leftLabel.font = [UIFont systemFontOfSize:10];
        [cell.contentView addSubview:leftLabel];
        [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView).offset(23);
            make.top.bottom.equalTo(cell.contentView);
        }];
        
        UILabel *userNameLabel = [[UILabel alloc] init];
        userNameLabel.text = @"--";
        userNameLabel.textAlignment = NSTextAlignmentLeft;
        userNameLabel.textColor = [UIColor colorWithHexString:@"ff9600"];
        userNameLabel.font = [UIFont systemFontOfSize:12];
        userNameLabel.shadowOffset = CGSizeMake(0.5, 1);
        userNameLabel.shadowColor = [UIColor colorWithHex:0 withAlpha:0.4];
        userNameLabel.tag = userNameLabel_tag;
        [cell.contentView addSubview:userNameLabel];
        [userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftLabel.mas_right).offset(10);
            make.top.bottom.equalTo(cell.contentView);
            make.width.mas_equalTo(80);
        }];
        
        UILabel *middleLabel = [[UILabel alloc] init];
        middleLabel.text = @"的";
        middleLabel.textAlignment = NSTextAlignmentLeft;
        middleLabel.textColor = [UIColor colorWithHexString:@"343434"];
        middleLabel.font = [UIFont systemFontOfSize:10];
        [cell.contentView addSubview:middleLabel];
        [middleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(userNameLabel.mas_right).offset(5);
            make.top.bottom.equalTo(cell.contentView);
        }];
        
        UIImageView *giftImageView = [[UIImageView alloc] init];
        giftImageView.tag = giftImageView_tag;
        [cell.contentView addSubview:giftImageView];
        [giftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(middleLabel.mas_right).offset(15);
            make.centerY.equalTo(cell.contentView);
            make.size.mas_equalTo(CGSizeMake(35, 35));
        }];
        
        UILabel *numLabel = [[UILabel alloc] init];
        numLabel.text = @"--";
        numLabel.textAlignment = NSTextAlignmentLeft;
        numLabel.textColor = [UIColor colorWithHexString:@"ff006c"];
        numLabel.font = [UIFont systemFontOfSize:12];
        numLabel.shadowOffset = CGSizeMake(0.5, 1);
        numLabel.shadowColor = [UIColor colorWithHex:0 withAlpha:0.4];
        numLabel.tag = numLabel_tag;
        [cell.contentView addSubview:numLabel];
        [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(giftImageView.mas_right).offset(11);
            make.top.bottom.equalTo(cell.contentView);
        }];
        
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.text = @"--";
        timeLabel.textAlignment = NSTextAlignmentLeft;
        timeLabel.textColor = [UIColor colorWithHexString:@"343434"];
        timeLabel.font = [UIFont systemFontOfSize:10];
        timeLabel.tag = timeLabel_tag;
        [cell.contentView addSubview:timeLabel];
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.contentView).offset(-23);
            make.top.bottom.equalTo(cell.contentView);
        }];
        
    }
    
    UILabel *userNameLabel = [cell.contentView viewWithTag:userNameLabel_tag];
    UIImageView *giftImageView = [cell.contentView viewWithTag:giftImageView_tag];
    UILabel *numLabel = [cell.contentView viewWithTag:numLabel_tag];
    UILabel *timeLabel = [cell.contentView viewWithTag:timeLabel_tag];
    
    WYGiftHistoryModel *giftHistoryModel = [self.giftHistoryList objectAtIndex:indexPath.row];
    userNameLabel.text = giftHistoryModel.sendNickName;
    numLabel.text = [NSString stringWithFormat:@"x%@",giftHistoryModel.giftNumber];
    NSString *timeTetx = [WYCommonUtils dateHourToMinuteDiscriptionFromDate:[WYCommonUtils dateFromUSDateString:giftHistoryModel.giftTime]];
    timeLabel.text = timeTetx;
    
    NSURL *avatarUrl = [NSURL URLWithString:giftHistoryModel.giftLogo];
    [WYCommonUtils setImageWithURL:avatarUrl setImageView:giftImageView placeholderImage:@"wy_common_placehoder_image"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
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

- (UIView *)contentContainerView{
    if (!_contentContainerView) {
        _contentContainerView = [[UIView alloc] init];
        _contentContainerView.backgroundColor = [UIColor clearColor];
        _contentContainerView.layer.cornerRadius = 4;
        _contentContainerView.layer.masksToBounds = YES;
        [_contentContainerView.layer setBorderWidth:0.5];
        [_contentContainerView.layer setBorderColor:[UIColor whiteColor].CGColor];
    }
    return _contentContainerView;
}

- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = [WYCommonUtils acquireCurrentLocalizedText:@"礼物历史"];
        [_topView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_topView);
        }];
        
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.backgroundColor = [UIColor whiteColor];
        [_topView addSubview:lineImageView];
        [lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(_topView);
            make.height.mas_equalTo(0.5);
        }];
    }
    return _topView;
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorWithHexString:@"DDDDDD"];
        
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.backgroundColor = [UIColor colorWithHexString:@"BCBCBC"];
        [_bottomView addSubview:lineImageView];
        [lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_bottomView);
            make.left.equalTo(_bottomView).offset(20);
            make.right.equalTo(_bottomView).offset(-20);
            make.height.mas_equalTo(0.5);
        }];
        
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmButton.layer.cornerRadius = 3;
        confirmButton.layer.masksToBounds = YES;
        [confirmButton setTitle:[WYCommonUtils acquireCurrentLocalizedText:@"wy_affirm"] forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        confirmButton.backgroundColor = [UIColor colorWithHexString:@"FF7300"];
        confirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_bottomView addSubview:confirmButton];
        [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_bottomView);
            make.size.mas_equalTo(CGSizeMake(80, 28));
        }];
        [confirmButton addTarget:self action:@selector(onBgClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor colorWithHexString:@"DDDDDD"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _tableView;
}

@end
