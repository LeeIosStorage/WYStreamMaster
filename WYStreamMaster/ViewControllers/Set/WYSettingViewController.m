//
//  WYSettingViewController.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/5/12.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYSettingViewController.h"

@interface WYSettingViewController ()
<
UITableViewDataSource,
UITableViewDelegate
>

@property (nonatomic, strong) NSMutableArray *serverLists;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation WYSettingViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"切换服务器(选后杀掉重启)"];
    
    self.serverLists = [[NSMutableArray alloc] init];
    [self.serverLists addObject:defaultNetworkHost];
    [self.serverLists addObject:defaultNetworkPreRelease];
    [self.serverLists addObject:defaultNetworkHostTest];
    [self.serverLists addObject:@"183.60.106.181:80"];
    [self.serverLists addObject:@"103.230.243.174:80"];
    
    [self.tableView reloadData];
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.serverLists.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifierCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    NSString *server = self.serverLists[indexPath.row];
    cell.textLabel.text = server;
    cell.textLabel.textColor = [UIColor blackColor];
    
    if ([server isEqualToString:[WYAPIGenerate sharedInstance].netWorkHost]) {
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    
    NSString *object = self.serverLists[indexPath.row];
    [WYAPIGenerate sharedInstance].netWorkHost = object;
    NSUserDefaults *originalDefaults = [NSUserDefaults standardUserDefaults];
    if (object && ![object isKindOfClass:[NSNull class]]) {
        [originalDefaults setObject:object forKey:kNetworkHostCacheKey];
    }
    
    [self.tableView reloadData];
}

@end
