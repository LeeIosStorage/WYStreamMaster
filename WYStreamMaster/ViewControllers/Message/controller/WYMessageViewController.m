//
//  WYMessageViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/26.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYMessageViewController.h"
#import "WYMessageTableViewCell.h"
#import "WYMessageModel.h"
@interface WYMessageViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *messageArray;
@property (nonatomic, assign) int startIndexPage;
@end

@implementation WYMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startIndexPage = 1;
    self.title = @"我的消息";
    [self setupView];
    [self setupData];
    [self getMessageRequest];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - setup
- (void)setupView
{

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"WYMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    WEAKSELF
    [self addRefreshHeaderWithBlock:^{
        self.startIndexPage = 1;
        [weakSelf getMessageRequest];
    }];
    
    [self addRefreshFooterWithBlock:^{
        [weakSelf getMessageRequest];
    }];
}

- (void)setupData
{
    self.messageArray = [NSMutableArray array];
}

#pragma mark -
#pragma mark - Server
- (void)getMessageRequest{
    if (self.startIndexPage == 1) {
        [self.messageArray removeAllObjects];
    }
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"get_messages"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"user_code"];
    [paramsDic setObject:@"20" forKey:@"page_size"];
    [paramsDic setObject:[NSString stringWithFormat:@"%d", self.startIndexPage] forKey:@"cur_page"];

    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        if (requestType == WYRequestTypeSuccess) {
            weakSelf.startIndexPage ++;
            NSDictionary *dataDic = (NSDictionary *)dataObject;
            if ([dataObject isKindOfClass:[NSArray class]]) {
                return ;
            }
            NSArray *object = [NSArray modelArrayWithClass:[WYMessageModel class] json:[dataDic objectForKey:@"list"]];
            [weakSelf.messageArray addObjectsFromArray:object];
            if (object.count < 20) {
                [weakSelf hideRefreshFooter];
            }
            [weakSelf.tableView reloadData];
        }else{
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        [weakSelf endRefreshHeader];
        [weakSelf endRefreshFooter];

    } failure:^(id responseObject, NSError *error) {
        [weakSelf endRefreshHeader];
        [weakSelf endRefreshFooter];

        //        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_failure_tip"] toView:weakSelf.view];
    }];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.messageArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WYMessageModel *messageModel = self.messageArray[section];
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithHexString:@"fafafa"];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 95) / 2.0, 15, 95, 30)];
    if (messageModel.create_date.length > 10) {
        headerLabel.text = [messageModel.create_date substringToIndex:10];
    } else {
        headerLabel.text = messageModel.create_date;
    }
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    headerLabel.backgroundColor = [UIColor colorWithHexString:@"c8c8c8"];
    [headerLabel setTextColor:[UIColor colorWithHexString:@"ffffff"]];
    headerLabel.font = [UIFont systemFontOfSize:12.0];
    headerLabel.layer.cornerRadius = 15.0;
    headerLabel.layer.masksToBounds = YES;
    [headerView addSubview:headerLabel];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cell";
    WYMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    WYMessageModel *messageModel = self.messageArray[indexPath.section];
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"fafafa"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell updateMessageCellData:messageModel];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
