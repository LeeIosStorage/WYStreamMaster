//
//  WYHelpDetailViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/11/9.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYHelpDetailViewController.h"
#import "WYHelpDetailCell.h"
@interface WYHelpDetailViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, assign) NSInteger imageHeight;
@end

@implementation WYHelpDetailViewController
- (instancetype)initHelpDetailViewController:(NSString *)imageName imageHeight:(NSInteger)imageHeight
{
    if (self = [super init]) {
        self.imageName = imageName;
        self.imageHeight = imageHeight;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"WYHelpDetailCell" bundle:nil] forCellReuseIdentifier:@"cell"];

    // Do any additional setup after loading the view from its nib.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return SCREEN_HEIGHT;
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cell";
    WYHelpDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    cell.imageView.image = [UIImage imageNamed:self.imageName];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.imageHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .1;
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
